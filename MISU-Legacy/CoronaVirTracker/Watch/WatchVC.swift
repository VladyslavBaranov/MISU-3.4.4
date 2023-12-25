//
//  WatchVC.swift
//  CoronaVirTracker
//
//  Created by WH ak on 07.10.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit
import TrusangBluetooth

class WatchVC: UIViewController {
    let activityProgView: UIView = .createCustom(bgColor: .clear)
    let watchTableView: UITableView = .createTableView()
    
    let watchManager = WatchSinglManager.shared
    let watchesManager = WatchesController.shared
    let healthDataManager = HealthDataController.shared
    
    var deviceZHJ: ZHJBTDevice? = nil
    var batteryPower: Int = 0
    
    var syncInProgress: Bool = false
}



// MARK: - View loads Overrides
extension WatchVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetUp()
        setUpNavigationView()
        
        //chackIfWatchWasConnected()
        setUpSubViews()
        watchManager.readParamsDelegate = self
        healthDataManager.indicatorsDeledate = self
        // HK
        //print(HealthKitAssistant.shared)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        chackIfWatchWasConnected()
        updateParams()
        _ = WatchFakeVPNManager.shared
        
        healthDataManager.updateAllData()
    }
    
    func chackIfWatchWasConnected() {
        if KeychainUtils.getCurrentUserToken() == applePatToken { return }
        if !watchesManager.wasConnectedAny {
            let vc = PreWatchVC()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}



// MARK: - Actions
extension WatchVC {
    func updateParams() {
        deviceZHJ = watchManager.connectedDeviceZHJ
        watchManager.wFSequencer.add(.readBatteryPower)
        
        //watchTableView.reloadData()
    }
}



// MARK: - Scroll view overloads
extension WatchVC: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let yDownToRefresh: CGFloat = -80
        if scrollView.contentOffset.y < yDownToRefresh {
            WatchesController.shared.updateAllData()
            let cell = watchTableView.cellForRow(
                at: IndexPath(row: WatchViewStruct.HeaderStruct.general.rawValue,
                              section: WatchViewStruct.header.rawValue)
            ) as? WatchHeaderHIMMTVCell
            cell?.startUpdateAllDevices()
            healthDataManager.updateAllData()
        }
    }
}



// MARK: - Watch Delegate
extension WatchVC: WatchReadParamsDelegate, RequestUIController, IndicatorsDataDeledate {
    func uniqeKeyForStore() -> String? {
        return view.getAddress()
    }
    
    func indicatorUpdated(type tp: HealthParamsEnum, range: HealthParamsEnum.StaticticRange, data: [HealthParameterModel]) {
        DispatchQueue.main.async {
            self.watchTableView.reloadSections([WatchViewStruct.charts.rawValue], with: .none)
        }
    }
    
    func indicatorUpdatedWith(error: String, type tp: HealthParamsEnum, range: HealthParamsEnum.StaticticRange) {
        
    }
    
    func deviceDisconnected() {
        deviceZHJ = nil
        watchTableView.reloadSections([WatchViewStruct.header.rawValue], with: .none)
        chackIfWatchWasConnected()
    }
    
    func parametersDidUpdate() {
        // FIX: don`t use table view reload here
    }
    
    func didConnected(_ device: ZHJBTDevice?, success: Bool) {
        if success {
            deviceZHJ = device
            watchTableView.reloadSections([WatchViewStruct.header.rawValue], with: .none)
        }
    }
    
    func batteryPowerUpdated(_ pow: Int) {
        batteryPower = pow
        watchTableView.reloadSections([WatchViewStruct.header.rawValue], with: .none)
    }
    
    func syncDidStart() {
        //syncInProgress = true
        //activityProgView.animateConstraint(activityProgView.customHeightAnchorConstraint, constant: view.standartInset*2, duration: 0.3)
        //prepareViewsBeforReqest(activityView: activityProgView)
        //watchTableView.reloadData()
        watchTableView.reloadSections([WatchViewStruct.header.rawValue], with: .none)
    }
    
    func syncDidEnd() {
        //syncInProgress = false
        //activityProgView.animateConstraint(activityProgView.customHeightAnchorConstraint, constant: 0, duration: 0.3)
        //enableViewsAfterReqest()
        //watchTableView.reloadData()
        watchTableView.reloadSections([WatchViewStruct.header.rawValue], with: .none)
    }
    
}



