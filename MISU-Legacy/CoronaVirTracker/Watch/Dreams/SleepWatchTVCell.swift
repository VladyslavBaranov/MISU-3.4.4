 //
//  SleepWatchTVCell.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 22.07.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit
import Charts

protocol SleepChartDelegate {
    func changed(_ sleepModel: SleepModel?)
}

protocol SleepPhasesDelegate {
    func selected(_ sleepPhase: SleepPhaseType)
}

class SleepChartView: UIView, RequestUIController {
    func uniqeKeyForStore() -> String? { return getAddress() }
    
    let sleepChart: LineChartView = .createCustom()
    let mainStack: UIStackView = .createCustom(axis: .vertical, distribution: .fill, spacing: 16)
    
    let switchDayStack: UIStackView = .createCustom()
    let prewButton: UIButton = .createCustom(withImage: UIImage(named: "arrowIconLeft")?.scaleTo(16), backgroundColor: UIColor.appDefault.blue, contentEdgeInsets: .init(top: 10, left: 12, bottom: 10, right: 12), tintColor: .white, imageRenderingMode: .alwaysTemplate, partCornerRadius: false, cornerRadius: 5, shadow: false)
    let dateLabel: UILabel = .createTitle(text: "--", fontSize: 14, color: .lightGray)
    let nextButton: UIButton = .createCustom(withImage: UIImage(named: "sendImage")?.scaleTo(16), backgroundColor: UIColor.appDefault.blue, contentEdgeInsets: .init(top: 10, left: 12, bottom: 10, right: 12), tintColor: .white, imageRenderingMode: .alwaysTemplate, partCornerRadius: false, cornerRadius: 5, shadow: false)
    
    let sleepTypesStack: UIStackView = .createCustom(distribution: .fillEqually)
    let typeDurationLabels: [SleepPhaseType:UILabel] = {
        return SleepPhaseType.allListForChart.reduce(into: [SleepPhaseType:UILabel]()) { dict, sType in
            let tt = UILabel.createTitle(text: "", color: .white)
            tt.attributedText = 0.getHoursAndMinuts()
            dict.updateValue(tt, forKey: sType)
        }
    }()
    var typeDurationTitleLabels: [SleepPhaseType:UILabel] = {
        return SleepPhaseType.allListForChart.enumerated().reduce(into: [SleepPhaseType:UILabel]()) { dict, sType in
            dict.updateValue(.createTitle(text: SleepPhaseType(forChart: sType.offset).localized,
                                          weight: .semibold, color: .white), forKey: sType.element)
        }
    }()
    var typeDurationBGView: [SleepPhaseType:UIView] = [:]
    var typeDurationIcon: [SleepPhaseType:UIImageView] = [:]
    var typeDurationStack: [SleepPhaseType:UIStackView] = [:]
    let defDurationText = "-\(NSLocalizedString("h", comment: "")) --\(NSLocalizedString("m", comment: ""))"
    let lenOfOneEntry = 5
    
    var sleepPhasesDelegate: SleepPhasesDelegate?
    var sleepChartDelegate: SleepChartDelegate?
    
    var sleepModel: SleepModel? {
        didSet {
            setUpChart()
            dateLabel.text = sleepModel?.date?.getDate() ?? HealthDataController.shared.currentSleepDateString
            nextButton.isEnabled = !(sleepModel?.date?.isSameDay(with: Date()) == true)
        }
    }
    
