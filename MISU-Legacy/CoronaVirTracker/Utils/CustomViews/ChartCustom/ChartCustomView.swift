//
//  ChartCustomView.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 08.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit
import Charts

protocol ChartCustomViewDelegate {
    func timeButtonTapped(_ time: TimeScalesDataEnum, type: HealthParamsEnum)
}

class ChartCustomView: UIView {
    var delegate: ChartCustomViewDelegate? = nil
    let lineChartView: LineChartView = .createCustom()
    let firstXLabel: UILabel = .createTitle(text: "--", fontSize: 8)
    let lastXLabel: UILabel = .createTitle(text: "--", fontSize: 8)
    
    let titleImage: UIImageView = .makeImageView("koliaReloadIcon")
    let titleLabel: UILabel = .createTitle(text: "-", fontSize: 16, color: .black, alignment: .left)
    let subTitleLabel: UILabel = .createTitle(text: "-", fontSize: 16, color: .lightGray)
    let timeButtonsStack: UIStackView = .createCustom()
    let timeButtonViews: [UIButton] = {
        var btns: [UIButton] = []
        TimeScalesDataEnum.allCases.forEach { tm in
            btns.append(.createCustom(title: tm.localized, color: .clear, fontSize: 14, textColor: .gray, shadow: false, customContentEdgeInsets: false))
        }
        return btns
    }()
    
    var selectedTimeScale: TimeScalesDataEnum = .today
    var typeHP: HealthParamsEnum {
        didSet {
            delegate?.timeButtonTapped(selectedTimeScale, type: typeHP)
        }
    }
    var healthParameters: [HealthParameterModel] = []
    var cutedHealthParameters: [HealthParameterModel] = []
    
    var maxYValue: Double? {
        didSet {
            guard let mx = maxYValue else { return }
            lineChartView.leftAxis.axisMaximum = mx
            
        }
    }
    
    var minYValue: Double? {
        didSet {
            guard let mn = minYValue else { return }
            lineChartView.leftAxis.axisMinimum = mn
        }
    }
    
    var linesColors: [UIColor] = [
        UIColor.appDefault.blackPrimary
    ]
    var gradientFills: [CGGradient] = []
    /*    CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                        colors: [UIColor.appDefault.red.cgColor, UIColor.white.cgColor] as CFArray,
                        locations: [1.0, 0.0])
    ]*/
    
    init(icon: UIImage? = nil, title: String? = nil, subtitle: String? = nil) {
        typeHP = .bloodOxygen
        super.init(frame: .zero)
        setUpView()
        setTitleBar(icon: icon, title: title, subtitle: subtitle)
        //sortByTimeScale()
        setSelectedCorrectButton()
    }
    
    func updateChartData(healthParams list: [HealthParameterModel], isSTimeBAction: Bool = false, _ completion: (()->Void)? = nil) {
        
        //healthParameters = list
        var data: [ChartDataEntry] = []
        var additData: [ChartDataEntry] = []
        
        healthParameters = list
        cutedHealthParameters = list
        data = list.enumerated().map { index, param -> ChartDataEntry in
            return ChartDataEntry(x: Double(index), y: Double(param.value ?? 0))
        }
        
        if typeHP == .pressure {
            additData = list.enumerated().map({ index, param -> ChartDataEntry in
                //print("### \(param.additionalValue)")
                return ChartDataEntry(x: Double(index), y: Double(param.additionalValue ?? 0))
            })
        }
        
        DispatchQueue.main.async {
            //print("TTTT4 \(list.count) \(self.typeHP)")
            if data.isEmpty {
                self.lineChartView.data = nil
                return
            }
            
            let set = LineChartDataSet.createCustom(data: data,
                                                    circleColor: self.linesColors.first,
                                                    circleRadius: 1,
                                                    lineColor: self.linesColors.first,
                                                    gradientCollor: self.gradientFills.first)
            var chartData: LineChartData = .init(dataSet: set)
            if !additData.isEmpty {
                let addSet = LineChartDataSet.createCustom(data: additData,
                                                           circleColor: self.linesColors.last,
                                                           circleRadius: 1,
                                                           lineColor: self.linesColors.last,
                                                           gradientCollor: self.gradientFills.last)
                chartData = .init(dataSets: [set, addSet])
            }
            self.lineChartView.data = chartData
            self.firstXLabel.text = self.healthParameters.first?.date?.toDate()?.getTimeDateWitoutToday(zeroCalendar: true)
            self.lastXLabel.text = self.healthParameters.last?.date?.toDate()?.getTimeDateWitoutToday(zeroCalendar: true)
            completion?()
        }
    }
    
