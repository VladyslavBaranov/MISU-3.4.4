//
//  ChatCollectionViewDelegateExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 03.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class CustomIndexPath: NSCopying {
    let indexPath: IndexPath
    
    init(indexPath ip: IndexPath) {
        indexPath = ip
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = CustomIndexPath(indexPath: indexPath)
        return copy
    }
}

// MARK: - UICollectionView Delegate
extension ChatVC: UICollectionViewDelegate {
    /* HERE
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let mId = chat.messagesIdsAndInProg[safe: indexPath.item]?.id, let msg = chat.allMessages[mId] else { return nil }
        //`CustomIndexPath(indexPath: indexPath)
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (sugAct) -> UIMenu? in
            return MessageContextMenuItems.makeContextMenu(messageModel: msg)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        //.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
 */
//    func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
//        //guard let indexPath = configuration.identifier as? IndexPath,
//              //let destinationVc = destinationViewController(for: indexPath) else { return }
//        //cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
//
//    }
    
//    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
//        guard let identifier = configuration.identifier.copy() as? CustomIndexPath else { return nil }
//        let parameters = UIPreviewParameters()
//        parameters.backgroundColor = .black
//        guard let cell = collectionView.cellForItem(at: identifier.indexPath) else { return nil }
//        //UITableViewCell()
//        print("--- \(cell)")
//        //configuration
//        return UITargetedPreview(view: cell.contentView, parameters: parameters)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
//        guard let identifier = configuration.identifier.copy() as? CustomIndexPath else { return nil }
//        let parameters = UIPreviewParameters()
//        parameters.backgroundColor = .black
//        guard let cell = collectionView.cellForItem(at: identifier.indexPath) else { return nil }
//        //UITableViewCell()
//        //print("--- \(cell)")
//        //configuration
//        return UITargetedPreview(view: cell.contentView, parameters: parameters)
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //print("### didSelectItemAt \(collectionView.interactions)...") //UIContextMenuInteraction
//        if let iter = collectionView.interactions.first(where: { ($0 as? UIContextMenuInteraction) != nil }), let iterM = iter as? UIContextMenuInteraction {
//            //iterM.view?.transform = CGAffineTransform(scaleX: 1, y: -1)
//        }
        //collectionView.beginInteractiveMovementForItem(at: indexPath)
        
        if let tp = tapIndexPath, tp == indexPath {
            tapIndexPath = nil
            print("### double tap...")
            
            guard let cell = collectionView.cellForItem(at: indexPath) as? ChatMessageCustomViewCell else {
                return
            }
            (cell.messageLabel as? CopyableLabel)?.showMenu(nil)
        } else {
            tapIndexPath = indexPath
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
                self.tapIndexPath = nil
            })
        }
    }
}



// MARK: - Data Source
extension ChatVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return chatModel.messages.count
        return chat.messagesIdsAndInProg.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let mId = chat.messagesIdsAndInProg[safe: indexPath.item]?.id, let msg = chat.allMessages[mId] else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "empty", for: indexPath)
        }
        
        if msg.recommendation {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatCellsIdsEnum.recommendationCellId.rawValue, for: indexPath) as? RecommendationViewCell else {
                return collectionView.dequeueReusableCell(withReuseIdentifier: "empty", for: indexPath)
            }
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        }
        
        if msg.invitation != nil {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatCellsIdsEnum.invitationCellId.rawValue, for: indexPath) as? InvitationViewCell else {
                return collectionView.dequeueReusableCell(withReuseIdentifier: "empty", for: indexPath)
            }
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        }
        
        switch msg.isMyMessage {
        case true:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatCellsIdsEnum.myMessageCellId.rawValue, for: indexPath) as? MyMessageViewCell else {
                return collectionView.dequeueReusableCell(withReuseIdentifier: "empty", for: indexPath)
            }
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        case false:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatCellsIdsEnum.recipientMessageCellId.rawValue, for: indexPath) as? OtherMessageViewCell else {
                return collectionView.dequeueReusableCell(withReuseIdentifier: "empty", for: indexPath)
            }
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = (cell as? ChatMessageCustomViewCell)
        cell?.indexPath = indexPath
        guard let m = chat.messagesIdsAndInProg[safe: indexPath.item] else { return }
        guard let mId = m.id else { return }
        if let mess = chat.allMessages[mId] {
            cell?.message = mess
        } else {
            chat.allMessages.updateValue(m, forKey: mId)
            cell?.message = m
        }
//        (cell as? RecommendationViewCell)?.messageModel = mess
//        (cell as? InvitationViewCell)?.messageModel = mess
//        (cell as? MyMessageViewCell)?.messageModel = mess
//        (cell as? OtherMessageViewCell)?.messageModel = mess
    }
}



// MARK: - Flow Layout delegate
extension ChatVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w: CGFloat = view.frame.width
        var h: CGFloat = view.standart24Inset
        
        guard let mId = chat.messagesIdsAndInProg[safe: indexPath.item]?.id, let msg = chat.allMessages[mId] else { return .init(width: w, height: h) }
        
        switch msg.isMyMessage {
        case true:
            h = MyMessageViewCell.getHeight(text: msg.text ?? "",
                                            time: msg.sendDate?.getTimeDateWitoutToday(),
                                            frame: CGRect(origin: .zero, size: CGSize(width: w, height: view.standartInset)))
        case false:
            h = OtherMessageViewCell.getHeight(text: msg.text ?? "", time: msg.sendDate?.getTimeDateWitoutToday(),
                                               frame: CGRect(origin: .zero, size: CGSize(width: w, height: view.standartInset)))
        }
        
        if msg.recommendation == true {
            h = RecommendationViewCell.getHeight(text: msg.text ?? "",
                                                 frame: CGRect(origin: .zero, size: CGSize(width: w, height: view.standartInset)),
                                                 isImage: (msg.imageLink != nil))
        }
        
        if msg.invitation != nil {
            h = InvitationViewCell.getHeight(text: msg.text ?? "",
                                             frame: CGRect(origin: .zero, size: CGSize(width: w, height: view.standartInset)))
        }
        
        return CGSize(width: w, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: collectionView.standartInset, left: 0,
                            bottom: collectionView.standartInset, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView.standartInset
    }
}
