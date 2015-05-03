//
//  RecordInfo.swift
//  Mobile Medicine
//
//  Created by Bill Otwell on 4/29/15.
//  Copyright (c) 2015 BRIM. All rights reserved.
//

import Foundation
import CoreData

@objc(RecordInfo)
class RecordInfo: NSManagedObject {

    @NSManaged var rDate: NSDate!
    @NSManaged var rName: String!
    @NSManaged var dataRelation: NSOrderedSet!

}
