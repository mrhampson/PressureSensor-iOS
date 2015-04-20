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
    var sensorStatus : Int = 0
        /*
            Status Code for the device, used to print the status text on portrait mode
            0 = loading / haven't scanned
            1 = searching for device
            2 = Sesor Tag found
            -2 = sensor tag not found

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
    
    
    
}
