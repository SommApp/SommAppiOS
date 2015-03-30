//
//  Store.swift
//  Somm
//
//  Created by Connor Knabe on 3/30/15.
//  Copyright (c) 2015 Somm. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class Store: NSObject {
   // let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    
    var visits = [NSManagedObject]()

    
    func saveVisit(visit:CLVisit)-> Bool{
//arrivalDate:NSDate, departureDate:NSDate, timeStamp:NSDate, latitude:Double, longitude:Double
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let entity =  NSEntityDescription.entityForName("Visit",
            inManagedObjectContext:
            managedContext)
        
        let visit = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)

        //Save info into model
        visit.setValue(visit.arrivalDate, forKey: "arrivalDate")
        visit.setValue(departureDate, forKey: "departureDate")
        visit.setValue(timeStamp, forKey: "timeStamp")
        visit.setValue(latitude, forKey: "latitude")
        visit.setValue(longitude, forKey: "longitude")

        
        //Return false if error occurs for saving
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
            return false;
        }  else {
            return true;
        }

    }
    
    func grabVisit() -> NSArray{
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName:"Visit")
    
        var error: NSError?
        
        //Grab results from model
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            return results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
            var arr = ["Failed","\(error)"]
            return arr
        }
        
    }

    
    
        
    

}
