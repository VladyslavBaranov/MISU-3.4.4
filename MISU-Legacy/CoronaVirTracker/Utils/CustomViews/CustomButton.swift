//
//  CustomButton.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 31.03.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class ImageTitleButton: UIButton {    
    var imagePosition: ImagePosition? {
        didSet {
            guard let newValue = imagePosition else { return }
            setUpImage(newValue)
        }
    }
    
    var imageName: String
    
    init(title: String, imageName imgn: String, imagePosition imgPos: ImagePosition) {
        imageName = imgn
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setTitle(title, for: .normal)
        setUp()
        //setUpImag
    }
    
    func setUpImage(name: String = "Title",
                    imageEdgeInsets iei: UIEdgeInsets = .zero, height hImg: CGFloat?,
                    renderAs: UIImage.RenderingMode = .automatic) {
        var img = UIImage(named: name)?.withRenderingMode(renderAs)
        if let imgScale = hImg {
            img = img?.scaleTo(CGSize(width: imgScale*(img?.imageWidthToHeightMultiplier() ?? 1), height: imgScale))
        }
        self.setImage(img, for: .normal)
        self.imageEdgeInsets = iei
    }
    
    func setUp(color: UIColor = UIColor.appDefault.red,
               fontSize: CGFloat = 14, textColor: UIColor = .white,
               disabledTextColor: UIColor = .lightGray, textAlignment: NSTextAlignment = .center,
               shadow: Bool = true, customContentEdgeInsets: Bool = true,
               setCustomCornerRadius stCustRad: Bool = true, tintColor tntclr: UIColor? = nil) {
        backgroundColor = color
        stCustRad ? setCustomCornerRadius() : pass
        titleLabel?.textAlignment = textAlignment
        titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        setTitleColor(textColor, for: .normal)
        setTitleColor(disabledTextColor, for: .disabled)
        if let tc = tntclr {
            tintColor = tc
        }
        
        if customContentEdgeInsets {
            contentEdgeInsets = .init(top: standartInset*0.75, left: standartInset,
                                      bottom: standartInset*0.75, right: standartInset)
        }
        addTapCustomAnim()
        shadow ? addCustomShadow() : pass
    }
    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//
//        addEditImage = false
//        let const = standartInset/2
//        imageEdgeInsets = .init(top: const, left: const, bottom: const, right: const)
//        imageView?.contentMode = .scaleAspectFit
//        textLabel?.textColor = .gray
//        detailTextLabel?.textColor = .black
//    }
    
    //private var needSetUp: Bool = true
    
    override func layoutSubviews() {
        super.layoutSubviews()
        /*guard let insets = imageEdgeInsets else {
            let const = standartInset/2
            imageEdgeInsets = .init(top: const, left: const, bottom: const, right: const)
            return
        }
        setImageInsets(insets)*/
    }
    
    func setUpImage(_ iPos: ImagePosition) {
        
    }
    /*
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
    } */
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
