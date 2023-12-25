//
//  WatchSinglManager.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 01.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation
import TrusangBluetooth
import CoreBluetooth


class WatchSinglManager: WatchManager {
    private let keyUDefIsWatch = "i8&#*YDMISUsad31WATCH7dG#*D&*#dg"
    override var isConnected: Bool {
        get { return UserDefaultsUtils.getBool(key: keyUDefIsWatch) ?? false }
        set { UserDefaultsUtils.save(value: newValue, key: keyUDefIsWatch) }
    }
    
    static let shared = WatchSinglManager()
    private override init() {
        super.init()
        if !UCardSingleManager.shared.isUserToken() {
            removeAutoReconnect()
            isConnected = false
            disconnectDevice()
        }
        bluetoothPrepare()
    }
    
    let btProvider = ZHJBLEManagerProvider.shared
    let enablePairProcessor = ZHJEnablePairProcessor()
    let batteryProcessor = ZHJBatteryProcessor()
    let syncTimeProcessor = ZHJSyncTimeProcessor()
    let HR_BP_BOProcessor = ZHJHR_BP_BOProcessor()
    let temperatureProcessor = ZHJTemperatureProcessor()
    let stepAndSleepProcessor = ZHJStepAndSleepProcessor()
    let deviceConfigProcessor = ZHJDeviceConfigProcessor()
    var deviceConfig = ZHJDeviceConfig()
    //let messageNoticeProcessor = ZHJMessageNoticeProcessor()
    
    let wFSequencer = WatchFuncSequencer.shared
    var listDelegate: WatchListDelegate? = nil
    var readParamsDelegate: WatchReadParamsDelegate? = nil
    var trusangDeviceDelegate: TrusangDeviceDelegate? = nil
    var connectedDeviceCB: CBPeripheral? = nil
    var connectedDeviceZHJ: ZHJBTDevice? {
        get { btProvider.currentDevice }
    }
    
    var devicePow: Int? {
        didSet {
            trusangDeviceDelegate?.batteryPowerUpdated(devicePow ?? 0)
        }
    }
    
    var indicatorsDateRange: [Date] {
        var dt: [Date] = [Date()]
        (0..<7).forEach { _ in
            guard let pdt = dt.last?.previous() else { return }
            dt.append(pdt)
        }
        return dt
    }
}



// MARK: - ZHJ SDK Data Synchronization
extension WatchSinglManager {
    func afterConnectionSyns(_ completion: (() -> Void)? = nil) {
        print("ZHJ start sync ...")
        discoverWriteCharacteristic(completion)
    }
    
    override func updateAllData() {
        if isUpdating { return }
        updateSyns()
    }
    
    func updateSyns() {
        print("ZHJ start update sync ...")
        wFSequencer.add(.startSyns)
        wFSequencer.add(.syncTime)
        wFSequencer.add(.readBatteryPower)
        indicatorsDateRange.forEach { dt in
            wFSequencer.add(.readHR_BP_BOHistoryRecord(date: dt))
            wFSequencer.add(.readTemperatureHistoryRecord(date: dt))
            wFSequencer.add(.readStepAndSleepHistoryRecord(date: dt))
        }
        wFSequencer.add(.setAutoDetectTemperature)
        wFSequencer.add(.setAutoDetectHeartRate)
        wFSequencer.add(.readDeviceConfig)
        wFSequencer.add(.messageSwitch)
        wFSequencer.add(.endSyns)
    }
    
    func discoverWriteCharacteristic(_ completion: (() -> Void)? = nil) {
        btProvider.discoverWriteCharacteristic { [self] characteristic in
            print("ZHJ discoverWriteCharacteristic \(characteristic)")
            updateSyns()
            completion?()
        }
    }
    
