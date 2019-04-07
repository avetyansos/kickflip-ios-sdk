//
//  AppConstants.swift
//  VideoStreamerTest
//
//  Created by Sos Avetyan on 05/03/2019.
//  Copyright © 2019 Sos Avetyan. All rights reserved.
//

import UIKit

class AppConstants: NSObject {
    static let BASE_URL = "https://app.msrvba.ru/streams/"
    static let createSessionTail = ""
    static let startSessionTail = "/start"
    static let getUploadBaseUrlTail = "/uploadServer"
    static let fragmentUpload = "fragment"
    
    //MARK: error handle
    static let SSS_ERROR_DOMAIN = "com.sss.error"
    static let DATA_VALUE = "value"
    static let DATA_KEY = "user"
    static let TOKEN_KEY = "token"
    static let ERROR_KEY = "error"
    static let SUCCESS_KEY = "status"
    static let FAILURE_KEY = "errors"
    static let CODE_KEY = "code"
    static let MESSAGE_KEY = "message"
    static let INVALID_TYPE_CODE = 50001
    static let EMPTY_RESPONSE_CODE = 50002
    static let UNKNOWN_RESPONSE_CODE = 50003
}
