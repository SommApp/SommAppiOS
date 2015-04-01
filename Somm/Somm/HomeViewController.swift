//
//  ViewController.swift
//  Somm
//
//  Created by Connor Knabe on 2/11/15.
//  Copyright (c) 2015 Somm. All rights reserved.
//

import UIKit
import CoreData



class ViewController: UIViewController {
    @IBOutlet weak var txtLocation: UILabel!
    @IBOutlet weak var txtUpdate: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var error_msg:NSString = ""
    var emailString = ""
    let store = Store()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let reachability = Reachability.reachabilityForInternetConnection()

        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        } else {
            emailString = "Welcome "
            emailString += prefs.valueForKey("EMAIL") as NSString
            emailString += "!"
            self.emailLabel.text = emailString
            //sendVisits()
        }
        reachability.whenUnreachable = { reachability in
            self.displayFailure("network")
        }
        reachability.startNotifier()
        println("Start")
    }
    
    func sendVisits(){
        if let visits = store.grabVisit() as? [NSManagedObject]{
            
            var timeStamp: NSDate
            var arrivalDate: NSDate
            var departureDate: NSDate
            var longitude: Double
            var latitude: Double
            
            for visit in visits{
                timeStamp = visit.valueForKey("timeStamp") as NSDate!
                arrivalDate = visit.valueForKey("arrivalDate") as NSDate!
                departureDate = visit.valueForKey("departureDate") as NSDate!
                longitude = visit.valueForKey("longitude") as Double!
                latitude = visit.valueForKey("latitude") as Double!
                sendGps(timeStamp, arrivalDate: arrivalDate, departureDate: departureDate, longitude: longitude, latitude: latitude)
            }
            
        } else {
            let visits = store.grabVisit()
            if(visits[0].isEqualToString("Failed")){
                println("Failed to grab visits")
            }
            
        }
        
    }
    
    
  
    
    func sendGps(timeStamp: NSDate, arrivalDate: NSDate, departureDate: NSDate, longitude: Double, latitude:Double){
        var email = prefs.valueForKey("EMAIL") as NSString
        
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "LONG"
        let timeStampConv = dateFormatter.stringFromDate(timeStamp)
        let arrivalDateConv = dateFormatter.stringFromDate(arrivalDate)
        let departureDateConv = dateFormatter.stringFromDate(departureDate)

        
        var post:NSString = "gps=\(timeStamp)&email=\(email)"
        NSLog("PostData: %@",post);
        var url:NSURL = NSURL(string:"http://smiil.es:1337/gps")!
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
            //processResponse(email, res: res, urlData: urlData!)
        } else {
            displayFailure(error_msg)
        }
    }
    
    func processResponse(email:NSString, res: NSHTTPURLResponse,urlData: NSData){
        NSLog("Response code: %ld", res.statusCode);
        if (res.statusCode >= 200 && res.statusCode < 300) {
            var responseData:NSString  = NSString(data:urlData, encoding:NSUTF8StringEncoding)!
            NSLog("Response ==> %@", responseData);
            var error: NSError?
            let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData, options:NSJSONReadingOptions.MutableContainers , error: &error) as NSDictionary
            let success:NSInteger = jsonData.valueForKey("success") as NSInteger
            NSLog("Success: %ld", success);
            if(success == 1) {
                NSLog("GPS SUCCESS");
            } else {
                if jsonData["error_message"] as? NSString != nil {
                    error_msg = jsonData["error_message"] as NSString
                } else {
                    error_msg = "Unknown Error"
                }
                displayFailure(error_msg)
            }
        } else {
            displayFailure(error_msg)
        }
    }
    
    
    func displayFailure(error: NSString){
        var alertView:UIAlertView = UIAlertView()
        if (error.isEqualToString("location")){
            alertView.title = "Location cannot be found"
            alertView.message = "Please enable location services: settings > privacy > location services"
        } else if (error.isEqualToString("network"))  {
            alertView.title = "Network error"
            alertView.message = "Internet connection required for application to function properly"
        }
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
    }

    @IBAction func logoutTapped(sender: UIButton) {
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        self.performSegueWithIdentifier("goto_login", sender: self)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

