//
//  StandartAlertUtils.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 8/30/19.
//  Copyright © 2019 WHAR. All rights reserved.
//

import UIKit

class StandartAlertUtils: UIViewController {
    //-------------------------------------------------------------------------------------------
    // MARK: - start warning animation
    //-------------------------------------------------------------------------------------------
    
    static func emptyFieldAnimation(_ view: UIView, alertColor: UIColor) {
        let defaultColor = view.backgroundColor
        view.animateColor(alertColor, duration: 0.1) { _ in
            view.animateColor(defaultColor, duration: 1.0)
            view.animateShake(intensity: 3, duration: 0.5)
        }
    }
    
    static func startWarningAnimation(label: UILabel, text: String, color: UIColor, changeColor: [UIView]? = nil, show: [UIView]? = nil, shake: [UIView]? = nil) {
        label.text = text
        label.textColor = color
        
        if label.alpha == 1.0 {
            label.animateFade(duration: 0.3)
        }
        
        if let show = show {
            for element in show {
                element.animateShow(duration: 0.3)
            }
        }
        
        if let cColor = changeColor {
            for element in cColor {
                element.animateColor(color, duration: 0.1)
            }
        }
        
        if let shake = shake {
            for element in shake {
                element.animateShake(intensity: 3, duration: 0.5)
            }
        }
    }
    
    
    //-------------------------------------------------------------------------------------------
    // MARK: - standart alert massages
    //-------------------------------------------------------------------------------------------
    
    static func displayAlertMessageWithOk(title: String, message: String, selfObject: AnyObject) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "Ok", style: .default) {
                (action: UIAlertAction!) in
                //canShow = true
                print("Ok tapped ...")
            }
            alertController.addAction(OKAction)
            selfObject.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    //-------------------------------------------------------------------------------------------
    // MARK: - start and stop standart activiti process view
    //-------------------------------------------------------------------------------------------
    
    static func startAndReturnActivityProcessViewOn(view: UIView, style: UIActivityIndicatorView.Style) -> UIActivityIndicatorView {
        // Don`t forget to stop this procces view ;)
        
        let activityIndicator = UIActivityIndicatorView(style: style)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = false
        activityIndicator.startAnimating()
        
        view.addSubview(activityIndicator)
        return activityIndicator
    }
    
    static func startAndReturnActivityProcessViewOn(center view: UIView?, style: UIActivityIndicatorView.Style, color: UIColor) -> UIActivityIndicatorView? {
        guard let center = view else { return nil }
        // Don`t forget to stop this procces view ;)
        
        let activityIndicator = UIActivityIndicatorView(style: style)
        activityIndicator.color = color
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = false
        center.addSubview(activityIndicator)
        
        let xCenterConstraint = NSLayoutConstraint(item: center, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        center.addConstraint(xCenterConstraint)
        let yCenterConstraint = NSLayoutConstraint(item: center, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        center.addConstraint(yCenterConstraint)
        
        activityIndicator.startAnimating()
        return activityIndicator
    }
    
    static func stopActivityProcessView(activityIndicator: UIActivityIndicatorView?) {
        DispatchQueue.main.async {
            activityIndicator?.stopAnimating()
            activityIndicator?.removeFromSuperview()
        }
    }
    
}
