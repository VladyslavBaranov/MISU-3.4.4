//
//  SugarInsulinHistoryVC.swift
//  CoronaVirTracker
//
//  Created by WH ak on 22.08.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit
import Charts

class SugarInsulinHistoryVC: UIViewController {
    let mainCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.alwaysBounceVertical = false
        cv.alwaysBounceHorizontal = false
        cv.backgroundColor = UIColor.appDefault.lightGrey
        cv.isPagingEnabled = true
        
        return cv
    }()
    
    let segmentController: UISegmentedControl = {
        let items = [SugarInsulineEnum.sugar.localized, SugarInsulineEnum.insuline.localized]
        let sc = UISegmentedControl(items: items)
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    let lineChartView: ChartCustomView = .init()
    
    var sugarDataList: [HealthParameterModel] = []
    var insulinDataList: [HealthParameterModel] = []
    
    var selectedType: SugarInsulineEnum? {
        didSet {
            guard let type = selectedType else { return }
            selectCorrectSegment(type.index)
            //updateCollectionData(type)
        }
    }
    
    var userModel: UserModel?
    
    init(selectedTab: SugarInsulineEnum) {
        super.init(nibName: nil, bundle: nil)
        selectedType = selectedTab
    }
    
    init(selectedTab: SugarInsulineEnum, user: UserModel?) {
        super.init(nibName: nil, bundle: nil)
        selectedType = selectedTab
        userModel = user
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// MARK: - View loads Overrides
extension SugarInsulinHistoryVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewSetUp()
        setUpNavigationView()
        setUpCollectionView()
        setUpSegmentController()
        updateData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let type = selectedType else { return }
        selectCorrectSegment(type.index)
        mainCollectionView.scrollToItem(at: IndexPath(row: 0, section: type.index), at: .init(), animated: true)
    }
}



// MARK: - Actions
extension SugarInsulinHistoryVC {
    @objc func addParameterAction() {
        let type: SugarInsulineEnum = SugarInsulineEnum.allCases[segmentController.selectedSegmentIndex]
        let addSIView = SugarInsulinCreateView(frame: view.frame, type: type)
        addSIView.show { _ in
            guard let healthModel = addSIView.healthParamModel else { return }
            print(healthModel.dateDType?.getTimeDateForRequest() as Any)
            HealthParamsManager.shared.newValueHealthParam(model: healthModel, type: type.healtParamEnum) { successOp, errorOp in
                if let success = successOp {
                    print("New value \(type.rawValue): \(success)")
                    ModalMessagesController.shared.show(message: "Success ...", type: .success)
                    self.addNewValue(success, type: type)
                }

                if let error = errorOp {
                    print("New value \(type.rawValue) Error: \(error)")
                    ModalMessagesController.shared.show(message: error.getInfo(), type: .error)
                }
            }
        }
    }
}



// MARK: - Scroll view overloads
extension SugarInsulinHistoryVC {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let segment = Int((scrollView.contentOffset.x/view.frame.width).rounded(.toNearestOrAwayFromZero))
        selectCorrectSegment(segment)
    }
}
    
    

// MARK: - Others
extension SugarInsulinHistoryVC {
    func addNewValue(_ value: HealthParameterModel, type: SugarInsulineEnum) {
        switch type {
        case .sugar:
            sugarDataList.insert(value, at: 0)
            DispatchQueue.main.async { self.mainCollectionView.insertItems(at: [IndexPath(item: 0, section: type.index)]) }
        case .insuline:
            insulinDataList.insert(value, at: 0)
            DispatchQueue.main.async { self.mainCollectionView.insertItems(at: [IndexPath(item: 0, section: type.index)]) }
        }
        //DispatchQueue.main.async { self.mainCollectionView.reloadData() }
    }
    
