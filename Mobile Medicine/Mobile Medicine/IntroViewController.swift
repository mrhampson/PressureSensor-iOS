//
//  IntroViewController.swift
//  Mobile Medicine
//
//  Created by Marshall Hampson on 4/3/15.
//  Copyright (c) 2015 BRIM. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {

    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /* Code in case we need to switch to single parent
    
    var isShowingLandscapeView = false
    var isShowingCalendarView = false
    var isShowingDataView = false

    
    func orientationChanged(notification: NSNotification){
        let deviceOrientation = UIDevice.currentDevice().orientation;
        if(isShowingDataView){
            if (UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscapeView){
                self.performSegueWithIdentifier("DataToLandscape", sender: self)
                isShowingLandscapeView = true
                
            }
            else if(UIDeviceOrientationIsPortrait(deviceOrientation) && isShowingLandscapeView){
                self.dismissViewControllerAnimated(true, completion: nil)
                isShowingLandscapeView = false
            }
        }
        else if (isShowingCalendarView){
            if (UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscapeView){
                self.performSegueWithIdentifier("DataToLandscape", sender: self)
                isShowingLandscapeView = true
                
            }
            else if(UIDeviceOrientationIsPortrait(deviceOrientation) && isShowingLandscapeView){
                self.dismissViewControllerAnimated(true, completion: nil)
                isShowingLandscapeView = false
            }
        }
    }
    */

}