    func syncTime(_ completion: (() -> Void)? = nil) {
        //print("ZHJ try syncTime \(String(describing: btProvider.currentDevice))")
        syncTimeProcessor.writeTime(ZHJSyncTime.init(Date())) { [self] result in
            if result == .correct {
                print("ZHJ syncTime correct \(String(describing: result))")
            } else {
                print("ZHJ syncTime error \(String(describing: result))")
            }
            readParamsDelegate?.syncDidUpdate?()
            completion?()
        }
    }
    
    func readBatteryPower(_ completion: SequencerCompletion? = nil) {
        print("ZHJ try readBatteryPower")
        batteryProcessor.readBatteryPower { [self] pow in
            print("ZHJ readBatteryPower \(pow)")
            devicePow = pow
            readParamsDelegate?.batteryPowerUpdated?(pow)
            readParamsDelegate?.syncDidUpdate?()
            trusangDeviceDelegate?.batteryPowerUpdated(pow)
            completion?()
        }
    }
    
    func setAutoDetectTemperature(_ completion: (() -> Void)? = nil) {
        temperatureProcessor.setAutoDetectTemperature(interval: 15, isOn: true) { [self] result in
            if result == .correct {
                print("ZHJ setAutoDetectTemperature correct \(String(describing: result))")
            } else {
                print("ZHJ setAutoDetectTemperature error \(String(describing: result))")
            }
            readParamsDelegate?.syncDidUpdate?()
            completion?()
        }
    }
    
    func setAutoDetectHeartRate(_ completion: (() -> Void)? = nil) {
        HR_BP_BOProcessor.setAutoDetectHeartRate(interval: 15, isOn: true) { [self] result in
            if result == .correct {
                print("ZHJ setAutoDetectHeartRate correct \(String(describing: result))")
            } else {
                print("ZHJ setAutoDetectHeartRate error \(String(describing: result))")
            }
            readParamsDelegate?.syncDidUpdate?()
            completion?()
        }
    }
    
    func readStepAndSleepHistoryRecord(date: Date?, _ completion: SequencerCompletion? = nil) {
        let date = date ?? Date()
        stepAndSleepProcessor.readStepAndSleepHistoryRecord(date: date.getDateForRequest()) { stepsModel, sleepModel in
            print("ZHJ readStepAndSleepHistoryRecord step \(stepsModel) \(sleepModel)")
            let sm = SleepModel(from: sleepModel, dateStr: date.getDateForRequest())
            self.sleepHistory.updateValue(sm, forKey: date.getDateForRequest())
            HealthDataController.shared.saveToServer(sleepModel: sm)
            self.readParamsDelegate?.syncDidUpdate?()
            completion?()
        } historyDoneHandle: { obj in
            print("ZHJ readStepAndSleepHistoryRecord done \(obj)")
            completion?()
        }
    }
    
    func readHR_BP_BOCurrent(_ completion: (() -> Void)? = nil) {
        HR_BP_BOProcessor.readCurrentHR_BP_BO { [self] (heartRateD, bloodPressureD, bloodOxygenD) in
            print("ZHJ readHR_BP_BOCurrent \n\(heartRateD)\n\(bloodPressureD)\n\(bloodOxygenD)")
            let heartRate = ZHJHeartRate()
            let bloodPressure = ZHJBloodPressure()
            let bloodOxygen = ZHJBloodOxygen()
            heartRateD.dateTime = Date().getTimeDateForRequest()
            bloodOxygenD.dateTime = Date().getTimeDateForRequest()
            bloodPressureD.dateTime = Date().getTimeDateForRequest()
            //print("### ! \(heartRateD.dateTime)")
            bloodPressure.details.append(bloodPressureD)
            heartRate.details.append(heartRateD)
            bloodOxygen.details.append(bloodOxygenD)
            
            HealthDataController.shared.saveHealthParamsServer(
                healthParams: .init(heartRate: heartRate, bloodOxygen: bloodOxygen, bloodPressure: bloodPressure))
            
            readParamsDelegate?.syncDidUpdate?()
            completion?()
        }
    }
    
