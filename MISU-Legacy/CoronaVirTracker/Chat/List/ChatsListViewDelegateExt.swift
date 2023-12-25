//
//  ChatsListCollectionViewDelegateExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 07.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - UICollectionView Delegate
extension ChatsListVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ///guard var chat = chatsList[safe: indexPath.item] else { return }
        //chat.messages = Array(chat.messages.suffix(20))
        ///chat.messages = Array(chat.messages.prefix(20))
        ///let vc = ChatVC(chat: chat)
        
        guard let chat = chats[safe: indexPath.item] else { return }
        let vc = ChatVC(chat: ChatsSinglManager.shared.getChatBy(id: chat.id ?? -1) ?? chat)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}



// MARK: - Data Source
extension ChatsListVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return chatsList.count
        return chats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ChatCellsIdsEnum.chatCellId.rawValue, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //chats[safe: indexPath.item]
        //ChatsSinglManager.shared.getChatBy(id: )
        (cell as? ChatViewCell)?.setChat(chats[safe: indexPath.item]) // chat = chats[safe: indexPath.item]
    }
}



// MARK: - Flow Layout delegate
extension ChatsListVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w: CGFloat = view.frame.width - collectionView.standartInset*2
        let h: CGFloat = ChatViewCell.getHeight()
        return CGSize(width: w, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let const = collectionView.standartInset
        return UIEdgeInsets(top: const, left: 0, bottom: const, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView.standartInset
    }
}



// MARK: - Cells animation
extension ChatsListVC {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let cell = collectionView.cellForItem(at: indexPath)

        cell?.animateScaleTransform(x: 0.9, y: 0.9, duration: 0.1) { _ in
            cell?.animateScaleTransform(x: 1, y: 1, duration: 0.1)
        }

        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)

        cell?.animateScaleTransform(x: 0.9, y: 0.9, duration: 0.1)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)

        cell?.animateScaleTransform(x: 1, y: 1, duration: 0.1)
    }
}

