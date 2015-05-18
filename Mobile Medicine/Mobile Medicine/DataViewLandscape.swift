//
//  DataViewLandscape.swift
//  Mobile Medicine
//
//  Created by Marshall Hampson on 4/3/15.
//  Copyright (c) 2015 BRIM. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreData

class DataViewLandscape: UIViewController,CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDelegate, JBLineChartViewDataSource, JBLineChartViewDelegate {
    let _headerHeight:CGFloat = 80
    let _footerHeight:CGFloat = 40
    let _padding:CGFloat = 10
    //let graphData:[CGFloat] = [37,89,48,95,54,50,46,31,77,40,61,58];
    let chartHeaderView = ChartHeaderView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    let _tooltipView = ChartTooltipView();
    let _tooltipTipView = ChartTooltipTipView();
    
    
    // Variables to be set from the segue DataToLandscape
    // internal is an access specifier that is somewhere in between public and private
    // used so the Portrait View Controller can set that vars
    internal var startDate: NSDate!
    internal var dataName : String = ""
    internal var graphData: [Double] = []
    internal var recording: Bool = false
    
    var lineChartView : JBLineChartView
    
    //BLUETOOTH STUFF
    // BLE
    //var cMDelegate : CBCentralManagerDelegate!
    internal var centralManager : CBCentralManager!
    internal var sensorTagPeripheral : CBPeripheral!
    
    // Table View
    internal var sensorTagTableView : UITableView!
    
    // Sensor Values
    internal var allSensorLabels : [String] = []
    internal var allSensorValues : [Double] = []
    internal var ambientTemperature : Double = 0.0
    
    //var runCheck : Bool = false
    
    //Core Data information
    var context:NSManagedObjectContext!
    var infoEntity:NSEntityDescription
    var dataEntity:NSEntityDescription
    var insertDataInfo:NSManagedObject
    var insertData:NSMutableOrderedSet = []
    var appDel:AppDelegate!
    
    convenience init(){
        self.init()
        //Core data context
        appDel = (UIApplication.sharedApplication().delegate as! AppDelegate)
        context = appDel.managedObjectContext
        infoEntity = NSEntityDescription.entityForName("RecordInfo", inManagedObjectContext: context)!
        dataEntity = NSEntityDescription.entityForName("RecordData", inManagedObjectContext: context)!
        //insertDataInfo = NSManagedObject(entity: infoEntity, insertIntoManagedObjectContext: context)
        insertDataInfo = NSEntityDescription.insertNewObjectForEntityForName ("RecordInfo", inManagedObjectContext: context) as! RecordInfo
        lineChartView = JBLineChartView();
        
    }
    
