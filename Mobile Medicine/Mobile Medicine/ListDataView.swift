//
//  ListDataView.swift
//  Mobile Medicine
//
//  Created by Conor Woods on 5/18/15.
//  Copyright (c) 2015 BRIM. All rights reserved.
//

import UIKit
import CoreData

class ListDataView: UITableViewController {
/*
    
    var countriesinEurope = ["France","Spain","Germany"]
    var countriesinAsia = ["Japan","China","India"]
    var countriesInSouthAmerica = ["Argentia","Brasil","Chile"]
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // 1
        // Return the number of sections.
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 2
        return 3
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        // 3
        // Configure the cell...
        switch (indexPath.section) {
        case 0:
            cell.textLabel?.text = countriesinEurope[indexPath.row]
        case 1:
            cell.textLabel?.text = countriesinAsia[indexPath.row]
        case 2:
            cell.textLabel?.text = countriesInSouthAmerica[indexPath.row]
            //return sectionHeaderView
        default:
            cell.textLabel?.text = "Other"
        }
        
        return cell
    }

    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! ListDataHeader
        headerCell.backgroundColor = UIColor.lightGrayColor()
        
        switch (section) {
        case 0:
            headerCell.HeaderLabel.text = "Europe";
            //return sectionHeaderView
        case 1:
            headerCell.HeaderLabel.text = "Asia";
            //return sectionHeaderView
        case 2:
            headerCell.HeaderLabel.text = "South America";
            //return sectionHeaderView
        default:
            headerCell.HeaderLabel.text = "Other";
        }
        
        return headerCell
    }*/
    internal var date:CVDate!
    var context:NSManagedObjectContext!
    var infoEntity:NSEntityDescription?
    var dataEntity:NSEntityDescription?
    var insertDataInfo:NSManagedObject?
    var insertData:NSMutableOrderedSet = []
    var appDel:AppDelegate!
    var tableElements: [NSManagedObject]! = []
    //var dataToPass: [Double]! = []
    var selectedIndex: NSIndexPath!
    var daysWithData: [String] = []
    let calendar = NSCalendar.currentCalendar()
    //var dataOnDay: [NSManagedObect]! = []
    
    convenience init()
    {
        
        self.init()
        //Core data context
        appDel = (UIApplication.sharedApplication().delegate as! AppDelegate)
        context = appDel.managedObjectContext
        infoEntity = NSEntityDescription.entityForName("RecordInfo", inManagedObjectContext: context)!
        dataEntity = NSEntityDescription.entityForName("RecordData", inManagedObjectContext: context)!
        //insertDataInfo = NSManagedObject(entity: infoEntity, insertIntoManagedObjectContext: context)
    }
    required init(coder aDecoder: NSCoder)
    {
        
        //Core data context
        appDel = (UIApplication.sharedApplication().delegate as! AppDelegate)
        context = appDel.managedObjectContext
        infoEntity = NSEntityDescription.entityForName("RecordInfo", inManagedObjectContext: context)!
        dataEntity = NSEntityDescription.entityForName("RecordData", inManagedObjectContext: context)!
        //insertDataInfo = NSManagedObject(entity: infoEntity, insertIntoManagedObjectContext: context)
        //insertDataInfo = NSEntityDescription.insertNewObjectForEntityForName ("RecordInfo", inManagedObjectContext: context) as! RecordInfo
        super.init(coder: aDecoder)
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self,
            forCellReuseIdentifier: "Cell")
        var error: NSError?
        //var dateHeader: NSDateComponents?
        var inArray: Bool =  false
        let fetchRequest = NSFetchRequest(entityName:"RecordInfo")
        if let fetchedResults = context.executeFetchRequest(fetchRequest, error: &error)
        {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MMM d, y"
            let fetchedResultsOne = fetchedResults as? [NSManagedObject]
            if let results = fetchedResultsOne
            {
                for result in results
                {
                    let rDay = result.valueForKey("rDate") as? NSDate
                    let dateString = formatter.stringFromDate(rDay!)
                    //println(dateString)

                    if daysWithData.count == 0
                    {
                            daysWithData.append(dateString)
                    } // if daysWithData is empty, put in the first element
                    else if (daysWithData.count > 0)
                    {
                        inArray = false
                        for element in daysWithData
                        {
                            if element == dateString
                            {
                                inArray = true
                            }
                        }
                        if inArray == false
                        {
                            daysWithData.append(dateString)
                        }
                    } //if it's not empty, check to see if the day is in there, if not, add it
                    let dataArray = (result.valueForKey("dataRelation")) as! NSOrderedSet
                    if !result.isEqual(nil)
                    {
                        tableElements.append(result)
                    }
                }
            }
        }
        println(daysWithData)
        tableView.reloadData()
        // Do view setup here.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return daysWithData.count
    }
    
    override func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            if tableElements == nil
            {
                return 0
            }
            else
            {
                return tableElements!.count
            }
    }
    
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
            
            let cell =
            tableView.dequeueReusableCellWithIdentifier("Cell")
                as! UITableViewCell
            
            let row = tableElements[indexPath.row]
            cell.textLabel!.text = row.valueForKey("rName") as? String
            
            return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath
        self.performSegueWithIdentifier("dayDataViewToGraph", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "dayDataViewToGraph") {
            var graphView:DataViewLandscape = segue.destinationViewController as! DataViewLandscape
            graphView.dataName = tableElements[selectedIndex.row].valueForKey("rName") as! String
            let data = (tableElements[selectedIndex.row].valueForKey("dataRelation")) as! NSOrderedSet
            graphView.graphData = arrayHelper(data)
            
        }
    }
    func arrayHelper(orderedSet: NSOrderedSet) -> [Double]
    {
        var output: [Double] = []
        for data in orderedSet
        {
            output.append(Double(data.valueForKey("rData") as! NSNumber ))
            println(data.valueForKey("rData"))
        }
        return(output)
    }
    
    /*func getNumDaysWithData(tableElements: [NSManagedObject]) -> Int
    {
    
        for element in tableElements
        {
            if(element.)
        }
        println(numDays)
        return numDays
    }*/
}

