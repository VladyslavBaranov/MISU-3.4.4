//
//  HealthKitAssistant.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 18.08.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import Foundation
import HealthKit
import MapKit

// MARK: - HK Connections Protocol
protocol HealthKitConnectionDelegate {
    func beginHKConnecting()
    func endHKConnecting()
}



// MARK: - Models
class HKTypeIdStruct {
    let unit: HKUnit
    var idString: String { return unit.unitString }
    var samples: [HKSample] = []
    
    init(unit un: HKUnit) {
        unit = un
    }
}

class HKQuantityTypeIdStruct: HKTypeIdStruct {
    let identifier: HKQuantityTypeIdentifier
    override var idString: String { return identifier.rawValue }
    
    var quantitySamples: [HKQuantitySample] = []
    override var samples: [HKSample] {
        didSet {
            quantitySamples = samples.reduce(into: [HKQuantitySample]()) { result, element in
                if let qs = element as? HKQuantitySample {
                    result.append(qs)
                }
            }
        }
    }
    
    /// Linked model for data that need few values: pressure (systolic, diastolic)
    var linkedQuantityType: HKQuantityTypeIdStruct? = nil
    
    /// Special multiplier for values to convert HealthKit data to MISU server side
    /// - Default value is 1
    /// - Oxygen saturation: 0-1 HK -> MISU: 0-100 = multiplier should be 100
    var multiplier: Float
    
    init(identifier id: HKQuantityTypeIdentifier, unit un: HKUnit, multiplier mp: Float = 1) {
        identifier = id
        multiplier = mp
        super.init(unit: un)
    }
}

class HKCategoryTypeIdStruct: HKTypeIdStruct {
    let identifier: HKCategoryTypeIdentifier
    override var idString: String { return identifier.rawValue }
    
    var categorySample: [HKCategorySample] = []
    override var samples: [HKSample] {
        didSet {
            categorySample = samples.reduce(into: [HKCategorySample]()) { result, element in
                if let qs = element as? HKCategorySample {
                    result.append(qs)
                }
            }
        }
    }
    
    init(identifier id: HKCategoryTypeIdentifier, unit un: HKUnit) {
        identifier = id
        super.init(unit: un)
    }
}





// MARK: - HealthKitAssistant
class HealthKitAssistant: WatchManager {
    private let keyUDefIsHK = "HKsa&dja$hAss^ista32nt3W%atch"
    
    override var isConnected: Bool {
        get { return UserDefaultsUtils.getBool(key: keyUDefIsHK) ?? false }
        set { UserDefaultsUtils.save(value: newValue, key: keyUDefIsHK) }
    }
    
    static let shared = HealthKitAssistant()
    var store = HKHealthStore()
    
    var connectDelegate: HealthKitConnectionDelegate?
    
    let quantityTypeIds: [HKQuantityTypeIdentifier: HKQuantityTypeIdStruct] = [
        .bodyTemperature: .init(identifier: .bodyTemperature, unit: .degreeCelsius()),
        .bloodPressureDiastolic: .init(identifier: .bloodPressureDiastolic, unit: .millimeterOfMercury()),
        .bloodPressureSystolic: .init(identifier: .bloodPressureSystolic, unit: .millimeterOfMercury()),
        .heartRate: .init(identifier: .heartRate, unit:  HKUnit.count().unitDivided(by: .minute())),
        .oxygenSaturation: .init(identifier: .oxygenSaturation, unit: .percent(), multiplier: 100),
        .stepCount: .init(identifier: .stepCount, unit: .count())
    ]
    let categoryTypeIds: [HKCategoryTypeIdStruct] = [
        .init(identifier: .sleepAnalysis, unit: HKUnit.count())
    ]
    //HKObjectType.electrocardiogramType()
    
