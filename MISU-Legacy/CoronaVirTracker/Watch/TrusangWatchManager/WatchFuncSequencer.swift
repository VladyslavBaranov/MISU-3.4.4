//
//  WatchFuncSequencer.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 07.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation

typealias SequencerCompletion = () -> Void

class WatchFuncSequencer: NSObject {
    static let shared = WatchFuncSequencer()
    private override init() {
        super.init()
    }
    
    var sequence: [WatchMethods] = []
    fileprivate var isReady: Bool = true
    fileprivate let timeout: TimeInterval = 10
    fileprivate var timerToBreak: Timer? = nil
    fileprivate var funcIndex: Int = 0
    
    enum WatchMethods {
        //case bluetoothPrepare
        //case autoReconnect
        //case enablePair
        case startSyns
        case removeAutoReconnect
        case disconnectDevice
        //case discoverWriteCharacteristic
        
        case afterConnectionSyns
        case syncTime
        case readBatteryPower
        case setAutoDetectTemperature
        case setAutoDetectHeartRate
        case readHR_BP_BOCurrent
        case readCurrentTemperature
        case readHR_BP_BOHistoryRecord(date: Date? = nil)
        case readTemperatureHistoryRecord(date: Date? = nil)
        case readStepAndSleepHistoryRecord(date: Date? = nil)
        case readDeviceConfig
        case messageSwitch
        case endSyns
        
        private var wManager: WatchSinglManager {
            get { return WatchSinglManager.shared }
        }
        
        func fire() {
            switch self {
            //case .bluetoothPrepare:
                //wManager.bluetoothPrepare()
            //case .autoReconnect:
                //wManager.autoReconnect()
            //case .enablePair:
                //wManager.enablePair()
            case .startSyns:
                wManager.startSyns(completion)
            case .removeAutoReconnect:
                wManager.removeAutoReconnect(completion)
            case .disconnectDevice:
                wManager.disconnectDevice(completion)
            //case .discoverWriteCharacteristic:
                //wManager.discoverWriteCharacteristic()
            case .afterConnectionSyns:
                wManager.afterConnectionSyns(completion)
            case .syncTime:
                wManager.syncTime(completion)
            case .readBatteryPower:
                wManager.readBatteryPower(completion)
            case .setAutoDetectTemperature:
                wManager.setAutoDetectTemperature(completion)
            case .setAutoDetectHeartRate:
                wManager.setAutoDetectHeartRate(completion)
            case .readHR_BP_BOHistoryRecord(let dt):
                wManager.readHR_BP_BOHistoryRecord(date: dt, completion)
            case .readTemperatureHistoryRecord(let dt):
                wManager.readTemperatureHistoryRecord(date: dt, completion)
            case .endSyns:
                wManager.endSyns(completion)
            case .readHR_BP_BOCurrent:
                wManager.readHR_BP_BOCurrent(completion)
            case .readCurrentTemperature:
                wManager.readCurrentTemperature(completion)
            case .readStepAndSleepHistoryRecord(let dt):
                wManager.readStepAndSleepHistoryRecord(date: dt, completion)
            case .readDeviceConfig:
                wManager.readDeviceConfig(completion)
            case .messageSwitch:
                wManager.messageSwitch(completion)
            }
        }
        
        func completion() {
            WatchFuncSequencer.shared.doneCurrent()
        }
    }
}


extension WatchFuncSequencer {
    func add(_ method: WatchMethods) {
        print("ZHJ FS add")
        sequence.append(method)
        next()
    }
    
    func next() {
         print("ZHJ FS \(isReady)")
         if isReady, let funcToFire = sequence.first {
            isReady = false
            funcToFire.fire()
            timerToBreak = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false, block: { _ in
                print("ZHJ FS timerToBreak")
                self.doneCurrent()
            })
        }
    }
    
    func doneCurrent() {
        print("ZHJ FS doneCurrent")
        timerToBreak?.invalidate()
        timerToBreak = nil
        funcIndex += 1
        if sequence.count > 0 { sequence.removeFirst() }
        isReady = true
        next()
    }
    
    func breakAll() {
        sequence = []
        doneCurrent()
    }
}