    func readCurrentBP(_ completion: ((_ bp: HealthParameterModel) -> Void)? = nil) {
        HR_BP_BOProcessor.readCurrentHR_BP_BO { _, bloodPressureD, _ in
            print("ZHJ read BP Current \(bloodPressureD)")
            bloodPressureD.dateTime = Date().getTimeDateForRequest()
            HealthDataController.shared.saveHealthParamsServer(
                healthParams: .init(bloodPressure: bloodPressureD))
            completion?(HealthParameterModel(id: -1, value: Float(bloodPressureD.SBP), additionalValue: Float(bloodPressureD.DBP), date: bloodPressureD.dateTime))
        }
    }
    
    func readCurrentTemperature(_ completion: (() -> Void)? = nil) {
        temperatureProcessor.readCurrentTemperature { [self] (temperatureD) in
            print("ZHJ readCurrentTemperature \n\(temperatureD)")
            let temperature = ZHJTemperature()
            temperatureD.dateTime = Date().getTimeDateForRequest()
            temperature.details.append(temperatureD)
            HealthDataController.shared.saveHealthParamsServer(healthParams: .init(temperature: temperature))

            readParamsDelegate?.syncDidUpdate?()
            completion?()
        }
    }
    
    func readHR_BP_BOHistoryRecord(date: Date? = nil, _ completion: (() -> Void)? = nil) {
        HR_BP_BOProcessor.readHR_BP_BOHistoryRecord((date ?? Date()).getDateForRequest()) { [self] (heartRate, bloodPressure, bloodOxygen) in
            //print("ZHJ readHR_BP_BOHistoryRecord \n\(heartRate)\n\(bloodPressure)\n\(bloodOxygen)")
            print("ZHJ readHR_BP_BOHistoryRecord \(date?.getTimeDateForRequest() ?? "nil") \(heartRate.details.count) \(bloodPressure.details.count) \(bloodOxygen.details.count)")
            //print("ZHJ readHRHistoryRecord \n\(heartRate.min)\n\(heartRate.avg)\n\(heartRate.max)")
            //print("### !!! \(bloodOxygen.details.first?.dateTime)")
            DispatchQueue.background {
                HealthDataController.shared.saveHealthParamsServer(
                    healthParams: .init(heartRate: heartRate, bloodOxygen: bloodOxygen, bloodPressure: bloodPressure))
            } completion: {
                
            }
            readParamsDelegate?.syncDidUpdate?()
            completion?()
        } historyDoneHandle: { obj in
            print("ZHJ readHR_BP_BOHistoryRecord done \(obj)")
            completion?()
        }
    }
    
    func readTemperatureHistoryRecord(date: Date? = nil, _ completion: SequencerCompletion? = nil) {
        temperatureProcessor.readTemperatureHistoryRecord((date ?? Date()).getDateForRequest()) { [self] temperature in
            print("ZHJ readTemperatureHistoryRecord \(date?.getTimeDateForRequest() ?? "nil") \n\(temperature)")
            //print("ZHJ readTemperatureHistoryRecord \n\(temperature.details.count) \n\(temperature.details)")
            DispatchQueue.background {
                HealthDataController.shared.saveHealthParamsServer(healthParams: .init(temperature: temperature))
            } completion: {
                
            }
            readParamsDelegate?.syncDidUpdate?()
            completion?()
        } historyDoneHandle: { obj in
            print("ZHJ readTemperatureHistoryRecord done \(obj)")
            completion?()
        }
    }
    
    func startSyns(_ completion: (() -> Void)? = nil) {
        print("ZHJ start sync ...")
        addUpdatingProcess()
        readParamsDelegate?.syncDidStart()
        completion?()
    }
    
    func endSyns(_ completion: (() -> Void)? = nil) {
        enablePair()
        print("ZHJ end sync ...")
        readParamsDelegate?.syncDidEnd()
        completion?()
        removeUpdatingProcess()
    }
    
    func readDeviceConfig(_ completion: SequencerCompletion? = nil) {
        deviceConfigProcessor.readDeviceConfig { config in
            //print("### readDeviceConfig \(config) \(config.notice) ...")
            self.deviceConfig = config
            completion?()
        }
    }
    
