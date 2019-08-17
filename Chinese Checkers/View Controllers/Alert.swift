//
//  Alert.swift
//  Chinese Checkers
//
//  Created by Thalys Viana on 17/08/19.
//  Copyright © 2019 Thalys Viana. All rights reserved.
//

import UIKit

class Alert {
    
    static func showAlert(title: String?, message: String?, completion: @escaping (Bool) -> Void) -> UIAlertController {
        let alertController = UIAlertController(title: title ?? "Title", message: message ?? "Message", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
            completion(true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    static func showAlert(title: String?, message: String?) -> UIAlertController {
        let alertController = UIAlertController(title: title ?? "Title", message: message ?? "Message", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in }
        alertController.addAction(okAction)
        
        return alertController
    }
    
}
