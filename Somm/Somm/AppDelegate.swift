//
//  AppDelegate.swift
//  Somm
//
//  Created by Connor Knabe on 2/11/15.
//  Copyright (c) 2015 Somm. All rights reserved.
//

import UIKit
import CoreLocation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //Monitor visits and significant location changes
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringVisits()
        

        return true
    }
    
    
    func locationManager(manager: CLLocationManager!, didVisit visit: CLVisit!) {
        
        //store visit in database
        //maybe ask user if they want to store checkin?

        
        
        
        if(visit.departureDate.isEqualToDate(NSDate.distantFuture())){
            println("We have arrived somewhere")
        
        } else {
            println("We have left somewhere")
        
        }
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

        //store gps in database
        
        //sendGps(latLong)
        println(latLong)
        
        
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
    
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

