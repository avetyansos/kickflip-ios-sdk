//
//  Utils.swift
//  VideoStreamerTest
//
//  Created by Sos Avetyan on 3/5/19.
//  Copyright © 2019 Sos Avetyan. All rights reserved.
//

import UIKit

class Utils: NSObject {

    @objc static let shared = Utils()
    
    @objc var streamID = ""
    @objc var baseUploadUrl = ""
}
