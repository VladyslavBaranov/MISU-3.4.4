//
//  WatchSinglManager.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 01.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation
import TrusangBluetooth
//import CoreBluetooth

class WatchSinglManager: NSObject {
    var watchName: String = ""
    
    static let shared = WatchSinglManager()
    private override init() {
        super.init()
        bluetoothPrepare()
    }
    
    let btProvider = ZHJBLEManagerProvider.shared
    let enablePairProcessor = ZHJEnablePairProcessor()
    let batteryProcessor = ZHJBatteryProcessor()
    let syncTimeProcessor = ZHJSyncTimeProcessor()
    let HR_BP_BOProcessor = ZHJHR_BP_BOProcessor()
    let temperatureProcessor = ZHJTemperatureProcessor()
    
    var connectedDeviceZHJ: ZHJBTDevice? {
        get { btProvider.currentDevice }
    }
    
    var currentUserToken: String? = nil
    var currentDeviceName: String? = nil
    
    
    var bo_: [HealthParameterModel] = [] {
        didSet {
            var str = "ZHJ bo_ history:\n"
            bo_.forEach({ str += "\($0)\n" })
            //sendLogsToServer(string: str)
        }
    }
    var hr_: [HealthParameterModel] = [] {
        didSet {
            var str = "ZHJ hr_ history:\n"
            hr_.forEach({ str += "\($0)\n" })
            //sendLogsToServer(string: str)
        }
    }
    var tm_: [HealthParameterModel] = [] {
        didSet {
            var str = "ZHJ tm_ history:\n"
            tm_.forEach({ str += "\($0)\n" })
            //sendLogsToServer(string: str)
        }
    }
    var bp_: [HealthParameterModel] = [] {
        didSet {
            var str = "ZHJ bp_ history:\n"
            bp_.forEach({ str += "\($0)\n" })
            //sendLogsToServer(string: str)
        }
    }
}



// MARK: - ZHJ Server Get and Save
extension WatchSinglManager {
    func checkIndicByTime(date: Date?) -> Bool {
        guard let date = date,
              (date.compare(Date()) == .orderedAscending || date.compare(Date()) == .orderedSame) else { return false }
        return true
    }
    
    func saveHealthParamsServer(bo: [HealthParameterModel] = [], hr: [HealthParameterModel] = [], tm: [HealthParameterModel] = [], bp: [HealthParameterModel] = []) {
        //sendLogsToServer(string: "ZHJ try saveHealthParamsServer \n\(bo) \n\(hr) \n\(tm) \n\(bp)")
        guard let token = currentUserToken else { return }
        HealthParamsManager.shared.writeListHParams(token: token, model: ListHParameterModel(temp: tm, hb: hr, bo: bo, bp: bp)) { (success, errorOp) in
            self.bo_ += bo
            self.hr_ += hr
            self.tm_ += tm
            self.bp_ += bp
        }
    }
    
    func convertParams(heartRate: ZHJHeartRate) -> [HealthParameterModel] {
        var hpm: [HealthParameterModel] = []
        heartRate.details.forEach { zhjParam in
            //guard zhjParam.HR > 0 else { return }
            //guard checkIndicByTime(date: zhjParam.dateTime.toDate()) else { return }
            hpm.append(HealthParameterModel(id: -1, value: Float(zhjParam.HR), date: zhjParam.dateTime))
        }
        return hpm
    }
    
    func convertParams(bloodOxygen: ZHJBloodOxygen) -> [HealthParameterModel] {
        var hpm: [HealthParameterModel] = []
        bloodOxygen.details.forEach { zhjParam in
            //guard zhjParam.BO > 0 else { return }
            hpm.append(HealthParameterModel(id: -1, value: Float(zhjParam.BO), date: zhjParam.dateTime))
        }
        return hpm
    }
    
    func convertParams(temperature: ZHJTemperature) -> [HealthParameterModel] {
        var hpm: [HealthParameterModel] = []
        temperature.details.forEach { zhjParam in
            let corTemp = zhjParam.wristTemperature > 0 ? (Double(zhjParam.wristTemperature)/100.0).truncate(places: 1) :  (Double(zhjParam.headTemperature)/100.0).truncate(places: 1)
            //guard corTemp > 0 else { return }
            hpm.append(HealthParameterModel(id: -1, value: Float(corTemp), date: zhjParam.dateTime))
        }
        return hpm
    }
    