    private override init() {
        super.init()
        
        quantityTypeIds[.bloodPressureSystolic]?.linkedQuantityType = quantityTypeIds[.bloodPressureDiastolic]
        quantityTypeIds[.bloodPressureDiastolic]?.linkedQuantityType = quantityTypeIds[.bloodPressureSystolic]
        
        if isConnected {
            checkAvailability()
        }
    }
}



// MARK: - HK Connections
extension HealthKitAssistant {
    /// Disconnects if was connected. Checks availability and asks permition if was disconnected
    func connectDisconnectActions() {
        connectDelegate?.beginHKConnecting()
        if isConnected {
            isConnected = false
            connectDelegate?.endHKConnecting()
        } else {
            checkAvailability()
        }
    }
    
    /// Checks if HKHealthStore is avalible on this device
    /// - Not avalible on iPad
    private func checkAvailability() {
        if HKHealthStore.isHealthDataAvailable() {
            print("HK HealthData is Available ...")
            store = HKHealthStore()
            requestAccess()
        } else {
            ModalMessagesController.shared.show(message: "Health Kit is unavailable on this device ...", type: .error)
            print("HK HealthData is NOT Available ...")
            connectDelegate?.endHKConnecting()
        }
    }
    
    /// Requests access to heakth data
    /// - bodyTemperature
    /// - bloodPressureDiastolic
    /// - bloodPressureSystolic
    /// - heartRate
    /// - oxygenSaturation
    /// - sleepAnalysis
    private func requestAccess() {
        var healthKitTypesToRead: Set<HKObjectType> = []
        
        quantityTypeIds.forEach { qid, qt in
            guard let hkType = HKObjectType.quantityType(forIdentifier: qid) else {
                print("HK HealthData dataType is NOT Available \(qt.idString) ...")
                connectDelegate?.endHKConnecting()
                return
            }
            healthKitTypesToRead.insert(hkType)
        }
        
        categoryTypeIds.forEach { ct in
            guard let hkType = HKObjectType.categoryType(forIdentifier: ct.identifier) else {
                print("HK HealthData dataType is NOT Available \(ct.idString) ...")
                connectDelegate?.endHKConnecting()
                return
            }
            healthKitTypesToRead.insert(hkType)
        }
        
        store.requestAuthorization(toShare: nil, read: healthKitTypesToRead) { (success, error) in
            self.isConnected = success
            if success {
                self.getAllHKData()
                print("HK requestAuthorization \(success)")
            }
            
            if let er = error {
                print("HK requestAuthorization ERROR: \(er.localizedDescription)")
            }
            self.connectDelegate?.endHKConnecting()
        }
    }
}



// MARK: - Health Data getting
extension HealthKitAssistant {
    override func updateAllData() {
        getAllHKData()
    }
    
    func getAllHKData() {
        quantityTypeIds.values.forEach { qType in
            addUpdatingProcess()
            getQuantityData(forIdentifier: qType) {
                self.removeUpdatingProcess()
            }
        }
        categoryTypeIds.forEach { cType in
            addUpdatingProcess()
            getCategoryData(forIdentifier: cType) {
                self.removeUpdatingProcess()
            }
        }
        
        //retrieveSleepAnalysis()
    }
    
    public func getQuantityData(forIdentifier identifier: HKQuantityTypeIdStruct,
                                predicate: NSPredicate? = HKQuery.predicateForSamples(withStart: Date().previous(count: 7), end: Date(), options: []),
                                _ completion: @escaping FinishCompletion) {
        guard let sampleType = HKSampleType.quantityType(forIdentifier: identifier.identifier) else {
            print("HK \(identifier.idString) ERROR: Unable to get on this device")
            completion()
            return
        }
        
        getQuery(forIdentifier: identifier, sampleType: sampleType, predicate: predicate, completion)
    }
    
