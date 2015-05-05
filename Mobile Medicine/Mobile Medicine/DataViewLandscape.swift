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
    var lineChartView : JBLineChartView
    
    // Variables to be set from the segue DataToLandscape
    // internal is an access specifier that is somewhere in between public and private
    // used so the Portrait View Controller can set that vars
    internal var startDate: NSDate!
    internal var dataName : String = ""
    internal var graphData: [Double] = []
    internal var recording: Bool = false
    var count:Int = 0
    
    
    //Timer for recording data
    var timer : NSTimer!
    var refresh : Int = 0
    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "DataToPortrait") {
            var destinationView:DataViewPortrait = segue.destinationViewController as! DataViewPortrait;
            destinationView.startDate = self.startDate;
            destinationView.dataName = self.dataName;
            if self.graphData != []{
                destinationView.dataArray = self.graphData;
            }
            destinationView.recording = self.recording;
        }
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
            count = 0
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
                    println()
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
    
    
    func recordData() {
        if(recording){
            // Call bluetooth here
            count++
            refresh++
            refresh = refresh%4
            if refresh == 0{
                lineChartView.reloadData();
            }
            graphData.append(Double(count))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
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
        
        
        //start timer at 20Hz
        timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: Selector("recordData"), userInfo: nil, repeats: true)
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
}
