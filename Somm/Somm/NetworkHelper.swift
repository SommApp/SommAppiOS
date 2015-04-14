//
//  NetworkHelper.swift
//  Somm
//
//  Created by Connor Knabe on 4/8/15.
//  Copyright (c) 2015 Somm. All rights reserved.
//

import Foundation
import CoreLocation

class NetworkHelper: NSObject, CLLocationManagerDelegate {
    let errorHelper = ErrorHelper()
    let store = Store()
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var error_msg = ""
    let locationManager = CLLocationManager()
    
    
    
    func grabLocation(){
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationManager.stopUpdatingLocation()
    }
  
    func sendSettings(name:String, password:String, miles:Int) {
        let email = prefs.valueForKey("EMAIL") as NSString
        var post:NSString = "timestamp=\(NSDate())&email=\(email)&name=\(name)&password=\(password)&miles=\(miles)"
        NSLog("Email\(email)");
        NSLog("PostData: %@",post);
        var url:NSURL = NSURL(string:"http://babbage.cs.missouri.edu/~ckgdd/SommApp-middleware/middleware/settings.php")!
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
            processSettingsResponse(res, urlData: urlData!)
        } else {
            errorHelper.displayHttpError(error_msg)
        }
    }
    
    func updateRecommendationRequest(fromBtn:Bool) -> Bool {
        grabLocation()
        let email = prefs.valueForKey("EMAIL") as NSString
        var coords = ""
        if locationManager.location != nil {
            coords = ("\(locationManager.location.coordinate.latitude),\(locationManager.location.coordinate.longitude)")
        } else {
            coords = ""
        }
        var post:NSString = "timestamp=\(NSDate())&email=\(email)&coords=\(coords)"
        NSLog("Email\(email)");
        NSLog("PostData: %@",post);
        var url:NSURL = NSURL(string:"http://babbage.cs.missouri.edu/~ckgdd/SommApp-middleware/middleware/recommendationRequest.php")!
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
            if(processRecommendationResponse(res, urlData: urlData!, recommendationFromBtn: fromBtn)){
                return true
            } else {
                return false
            }
        } else {
            errorHelper.displayHttpError(error_msg)
            return false
        }
    }
    
    func processRecommendationResponse(res: NSHTTPURLResponse,urlData: NSData, recommendationFromBtn:Bool) -> Bool {
        NSLog("Response code: %ld", res.statusCode);
        if (res.statusCode >= 200 && res.statusCode < 300) {
            var responseData:NSString  = NSString(data:urlData, encoding:NSUTF8StringEncoding)!
            NSLog("Response ==> %@", responseData);
            var error: NSError?
            let jsonData:[[String:AnyObject]] = []
            let json = JSON.parse(responseData)
            let success = json[0]["success"].asString
            if(success! == "1") {
                NSLog("RECOMMENDATION SUCCESS");
                store.delReccomendations()
                for var i = 1; i < json.length; i++ {
                    store.saveRecommendation(json[i])
                }
                return true
            } else if (success! == "nonew"){
                if(recommendationFromBtn){
                    errorHelper.displayNoRecommendationsError()
                    return false
                }
            } else {
                errorHelper.displayHttpError("Error Fetching recommendations")
                return false
            }
        } else {
            errorHelper.displayHttpError(error_msg)
            return false
        }
        return false
    }
    
    func processSettingsResponse(res: NSHTTPURLResponse,urlData: NSData) {
        NSLog("Response code: %ld", res.statusCode);
        if (res.statusCode >= 200 && res.statusCode < 300) {
            var responseData:NSString  = NSString(data:urlData, encoding:NSUTF8StringEncoding)!
            NSLog("Response ==> %@", responseData);
            var error: NSError?
            let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData, options:NSJSONReadingOptions.MutableContainers , error: &error) as NSDictionary
            let success:NSInteger = jsonData.valueForKey("success") as NSInteger
            NSLog("Success: %ld", success);
            if(success == 1) {
                NSLog("SETTINGS SUCCESS");
            } else {
                if jsonData["error_message"] as? NSString != nil {
                    error_msg = jsonData["error_message"] as NSString
                } else {
                    error_msg = "Unknown Error"
                }
                errorHelper.displayHttpError(error_msg)
            }
        } else {
            errorHelper.displayHttpError(error_msg)
        }
    }
    
    func sendGps(timeStamp: NSDate, arrivalDate: NSDate, departureDate: NSDate, longitude: Double, latitude:Double) {
        let email = prefs.valueForKey("EMAIL") as NSString
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "LONG"
        let timeStampConv = dateFormatter.stringFromDate(timeStamp)
        let arrivalDateConv = dateFormatter.stringFromDate(arrivalDate)
        let departureDateConv = dateFormatter.stringFromDate(departureDate)
        var post:NSString = "time=\(timeStamp)&email=\(email)&coords=\(latitude),\(longitude)"
        NSLog("Email\(email)");
        NSLog("PostData: %@",post);
        var url:NSURL = NSURL(string:"http://babbage.cs.missouri.edu/~ckgdd/post.php")!
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
            //processGpsResponse(res, urlData: urlData!)
        } else {
            errorHelper.displayHttpError(error_msg)
        }
    }
    /*
    func processGpsResponse(res: NSHTTPURLResponse,urlData: NSData) {
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
                errorHelper.displayHttpError(error_msg)
            }
        } else {
            errorHelper.displayHttpError(error_msg)
        }
    }*/
    
    
    
    
    
    
}