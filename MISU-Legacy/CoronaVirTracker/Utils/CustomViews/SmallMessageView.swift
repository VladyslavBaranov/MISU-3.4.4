//
//  SmallMessageView.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 15.07.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class SmallMessageView: UIView {
    fileprivate static var prevView: SmallMessageView? = nil
    
    let titleLabel: UILabel = .createTitle(text: "Info text", fontSize: 14, alignment: .center, numberOfLines: 55)
    var position: NSRectAlignment = .topLeading {
        didSet {
            switch position {
            case .topLeading:
                setRoundedParticly(corners: [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner], radius: 15)
            case .topTrailing:
                setRoundedParticly(corners: [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner], radius: 15)
            default:
                cornerRadius = 15
            }
            addCustomShadow(shadowOffset: .zero, radius: 3)
        }
    }
    
    init() {
        super.init(frame: .zero)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    func showOn(_ view: UIView, anchorView: UIView, text: String, position ps: NSRectAlignment = .topLeading, edges: CGRect? = nil, secondsToFade: Double = 5) {
        SmallMessageView.prevView?.bgTapAction()
        SmallMessageView.prevView = self
        view.addSubview(self)
        view.bringSubviewToFront(self)
        titleLabel.text = text
        
        position = ps
        switch position {
        case .topLeading:
            topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: standartInset).isActive = true
            leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: standartInset).isActive = true
            trailingAnchor.constraint(equalTo: anchorView.leadingAnchor).isActive = true
            bottomAnchor.constraint(equalTo: anchorView.topAnchor).isActive = true
        case .topTrailing:
            topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: standartInset).isActive = true
            trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -standartInset).isActive = true
            leadingAnchor.constraint(equalTo: anchorView.trailingAnchor).isActive = true
            bottomAnchor.constraint(equalTo: anchorView.topAnchor).isActive = true
        default:
            bottomAnchor.constraint(equalTo: anchorView.topAnchor).isActive = true
            centerXAnchor.constraint(equalTo: anchorView.centerXAnchor).isActive = true
        }
        
        animateShow(duration: 0.3)
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsToFade) {
            self.bgTapAction()
        }
    }
    
    @objc func bgTapAction() {
        animateFade(duration: 0.3) { _ in
            self.removeFromSuperview()
        }
    }
    
    func setUp() {
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: standartInset/2).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: standartInset).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -standartInset).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -standartInset/2).isActive = true
        
        animateFade(duration: 0)
        
        addTapRecognizer(self, action: #selector(bgTapAction))
    }
}
