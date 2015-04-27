//
//  ErrorHelper.swift
//  Somm
//
//  Created by Connor Knabe on 4/3/15.
//  Copyright (c) 2015 Somm. All rights reserved.
//

import Foundation
import UIKit


class ErrorHelper: NSObject {
    let alertView:UIAlertView = UIAlertView()
    
    func displayNetworkError(){
        alertView.title = "Network error"
        alertView.message = "Internet connection required for application to function properly"
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
    }
    
    func displayLocationError(){
        alertView.title = "Location cannot be found"
        alertView.message = "Please enable location services: settings > privacy > location services"
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
    }
    
    func displayNoRecommendationsError(){
        alertView.title = "Recommendations"
        alertView.message = "No new recommendations found"
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
    }
    
    func displayHttpError(error_msg:NSString){
        alertView.title = "Sign in Failed!"
        if(error_msg.isEqualToString("")){
            alertView.message = "Connection Failed"
        } else {
            alertView.message = error_msg as String
        }
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
    }
    
    func displaySignInFail(error_msg:NSString){
        alertView.title = "Sign in Failed!"
        if(error_msg.isEqualToString("")){
            alertView.message = "Connection Failed"
        } else {
            alertView.message = error_msg as String
        }
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
    }
    
    func displayCurrentRecommendation(){
        alertView.title = "Recommendations"
        alertView.message = "We have grabbed your current restaurant recommendations"
        alertView.delegate = self
        alertView.addButtonWithTitle("OK")
        alertView.show()
        
    }


}
