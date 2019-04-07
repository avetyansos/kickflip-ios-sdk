//
//  KFHLSUploader.m
//  FFmpegEncoder
//
//  Created by Christopher Ballinger on 12/20/13.
//  Copyright (c) 2013 Christopher Ballinger. All rights reserved.
//

#import "KFHLSUploader.h"
#import "KFS3Stream.h"
#import "KFUser.h"
#import "KFLog.h"
#import "KFAPIClient.h"
#import "KFAWSCredentialsProvider.h"

static NSString * const kManifestKey =  @"manifest";
static NSString * const kFileNameKey = @"fileName";
static NSString * const kFileStartDateKey = @"startDate";

static NSString * const kVODManifestFileName = @"vod.m3u8";


static NSString * const kUploadStateQueued = @"queued";
static NSString * const kUploadStateFinished = @"finished";
static NSString * const kUploadStateUploading = @"uploading";
static NSString * const kUploadStateFailed = @"failed";

static NSString * const kKFS3TransferManagerKey = @"kKFS3TransferManagerKey";
static NSString * const kKFS3Key = @"kKFS3Key";


@interface KFHLSUploader()
@property (nonatomic) NSUInteger numbersOffset;
@property (nonatomic, strong) NSMutableDictionary *queuedSegments;
@property (nonatomic) NSUInteger nextSegmentIndexToUpload;
//@property (nonatomic, strong) AWSS3TransferManager *transferManager;
//@property (nonatomic, strong) AWSS3 *s3;
@property (nonatomic, strong) KFDirectoryWatcher *directoryWatcher;
@property (atomic, strong) NSMutableDictionary *files;
@property (nonatomic, strong) NSString *manifestPath;
@property (nonatomic) BOOL manifestReady;
@property (nonatomic, strong) NSString *finalManifestString;
@property (nonatomic) BOOL isFinishedRecording;
@property (nonatomic) BOOL hasUploadedFinalManifest;
@property (nonatomic, assign) NSInteger segmentIndex;
@property (nonatomic, copy) NSString *durationString;

@property (nonatomic, copy) void (^SuccessHndler)(void);
@end

@implementation KFHLSUploader

- (id) initWithDirectoryPath:(NSString *)directoryPath stream:(KFS3Stream *)stream {
    if (self = [super init]) {
        self.stream = stream;
        _directoryPath = [directoryPath copy];
        __weak KFHLSUploader *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.directoryWatcher = [KFDirectoryWatcher watchFolderWithPath:weakSelf.directoryPath delegate:self];
        });
        _files = [NSMutableDictionary dictionary];
        _scanningQueue = dispatch_queue_create("KFHLSUploader Scanning Queue", DISPATCH_QUEUE_SERIAL);
        _callbackQueue = dispatch_queue_create("KFHLSUploader Callback Queue", DISPATCH_QUEUE_SERIAL);
        _queuedSegments = [NSMutableDictionary dictionaryWithCapacity:5];
        _numbersOffset = 0;
        _nextSegmentIndexToUpload = 0;
        _manifestReady = NO;
        _isFinishedRecording = NO;
        self.manifestGenerator = [[KFHLSManifestGenerator alloc] initWithTargetDuration:10 playlistType:KFHLSManifestPlaylistTypeVOD];
    }
    return self;
}

- (void) finishedRecording {
    self.isFinishedRecording = YES;
    if (!self.hasUploadedFinalManifest) {
        NSString *manifestSnapshot = [self manifestSnapshot];
        NSLog(@"final manifest snapshot: %@", manifestSnapshot);
        [self.manifestGenerator appendFromLiveManifest:manifestSnapshot];
        [self.manifestGenerator finalizeManifest];
        NSString *manifestString = [self.manifestGenerator manifestString];
        [self s3RequestCompletedForFileName:kVODManifestFileName];
    }
}

- (void) setUseSSL:(BOOL)useSSL {
    _useSSL = useSSL;
}

