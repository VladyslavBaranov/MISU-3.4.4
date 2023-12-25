//
//  ChatMessageCustomViewCell.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 10.12.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class ChatMessageCustomViewCell: UICollectionViewCell, RequestUIController {
    func uniqeKeyForStore() -> String? { return getAddress() }
    
    let messageView: UIView = .createCustom(bgColor: .clear)
    let messageLabel: UILabel = .createTitle(text: "-", fontSize: 14, color: .black, alignment: .left, isCopyable: true)
    
    var session: URLSessionTask?
    var indexPath: IndexPath?
    
    var message: Message? {
        didSet {
            session?.cancel()
            enableViewsAfterReqest()
            if let msg = message {
                updateInfo(msg)
            }
            
            if message?.cacheUpdated == true { return }
            if message?.text == nil {
                prepareViewsBeforReqest(activityView: self)
            }
            session = message?.getInfo({
                self.enableViewsAfterReqest()
                DispatchQueue.main.async {
                    if let ip = self.indexPath {
                        (self.controller() as? ChatVC)?.chatCollectionView.reloadItems(at: [ip])
                    } else {
                        (self.controller() as? ChatVC)?.chatCollectionView.reloadData()
                    }
                }
            })
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        messageLabel.numberOfLines = 500
    }
    
    @objc func updateInfo(_ msg: Message) {
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        session?.cancel()
        enableViewsAfterReqest()
        message = nil
        messageLabel.text = ""
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