    func convertParams(bloodPressure: ZHJBloodPressure) -> [HealthParameterModel] {
        var hpm: [HealthParameterModel] = []
        bloodPressure.details.forEach { zhjParam in
            //guard zhjParam.DBP > 0 else { return }
            //guard zhjParam.SBP > 0 else { return }
            hpm.append(HealthParameterModel(id: -1, value: Float(zhjParam.SBP), additionalValue: Float(zhjParam.DBP), date: zhjParam.dateTime))
        }
        return hpm
    }
}



// MARK: - ZHJ SDK Data Synchronization
extension WatchSinglManager {
    func afterConnectionSyns(_ completion: (() -> Void)? = nil) {
        print("ZHJ start sync ...")
        //sendLogsToServer(string: "ZHJ start sync ...")
        discoverWriteCharacteristic(completion)
    }
    
    func updateSyns() {
        print("ZHJ start update sync ...")
    }
    
    func discoverWriteCharacteristic(_ completion: (() -> Void)? = nil) {
        btProvider.discoverWriteCharacteristic { [self] characteristic in
            print("ZHJ discoverWriteCharacteristic \(characteristic)")
            //sendLogsToServer(string: "ZHJ discoverWriteCharacteristic \(characteristic)")
            completion?()
            readCurrentTemperature {
                self.readHR_BP_BOCurrent()
            }
        }
    }
    
    func readHR_BP_BOCurrent(_ completion: (() -> Void)? = nil) {
        //sendLogsToServer(string: "ZHJ try readHR_BP_BOCurrent")
        HR_BP_BOProcessor.readCurrentHR_BP_BO { [self] (heartRateD, bloodPressureD, bloodOxygenD) in
            print("ZHJ readHR_BP_BOCurrent \n\(heartRateD)\n\(bloodPressureD)\n\(bloodOxygenD)")
            //sendLogsToServer(string: "ZHJ readHR_BP_BOCurrent \n\(heartRateD)\n\(bloodPressureD)\n\(bloodOxygenD)")
            let heartRate = ZHJHeartRate()
            let bloodOxygen = ZHJBloodOxygen()
            let bloodPressure = ZHJBloodPressure()
            heartRateD.dateTime = Date().getTimeDateForRequest()
            bloodOxygenD.dateTime = Date().getTimeDateForRequest()
            bloodPressureD.dateTime = Date().getTimeDateForRequest()
            bloodPressure.details.append(bloodPressureD)
            heartRate.details.append(heartRateD)
            bloodOxygen.details.append(bloodOxygenD)
            
            self.saveHealthParamsServer(
                bo: convertParams(bloodOxygen: bloodOxygen),
                hr: convertParams(heartRate: heartRate),
                bp: convertParams(bloodPressure: bloodPressure))
            
            completion?()
        }
    }
    
    func readCurrentTemperature(_ completion: (() -> Void)? = nil) {
        //sendLogsToServer(string: "ZHJ try readCurrentTemperature")
        temperatureProcessor.readCurrentTemperature { [self] (temperatureD) in
            print("ZHJ readCurrentTemperature \n\(temperatureD)")
            //sendLogsToServer(string: "ZHJ readCurrentTemperature \n\(temperatureD)")
            let temperature = ZHJTemperature()
            temperatureD.dateTime = Date().getTimeDateForRequest()
            temperature.details.append(temperatureD)
            self.saveHealthParamsServer(tm: convertParams(temperature: temperature))

            completion?()
        }
    }
}



// MARK: - ZHJ SDK Connections
extension WatchSinglManager {
    func enablePair(_ completion: (() -> Void)? = nil) {
        enablePairProcessor.enablePair { result in
            if result == .correct {
                print("ZHJ enablePair correct \(result)")
                return
            }
            print("ZHJ enablePair error \(result)")
            completion?()
        }
    }
    