    func messageSwitch(_ completion: SequencerCompletion? = nil) {
        if deviceConfig.notice {
            completion?()
            return
        }
        let config = deviceConfig
        config.notice = true
        deviceConfigProcessor.writeDeviceConfig(config, setHandle: { result in
            print("### writeDeviceConfig \(config.notice) \(result == .correct)")
            self.deviceConfig.notice = config.notice
            completion?()
        })
    }
}



// MARK: - ZHJ SDK Connections
extension WatchSinglManager {
    func enablePair(_ completion: (() -> Void)? = nil) {
        enablePairProcessor.enablePair { result in
            if result == .correct {
                print("ZHJ enablePair correct \(result)")
                completion?()
                return
            }
            print("ZHJ enablePair error \(result)")
            completion?()
        }
    }
    
    func autoReconnect() {
        readParamsDelegate?.didStartConnecting?()
        btProvider.autoReconnect(success: { [self] p in
            print("ZHJ Reconnect done \(p)")
            connectedDeviceCB = p
            isConnected = true
            trusangDeviceDelegate?.deviceConnected(device: connectedDeviceZHJ, success: true)
            readParamsDelegate?.didConnected(connectedDeviceZHJ, success: true)
            afterConnectionSyns()
        }) { [self] (p, err) in
            print("ZHJ Reconnect failed \(p) \(String(describing: err))")
            readParamsDelegate?.didConnected(nil, success: false)
            trusangDeviceDelegate?.deviceConnected(device: nil, success: false)
        }
    }
    
    func disconnectDeviceFully() {
        wFSequencer.breakAll()
        isConnected = false
        connectedDeviceCB = nil
        wFSequencer.add(.removeAutoReconnect)
        wFSequencer.add(.disconnectDevice)
    }
    
    func removeAutoReconnect(_ completion: (() -> Void)? = nil) {
        btProvider.removeAutoReconnectDevice()
        print("ZHJ removeAutoReconnectDevice")
        completion?()
    }
    
    func disconnectDevice(_ completion: (() -> Void)? = nil) {
        btProvider.disconnectDevice { p in
            print("ZHJ disconnectDevice \(p)")
            completion?()
            self.listDelegate?.deviceDisconnected()
            self.readParamsDelegate?.deviceDisconnected()
            self.trusangDeviceDelegate?.deviceDisconnected()
        }
    }
    
    func connectDevice(_ device: ZHJBTDevice, _ completion: ((Bool)-> Void)? = nil) {
        wFSequencer.breakAll()
        readParamsDelegate?.didStartConnecting?()
        btProvider.connectDevice(device: device) { [self] p in
            print("ZHJ connectDevice success \(p)")
            isConnected = true
            connectedDeviceCB = device.peripheral
            completion?(true)
            readParamsDelegate?.didConnected(connectedDeviceZHJ, success: true)
            listDelegate?.deviceConnected(device: device, success: true)
            trusangDeviceDelegate?.deviceConnected(device: device, success: true)
            //enablePair()
            afterConnectionSyns()
        } fail: { [self] (p, error) in
            print("ZHJ connectDevice error \(p) \(String(describing: error))")
            completion?(false)
            listDelegate?.deviceConnected(device: device, success: false)
            trusangDeviceDelegate?.deviceConnected(device: device, success: false)
            readParamsDelegate?.didConnected(nil, success: false)
        } timeout: { [self] in
            print("ZHJ connectDevice timeout")
            completion?(false)
            listDelegate?.deviceConnected(device: device, success: false)
            readParamsDelegate?.didConnected(nil, success: false)
            trusangDeviceDelegate?.deviceConnected(device: nil, success: false)
        }
    }
    
    func scanDevices(seconds: TimeInterval, _ completion: (([ZHJBTDevice]) -> Void)? = nil) {
        btProvider.scan(seconds: seconds) { devices in
            print("ZHJ scan \(devices)")
            completion?(devices)
        }
    }
    