    required init(coder aDecoder: NSCoder) {
        
        //Core data context
        appDel = (UIApplication.sharedApplication().delegate as! AppDelegate)
        context = appDel.managedObjectContext
        infoEntity = NSEntityDescription.entityForName("RecordInfo", inManagedObjectContext: context)!
        dataEntity = NSEntityDescription.entityForName("RecordData", inManagedObjectContext: context)!
        //insertDataInfo = NSManagedObject(entity: infoEntity, insertIntoManagedObjectContext: context)
        insertDataInfo = NSEntityDescription.insertNewObjectForEntityForName ("RecordInfo", inManagedObjectContext: context) as! RecordInfo
        lineChartView = JBLineChartView();
        
        super.init(coder: aDecoder)
        
    }
    
    


    
    
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }
    
  
    
    @IBAction func StartStopButtonAction(sender: AnyObject) {
        println("Start/Stop button pressed");
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
            
            //let fetchRequest = NSFetchRequest(entityName:"RecordInfo")
            //let fetchedResults = context.executeFetchRequest(fetchRequest,
                //error: &error) as? [NSManagedObject]
           /* if let results = fetchedResults {
                for result in results{
                    println(result.valueForKey("rName"))
                    println(result.valueForKey("rDate"))
                    let dataArray = (result.valueForKey("dataRelation")) as! NSOrderedSet
                    for data in dataArray{
                        print(data.valueForKey("rData"), " ")
                    }
                    println()
                }
            }*/
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
                println(self.insertDataInfo.valueForKey("rDate"))
                println(self.insertDataInfo.valueForKey("rName"))
                
                
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        //BLUETOOTH STUFF
        
        // Initialize all sensor values and labels
        allSensorLabels = SensorTag.getSensorLabels()
        for (var i=0; i<allSensorLabels.count; i++) {
            allSensorValues.append(0)
        }
        
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





    /******* CBCentralManagerDelegate *******/

    // Check status of BLE hardware
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if central.state == CBCentralManagerState.PoweredOn {
            println("CM did update state")
            // Scan for peripherals if BLE is turned on
            central.scanForPeripheralsWithServices(nil, options: nil)
        }
        else {
            // Can have different conditions for all states if needed - show generic alert for now
            //showAlertWithText(header: "Error", message: "Bluetooth switched off or not initialized")
        }
    }


    // Check out the discovered peripherals to find Sensor Tag
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        println("CM 1")
        
        if SensorTag.sensorTagFound(advertisementData) == true {
            
            // Update Status Label
            //self.statusLabel.text = "Sensor Tag Found"
            
            // Stop scanning, set as the peripheral to use and establish connection
            self.centralManager.stopScan()
            self.sensorTagPeripheral = peripheral
            self.sensorTagPeripheral?.delegate = self
            self.centralManager.connectPeripheral(peripheral, options: nil)
        }
        else {
            //self.statusLabel.text = "Sensor Tag NOT Found"
            //showAlertWithText(header: "Warning", message: "SensorTag Not Found")
        }
    }

    // Discover services of the peripheral
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        println("CM 2")
        
        //self.statusLabel.text = "Discovering peripheral services"
        peripheral.discoverServices(nil)
    }


    // If disconnected, start searching again
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("CM 3")
        
        //self.statusLabel.text = "Disconnected"
        central.scanForPeripheralsWithServices(nil, options: nil)
        print("looking for shit")
    }

    /******* CBCentralPeripheralDelegate *******/

    // Check if the service discovered is valid i.e. one of the following:
    // IR Temperature Service
    // Accelerometer Service
    // Humidity Service
    // Magnetometer Service
    // Barometer Service
    // Gyroscope Service
    // (Others are not implemented)
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        //self.statusLabel.text = "Looking at peripheral services"
        for service in peripheral.services {
            let thisService = service as! CBService
            if SensorTag.validService(thisService) {
                // Discover characteristics of all valid services
                peripheral.discoverCharacteristics(nil, forService: thisService)
            }
        }
    }


    // Enable notification and sensor for each characteristic of valid service
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        println("Peripheral 1")
        
        //self.statusLabel.text = "Enabling sensors"
        
        var enableValue = 1
        let enablyBytes = NSData(bytes: &enableValue, length: sizeof(UInt8))
        
        for charateristic in service.characteristics {
            let thisCharacteristic = charateristic as! CBCharacteristic
            if SensorTag.validDataCharacteristic(thisCharacteristic) {
                // Enable Sensor Notification
                self.sensorTagPeripheral?.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            }
            if SensorTag.validConfigCharacteristic(thisCharacteristic) {
                // Enable Sensor
                self.sensorTagPeripheral?.writeValue(enablyBytes, forCharacteristic: thisCharacteristic, type: CBCharacteristicWriteType.WithResponse)
            }
        }
        
    }


    // Get data values when they are updated
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        println("Peripheral 2")
        
        //self.statusLabel.text = "Connected"
        
        if characteristic.UUID == IRTemperatureDataUUID {
            self.ambientTemperature = SensorTag.getAmbientTemperature(characteristic.value)
            self.allSensorValues[0] = self.ambientTemperature
            //let model = (self.tabBarController as! CustomTabBarController).model
            //model.dataArray.append(self.ambientTemperature)
            if(recording)
            {
                graphData.append(self.ambientTemperature)
                //tempLabel.text = String(format:"%.2f", self.ambientTemperature)
                lineChartView.reloadData()
            }
            //            dataArray.append(self.ambientTemperature)
            //            tempLabel.text = String(format:"%.2f", self.ambientTemperature)
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
