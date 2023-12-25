//
//  HealthParamsCVCell.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 06.03.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class HealthParamsCVCell: UICollectionViewCell, RequestUIController {
    func uniqeKeyForStore() -> String? {
        return getAddress()
    }
    
    let hParamView: HealthParamsView = .init()
    
    var userModel: UserModel?
    
    var hParamsStatistic: [HeadersParamEnum:[HealthParameterModel]] {
        didSet {
            setHealthParams(bo: hParamsStatistic[.bloodOxygen]?.last?.value,
                            hr: hParamsStatistic[.heartBeat]?.last?.value,
                            temp: hParamsStatistic[.temperature]?.last?.value,
                            bps: hParamsStatistic[.pressure]?.last?.value,
                            bpd: hParamsStatistic[.pressure]?.last?.additionalValue)
        }
    }
    
    override init(frame: CGRect) {
        hParamsStatistic = [:]
        super.init(frame: frame)
        setUpView()
        setUpSubViews()
    }
    
    func goToAllCharts() {
        if let um = userModel {
            // go to all charts
            let vc = HParamsCListVC(userModel: um)
            vc.hidesBottomBarWhenPushed = true
            controller()?.navigationController?.pushViewController(vc, animated: true)
        } else {
            // go to watch
            (controller()?.tabBarController as? MainTabBarController)?.setSelectedTab(index: MainTabBarStructEnum.watch.rawValue)
        }
    }
    
    func requestHParams() {

        prepareViewsBeforReqest(activityView: self)
        HealthParamsManager.shared.getLast(uId: userModel?.id) { success, error in
            self.enableViewsAfterReqest()
            //print("### getLastParams \(String(describing: success))")
            //print("### getLastParams error \(String(describing: error))")
            DispatchQueue.main.async {
                self.setHealthParams(bo: success?.blood_oxygen,
                                     hr: success?.pulse ,
                                     temp: success?.temperature,
                                     bps: success?.pressure_systolic,
                                     bpd: success?.pressure_diastolic)
            }
        }
    }
    
    func setHealthParams(bo: Float?, hr: Float?, temp: Float?, bps: Float?, bpd: Float?) {
        hParamView.setHealthParams(bo: bo, hr: hr, temp: temp, bps: bps, bpd: bpd)
    }
    
    func setUpView() {
        self.backgroundColor = .clear
    }
    
    func setUpSubViews() {
        contentView.addSubview(hParamView)
        
        hParamView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.inset/2).isActive = true
        hParamView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.inset/2).isActive = true
        hParamView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    static func getHeight() -> CGFloat {
        let cell = HealthParamsView()
        return cell.paramStackHeight + cell.standartInset
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
