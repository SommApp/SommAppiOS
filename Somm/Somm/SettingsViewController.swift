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
    let FitDescription : [String] = ["0.50 flat", "0.25 flat", "aligned", "0.25 steep", "0.50 steep"]
    let FitValue : [Float] = [ -0.50, -0.25, 0,  0.25, 0.50]
    var selectedPower : Float!

    @IBOutlet weak var pickerView: UIPickerView!
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
    
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return 1
        
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return FitDescription.count
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        
        return FitDescription[row]
        
    }
    
    func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int) {
        
        selectedPower = FitValue[row]
    }
    

}