//
//  ViewController.swift
//  SwiftSensorTag
//
//  Created by Anas Imtiaz on 26/01/2015.
//  Copyright (c) 2015 Anas Imtiaz. All rights reserved.
//

import UIKit
import CoreBluetooth

class DataViewPortrait: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDataSource, UITableViewDelegate {
    
    
    var isScanning : Bool = false
    var tempArray : [CGFloat] = []
    var isShowingLandscapeView = false
    
    
    @IBAction func startScanning()
    {
        isScanning = true
    }
    
    @IBAction func stopScanning()
    {
        isScanning = false
    }
    
    @IBAction func buttonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("", sender: tempArray)
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
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
        }
        var secondVC: DataViewLandscape = segue.destinationViewController as! DataViewLandscape
        //secondVC.graphData = tempArray
    }

    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        println("Segue")
//        var secondVC: DataViewLandscape = segue.destinationViewController as! DataViewLandscape
//        secondVC.graphData = tempArray
//        
//    }
    
    override func viewWillAppear(animated: Bool) {
        // Get a reference to the model data from the custom tab bar controller.

        if(self.sensorTagPeripheral == nil)
        {

        }
        else
        {
            let model = (self.tabBarController as! CustomTabBarController).model
            model.tempArray = [] // data goes here to pass back and forth
        }
        
        // Show the we can access and update the model data from the first tab.
        // Let's just increase the age each time this tab appears and assign
        // a random name.
        
    }
    
    
    // Title labels
    var titleLabel : UILabel!
    var statusLabel : UILabel!
    
    // BLE
    var centralManager : CBCentralManager!
    var sensorTagPeripheral : CBPeripheral!
    
    // Table View
    var sensorTagTableView : UITableView!
    
    // Sensor Values
    var allSensorLabels : [String] = []
    var allSensorValues : [CGFloat] = []
    var ambientTemperature : CGFloat = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Initialize central manager on load
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Set up title label
        titleLabel = UILabel()
        titleLabel.text = "Sensor Tag"
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
        //statusLabel.center = CGPoint(x: self.view.frame.midX, y: (titleLabel.frame.maxY + statusLabel.bounds.height/2) )
        statusLabel.frame = CGRect(x: self.view.frame.origin.x, y: self.titleLabel.frame.maxY, width: self.view.frame.width, height: self.statusLabel.bounds.height)
        self.view.addSubview(statusLabel)
        
        // Set up table view
        setupSensorTagTableView()
        
        // Initialize all sensor values and labels
        allSensorLabels = SensorTag.getSensorLabels()
        for (var i=0; i<allSensorLabels.count; i++) {
            allSensorValues.append(0)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    /******* CBCentralManagerDelegate *******/
    
    // Check status of BLE hardware
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if central.state == CBCentralManagerState.PoweredOn {
            println("CM did update state")
            // Scan for peripherals if BLE is turned on
            central.scanForPeripheralsWithServices(nil, options: nil)
            self.statusLabel.text = "Searching for BLE Devices"
        }
        else {
            // Can have different conditions for all states if needed - show generic alert for now
            showAlertWithText(header: "Error", message: "Bluetooth switched off or not initialized")
        }
    }
    
    
    // Check out the discovered peripherals to find Sensor Tag
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        println("CM 1")
        
        if SensorTag.sensorTagFound(advertisementData) == true {
            
            // Update Status Label
            self.statusLabel.text = "Sensor Tag Found"
            
            // Stop scanning, set as the peripheral to use and establish connection
            self.centralManager.stopScan()
            self.sensorTagPeripheral = peripheral
            self.sensorTagPeripheral?.delegate = self
            self.centralManager.connectPeripheral(peripheral, options: nil)
        }
        else {
            self.statusLabel.text = "Sensor Tag NOT Found"
            //showAlertWithText(header: "Warning", message: "SensorTag Not Found")
        }
    }
    
    // Discover services of the peripheral
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        println("CM 2")

        self.statusLabel.text = "Discovering peripheral services"
        peripheral.discoverServices(nil)
    }
    
    
    // If disconnected, start searching again
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("CM 3")

        self.statusLabel.text = "Disconnected"
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
        self.statusLabel.text = "Looking at peripheral services"
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
        
        self.statusLabel.text = "Enabling sensors"
        
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

        
        if isScanning == false
        {
            return
        }
        
        self.statusLabel.text = "Connected"
        
        if characteristic.UUID == IRTemperatureDataUUID {
            self.ambientTemperature = SensorTag.getAmbientTemperature(characteristic.value)
            self.allSensorValues[0] = self.ambientTemperature
            if error != nil
            {
                let model = (self.tabBarController as! CustomTabBarController).model
                model.tempArray.append(self.ambientTemperature)
   
            }            
        }
        
        self.sensorTagTableView.reloadData()
    }
    
    
    /******* UITableViewDataSource *******/
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSensorLabels.count
    }
    
    
    /******* UITableViewDelegate *******/
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var thisCell = tableView.dequeueReusableCellWithIdentifier("sensorTagCell") as! SensorTagTableViewCell
        thisCell.sensorNameLabel.text  = allSensorLabels[indexPath.row]
        
        var valueString = NSString(format: "%.2f", allSensorValues[indexPath.row])
        thisCell.sensorValueLabel.text = valueString as String
        
        return thisCell
    }
    
    
    /******* Helper *******/
    
    // Show alert
    func showAlertWithText (header : String = "Warning", message : String) {
        var alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        alert.view.tintColor = UIColor.redColor()
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // Set up Table View
    func setupSensorTagTableView () {
        
        self.sensorTagTableView = UITableView()
        self.sensorTagTableView.delegate = self
        self.sensorTagTableView.dataSource = self
        
        
        self.sensorTagTableView.frame = CGRect(x: self.view.bounds.origin.x, y: self.statusLabel.frame.maxY+20, width: self.view.bounds.width, height: self.view.bounds.height)
        
        self.sensorTagTableView.registerClass(SensorTagTableViewCell.self, forCellReuseIdentifier: "sensorTagCell")
        
        self.sensorTagTableView.tableFooterView = UIView() // to hide empty lines after cells
        self.view.addSubview(self.sensorTagTableView)
    }
    
    func writeDataToFile(data : NSString) -> NSString
    {
        let file = "temperatureData.txt"
        
        if let dirs : [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
        {
            let dir = dirs[0] //documents directory
            let path = dir.stringByAppendingPathComponent(file);
            //println(path)
            data.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding, error: nil);
            return(path)
        }
        else
        {
            return("No valid path found")
        }
    }
    
    /*    func readDataFromFile(path : NSString)
    {
    let stringData = String:(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)
    }
    */
    // Segues
    
}

