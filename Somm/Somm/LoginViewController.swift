//
//  LoginViewController.swift
//  Somm
//
//  Created by Connor Knabe on 2/23/15.
//  Copyright (c) 2015 Somm. All rights reserved.
//

import UIKit
import LocalAuthentication


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
        //self.authenticateUser()
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
    
    func authenticateUser() {
        // Get the local authentication context.
        let context = LAContext()
        
        // Declare a NSError variable.
        var error: NSError?
        
        // Set the reason string that will appear on the authentication alert.
        var reasonString = "Authentication is needed to access your notes."
        
        // Check if the device can evaluate the policy.
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            [context .evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, evalPolicyError: NSError?) -> Void in
                
                if success {
                    
                }
                else{
                    // If authentication failed then show a message to the console with a short description.
                    // In case that the error is a user fallback, then show the password alert view.
                    println(evalPolicyError?.localizedDescription)
                    
                    switch evalPolicyError!.code {
                        
                    case LAError.SystemCancel.rawValue:
                        println("Authentication was cancelled by the system")
                        
                    case LAError.UserCancel.rawValue:
                        println("Authentication was cancelled by the user")
                        
                    case LAError.UserFallback.rawValue:
                        println("User selected to enter custom password")
                        
                    default:
                        println("Authentication failed")
                        self.displayAuthenticationFailed()
                    }
                }
                
            })]
        }
        else{
            // If the security policy cannot be evaluated then show a short message depending on the error.
            switch error!.code{
                
            case LAError.TouchIDNotEnrolled.rawValue:
                println("TouchID is not enrolled")
                
            case LAError.PasscodeNotSet.rawValue:
                println("A passcode has not been set")
                
            default:
                // The LAError.TouchIDNotAvailable case.
                println("TouchID not available")
            }
            
            // Optionally the error description can be displayed on the console.
            println(error?.localizedDescription)
            
            // Show the custom alert view to allow users to enter the password.
            //self.showPasswordAlert()
        }
    }
    
    func displayAuthenticationFailed(){
        alertView.title = "Authentication failed"
        alertView.message = "Please try again"
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
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
