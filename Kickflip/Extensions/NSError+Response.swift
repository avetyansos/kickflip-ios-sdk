//
//  NSError+Response.swift
//  VideoStreamerTest
//
//  Created by Sos Avetyan on 05/03/2019.
//  Copyright © 2019 Sos Avetyan. All rights reserved.
//

import UIKit

extension NSError {
    
    func invalidTypeError() -> NSError {
        
        let error = NSError(domain: AppConstants.SSS_ERROR_DOMAIN, code: AppConstants.INVALID_TYPE_CODE, userInfo: [NSLocalizedDescriptionKey: "Invalid Type"])
        
        return error
    }
    
    func invalidTypeError(value:String) -> NSError {
        
        let error = NSError(domain: AppConstants.SSS_ERROR_DOMAIN, code: AppConstants.INVALID_TYPE_CODE, userInfo: [NSLocalizedDescriptionKey: value])
        
        return error
    }
    
    func emptyResponseError() -> NSError {
        
        let error = NSError(domain: AppConstants.SSS_ERROR_DOMAIN, code: AppConstants.EMPTY_RESPONSE_CODE, userInfo: [NSLocalizedDescriptionKey: "AppConstants.AlertMessage"])
        
        return error
    }
    
    func unknownResponseError() -> NSError {
        
        let error = NSError(domain: AppConstants.SSS_ERROR_DOMAIN, code: AppConstants.UNKNOWN_RESPONSE_CODE, userInfo: [NSLocalizedDescriptionKey: "Unknown Response"])
        
        return error
    }
    
    func errorWithParams(params: [String:Any]) -> NSError {
        
        var error: NSError!
        
        if let code = params[AppConstants.CODE_KEY] as? Int, let message = params[AppConstants.MESSAGE_KEY] {
            
            error = NSError(domain: AppConstants.SSS_ERROR_DOMAIN, code: code, userInfo: [NSLocalizedDescriptionKey: message])
        }
        else {
            
            error = self.invalidTypeError() as NSError
        }
        
        return error
    }
}

