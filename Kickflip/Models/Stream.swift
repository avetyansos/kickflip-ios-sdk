//
//  Stream.swift
//  VideoStreamerTest
//
//  Created by Sos Avetyan on 05/03/2019.
//  Copyright © 2019 Sos Avetyan. All rights reserved.
//

import UIKit

@objc class Stream: NSObject, Codable {
    @objc dynamic let id: String?
}

@objc class UploadUrl: NSObject, Codable {
    @objc dynamic let url: String?
}
