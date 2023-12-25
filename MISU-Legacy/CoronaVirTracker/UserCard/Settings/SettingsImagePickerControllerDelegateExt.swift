//
//  SettingsImagePickerControllerDelegateExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 15.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension SettingsVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if var imageEdited = info[.editedImage] as? UIImage, let imageOrigin = info[.originalImage] as? UIImage {
            if imageOrigin.size.width < imageEdited.size.width || imageOrigin.size.height < imageEdited.size.height {
                imageEdited = imageOrigin
            }
            
            editedUserModel?.profile?.image = imageEdited
            editedUserModel?.doctor?.image = imageEdited
            
            self.settingsTableView.reloadData()
        }
        
        dismiss(animated: true, completion: nil)
    }
}
