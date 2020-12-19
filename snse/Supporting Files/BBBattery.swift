//
//  BBBattery.swift
//  snse
//
//  Created by Blake Barrett on 12/18/20.
//  Copyright © 2020 Blake Barrett. All rights reserved.
//

import Foundation
import UIKit

class BBBattery {
    
    private static var instance: BBBattery?
    public static var shared: BBBattery {
        get {
            if let instance = instance {
                return instance
            }
            instance = BBBattery()
            return instance!
        }
    }
    
    private let KEY = "bbbattery"
    
    private var store: UserDefaults
    private var device: UIDevice
    
    private var intialBatteryLevel: Float = -1
    
    // Returns the battery's current charge percentage.
    var batteryLevel: Float {
        get {
            if !device.isBatteryMonitoringEnabled {
                return -1
            }
            return device.batteryLevel
        }
    }
    
    // Returns the total percentage of this battery used by this app over all time.
    public var total: Float {
        get {
            return store.float(forKey: KEY)
        }
    }
    
    private init(valueStore: UserDefaults = UserDefaults.standard,
         device: UIDevice = UIDevice.current) {
        self.store = valueStore
        self.device = device
        self.device.isBatteryMonitoringEnabled = true
    }
    
    public func open() {
        self.intialBatteryLevel = batteryLevel
    }
    
    public func close() {
        let current = batteryLevel
        let total = current - self.intialBatteryLevel
        save(total)
    }
    
    // Writes the percentage of battery USED in this session (not an instantaneous charge value).
    private func save(_ used: Float) {
        let previous = total
        let combined = used + previous
        store.setValue(combined, forKey: KEY)
        // reset the "initial" state to whatever it currently is.
        // Unpairs `close()` from having to have a matched `open()`
        intialBatteryLevel = used
    }
}
