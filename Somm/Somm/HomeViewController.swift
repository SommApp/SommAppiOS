//
//  ViewController.swift
//  Somm
//
//  Created by Connor Knabe on 2/11/15.
//  Copyright (c) 2015 Somm. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import CoreLocation
import MapKit


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var txtLocation: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var txtStatus: UILabel!
    @IBOutlet weak var txtArrival: UILabel!
    @IBOutlet weak var txtVisit: UILabel!
    @IBOutlet weak var tableInfo: UITableView!
    let store = Store()
    let errorHelper = ErrorHelper()
    let networkHelper = NetworkHelper()
    
    
    var restaurants:[String] = ["Chipotle", "Taco Bell", "Noodles & Company", "Subway", "Casa Blanca", "Petra", "Starbucks"]
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var error_msg:NSString = ""
    var emailString = ""
    //let reachability = Reachability.reachabilityForInternetConnection()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn == 1) {
            emailString = "Welcome "
            emailString += prefs.valueForKey("NAME") as NSString
            emailString += "!"
            self.emailLabel.text = emailString
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        tableInfo.dataSource = self
        tableInfo.delegate = self
        
        
        var obj:[String:AnyObject] = [
            "restaurant":[
                "name":   "Chipotle",
                "latitude":   0,
                "longitude":    0,
                "address": ""
            ]
        ]
        
        
        
        
        
        var shoppingList: [String] = ["Eggs", "Milk"]

        shoppingList += ["Baking Powder"]

        var dict: [[String:AnyObject]] = []
        
        dict += [["name":"Chipotle", "latitude":0, "longitude":0,"address":""]]
        dict += [["name":"Tacobell", "latitude":0, "longitude":0,"address":""]]

        

        for item in dict {
            println(item["name"]!)
        }
        
        
        
        
        let json = JSON(obj)
        
        
        let name = json["restaurant"]["name"].asString
        
        
        
        
        println("\(name!)")
    
        
        
        for (name, v) in json["restaurant"] {
            
            println("\(name)")
            
            // k is NSString, v is another JSON object
        }
        
        
        
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        } else {
            sendVisits()
        }
        
        

        /*reachability.whenUnreachable = { reachability in
            self.errorHelper.displayNetworkError()
        }
        reachability.startNotifier()*/
        println("Start")
    }
    
    func sendVisits(){
        if let visits = store.grabVisit() as? [NSManagedObject] {
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
                networkHelper.sendGps(timeStamp, arrivalDate: arrivalDate, departureDate: departureDate, longitude: longitude, latitude: 99)
            }
            store.delVisits()
        } else {
            let visits = store.grabVisit()
            if(visits[0].isEqualToString("Failed")){
                println("Failed to grab visits")
            }
        }
    }

    

//    func openMapForPlace() {
//        
//        var lat1 : NSString =
//        var lng1 : NSString =
//        
//        var latitute:CLLocationDegrees =  lat1.doubleValue
//        var longitute:CLLocationDegrees =  lng1.doubleValue
//        
//        let regionDistance:CLLocationDistance = 10000
//        var coordinates = CLLocationCoordinate2DMake(latitute, longitute)
//        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
//        var options = [
//            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
//            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
//        ]
//        var placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
//        var mapItem = MKMapItem(placemark: placemark)
//        mapItem.name = "\(self.venueName)"
//        mapItem.openInMapsWithLaunchOptions(options)
//        
//    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.restaurants.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor(red: 0.3843, green: 0.0627, blue: 0.3725, alpha: 1.0)
        cell.selectedBackgroundView.backgroundColor = UIColor(red: 0.6431, green: 0.1490, blue: 0.6902, alpha: 1.0)
        let label = UILabel(frame: CGRect(x:0, y:0, width:tableInfo.frame.width, height:50))
        label.text = self.restaurants[indexPath.row]
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        cell.addSubview(label)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("Restaurant name \(self.restaurants[indexPath.row])")
        self.performSegueWithIdentifier("goto_map", sender: self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier=="goto_map"){
            let indexPath:NSIndexPath = self.tableInfo.indexPathForSelectedRow()!
            let mapViewController:MapViewController = segue.destinationViewController as MapViewController
            mapViewController.restaurantName = restaurants[indexPath.row]
        } else if (segue.identifier=="goto_home"){
            

            /*
            UIViewController *sourceViewController = self.sourceViewController;
            UIViewController *destinationViewController = self.destinationViewController;
            
            
            [sourceViewController presentViewController:destinationViewController animated:NO completion:nil];
            [destinationViewController.view addSubview:sourceViewController.view];
            [sourceViewController.view setTransform:CGAffineTransformMakeTranslation(0, 0)];
            [sourceViewController.view setAlpha:1.0];
            
            [UIView animateWithDuration:0.75
                delay:0.0
                options:UIViewAnimationOptionTransitionFlipFromBottom
                animations:^{
                [sourceViewController.view setTransform:CGAffineTransformMakeTranslation(0,destinationViewController.view.frame.size.height)];
                [sourceViewController.view setAlpha:1.0];
                }
                completion:^(BOOL finished){
                [sourceViewController.view removeFromSuperview];
                }];
            
        }*/
            println("BLAAH")
        }
        
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