// MARK: - TableView Delegate, DataSource
extension WatchVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return WatchViewStruct.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WatchViewStruct(rawValue: section)?.numberOfRowsInSection ?? 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch WatchViewStruct.allCases[safe: indexPath.section] {
        case .header:
            return WatchHeaderHIMMTVCell.getHeight()
        case .himm:
            return HIMModeCell.getHeight()
        case .charts:
            return view.frame.width*0.9
        case .hParams:
            switch WatchViewStruct.HParamsStruct(rawValue: indexPath.item) {
            case .hParams:
                return HealthParamsTVCell.getHeight()
            default:
                break
            }
        default:
            break
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch WatchViewStruct.allCases[safe: indexPath.section] {
        case .header:
            switch WatchViewStruct.HeaderStruct.allCases[safe: indexPath.row] {
            case .general:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: WatchViewStruct.HeaderStruct.general.key, for: indexPath) as? WatchHeaderHIMMTVCell else { break }
                return cell
            default:
                break
            }
        case .himm:
            let cell = tableView.dequeueReusableCell(withIdentifier: WatchViewStruct.HIMModeStruct.switcher.key, for: indexPath)
            return cell
        case .hParams:
            switch WatchViewStruct.HParamsStruct(rawValue: indexPath.item) {
            case .hParams:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: WatchViewStruct.HParamsStruct.hParams.key, for: indexPath) as? HealthParamsTVCell else { break }
                return cell
            default:
                break
            }
        case .charts:
            let chartCase = WatchViewStruct.ChartsStruct(rawValue: indexPath.row)
            switch chartCase {
            case .sleep:
                guard let cId = chartCase?.key,
                      let cell = tableView.dequeueReusableCell(withIdentifier: cId, for: indexPath) as? SleepWatchTVCell else { break }
                return cell
            default:
                let type = chartCase?.headerParm
                guard let celId = type?.watchChartsStruct.key, let cell = tableView.dequeueReusableCell(withIdentifier: celId, for: indexPath) as? WatchChartTVCell else { break }
                cell.healthType = type
                return cell
            }
        default:
            break
        }
        return tableView.dequeueReusableCell(withIdentifier: "qwe", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch WatchViewStruct(rawValue: indexPath.section) {
        case .header:
            (cell as? WatchHeaderHIMMTVCell)?.updateDevices()
        case .himm:
            let cell = cell as? HIMModeCell
            cell?.checkStatus()
        case .charts:
            let chartCase = WatchViewStruct.ChartsStruct(rawValue: indexPath.row)
            switch chartCase {
            case .sleep:
                let cell = cell as? SleepWatchTVCell
                healthDataManager.getCurrentDaySleep { _sm in
                    DispatchQueue.main.async {
                        cell?.sleepModel = _sm
                    }
                }
            default:
                guard WatchViewStruct.ChartsStruct(rawValue: indexPath.row) != .sleep,
                      let cell = cell as? WatchChartTVCell,
                      let ht = WatchViewStruct.ChartsStruct(rawValue: indexPath.row)?.headerParm.healthParamStruct else { return }
                cell.historicalIndicators = healthDataManager.indicators[ht] ?? [:]
            }
        default:
            break
        }
        
        switch (WatchViewStruct(rawValue: indexPath.section), WatchViewStruct.HParamsStruct(rawValue: indexPath.item)) {
        case (.hParams, .hParams):
            guard let cell = cell as? HealthParamsTVCell else { return }
            cell.prepareViewsBeforReqest(activityView: cell)
            HealthParamsManager.shared.getLast(uId: nil) { success, error in
                cell.enableViewsAfterReqest()
                DispatchQueue.main.async {
                    cell.setHealthParams(bo: success?.blood_oxygen,
                                         hr: success?.pulse ,
                                         temp: success?.temperature,
                                         bps: success?.pressure_systolic,
                                         bpd: success?.pressure_diastolic)
                }
            }
        default:
            return
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch WatchViewStruct(rawValue: section) {
        case .himm, .hParams:
            return Constants.inset/2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch WatchViewStruct(rawValue: section) {
        case .himm, .hParams:
            return UIView()
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch WatchViewStruct(rawValue: indexPath.section) {
        case .header:
            let devicesView = DevicesListModalView(frame: view.frame)
            devicesView.show { _ in
                tableView.reloadData()
            }
        default:
            break
        }
        
        switch (WatchViewStruct(rawValue: indexPath.section), WatchViewStruct.ChartsStruct(rawValue: indexPath.row)) {
        case (.charts, .sleep):
            guard let cell = tableView.cellForRow(at: indexPath) as? SleepWatchTVCell else { return }
            let vc = DetailedSleepInfoVC()
            vc.sleepModel = cell.sleepModel
            vc.didDisappearCompletion = {
                tableView.reloadRows(at: [indexPath], with: .none)
            }
            present(vc, animated: true)
        default:
            break
        }
    }
}



// MARK: - View Setups
extension WatchVC {
    func setUpSubViews() {
        view.addSubview(activityProgView)
        activityProgView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        activityProgView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        activityProgView.customHeightAnchorConstraint = activityProgView.heightAnchor.constraint(equalToConstant: 0)
        activityProgView.customHeightAnchorConstraint?.isActive = true
        activityProgView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        view.addSubview(watchTableView)
        
        watchTableView.delegate = self
        watchTableView.dataSource = self
        watchTableView.separatorColor = .clear
        watchTableView.backgroundColor = UIColor.appDefault.lightGrey
        
        watchTableView.topAnchor.constraint(equalTo: activityProgView.bottomAnchor).isActive = true
        watchTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        watchTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        watchTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        WatchViewStruct.registerCells(for: watchTableView)
        watchTableView.register(UITableViewCell.self, forCellReuseIdentifier: "qwe")
    }
    
    func viewSetUp() {
        view.backgroundColor = .white
    }

    func setUpNavigationView() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
