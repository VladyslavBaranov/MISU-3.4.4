//
//  StatePopoverView.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 13.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class StatePopoverView: UIViewController {
    let stackView: UIStackView = .createCustom(axis: .vertical, distribution: .fillEqually , spacing: 8)
    let titleLabels: [UILabel] = {
        var tt: [UILabel] = []
        HealthStatusEnum.allCases.forEach { st in
            tt.append(.createTitle(text: st.localized, fontSize: 16, color: .black, alignment: .center))
        }
        return tt
    }()
    let switchViews: [UISwitch] = {
        var tt: [UISwitch] = []
        HealthStatusEnum.allCases.forEach { st in
            let sw = UISwitch()
            sw.addTarget(self, action: #selector(switcherAction(_:)), for: .valueChanged)
            sw.isOn = PatientsVCStructEnum.selectedStates.firstIndex(of: st) != nil
            tt.append(sw)
        }
        return tt
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .popover
    }
    
    override func loadView() {
        view = stackView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    @objc func switcherAction(_ sender: UISwitch) {
        guard let index = switchViews.firstIndex(of: sender) else { return }
        guard let hStat = HealthStatusEnum.getBy(id: index) else { return }
        if sender.isOn {
            if PatientsVCStructEnum.selectedStates.firstIndex(of: hStat) == nil {
                PatientsVCStructEnum.selectedStates.append(hStat)
            }
        } else {
            PatientsVCStructEnum.selectedStates.removeAll(where: { $0 == hStat })
        }
        PatientsVCStructEnum.patientsSortingDelegate?.statesChanged(PatientsVCStructEnum.selectedStates)
    }
    
    func setUpViews() {
        var stVvs: [UIStackView] = []
        HealthStatusEnum.allCases.forEach { st in
            stVvs.append(.createCustom(axis: .horizontal, spacing: 8))
        }
        
        stVvs.enumerated().forEach { index, vw in
            guard let sw = switchViews[safe: index], let tt = titleLabels[safe: index] else { return }
            vw.addArrangedSubview(sw)
            vw.addArrangedSubview(tt)
            vw.contentMode = .left
            //vw.distribution = .
            stackView.addArrangedSubview(vw)
        }
        self.loadViewIfNeeded()
        stackView.contentMode = .left
        stackView.alignment = .leading
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: view.standartInset,
                                                                     leading: view.standartInset/2,
                                                                     bottom: view.standartInset,
                                                                     trailing: view.standartInset/2)
        
        let labelWidts = titleLabels.map { lb -> CGFloat in
            return lb.frame.width
        }
        
        let h: CGFloat = CGFloat(stVvs.count) * (switchViews.first?.frame.height ?? 1) + 48
        let w: CGFloat = (switchViews.first?.frame.width ?? 0) + view.standartInset*3 + (labelWidts.max() ?? 0)
        preferredContentSize = .init(width: w, height: h)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
