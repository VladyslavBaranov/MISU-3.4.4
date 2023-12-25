//
//  ParamChartViewCell.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 07.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit
import Charts

class ParamChartViewCell: UICollectionViewCell, RequestUIController, ChartCustomViewDelegate {
    func uniqeKeyForStore() -> String? {
        return self.getAddress()
    }
    
    func timeButtonTapped(_ time: TimeScalesDataEnum, type: HealthParamsEnum) {
        prepareViewsBeforReqest(viewsToBlock: lineChart.timeButtonViews, activityView: lineChart)
        HealthParamsManager.shared.getStatictic(userId: user?.profile?.id, type: type, range: time.sRange) { (paramsOp, errorOp) in
            self.enableViewsAfterReqest()
            print("getStatictic \(String(describing: paramsOp?.count)) \(String(describing: errorOp))")
            DispatchQueue.main.async {
                self.healthParams = paramsOp
            }
        }
    }
    
    let lineChart: ChartCustomView = .init()
    
    var healthParams: [HealthParameterModel]? {
        didSet {
            guard let hParams = healthParams else { return }
            lineChart.updateChartData(healthParams: hParams)
        }
    }
    
    var user: UserModel? {
        didSet {
            //updateUC()
        }
    }
    
    var healthType: HeadersParamEnum? {
        didSet {
            let sub: String? = {
                if let v = healthParams?.last?.value {
                    if healthType == .heartBeat { return "\(Int(v))" + (healthType?.label ?? "") }
                    if healthType == .pressure {
                        let addLbl = healthParams?.last?.additionalValue
                        return "\(Int(v)) | \(Int(addLbl ?? 0))" + (healthType?.label ?? "") }
                    return "\(v)" + (healthType?.label ?? "")
                }
                return nil
            }()
            lineChart.maxYValue = healthType?.maxValue
            lineChart.minYValue = healthType?.minValue
            lineChart.setTitleBar(icon: healthType?.imageIcon, title: healthType?.title, subtitle: sub)
            lineChart.typeHP = healthType?.healthParamStruct ?? .bloodOxygen
            lineChart.delegate = self
            lineChart.linesColors = healthType?.lineColor ?? []
            lineChart.gradientFills = healthType?.gradientFill ?? []
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    func setUpView() {
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(lineChart)
        
        lineChart.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        lineChart.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        lineChart.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        lineChart.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        lineChart.addCustomShadow()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

