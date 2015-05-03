//
//  RecordData.swift
//  Mobile Medicine
//
//  Created by Bill Otwell on 4/29/15.
//  Copyright (c) 2015 BRIM. All rights reserved.
//

import Foundation
import CoreData

@objc(RecordData)
class RecordData: NSManagedObject {

    @NSManaged var rData: NSNumber!
    @NSManaged var infoRelation: RecordInfo!

}
