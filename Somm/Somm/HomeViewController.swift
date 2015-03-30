//
//  ViewController.swift
//  Somm
//
//  Created by Connor Knabe on 2/11/15.
//  Copyright (c) 2015 Somm. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var txtLocation: UILabel!
    @IBOutlet weak var txtUpdate: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var error_msg:NSString = ""

    
    @IBAction func btnReset(sender: AnyObject) {
        self.txtUpdate.text = ""
        self.txtLocation.textColor = UIColor.blackColor()
    }

    
    
    var emailString = "Welcome "
    let locationManager = CLLocationManager()
    

    @IBAction func locationTapped(sender: AnyObject) {
        println("Location tapped")
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//        locationManager.requestAlwaysAuthorization()
//        locationManager.startUpdatingLocation()
    }
    
    
    
    
    @IBAction func logoutTapped(sender: UIButton) {
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        self.performSegueWithIdentifier("goto_login", sender: self)
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        let reachability = Reachability.reachabilityForInternetConnection()

        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        } else {
            emailString += prefs.valueForKey("EMAIL") as NSString
            emailString += "!"
            self.emailLabel.text = emailString
        }
        reachability.whenUnreachable = { reachability in
            self.displayFailure("network")
        }
        reachability.startNotifier()
        println("Start")
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startMonitoringVisits()
        
    }
    
    func locationManager(manager: CLLocationManager!, didVisit visit: CLVisit!) {
        
        
        
       /* if(visit.departureDate.isEqualToDate(NSDate.distantFuture()){
            println("We have arrived somewhere")
        
        } else {
        
        
        }*/
        /*
        if ([visit.departureDate isEqual: [NSDate distantFuture]]) {
            n.alertBody = [NSString stringWithFormat:@"didVisit: We arrived somewhere!"];
        } else {
            n.alertBody = @"didVisit: We left somewhere!";
        }
        */
        
        //Need to add handling multiple visits
        println("Visit: \(visit)")

        println("Arrival\(visit.arrivalDate)")
        println("Departure\(visit.departureDate)")
        println("Coords \(visit.coordinate)")
        
    
    
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var long = locations[locations.endIndex-1].coordinate.longitude
        var lat = locations[locations.endIndex-1].coordinate.latitude
        var latLong = "\(long),\n\(lat)"
        var interval = locations[locations.endIndex-1].timeIntervalSinceNow
        
        /*if(abs(interval)>300){
            sendGps(latLong)
        }*/
        sendGps(latLong)
        println(latLong)
        self.txtUpdate.text = "Updated"
        self.txtLocation.text = latLong
        self.txtLocation.textColor = UIColor.redColor()
        
    }
    
    func sendGps(gps: NSString){
        var email = prefs.valueForKey("EMAIL") as NSString
        var post:NSString = "gps=\(gps)&email=\(email)"
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
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location " + error.localizedDescription)
        displayFailure("location")
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
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

