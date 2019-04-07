//
//  UploadSessionRequestManager.swift
//  VideoStreamerTest
//
//  Created by Sos Avetyan on 06/03/2019.
//  Copyright © 2019 Sos Avetyan. All rights reserved.
//

import UIKit

typealias SuccessUploadFragment = (( ) -> Void)

@objc class UploadSessionRequestManager: NSObject {
    
    @objc static let shared = UploadSessionRequestManager()
    
    @objc var requestManager: NetworkRequestManager!
    
    private override init() {
        super.init()
        
        requestManager = NetworkRequestManager()
    }
    
    @objc func uploadFragment(seconds : String , segment: Int32, dataPath: NSURL, success: @escaping SuccessUploadFragment, failure: @escaping FailureHandler){
        let params:[String: Any] = ["duration" : seconds]
        let url = Utils.shared.streamID + "/" + AppConstants.fragmentUpload + "/" + String(segment) + "?" + "duration=" +
            seconds
        requestManager.POSTRequestWithUrl(urlTail: url, parameters: params, filePath: dataPath, authToken: "YmF0dGxlYXJlbmE6dG9iYXR0bGUh", showHUD: false, success: { (response) in
            success()
        }) { (failure) in
            print(failure)
        }
    }
}