    var extendSleepPhases: Bool = false {
        didSet {
            if !extendSleepPhases { return }
            SleepPhaseType.allListForChart.forEach { sType in
                let st = typeDurationStack[sType]
                st?.axis = .vertical
                if let tt = typeDurationTitleLabels[sType] {
                    st?.insertArrangedSubview(tt, at: 1)
                }
                st?.spacing = standart24Inset/2
                st?.customTopAnchorConstraint?.constant = standartInset
                st?.customBottomAnchorConstraint?.constant = standartInset
                if let img = sType.bgStars, let bgView = typeDurationBGView[sType] {
                    let imgView = UIImageView.makeImageView(img)
                    bgView.addSubview(imgView)
                    imgView.topAnchor.constraint(equalTo: bgView.topAnchor).isActive = true
                    imgView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor).isActive = true
                    imgView.trailingAnchor.constraint(equalTo: bgView.trailingAnchor).isActive = true
                }
            }
        }
    }
    
    init() {
        super.init(frame: .zero)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    @objc func leftRightButtonAction(_ sender: UIButton) {
        switch sender {
        case prewButton:
            prepareViewsBeforReqest(viewsToBlock: [nextButton, prewButton], activityView: self)
            let currDate = HealthDataController.shared.getPreviousDaySleep { sm_ in
                self.enableViewsAfterReqest()
                DispatchQueue.main.async {
                    self.sleepModel = sm_
                    self.sleepChartDelegate?.changed(sm_)
                }
            }
            dateLabel.text = currDate.getDate()
        case nextButton:
            prepareViewsBeforReqest(viewsToBlock: [prewButton, nextButton], activityView: self)
            let currDate = HealthDataController.shared.getNextDaySleep { sm_ in
                self.enableViewsAfterReqest()
                DispatchQueue.main.async {
                    self.sleepModel = sm_
                    self.sleepChartDelegate?.changed(sm_)
                }
            }
            dateLabel.text = currDate.getDate()
        default:
            return
        }
    }
    
    @objc func sleepPhasesTapAction(_ sender: UITapGestureRecognizer) {
        let res = typeDurationBGView.first { key, vw in
            return vw == sender.view
        }
        guard let sType = res?.key else { return }
        
        sleepPhasesDelegate?.selected(sType)
    }
    
    var highlightedSleepPhase: SleepPhaseType?
    func highlightSleepPhase(_ phase: SleepPhaseType) {
        switch phase {
        case highlightedSleepPhase:
            highlightedSleepPhase = nil
            unHighlight(phase)
            setUpChart()
        default:
            if let prew = highlightedSleepPhase {
                unHighlight(prew)
            }
            highlightedSleepPhase = phase
            phase.addShadow(onView: typeDurationBGView[phase])
            setUpChart()
        }
    }
    func unHighlight(_ phase: SleepPhaseType) {
        typeDurationBGView[phase]?.removeShadow()
    }
    
    func setUpChart() {
        guard let sm = sleepModel else {
            //print("^^^ Sleep is EMPTY:")
            sleepChart.data = nil
            return
        }
        var entries: [ChartDataEntry] = []
        
        typeDurationLabels[.REM]?.attributedText = sm.REMCalcDuration.getHoursAndMinuts()
        typeDurationLabels[.awake]?.attributedText = sm.beginCalcDuration.getHoursAndMinuts()
        typeDurationLabels[.deep]?.attributedText = sm.deepCalcDuration.getHoursAndMinuts()
        typeDurationLabels[.light]?.attributedText = sm.lightCalcDuration.getHoursAndMinuts()
        
        var setsEntries = [[ChartDataEntry]]()
        sm.details.enumerated().forEach { key, value in
            guard let y = value.pType?.yForChart else { return }
            
            for i in 0..<lenOfOneEntry {
                entries.append(ChartDataEntry(x: Double(key*lenOfOneEntry+i), y: Double(y)))
            }
            
            if let entr = setsEntries.last, let lastY = entr.last?.y, Int(lastY) == y {
                for i in 0..<lenOfOneEntry {
                    setsEntries[setsEntries.count-1].append(ChartDataEntry(x: Double(key*lenOfOneEntry+i), y: Double(y)))
                }
            } else {
                var entrs = [ChartDataEntry]()
                for i in 0..<lenOfOneEntry {
                    entrs.append(ChartDataEntry(x: Double(key*lenOfOneEntry+i), y: Double(y)))
                }
                setsEntries.append(entrs)
            }
        }
        
        let set = LineChartDataSet(entries: entries)
        set.drawCirclesEnabled = false
        set.drawCircleHoleEnabled = false
        set.drawValuesEnabled = false
        set.colors = [.lightGray]
        var sets = [set]
        setsEntries.forEach { partEnteries in
            let s = LineChartDataSet(entries: partEnteries)
            s.drawCirclesEnabled = false
            s.drawCircleHoleEnabled = false
            s.drawValuesEnabled = false
            s.colors = [SleepPhaseType(forChart: Int(partEnteries.first?.y ?? 0)).color]
            s.lineWidth = 5
            s.lineCapType = .round
            sets.append(s)
        }
        
        if let y = highlightedSleepPhase?.yForChart, let x = entries.last?.x {
            var hEntries: [ChartDataEntry] = []
            hEntries.append(.init(x: 0, y: Double(y)))
            hEntries.append(.init(x: x, y: Double(y)))
            let hs = LineChartDataSet(entries: hEntries)
            
            hs.drawCirclesEnabled = false
            hs.drawCircleHoleEnabled = false
            hs.drawValuesEnabled = false
            hs.colors = [(highlightedSleepPhase?.color ?? .lightGray).withAlphaComponent(0.2)]
            hs.lineWidth = 20
            hs.lineCapType = .round
            sets.append(hs)
        }
        
        let chartData: LineChartData = .init(dataSets: sets)
        sleepChart.data = chartData
    }
    
    func setUp() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)
        mainStack.fixedEdgesConstraints(on: self, inset: .init())
        
        mainStack.addArrangedSubview(switchDayStack)
        switchDayStack.addArrangedSubview(prewButton)
        switchDayStack.addArrangedSubview(dateLabel)
        switchDayStack.addArrangedSubview(nextButton)
        switchDayStack.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true
        mainStack.addArrangedSubview(sleepChart)
        mainStack.addArrangedSubview(sleepTypesStack)
        sleepTypesStack.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true
        sleepChart.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true
        //sleepTypesStack.addTapRecognizer(self, action: #selector(sleepPhasesTapAction))
        
        prewButton.addTarget(self, action: #selector(leftRightButtonAction(_:)), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(leftRightButtonAction(_:)), for: .touchUpInside)
        
        sleepPhasesDelegate = self
        SleepPhaseType.allListForChart.forEach { sType in
            guard let title = typeDurationLabels[sType] else { return }
            let bgv = UIView.createCustom(bgColor: sType.color, cornerRadius: 5)
            let icon = UIImageView.makeImageView(sType.icon)
            let stk = UIStackView.createCustom([icon, title], spacing: 4)
            typeDurationBGView.updateValue(bgv, forKey: sType)
            typeDurationIcon.updateValue(icon, forKey: sType)
            typeDurationStack.updateValue(stk, forKey: sType)
            bgv.addSubview(stk)
            bgv.addTapRecognizer(self, action: #selector(sleepPhasesTapAction(_:)))
            stk.customCentrConstraints(on: bgv, inset: .init(top: 8, left: 4, bottom: 8, right: 4))
            //icon.heightAnchor.constraint(equalToConstant: 16).isActive = true
            //let w = icon.widthAnchor.constraint(equalToConstant: 16)
            //w.priority = .init(100)
            //w.isActive = true
            icon.setContentCompressionResistancePriority(.init(100), for: .horizontal)
            sleepTypesStack.addArrangedSubview(bgv)
        }
        
        sleepChart.xAxis.valueFormatter = self
        sleepChart.leftAxis.valueFormatter = self
        sleepChart.leftAxis.labelFont = .systemFont(ofSize: 8)
        sleepChart.xAxis.labelFont = .systemFont(ofSize: 8)
        sleepChart.leftAxis.axisMinimum = Double(SleepPhaseType.yChartRange.lowerBound)
        sleepChart.leftAxis.axisMaximum = Double(SleepPhaseType.yChartRange.upperBound)
        sleepChart.leftAxis.granularity = 1
        sleepChart.xAxis.granularity = 1
        sleepChart.highlightPerDragEnabled = false
        sleepChart.pinchZoomEnabled = false
        sleepChart.doubleTapToZoomEnabled = false
        sleepChart.leftAxis.spaceMin = 8
        sleepChart.leftAxis.spaceMax = 8
        sleepChart.xAxis.avoidFirstLastClippingEnabled = true
        sleepChart.xAxis.labelRotationAngle = 0
        sleepChart.setExtraOffsets(left: 0, top: 0, right: 0, bottom: 0)
        sleepChart.minOffset = 0
        sleepChart.delegate = self
        
        sleepChart.data = nil
    }
}

