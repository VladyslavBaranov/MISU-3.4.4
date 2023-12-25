//
//  GroupCollectionViewDelegate.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 17.12.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension GroupVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return GroupStruct.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch GroupStruct.allCases[safe: section] {
        case .info:
            return 1
        case .participants:
            return groupModel.allMembers.count
        case .pending:
            return gInvitesModels.count
        case nil:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = collectionView.frame.width - view.standartInset
        var h: CGFloat = view.standartInset*5
        
        switch GroupStruct.allCases[safe: indexPath.section] {
        case .info:
            h = GroupAdminViewCell.getHeight(frame: collectionView.frame)
        case .participants, .pending:
            h = UserViewCell.getHeight()
        default:
            break
        }
        
        return CGSize(width: w, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch GroupStruct.allCases[safe: section] {
        case .pending:
            if gInvitesModels.isEmpty { return .zero }
             return CGSize(width: collectionView.frame.width, height: TitleCollectionReusableView.getHeight())
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch GroupStruct.allCases[safe: indexPath.section] {
        case .info:
            let vc = ProfileVC()
            vc.setUser(groupModel.admin, isCurrent: false)
            navigationController?.pushViewController(vc, animated: true)
            return
        case .participants:
            let vc = ProfileVC()
            vc.setUser(groupModel.allMembers[safe: indexPath.row], isCurrent: false)
            navigationController?.pushViewController(vc, animated: true)
            return
        default:
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let type = GroupStruct.allCases[safe: indexPath.section], groupModel.isICreator else { return nil }
        switch type {
        case .participants:
            guard let user = groupModel.allMembers[safe: indexPath.row] else { return nil }
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (sugAct) -> UIMenu? in
                return type.makeContextMenu(id: user.id, groupId: self.groupModel.id)
            }
        case .pending:
            guard let inviteId = gInvitesModels[safe: indexPath.row]?.id else { return nil }
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (sugAct) -> UIMenu? in
                return type.makeContextMenu(id: inviteId, groupId: self.groupModel.id)
            }
        default:
            return nil
        }
    }
}



// MARK: - Layout delegate
extension GroupVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch GroupStruct.allCases[safe: indexPath.section] {
        case .info:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GroupStruct.info.description, for: indexPath) as? GroupAdminViewCell else {
                break
            }
            cell.adminModel = groupModel.admin
            return cell
        case .participants, .pending:
            let key: String = GroupStruct.allCases[safe: indexPath.section]?.description ?? GroupStruct.pending.description
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: key, for: indexPath) as? UserViewCell else {
                break
            }
//            if GroupStruct.allCases[safe: indexPath.section] == .pending {
//                cell.userModel = gInvitesModels[safe: indexPath.row]?.recipient
//            } else {
//                cell.userModel = groupModel.allMembers[safe: indexPath.row]
//            }
//            cell.alpha = GroupStruct.allCases[safe: indexPath.section] == .pending ? 0.5 : 1
            return cell
        default:
            break
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Test", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch GroupStruct.allCases[safe: indexPath.section] {
        case .participants:
            guard let customCell = cell as? UserViewCell else { return }
            customCell.userModel = groupModel.allMembers[safe: indexPath.row]
            cell.alpha = 1
        case .pending:
            guard let customCell = cell as? UserViewCell else { return }
            customCell.userModel = gInvitesModels[safe: indexPath.row]?.recipient
            cell.alpha = 0.5
        default:
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView.standartInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch GroupStruct.allCases[safe: section] {
        case .info:
            return UIEdgeInsets(top: 0, left: 0, bottom: view.standartInset/2, right: 0)
        case .pending:
            return UIEdgeInsets(top: view.standartInset/2, left: 0, bottom: view.standartInset, right: 0)
        default:
            return UIEdgeInsets(top: view.standartInset/2, left: 0, bottom: view.standart24Inset, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind != UICollectionView.elementKindSectionHeader || gInvitesModels.isEmpty {
            return UICollectionReusableView()
        }
//        switch kind {
//        case UICollectionView.elementKindSectionHeader:
//            break
//        default:
//            return UICollectionReusableView()
//        }
            
        switch GroupStruct.allCases[safe: indexPath.section]  {
        case .pending:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: GroupStruct.pending.description, for: indexPath) as? TitleCollectionReusableView else { return UICollectionReusableView() }
                headerView.titleLabel.text = "\(NSLocalizedString("In pending", comment: "")):"
                return headerView
        default:
            return UICollectionReusableView()
        }
    }
}



// MARK: - Cells animation
extension GroupVC {
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
