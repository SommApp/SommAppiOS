//
//  SignupViewController.swift
//  Somm
//
//  Created by Connor Knabe on 2/23/15.
//  Copyright (c) 2015 Somm. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtPassword2: UITextField!
    var stringHelper :StringHelper = StringHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func signupTapped(sender: UIButton) {
        var name:NSString = txtFirstName.text as NSString
        var email:NSString = txtEmail.text as NSString
        var password:NSString = txtPassword.text as NSString
        var confirm_password:NSString = txtPassword2.text as NSString
        
        if (stringHelper.isEmailPassBlank(email: email, password: password)||name.isEqualToString("")) {
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign Up Failed!"
            alertView.message = "Please enter your Name, Email, and Password"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else if ( !password.isEqual(confirm_password) ) {
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign Up Failed!"
            alertView.message = "Passwords don't Match"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else if (!stringHelper.containsEmail(email)){
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign Up Failed!"
            alertView.message = "You did not enter a correct email address!"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else {
            var post:NSString = "name=\(name)&email=\(email)&password=\(password)&c_password=\(confirm_password)"
            NSLog("PostData: %@",post);
            var url:NSURL = NSURL(string: "http://52.11.190.66/mobile/register.php")!
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
                NSLog("Response code: %ld", res.statusCode);
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                    NSLog("Response ==> %@", responseData);
                    var error: NSError?
                    let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as NSDictionary
                    let success:NSInteger = jsonData.valueForKey("success") as NSInteger
                    NSLog("Success: %ld", success);
                    if(success == 1) {
                        NSLog("Sign Up SUCCESS");
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        var error_msg:NSString
                        
                        if jsonData["error_message"] as? NSString != nil {
                            error_msg = jsonData["error_message"] as NSString
                        } else {
                            error_msg = "Unknown Error"
                        }
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign Up Failed!"
                        alertView.message = error_msg
                        alertView.delegate = self
                        alertView.addButtonWithTitle("OK")
                        alertView.show()
                    }
                    
                } else {
                    var alertView:UIAlertView = UIAlertView()
                    alertView.title = "Sign Up Failed!"
                    alertView.message = "Connection Failed"
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                }
            }  else {
                var alertView:UIAlertView = UIAlertView()
                alertView.title = "Sign in Failed!"
                alertView.message = "Connection Failure"
                if let error = reponseError {
                    alertView.message = (error.localizedDescription)
                }
                alertView.delegate = self
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
        }
    }
    
    @IBAction func gotoLogin(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: NSSet,
        withEvent event: UIEvent){
            self.view.endEditing(true);
            super.touchesBegan(touches, withEvent: event)
    }
}