extension SleepChartView: IAxisValueFormatter, SleepPhasesDelegate, ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        sleepPhasesDelegate?.selected(SleepPhaseType(forChart: Int(entry.y)))
        sleepChart.highlightValue(nil)
    }
    
    func selected(_ sleepPhase: SleepPhaseType) {
        let vc = DetailedSleepInfoVC()
        vc.sleepModel = sleepModel
        vc.preSelectedSleepPhase = sleepPhase
        controller()?.present(vc, animated: true)
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        switch axis {
        case is YAxis:
            if Int(value) > SleepPhaseType.awake.yForChart || Int(value) < SleepPhaseType.deep.yForChart { return "" }
            return SleepPhaseType(forChart: Int(value)).localized
        default:
            //print("SSS ---------------------------------------------------------")
            //print("SSS ch dateTime \(sleepModel?.details[safe: Int(value)/lenOfOneEntry]?.dateTime ?? "nil")")
            //print("SSS ch date \(sleepModel?.details[safe: Int(value)/lenOfOneEntry]?.date)")
            //print("SSS ch date \(sleepModel?.details[safe: Int(value)/lenOfOneEntry]?.decoratedTime ?? "nil")")
            
            let curr = Int(value) - (Int(value)/lenOfOneEntry)*lenOfOneEntry
            let percent = Float(curr) / Float((lenOfOneEntry-1))
            return sleepModel?.details[safe: Int(value)/lenOfOneEntry]?.decoratedTimeBy(percent: percent) ?? "--"
        }
    }
}


