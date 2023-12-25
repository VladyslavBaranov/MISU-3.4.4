//
//  HParamsCListVC.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 20.03.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class HParamsCListVC: UIViewController {
    let hParamsTV: UITableView = .createTableView()
    var userModel: UserModel? = nil
    
    var updatindCount: Int = 0 {
        didSet {
            if updatindCount < 0 {
                updatindCount = 0
            }
            if updatindCount == 0 {
                enableViewsAfterReqest()
            }
            if updatindCount == 1, oldValue == 0 {
                navigationItem.titleView = UIView()
                prepareViewsBeforReqest(activityView: navigationItem.titleView)
            }
        }
    }
    
    init(userModel um: UserModel?) {
        super.init(nibName: nil, bundle: nil)
        userModel = um
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// MARK: - View loads Overrides
extension HParamsCListVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetUp()
        setUpNavigationView()
        setUpSubViews()
        updateParams()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateParams()
    }
}



// MARK: - Actions
extension HParamsCListVC: RequestUIController {
    func uniqeKeyForStore() -> String? {
        return view.getAddress()
    }
    
    func updateParams() {
        guard let uid = userModel?.profile?.id else { return }
        HealthParamsEnum.headerParams.allCases.forEach { pType in
            HealthParamsEnum.StaticticRange.allCases.forEach { htRange in
                updatindCount += 1
                HealthDataController.shared.updateIndicatorOf(
                    profileId: uid,
                    type: pType.healthParamStruct,
                    range: htRange)
                { hType, hIndicators in
                    self.updatindCount -= 1
                    DispatchQueue.main.async {
                        if let row = hType.headersParamEnum()?.index {
                            self.hParamsTV.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
                        } else {
                            self.hParamsTV.reloadData()
                        }
                    }
                }
            }
        }
    }
}



// MARK: - Scroll view overloads
extension HParamsCListVC: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let yDownToRefresh: CGFloat = -80
        if scrollView.contentOffset.y < yDownToRefresh {
            updateParams()
        }
    }
}



// MARK: - TableView Delegate, DataSource
extension HParamsCListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return HeadersParamEnum.allCases.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.width
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let hCase = HeadersParamEnum.allCases[safe: indexPath.row] ?? .bloodOxygen
        guard let cell = tableView.dequeueReusableCell(withIdentifier: hCase.key, for: indexPath) as? WatchChartTVCell else {
            return tableView.dequeueReusableCell(withIdentifier: "qwe", for: indexPath)
        }
        cell.userProfId = userModel?.profile?.id ?? -1
        cell.healthType = hCase
        
        guard let uid = userModel?.profile?.id else { return cell }
        cell.historicalIndicators = HealthDataController.shared.indicatorsCachedUId[uid]?[hCase.healthParamStruct] ?? [:]
        
        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView()
        return v
    }
}



// MARK: - View Setups
extension HParamsCListVC {
    func setUpSubViews() {
        view.addSubview(hParamsTV)

        hParamsTV.delegate = self
        hParamsTV.dataSource = self
        hParamsTV.separatorColor = .clear
        hParamsTV.backgroundColor = UIColor.appDefault.lightGrey
        
        hParamsTV.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        hParamsTV.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        hParamsTV.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        hParamsTV.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        HeadersParamEnum.allCases.forEach { hpCase in
            hParamsTV.register(WatchChartTVCell.self, forCellReuseIdentifier: hpCase.key)
        }
        hParamsTV.register(UITableViewCell.self, forCellReuseIdentifier: "qwe")
    }
    
    func viewSetUp() {
        view.backgroundColor = .white
    }

    func setUpNavigationView() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