    func updateData() {
        let proccess = StandartAlertUtils.startAndReturnActivityProcessViewOn(center: mainCollectionView, style: .medium, color: .gray)
        HealthParamsManager.shared.getHealthParamsHistory(type: .sugar, profileId: userModel?.profile?.id) { (sugarDataOp, error) in
            if var sugarData = sugarDataOp {
                sugarData.sort { (first, second) -> Bool in
                    guard let firstDate = first.date?.toDate() else { return false }
                    guard let secondDate = second.date?.toDate() else { return true }
                    if firstDate.compare(secondDate) == .orderedDescending {
                        return true
                    }
                    return false
                }
                self.sugarDataList = sugarData
                DispatchQueue.main.async { self.mainCollectionView.reloadData() }
                print("Get Sugar list success: \(sugarData.count)")
                DispatchQueue.main.async { self.updateChart() }
            }
            print("Get Sugar list Error: \(String(describing: error))")
            StandartAlertUtils.stopActivityProcessView(activityIndicator: proccess)
        }
        
        let proccess2 = StandartAlertUtils.startAndReturnActivityProcessViewOn(center: mainCollectionView, style: .medium, color: .gray)
        HealthParamsManager.shared.getHealthParamsHistory(type: .insuline, profileId: userModel?.profile?.id) { (insulinDataOp, error) in
            if var insulinData = insulinDataOp {
                insulinData.sort { (first, second) -> Bool in
                    guard let firstDate = first.date?.toDate() else { return false }
                    guard let secondDate = second.date?.toDate() else { return true }
                    if firstDate.compare(secondDate) == .orderedDescending {
                        return true
                    }
                    return false
                }
                self.insulinDataList = insulinData
                DispatchQueue.main.async { self.mainCollectionView.reloadData() }
                print("Get Insuline list success: \(insulinData.count)")
                DispatchQueue.main.async { self.updateChart() }
            }
            print("Get Insuline list Error: \(String(describing: error))")
            StandartAlertUtils.stopActivityProcessView(activityIndicator: proccess2)
        }
    }
    
    func selectCorrectSegment(_ segment: Int = 0) {
        if segment != segmentController.selectedSegmentIndex {
            segmentController.selectedSegmentIndex = segment
            updateChart()
        }
    }
    
    @objc func segmentedControlValueChanged(segment: UISegmentedControl) {
        let section = segment.selectedSegmentIndex
        mainCollectionView.scrollToItem(at: IndexPath(row: 0, section: section), at: .init(), animated: true)
        updateChart()
    }
    
    func updateChart() {
        let params = segmentController.selectedSegmentIndex == SugarInsulineEnum.insuline.index ? insulinDataList : sugarDataList
        lineChartView.updateChartData(healthParams: params.reversed())
    }
}



// MARK: - View Setups
extension SugarInsulinHistoryVC {
    func viewSetUp() {
        view.backgroundColor = UIColor.appDefault.lightGrey
    }
    
    func setUpCollectionView() {
        view.addSubview(lineChartView)
        lineChartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.standartInset).isActive = true
        lineChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.standartInset).isActive = true
        lineChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -view.standartInset).isActive = true
        //lineChartView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        lineChartView.heightAnchor.constraint(equalTo: lineChartView.widthAnchor, multiplier:0.72).isActive = true
        lineChartView.addCustomShadow()
        
        view.addSubview(mainCollectionView)
        
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        
        mainCollectionView.register(ParamHistoryViewCell.self, forCellWithReuseIdentifier: SugarInsulineEnum.sugar.rawValue)
        
        //mainCollectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainCollectionView.topAnchor.constraint(equalTo: lineChartView.bottomAnchor, constant: view.standartInset).isActive = true
        mainCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        mainCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        mainCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
    
    func setUpNavigationView() {
        navigationItem.titleView = segmentController
        navigationController?.navigationBar.isTranslucent = false
        if userModel == nil {
            navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(addParameterAction))
        }
    }
    
    func setUpSegmentController() {
        segmentController.addTarget(self, action: #selector(segmentedControlValueChanged(segment:)), for: .valueChanged)
    }
}