    func bluetoothPrepare(_ completion: ((Bool) -> Void)? = nil) {
        btProvider.bluetoothProviderManagerStateDidUpdate { [self] state in
            print("ZHJ bluetoothPrepare \(String(describing: state))")
            switch state {
            case .poweredOn:
                print("ZHJ poweredOn")
                if UCardSingleManager.shared.user.doctor != nil { return }
                autoReconnect()
                completion?(true)
            case .poweredOff:
                print("ZHJ poweredOff")
                completion?(false)
            case .unsupported:
                print("ZHJ unsupported")
                completion?(false)
            case .resetting:
                print("ZHJ resetting")
                completion?(false)
            case .unauthorized:
                print("ZHJ unauthorized")
                completion?(false)
            case .unknown:
                print("ZHJ unknown")
                completion?(false)
            default:
                completion?(false)
                return
            }
        }
    }
}



extension Double {
    func truncate(places: Int) -> Double {
        if self.isNaN || self.isInfinite{ return 0 }
        let divisor = pow(10.0, Double(places))
        return Double(Int(self * divisor)) / divisor
    }
    
    func getStrValue(places: Int = 1) -> String? {
        return String(self.truncate(places: 1))
    }
}



// MARK: - Extensions
extension SleepPhaseType {
    init(from: ZHJSleepType) {
        switch from {
        case .REM:
            self = .REM
        case .awake:
            self = .REM
        case .begin:
            self = .begin
        case .deep:
            self = .deep
        case .light:
            self = .light
        @unknown default:
            self = .REM
        }
    }
}



extension SleepPhaseModel {
    convenience init(from phase: ZHJSleepDetail) {
        self.init()
        dateTime = phase.dateTime
        duration = phase.duration
        pType = .init(from: ZHJSleepType(rawValue: phase.type) ?? .REM)
    }
}

extension SleepModel {
    convenience init(from sleep: ZHJSleep, dateStr: String?) {
        self.init()
        details = sleep.details.map({ dt in
            return SleepPhaseModel(from: dt)
        })
        
        beginDuration = sleep.beginDuration == 0 ? beginCalcDuration : sleep.beginDuration
        REMDuration = sleep.REMDuration == 0 ? REMCalcDuration : sleep.REMDuration
        lightDuration = sleep.lightDuration == 0 ? lightCalcDuration : sleep.lightDuration
        deepDuration = sleep.deepDuration == 0 ? deepCalcDuration : sleep.deepDuration
        awakeDuration = sleep.awakeDuration == 0 ? awakeCalcDuration : sleep.awakeDuration
        
        dateTime = dateStr
    }
}



// MARK: - Convert params to [HealthParameterModel] extension for ListHParameterModel
extension ListHParameterModel {
    /// Initializer for TrusangBluetooth ZHJ params, also convert params to [HealthParameterModel] and saves to varibles pulse, bloodOxygen, bloodPressure, temperature
    init(heartRate hr_: ZHJHeartRate? = nil,
         bloodOxygen bo_: ZHJBloodOxygen? = nil,
         bloodPressure bp_: ZHJBloodPressure? = nil,
         temperature tm_: ZHJTemperature? = nil) {
        if let hr = hr_ {
            pulse = convertParams(heartRate: hr)
        }
        if let bo = bo_ {
            bloodOxygen = convertParams(bloodOxygen: bo)
        }
        if let bp = bp_ {
            bloodPressure = convertParams(bloodPressure: bp)
        }
        if let tm = tm_ {
            temperature = convertParams(temperature: tm)
        }
    }
    
