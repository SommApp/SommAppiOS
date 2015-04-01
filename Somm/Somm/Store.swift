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

    func delVisits(){
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"Visit")
        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as [NSManagedObject]?
        
        
        if let results = fetchedResults {
            var manObj: NSManagedObject!
            
            for manObj: AnyObject in results{
                managedContext.deleteObject(manObj as NSManagedObject)
                NSLog("Object deleted")
            }

        }
        
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        
    }
    
    func saveVisit(aVisit:CLVisit)-> Bool{
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let entity =  NSEntityDescription.entityForName("Visit",
            inManagedObjectContext:
            managedContext)
        
        let visit = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)

        //Save info into model
//        visit.setValue(aVisit.arrivalDate, forKey: "arrivalDate")
//        visit.setValue(aVisit.departureDate, forKey: "departureDate")
        visit.setValue(NSDate(), forKey: "arrivalDate")
        visit.setValue(NSDate(), forKey: "departureDate")
        visit.setValue(NSDate(), forKey: "timeStamp")
        visit.setValue(aVisit.coordinate.latitude, forKey: "latitude")
        visit.setValue(aVisit.coordinate.longitude, forKey: "longitude")

        
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
