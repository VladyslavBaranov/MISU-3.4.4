//
//  ShortInfoView.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 3/20/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation
import UIKit

class ShortInfoView: UIView {
    let contentView: UIView = {
        let vw = UIView()
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.backgroundColor = .white
        vw.setCustomCornerRadius()
        vw.addCustomShadow()
        //vw.isHidden = true
        return vw
    }()
    
    var imageView: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.image = UIImage(named: "notApprovedDocStatus")
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        return img
    }()
    
    var title: UILabel = {
        let tl = UILabel()
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.textAlignment = .left
        tl.font = UIFont.systemFont(ofSize: 18)
        tl.numberOfLines = 2
        tl.text = "Title"
        return tl
    }()
    
    var subTitle: UILabel = {
        let tl = UILabel()
        tl.translatesAutoresizingMaskIntoConstraints = false
        tl.textAlignment = .left
        tl.textColor = .lightGray
        tl.font = UIFont.systemFont(ofSize: 14)
        tl.text = "Subtitle"
        return tl
    }()
    
    var parentView: UIView
    
    var doctor: UserModel? {
        didSet {
            guard let doc = doctor else { return }
            
            title.text = doc.doctor?.fullName
            subTitle.text = doc.doctor?.docPost?.name
            //imageView.image = doc.doctor.image
        }
    }
    
    var hospital: HospitalModel? {
        didSet {
            //print("### shorw view \(String(describing: hospital))")
            guard let hosp = hospital else { return }
            title.text = hosp.fullName
            subTitle.text = hosp.location?.getFullLocationStr(withName: false)
            imageView.image = hosp.customImage
            
            show()
        }
    }
    
    init(parentView: UIView) {
        self.parentView = parentView
        
        super.init(frame: CGRect(origin: CGPoint(x: 0, y: 999), size: .zero))
        
        initSetUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSetUp() {
        self.translatesAutoresizingMaskIntoConstraints = false
        //self.backgroundColor = .white
        //self.setCustomCornerRadius()
        //self.addCustomShadow()
        //self.isHidden = true
        
        parentView.addSubview(self)
        self.addSubview(contentView)
        contentView.addSubview(imageView)
        contentView.addSubview(title)
        contentView.addSubview(subTitle)
        
        self.heightAnchor.constraint(greaterThanOrEqualToConstant: contentView.standartInset*2).isActive = true
        self.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: self.standartInset).isActive = true
        self.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -self.standartInset).isActive = true
        self.customBottomAnchorConstraint = self.bottomAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor, constant: -self.standartInset)
        self.customBottomAnchorConstraint?.isActive = false
        self.customTopAnchorConstraint = self.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor, constant: self.standartInset)
        self.customTopAnchorConstraint?.isActive = true
        
        contentView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: contentView.standartInset).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: title.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: subTitle.bottomAnchor).isActive = true
        
        title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: contentView.standartInset).isActive = true
        title.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: contentView.standartInset/2).isActive = true
        title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -contentView.standartInset).isActive = true
        title.setContentHuggingPriority(UILayoutPriority(1001), for: .vertical)
        
        subTitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: contentView.standartInset/2).isActive = true
        subTitle.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: contentView.standartInset/2).isActive = true
        subTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -contentView.standartInset).isActive = true
        subTitle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -contentView.standartInset).isActive = true
        subTitle.setContentHuggingPriority(UILayoutPriority(1001), for: .vertical)
        
        self.isHidden = true
    }
}



// MARK: - View Show and Hide
extension ShortInfoView {
    func show() {
        self.isHidden = false
        self.animateShow(duration: 0.1)
        self.animateChangeConstraints(deactivate: self.customTopAnchorConstraint, activate: self.customBottomAnchorConstraint, duration: 0.3)
//        contentView.animateMove(y: parentView.frame.height, duration: 0) { _ in
//            self.contentView.isHidden = false
//            self.contentView.animateMove(y: 0, duration: 0.3)
//        }
    }
    
    func hide() {
        self.animateFade(duration: 0.4)
        self.animateChangeConstraints(deactivate: self.customBottomAnchorConstraint, activate: self.customTopAnchorConstraint, duration: 0.3) { _ in
            //self.isHidden = true
            //DispatchQueue.main.async { self.removeFromSuperview() }
        }
//        contentView.animateMove(y: parentView.frame.height, duration: 0.3) { _ in
//            self.removeFromSuperview()
//        }
    }
}



// MARK: - View touches overrides
extension ShortInfoView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.animateScaleTransform(x: 0.9, y: 0.9, duration: 0.1)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.animateScaleTransform(x: 1, y: 1, duration: 0.1)
        if !isTouchMovedOut {
            goToProfileAfterTap()
        }
        isTouchMovedOut = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if isTouchMoveOut(touch: touch) {
            isTouchMovedOut = true
            self.animateScaleTransform(x: 1, y: 1, duration: 0.1)
        }
    }
}



// MARK: - Other Methods
extension ShortInfoView {
    func goToProfileAfterTap() {
        if let hosp = hospital {
            let vc = HospitalVC()
            vc.hospital = hosp
            //print("### go to \(hosp)")
            navigationController()?.pushViewController(vc, animated: true)
        }
        
        if let doc = doctor {
            let vc = ProfileVC()
            vc.setUser(doc, isCurrent: false)
            navigationController()?.pushViewController(vc, animated: true)
        }
    }
}
