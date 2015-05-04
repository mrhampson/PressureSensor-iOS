
//
//  CustomTabBarController.swift
//  Wearable Pressure Sensor
//
//  Created by Conor Woods on 3/8/15.
//  Copyright (c) 2015 Rutvi Kotak. All rights reserved.
//

import UIKit
class ModelData
{
    var tempArray : [CGFloat] = []
    
}
class CustomTabBarController: UITabBarController {
    
    var model = ModelData()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
