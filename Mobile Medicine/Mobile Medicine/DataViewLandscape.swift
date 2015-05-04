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
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Landscape.rawValue)
    }
    
    @IBAction func StartStopButtonAction(sender: AnyObject) {
        println("Start/Stop button pressed");
    }
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let lineChartView = JBLineChartView();
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
}
