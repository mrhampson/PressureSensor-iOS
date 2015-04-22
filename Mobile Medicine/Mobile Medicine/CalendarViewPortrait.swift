//
//  CalendarViewPortrait.swift
//  Mobile Medicine
//
//  Created by Marshall Hampson on 4/3/15.
//  Copyright (c) 2015 BRIM. All rights reserved.
//

import UIKit

class CalendarViewPortrait: UIViewController {
    
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "orientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
    }
    
    func orientationChanged(notification: NSNotification){
        let deviceOrientation = UIDevice.currentDevice().orientation;
        if (UIDeviceOrientationIsLandscape(deviceOrientation)){
            self.performSegueWithIdentifier("CalToLandscape", sender: self)
            
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