    public func getCategoryData(forIdentifier identifier: HKCategoryTypeIdStruct,
                                predicate: NSPredicate? = HKQuery.predicateForSamples(withStart: Date().previous(count: 7), end: Date(), options: []),
                                _ completion: @escaping FinishCompletion) {
        
        guard let sampleType = HKSampleType.categoryType(forIdentifier: identifier.identifier) else {
            print("HK \(identifier.idString) ERROR: Unable to get on this device")
            completion()
            return
        }
        
        getQuery(forIdentifier: identifier, sampleType: sampleType, predicate: predicate, completion)
    }
    
    func getQuery(forIdentifier identifier: HKQuantityTypeIdStruct,
                  sampleType: HKQuantityType,
                  predicate: NSPredicate? = nil,
                  limit: Int = HKObjectQueryNoLimit,
                  sortDescriptors: [NSSortDescriptor]? = nil,
                  _ completion: @escaping FinishCompletion) {
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { sampleQuery, hkSamples, error in
            print(">>>>>>>>>>>>>>>>>>>>>>> HK \(identifier.idString) <<<<<<<<<<<<<<<<<<<<<<<")
            
            if let hks = hkSamples {
                identifier.samples = hks
                HealthDataController.shared.saveHealthParamsServer(healthParams: ListHParameterModel(dataStruct: identifier)) 
            }
            
            if let er = error {
                print("HK \(identifier.idString) getQuery ERROR: \(er.localizedDescription)")
            }
            
            completion()
        }
        
        store.execute(query)
    }
    
    func getQuery(forIdentifier identifier: HKCategoryTypeIdStruct,
                  sampleType: HKCategoryType,
                  predicate: NSPredicate? = nil,
                  limit: Int = HKObjectQueryNoLimit,
                  sortDescriptors: [NSSortDescriptor]? = nil,
                  _ completion: @escaping FinishCompletion) {
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { sampleQuery, hkSamples, error in
            print(">>>>>>>>>>>>>>>>>>>>>>> HK \(identifier.idString) <<<<<<<<<<<<<<<<<<<<<<<")
            /*print("HK \(identifier.idString) SQ: \(sampleQuery)")
            print("HK \(identifier.idString) hkS: \(hkSamples?.count ?? -1) \(hkSamples?.first as Any) \(hkSamples?[safe: 1] as Any) \(hkSamples?.last as Any)")
            print("HK \(identifier.idString) ERROR: \(error?.localizedDescription ?? "nil")")
            if let frst = hkSamples?.last as? HKCategorySample {
                print("HK \(identifier.idString) \(frst)")
                print("HK \(identifier.idString) \(frst.sampleType)")
                print("HK \(identifier.idString) \(frst.startDate)")
                print("HK \(identifier.idString) \(frst.endDate)")
                print("HK \(identifier.idString) \(frst.device as Any)")
                print("HK \(identifier.idString) \(frst.value)")
            }*/
            
            if let hks = hkSamples {
                identifier.samples = hks
                identifier.convertAndSave()
            }
            
            if let er = error {
                print("HK \(identifier.idString) getQuery ERROR: \(er.localizedDescription)")
            }
            
            completion()
        }
        
        store.execute(query)
    }
}



// MARK: - Extensions



// MARK: - typealiases and ERRORs
extension HealthKitAssistant {
    
    // FIX: Add HKError enum and handle all errors in it
    typealias FinishCompletion = () -> Void
}



// MARK: - Convert HKCategoryType to specific Type
extension HKCategoryTypeIdStruct {
    /// Runs methods for converting, seves to server and in to HealthKitAssistant
    /// - converts samples of HKCategoryTypeIdStruct to specific Type
    /// - saves to server by using HealthDataController
    func convertAndSave() {
        switch identifier {
        case .sleepAnalysis:
            print("HK \(idString) convertAndSave")
            let sleepDict = convertSleep()
            HealthKitAssistant.shared.sleepHistory.merge(with: sleepDict)
            HealthDataController.shared.saveToServer(sleepList: Array(sleepDict.values))
        default:
            print("HК HKCategoryTypeIdStruct convertAndSave ERROR: switch case is not provided for \(identifier)")
        }
    }
    
