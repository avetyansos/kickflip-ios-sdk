//
//  CreateSessionRequestManager.swift
//  VideoStreamerTest
//
//  Created by Sos Avetyan on 05/03/2019.
//  Copyright © 2019 Sos Avetyan. All rights reserved.
//

import UIKit


typealias SuccessCreateSession = ((_ responseObject: Stream) -> Void)
typealias SuccessGetSessions = ((_ responseObject: [Stream]) -> Void)
typealias SuccessStartSession = (( ) -> Void)
typealias SuccessGetUploadSessionURL = ((_ responseObject: UploadUrl) -> Void)

@objc class CreateSessionRequestManager: NSObject {
    
    @objc static let shared = CreateSessionRequestManager()
    
    @objc var requestManager: NetworkRequestManager!
    
    private override init() {
        super.init()
        
        requestManager = NetworkRequestManager()
    }
    
   @objc func createSession(success: @escaping SuccessCreateSession, failure: @escaping FailureHandler){
        let params = [String: Any]()
        
    requestManager.POSTRequestWithUrl(urlTail: AppConstants.createSessionTail, parameters: params, filePath: nil, authToken: "YmF0dGxlYXJlbmE6dG9iYXR0bGUh", showHUD: false, success: { (response) in
            guard let jsonData = try? JSONSerialization.data(withJSONObject: response, options: []) else {return}
            do {
                let decoder = JSONDecoder()
                let session = try decoder.decode(Stream.self, from: jsonData)
                print(session.id!)
                success(session)
            } catch let err {
                print("Err", err)
            }
        }) { (error) in
            failure(error)
        }
        
    }
    
    func getSessions(success: @escaping SuccessGetSessions, failure: @escaping FailureHandler){
        let params = [String: Any]()
        
        requestManager.GETRequestWithUrl(urlTail:  AppConstants.createSessionTail, parameters: params, authToken: "YmF0dGxlYXJlbmE6dG9iYXR0bGUh", showHUD: true, success: { (response) in
            guard let jsonData = try? JSONSerialization.data(withJSONObject: response, options: []) else {return}
            do {
                let decoder = JSONDecoder()
                let sessions = try decoder.decode([Stream].self, from: jsonData)
//                print(session.id!)
                print(sessions)
                success(sessions)
            } catch let err {
                print("Err", err)
            }
        }, failure: { (error) in
            failure(error)
        })
    }
    
    @objc func startSession(success: @escaping SuccessStartSession , failure: @escaping FailureHandler ){
        let params = [String : Any]()
        requestManager.POSTRequestWithUrl(urlTail: Utils.shared.streamID + AppConstants.startSessionTail, parameters: params, filePath: nil, authToken: "YmF0dGxlYXJlbmE6dG9iYXR0bGUh", showHUD: false, success: { (response) in
            success()
        }) { (error) in
            failure(error)
        }
    }
    
    @objc func uploadSessionGetURL(success: @escaping SuccessGetUploadSessionURL, failure: @escaping FailureHandler ){
        let params = [String : Any]()
        requestManager.GETRequestWithUrl(urlTail: Utils.shared.streamID + AppConstants.getUploadBaseUrlTail, parameters: params, authToken: "YmF0dGxlYXJlbmE6dG9iYXR0bGUh", showHUD: false, success: { (response) in
            guard let jsonData = try? JSONSerialization.data(withJSONObject: response, options: []) else {return}
            do {
                let decoder = JSONDecoder()
                let url = try decoder.decode(UploadUrl.self, from: jsonData)
                print(url.url!)
                success(url)
            } catch let err {
                print("Err", err)
            }
        }) { (error) in
            failure(error)
        }
    }
    
}

