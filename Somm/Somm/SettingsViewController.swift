//
//  SettingsViewController.swift
//  Somm
//
//  Created by Connor Knabe on 4/8/15.
//  Copyright (c) 2015 Somm. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var btnSave: UIButton!
    
    let errorHelper: ErrorHelper = ErrorHelper()
    let networkHelper = NetworkHelper()
    let stringHelper = StringHelper()
    let milesText:[String] = ["1 mile", "3 miles", "5 miles", "10 miles", "15 miles"]
    let mileNumVal:[Int] = [1, 3, 5, 10, 15]
    var selectedMiles:Int = 1
    let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var milesFromPrefs:Int = 0
    var settingsDistanceChange = false
    var cancelBtnSelected = false

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        milesFromPrefs = self.prefs.valueForKey("MAXMILES") as! Int
        txtName.text = self.prefs.valueForKey("NAME") as! String
        for var i = 0; i < mileNumVal.count; i++ {
            if (milesFromPrefs==mileNumVal[i]){
                pickerView.selectRow(i, inComponent: 0, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        txtName.delegate = self
        txtPassword.delegate = self
        txtConfirmPassword.delegate = self
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
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedMiles = mileNumVal[row]
        if (milesFromPrefs as Int != selectedMiles as Int){
            settingsDistanceChange = true
        }
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
            if(networkHelper.sendSettings(txtName.text, password: txtPassword.text, miles: selectedMiles)){
                self.prefs.setObject(selectedMiles, forKey: "MAXMILES")
                prefs.setObject(txtName.text, forKey: "NAME")
                self.performSegueWithIdentifier("goto_home", sender: self)
            }
        }
    }
    @IBAction func btnCancel(sender: AnyObject) {
        cancelBtnSelected = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier=="goto_home"){
            let destViewController: ViewController = segue.destinationViewController as! ViewController
            destViewController.fromSettingsView = true
            
            if(cancelBtnSelected){
                settingsDistanceChange = false
            } 
            destViewController.settingsDistanceChange = settingsDistanceChange

            destViewController.cancelBtnSelected = cancelBtnSelected
        }
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(textField == txtName){
            txtPassword.becomeFirstResponder()
        } else if (textField == txtPassword) {
            txtConfirmPassword.becomeFirstResponder()
        } else {
            btnSave(btnSave)
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if (count(textField.text) >= 25 && range.length == 0){
            errorHelper.displayTextLengthError()
            return false
        } else {
            return true
        }
        
    }
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        self.view.endEditing(true);
    }
    
    

}