class SleepWatchTVCell: UITableViewCell, SleepChartDelegate {
    let baseView: BaseWatchView = .init()
    let sleepView: SleepChartView = .init()
    
    var sleepModel: SleepModel? {
        set {
            sleepView.sleepModel = newValue
            baseView.subTitleLabel.attributedText = NSAttributedString(string: NSLocalizedString("Total", comment: "") + ":   ") + (newValue?.totalDuration ?? 0).getHoursAndMinuts()
        }
        get {
            return sleepView.sleepModel
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    func setUp() {
        backgroundColor = .clear
        contentView.addSubview(baseView)
        baseView.fixedEdgesConstraints(on: contentView, inset: .init(top: standartInset/2, left: standartInset/2,
                                                                     bottom: standartInset/2, right: standartInset/2))
        baseView.titleLabel.text = NSLocalizedString("Sleep", comment: "")
        baseView.titleImage.image = UIImage(named: "moonIcon")
        baseView.subTitleLabel.textColor = .black
        
        baseView.mainStack.addArrangedSubview(sleepView)
        sleepView.widthAnchor.constraint(equalTo: baseView.mainStack.widthAnchor).isActive = true
        sleepView.sleepChartDelegate = self
    }
    
    func changed(_ sleepModel: SleepModel?) {
        baseView.subTitleLabel.attributedText = NSAttributedString(string: NSLocalizedString("Total", comment: "") + ":   ") + (sleepModel?.totalDuration.getHoursAndMinuts() ?? NSAttributedString(string: "--"))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}



class BaseWatchView: UIView {
    let mainStack: UIStackView = .createCustom(axis: .vertical, distribution: .fill, spacing: 16)
    let titleStack: UIStackView = .createCustom(distribution: .fill)
    let titleImage: UIImageView = .makeImageView(UIImage(named: "misuLogo")?.scaleTo(50))
    let titleLabel: UILabel = .createTitle(text: "Title", fontSize: 16)
    let subTitleLabel: UILabel = .createTitle(text: "SubTitle", fontSize: 16, color: .lightGray)
    
    init() {
        super.init(frame: .zero)
        setUp()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    func setUp() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        cornerRadius = 10
        addCustomShadow()
        
        addSubview(mainStack)
        mainStack.fixedEdgesConstraints(on: self, inset: .init(top: 16, left: 16, bottom: 16, right: 16))
        
        mainStack.addArrangedSubview(titleStack)
        titleStack.addArrangedSubview(titleImage)
        titleStack.addArrangedSubview(titleLabel)
        titleStack.addArrangedSubview(subTitleLabel)
        
        titleStack.widthAnchor.constraint(equalTo: mainStack.widthAnchor).isActive = true
        titleLabel.setContentCompressionResistancePriority(.init(100), for: .horizontal)
        titleLabel.setContentHuggingPriority(.init(100), for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.init(1000), for: .vertical)
        titleLabel.setContentHuggingPriority(.init(1000), for: .vertical)
        titleImage.heightAnchor.constraint(equalTo: titleLabel.heightAnchor, multiplier: 1.1).isActive = true
        titleImage.widthAnchor.constraint(equalTo: titleLabel.heightAnchor, multiplier: 1.1).isActive = true
        subTitleLabel.setContentCompressionResistancePriority(.init(1000), for: .horizontal)
        subTitleLabel.setContentHuggingPriority(.init(1000), for: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
}
