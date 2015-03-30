//
//  Store.swift
//  Somm
//
//  Created by Connor Knabe on 3/30/15.
//  Copyright (c) 2015 Somm. All rights reserved.
//

import UIKit
import CoreData

class Store: NSObject {
   // let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    
    var visits = [NSManagedObject]()

    
    func saveVisit(arrivalDate:NSDate, departureDate:NSDate, timeStamp:NSDate, latitude:Double, longitude:Double )-> Bool{
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //2
        let entity =  NSEntityDescription.entityForName("Visit",
            inManagedObjectContext:
            managedContext)
        
        let visit = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
        
        //3
        visit.setValue(arrivalDate, forKey: "arrivalDate")
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
    
    func grabVisit(name:String) -> NSArray{
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //2
        let fetchRequest = NSFetchRequest(entityName:"Person")
        
        //3
        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            return visits
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
            var arr = ["Failed","\(error)"]
            return arr
        }
        
    }

    
    
        
    

}
