//
//  GeneralInfoDoctorEditView.swift
//  CoronaVirTracker
//
//  Created by WH ak on 18.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class GeneralInfoDoctorEditView: EditView {
    let statusLabel: UILabel = .createTitle(text: NSLocalizedString("Profile will be approved after verifying your information", comment: ""), fontSize: 14, color: .lightGray, alignment: .left)
    let statusImageView: UIImageView = .makeImageView("greenHealthPin")
    
    let docPostLabel: UILabel = .createTitle(text: NSLocalizedString("Your position in the hospital:", comment: ""), fontSize: 14, color: .darkText, alignment: .center)
    let docPostPiker: UIPickerView = .createPickerView()
    
    let locationButton: UIButton = .createCustomButton(title: "Location", color: .white, fontSize: 16, shadow: false)
    
    var docPostPikerValue: DoctorPositionModel? {
        set {
            guard let newPost = newValue else { return }
            guard let cellId = ListDHUSingleManager.shared.doctorPosts.firstIndex(where: {$0.id == newPost.id}) else { return }
            docPostPiker.selectRow(cellId, inComponent: 0, animated: true)
        }
        get {
            let row = docPostPiker.selectedRow(inComponent: 0)
            return ListDHUSingleManager.shared.doctorPosts[safe: row]
        }
    }
    
    var hospitalButtonValue: LocationModel? {
        didSet {
            guard let location = hospitalButtonValue else { return }
            self.locationButton.setTitle(location.getFullLocationStr(), for: .normal)
        }
    }
    
    var locationButtonValue: HospitalModel? {
        didSet {
            guard let location = locationButtonValue else { return }
            self.locationButton.setTitle(location.fullName, for: .normal)
        }
    }
}
 


// MARK: - Overrides
extension GeneralInfoDoctorEditView {
    override func setUpAdditionalViews() {
        setUpStatusViews()
        setUpWorkPost()
        setUpLocationButton()
        
        dataSetUp()
    }
    
    override func saveAction() -> Bool {
        if UCardSingleManager.shared.user.doctor?.docPost != docPostPikerValue {
            let old = UCardSingleManager.shared.user
            UCardSingleManager.shared.user.doctor?.docPost = docPostPikerValue
            //UCardSingleManager.shared.user.doctor?.docPostModel = HospitalWorkPostModel(id: docPostPikerValue?.getId(), name: nil, language: nil)
            UCardSingleManager.shared.saveCurrUser(oldUser: old, requestToSave: true) { success in
                if success { DispatchQueue.main.async { self.completionAction?(true) } }
            }
        }
        return true
    }
}
    


// MARK: - Recognizer Actions
extension GeneralInfoDoctorEditView {
    @objc func locationButtonAction() {
        let citySelector = HospitalSelectView(frame: self.frame)
        citySelector.show { _ in
            self.dataSetUp()
        }
    }
}



// MARK: - Other methods
extension GeneralInfoDoctorEditView {
}



// MARK: - Additional views set up
extension GeneralInfoDoctorEditView {
    private func dataSetUp() {
        statusImageView.image = UCardSingleManager.shared.user.doctor?.getStatusImage()
        statusLabel.text = UCardSingleManager.shared.user.doctor?.getStatusTitle()
        docPostPikerValue = UCardSingleManager.shared.user.doctor?.docPost
        locationButtonValue = UCardSingleManager.shared.user.doctor?.hospitalModel
    }
    
    private func setUpStatusViews() {
        contentView.addSubview(statusImageView)
        contentView.addSubview(statusLabel)
        
        statusImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standartInset).isActive = true
        statusImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        statusImageView.heightAnchor.constraint(equalTo: statusLabel.heightAnchor, multiplier: 1.3).isActive = true
        statusImageView.widthAnchor.constraint(equalTo: statusImageView.heightAnchor).isActive = true
        
        statusLabel.numberOfLines = 2
        statusLabel.centerYAnchor.constraint(equalTo: statusImageView.centerYAnchor).isActive = true
        statusLabel.leadingAnchor.constraint(equalTo: statusImageView.trailingAnchor, constant: standartInset/2).isActive = true
        statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        statusLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1001), for: .horizontal)
    }
    
    private func setUpWorkPost() {
        contentView.addSubview(docPostLabel)
        contentView.addSubview(docPostPiker)
        
        docPostLabel.topAnchor.constraint(equalTo: statusImageView.bottomAnchor, constant: standartInset).isActive = true
        docPostLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        docPostLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        
        docPostPiker.delegate = self
        docPostPiker.dataSource = self
        docPostPiker.topAnchor.constraint(equalTo: docPostLabel.bottomAnchor, constant: standartInset/2).isActive = true
        docPostPiker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        docPostPiker.heightAnchor.constraint(equalToConstant: standartInset*8).isActive = true
        docPostPiker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
    }
    
    private func setUpLocationButton() {
        contentView.addSubview(locationButton)
        
        locationButton.addTarget(self, action: #selector(locationButtonAction), for: .touchUpInside)
        locationButton.topAnchor.constraint(equalTo: docPostPiker.bottomAnchor, constant: standartInset).isActive = true
        locationButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        locationButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        locationButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset/2).isActive = true
    }
}
