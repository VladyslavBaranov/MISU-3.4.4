//
//  IllnessHistoryVC.swift
//  CoronaVirTracker
//
//  Created by WH ak on 22.08.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class IllnessHistoryVC: UIViewController {
    let customIllnesCellId = "customIllnesCellId"
    let mainCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.alwaysBounceVertical = true
        cv.alwaysBounceHorizontal = false
        cv.backgroundColor = UIColor.appDefault.lightGrey
        
        return cv
    }()
    
    var illnessHistoryDataList: [IllnessModel] = []
        //.init(id: 0, name: ListDHUSingleManager.shared.illnessList.randomElement()?.name ?? "-", confirmed: .doctor, state: .chronic, date: Date()),
        //.init(id: 1, name: ListDHUSingleManager.shared.illnessList.randomElement()?.name ?? "-", confirmed: .analyzes, state: .cured, date: Date()),
        //.init(id: 2, name: ListDHUSingleManager.shared.illnessList.randomElement()?.name ?? "-", confirmed: .notConfirmed, state: .ill, date: Date()),
        //.init(id: 3, name: ListDHUSingleManager.shared.illnessList.randomElement()?.name ?? "-", confirmed: .doctor, state: .chronic, date: Date()),
        //.init(id: 4, name: ListDHUSingleManager.shared.illnessList.randomElement()?.name ?? "-", confirmed: .analyzes, state: .cured, date: Date()),
        //.init(id: 5, name: ListDHUSingleManager.shared.illnessList.randomElement()?.name ?? "-", confirmed: .notConfirmed, state: .ill, date: Date())

    var sortedByStateDataList: [IllnessStateEnum:[IllnessModel]] = [:]
    
    var userModel: UserModel?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    init(user: UserModel?) {
        super.init(nibName: nil, bundle: nil)
        userModel = user
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// MARK: - View loads Overrides
extension IllnessHistoryVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewSetUp()
        setUpNavigationView()
        setUpCollectionView()
        updateData()
    }
}



// MARK: - Scroll View
extension IllnessHistoryVC {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let yDownToRefresh: CGFloat = -80
        if scrollView.contentOffset.y < yDownToRefresh {
            updateData()
        }
    }
}
    
    

// MARK: - Actions
extension IllnessHistoryVC {
    @objc func addParameterAction() {
        let addSIView = IllnessCreateView(frame: view.frame)
        addSIView.show { _ in
            guard let newIll = addSIView.illnessModel else { return }
            MedicalHistoryManager.shared.createIllness(newIll) { (illness_, error_) in
                if let illness = illness_ {
                    print("### create illness success \(illness)")
                    self.illnessHistoryDataList.append(illness)
                    DispatchQueue.main.async { self.sortIllnessData() }
                }
                
                if let error = error_ {
                    ModalMessagesController.shared.show(message: error.getInfo(), type: .error)
                    //print("### illness error \(error)")
                }
            }
        }
    }
}



// MARK: - Others
extension IllnessHistoryVC: RequestUIController {
    func uniqeKeyForStore() -> String? {
        return view.getAddress()
    }
    func updateIllness(illness illOp: IllnessModel?) {
        guard let illness = illOp else { return }
        let addSIView = IllnessCreateView(frame: view.frame, illnessModel: illness)
        addSIView.show { _ in
            guard let ill = addSIView.illnessModel else { return }
            MedicalHistoryManager.shared.updateIllness(ill) { (illness_, error_) in
                if let illness = illness_ {
                    print("### update illness success \(illness)")
                    self.updateData()
                }
                
                if let error = error_ {
                    ModalMessagesController.shared.show(message: error.getInfo(), type: .error)
                    //print("### update illness error \(error)")
                }
            }
        }
    }
    
    func deleteIllness(illness illOp: IllnessModel?) {
        guard let illness = illOp else { return }
        prepareViewsBeforReqest(viewsToBlock: [], activityView: mainCollectionView)
        MedicalHistoryManager.shared.deleteIllness(id: illness.id) { (success, errOp) in
            self.enableViewsAfterReqest()
            if success {
                ModalMessagesController.shared.show(message: "Success ...", type: .success)
            }
            
            if let error = errOp {
                ModalMessagesController.shared.show(message: error.getInfo(), type: .error)
            }
            self.updateData()
        }
    }
    
    func updateData() {
        prepareViewsBeforReqest(viewsToBlock: [], activityView: mainCollectionView)
        MedicalHistoryManager.shared.illnessHistory(id: userModel?.profile?.id) { (illness_, error_) in
            self.enableViewsAfterReqest()
            if let illness = illness_ {
                print("### illness success \(illness)")
                self.illnessHistoryDataList = illness
                DispatchQueue.main.async { self.sortIllnessData() }
            }
            
            if let error = error_ {
                ModalMessagesController.shared.show(message: error.getInfo(), type: .error)
                print("### illness error \(error)")
            }
        }
    }
    
    func sortIllnessData() {
        IllnessStateEnum.allCases.forEach({ sortedByStateDataList.updateValue([], forKey: $0) })
        
        illnessHistoryDataList.forEach { illness in
            guard let st = illness.state else { return }
            sortedByStateDataList[st]?.append(illness)
        }
        
        sortedByStateDataList.forEach { state, values in
            sortedByStateDataList[state] = values.sorted(by: { (first, second) -> Bool in
                guard let firstDate = first.date else { return false }
                guard let secondDate = second.date else { return true }
                if firstDate.compare(secondDate) == .orderedDescending {
                    return true
                }
                return false
            })
        }
        
        mainCollectionView.reloadData()
    }
}



// MARK: - View Setups
extension IllnessHistoryVC {
    func viewSetUp() {
        view.backgroundColor = UIColor.appDefault.lightGrey
    }
    
    func setUpCollectionView() {
        view.addSubview(mainCollectionView)
        
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        
        mainCollectionView.register(IllnessViewCell.self, forCellWithReuseIdentifier: customIllnesCellId)
        
        mainCollectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        mainCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        mainCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        mainCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
    
    func setUpNavigationView() {
        navigationItem.title = NSLocalizedString("Medical history", comment: "")
        navigationController?.navigationBar.isTranslucent = false
        if userModel == nil {
            navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(addParameterAction))
        }
    }
}
