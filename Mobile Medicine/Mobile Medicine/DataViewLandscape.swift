//
//  DataViewLandscape.swift
//  Mobile Medicine
//
//  Created by Marshall Hampson on 4/3/15.
//  Copyright (c) 2015 BRIM. All rights reserved.
//

import UIKit
import CoreData

class DataViewLandscape: UIViewController, CPTScatterPlotDataSource, CPTScatterPlotDelegate, CPTPlotSpaceDelegate {
    var alert : UIAlertController?
    
    
    // Variables to be set from the segue DataToLandscape
    // internal is an access specifier that is somewhere in between public and private
    // used so the Portrait View Controller can set that vars
    var showLabels:Bool = false
    var fromDataViewPortrait: Bool?
    internal var startDate: NSDate!
    internal var dataName : String = ""
    internal var graphData: [Double] = []
    internal var recording: Bool = false
    var timer : NSTimer!
    //temp for testing
    var lastTemp : Double = 0.0
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

    var counter:Int = 1
    
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
    

    @IBOutlet var graphView: CPTGraphHostingView!
    
    func initPlot() -> Void {
        self.configureHost();
        self.configureGraph();
        self.configurePlots();
        self.configureAxes();
    }
    
    func configureHost() -> Void {

        graphView.frame = self.view.bounds
        graphView.frame.offset(dx: 0, dy: 30)
        //self.view.bounds.
        graphView.allowPinchScaling = true
    }
    
    func configureGraph() -> Void {
        // Create the graph
        var graph:CPTGraph = CPTXYGraph(frame: self.graphView.bounds)
        graph.applyTheme(CPTTheme(named: "kCPTDarkGradientTheme"))
        self.graphView.hostedGraph = graph
        // Set title
        //graph.title = "Test Graph"
        // Create and set text syle
        var titleStyle:CPTMutableTextStyle = CPTMutableTextStyle()
        titleStyle.color = CPTColor.whiteColor()
        titleStyle.fontName = "Helvetica-Bold"
        titleStyle.fontSize = 16.0
        graph.titleTextStyle = titleStyle
        graph.titlePlotAreaFrameAnchor = CPTRectAnchor.Top
        graph.titleDisplacement = CGPointMake(0, 10)
        // Set padding for plot area

        graph.plotAreaFrame.paddingLeft = 60
        graph.plotAreaFrame.paddingBottom = 45
        graph.plotAreaFrame.paddingTop = 0

        // Enable user interaction for plot space
        graph.defaultPlotSpace.allowsUserInteraction = true
    }
    
    func configurePlots() -> Void {
        // Get graph and plot space
        var graph:CPTGraph = graphView.hostedGraph
        var plotSpace:CPTXYPlotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        // Create plots
        var plot:CPTScatterPlot = CPTScatterPlot(frame: CGRectZero)
        var lineStyle: CPTMutableLineStyle = plot.dataLineStyle.mutableCopy() as! CPTMutableLineStyle
        lineStyle.lineColor = CPTColor.blueColor()
        lineStyle.lineWidth = 2
        plot.dataLineStyle = lineStyle
        plot.interpolation = CPTScatterPlotInterpolation.Curved
        plot.dataSource = self
        plot.delegate = self
        // Add plot symbols
        var plotSymbol:CPTPlotSymbol = CPTPlotSymbol.ellipsePlotSymbol()
        plotSymbol.fill = CPTFill(color: CPTColor.redColor())
        plotSymbol.size = CGSizeMake(5, 5)
        plot.plotSymbol = plotSymbol
        graph.addPlot(plot, toPlotSpace: plotSpace)

        // Set up plot space
        var plots:[CPTScatterPlot] = [plot]
        plotSpace.scaleToFitPlots(plots)
        plotSpace.globalXRange = CPTPlotRange(location: FloatToDecimal.Convert(0), length: FloatToDecimal.Convert(1500))
        // Create styles and symbols
    }
    
