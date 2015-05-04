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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var error: NSError?
        
        let fetchRequest = NSFetchRequest(entityName:"RecordInfo")
        if error != nil
        {
            let fetchedResults = context.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
            println("Is this executed")
            
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

        // Do view setup here.
    }
    
}