    func sortByTimeScale() {
        updateChartData(healthParams: healthParameters, isSTimeBAction: true)
        setSelectedCorrectButton()
    }
    
    func setSelectedCorrectButton() {
        if let btn = timeButtonViews[safe: selectedTimeScale.index ] {
            setSelectedButton(btn)
        }
    }
    
    func cutDataByTimeScale(isSTimeBAction: Bool) -> [HealthParameterModel] {
        var newCut: [HealthParameterModel] = []
        
        
        healthParameters.forEach { hParam in
            guard let dt = hParam.date?.toDate() else { return }
            let components = Calendar.current.dateComponents([selectedTimeScale.calendarComponent], from: dt, to: Date())
            if selectedTimeScale.include(components) {
                newCut.append(hParam)
            }
        }
        
        if newCut.isEmpty, selectedTimeScale != TimeScalesDataEnum.allCases.last, !isSTimeBAction {
            if let nextBtnIndex = timeButtonViews[safe: selectedTimeScale.index + 1] {
                DispatchQueue.main.async { self.timeButtonAction(nextBtnIndex) }
            }
        }
        cutedHealthParameters = newCut
        
        return cutedHealthParameters
    }
    
    @objc func timeButtonAction(_ sender: UIButton) {
        guard let btnIndex = timeButtonViews.firstIndex(of: sender) else { return }
        selectedTimeScale = TimeScalesDataEnum.allCases[safe: btnIndex] ?? .today
        
        sortByTimeScale()
        
        delegate?.timeButtonTapped(selectedTimeScale, type: typeHP)
    }
    
    func setSelectedButton(_ sender: UIButton) {
        sender.setTitleColor(.black, for: .normal)
        timeButtonViews.forEach { btn in
            if btn == sender { return }
            btn.setTitleColor(UIColor.gray.withAlphaComponent(0.5), for: .normal)
        }
    }
    
    func setTitleBar(icon: UIImage? = nil, title: String? = nil, subtitle: String? = nil) {
        titleImage.image = icon
        titleLabel.text = title
        subTitleLabel.text = subtitle
        isTitleBar(icon != nil || title != nil || subtitle != nil)
    }
    
    func isTitleBar(_ isTB: Bool) {
        if isTB {
            let ancActiv = timeButtonsStack.topAnchor.constraint(equalTo: titleImage.bottomAnchor, constant: standartInset)
            self.animateChangeConstraints(deactivate: timeButtonsStack.customTopAnchorConstraint, activate: ancActiv, duration: 0.1)
            timeButtonsStack.customTopAnchorConstraint = ancActiv
            return
        }
        let ancActiv = timeButtonsStack.topAnchor.constraint(equalTo: self.topAnchor, constant: standartInset)
        self.animateChangeConstraints(deactivate: timeButtonsStack.customTopAnchorConstraint, activate: ancActiv, duration: 0.1)
        timeButtonsStack.customTopAnchorConstraint = ancActiv
    }
    
    func setUpView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        //self.addCustomShadow()
        self.cornerRadius = standartInset
        //self.addSubview(lineChartView)
        self.addSubview(titleImage)
        self.addSubview(titleLabel)
        self.addSubview(subTitleLabel)
        self.addSubview(timeButtonsStack)
        
