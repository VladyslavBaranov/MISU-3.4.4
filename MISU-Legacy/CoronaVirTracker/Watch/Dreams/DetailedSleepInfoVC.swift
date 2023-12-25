//
//  DetailedSleepInfoVC.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 31.07.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class DetailedSleepInfoVC: PresentUIViewController {
    let scrollView: UIScrollView = .create()
    let mainView: BaseWatchView = .init()
    let chartView: SleepChartView = .init()
    let detailedInfoBGView: UIView = .createCustom(bgColor: .white, cornerRadius: 10)
    let detailedInfoLabel: UILabel = .createTitle(text: "", alignment: .center, numberOfLines: 13)
    
    let recommendationTitle: UILabel = .createTitle(text: NSLocalizedString("Recommendations", comment: "") + ":", color: .gray)
    let recommendationCV: UICollectionView = .create(scrollDirection: .horizontal, alwaysBounceHorizontal: true, isPagingEnabled: false)
    let cellId = "recommendationCVCellId"
    var cellWidth: CGFloat {
        return mainView.mainStack.frame.width*0.8
    }
    
    var sleepModel: SleepModel? {
        didSet {
            chartView.sleepModel = sleepModel
            mainView.subTitleLabel.attributedText = NSAttributedString(string: NSLocalizedString("Total", comment: "") + ":   ") + (sleepModel?.totalDuration ?? 0).getHoursAndMinuts()
        }
    }
    
    var selectedSleepPhase: SleepPhaseType?
    var preSelectedSleepPhase: SleepPhaseType?
    let healthDataController = HealthDataController.shared
    var recommendations: [RecommendationSleepModel] {
        healthDataController.sleepRecommendations
    }
    
    var didDisappearCompletion: (()->())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        healthDataController.sleepDelegate = self
        
        if let pssp = preSelectedSleepPhase {
            selected(pssp)
        }
        
        getReco()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        didDisappearCompletion?()
    }
}



extension DetailedSleepInfoVC: SleepPhasesDelegate, SleepChartDelegate, RequestUIController, SleepDataDeledate {
    func uniqeKeyForStore() -> String? {
        return view.getAddress()
    }
    
    func getReco() {
        healthDataController.update(.sleep)
    }
    
    func sleepDataUpdated() {
        DispatchQueue.main.async {
            self.recommendationCV.reloadData()
        }
    }
    
    func sleepDataUpdatedWith(error: String) {
        print("SleepData Updated With ERROR \(error)")
    }
    
    func changed(_ sleepModel: SleepModel?) {
        mainView.subTitleLabel.attributedText = NSAttributedString(string: NSLocalizedString("Total", comment: "") + ":   ") + (sleepModel?.totalDuration.getHoursAndMinuts() ?? NSAttributedString(string: "--"))
    }
    
    func selected(_ sleepPhase: SleepPhaseType) {
        switch sleepPhase {
        case selectedSleepPhase:
            selectedSleepPhase = nil
            
            detailedInfoBGView.backgroundColor = .white
            detailedInfoBGView.removeFromSuperview()
            mainView.mainStack.setCustomSpacing(mainView.mainStack.spacing, after: chartView)
        default:
            selectedSleepPhase = sleepPhase
            
            detailedInfoLabel.text = sleepPhase.localizedDetailedText
            detailedInfoBGView.backgroundColor = sleepPhase.color.withAlphaComponent(0.2)
            mainView.mainStack.insertArrangedSubview(detailedInfoBGView,
                                                     at: (mainView.mainStack.arrangedSubviews.firstIndex(of: chartView) ?? 0)+1)
            mainView.mainStack.setCustomSpacing(chartView.sleepTypesStack.spacing, after: chartView)
        }
        chartView.highlightSleepPhase(sleepPhase)
    }
}



extension DetailedSleepInfoVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        (collectionView.cellForItem(at: indexPath) as? RecoSleepCell)?.cellSelected()
        //let vc = ScrollPresentVC()
        //present(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as? RecoSleepCell
        cell?.reco = recommendations[safe: indexPath.item]
        //cell?.nextReco = recommendations[safe: indexPath.item+1]
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: cellWidth, height: collectionView.frame.height)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == recommendationCV, !recommendations.isEmpty {
            let cellId: Int = Int((recommendationCV.contentOffset.x/cellWidth).rounded(.toNearestOrEven))
            recommendationCV.scrollToItem(at: .init(item: cellId, section: 0), at: .left, animated: true)
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView == recommendationCV, !recommendations.isEmpty {
            let cellId: Int = Int((recommendationCV.contentOffset.x/cellWidth).rounded(.toNearestOrEven))
            recommendationCV.scrollToItem(at: .init(item: cellId, section: 0), at: .left, animated: true)
        }
    }
}



extension DetailedSleepInfoVC {
    override func setUp() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.fixedEdgesConstraints(on: view, inset: .zero)
        scrollView.addSubview(mainView)
        scrollView.showsVerticalScrollIndicator = false
        
        mainView.removeShadow()
        mainView.titleLabel.text = NSLocalizedString("Sleep", comment: "")
        
        mainView.titleImage.image = UIImage(named: "moonIcon")
        
        mainView.subTitleLabel.textColor = .black
        mainView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        mainView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: view.standartInset).isActive = true
        mainView.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor).isActive = true
        mainView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -view.standartInset).isActive = true
        mainView.mainStack.spacing = view.standartInset*2
        
        mainView.mainStack.addArrangedSubview(chartView)
        chartView.widthAnchor.constraint(equalTo: mainView.mainStack.widthAnchor).isActive = true
        chartView.sleepChart.heightAnchor.constraint(equalToConstant: view.frame.width*0.4).isActive = true
        chartView.extendSleepPhases = true
        chartView.mainStack.spacing = view.standart24Inset
        chartView.mainStack.insertArrangedSubview(chartView.switchDayStack, at: 1)
        chartView.sleepPhasesDelegate = self
        chartView.sleepChartDelegate = self
        
        detailedInfoBGView.addSubview(detailedInfoLabel)
        detailedInfoLabel.fixedEdgesConstraints(on: detailedInfoBGView, inset: .init(top: 16, left: 8, bottom: 16, right: 8))
        
        mainView.mainStack.addArrangedSubview(recommendationTitle)
        recommendationTitle.widthAnchor.constraint(equalTo: mainView.mainStack.widthAnchor).isActive = true
        mainView.mainStack.setCustomSpacing(mainView.mainStack.spacing/2, after: recommendationTitle)
        
        mainView.mainStack.customTopAnchorConstraint?.constant = Constants.inset/2
        //mainView.mainStack.customLeadingAnchorConstraint?.constant = Constants.inset/2
        //mainView.mainStack.customTrailingAnchorConstraint?.constant = -Constants.inset/2
        
        mainView.mainStack.addArrangedSubview(recommendationCV)
        recommendationCV.heightAnchor.constraint(equalTo: mainView.mainStack.widthAnchor, multiplier: 0.5).isActive = true
        recommendationCV.widthAnchor.constraint(equalTo: mainView.mainStack.widthAnchor).isActive = true
        recommendationCV.register(RecoSleepCell.self, forCellWithReuseIdentifier: cellId)
        recommendationCV.delegate = self
        recommendationCV.dataSource = self
        recommendationCV.clipsToBounds = false
    }
}
