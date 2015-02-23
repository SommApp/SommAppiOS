//
//  ViewController.swift
//  Somm
//
//  Created by Connor Knabe on 2/11/15.
//  Copyright (c) 2015 Somm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var usernameLabel: UILabel!
    var usernameString = "Welcome "
    
    @IBAction func logoutTapped(sender: UIButton) {
        
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        

        self.performSegueWithIdentifier("goto_login", sender: self)
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        } else {
            
            self.usernameLabel.lineBreakMode = .ByWordWrapping // or NSLineBreakMode.ByWordWrapping
            self.usernameLabel.numberOfLines = 4

            usernameString += prefs.valueForKey("USERNAME") as NSString
            usernameString += "! \n Somm recommends"

            self.usernameLabel.text = usernameString
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

