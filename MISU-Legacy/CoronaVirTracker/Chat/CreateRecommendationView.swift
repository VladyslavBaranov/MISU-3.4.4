//
//  CreateRecommendationView.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 18.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//  mimimi

import UIKit

class CreateRecommendationView: EditView {
    let titleLabel: UILabel = .createTitle(text: NSLocalizedString("Your recommendations for patient", comment: ""), fontSize: 14, color: .black, alignment: .center)
    let valueTextField: UITextView = {
        let tf = UITextView()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = .systemFont(ofSize: 16)
        tf.cornerRadius = 10
        tf.addBorder(radius: 1, color: .lightGray)
        return tf
    }()
    
    let imageView: UIImageView = .makeImageView("AddImageIcon", contentMode: .scaleAspectFit)
    var selectedImage: UIImage?
    let imagePickerController = UIImagePickerController()
    var parentVC: UIViewController?
    
    var reccmmendationModel: SendMessage? {
        get {
            guard let mssg = valueTextField.text else { return nil }
            if mssg.isEmpty, selectedImage == nil { return nil }
            return .init(sender: UCardSingleManager.shared.user.id, message: mssg, recom: true, img: selectedImage)
        }
    }
}



// MARK: - Overrides
extension CreateRecommendationView {
    override func setUpAdditionalViews() {
        imagePickerController.delegate = self
        saveButton.setTitle(NSLocalizedString("Send", comment: ""), for: .normal)
        setUpSubViews()
    }
    
    override func saveAction() -> Bool {
        return true
    }
}



// MARK: - keyboard observer methods
extension CreateRecommendationView {
    override func keyboardWillShowAction(keyboardFrame: CGRect) {
        cancelButton.animateConstraint(cancelButton.customBottomAnchorConstraint, constant: -keyboardFrame.height+cancelButton.frame.height, duration: 0.3)
    }
    
    override func keyboardWillHideAction() {
        cancelButton.animateConstraint(cancelButton.customBottomAnchorConstraint, constant: -standartInset, duration: 0.3)
    }
}



// MARK: - Actions
extension CreateRecommendationView {
    @objc func selectImageAction() {
        imagePickerController.allowsEditing = true
        
        let imageSourceTypeController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        imageSourceTypeController.popoverPresentationController?.sourceView = self
        let galeryAction = UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.imagePickerController.sourceType = .photoLibrary
            self.parentVC?.present(self.imagePickerController, animated: true)
        })
        galeryAction.customImage = UIImage(named: "QuickActions_Search")
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.imagePickerController.sourceType = .camera
            self.parentVC?.present(self.imagePickerController, animated: true)
        })
        cameraAction.customImage = UIImage(named: "QuickActions_CapturePhoto")
        
        let deleteAction = UIAlertAction(title: "Delete photo", style: .destructive, handler: { _ in
            self.selectedImage = nil
            self.imageView.image = UIImage(named: "cameraTemplateImage")
        })
        deleteAction.customImage = UIImage(named: "Navigation_Trash")
        
        imageSourceTypeController.addAction(galeryAction)
        imageSourceTypeController.addAction(cameraAction)
        imageSourceTypeController.addAction(deleteAction)
        
        imageSourceTypeController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        print("### qwertyuiop[")
        parentVC?.present(imageSourceTypeController, animated: true)
    }
}



extension CreateRecommendationView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if var imageEdited = info[.editedImage] as? UIImage, let imageOrigin = info[.originalImage] as? UIImage {
            if imageOrigin.size.width < imageEdited.size.width || imageOrigin.size.height < imageEdited.size.height {
                imageEdited = imageOrigin
            }
            selectedImage = imageEdited
            imageView.image = imageEdited
        }
        parentVC?.dismiss(animated: true, completion: nil)
    }
}



// MARK: - Additional views set up
// don't do this
extension CreateRecommendationView {
    private func setUpSubViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueTextField)
        contentView.addSubview(imageView)
        
        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standartInset).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        
        valueTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: standartInset).isActive = true
        valueTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        valueTextField.heightAnchor.constraint(equalToConstant: (valueTextField.font?.lineHeight ?? standartInset) * 8).isActive = true
        valueTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standartInset).isActive = true
        //valueTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset).isActive = true
        
        imageView.topAnchor.constraint(equalTo: valueTextField.bottomAnchor, constant: standartInset).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standartInset).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: standartInset*4).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: standartInset*4).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standartInset).isActive = true
        imageView.setCustomCornerRadius()
        imageView.addCustomShadow()
        imageView.addTapRecognizer(self, action: #selector(selectImageAction))
    }
}
