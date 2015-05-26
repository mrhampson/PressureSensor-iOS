//
//  Bluetooth.swift
//  Mobile Medicine
//
//  Created by Bill Otwell on 4/19/15.
//  Copyright (c) 2015 BRIM. All rights reserved.
//

import CoreBluetooth



class Bluetooth: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager : CBCentralManager!
    var sensorTagPeripheral : CBPeripheral!
    var bTemp : Double = 0.0
    var sensorStatus : Int = 0
        /*
            Status Code for the device, used to print the status text on portrait mode
            0 = loading / haven't scanned
            -1 = Bluetooth turned off
            1 = searching for device
            2 = Sesor Tag found
            -2 = sensor tag not found
            3 = discovering services
            4 = looking at peripheral services
            5 = enabling sensors

        */
    // IR Temp UUIDs
    let IRTemperatureServiceUUID = CBUUID(string: "F000AA00-0451-4000-B000-000000000000")
    let IRTemperatureDataUUID   = CBUUID(string: "F000AA01-0451-4000-B000-000000000000")
    let IRTemperatureConfigUUID = CBUUID(string: "F000AA02-0451-4000-B000-000000000000")
    
    
    override init() {
            super.init()
            centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    
    // Check status of BLE hardware
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if central.state == CBCentralManagerState.PoweredOn {
            // Scan for peripherals if BLE is turned on
            central.scanForPeripheralsWithServices(nil, options: nil)
            //self.statusLabel.text = "Searching for BLE Devices"
            sensorStatus = 1
        }
        else {
            // Can have different conditions for all states if needed - print generic message for now
            sensorStatus = -1
            
            
            println("Bluetooth switched off or not initialized")
        }
    }
    
    
    // Check out the discovered peripherals to find Sensor Tag
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        let deviceName = "SensorTag"
        let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString
        
        if (nameOfDeviceFound == deviceName) {
            // Update Status Label
            //self.statusLabel.text = "Sensor Tag Found"
            sensorStatus = 2
            
            // Stop scanning
            self.centralManager.stopScan()
            // Set as the peripheral to use and establish connection
            self.sensorTagPeripheral = peripheral
            self.sensorTagPeripheral.delegate = self
            self.centralManager.connectPeripheral(peripheral, options: nil)
        }
        else {
            //self.statusLabel.text = "Sensor Tag NOT Found"
            sensorStatus = -2
        }
    }
    
    
    // Discover services of the peripheral
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        //self.statusLabel.text = "Discovering peripheral services"
        sensorStatus = 3
        peripheral.discoverServices(nil)
    }
    
    
    // Check if the service discovered is a valid IR Temperature Service
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        //self.statusLabel.text = "Looking at peripheral services"
        sensorStatus = 4
        for service in peripheral.services {
            let thisService = service as! CBService
            if service.UUID == IRTemperatureServiceUUID {
                // Discover characteristics of IR Temperature Service
                peripheral.discoverCharacteristics(nil, forService: thisService)
            }
            // Uncomment to print list of UUIDs
            //println(thisService.UUID)
        }
    }
    
    // Enable notification and sensor for each characteristic of valid service
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        
        // update status label
        //self.statusLabel.text = "Enabling sensors"
        sensorStatus = 5
        
        // 0x01 data byte to enable sensor
        var enableValue = 1
        let enablyBytes = NSData(bytes: &enableValue, length: sizeof(UInt8))
        
        // check the uuid of each characteristic to find config and data characteristics
        for charateristic in service.characteristics {
            let thisCharacteristic = charateristic as! CBCharacteristic
            // check for data characteristic
            if thisCharacteristic.UUID == IRTemperatureDataUUID {
                // Enable Sensor Notification
                self.sensorTagPeripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            }
            // check for config characteristic
            if thisCharacteristic.UUID == IRTemperatureConfigUUID {
                // Enable Sensor
                self.sensorTagPeripheral.writeValue(enablyBytes, forCharacteristic: thisCharacteristic, type: CBCharacteristicWriteType.WithResponse)
            }
        }
        
    }
    
    // Get data values when they are updated
//    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
//        
//        //self.statusLabel.text = "Connected"
//        sensorStatus = 6
//        
//        if characteristic.UUID == IRTemperatureDataUUID {
//            // Convert NSData to array of signed 16 bit values
//            let dataBytes = characteristic.value
//            let dataLength = dataBytes.length
//            var dataArray = [Int16](count: dataLength, repeatedValue: 0)
//            dataBytes.getBytes(&dataArray, length: dataLength * sizeof(Int16))
//            
//            // Element 1 of the array will be ambient temperature raw value
//            let bTemp = Double(dataArray[1])/128
//            
//            // Display on the temp label
//            //self.tempLabel.text = NSString(format: "%.2f", ambientTemperature)
//        }
//    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        println("Peripheral 2")
        
        sensorStatus = 6
        
        if characteristic.UUID == IRTemperatureDataUUID {
            self.bTemp = SensorTag.getAmbientTemperature(characteristic.value)
            //self.allSensorValues[0] = self.ambientTemperature
            //let model = (self.tabBarController as! CustomTabBarController).model
            //model.dataArray.append(self.ambientTemperature)
            println("BTemp = ", bTemp.description)
        }
    }
    
    func getTemp() -> Double{
        //println("Bluetooth: Temp = ", bTemp.description)
        return bTemp
    }
    
    func getStatus() -> Int{
        //println("BlueTooth: Status = ", sensorStatus.description)
        return sensorStatus
    }

    
    
}
