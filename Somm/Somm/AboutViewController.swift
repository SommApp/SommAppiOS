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
        let url = NSURL(string: "https://github.com/connor-knabe")!
        UIApplication.sharedApplication().openURL(url)
    }
    
    @IBAction func btnJackie(sender: AnyObject) {
        let url = NSURL(string: "https://github.com/Jackietrahan")!
        UIApplication.sharedApplication().openURL(url)
    }
    @IBAction func btnPaul(sender: AnyObject) {
        let url = NSURL(string: "https://github.com/pmsthf")!
        UIApplication.sharedApplication().openURL(url)
    }
    @IBAction func btnSeth(sender: AnyObject) {
        let url = NSURL(string: "https://github.com/sjwiesman")!
        UIApplication.sharedApplication().openURL(url)
    }
}