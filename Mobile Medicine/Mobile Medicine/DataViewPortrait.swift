//
//  DataViewPortrait.swift
//  Mobile Medicine
//
//  Created by Marshall Hampson on 4/3/15.
//  Copyright (c) 2015 BRIM. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth

class DataViewPortrait: UIViewController, UITableViewDelegate{
    
    //UI info
    var titleLabel : UILabel!
    var statusLabel : UILabel!
    var tempLabel : UILabel!
    var warningLabel : UILabel!
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
    var startDate: NSDate!
    var dataName : String = ""
    var dataArray: [Double] = []      //temp for testing
    var lastTemp : Double = Double.NaN
    var lastStatus : Int = 0
    var recording : Bool = false
    var connected : Bool = false
    
    /*
    //BLUETOOTH STUFF
    // BLE
    var centralManager : CBCentralManager!
    var sensorTagPeripheral : CBPeripheral!
    
    // Table View
    var sensorTagTableView : UITableView!
    
    // Sensor Values
    var allSensorLabels : [String] = []
    var allSensorValues : [Double] = []
    var ambientTemperature : Double = 0.0
    
    //var runCheck : Bool = false
    */
    
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
        
        //centralManager = CBCentralManager(delegate: self, queue: nil)
        
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
        tempLabel.text = "00.00" + "°C"
        tempLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 72)
        tempLabel.sizeToFit()
        tempLabel.center = self.view.center
        self.view.addSubview(tempLabel)

        //start timer at 20Hz Changed to be 10 HZ since sensor tag operates at 4
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("recordData"), userInfo: nil, repeats: true)
        
        //BLUETOOTH
        
    }
    
    func buttonAction(sender:UIButton!)
    {
        let btn:UIButton = sender
        if connected
        {
            warningLabel.removeFromSuperview()
            //warningLabel.removeAllSubviews()
            
            let btn:UIButton = sender
            let title = btn.titleLabel?.text
            if (title == "Start")
            {
                //Start
                startDate = NSDate()
                recording = true
                dataArray = []
                dataName = String()
                //creating new objects
                insertData = []
                //Start bluetooth recording (or have that automatic based on flag
                btn.setTitle("Stop", forState: UIControlState.Normal)
                btn.setTitleColor((UIColor.blackColor()), forState: UIControlState.Normal)

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
                //Stop
                recording = false
                //Save data to NSData here
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
                btn.backgroundColor = UIColor(red: 0.0, green:0.777, blue:0.222, alpha:1.0)
            }
        }
        else
        {
            showAlertWithText(header: "Error", message: "Connect the device before recording data")
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
        if(segue.identifier != "DataToLandscape"){
            // Notification center will detect when you rotate to landscape view and will call
            // a segue to DataLandscape
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
        } else if(segue.identifier == "DataToLandscape" && self.dataArray.count != 0 ) {
            var destinationView:DataViewLandscape = segue.destinationViewController as! DataViewLandscape;
            destinationView.startDate = self.startDate;
            destinationView.dataName = self.dataName;
            for stuff in dataArray{
                print(stuff)
            }
            destinationView.graphData = self.dataArray;
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
        
        button = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        button.frame = CGRectMake(100, 100, 100, 50)
        button.layer.cornerRadius = 15
        button.backgroundColor = UIColor(red: 0.0, green:0.777, blue:0.222, alpha:1.0)
        button.setTitle("Start", forState: UIControlState.Normal)
        button.setTitleColor((UIColor.blackColor()), forState: UIControlState.Normal)
        button.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        button.center = CGPoint(x: self.view.frame.midX, y: self.view.bounds.maxY - 100 )
        
        warningLabel = UILabel(frame:CGRectMake(0, 0, 200, 100))
        warningLabel.backgroundColor = UIColor(red: 0.777, green:0.222, blue:0.222, alpha:1.0)
        warningLabel.textAlignment = .Center
        warningLabel.text = "Please connect the device before recording data"
        warningLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        warningLabel.center = CGPoint(x: self.view.frame.midX, y:self.titleLabel.bounds.midY + 350)
        warningLabel.lineBreakMode = .ByWordWrapping
        warningLabel.numberOfLines = 0
        warningLabel.layer.cornerRadius = 15

        
        if(appDel.sensorTag.getStatus() != lastStatus){
            lastStatus = appDel.sensorTag.getStatus()
            switch(appDel.sensorTag.getStatus()){
                /*
                Status Code for the device, used to print the status text on portrait mode
                0 = loading / haven't scanned
                1 = searching for device
                2 = Sesor Tag found
                -2 = sensor tag not found
                3 = discovering services
                4 = looking at peripheral services
                5 = enabling sensors
                */
            case 0:
                statusLabel.text = "Loading..."
            case 1:
                statusLabel.text = "Searching for Device"
            case 2:
                statusLabel.text = "SensorTag found"
            case 3:
                statusLabel.text = "Discovering Services"
            case 4:
                statusLabel.text = "Looking at Peripheral Services"
            case 5:
                statusLabel.text = "Enabling Sensors"
            case 6:
                statusLabel.text = "Connected"
                if(!connected)
                {
                    println("We in here")
                    print(warningLabel)
                    warningLabel.text = " "
                    warningLabel.backgroundColor = UIColor.clearColor()
                    //(red:(0xe4/255) , green:(0xf1/255), blue:(0xfe/255), alpha:1.0)
                    self.view.addSubview(warningLabel)

                }
                connected = true
                self.view.addSubview(button)

            case -1:
                showAlertWithText(header: "Error", message: "Bluetooth switched off or not initialized")
            case -2:
                connected = false
                showAlertWithText(header: "Warning", message: "SensorTag Not Found")
                self.view.addSubview(warningLabel)
            default:
                statusLabel.text = "Unknown"
            }
        }
        if(recording){
            // Call bluetooth here
            //let tmp = Int.min
            if( appDel.sensorTag.getTemp() != lastTemp || lastTemp.isNaN){
                lastTemp = appDel.sensorTag.getTemp()
                dataArray.append(lastTemp)
                tempLabel.text = String(format:"%.2f" + "°C", self.lastTemp)
            }
        }
    }
    
    // Show alert
    func showAlertWithText (header : String = "Warning", message : String) {
        var alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        alert.view.tintColor = UIColor.redColor()
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}