    /// Initializer for TrusangBluetooth ZHJ Detail param, also convert param to [HealthParameterModel] and saves to varibles pulse, bloodOxygen, bloodPressure, temperature
    init(heartRate hr_: ZHJHeartRateDetail? = nil,
         bloodOxygen bo_: ZHJBloodOxygenDetail? = nil,
         bloodPressure bp_: ZHJBloodPressureDetail? = nil,
         temperature tm_: ZHJTemperatureDetail? = nil) {
        if let hr = hr_ {
            let hrList = ZHJHeartRate()
            hrList.details.append(hr)
            pulse = convertParams(heartRate: hrList)//hr)
        }
        if let bo = bo_ {
            let boList = ZHJBloodOxygen()
            boList.details.append(bo)
            bloodOxygen = convertParams(bloodOxygen: boList)
        }
        if let bp = bp_ {
            let bpList = ZHJBloodPressure()
            bpList.details.append(bp)
            bloodPressure = convertParams(bloodPressure: bpList)
        }
        if let tm = tm_ {
            let tmList = ZHJTemperature()
            tmList.details.append(tm)
            temperature = convertParams(temperature: tmList)
        }
    }
    
    func checkIndicByTime(date: Date?) -> Bool {
        guard let date = date,
              (date.compare(Date()) == .orderedAscending || date.compare(Date()) == .orderedSame) else { return false }
        return true
    }
    
    /// Converts ZHJHeartRate  to [HealthParameterModel]
    /// - Returns: list of parameters - [HealthParameterModel]
    func convertParams(heartRate: ZHJHeartRate) -> [HealthParameterModel] {
        var hpm: [HealthParameterModel] = []
        //print("### conv \(heartRate.details.count) \(heartRate.details)")
        heartRate.details.enumerated().forEach { key, zhjParam in
            //print("### conv heartRate \(key) \(zhjParam.dateTime) \(zhjParam.HR)")
            guard checkIndicByTime(date: zhjParam.dateTime.toDate()) else { return }
            //print("### conv heartRate pass \(date.minutesDiff(with: Date())) \(key) \(zhjParam.dateTime) \(zhjParam.HR)")
            hpm.append(HealthParameterModel(value: Float(zhjParam.HR), date: zhjParam.dateTime))
        }
        return hpm
    }
    
    /// Converts ZHJBloodOxygen  to [HealthParameterModel]
    /// - Returns: list of parameters - [HealthParameterModel]
    func convertParams(bloodOxygen: ZHJBloodOxygen) -> [HealthParameterModel] {
        var hpm: [HealthParameterModel] = []
        bloodOxygen.details.forEach { zhjParam in
            guard checkIndicByTime(date: zhjParam.dateTime.toDate()) else { return }
            hpm.append(HealthParameterModel(value: Float(zhjParam.BO), date: zhjParam.dateTime))
        }
        return hpm
    }
    
    /// Converts ZHJBloodPressure  to [HealthParameterModel]
    /// - Returns: list of parameters - [HealthParameterModel]
    func convertParams(bloodPressure: ZHJBloodPressure) -> [HealthParameterModel] {
        var hpm: [HealthParameterModel] = []
        bloodPressure.details.forEach { zhjParam in
            guard checkIndicByTime(date: zhjParam.dateTime.toDate()) else { return }
            hpm.append(HealthParameterModel(value: Float(zhjParam.SBP), additionalValue: Float(zhjParam.DBP), date: zhjParam.dateTime))
        }
        return hpm
    }
    
    /// Converts ZHJTemperature  to [HealthParameterModel]
    /// - Returns: list of parameters - [HealthParameterModel]
    func convertParams(temperature: ZHJTemperature) -> [HealthParameterModel] {
        var hpm: [HealthParameterModel] = []
        temperature.details.forEach { zhjParam in
            let corTemp = zhjParam.wristTemperature > 0 ? (Double(zhjParam.wristTemperature)/100.0).truncate(places: 1) :  (Double(zhjParam.headTemperature)/100.0).truncate(places: 1)
            guard checkIndicByTime(date: zhjParam.dateTime.toDate()) else { return }
            hpm.append(HealthParameterModel(value: Float(corTemp), date: zhjParam.dateTime))
        }
        return hpm
    }
}
