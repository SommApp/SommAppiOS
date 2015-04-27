//
//  AboutViewController.swift
//  Somm
//
//  Created by Connor Knabe on 4/27/15.
//  Copyright (c) 2015 Somm. All rights reserved.
//

import Foundation
import UIKit

class AboutViewController:UIViewController {
    
    

    
    @IBAction func btnConnor(sender: AnyObject) {
        let url = NSURL(string: "http://google.com")!
        UIApplication.sharedApplication().openURL(url)
    }
    
    @IBAction func btnJackie(sender: AnyObject) {
    }
    @IBAction func btnPaul(sender: AnyObject) {
    }
    @IBAction func btnSeth(sender: AnyObject) {
    }
}