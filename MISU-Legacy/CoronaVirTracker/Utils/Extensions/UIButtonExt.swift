//
//  UIButtonExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 22.04.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

struct AddImageModel {
    var name: String
    var renderAs: UIImage.RenderingMode
    var height: CGFloat?
    var space: CGFloat
    var position: UIButton.ImagePosition
    var contentVerticalAlignment: UIControl.ContentVerticalAlignment
    var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment
    
    init(name: String = "name",
         renderAs: UIImage.RenderingMode = .automatic,
         height: CGFloat? = nil,
         space: CGFloat = 8,
         position: UIButton.ImagePosition = .left,
         contentVerticalAlignment: UIControl.ContentVerticalAlignment = .center,
         contentHorizontalAlignment: UIControl.ContentHorizontalAlignment = .center) {
        self.name = name
        self.renderAs = renderAs
        self.height = height
        self.space = space
        self.position = position
        self.contentVerticalAlignment = contentVerticalAlignment
        self.contentHorizontalAlignment = contentHorizontalAlignment
    }
}

class CoolButton: UIButton {
    init(title: String = "Title", fontSize: CGFloat = 14, textColor: UIColor? = nil, tintColor tc: UIColor = .white,
         color: UIColor = .appDefault.red, shadow: Bool = false, cornerRadius cr: CGFloat = Constants.cornerRadius,
         customContentEdgeInsets: UIEdgeInsets? = .init(top: Constants.inset/4, left: Constants.inset/2, bottom: Constants.inset/4, right: Constants.inset/2),
         image addImageModel: AddImageModel? = nil) {
        super.init(frame: .zero)
        //super.init(type: .roundedRect)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = color
        cornerRadius = cr
        
        titleLabel?.textAlignment = .center
        titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        if let tc = textColor {
            setTitleColor(tc, for: .normal)
        }
        setTitle(title, for: .normal)
        
        if let cce = customContentEdgeInsets {
            contentEdgeInsets = cce
        }
        
        if shadow {
            addCustomShadow()
        }
        
        addTapCustomAnim()
        
        if let aim = addImageModel {
            addImage(name: aim.name,
                     renderAs: aim.renderAs,
                     height: aim.height,
                     space: aim.space,
                     position: aim.position,
                     contentVerticalAlignment: aim.contentVerticalAlignment,
                     contentHorizontalAlignment: aim.contentHorizontalAlignment)
        }
        
        tintColor = tc
        imageView?.tintColor = tc
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIButton {
    func startActivity(style: UIActivityIndicatorView.Style, color col_: UIColor = .white) {
        self.isEnabled = false
        self.originText = self.titleLabel?.text
        //self.originControlState = self.state
        self.originImage = self.imageView?.image
        self.setTitle("", for: .normal)
        self.setImage(nil, for: .normal)
        StandartAlertUtils.stopActivityProcessView(activityIndicator: originActivityView)
        originActivityView = StandartAlertUtils.startAndReturnActivityProcessViewOn(center: self, style: style, color: col_)
    }
    
    func stopActivity() {
        StandartAlertUtils.stopActivityProcessView(activityIndicator: originActivityView)
        DispatchQueue.main.async {
            self.isEnabled = true
            self.setTitle(self.originText, for: self.state)
            self.setImage(self.originImage, for: self.state)
        }
    }
}

extension UIButton {
    func removeAllTargets() {
        removeTarget(nil, action: nil, for: .allEvents)
    }
    
    func addTapCustomAnim() {
        self.addTarget(self, action: #selector(touchEnter), for: [.touchDown, .touchDragEnter])
        self.addTarget(self, action: #selector(touchUp), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
        //self.addTarget(self, action: #selector(touch), for: .primaryActionTriggered)
    }

    @objc fileprivate func touchEnter() {
        self.animateScaleTransform(x: 0.9, y: 0.9, duration: 0.05)
    }
    
    /*@objc fileprivate func touch() {
        self.animateScaleTransform(x: 0.9, y: 0.9, duration: 0.05) { _ in
            self.animateScaleTransform(x: 1, y: 1, duration: 0.1)
        }
    }*/
    
    @objc fileprivate func touchUp() {
        self.animateScaleTransform(x: 1, y: 1, duration: 0.1)
    }
    
    func makeRounded() {
        self.cornerRadius = self.frame.height/2
    }
}

class CustomButton: UIButton {
    override var intrinsicContentSize: CGSize {
        return titleLabel?.intrinsicContentSize ?? super.intrinsicContentSize
    }
}

extension UIButton {
    enum ImagePosition {
        case top
        case bottom
        case left
        case right
    }
    
    var minHeight: CGFloat {
        return 40
    }
    
    var minWidth: CGFloat {
        return 40
    }
    
    static func createCustom(withImage image: UIImage? = UIImage(named: "Arrow"),
                             backgroundColor bgColor: UIColor = .clear,
                             contentEdgeInsets: UIEdgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16),
                             tintColor: UIColor = .black,
                             imageRenderingMode: UIImage.RenderingMode = .alwaysTemplate,
                             partCornerRadius: Bool = true,
                             cornerRadius: CGFloat = 8, shadow: Bool = true) -> UIButton {
        let bt = UIButton(type: UIButton.ButtonType.system)
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.backgroundColor = bgColor
        bt.contentEdgeInsets = contentEdgeInsets
        bt.setImage(image?.withRenderingMode(imageRenderingMode), for: .normal)
        bt.tintColor = tintColor
        bt.imageView?.contentMode = .scaleAspectFit
        //bt.cornerRadius = cornerRadius
        if partCornerRadius {
            bt.setRoundedParticly(corners: [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner],
                                  radius: cornerRadius)
        } else {
            bt.cornerRadius = cornerRadius
        }
        if shadow {
            bt.addCustomShadow()
        }
        return bt
    }
    /*
     var img = UIImage(named: "chatIconNew")
     let hImg = standartInset
     img = img?.scaleTo(CGSize(width: hImg*(img?.imageWidthToHeightMultiplier() ?? 1), height: hImg))
     sendMassageButton.setImage(img, for: .normal)
     sendMassageButton.tintColor = .white
     sendMassageButton.imageEdgeInsets = .zero
     */
    
    /*func addImage(name: String = "Title", imageEdgeInsets iei: UIEdgeInsets = .zero, height hImg: CGFloat?, renderAs: UIImage.RenderingMode = .automatic) {
        var img = UIImage(named: name)?.withRenderingMode(renderAs)
        if let imgScale = hImg {
            img = img?.scaleTo(CGSize(width: imgScale*(img?.imageWidthToHeightMultiplier() ?? 1), height: imgScale))
        }
        self.setImage(img, for: .normal)
        self.imageEdgeInsets = iei
    }*/
    
    func addImage(name: String = "Title",
                  renderAs: UIImage.RenderingMode = .automatic,
                  height hImg: CGFloat?, space: CGFloat = 8,
                  position: ImagePosition = .left,
                  contentVerticalAlignment cva: UIControl.ContentVerticalAlignment = .center,
                  contentHorizontalAlignment cha: UIControl.ContentHorizontalAlignment = .center) {
        var img = UIImage(named: name)?.withRenderingMode(renderAs)
        if let imgScale = hImg {
            img = img?.scaleTo(CGSize(width: imgScale*(img?.imageWidthToHeightMultiplier() ?? 1), height: imgScale))
            img = img?.withRenderingMode(renderAs)
        }
        self.setImage(img, for: .normal)
        
        self.contentVerticalAlignment = cva
        self.contentHorizontalAlignment = cha
        
        //let imgFrame: CGRect = imageView?.frame ?? .zero

        switch position {
        case .left:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: space)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: space, bottom: 0, right: -space)
            
            contentEdgeInsets = UIEdgeInsets(top: contentEdgeInsets.top, left: contentEdgeInsets.left,
                                             bottom: contentEdgeInsets.bottom, right: contentEdgeInsets.right + space)
        case .right:
            //imageEdgeInsets = UIEdgeInsets(top: 0, left: frame.width-imgFrame.width, bottom: 0, right: 0)
            //titleEdgeInsets = UIEdgeInsets(top: 0, left: -imgFrame.width, bottom: 0, right: imgFrame.width+space)
            break
        default:
            break
        }
        
        
        
        /*let w = (imageView?.frame.width ?? .zero) + (titleLabel?.frame.width ?? .zero) + contentEdgeInsets.left + contentEdgeInsets.right
        if w > frame.width {
            frame.size = .init(width: frame.width*2 - w, height: frame.height)
        }*/
    }
    
    static func createCustom(title: String = "Title", color: UIColor = UIColor.appDefault.redNew,
                             fontSize: CGFloat = 14, weight: UIFont.Weight = .regular,
                             textColor: UIColor = .white, disabledTextColor: UIColor = .lightGray,
                             shadow: Bool = true, customContentEdgeInsets: Bool = true,
                             setCustomCornerRadius stCustRad: Bool = true, tintColor: UIColor? = nil,
                             zeroInset: Bool = false, btnType: UIButton.ButtonType = .roundedRect) -> UIButton {
        let bt = zeroInset ? CustomButton(type: btnType) : UIButton(type: btnType)
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.backgroundColor = color
        if stCustRad { bt.setCustomCornerRadius() }
        bt.titleLabel?.textAlignment = .center
        bt.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        bt.setTitleColor(textColor, for: .normal)
        bt.setTitleColor(disabledTextColor, for: .disabled)
        bt.setTitle(title, for: .normal)
        if let tc = tintColor {
            bt.tintColor = tc
        }
        
        if customContentEdgeInsets {
            bt.contentEdgeInsets = .init(top: bt.standartInset*0.75, left: bt.standartInset,
                                         bottom: bt.standartInset*0.75, right: bt.standartInset)
        }
        bt.addTapCustomAnim()
        if shadow {
            bt.addCustomShadow()
        }
        
        return bt
    }
    
    static func createCustomButton(title: String = "Title", color: UIColor = UIColor.appDefault.red,
                             fontSize: CGFloat = 14, textColor: UIColor? = nil, shadow: Bool = true,
                             customContentEdgeInsets: Bool = true) -> UIButton {
        let bt = UIButton(type: UIButton.ButtonType.roundedRect)
        bt.translatesAutoresizingMaskIntoConstraints = false
        bt.backgroundColor = color
        bt.setCustomCornerRadius()
        
        bt.titleLabel?.textAlignment = .center
        bt.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        if let tc = textColor {
            bt.setTitleColor(tc, for: .normal)
        }
        bt.setTitle(title, for: .normal)
        
        if customContentEdgeInsets {
            bt.contentEdgeInsets = .init(top: bt.standartInset*0.75, left: bt.standartInset,
                                         bottom: bt.standartInset*0.75, right: bt.standartInset)
        }
        bt.addTapCustomAnim()
        if shadow {
            bt.addCustomShadow()
        }
        
        return bt
    }
}