    func autoReconnect() {
        btProvider.autoReconnect(success: { [self] p in
            print("ZHJ Reconnect done \(p)")
            //sendLogsToServer(string: "ZHJ Reconnect done \(p)")
            afterConnectionSyns()
            enablePair()
        }) { (p, err) in
            print("ZHJ Reconnect failed \(p) \(String(describing: err))")
            //endLogsToServer(string: "ZHJ Reconnect failed \(p) \(String(describing: err))")
        }
    }
    
    func connectDevice(_ device: ZHJBTDevice, _ completion: ((Bool)-> Void)? = nil) {
        //sendLogsToServer(string: "ZHJ try connectDevice \(device.name)")
        btProvider.connectDevice(device: device) { [self] p in
            print("ZHJ connectDevice success \(p)")
            //sendLogsToServer(string: "ZHJ connectDevice success \(p)")
            completion?(true)
            enablePair()
            afterConnectionSyns()
        } fail: { (p, error) in
            print("ZHJ connectDevice error \(p) \(String(describing: error))")
            //sendLogsToServer(string: "ZHJ connectDevice error \(p) \(String(describing: error))")
            completion?(false)
        } timeout: {
            print("ZHJ connectDevice timeout")
            //sendLogsToServer(string: "ZHJ connectDevice timeout")
            completion?(false)
        }
    }
    
    func scanDevices(seconds: TimeInterval, _ completion: (([ZHJBTDevice]) -> Void)? = nil) {
        //sendLogsToServer(string: "token \(String(describing: KeychainUtils.getSharedCurrentUserToken()))")
        if let token = KeychainUtils.getSharedCurrentUserToken() {
            currentUserToken = token
        }
        if let deviceName = KeychainUtils.getSharedDeviceName() {
            currentDeviceName = deviceName
        }
        
        if connectedDeviceZHJ != nil {
            readCurrentTemperature {
                self.readHR_BP_BOCurrent()
            }
            return
        }
        
        //sendLogsToServer(string: "### try scanDevices")
        btProvider.scan(seconds: seconds) { [self] devices in
            print("ZHJ scan \(devices)")
            //sendLogsToServer(string: "### ZHJ scan \(devices)")
            if let fDevice = devices.first(where: {$0.name == currentDeviceName }) {
                connectDevice(fDevice)
            }
            completion?(devices)
        }
    }
    
    func bluetoothPrepare(_ completion: ((Bool) -> Void)? = nil) {
        //sendLogsToServer(string: "try bluetoothPrepare")
        btProvider.bluetoothProviderManagerStateDidUpdate { [self] state in
            print("ZHJ bluetoothPrepare \(String(describing: state))")
            //sendLogsToServer(string: "State \(String(describing: state))")
            
            switch state {
            case .poweredOn:
                print("ZHJ poweredOn")
                autoReconnect()
                completion?(true)
                //sendLogsToServer(string: "State ZHJ poweredOn")
            case .poweredOff:
                print("ZHJ poweredOff")
                completion?(false)
                //sendLogsToServer(string: "State ZHJ poweredOff")
            case .unsupported:
                print("ZHJ unsupported")
                completion?(false)
                //sendLogsToServer(string: "State ZHJ unsupported")
            case .resetting:
                print("ZHJ resetting")
                completion?(false)
                //sendLogsToServer(string: "State ZHJ resetting")
            case .unauthorized:
                print("ZHJ unauthorized")
                completion?(false)
                //sendLogsToServer(string: "State ZHJ unauthorized")
            case .unknown:
                print("ZHJ unknown")
                completion?(false)
                //sendLogsToServer(string: "State ZHJ unknown")
            default:
                completion?(false)
                return
                    //sendLogsToServer(string: "State did not handled")
            }
        }
    }
    
    func sendLogsToServer(string: String) {
        ImagesManager.shared.getBy(link: string) { (success, error) in }
    }
}

extension Double {
    func truncate(places: Int) -> Double {
        if self.isNaN || self.isInfinite{ return 0 }
        let divisor = pow(10.0, Double(places))
        return Double(Int(self * divisor)) / divisor
    }
}
