//
//  SensorTag.swift
//  SwiftSensorTag
//
//  Created by Anas Imtiaz on 26/01/2015.
//  Copyright (c) 2015 Anas Imtiaz. All rights reserved.
//

import Foundation
import CoreBluetooth


let deviceName = "SensorTag"

// Service UUIDs
let IRTemperatureServiceUUID = CBUUID(string: "F000AA00-0451-4000-B000-000000000000")

// Characteristic UUIDs
let IRTemperatureDataUUID   = CBUUID(string: "F000AA01-0451-4000-B000-000000000000")
let IRTemperatureConfigUUID = CBUUID(string: "F000AA02-0451-4000-B000-000000000000")


class SensorTag {
    
    // Check name of device from advertisement data
    class func sensorTagFound (advertisementData: [NSObject : AnyObject]!) -> Bool {
        let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString
        return (nameOfDeviceFound == deviceName)
    }
    
    
    // Check if the service has a valid UUID
    class func validService (service : CBService) -> Bool {
        if service.UUID == IRTemperatureServiceUUID {
                return true
        }
        else {
            return false
        }
    }
    
    
    // Check if the characteristic has a valid data UUID
    class func validDataCharacteristic (characteristic : CBCharacteristic) -> Bool {
        if characteristic.UUID == IRTemperatureDataUUID {
                return true
        }
        else {
            return false
        }
    }
    
    
    // Check if the characteristic has a valid config UUID
    class func validConfigCharacteristic (characteristic : CBCharacteristic) -> Bool {
        if characteristic.UUID == IRTemperatureConfigUUID {
                return true
        }
        else {
            return false
        }
    }
    
    
    // Get labels of all sensors
    class func getSensorLabels () -> [String] {
        let sensorLabels : [String] = [
            "Ambient Temperature"
        ]
        return sensorLabels
    }
    
    
    
    // Process the values from sensor
    
    
    // Convert NSData to array of bytes
    class func dataToSignedBytes16(value : NSData) -> [Int16] {
        let count = value.length
        var array = [Int16](count: count, repeatedValue: 0)
        value.getBytes(&array, length:count * sizeof(Int16))
        return array
    }
    
    class func dataToUnsignedBytes16(value : NSData) -> [UInt16] {
        let count = value.length
        var array = [UInt16](count: count, repeatedValue: 0)
        value.getBytes(&array, length:count * sizeof(UInt16))
        return array
    }
    
    class func dataToSignedBytes8(value : NSData) -> [Int8] {
        let count = value.length
        var array = [Int8](count: count, repeatedValue: 0)
        value.getBytes(&array, length:count * sizeof(Int8))
        return array
    }
    
    // Get ambient temperature value
    class func getAmbientTemperature(value : NSData) -> CGFloat {
        let dataFromSensor = dataToSignedBytes16(value)
        let ambientTemperature = CGFloat(dataFromSensor[1])/128
        return ambientTemperature
    }
    
}