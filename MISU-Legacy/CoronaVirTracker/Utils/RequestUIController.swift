//
//  RequestUIController.swift
//  CoronaVirTracker
//
//  Created by WH ak on 27.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

protocol RequestUIController {
    func uniqeKeyForStore() -> String?
}

fileprivate struct ActivityViewsStore {
    static var blokedViews: [String:[UIControl]] = [:]
    static var blokedUIViews: [String:[UIView]] = [:]
    static var activityViewGlobal: [String:UIView] = [:]
    static var activityButtonGlobal: [String:UIButton] = [:]
}

extension RequestUIController {
    func setBlokedViews(_ newValue: [UIControl]) {
        guard let address = self.uniqeKeyForStore() else { return }
        ActivityViewsStore.blokedViews[address] = newValue
    }
    func getBlokedViews() -> [UIControl] {
        guard let address = self.uniqeKeyForStore() else { return [] }
        return ActivityViewsStore.blokedViews[address] ?? []
    }
    
    func setBlokedUIViews(_ newValue: [UIView]) {
        guard let address = self.uniqeKeyForStore() else { return }
        ActivityViewsStore.blokedUIViews[address] = newValue
    }
    func getBlokedUIViews() -> [UIView] {
        guard let address = self.uniqeKeyForStore() else { return [] }
        return ActivityViewsStore.blokedUIViews[address] ?? []
    }
    
    func setActivityViewGlobal(_ newValue: UIView?) {
        guard let address = self.uniqeKeyForStore() else { return }
        ActivityViewsStore.activityViewGlobal[address] = newValue
    }
    func getActivityViewGlobal() -> UIView? {
        guard let address = self.uniqeKeyForStore() else { return nil }
        return ActivityViewsStore.activityViewGlobal[address]
    }
    
    func setActivityButtonGlobal(_ newValue: UIButton?) {
        guard let address = self.uniqeKeyForStore() else { return }
        ActivityViewsStore.activityButtonGlobal[address] = newValue
    }
    func getActivityButtonGlobal() -> UIButton? {
        guard let address = self.uniqeKeyForStore() else { return nil}
        return ActivityViewsStore.activityButtonGlobal[address]
    }

    
    
    func prepareViewsBeforReqest(viewsToBlock views: [UIControl] = [], UIViewsToBlock uiViewsOp: [UIView]? = nil, activityView: UIView? = nil, activityButton: UIButton? = nil, activityButtonColor: UIColor = .white) {
        DispatchQueue.main.async {
            setActivityViewGlobal(activityView)
            setActivityButtonGlobal(activityButton)
            activityButton?.startActivity(style: .medium, color: activityButtonColor)
            if let activ = getActivityViewGlobal()?.originActivityView {
                StandartAlertUtils.stopActivityProcessView(activityIndicator: activ)
            }
            activityView?.originActivityView = StandartAlertUtils.startAndReturnActivityProcessViewOn(center: activityView, style: .medium, color: .gray)
            if !views.isEmpty {
                views.forEach { vw in vw.isEnabled = false }
                setBlokedViews(views)
            }
            
            guard let uiViews = uiViewsOp, !uiViews.isEmpty else { return }
            uiViews.forEach { vw in vw.isUserInteractionEnabled = false }
            setBlokedUIViews(uiViews)
        }
    }
    
    func enableViewsAfterReqest() {
        DispatchQueue.main.async {
            if !getBlokedViews().isEmpty {
                getBlokedViews().forEach { vw in vw.isEnabled = true }
                setBlokedViews([])
            }
            
            if !getBlokedUIViews().isEmpty {
                getBlokedUIViews().forEach { vw in vw.isUserInteractionEnabled = true }
                setBlokedUIViews([])
            }
            
            getActivityButtonGlobal()?.stopActivity()
            if let activ = getActivityViewGlobal()?.originActivityView {
                StandartAlertUtils.stopActivityProcessView(activityIndicator: activ)
            }
        }
    }
}