        titleImage.topAnchor.constraint(equalTo: self.topAnchor, constant: standartInset).isActive = true
        titleImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: standartInset).isActive = true
        titleImage.heightAnchor.constraint(equalToConstant: standartInset).isActive = true
        //let w = (titleImage.image?.size.width ?? 1)/(titleImage.image?.size.height ?? 1)
        titleImage.widthAnchor.constraint(equalTo: titleImage.heightAnchor).isActive = true
        
        titleLabel.centerYAnchor.constraint(equalTo: titleImage.centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: titleImage.trailingAnchor, constant: standartInset/2).isActive = true
        
        subTitleLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        subTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: standartInset/2).isActive = true
        subTitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -standartInset).isActive = true
        subTitleLabel.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        subTitleLabel.setContentHuggingPriority(.init(1000), for: .horizontal)
        
        timeButtonsStack.customTopAnchorConstraint = timeButtonsStack.topAnchor.constraint(equalTo: self.topAnchor, constant: standartInset)
        timeButtonsStack.customTopAnchorConstraint?.isActive = false
        timeButtonsStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: standartInset).isActive = true
        timeButtonsStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -standartInset).isActive = true
        timeButtonsStack.heightAnchor.constraint(equalToConstant: standart24Inset).isActive = true
        timeButtonViews.forEach { btn in
            btn.addTarget(self, action: #selector(timeButtonAction(_:)), for: .touchUpInside)
            timeButtonsStack.addArrangedSubview(btn)
        }
        setUpChart()
    }
    
    func setUpChart() {
        self.addSubview(lineChartView)
        addSubview(firstXLabel)
        addSubview(lastXLabel)
        lineChartView.topAnchor.constraint(equalTo: timeButtonsStack.bottomAnchor, constant: standartInset/2).isActive = true
        lineChartView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: standartInset).isActive = true
        lineChartView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -standartInset).isActive = true
        //lineChartView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -standartInset).isActive = true
        lineChartView.bottomAnchor.constraint(equalTo: firstXLabel.topAnchor).isActive = true
        lineChartView.xAxis.valueFormatter = self
        firstXLabel.topAnchor.constraint(equalTo: lineChartView.bottomAnchor).isActive = true
        firstXLabel.leadingAnchor.constraint(equalTo: lineChartView.leadingAnchor).isActive = true
        firstXLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -standartInset).isActive = true
        lastXLabel.topAnchor.constraint(equalTo: lineChartView.bottomAnchor).isActive = true
        lastXLabel.trailingAnchor.constraint(equalTo: lineChartView.trailingAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ChartCustomView: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if cutedHealthParameters.count <= 0 { return "" }
        let str = cutedHealthParameters[safe: Int(value) % cutedHealthParameters.count]?.date?.toDate()?.getTimeDateWitoutToday(zeroCalendar: true) ?? ""
        return str
    }
}

extension LineChartDataSet {
    static func createCustom(data: [ChartDataEntry],
                             circleColor: UIColor? = nil,
                             circleRadius: CGFloat = 0,
                             circleHoleRadius: CGFloat = 0,
                             lineWidth: CGFloat = 2,
                             lineColor: UIColor? = nil,
                             gradientCollor: CGGradient? = nil
    ) -> LineChartDataSet {
        let setCust = LineChartDataSet(entries: data)
        setCust.drawValuesEnabled = false
        setCust.lineWidth = lineWidth
        setCust.circleRadius = circleRadius
        setCust.circleHoleRadius = circleHoleRadius
        setCust.setCircleColor(circleColor ?? UIColor.appDefault.blackPrimary)
        setCust.setColor(lineColor ?? UIColor.appDefault.blackPrimary)
        setCust.mode = .horizontalBezier
        
        if let fillGrad = gradientCollor {
            setCust.fill = Fill.fillWithLinearGradient(fillGrad, angle: 90.0)
            setCust.drawFilledEnabled = true
        } else {
            setCust.drawFilledEnabled = false
        }
        
        return setCust
    }
}

extension LineChartView {
    static func createCustom() -> LineChartView {
        let ch = LineChartView()
        ch.translatesAutoresizingMaskIntoConstraints = false
        ch.backgroundColor = .white
        ch.xAxis.labelPosition = .bottom
        ch.xAxis.drawGridLinesEnabled = false
        ch.xAxis.drawAxisLineEnabled = false
        ch.leftAxis.drawZeroLineEnabled = false
        ch.rightAxis.enabled = false
        ch.leftAxis.drawAxisLineEnabled = false
        ch.leftAxis.gridLineDashLengths = [3,8]
        ch.leftAxis.spaceMin = 16
        ch.drawBordersEnabled = false
        ch.legend.enabled = false
        ch.xAxis.granularity = 1
        ch.setExtraOffsets(left: 0, top: 0, right: 16, bottom: 0)
        //ch.xAxis.setLabelCount(5, force: true)
        ch.xAxis.avoidFirstLastClippingEnabled = false
//        ch.xAxis.granularityEnabled = true
        ch.xAxis.labelRotationAngle = -15
        //ch.xAxis.axisMaxLabels = 5
        //ch.xAxis.label
        let marker = ChartMarker()
        marker.chartView = ch
        ch.highlightPerDragEnabled = false
        ch.marker = marker
        //ch.highlightPerTapEnabled = true
        //ch.isUserInteractionEnabled = false
        //ch.leftAxis.granularity = 1
        return ch
    }
}
