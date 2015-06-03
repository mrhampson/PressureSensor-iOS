//
//  DataViewLandscape.swift
//  Mobile Medicine
//
//  Created by Marshall Hampson on 4/3/15.
//  Copyright (c) 2015 BRIM. All rights reserved.
//

import UIKit
import CoreData

class DataViewLandscape: UIViewController, JBLineChartViewDataSource, JBLineChartViewDelegate {
    let _headerHeight:CGFloat = 80
    let _footerHeight:CGFloat = 40
    let _padding:CGFloat = 10
    //let graphData:[CGFloat] = [37,89,48,95,54,50,46,31,77,40,61,58];
    let chartHeaderView = ChartHeaderView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    let _tooltipView = ChartTooltipView();
    let _tooltipTipView = ChartTooltipTipView();
    var lineChartView : JBLineChartView!
    
    // Variables to be set from the segue DataToLandscape
    // internal is an access specifier that is somewhere in between public and private
    // used so the Portrait View Controller can set that vars
    var fromDataViewPortrait: Bool?
    internal var startDate: NSDate!
    internal var dataName : String = ""
    internal var graphData: [Double] = []
    internal var recording = false // this may be the problem, it's always initialized to false
    var timer : NSTimer!
    //temp for testing
    var lastTemp : Double = Double.NaN
    var lastStatus : Int = 0
    
    //core data stuff
    var context:NSManagedObjectContext!
    var infoEntity:NSEntityDescription
    var dataEntity:NSEntityDescription
    var insertDataInfo:NSManagedObject
    var insertData:NSMutableOrderedSet = []
    var appDel:AppDelegate!
    var connected : Bool = false
    var dateFormat : NSDateFormatter

    
    convenience init(){
        self.init()
        //Core data context
        appDel = (UIApplication.sharedApplication().delegate as! AppDelegate)
        context = appDel.managedObjectContext
        infoEntity = NSEntityDescription.entityForName("RecordInfo", inManagedObjectContext: context)!
        dataEntity = NSEntityDescription.entityForName("RecordData", inManagedObjectContext: context)!
        //insertDataInfo = NSManagedObject(entity: infoEntity, insertIntoManagedObjectContext: context)
        insertDataInfo = NSEntityDescription.insertNewObjectForEntityForName ("RecordInfo", inManagedObjectContext: context) as! RecordInfo
        dateFormat = NSDateFormatter()
    }
    
