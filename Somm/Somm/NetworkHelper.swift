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
    var coords = ""
    
    func grabLocation(){
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        locationManager.stopUpdatingLocation()
    }
  
    func sendSettings(name:String, password:String, miles:Int)->Bool {
        let email = prefs.valueForKey("EMAIL") as! NSString
        var post:NSString = "timestamp=\(NSDate())&email=\(email)&name=\(name)&password=\(password)&miles=\(miles)"
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
    
    
    func getRecommendations(completion: (success: Bool)->()) {
        var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration)
        grabLocation()
        let email = prefs.valueForKey("EMAIL") as! NSString
        coords = ""
        if locationManager.location != nil {
            coords = ("\(locationManager.location.coordinate.latitude),\(locationManager.location.coordinate.longitude)")
            prefs.setBool(true, forKey: "LOATION")
        } else {
            coords = ""
            if(prefs.boolForKey("LOCATION")){
                errorHelper.displayNetworkError()
            } else {
                errorHelper.displayLocationError()
            }
            completion(success: false)
            return
        }
        
        var post:NSString = "timestamp=\(NSDate())&email=\(email)&gps=\(coords)"
        var postData:NSData = post.dataUsingEncoding(NSASCIIStringEncoding)!
        let url:NSURL = NSURL(string:"http://52.11.190.66/middleware/recommendationRequest.php")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = postData
        var postLength:NSString = String( postData.length )
        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")

        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        var reponseError: NSError?
        var response: NSURLResponse?
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let httpResponse = response as? NSHTTPURLResponse {
                if ( data != nil ) {
                    let res = response as! NSHTTPURLResponse!;
                    if(self.processRecommendationResponse(res, urlData: data)){
                        completion(success: true)
                    } else {
                        completion(success: false)
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.errorHelper.displayRecommendationsFailError()
                    })
                    completion(success: false)
                }
            }
                            
        }
        task.resume()
    }
    
    func processRecommendationResponse(res: NSHTTPURLResponse,urlData: NSData) -> Bool {
        if (res.statusCode >= 200 && res.statusCode < 300) {
            var responseData:NSString  = NSString(data:urlData, encoding:NSUTF8StringEncoding)!
            var error: NSError?
            let jsonData:[[String:AnyObject]] = []
            let json = JSON.parse(responseData as String)
            let success = json[0]["success"].asString
            let successInt = json[0]["success"].asInt
            if(successInt! == 1) {
                var haveData = prefs.boolForKey("HAVEDATA")    
                if(json.length==1 && !haveData && !coords.isEmpty){
                    dispatch_async(dispatch_get_main_queue(), {
                        self.errorHelper.displayNewRecommendationsError()
                    })
                    return false
                } else {
                    store.delReccomendations()
                    for var i = 1; i < json.length; i++ {
                        store.saveRecommendation(json[i])
                    }
                    return true
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.errorHelper.displayRecommendationsFailError()
                })
                return false
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.errorHelper.displayHttpError(self.error_msg)
            })
            return false
        }
    }
    
    func processSettingsResponse(res: NSHTTPURLResponse,urlData: NSData)->Bool {
        if (res.statusCode >= 200 && res.statusCode < 300) {
            var responseData:NSString  = NSString(data:urlData, encoding:NSUTF8StringEncoding)!
            var error: NSError?
            let jsonData:NSDictionary = NSJSONSerialization.JSONObjectWithData(urlData, options:NSJSONReadingOptions.MutableContainers , error: &error) as! NSDictionary
            let success:String = jsonData.valueForKey("success") as! String
            if(success == "1") {
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
        } else {
            errorHelper.displayHttpError(error_msg)
        }
    }
    
       
    
    
    
    
    
    
}