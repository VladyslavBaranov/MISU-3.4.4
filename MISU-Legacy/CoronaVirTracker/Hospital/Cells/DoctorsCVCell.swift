//
//  DoctorsCVCell.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 08.04.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class DoctorsCVCell: CustomCVCell {
    let leftTitle: UILabel = .createTitle(text: NSLocalizedString("Doctors", comment: ""), fontSize: 16, color: .lightGray)
    let mainTV: UITableView = .createTableView()
    let cellId: String = "doctorsCellId"
    
    var doctors: [UserModel] {
        didSet {
            mainTV.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        doctors = []
        super.init(frame: frame)
        
        setUp()
    }
    
    func setUp() {
        backgroundColor = .white
        setCustomCornerRadius()
        addCustomShadow()
        
        addSubview(leftTitle)
        addSubview(mainTV)
        
        leftTitle.topAnchor.constraint(equalTo: topAnchor, constant: standartInset).isActive = true
        leftTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: standartInset).isActive = true
        leftTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -standartInset).isActive = true
        
        mainTV.topAnchor.constraint(equalTo: leftTitle.bottomAnchor, constant: standartInset).isActive = true
        mainTV.leadingAnchor.constraint(equalTo: leadingAnchor, constant: standartInset).isActive = true
        mainTV.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -standartInset).isActive = true
        mainTV.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -standartInset).isActive = true
        
        mainTV.delegate = self
        mainTV.dataSource = self
        mainTV.separatorStyle = .none
        mainTV.register(SubtitleTVCell.self, forCellReuseIdentifier: cellId)
    }
    
    override func getSize(cv: UICollectionView) -> CGSize {
        return .init(width: cv.frame.width - cv.standartInset,
                     height: cv.frame.width/2)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DoctorsCVCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doctors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.text = doctors[safe: indexPath.row]?.doctor?.fullName ?? "-"
        cell.detailTextLabel?.text = doctors[safe: indexPath.row]?.doctor?.docPost?.name ?? "-"
        if let imgUrl = doctors[safe: indexPath.row]?.doctor?.imageURL {
            cell.imageView?.setImage(url: imgUrl, resize: .init(width: standartInset*2,
                                                                height: standartInset*2))
        }
        cell.imageView?.setRounded()
        
        cell.selectionStyle = .none
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ProfileVC()
        vc.setUser(doctors[safe: indexPath.row], isCurrent: false)
        controller()?.navigationController?.pushViewController(vc, animated: true)
    }
}