- (void) uploadNextSegment {
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.directoryPath error:nil];
    NSUInteger tsFileCount = 0;
    for (NSString *fileName in contents) {
        if ([[fileName pathExtension] isEqualToString:@"ts"]) {
            tsFileCount++;
        }
    }
    
    
    NSDictionary *segmentInfo = [_queuedSegments objectForKey:@(_nextSegmentIndexToUpload)];
    
    // Skip uploading files that are currently being written
    if (tsFileCount == 1 && !self.isFinishedRecording) {
        NSLog(@"Skipping upload of ts file currently being recorded: %@ %@", segmentInfo, contents);
        return;
    }
    
    NSString *fileName = [segmentInfo objectForKey:kFileNameKey];
    NSString *fileUploadState = [_files objectForKey:fileName];
    if (![fileUploadState isEqualToString:kUploadStateQueued]) {
        NSLog(@"Trying to upload file that isn't queued (%@): %@", fileUploadState, segmentInfo);
        
        return;
    }
    [_files setObject:kUploadStateUploading forKey:fileName];
    NSString *filePath = [_directoryPath stringByAppendingPathComponent:fileName];
    NSURL *dataPath = [NSURL fileURLWithPath:filePath];
    NSData *data = [NSData dataWithContentsOfURL:dataPath];
    NSLog(@"data = %@", data);
    [self startSessionNetworkWith:^{
        [self uploadFragmentToServerwithFileName:fileName andDataPath:dataPath];
    } andFailure:^(NSError *error) {
        NSLog(@"error %@", error.localizedDescription);
    }];
}

- (void)uploadFragmentToServerwithFileName:(NSString*)fileName andDataPath:(NSURL*) dataPath{
    
//    [[UploadSessionRequestManager shared] uploadFragmentWithSeconds:self.durationString segment:(int)self.segmentIndex dataPath:dataPath success:^{
//        [self s3RequestCompletedForFileName:fileName];
//    } failure:^(NSError * error) {
//        NSLog(@"data = %@", error.localizedDescription);
//        [self s3RequestFailedForFileName:fileName withError:error];
//    }];
    
}

- (void)startSessionNetworkWith:(void (^)(void))successHandler andFailure:(void (^)(NSError *error))failureHandler{
//    [[CreateSessionRequestManager shared] startSessionWithSuccess:^{
//        [self getBaseUrlForUpload:^{
//            successHandler();
//        } andFailureWithError:^(NSError *error) {
//            NSLog(@"Error Getttt BAse URLLLLLLL %@", error.localizedDescription);
//        }];
//    } failure:^(NSError * error) {
//        NSLog(@"Errrrrrrrrrrrro Start Session %@", error.localizedDescription);
//    }];
}

- (void)getBaseUrlForUpload:(void (^)(void))success andFailureWithError:(void (^)(NSError *error))failureHandler {
//    [[CreateSessionRequestManager shared] uploadSessionGetURLWithSuccess:^(UploadUrl * url) {
//        [Utils shared].baseUploadUrl = url.url;
//        success();
//    } failure:^(NSError * error) {
//        failureHandler(error);
//    }];
}

- (void) directoryDidChange:(KFDirectoryWatcher *)folderWatcher {
    __weak KFHLSUploader *weakSelf = self;
    dispatch_async(_scanningQueue, ^{
        NSError *error = nil;
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:weakSelf.directoryPath error:&error];
        NSLog(@"Directory changed, fileCount: %lu", (unsigned long)files.count);
        if (error) {
            NSLog(@"Error listing directory contents");
        }
        if (!weakSelf.manifestPath) {
            [self initializeManifestPathFromFiles:files];
        }
        [self detectNewSegmentsFromFiles:files];
    });
}