    required init(coder aDecoder: NSCoder) {
        
        //Core data context
        appDel = (UIApplication.sharedApplication().delegate as! AppDelegate)
        context = appDel.managedObjectContext
        infoEntity = NSEntityDescription.entityForName("RecordInfo", inManagedObjectContext: context)!
        dataEntity = NSEntityDescription.entityForName("RecordData", inManagedObjectContext: context)!
        //insertDataInfo = NSManagedObject(entity: infoEntity, insertIntoManagedObjectContext: context)
        insertDataInfo = NSEntityDescription.insertNewObjectForEntityForName ("RecordInfo", inManagedObjectContext: context) as! RecordInfo
        dateFormat = NSDateFormatter()
        super.init(coder: aDecoder)
        
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad();
        
        lineChartView = JBLineChartView();
        lineChartView.dataSource = self;
        lineChartView.delegate = self;
        lineChartView.backgroundColor = UIColor.whiteColor();
        lineChartView.frame = CGRectMake(0, 44, self.view.frame.height, self.view.frame.width-44);
        lineChartView.reloadData();
        self.view.addSubview(lineChartView);
        
        chartHeaderView.frame =  CGRectMake(_padding,ceil(self.view.bounds.size.height * 0.5) - ceil(_headerHeight * 0.5),self.view.bounds.width - _padding*2, _headerHeight);
        chartHeaderView.titleLabel.text = "Temperature vs Time";
        chartHeaderView.backgroundColor = UIColor.whiteColor();
        chartHeaderView.titleLabel.textColor = UIColor.blackColor();
        chartHeaderView.titleLabel.shadowColor = UIColor.whiteColor();
        lineChartView.headerView = chartHeaderView;
        
        _tooltipView.alpha = 0.0;
        lineChartView.addSubview(_tooltipView);
        _tooltipTipView.alpha = 0.0;
        lineChartView.addSubview(_tooltipTipView);
        //start timer at 20Hz Changed to be 10 HZ since sensor tag operates at 4
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("recordData"), userInfo: nil, repeats: true)
    }
    
    
    @IBAction func StartStopButtonAction(sender: AnyObject) {
        println("Start/Stop button pressed");
        println("Recording: \(recording)")
        if !connected
        {
            showAlertWithText(header: "Error", message: "Device is not connected")
        }
        else
        {
            let btn:UIBarButtonItem = sender as! UIBarButtonItem
            let title = btn.title

            if (!recording)
            {
                println("starting")
                //Start
                startDate = NSDate()
                recording = true
               
                graphData = []
                dataName = String()
                //creating new objects
                insertData = []
                //Start bluetooth recording (or have that automatic based on flag
                //btn.setTitle("Stop", forState: UIControlState.Normal)
                //btn.backgroundColor = UIColor.redColor()
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
                    }
                }
            }
        
            else
            {
                //Stop
                println("Landscape Stopping")
                recording = false
                //Save data to NSData here
                println(startDate.descriptionWithLocale(NSLocale.autoupdatingCurrentLocale()))
                println("inserting Date")
                insertDataInfo.setValue(startDate, forKey: "rDate")
                println(graphData)
                for data in graphData {
                    var newData = NSEntityDescription.insertNewObjectForEntityForName ("RecordData",
                        inManagedObjectContext: context) as! NSManagedObject
                    newData.setValue(data, forKey: "rData")
                    
                    insertData.addObject(newData)
                }
                insertDataInfo.setValue(insertData, forKey: "dataRelation")
                println(insertDataInfo.valueForKey("rDate"))
                addName(self) //sets and saves rName
                //println(startDate.descriptionWithLocale(NSLocale.autoupdatingCurrentLocale()))
                //println(graphData)
                
                println()
                //btn.setTitle("Start", forState: UIControlState.Normal)
                //btn.backgroundColor = UIColor.greenColor()
            }
            
        }
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func numberOfLinesInLineChartView(lineChartView: JBLineChartView!) -> UInt {
        return 1;
    }
    
    func lineChartView(lineChartView: JBLineChartView!, selectionColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return uicolorFromHex(0x3498db);
    }
    
    func lineChartView(lineChartView: JBLineChartView!, selectionColorForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> UIColor! {
        return uicolorFromHex(0xe74c3c);
    }
    
    
    
    func lineChartView(lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        return UInt(graphData.count);
    }
    
    func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        return CGFloat(graphData[Int(horizontalIndex)]);
    }
    
    func lineChartView(lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return uicolorFromHex(0x3498db)
    }
    
    func lineChartView(lineChartView: JBLineChartView!, smoothLineAtLineIndex lineIndex: UInt) -> Bool {
        return true;
    }
    
    func lineChartView(lineChartView: JBLineChartView!, dotRadiusForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        return 2;
    }
    
    func lineChartView(lineChartView: JBLineChartView!, widthForLineAtLineIndex lineIndex: UInt) -> CGFloat {
        return 1;
    }
    
    func lineChartView(lineChartView: JBLineChartView!, showsDotsForLineAtLineIndex lineIndex: UInt) -> Bool {
        return true;
    }
    func lineChartView(lineChartView: JBLineChartView!, colorForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> UIColor! {
        return uicolorFromHex(0xe74c3c)
    }

    func lineChartView(lineChartView: JBLineChartView!, didSelectLineAtIndex lineIndex: UInt, horizontalIndex: UInt, touchPoint: CGPoint) {

        // Adjust tooltip position
        var convertedTouchPoint:CGPoint = touchPoint
        let minChartX:CGFloat = (lineChartView.frame.origin.x + ceil(_tooltipView.frame.size.width * 0.5))
        if (convertedTouchPoint.x < minChartX)
        {
            convertedTouchPoint.x = minChartX
        }
        var maxChartX:CGFloat = (lineChartView.frame.origin.x + lineChartView.frame.size.width - ceil(_tooltipView.frame.size.width * 0.5))
        if (convertedTouchPoint.x > maxChartX)
        {
            convertedTouchPoint.x = maxChartX
        }
        _tooltipView.frame = CGRectMake(
                                convertedTouchPoint.x - ceil(_tooltipView.frame.size.width * 0.5),
                                CGRectGetMaxY(chartHeaderView.frame),
                                _tooltipView.frame.size.width,
                                _tooltipView.frame.size.height
                             );
        
        let formatter = NSNumberFormatter();
        formatter.maximumSignificantDigits = 2;
        formatter.minimumSignificantDigits = 2;
        let currentValue:CGFloat = CGFloat(graphData[Int(horizontalIndex)]);
        let string = formatter.stringFromNumber(currentValue) ?? "0.00";
        _tooltipView.setText(string);
        
        
        var originalTouchPoint:CGPoint = touchPoint
        let minTipX:CGFloat = (lineChartView.frame.origin.x + _tooltipTipView.frame.size.width)
        if (touchPoint.x < minTipX)
        {
            originalTouchPoint.x = minTipX;
        }
        let maxTipX = (lineChartView.frame.origin.x + lineChartView.frame.size.width - _tooltipTipView.frame.size.width);
        if (originalTouchPoint.x > maxTipX)
        {
            originalTouchPoint.x = maxTipX;
        }
        _tooltipTipView.frame = CGRectMake(
                                    originalTouchPoint.x - ceil(_tooltipTipView.frame.size.width * 0.5),
                                    CGRectGetMaxY(_tooltipView.frame),
                                    _tooltipTipView.frame.size.width,
                                    _tooltipTipView.frame.size.height
                                );
        _tooltipView.alpha = 1.0;
        _tooltipTipView.alpha = 1.0;
    }
    
    func didDeselectLineInLineChartView(lineChartView: JBLineChartView!) {
        _tooltipView.alpha = 0.0
        _tooltipTipView.alpha = 0.0
    }
    
    func uicolorFromHex(rgbValue:UInt32)->UIColor{
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:1.0)
    }
    func recordData() {
        if(fromDataViewPortrait!)
        {
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
                    println( "Loading...")
                case 1:
                    println( "Searching for Device" )
                case 2:
                    println( "SensorTag found")
                case 3:
                    println( "Discovering Services" )
                case 4:
                    println( "Looking at Peripheral Services" )
                case 5:
                    println( "Enabling Sensors" )
                case 6:
                    println( "Connected" )
                    connected = true
                case -1:
                    showAlertWithText(header: "Error", message: "Bluetooth switched off or not initialized")
                case -2:
                    showAlertWithText(header: "Warning", message: "SensorTag Not Found")
                default:
                    println( "Unknown" )
                }
            }
            
            if(recording)
            {
            // Call bluetooth here
            //println("Landscape: Recording")
            //let tmp = Int.min
            if( appDel.sensorTag.getTemp() != lastTemp || lastTemp.isNaN){
                //println("Landscape: recorded")
                lastTemp = appDel.sensorTag.getTemp()
                graphData.append(lastTemp)
                lineChartView.reloadData()
                }
                
            }
        }
        
    }
    
    
    // Show alert
    func showAlertWithText (header : String = "Warning", message : String) {
        if(fromDataViewPortrait!)
        {
            var alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            alert.view.tintColor = UIColor.redColor()
            self.presentViewController(alert, animated: true, completion: nil)
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
                if(self.dataName == ""){
                    self.dataName = self.dateFormat.stringFromDate(self.startDate)
                    self.insertDataInfo.setValue(self.dataName, forKey: "rName")
                }
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
                self.dataName = self.dateFormat.stringFromDate(self.startDate)
                self.insertDataInfo.setValue(self.dataName, forKey: "rName")

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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "orientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        notificationCenter.addObserver(self, selector: "saveOnQuit:", name:UIApplicationWillResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: "saveOnQuit:", name:UIApplicationWillTerminateNotification, object: nil)
        
    }
    
    func saveOnQuit(notification: NSNotification){
        if(recording && fromDataViewPortrait!){
            insertDataInfo.setValue(startDate, forKey: "rDate")
            for data in graphData {
                var newData = NSEntityDescription.insertNewObjectForEntityForName ("RecordData",
                    inManagedObjectContext: context) as! NSManagedObject
                newData.setValue(data, forKey: "rData")
                
                insertData.addObject(newData)
            }
            insertDataInfo.setValue(insertData, forKey: "dataRelation")
            dataName = dateFormat.stringFromDate(startDate)
            insertDataInfo.setValue(dataName, forKey: "rName")
            
            //save the data set
            var error: NSError?
            if !self.context.save(&error) {
                println("Could not save \(error), \(error?.userInfo)")
            }
            self.insertDataInfo = NSEntityDescription.insertNewObjectForEntityForName ("RecordInfo", inManagedObjectContext: self.context) as! RecordInfo
            
            recording = false
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(fromDataViewPortrait!)
        {
            
            
            let notificationCenter = NSNotificationCenter.defaultCenter()
            
            notificationCenter.removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
            notificationCenter.removeObserver(self, name: UIApplicationWillTerminateNotification, object: nil)
            
            //moving data back to portrait
            println("preparing for segue from Landscape");
            if(segue.identifier == "DataToPortrait") {
                println("Data to portrait: \(self.recording)")
                var destinationView:DataViewPortrait = segue.destinationViewController as! DataViewPortrait;
                destinationView.dataArray = self.graphData;
                destinationView.recording = self.recording;
                destinationView.startDate = self.startDate;
                destinationView.dataName = self.dataName;
                for stuff in graphData{
                    print(stuff)
                }
            }
        }
    }
    
    func orientationChanged(notification: NSNotification){
        if(fromDataViewPortrait!)
        {
            let deviceOrientation = UIDevice.currentDevice().orientation;
            if (UIDeviceOrientationIsPortrait(deviceOrientation)){
                
                let notificationCenter = NSNotificationCenter.defaultCenter()
                notificationCenter.removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
                self.performSegueWithIdentifier("DataToPortrait", sender: self)
                //isShowingLandscapeView = true
            }
            /*
            else if(UIDeviceOrientationIsPortrait(deviceOrientation) && isShowingLandscapeView){
            self.dismissViewControllerAnimated(true, completion: nil)
            isShowingLandscapeView = false
            }
            */
        }
    }
}
