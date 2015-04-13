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
    var dict: [[String:AnyObject]] = []
    var restaurants: [[String:String]] = []
    
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
            
            //have sendRecommendationRequest check if there are new reccomendations if so delete and repopulate restaurantDict
            //also give user ability to manually click button to update reccomendations
            
            /*Need to send cordinates here*/networkHelper.sendRecommendationRequest()
            popRestaurantsDict()
        }
        
    }
    
  
    

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        tableInfo.dataSource = self
        tableInfo.delegate = self
        
        
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        } else {
            sendVisits()

        }
        

        if(!CLLocationManager.locationServicesEnabled()){
            errorHelper.displayLocationError()
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

    func popRestaurantsDict(){
        if let restaurants = store.grabReccomendation() as? [NSManagedObject] {
            for restaurant in restaurants{
                let name = restaurant.valueForKey("name") as String!
                let latitude = restaurant.valueForKey("latitude") as String!
                let longitude = restaurant.valueForKey("longitude") as String!
                let address = restaurant.valueForKey("address") as String!
                self.restaurants += [["name":name, "latitude":latitude,"longitude":longitude,"address":address]]
            }
            //store.delVisits()
        } else {
            let restaurants = store.grabReccomendation()
            if(restaurants[0].isEqualToString("Failed")){
                println("Failed to grab restaurants")
            }
        }

        
    }



    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.restaurants.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor(red: 0.3843, green: 0.0627, blue: 0.3725, alpha: 1.0)
        cell.selectedBackgroundView.backgroundColor = UIColor(red: 0.6431, green: 0.1490, blue: 0.6902, alpha: 1.0)
        let label = UILabel(frame: CGRect(x:0, y:0, width:tableInfo.frame.width, height:50))
        label.text = self.restaurants[indexPath.row]["name"]
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        cell.addSubview(label)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("goto_map", sender: self)
    }
    
  

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier=="goto_map"){
            let indexPath: NSIndexPath = self.tableInfo.indexPathForSelectedRow()!
            let destViewController: MapViewController = segue.destinationViewController as MapViewController
            destViewController.restaurantName = self.restaurants[indexPath.row]["name"]!
            destViewController.restaurantAddress = self.restaurants[indexPath.row]["address"]!
            destViewController.latitude = self.restaurants[indexPath.row]["latitude"]!
            destViewController.longitude = self.restaurants[indexPath.row]["longitude"]!
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

