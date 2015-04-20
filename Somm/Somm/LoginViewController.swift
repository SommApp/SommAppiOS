//
//  LoginViewController.swift
//  Somm
//
//  Created by Connor Knabe on 2/23/15.
//  Copyright (c) 2015 Somm. All rights reserved.
//

import UIKit



class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnSignIn: UIButton!
    
    var stringHelper :StringHelper = StringHelper()
    var error_msg:NSString = ""
    let errorHelper = ErrorHelper()
    
    let alertView:UIAlertView = UIAlertView()

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        txtEmail.delegate = self
        txtPassword.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(textField == txtEmail){
            txtPassword.becomeFirstResponder()
        } else {
            signinTapped(btnSignIn)
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func signinTapped(sender: UIButton) {
        var email:NSString = txtEmail.text
        var password:NSString = txtPassword.text

        if (stringHelper.isEmailPassBlank(email: email, password: password)) {
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign in Failed!"
            alertView.message = "Please enter Email and Password"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        }  else if (!stringHelper.containsEmail(email)) {
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign in Failed!"
            alertView.message = "You did not enter a correct email address!"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else {
            var post:NSString = "email=\(email)&password=\(password)"
            NSLog("PostData: %@",post);
            var url:NSURL = NSURL(string:"http://52.11.190.66/mobile/login.php")!
            var postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
            var postLength:NSString = String( postData.length )
            var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.HTTPBody = postData
            request.setValue(postLength, forHTTPHeaderField: "Content-Length")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            var reponseError: NSError?
            var response: NSURLResponse?
            var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
            if ( urlData != nil ) {
                let res = response as NSHTTPURLResponse!;
                processLoginResponse(email, res: res, urlData: urlData!)
            } else {
                errorHelper.displaySignInFail(error_msg)
            }
        }
        
    }
    
    func processLoginResponse(email:NSString, res: NSHTTPURLResponse,urlData: NSData){
        NSLog("Response code: %ld", res.statusCode);
        if (res.statusCode >= 200 && res.statusCode < 300) {
            var responseData:NSString  = NSString(data:urlData, encoding:NSUTF8StringEncoding)!
            NSLog("Response ==> %@", responseData);
            var error: NSError?
            let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData, options:NSJSONReadingOptions.MutableContainers , error: &error) as NSDictionary
            let success:NSInteger = jsonData.valueForKey("success") as NSInteger
            let name:String = jsonData.valueForKey("firstname") as String
            // let maxMiles:NSInteger = jsonData.valueForKey("maxMiles") as NSInteger
            NSLog("Success: %ld", success);
            if(success == 1) {
                NSLog("Login SUCCESS");
                var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                prefs.setObject(email, forKey: "EMAIL")
                prefs.setObject(name, forKey: "NAME")
                /* this needs to be changed to take in json value*/  prefs.setObject(5, forKey: "MAXMILES")
                prefs.setInteger(1, forKey: "ISLOGGEDIN")
                prefs.synchronize()
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                if jsonData["error_message"] as? NSString != nil {
                    error_msg = jsonData["error_message"] as NSString
                } else {
                    error_msg = "Unknown Error"
                }
                errorHelper.displaySignInFail(error_msg)
            }
        } else {
            errorHelper.displaySignInFail(error_msg)
        }
    }
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: NSSet,
        withEvent event: UIEvent){
            self.view.endEditing(true);
            super.touchesBegan(touches, withEvent: event)
    }
}
