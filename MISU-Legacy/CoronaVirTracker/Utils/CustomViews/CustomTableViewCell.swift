//
//  CustomTableViewCell.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 6/14/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    var imageEdgeInsets: UIEdgeInsets? {
        didSet {
            guard let newValue = imageEdgeInsets else { return }
            setImageInsets(newValue)
        }
    }
    
    var leftTextInset: CGFloat? = nil
    
    let editImageView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "cameraTemplateImage")
        img.contentMode = .scaleAspectFit
        img.tintColor = .gray
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    var addEditImage: Bool {
        set {
            editImageView.isHidden = !newValue
            if newValue {
                setUpEditImageIfNeeded()
            }
        }
        get {
            return editImageView.isHidden
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addEditImage = false
        let const = standartInset/2
        imageEdgeInsets = .init(top: const, left: const, bottom: const, right: const)
        imageView?.contentMode = .scaleAspectFit
        textLabel?.textColor = .gray
        detailTextLabel?.textColor = .black
    }
    
    private var needSetUp: Bool = true
    private func setUpEditImageIfNeeded() {
        if !needSetUp { return }
        needSetUp = !needSetUp
        guard let cellImageView = imageView else { return }
        contentView.addSubview(editImageView)
        editImageView.trailingAnchor.constraint(equalTo: cellImageView.trailingAnchor).isActive = true
        editImageView.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor).isActive = true
        editImageView.widthAnchor.constraint(equalToConstant: standartInset*0.8).isActive = true
        editImageView.heightAnchor.constraint(equalToConstant: standartInset*0.8).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let insets = imageEdgeInsets else {
            let const = standartInset/2
            imageEdgeInsets = .init(top: const, left: const, bottom: const, right: const)
            return
        }
        setImageInsets(insets)
    }
    
    private func setImageInsets(_ insets: UIEdgeInsets) {
        if imageView?.originFrame == nil {
            imageView?.frame = CGRect(origin: imageView?.frame.origin ?? .zero, size: CGSize(width: contentView.frame.size.height, height: contentView.frame.size.height))
            imageView?.originFrame = imageView?.frame
        } else if let imgFrame = imageView?.originFrame {
            imageView?.frame = imgFrame
        }
        
        let x = (imageView?.frame.origin.x ?? 0) + (leftTextInset != nil ? insets.left : 0)
        let y = (imageView?.frame.origin.y ?? 0) + insets.top
        let width = (imageView?.frame.size.width ?? 0) - insets.left - insets.right
        let height = (imageView?.frame.size.height ?? 0) - insets.top - insets.bottom
        
        imageView?.frame = CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height))
        if leftTextInset != nil {
            imageView?.frame.size.width = (imageView?.frame.height ?? 0) * (imageView?.imageWidthToHeightMultiplier() ?? 1)
            
            let newX = (imageView?.frame.origin.x ?? 0) + (imageView?.frame.width ?? 0) + insets.right
            let diff = (textLabel?.frame.origin.x ?? 0) - newX
            textLabel?.frame.origin.x = newX
            textLabel?.frame.size.width += diff
            
            //separatorInset.left -= diff
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
