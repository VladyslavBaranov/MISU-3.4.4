//
//  CopyableLabel.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 07.06.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class CopyableLabel: UILabel {
    init() {
        super.init(frame: .zero)
        self.sharedInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }
    
    func sharedInit() {
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.showMenu)))
    }
    
    @objc func showMenu(_ recognizer: UILongPressGestureRecognizer?) {
        self.becomeFirstResponder()
        
        let menu = UIMenuController.shared

        if !menu.isMenuVisible {
            var rect = bounds
            rect.origin = CGPoint(x: self.frame.width/2, y: 0)
            rect.size = CGSize(width: 1, height: 1)
            
            menu.showMenu(from: self, rect: rect)
        }
    }
    
    override func copy(_ sender: Any?) {
        let board = UIPasteboard.general
        
        board.string = text
        
        let menu = UIMenuController.shared
        
        menu.hideMenu(from: self)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.copy)
    }
}
