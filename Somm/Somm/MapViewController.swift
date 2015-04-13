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
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var mapView: MKMapView!


    var restaurantName = ""
    var restaurantAddress = ""
    var latitude:NSString = ""
    var longitude:NSString = ""

    
    override func viewWillAppear(animated: Bool) {
        lblName.text = restaurantName
        lblAddress.text = restaurantAddress
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let lat = self.latitude.doubleValue
        let long = self.longitude.doubleValue
        
        println("\(lat)\(long)")

        
        let location = CLLocationCoordinate2D(
            latitude: lat,
            longitude: long
        )
        
        let span = MKCoordinateSpanMake(0.001, 0.001)
        let region = MKCoordinateRegion(center: location, span: span)
        
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.setCoordinate(location)
        annotation.title = restaurantName
        annotation.subtitle = restaurantAddress
        
        mapView.addAnnotation(annotation)

        
    }
    
    
    
    
    @IBAction func btnDirections(sender: AnyObject) {
        var lat1: NSString = latitude
        var lng1: NSString = longitude
        
        var latitute:CLLocationDegrees =  lat1.doubleValue
        var longitute:CLLocationDegrees =  lng1.doubleValue
        
        let regionDistance:CLLocationDistance = 10000
        var coordinates = CLLocationCoordinate2DMake(latitute, longitute)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        var options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        var placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        var mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(restaurantName)"
        mapItem.openInMapsWithLaunchOptions(options)
        
    }
    
    
    



}
