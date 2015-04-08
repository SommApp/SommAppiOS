//
//  SettingsViewController.swift
//  Somm
//
//  Created by Connor Knabe on 4/8/15.
//  Copyright (c) 2015 Somm. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!

    let networkHelper = NetworkHelper()
    let stringHelper = StringHelper()
    let milesText:[String] = ["1 mile", "3 miles", "5 miles", "10 miles", "15 miles"]
    let mileNumVal:[Int] = [1, 3, 5, 10, 15]
    var selectedMiles:Int = 1
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var milesFromPrefs:Int = 0

    //   var milesFromPrefs = 15
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        milesFromPrefs = self.prefs.valueForKey("MAXMILES") as Int
        txtName.text = self.prefs.valueForKey("NAME") as String
        
        for var i = 0; i < mileNumVal.count; i++ {
            if (milesFromPrefs==mileNumVal[i]){
                pickerView.selectRow(i, inComponent: 0, animated: true)
            }
            
        }

    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return milesText.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return milesText[row]
        
    }
    
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int) {
        selectedMiles = mileNumVal[row]
    }
    
    

    
    
    @IBAction func btnSave(sender: AnyObject) {
        
        if(txtPassword.text != txtConfirmPassword.text){
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Change Password Failed!"
            alertView.message = "Passwords don't Match"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else {
            println("\(selectedMiles)")
            networkHelper.sendSettings(txtName.text, password: txtPassword.text, miles: selectedMiles)
            self.prefs.setObject(selectedMiles, forKey: "MAXMILES")
            self.performSegueWithIdentifier("goto_home", sender: self)
        }
        
        
    }
    
    override func touchesBegan(touches: NSSet,
        withEvent event: UIEvent){
            self.view.endEditing(true);
            super.touchesBegan(touches, withEvent: event)
    }
    

}