- (void) detectNewSegmentsFromFiles:(NSArray*)files {
    if (!_manifestPath) {
        NSLog(@"Manifest path not yet available");
        return;
    }
    __weak KFHLSUploader *weakSelf = self;
    [files enumerateObjectsUsingBlock:^(NSString *fileName, NSUInteger idx, BOOL *stop) {
        NSArray *components = [fileName componentsSeparatedByString:@"."];
        NSString *filePrefix = [components firstObject];
        NSString *fileExtension = [components lastObject];
        if ([fileExtension isEqualToString:@"ts"]) {
            NSString *uploadState = [weakSelf.files objectForKey:fileName];
            if (!uploadState) {
                NSString *manifestSnapshot = [self manifestSnapshot];
                self.durationString = [self getDurationFromManifest:manifestSnapshot];
                [self.manifestGenerator appendFromLiveManifest:manifestSnapshot];
                self.segmentIndex = [self indexForFilePrefix:filePrefix];
                NSDictionary *segmentInfo = @{kManifestKey: manifestSnapshot,
                                              kFileNameKey: fileName,
                                              kFileStartDateKey: [NSDate date]};
                NSLog(@"new ts file detected: %@", fileName);
                [weakSelf.files setObject:kUploadStateQueued forKey:fileName];
                [weakSelf.queuedSegments setObject:segmentInfo forKey:@(self.segmentIndex)];
                [self uploadNextSegment];
            }
        }
    }];
}

- (NSString*)getDurationFromManifest:(NSString*)manifest {
    NSArray *components = [manifest componentsSeparatedByString:@"\n"];
    for (NSString *component in components) {
        NSArray *paramsArray = [component componentsSeparatedByString:@":"];
        if ([paramsArray[0] isEqual: @"#EXTINF"]) {
            NSString *correctString = paramsArray[1];
            NSString *durationString = [correctString substringToIndex:correctString.length - 1];
            return durationString;
        }
    }
    return @"";
}

- (void) initializeManifestPathFromFiles:(NSArray*)files {
    __weak KFHLSUploader *weakSelf = self;
    [files enumerateObjectsUsingBlock:^(NSString *fileName, NSUInteger idx, BOOL *stop) {
        if ([[fileName pathExtension] isEqualToString:@"m3u8"]) {
            NSArray *components = [fileName componentsSeparatedByString:@"."];
            NSString *filePrefix = [components firstObject];
            weakSelf.manifestPath = [weakSelf.directoryPath stringByAppendingPathComponent:fileName];
            weakSelf.numbersOffset = filePrefix.length;
            NSAssert(weakSelf.numbersOffset > 0, nil);
            *stop = YES;
        }
    }];
}

- (NSString*) manifestSnapshot {
    return [NSString stringWithContentsOfFile:_manifestPath encoding:NSUTF8StringEncoding error:nil];
}

- (NSUInteger) indexForFilePrefix:(NSString*)filePrefix {
    NSString *numbers = [filePrefix substringFromIndex:_numbersOffset];
    return [numbers integerValue];
}

- (NSURL*) urlWithFileName:(NSString*)fileName {
    //    NSString *key = [self awsKeyForStream:self.stream fileName:fileName];
    NSString *ssl = @"";
    if (self.useSSL) {
        ssl = @"s";
    }
    //    NSString *urlString = [NSString stringWithFormat:@"http%@://%@.s3.amazonaws.com/%@", ssl, self.stream.bucketName, key];
    return [NSURL URLWithString:@"urlString"];
}

- (NSURL*) manifestURL {
    NSString *manifestName = nil;
    if (self.isFinishedRecording) {
        manifestName = kVODManifestFileName;
    } else {
        manifestName = [_manifestPath lastPathComponent];
    }
    return [self urlWithFileName:manifestName];
}

