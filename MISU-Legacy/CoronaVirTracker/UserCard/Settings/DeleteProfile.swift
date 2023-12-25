//
//  DeleteProfile.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 21.08.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class DeleteProfilePV: BaseEditView, RequestUIController {
    let contentStack: UIStackView = .createCustom(axis: .vertical, spacing: 24)
    let titleImage: UIImageView = .makeImageView(UIImage(named: "warningIcon")?.scaleTo(55))
    let titleLabel: UILabel = .createTitle(text: NSLocalizedString("Warning", comment: ""), fontSize: 24, weight: .semibold)
    let subTitleLabel: UILabel = .createTitle(text: NSLocalizedString("Your profile will be deleted and your data will not be possible to recover.\nAre you sure you want to continue?", comment: ""), fontSize: 16, alignment: .center, numberOfLines: 5)
    
    override func saveButtonAction(_ sender: UIButton) {
        prepareViewsBeforReqest(viewsToBlock: [cancelButton], activityButton: saveButton, activityButtonColor: .gray)
        UCardSingleManager.shared.deleteUser { success in
            self.enableViewsAfterReqest()
            
            if !success { return }
            DispatchQueue.main.async {
                super.saveButtonAction(sender)
            }
        }
    }
    
    func uniqeKeyForStore() -> String? {
        return getAddress()
    }
    
    override func setUp() {
        super.setUp()
        
        contentView.addSubview(contentStack)
        contentStack.fixedEdgesConstraints(on: contentView, inset: .init(top: standart24Inset, left: standart24Inset, bottom: standart24Inset, right: standart24Inset))
        
        contentStack.addArrangedSubview(titleImage)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(subTitleLabel)
        
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        saveButton.setTitle(NSLocalizedString("Yes, delete my profile", comment: ""), for: .normal)
        saveButton.setTitleColor(UIColor.appDefault.redNew, for: .normal)
    }
}
