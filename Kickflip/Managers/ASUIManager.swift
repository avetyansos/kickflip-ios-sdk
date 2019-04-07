//
//  ASUIManager.swift
//  VideoStreamerTest
//
//  Created by Sos Avetyan on 05/03/2019.
//  Copyright © 2019 Sos Avetyan. All rights reserved.
//

import UIKit

class ASUIManager: NSObject {
    private override init() {
        super.init()
    }
    
    static let shared = ASUIManager()
    
    func showAlert(viewController: UIViewController, error: NSError, completion: (() -> Void)?) {
        
        let message = error.userInfo[NSLocalizedDescriptionKey]
        let alertController = UIAlertController(title: "Error", message: message as? String, preferredStyle: UIAlertController.Style.alert)
        
        let okAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (alertAction) in
            alertController.dismiss(animated: true, completion: {
                if completion != nil {
                    completion!()
                }
            })
        }
        
        alertController.addAction(okAlertAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func showSuccessAlert(viewController: UIViewController, message: String, completion: (() -> Void)?) {
        let alertController = UIAlertController(title: "Success", message: message, preferredStyle: UIAlertController.Style.alert)
        
        let okAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (alertAction) in
            alertController.dismiss(animated: true, completion: {
                if completion != nil {
                    completion!()
                }
            })
        }
        alertController.addAction(okAlertAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func showAttentionAlert(viewController: UIViewController, message: String, completion: (() -> Void)?) {
        let alertController = UIAlertController(title: "Attention", message: message, preferredStyle: UIAlertController.Style.alert)
        
        let okAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (alertAction) in
            alertController.dismiss(animated: true, completion: {
                if completion != nil {
                    completion!()
                }
            })
        }
        alertController.addAction(okAlertAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func showProgressHUD(tag: Int) {
        
//        DispatchQueue.main.async {
//            let progressHUD = MBProgressHUD.showAdded(to: UIApplication.shared.delegate!.window!!, animated: true)
//            progressHUD.tag = tag
//        }
    }
    
    func hideProgressHUD(tag: Int) {
//        DispatchQueue.main.async {
//            MBProgressHUD.hide(for: UIApplication.shared.delegate!.window!!, animated: true)
//        }
    }
    
}

