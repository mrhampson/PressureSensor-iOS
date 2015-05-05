//
//  DataViewPortrait.swift
//  Mobile Medicine
//
//  Created by Marshall Hampson on 4/3/15.
//  Copyright (c) 2015 BRIM. All rights reserved.
//

import UIKit
import CoreData

class DataViewPortrait: UIViewController {
    
    //UI info
    var titleLabel : UILabel!
    var statusLabel : UILabel!
    var tempLabel : UILabel!
    var button : UIButton!
    var isShowingLandscapeView = false
    var timer : NSTimer!
    
    var context:NSManagedObjectContext!
    var infoEntity:NSEntityDescription
    var dataEntity:NSEntityDescription
    var insertDataInfo:NSManagedObject
    var insertData:NSMutableOrderedSet = []
    var appDel:AppDelegate!
    
    //The variables we will record data to
    internal var startDate: NSDate!
    internal var dataName : String = ""
    internal var dataArray: [Double] = []
    internal var recording: Bool = false
    //temp for testing
    var count:Int = 0
    
    convenience init(){
        self.init()
        //Core data context
        appDel = (UIApplication.sharedApplication().delegate as! AppDelegate)
        context = appDel.managedObjectContext
        infoEntity = NSEntityDescription.entityForName("RecordInfo", inManagedObjectContext: context)!
        dataEntity = NSEntityDescription.entityForName("RecordData", inManagedObjectContext: context)!
        //insertDataInfo = NSManagedObject(entity: infoEntity, insertIntoManagedObjectContext: context)
        insertDataInfo = NSEntityDescription.insertNewObjectForEntityForName ("RecordInfo", inManagedObjectContext: context) as! RecordInfo
        
    }

