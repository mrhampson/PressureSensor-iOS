//
//  dayDataViewTable.swift
//  Mobile Medicine
//
//  Created by Conor Woods on 5/3/15.
//  Copyright (c) 2015 BRIM. All rights reserved.
//

import UIKit
import CoreData

class dayDataViewTable: UITableViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self,
            forCellReuseIdentifier: "Cell")
        var error: NSError?
        let fetchRequest = NSFetchRequest(entityName:"RecordInfo")

            
        if let fetchedResults = context.executeFetchRequest(fetchRequest, error: &error)
        {
            let fetchedResultsOne = fetchedResults as? [NSManagedObject]
            if let results = fetchedResultsOne
            {
                for result in results
                {
                    let rDay = result.valueForKey("rDate") as? NSDate
                    let cDay = date.convertedDate()
                    let next = cDay!.dateByAddingTimeInterval( (24 * 60 * 60 - 8*60*60) )
                    let prev = cDay!.dateByAddingTimeInterval( (-24 * 60 * 60 - 8*60*60))
                    if rDay?.earlierDate(next) == rDay && rDay?.laterDate(prev) == rDay
                    {
                        //println(result.valueForKey("rName"))
                        //println(result.valueForKey("rDate"))
                        let dataArray = (result.valueForKey("dataRelation")) as! NSOrderedSet
                        if !result.isEqual(nil)
                        {
                            tableElements.append(result)
                            println("Appended value")
                        }
                        /*for data in dataArray
                        {
                            print(data.valueForKey("rData"), " ")
                        }*/
                    }
                    println()
                }
            }
        }

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
}
