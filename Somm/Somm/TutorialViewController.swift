//
//  TutorialViewController.swift
//  Somm
//
//  Created by Connor Knabe on 4/27/15.
//  Copyright (c) 2015 Somm. All rights reserved.
//


import Foundation
import UIKit

class TutorialViewController:UIViewController {
    
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()

    
    @IBAction func btnStart(sender: AnyObject) {
        prefs.setBool(true, forKey: "TUTORIAL")
        prefs.synchronize()
        self.performSegueWithIdentifier("goto_login", sender: self)
    }
    
}