    func configureAxes() -> Void {
        var axisTitleStyle:CPTMutableTextStyle = CPTMutableTextStyle()
        axisTitleStyle.color = CPTColor.blackColor()
        axisTitleStyle.fontSize = 12
        
        var axisSet:CPTXYAxisSet = self.graphView.hostedGraph.axisSet as! CPTXYAxisSet
        axisSet.xAxis.title = "Time (Seconds)"
        axisSet.xAxis.titleTextStyle = axisTitleStyle;
        axisSet.xAxis.titleOffset = 17.0;
        var x:CPTXYAxis = axisSet.xAxis
        x.labelingPolicy = .Automatic
        //x.title = "time (0.25s)"
        x.axisConstraints = CPTConstraints(lowerOffset: 0.0)
        x.minorTicksPerInterval = 3
        
        
        
        axisSet.yAxis.title = "Temp (°C)"
        axisSet.yAxis.titleTextStyle = axisTitleStyle;
        axisSet.yAxis.titleOffset = 30.0;
        var y:CPTXYAxis = axisSet.yAxis
        
        y.labelingPolicy = .Automatic
        y.axisConstraints = CPTConstraints(lowerOffset: 0.0)
        y.minorTicksPerInterval = 9
        y.labelingPolicy = .Automatic
        
        //axisSet.yAxis.title = "Temp (°C)"
        
//        y.titleTextStyle = axisTitleStyle
//        axisSet.xAxis.titleTextStyle = axisTitleStyle;
//        axisSet.xAxis.titleOffset = 10.0f;

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.initPlot()
        dateFormat.dateStyle = NSDateFormatterStyle.NoStyle
        dateFormat.timeStyle = NSDateFormatterStyle.MediumStyle
        //start timer at 20Hz Changed to be 10 HZ since sensor tag operates at 4
        timer = NSTimer.scheduledTimerWithTimeInterval(0.25, target: self, selector: Selector("recordData"), userInfo: nil, repeats: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        return UInt(graphData.count);
    }
    
    func numberForPlot(plot: CPTPlot!, field fieldEnum: UInt, recordIndex idx: UInt) -> AnyObject! {
        if (fieldEnum == UInt(CPTScatterPlotField.X.rawValue)) {
            // Divide by 4 because our sample rate is 4 Hz.
            return Double(idx)/4
        } else if(fieldEnum == UInt(CPTScatterPlotField.Y.rawValue)) {
            return graphData[Int(idx)]
        }
        return graphData[Int(idx)];
    }
    
    func scatterPlotDataLineWasSelected(plot: CPTScatterPlot!) {
        if let plot = graphView.hostedGraph.plotAtIndex(0) {
            showLabels = !showLabels
            if (showLabels) {
                var formatter:NSNumberFormatter = NSNumberFormatter()
                formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
                formatter.minimumFractionDigits = 2
                plot.labelFormatter = formatter
                var pointLabelTextStyle:CPTMutableTextStyle = CPTMutableTextStyle()
                pointLabelTextStyle.color = CPTColor.blackColor()
                pointLabelTextStyle.fontName = "Helvetica-Bold"
                pointLabelTextStyle.fontSize = 16.0
                plot.labelTextStyle = pointLabelTextStyle
                plot.reloadDataLabels()
            } else {
                plot.labelFormatter = nil
                plot.labelTextStyle = nil
                plot.reloadDataLabels()
            }
        }
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
            
            if(recording) {
            // Call bluetooth here

                //println("Landscape: Recording")
                //if( appDel.sensorTag.getTemp() != lastTemp || lastTemp.isNaN){
                //println("Landscape: recorded")
                lastTemp = appDel.sensorTag.getTemp()
                //lastTemp = (lastTemp+1)%10
                graphData.append(lastTemp)
                //println(lastTemp)
                if let plotspace = graphView.hostedGraph.defaultPlotSpace {
                    plotspace.scaleToFitPlots(graphView.hostedGraph.allPlots())
            
                }
                if let plot = graphView.hostedGraph.plotAtIndex(0) {
                    plot.reloadData()
                }
            }
        }
        
    }
    
    
    // Show alert
    func showAlertWithText (header : String = "Warning", message : String) {
        if(fromDataViewPortrait!)
        {
            alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert!.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            alert!.view.tintColor = UIColor.redColor()
            self.presentViewController(alert!, animated: true, completion: nil)
        }
    }
    
    //give our data a name
    @IBAction func addName(sender: AnyObject) {
        
        alert = UIAlertController(title: "New name",
            message: "Add a new name",
            preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
            style: .Default) { (action: UIAlertAction!) -> Void in
                
                let textField = self.alert!.textFields![0] as! UITextField
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
        
        alert!.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
        }
        
        alert!.addAction(saveAction)
        alert!.addAction(cancelAction)
        
        presentViewController(alert!,
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
                if let activeAlert = alert{
                    activeAlert.dismissViewControllerAnimated(false, completion: nil)
                }
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
