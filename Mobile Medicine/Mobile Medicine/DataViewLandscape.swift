//
//  DataViewLandscape.swift
//  Mobile Medicine
//
//  Created by Marshall Hampson on 4/3/15.
//  Copyright (c) 2015 BRIM. All rights reserved.
//

import UIKit

class DataViewLandscape: UIViewController, JBLineChartViewDataSource, JBLineChartViewDelegate {
    let _headerHeight:CGFloat = 80
    let _footerHeight:CGFloat = 40
    let _padding:CGFloat = 10
    let graphData:[CGFloat] = [37,89,48,95,54,50,46,31,77,40,61,58,74,76,100,72,56,44,59,73,92,60,17,29,7,24,18,71,52,51,69,68,55,99,67,70,84,28,30,27,79,97,75,90,49,62,12,96,14,83,35,5,22,11,66,53,45,98,8,94,16,21,36,93,91,20,65,34,2,25,32,15,86,6,23,81,39,88,10,47,63,57,64,87,26,80,3,42,1,41,78,19,9,43,33,85,13,38,4,82];
    let chartHeaderView = ChartHeaderView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    let _tooltipView = ChartTooltipView();
    let _tooltipTipView = ChartTooltipTipView();


    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let lineChartView = JBLineChartView();
        lineChartView.dataSource = self;
        lineChartView.delegate = self;
        lineChartView.backgroundColor = UIColor.darkGrayColor();
        lineChartView.frame = CGRectMake(0,
            0,
            UIScreen.mainScreen().applicationFrame.height,
            UIScreen.mainScreen().applicationFrame.width);
        lineChartView.reloadData();
        self.view.addSubview(lineChartView);
        
        chartHeaderView.frame =  CGRectMake(_padding,ceil(self.view.bounds.size.height * 0.5) - ceil(_headerHeight * 0.5),self.view.bounds.width - _padding*2, _headerHeight);
        chartHeaderView.titleLabel.text = "Temperature vs Time";
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "orientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
    }
    
    func orientationChanged(notification: NSNotification){
        let deviceOrientation = UIDevice.currentDevice().orientation;
        if (UIDeviceOrientationIsPortrait(deviceOrientation)){
            self.performSegueWithIdentifier("DataToPortrait", sender: self)
            
        }
        
    }
    
    func numberOfLinesInLineChartView(lineChartView: JBLineChartView!) -> UInt {
        return 1;
    }
    
    func lineChartView(lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        return UInt(graphData.count);
    }
    
    func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        return graphData[Int(horizontalIndex)];
    }
    
    func lineChartView(lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return uicolorFromHex(0x34b234)
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
        _tooltipView.frame = CGRectMake(convertedTouchPoint.x - ceil(_tooltipView.frame.size.width * 0.5),
            CGRectGetMaxY(chartHeaderView.frame),
            _tooltipView.frame.size.width,
            _tooltipView.frame.size.height)
        
        let formatter = NSNumberFormatter();
        formatter.maximumSignificantDigits = 2;
        let currentValue:CGFloat = graphData[Int(horizontalIndex)];
        let string = formatter.stringFromNumber(currentValue) ?? "0.00";
        _tooltipView.setText(string);
        
        
        var originalTouchPoint:CGPoint = touchPoint
        let minTipX:CGFloat = (lineChartView.frame.origin.x + _tooltipTipView.frame.size.width)
        if (touchPoint.x < minTipX)
        {
            originalTouchPoint.x = minTipX
        }
        let maxTipX = (lineChartView.frame.origin.x + lineChartView.frame.size.width - _tooltipTipView.frame.size.width)
        if (originalTouchPoint.x > maxTipX)
        {
            originalTouchPoint.x = maxTipX
        }
        _tooltipTipView.frame = CGRectMake(originalTouchPoint.x - ceil(_tooltipTipView.frame.size.width * 0.5), CGRectGetMaxY(_tooltipView.frame), _tooltipTipView.frame.size.width, _tooltipTipView.frame.size.height)
        _tooltipView.alpha = 1.0
        _tooltipTipView.alpha = 1.0
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
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