    func convertSleep() -> HistoricalSleep {
        print("HK \(idString) convertSleep")
        var historicalSleep: HistoricalSleep = [:]
        
        categorySample.sort { first, second in
            if first.startDate.compare(second.startDate) == .orderedAscending {
                return true
            }
            return false
        }
        
        /*categorySample.forEach { smpl in
            print("^^^ $$$ A \(smpl.startDate) \(smpl.endDate) \(HKCategoryValueSleepAnalysis(rawValue: smpl.value)?.descriptor ?? "nil") \(smpl.value)")
        }*/
        var categorySmplID: [Int: [HKCategorySample]] = [:]
        var lastId: Int = 0
        var index = 0
        categorySample.forEach { value in
            guard let next = categorySample[safe: index+1] else {
                index += 1
                return
            }
            
            // print("^^^", value.startDate.getDateForRequest())
            // print("^^^", value.endDate, next.startDate)
            // print("^^^^^^", value.endDate.percentageProximityToDate(next.startDate))
            
            if categorySmplID[lastId] == nil {
                categorySmplID.updateValue([value], forKey: lastId)
            }
            
            if value.endDate.compare(next.startDate) == .orderedDescending ||
               value.endDate.percentageProximityToDate(next.startDate) < 0.05 {
                // print("^^^ ###..", value.endDate.getDateForRequest())
                // print("^^^ ###--", next.startDate.getDateForRequest())
                categorySmplID[lastId]?.append(next)
            } else {
                lastId += 1
                categorySmplID.updateValue([next], forKey: lastId)
            }
            
            index += 1
        }
        
        
        // FIX !!! Few sleeps in one day
        categorySmplID.forEach { key, values in
            /*print("^^^", key, values.first?.startDate.getDateForRequest() ?? "nil")
            for v in values {
                print("^^^^^^^^^", v.startDate, v.endDate)
            }*/
            guard let dateKey = values.first?.startDate.getDateForRequest() else { return }
            
            values.forEach { value in
                if historicalSleep[dateKey] == nil {
                    //print("HK \(idString) init")
                    historicalSleep[dateKey] = .init(date: value.startDate, uId: -1)
                }
                historicalSleep[dateKey]?.details.append(SleepPhaseModel(from: value))
            }
        }
        
        return historicalSleep
    }
}


extension SleepPhaseModel {
    convenience init(from phase: HKCategorySample) {
        self.init()
        dateTime = phase.startDate.getTimeDateForRequest()
        duration = Calendar.current.dateComponents([.minute], from: phase.startDate, to: phase.endDate).minute
        pType = .init(from: HKCategoryValueSleepAnalysis(rawValue: phase.value) ?? .inBed)
        print("HК Sleep phase \(pType?.title ?? "nil") = \(HKCategoryValueSleepAnalysis(rawValue: phase.value)?.descriptor ?? "nil") \(duration ?? -1) \(dateTime ?? "nil") |: \(phase.startDate.getTimeDateForRequest()) \(phase.endDate.getTimeDateForRequest())")
    }
}



// MARK: - Convert params to [HealthParameterModel] extension for ListHParameterModel
extension ListHParameterModel {
    /// Initializer  for HKQuantityTypeIdStruct, also convert params to [HealthParameterModel] and saves to varibles pulse, bloodOxygen, bloodPressure, temperature
    init(dataStruct: HKQuantityTypeIdStruct) {
        switch dataStruct.identifier {
        case .heartRate:
            pulse = convertParams(dataStruct)
        case .bloodPressureSystolic:
            guard let pDias = dataStruct.linkedQuantityType else {
                print("HK HD ERROR: pressureSystolic doe's not have linked type pressureDiastolic ...")
                return
            }
            bloodPressure = convertParams(pressureSystolic: dataStruct, pressureDiastolic: pDias)
        case .bloodPressureDiastolic:
            guard let pSys = dataStruct.linkedQuantityType else {
                print("HK HD ERROR: pressureDiastolic doe's not have linked type pressureSystolic ...")
                return
            }
            bloodPressure = convertParams(pressureSystolic: pSys, pressureDiastolic: dataStruct)
        case .oxygenSaturation:
            bloodOxygen = convertParams(dataStruct)
        case .bodyTemperature:
            temperature = convertParams(dataStruct)
        default:
            return
        }
    }
    