    required init(coder aDecoder: NSCoder) {
        
        //Core data context
        appDel = (UIApplication.sharedApplication().delegate as! AppDelegate)
        context = appDel.managedObjectContext
        infoEntity = NSEntityDescription.entityForName("RecordInfo", inManagedObjectContext: context)!
        dataEntity = NSEntityDescription.entityForName("RecordData", inManagedObjectContext: context)!
        //insertDataInfo = NSManagedObject(entity: infoEntity, insertIntoManagedObjectContext: context)
        insertDataInfo = NSEntityDescription.insertNewObjectForEntityForName ("RecordInfo", inManagedObjectContext: context) as! RecordInfo
        super.init(coder: aDecoder)
        
     }
    
    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up title label
        titleLabel = UILabel()
        titleLabel.text = "Mobile Medicine"
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: self.view.frame.midX, y: self.titleLabel.bounds.midY+28)
        self.view.addSubview(titleLabel)
        
        // Set up status label
        statusLabel = UILabel()
        statusLabel.textAlignment = NSTextAlignment.Center
        statusLabel.text = "Loading..."
        statusLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        statusLabel.sizeToFit()
        statusLabel.frame = CGRect(x: self.view.frame.origin.x, y: self.titleLabel.frame.maxY, width: self.view.frame.width, height: self.statusLabel.bounds.height)
        self.view.addSubview(statusLabel)
        
        // Set up temperature label
        tempLabel = UILabel()
        tempLabel.text = "00.00"
        tempLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 72)
        tempLabel.sizeToFit()
        tempLabel.center = self.view.center
        self.view.addSubview(tempLabel)

        // Do any additional setup after loading the view.
        button   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        button.frame = CGRectMake(100, 100, 100, 50)
        button.backgroundColor = UIColor.greenColor()
        button.setTitle("Start", forState: UIControlState.Normal)
        button.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        button.center = CGPoint(x: self.view.frame.midX, y: self.view.bounds.maxY - 100 )
        
        self.view.addSubview(button)
        
        //start timer at 20Hz
        timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("recordData"), userInfo: nil, repeats: true)
    }
    
    func buttonAction(sender:UIButton!)
    {
        let btn:UIButton = sender
        let title = btn.titleLabel?.text
        if (!recording)
        {
            //Start
            startDate = NSDate()
            recording = true
            count = 0
            dataArray = []
            dataName = String()
            //creating new objects
            insertData = []
            //Start bluetooth recording (or have that automatic based on flag
            btn.setTitle("Stop", forState: UIControlState.Normal)
            btn.backgroundColor = UIColor.redColor()
            var error: NSError?
            
            let fetchRequest = NSFetchRequest(entityName:"RecordInfo")
            let fetchedResults = context.executeFetchRequest(fetchRequest,
                error: &error) as? [NSManagedObject]
            if let results = fetchedResults {
                for result in results{
                    println(result.valueForKey("rName"))
                    println(result.valueForKey("rDate"))
                    let dataArray = (result.valueForKey("dataRelation")) as! NSOrderedSet
                    for data in dataArray{
                        print(data.valueForKey("rData"), " ")
                    }
                    println()
                }
            }
        }
        else
        {
            println("Portrait stopping")
            //Stop
            recording = false
            //Save data to NSData here
            println("landscape date")
            println(startDate.descriptionWithLocale(NSLocale.autoupdatingCurrentLocale()))
            insertDataInfo.setValue(startDate, forKey: "rDate")
            println(dataArray)
            for data in dataArray {
                var newData = NSEntityDescription.insertNewObjectForEntityForName ("RecordData",
                    inManagedObjectContext: context) as! NSManagedObject
                newData.setValue(data, forKey: "rData")
                
                insertData.addObject(newData)
            }
            insertDataInfo.setValue(insertData, forKey: "dataRelation")
            addName(self) //sets and saves rName
            println(startDate.descriptionWithLocale(NSLocale.autoupdatingCurrentLocale()))
            println(dataArray)

            println()
            btn.setTitle("Start", forState: UIControlState.Normal)
            btn.backgroundColor = UIColor.greenColor()
        }
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
        if (UIDeviceOrientationIsLandscape(deviceOrientation) && !isShowingLandscapeView){
            self.performSegueWithIdentifier("DataToLandscape", sender: self)
            isShowingLandscapeView = true
            
        }
        else if(UIDeviceOrientationIsPortrait(deviceOrientation) && isShowingLandscapeView){
            self.dismissViewControllerAnimated(true, completion: nil)
            isShowingLandscapeView = false
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "DataToCal"){
            // Notification center will detect when you rotate to landscape view and will call
            // a segue to DataLandscape
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
        } else if(segue.identifier == "DataToLandscape") {
            var destinationView:DataViewLandscape = segue.destinationViewController as! DataViewLandscape;
            destinationView.startDate = self.startDate;
            destinationView.dataName = self.dataName;
            if self.dataArray != []{
                destinationView.graphData = self.dataArray;
            }
            destinationView.recording = self.recording;
        }
    }
    
    //give our data a name
    @IBAction func addName(sender: AnyObject) {
        
        var alert = UIAlertController(title: "New name",
            message: "Add a new name",
            preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
            style: .Default) { (action: UIAlertAction!) -> Void in
                println("saving")
                let textField = alert.textFields![0] as! UITextField
                self.dataName = textField.text
                self.insertDataInfo.setValue(self.dataName, forKey: "rName")
                println(self.dataName) //There is some sort of threading going on, tis isn't waiting for addName
                println()
                var error: NSError?
                if !self.context.save(&error) {
                    println("Could not save \(error), \(error?.userInfo)")
                }
                self.insertDataInfo = NSEntityDescription.insertNewObjectForEntityForName ("RecordInfo", inManagedObjectContext: self.context) as! RecordInfo
                
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Default) { (action: UIAlertAction!) -> Void in
                self.insertDataInfo = NSEntityDescription.insertNewObjectForEntityForName ("RecordInfo", inManagedObjectContext: self.context) as! RecordInfo

        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
            animated: true,
            completion: nil)
    }

    
    func recordData() {
        if(recording){
            // Call bluetooth here
            count++
            dataArray.append(Double(count))
        }
    }
    
    /* Apple example code (in Obj C)
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation) &&
    !isShowingLandscapeView)
    {
    [self performSegueWithIdentifier:@"DisplayAlternateView" sender:self];
    isShowingLandscapeView = YES;
    }
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
    isShowingLandscapeView)
    {
    [self dismissViewControllerAnimated:YES completion:nil];
    isShowingLandscapeView = NO;
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
