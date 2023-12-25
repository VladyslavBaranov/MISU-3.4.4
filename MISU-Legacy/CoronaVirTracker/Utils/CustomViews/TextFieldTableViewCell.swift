//
//  TextFieldTableViewCell.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 6/14/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: CustomTableViewCell {
    let textField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    var isImageRounded: Bool = true
    
    private var didEndEditingCompletion: ((_ text: String) -> ())? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpTextField()
        setUpImage()
    }
    
    func setUp(placeholder: String, text: String?, didEndEditing: ((_ text: String) -> ())?) {
        textField.placeholder = placeholder
        textField.text = text
        didEndEditingCompletion = didEndEditing
    }
    
    private func setUpTextField() {
        contentView.addSubview(textField)
        textField.delegate = self
        textField.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        textField.leadingAnchor.constraint(equalTo: imageView?.trailingAnchor ?? contentView.leadingAnchor, constant: standartInset*3).isActive = true
        textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUpImage()
    }
    
    private func setUpImage() {
        imageView?.contentMode = .scaleAspectFill
        imageView?.clipsToBounds = true
        if isImageRounded {
            imageView?.cornerRadius = (imageView?.frame.size.height ?? 0)/2
        } else {
            imageView?.cornerRadius = 0
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



extension TextFieldTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        didEndEditingCompletion?(text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