    /// Converts [HKQuantitySample] from HKQuantityTypeIdStruct to [HealthParameterModel]
    /// - Returns: list of parameters - [HealthParameterModel]
    /// - if gets  bloodPressureDiastolic or bloodPressureSystolic than returns empty list and prints ERROR in console
    func convertParams(_ qHealthParams: HKQuantityTypeIdStruct) -> [HealthParameterModel] {
        if qHealthParams.identifier == .bloodPressureDiastolic || qHealthParams.identifier == .bloodPressureSystolic {
            print("HK HD ERROR: Wrong pressure converting! Use special method for pressure -> convertParams(pressureSystolic: HKQuantityTypeIdStruct, pressureDiastolic: HKQuantityTypeIdStruct) ...")
            return []
        }
        
        return qHealthParams.quantitySamples.map { sample in
            print("HK \(qHealthParams.idString) \(sample.sampleType)")
            print("HK \(qHealthParams.idString) \(sample.startDate)")
            print("HK \(qHealthParams.idString) \(sample.endDate)")
            
            let value = Float(sample.quantity.doubleValue(for: qHealthParams.unit)) * qHealthParams.multiplier
            
            print("HK \(qHealthParams.idString) \(value)")
            
            return .init(value: value,
                         additionalValue: nil,
                         date: sample.endDate)
        }
    }
    
    /// Converts pressure Systolic [HKQuantitySample] and Diastolic [HKQuantitySample] from HKQuantityTypeIdStruct to [HealthParameterModel]
    /// - Returns: list of parameters - [HealthParameterModel]
    /// - Special converter for pressure
    func convertParams(pressureSystolic: HKQuantityTypeIdStruct, pressureDiastolic: HKQuantityTypeIdStruct) -> [HealthParameterModel] {
        return pressureSystolic.quantitySamples.reduce(into: [HealthParameterModel]()) { result, pSysElement in
            guard let pDiasElement = pressureDiastolic.quantitySamples.first(
                where: {$0.endDate == pSysElement.endDate}) else { return }
            print("HK \(pressureSystolic.idString) \(pSysElement.startDate) \(pDiasElement.startDate)")
            print("HK \(pressureSystolic.idString) \(pSysElement.endDate) \(pDiasElement.endDate)")
            print("HK \(pressureSystolic.idString) \(pSysElement.quantity.doubleValue(for: pressureSystolic.unit)) \(pDiasElement.quantity.doubleValue(for: pressureDiastolic.unit))")
            
            let sValue = Float(pSysElement.quantity.doubleValue(for: pressureSystolic.unit))
            let dValue = Float(pDiasElement.quantity.doubleValue(for: pressureDiastolic.unit))
            
            print("HK \(pressureSystolic.idString) \(sValue) \(dValue)")
            
            result.append(.init(value: sValue,
                                additionalValue: dValue,
                                date: pSysElement.endDate))
        }
    }
}



// MARK: - Ext SleepPhaseType
extension SleepPhaseType {
    init(from: HKCategoryValueSleepAnalysis) {
        switch from {
        case .asleep:
            self = .light
        case .awake:
            self = .begin
        case .inBed:
            self = .light
        @unknown default:
            self = .light
        }
    }
}



// MARK: - HKCategoryValueSleepAnalysis Extension
extension HKCategoryValueSleepAnalysis {
    var descriptor: String {
        switch self {
        case .inBed:
            return "inBed"
        case .asleep:
            return  "asleep"
        case .awake:
            return  "awake"
        @unknown default:
            return  "unknown"
        }
    }
}
