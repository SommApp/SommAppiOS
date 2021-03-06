//
//  SignupViewController.swift
//  Somm
//
//  Created by Connor Knabe on 2/23/15.
//  Copyright (c) 2015 Somm. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtPassword2: UITextField!
    @IBOutlet weak var btnSignUp: UIButton!
    
    let stringHelper: StringHelper = StringHelper()
    let errorHelper: ErrorHelper = ErrorHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtFirstName.delegate = self
        txtEmail.delegate = self
        txtPassword.delegate = self
        txtPassword2.delegate = self

    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == txtFirstName) {
            txtEmail.becomeFirstResponder()
        } else if (textField == txtEmail) {
            txtPassword.becomeFirstResponder()
        } else if (textField == txtPassword) {
            txtPassword2.becomeFirstResponder()
        } else {
            signupTapped(btnSignUp)
            textField.resignFirstResponder()
        }
        return true
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
        } else if (!stringHelper.containsEmail(email as String)){
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign Up Failed!"
            alertView.message = "You did not enter a correct email address!"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else {
            var post:NSString = "name=\(name)&email=\(email)&password=\(password)&c_password=\(confirm_password)"
            var url:NSURL = NSURL(string: "http://52.11.190.66/mobile/register.php")!
            var postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
            var postLength:NSString = String( postData.length )
            var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.HTTPBody = postData
            request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            var reponseError: NSError?
            var response: NSURLResponse?
            var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)
            if ( urlData != nil ) {
                let res = response as! NSHTTPURLResponse!;
                if (res.statusCode >= 200 && res.statusCode < 300) {
                    var responseData:NSString  = NSString(data:urlData!, encoding:NSUTF8StringEncoding)!
                    var error: NSError?
                    let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData!, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSDictionary
                    let success:NSInteger = jsonData.valueForKey("success") as! NSInteger
                    if(success == 1) {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        var error_msg:NSString
                        
                        if jsonData["error_message"] as? NSString != nil {
                            error_msg = jsonData["error_message"]as! NSString
                        } else {
                            error_msg = "Unknown Error"
                        }
                        var alertView:UIAlertView = UIAlertView()
                        alertView.title = "Sign Up Failed!"
                        alertView.message = error_msg as String
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
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if (count(textField.text) >= 30 && range.length == 0){
            errorHelper.displayTextLengthError()
            return false
        } else {
            return true
        }
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true);
    }
    
}
