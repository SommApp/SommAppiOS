//
//  ReverseSegue.swift
//  Somm
//
//  Created by Connor Knabe on 4/8/15.
//  Copyright (c) 2015 Somm. All rights reserved.
//

import Foundation
import UIKit

class ReverseSegue:UIStoryboardSegue {

    
    
    override func perform(){
        let sourceViewController:UINavigationController = self.sourceViewController as UINavigationController
        let destinationViewController:UINavigationController = self.destinationViewController as UINavigationController

        sourceViewController.presentViewController(destinationViewController, animated: false, completion: nil)
        
        destinationViewController.view.addSubview(sourceViewController.view)

        sourceViewController.view.transform = CGAffineTransformMakeTranslation(0, 0)
        sourceViewController.view.alpha = 1.0
        
        /*
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: { () -> Void in
            sourceViewController.view.transform = CGAffineTransformMakeTranslation(0,destinationViewController.view.frame.size.height)
            sourceViewController.view.alpha = 1.0
            }) { (_) -> Void in
            sourceViewController.view.removeFromSuperview()
        }*/

        
        UIView.animateWithDuration(0.25, delay: 0.0, options: UIViewAnimationOptions.TransitionFlipFromBottom, animations: {
            sourceViewController.view.transform = CGAffineTransformMakeTranslation(0,destinationViewController.view.frame.size.height)
            sourceViewController.view.alpha = 1.0
            }, completion: {(_) -> Void in
                sourceViewController.view.removeFromSuperview()
        })
        
    
    
    }
    


    
    
}