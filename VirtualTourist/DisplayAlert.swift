//
//  DisplayAlert.swift
//  OnTheMap
//
//  Created by Dean Copeland on 4/27/17.
//  Copyright © 2017 Dean Copeland. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func alert(title: String = "Error", message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
