//
//  Visit.swift
//  Somm
//
//  Created by Connor Knabe on 4/1/15.
//  Copyright (c) 2015 Somm. All rights reserved.
//

import Foundation
import CoreData

@objc(Visit)
class Visit: NSManagedObject {
    @NSManaged var arrivalDate: NSDate
    @NSManaged var departureDate: NSDate
    @NSManaged var timeStamp: NSDate
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    
}