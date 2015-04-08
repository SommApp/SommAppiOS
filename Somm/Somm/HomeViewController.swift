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
    var items: [String] = ["Chipotle", "Taco Bell", "Noodles & Company", "Subway", "Casa Blanca", "Petra", "Starbucks"]

    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var error_msg:NSString = ""
    var emailString = ""
    let store = Store()
    let errorHelper = ErrorHelper()
    //let reachability = Reachability.reachabilityForInternetConnection()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        navigationItem.title = "test"
        tableInfo.dataSource = self
        tableInfo.delegate = self

        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        if (isLoggedIn != 1) {
            self.performSegueWithIdentifier("goto_login", sender: self)
        } else {
            emailString = "Welcome "
            emailString += prefs.valueForKey("EMAIL") as NSString
            emailString += "!"
            self.emailLabel.text = emailString
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
                sendGps(timeStamp, arrivalDate: arrivalDate, departureDate: departureDate, longitude: longitude, latitude: 99)
            }
            store.delVisits()
        } else {
            let visits = store.grabVisit()
            if(visits[0].isEqualToString("Failed")){
                println("Failed to grab visits")
            }
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
            //processResponse(email, res: res, urlData: urlData!)
        } else {
            errorHelper.displayHttpError(error_msg)
        }
    }
    
    func processResponse(email:NSString, res: NSHTTPURLResponse,urlData: NSData) {
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
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor(red: 0.3843, green: 0.0627, blue: 0.3725, alpha: 1.0)
        let label = UILabel(frame: CGRect(x:0, y:0, width:tableInfo.frame.width, height:50))
        label.text = self.items[indexPath.row]
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        cell.addSubview(label)
        return cell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
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

