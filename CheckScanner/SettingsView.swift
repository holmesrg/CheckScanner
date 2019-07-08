//
//  SettingsView.swift
//  CheckScanner
//
//  Created by Ron Holmes on 7/11/17.
//  Copyright © 2017 Ron Holmes. All rights reserved.
//

import Foundation

class SettingsView: UIViewController, UITextFieldDelegate {
    
    let BCKAppTokenKey = "BCKAppTokenKey"
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let appToken = textField.text else {
            return false
        }
        
        if (appToken.count > 0)
        {
            // Make sure they entered a valid UUID
            guard let _: NSUUID = NSUUID.init(uuidString: appToken) else {
                return false
            }
            
            textField.resignFirstResponder()
            
            if let defaults = UserDefaults.init(suiteName: "group.com.bluecats.checkscanner") {
                defaults.set(textField.text, forKey: BCKAppTokenKey)
            }
            else {
                return false
            }
            
            dismiss(animated: true, completion: nil)
            return true
        }
        else {
            return false
        }
    }
    
}
