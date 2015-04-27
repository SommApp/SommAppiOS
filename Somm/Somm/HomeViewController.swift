
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
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    let store = Store()
    let errorHelper = ErrorHelper()
    let networkHelper = NetworkHelper()
    var dict: [[String:AnyObject]] = []
    var restaurants: [[String:String]] = []
    var settingsDistanceChange = false
    var fromSettingsView = false
    var fromMapView = false
    var cancelBtnSelected = false
    
    
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var error_msg:NSString = ""
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        spinner.hidesWhenStopped = true

        
        if (isLoggedIn == 1) {
            var nameString = "Welcome "
            nameString += prefs.valueForKey("NAME") as! String
            nameString += "!"
            self.emailLabel.text = nameString
            if(settingsDistanceChange && fromSettingsView){
                spinner.startAnimating()
                networkHelper.getRecommendations(fromBtn: false, completion: {(success: Bool) -> Void in
                    self.popRestaurantsDict()
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableInfo.reloadData()
                        self.spinner.stopAnimating()
                    })
                    self.settingsDistanceChange = false
                    self.fromSettingsView = false
                })
            } else if (!settingsDistanceChange && fromSettingsView || fromMapView) {
                popRestaurantsDict()
                self.tableInfo.reloadData()
                settingsDistanceChange = false
                fromSettingsView = false
            }
           
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        tableInfo.dataSource = self
        tableInfo.delegate = self


        let hadTutorial:Bool = prefs.boolForKey("TUTORIAL")
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (!hadTutorial) {
            self.performSegueWithIdentifier("goto_tutorial", sender: self)
        } else if(isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        } else {
            sendVisits()
            
            if(!fromSettingsView && !fromMapView && !settingsDistanceChange && !cancelBtnSelected){
                spinner.startAnimating()
                networkHelper.getRecommendations(fromBtn: false, completion: {(success: Bool) -> Void in
                    self.popRestaurantsDict()
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableInfo.reloadData()
                        self.spinner.stopAnimating()
                    })
                    self.settingsDistanceChange = false
                    self.fromMapView = false
                    
                })
            }
        }
        
        if(!CLLocationManager.locationServicesEnabled()){
            errorHelper.displayLocationError()
        }
    }
    
    
    func sendVisits(){
        if let visits = store.grabVisit() as? [NSManagedObject] {
            var timeStamp: NSDate
            var arrivalDate: NSDate
            var departureDate: NSDate
            var longitude: Double
            var latitude: Double
            for visit in visits{
                timeStamp = visit.valueForKey("timeStamp") as! NSDate!
                arrivalDate = visit.valueForKey("arrivalDate") as! NSDate!
                departureDate = visit.valueForKey("departureDate") as! NSDate!
                longitude = visit.valueForKey("longitude") as! Double!
                latitude = visit.valueForKey("latitude") as! Double!
                networkHelper.sendGps(timeStamp, arrivalDate: arrivalDate, departureDate: departureDate, longitude: longitude, latitude: latitude)
            }
            store.delVisits()
        } else {
            let visits = store.grabVisit()
            if(visits[0].isEqualToString("Failed")){
                errorHelper.displayRestaurantSaveError()
            }
        }
    }

    func popRestaurantsDict(){
        self.restaurants.removeAll(keepCapacity: false)
        if let restaurants = store.grabReccomendation() as? [NSManagedObject] {
            for restaurant in restaurants{
                let name = restaurant.valueForKey("name")as! String!
                let latitude = restaurant.valueForKey("latitude") as! String!
                let longitude = restaurant.valueForKey("longitude")as! String!
                let address = restaurant.valueForKey("address") as! String!
                self.restaurants += [["name":name, "latitude":latitude,"longitude":longitude,"address":address]]
            }
        } else {
            let restaurants = store.grabReccomendation()
            if(restaurants[0].isEqualToString("Failed")){
                errorHelper.displayRestaurantSaveError()
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
            let destViewController: MapViewController = segue.destinationViewController as! MapViewController
            destViewController.restaurantName = self.restaurants[indexPath.row]["name"]!
            destViewController.restaurantAddress = self.restaurants[indexPath.row]["address"]!
            destViewController.latitude = self.restaurants[indexPath.row]["latitude"]!
            destViewController.longitude = self.restaurants[indexPath.row]["longitude"]!
        }
    }
    
    @IBAction func btnRecommendation(sender: AnyObject) {
   
        spinner.startAnimating()
            networkHelper.getRecommendations(fromBtn: false, completion: {(success: Bool) -> Void in
                self.popRestaurantsDict()
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableInfo.reloadData()
                    self.spinner.stopAnimating()
                })
                self.settingsDistanceChange = false
                self.fromMapView = false
            })
        errorHelper.displayCurrentRecommendation()
        

        //mocking no recommendations for demo
        //errorHelper.displayNoRecommendationsError()
        
    }
    
    @IBAction func logoutTapped(sender: UIButton) {
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        prefs.setBool(true, forKey: "TUTORIAL")
        prefs.synchronize()
        self.performSegueWithIdentifier("goto_login", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