-(void)s3RequestCompletedForFileName:(NSString*)fileName
{
    __weak KFHLSUploader *weakSelf = self;
    dispatch_async(_scanningQueue, ^{
        if ([fileName.pathExtension isEqualToString:@"m3u8"]) {
            dispatch_async(self.callbackQueue, ^{
                if (!weakSelf.manifestReady) {
                    if (self.delegate && [self.delegate respondsToSelector:@selector(uploader:liveManifestReadyAtURL:)]) {
                        [self.delegate uploader:self liveManifestReadyAtURL:[self manifestURL]];
                    }
                    weakSelf.manifestReady = YES;
                }
                if (self.isFinishedRecording && weakSelf.queuedSegments.count == 0) {
                    self.hasUploadedFinalManifest = YES;
                    if (self.delegate && [self.delegate respondsToSelector:@selector(uploader:vodManifestReadyAtURL:)]) {
                        [self.delegate uploader:self vodManifestReadyAtURL:[self manifestURL]];
                    }
                    if (self.delegate && [self.delegate respondsToSelector:@selector(uploaderHasFinished:)]) {
                        [self.delegate uploaderHasFinished:self];
                    }
                }
            });
        } else if ([fileName.pathExtension isEqualToString:@"ts"]) {
            NSDictionary *segmentInfo = [weakSelf.queuedSegments objectForKey:@(weakSelf.nextSegmentIndexToUpload)];
            NSString *filePath = [weakSelf.directoryPath stringByAppendingPathComponent:fileName];
            
            NSString *manifest = [segmentInfo objectForKey:kManifestKey];
            NSDate *uploadStartDate = [segmentInfo objectForKey:kFileStartDateKey];
            
            NSDate *uploadFinishDate = [NSDate date];
            
            NSError *error = nil;
            NSDictionary *fileStats = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
            if (error) {
                NSLog(@"Error getting stats of path %@: %@", filePath, error);
            }
            uint64_t fileSize = [fileStats fileSize];
            
            NSTimeInterval timeToUpload = [uploadFinishDate timeIntervalSinceDate:uploadStartDate];
            double bytesPerSecond = fileSize / timeToUpload;
            double KBps = bytesPerSecond / 1024;
            [weakSelf.files setObject:kUploadStateFinished forKey:fileName];
            
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
            if (error) {
                NSLog(@"Error removing uploaded segment: %@", error.description);
            }
            [weakSelf.queuedSegments removeObjectForKey:@(weakSelf.nextSegmentIndexToUpload)];
            NSUInteger queuedSegmentsCount = weakSelf.queuedSegments.count;
            [self s3RequestCompletedForFileName:@"index.m3u8"];
            weakSelf.nextSegmentIndexToUpload++;
            [self uploadNextSegment];
            if (self.delegate && [self.delegate respondsToSelector:@selector(uploader:didUploadSegmentAtURL:uploadSpeed:numberOfQueuedSegments:)]) {
                NSURL *url = [self urlWithFileName:fileName];
                dispatch_async(self.callbackQueue, ^{
                    [self.delegate uploader:self didUploadSegmentAtURL:url uploadSpeed:KBps numberOfQueuedSegments:queuedSegmentsCount];
                });
            }
        } else if ([fileName.pathExtension isEqualToString:@"jpg"]) {
            [self.files setObject:kUploadStateFinished forKey:fileName];
            if (self.delegate && [self.delegate respondsToSelector:@selector(uploader:thumbnailReadyAtURL:)]) {
                NSURL *url = [self urlWithFileName:fileName];
                dispatch_async(self.callbackQueue, ^{
                    [self.delegate uploader:self thumbnailReadyAtURL:url];
                });
            }
            NSString *filePath = [weakSelf.directoryPath stringByAppendingPathComponent:fileName];
            
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
            if (error) {
                NSLog(@"Error removing thumbnail: %@", error.description);
            }
            self.stream.thumbnailURL = [self urlWithFileName:fileName];
            [[KFAPIClient sharedClient] updateMetadataForStream:self.stream callbackBlock:^(KFStream *updatedStream, NSError *error) {
                if (error) {
                    NSLog(@"Error updating stream thumbnail: %@", error);
                } else {
                    NSLog(@"Updated stream thumbnail: %@", updatedStream.thumbnailURL);
                }
            }];
        }
    });
}

-(void)s3RequestFailedForFileName:(NSString*)fileName withError:(NSError *)error
{
    __weak KFHLSUploader *weakSelf = self;
    dispatch_async(_scanningQueue, ^{
        [weakSelf.files setObject:kUploadStateFailed forKey:fileName];
        NSLog(@"Failed to upload request, requeuing %@: %@", fileName, error.description);
        [self uploadNextSegment];
    });
}

@end
