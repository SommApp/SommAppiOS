//
//  StringHelper.swift
//  Somm
//
//  Created by Connor Knabe on 2/25/15.
//  Copyright (c) 2015 Somm. All rights reserved.
//

import UIKit

class StringHelper: NSObject {
   
    func containsEmail(email:NSString) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        if let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx) {
            return emailTest.evaluateWithObject(email)
        }
        return false
    }
    
    func isEmailPassBlank(#email: NSString, password: NSString) -> Bool {
        if (email.isEqualToString("") || password.isEqualToString("")){
            return true
        } else {
            return false;
        }
    }
    
    
}
