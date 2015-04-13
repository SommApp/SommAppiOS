//
//  MapViewController.swift
//  Somm
//
//  Created by Connor Knabe on 4/8/15.
//  Copyright (c) 2015 Somm. All rights reserved.
//

import Foundation
import MapKit

class MapViewController:UIViewController {
    var restaurantName = ""
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    
    
    override func viewWillAppear(animated: Bool) {
        lblName.text = restaurantName
        
    }
    
    override func viewDidAppear(animated: Bool) {
        println("\(restaurantName)")
        
        
        
        
    }
}
