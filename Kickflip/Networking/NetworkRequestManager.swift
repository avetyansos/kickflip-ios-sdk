//
//  NetworkRequestManager.swift
//  VideoStreamerTest
//
//  Created by Sos Avetyan on 05/03/2019.
//  Copyright © 2019 Sos Avetyan. All rights reserved.
//

import UIKit
import Alamofire
//import MBProgressHUD


typealias RequestSuccessHandler = ((_ responseObject: AnyObject) -> Void)
typealias RequestFreeSuccessHandler = (( ) -> Void)
typealias SuccessRequestHandler = ((_ responseObject: NSDictionary) -> Void)
typealias SuccessResquestArrayHandler = ((_ responseObject: Array<Any>) -> Void)

typealias FailureHandler = ((_ error: NSError) -> Void)

class NetworkRequestManager: NSObject {
    func tagForHUD() -> Int {
        struct Holder {
            static var count = 0
        }
        Holder.count += 1
        return Holder.count
    }
    
    func GETRequestWithUrl(urlTail: String,
                           parameters: Parameters?,
                           authToken: String?,
                           showHUD: Bool,
                           success: @escaping RequestSuccessHandler,
                           failure: @escaping FailureHandler) {
        
        
        let tag = tagForHUD()
        if showHUD {
            ASUIManager.shared.showProgressHUD(tag: tag)
        }
        
        
        let urlRequest: DataRequest = createGETRequestWithURLTail(urlTail: urlTail, parameters: parameters, authToken: authToken)
        urlRequest.validate().responseJSON { response in
            
            self.handleResponse(response: response, showHUD: showHUD, success: { (responseObject) in
                
                if showHUD {
                    ASUIManager.shared.hideProgressHUD(tag: tag)
                }
                
                success(responseObject)
                
            }, failure: { (error) in
                
                if showHUD {
                    ASUIManager.shared.hideProgressHUD(tag: tag)
                }
                
                failure(error)
            })
            if showHUD {
                ASUIManager.shared.hideProgressHUD(tag: tag)
            }
        }
    }
    
    func POSTRequestWithUrl(urlTail: String,
                            parameters: Parameters?,
                            filePath: NSURL?,
                            authToken: String?,
                            showHUD: Bool,
                            success: @escaping RequestSuccessHandler,
                            failure: @escaping FailureHandler) {
        
        
        let tag = tagForHUD()
        if showHUD {
            ASUIManager.shared.showProgressHUD(tag: tag)
        }
        if filePath == nil {
            let urlRequest: DataRequest = createPOSTRequestWithURLTail(urlTail: urlTail, parameters: parameters, authToken: authToken)
            urlRequest.validate().response { (response) in
                print(response)
            }
            urlRequest.validate(statusCode: 200..<600).responseJSON { response in
                
                self.handleResponse(response: response, showHUD: showHUD, success: { (responseObject) in
                    
                    if showHUD {
                        ASUIManager.shared.hideProgressHUD(tag: tag)
                    }
                    
                    success(responseObject)
                    
                }, failure: { (error) in
                    
                    if showHUD {
                        ASUIManager.shared.hideProgressHUD(tag: tag)
                    }
                    
                    failure(error)
                })
            }
        }
        else {
            let urlString = Utils.shared.baseUploadUrl + "/" + "streams/" + urlTail
            print("Upload URL = \(urlString)")
            var headers: HTTPHeaders = [
                "Accept": "application/json",
                "Content-Type": "application/json"
            ]
            
            if authToken != nil {
                headers["Authorization"] = "Basic" + " " + authToken!
            }
            var request = URLRequest(url: URL(string: urlString)!)
            if filePath != nil {
                request.allHTTPHeaderFields = headers
                request.timeoutInterval = 30
                request.httpMethod = "POST"
                let data = try? Data(contentsOf: filePath! as URL)
                print(data!)
                request.httpBody = data

                Alamofire.request(request).validate(statusCode: [200]).response { (response) in
                    print(response)
                    if let error = response.error {
                        failure(error as NSError)
                    }
                    else {
                        success(Array<Any>() as AnyObject)
                    }
                }
            }
        }
    }
    
    func createPOSTRequestWithURLTail(urlTail: String, parameters: Parameters?, authToken: String?) -> DataRequest {
        
        let urlString = AppConstants.BASE_URL + urlTail
        
        var headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        
        if authToken != nil {
            headers["Authorization"] = "Basic" + " " + authToken!
        }
        
        return Alamofire.request(urlString, method: HTTPMethod.post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
    }
    
    func createGETRequestWithURLTail(urlTail: String, parameters: Parameters?, authToken: String?) -> DataRequest {
        
        var urlQuery: String = ""
        if (parameters?.count)! > 0 {
            
            urlQuery += "?"
            let keys = Array(parameters!.keys)
            let count = keys.count
            
            for i in (0..<count) {
                
                let key = keys[i]
                let value = parameters?[key]
                urlQuery += key + "=" + "\(value!)"
                
                if i < count - 1 {
                    urlQuery += "&"
                }
            }
        }
        
        
        let urlString = AppConstants.BASE_URL + urlTail + urlQuery
        
        var headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        
        if authToken != nil {
            headers["Authorization"] = "Basic "/* + " " */+ authToken!
        }
        
        return Alamofire.request(urlString, method: HTTPMethod.get, parameters: nil, /*encoding: JSONEncoding.default,*/ headers: headers)
    }
    
    func handleResponse(response: DataResponse<Any>,
                        showHUD: Bool,
                        success: @escaping RequestSuccessHandler,
                        failure: @escaping FailureHandler) {
        
        switch response.result {
        case .success(let value):
            
            if let resultObject = value as? NSDictionary {
                success(resultObject)
            }
            else if let resArray = value as? Array<Any> {
                success(resArray as AnyObject)
            }
            else {
                failure(NSError().invalidTypeError())
            }
        case .failure(let error):
            failure(error as NSError)
        }
    }
    
}
