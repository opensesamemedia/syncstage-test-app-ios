//
//  UIViewController+Extensions.swift
//  SyncStageDemo_iOS
//
//  Created by bilal mahfouz on 08/11/2022.
//

import UIKit

extension UIViewController {
    func showAlert(with title: String, message: String, actions: [UIAlertAction]? = nil) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        if actions == nil {
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
        } else {
            for action in actions! {
                alert.addAction(action)
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
}
