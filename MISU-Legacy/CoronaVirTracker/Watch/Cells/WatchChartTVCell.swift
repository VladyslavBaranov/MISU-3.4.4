//
//  WatchChartTVCell.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 05.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit
import Charts

extension WatchChartTVCell: ChartCustomViewDelegate, RequestUIController {
    func uniqeKeyForStore() -> String? {
        return getAddress()
    }
    
    func timeButtonTapped(_ time: TimeScalesDataEnum, type: HealthParamsEnum) {
        //prepareViewsBeforReqest(viewsToBlock: lineChart.timeButtonViews, activityView: lineChart)
        /*HealthParamsManager.shared.getStatictic(userId: userProfId, type: type, range: time.sRange) { (paramsOp, errorOp) in
            self.enableViewsAfterReqest()
            print("getStatictic \(String(describing: paramsOp?.count)) \(String(describing: errorOp))")
            //print("### getStatictic \(String(describing: paramsOp))")
            DispatchQueue.main.async {
                self.healthParams = paramsOp
            }
        }*/
        //print("SUCCESSSSSSS! \(time.sRange) \(historicalIndicators[time.sRange])")
        guard let hp = historicalIndicators[time.sRange] else { return }
        //print("TTTT2 ", time.sRange, historicalIndicators[time.sRange]?.count as Any)
        healthParams = hp
    }
}

class WatchChartTVCell: UITableViewCell {
    let lineChart: ChartCustomView = .init()
    let calibrationButton: UIButton = .createCustom(title: NSLocalizedString("Needs calibration", comment: ""))
    let newCalibrationButton: UIButton = .createCustom(title: NSLocalizedString("Calibrate", comment: ""),
                                                       fontSize: 12, customContentEdgeInsets: false)
    
    var healthParams: [HealthParameterModel]? {
        didSet {
            // print("SUCCESSSSSSS!! \(healthParams)")
            guard let hParams = healthParams else { return }
            // print("TTTT3 \(hParams.count)")
            lineChart.updateChartData(healthParams: hParams)
        }
    }
    
    var historicalIndicators: HistoricalIndicators = [:] {
        didSet {
            timeButtonTapped(lineChart.selectedTimeScale, type: healthType?.healthParamStruct ?? .heartBeat)
        }
    }
    
    var userProfId: Int? = nil
    
    var healthType: HeadersParamEnum? {
        didSet {
            checkCalibrate()
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpView()
        setUpChart()
    }
    
    var task: URLSessionTask?
    func checkCalibrate() {
        if userProfId != nil { return }
        task?.cancel()
        if healthType != .pressure { return }
        task = HealthParamsManager.shared.getCalibrate { (calibratetModels, error) in
            //print("### needCalibrate \(String(describing: calibratetModels))")
            //print("### needCalibrate ERROR \(String(describing: error))")
            
            if let cm = calibratetModels, (cm.first(where: {$0.type == self.healthType?.healthParamStruct}) != nil) {
                DispatchQueue.main.async {
                    self.needCalibrate(false)
                }
            } else if calibratetModels != nil {
                DispatchQueue.main.async {
                    self.needCalibrate(true)
                }
            }
        }
    }
    
    @objc func calibrateAction() {
        let vc = CalibrationVC()
        navigationController()?.present(vc, animated: true)
    }
    
    func needCalibrate(_ need: Bool) {
        if need {
            lineChart.animateFade(alpha: 0.3, duration: 0.1)
            calibrationButton.animateShow(duration: 0.1)
            newCalibrationButton.animateFade(duration: 0.1)
        } else {
            lineChart.animateShow(duration: 0.1)
            newCalibrationButton.animateShow(duration: 0.1)
            calibrationButton.animateFade(duration: 0.1)
        }
        
    }
    
    func setUpView() {
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func setUpChart() {
        contentView.addSubview(lineChart)
        
        lineChart.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standartInset/2).isActive = true
        lineChart.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset/2).isActive = true
        lineChart.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset/2).isActive = true
        lineChart.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset/2).isActive = true
        lineChart.addCustomShadow()
        
        contentView.addSubview(calibrationButton)
        calibrationButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        calibrationButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        calibrationButton.animateFade(duration: 0)
        calibrationButton.addTarget(self, action: #selector(calibrateAction), for: .touchUpInside) //calibrateAction
        
        contentView.addSubview(newCalibrationButton)
        newCalibrationButton.centerYAnchor.constraint(equalTo: lineChart.subTitleLabel.centerYAnchor).isActive = true
        newCalibrationButton.trailingAnchor.constraint(equalTo: lineChart.subTitleLabel.leadingAnchor, constant: -standartInset).isActive = true
        newCalibrationButton.contentEdgeInsets = .init(top: standartInset/2, left: standartInset, bottom: standartInset/2, right: standartInset)
        newCalibrationButton.animateFade(duration: 0)
        newCalibrationButton.addTarget(self, action: #selector(calibrateAction), for: .touchUpInside)
        //newCalibrationButton.leadingAnchor.constraint(greaterThanOrEqualTo: lineChart.titleLabel.trailingAnchor, constant: standartInset).isActive = true
        //newCalibrationButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        //newCalibrationButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
