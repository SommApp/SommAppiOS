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
  
    func sendSettings(name:String, password:String, miles:Int)->Bool {
        let email = prefs.valueForKey("EMAIL") as! NSString
        var post:NSString = "timestamp=\(NSDate())&email=\(email)&name=\(name)&password=\(password)&miles=\(miles)"
        NSLog("Email\(email)");
        NSLog("PostData: %@",post);
        var url:NSURL = NSURL(string:"http://52.11.190.66/middleware/settings.php")!
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
            if(processSettingsResponse(res, urlData: urlData!)){
                return true
            } else {
                return false
            }
        } else {
            errorHelper.displayHttpError(error_msg)
            return false
        }
    }
    
    func getRecommendations(completion: (result: NSArray, error: NSError)->()) {

        
        //var url : NSURL = NSURL(string: "http://52.11.190.66/middleware/recommendationRequest.php?timestamp=0&email=con@con.com&gps=38.948655,-92.327862")!
        //var request: NSURLRequest = NSURLRequest(URL: url)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)

        //38.948655,-92.327862
        var post:NSString = "timestamp=\(NSDate())&email=con@con.com&gps=38.948655,-92.327862"
        var url:NSURL = NSURL(string:"http://52.11.190.66/middleware/recommendationRequest.php")!
        var postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
        var postLength:NSString = String( postData.length )
        var request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: "http://52.11.190.66/middleware/recommendationRequest.php")!) { data, response, error in
        
        
        }
        task.resume()

        /*
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
            
            // notice that I can omit the types of data, response and error
            
            // your code
            self.processRecommendationResponse(response, urlData: data, recommendationFromBtn: false)

            
        });*/

        
        
    }
    
    
    func getRec(completion: (result: Bool, error: NSError)->()) {
        
        
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration)

    
        var post:NSString = "timestamp=\(NSDate())&email=con@con.com&gps=38.948655,-92.327862"
        var postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
        let url:NSURL = NSURL(string:"http://52.11.190.66/middleware/recommendationRequest.php")!
        //var postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
        //var postLength:NSString = String( postData.length )

        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        var postLength:NSString = String( postData.length )
        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")

        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        var reponseError: NSError?
        var response: NSURLResponse?
        var urlData: NSData? = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&reponseError)

        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    println("response was not 200: \(response)")
                    completion(result: true, error: reponseError!)
                }
            }
            if (error != nil) {
                println("error submitting request: \(error)")
                completion(result: true, error: reponseError!)
            }
            
            // handle the data of the successful response here
            var result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as? NSDictionary
            println(result)
        }
        task.resume()
        
        
    }

    func updateRecommendationRequest(#fromBtn:Bool) -> Bool {
        grabLocation()
        let email = prefs.valueForKey("EMAIL") as! NSString
        var coords = ""
        if locationManager.location != nil {
            coords = ("\(locationManager.location.coordinate.latitude),\(locationManager.location.coordinate.longitude)")
        } else {
            coords = ""
        }
        
        //38.948655,-92.327862 
        var post:NSString = "timestamp=\(NSDate())&email=\(email)&gps=38.948655,-92.327862"
        NSLog("Email\(email)");
        NSLog("PostData: %@",post);
        var url:NSURL = NSURL(string:"http://52.11.190.66/middleware/recommendationRequest.php")!
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
            var error: NSError?
            NSLog(responseData as String)
            let jsonData:[[String:AnyObject]] = []
            let json = JSON.parse(responseData as String)
            let success = json[0]["success"].asString
            let successInt = json[0]["success"].asInt
            
            if(successInt! == 1) {
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
    
    func processSettingsResponse(res: NSHTTPURLResponse,urlData: NSData)->Bool {
        NSLog("Response code: %ld", res.statusCode);
        if (res.statusCode >= 200 && res.statusCode < 300) {
            var responseData:NSString  = NSString(data:urlData, encoding:NSUTF8StringEncoding)!
            var error: NSError?
            let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSDictionary
            let success:NSInteger = jsonData.valueForKey("success") as! NSInteger
            NSLog("Success: %ld", success);

            if(success == 1) {
                NSLog("SETTINGS SUCCESS");
                return true
            } else {
                if jsonData["error_message"] as? NSString != nil {
                    error_msg = jsonData["error_message"] as! NSString as String
                } else {
                    error_msg = "Unknown Error"
                }
                errorHelper.displayHttpError(error_msg)
                return false
            }
        } else {
            errorHelper.displayHttpError(error_msg)
            return false
        }
    }
    
    func sendGps(timeStamp: NSDate, arrivalDate: NSDate, departureDate: NSDate, longitude: Double, latitude:Double) {
        let email = prefs.valueForKey("EMAIL") as! NSString
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "LONG"
        let timeStampConv = dateFormatter.stringFromDate(timeStamp)
        let arrivalDateConv = dateFormatter.stringFromDate(arrivalDate)
        let departureDateConv = dateFormatter.stringFromDate(departureDate)
        var post:NSString = "time=\(timeStamp)&email=\(email)&coords=\(latitude),\(longitude)"
        NSLog("Email\(email)");
        NSLog("PostData: %@",post);
        var url:NSURL = NSURL(string:"http://52.11.190.66/middleware/gps.php")!
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