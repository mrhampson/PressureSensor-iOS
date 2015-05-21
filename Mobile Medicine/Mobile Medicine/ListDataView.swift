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
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MMM d, y"
            let cell =
            tableView.dequeueReusableCellWithIdentifier("Cell")
                as! UITableViewCell
            let row = tableElements[indexPath.row]
            let dataName = row.valueForKey("rName") as? String
            let dataDateStr = formatter.stringFromDate((row.valueForKey("rDate") as? NSDate)!)
            cell.textLabel!.text = dataName! + " - " + dataDateStr
            return cell

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath
        self.performSegueWithIdentifier("listDataViewToGraph", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "listDataViewToGraph") {
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
    
}

