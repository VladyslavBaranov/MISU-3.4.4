//
//  UsefullEnumUtils.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 10.03.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - General Enum Kit
protocol EnumKit {}

extension EnumKit {
    var key: String {
        return String(describing: self)
    }
}

extension EnumKit where Self: CaseIterable {
    static var allKeys: [String] {
        return Self.allCases.map { elem in
            return elem.key
        }
    }
}



// MARK: - CollectionView Struct Protocol
protocol CustomEnumStruct: CaseIterable, EnumKit {
    var cellClass: AnyClass { get }
    
    static func numberOfSections() -> Int
    static func numberOfItemsInSection<T>(_ section: Int, info: T?) -> Int
    static func didSelectItemAt<T>(_ indexPath: IndexPath, collectionView: UICollectionView,
                                   info: T?, completionAfterEdit: (() -> Void)?)
    
    static func willDisplay<T>(_ cell: UICollectionViewCell, collectionView: UICollectionView,
                               forItemAt indexPath: IndexPath, info: T?)
    
    //static func sizeForItemAt(_ indexPath: IndexPath, collectionView: UICollectionView, layout: UICollectionViewLayout) -> CGSize
    static func minimumInteritemSpacingForSectionAt(section: Int, collectionView: UICollectionView,
                                                    layout collectionViewLayout: UICollectionViewLayout) -> CGFloat
    static func insetForSectionAt(_ section: Int, collectionView: UICollectionView) -> UIEdgeInsets
    static func minimumLineSpacingForSectionAt(_ section: Int, collectionView: UICollectionView) -> CGFloat
    //static func cellForItemAt(_ indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell
}

extension CustomEnumStruct {
    static var nilCellKey: String {
        return "nilCellKey"
    }
    
    static func defaultSizeForItemAt(_ indexPath: IndexPath, collectionView: UICollectionView, layout: UICollectionViewLayout) -> CGSize {
        guard let index = indexPath.item as? Self.AllCases.Index,
              let size = (allCases[safe: index]?.cellClass as? CustomCVCell.Type)?.init().getSize(cv: collectionView) else {
            return .init(width: collectionView.standart24Inset, height: collectionView.standart24Inset)
        }
        return size
    }
    
    func collectionCellType<T: UICollectionViewCell>() -> T.Type? {
        return self.cellClass as? T.Type
    }
    
    static func getCellByType<T: UICollectionViewCell>(_ tp: T.Type, key: String, indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: key, for: indexPath) as? T else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: key, for: indexPath) }
        return cell
    }
    
    static func collectionRegisterCells(_ collectionView: UICollectionView) {
        allCases.forEach { sType in
            collectionView.register(sType.cellClass, forCellWithReuseIdentifier: sType.key)
        }
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: nilCellKey)
    }
    
    static func cellForItemAt(_ indexPath: IndexPath, collectionView: UICollectionView) -> UICollectionViewCell {
        guard let sType = allCases[safe: indexPath.item as! Self.AllCases.Index] else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: nilCellKey, for: indexPath)
        }
        return collectionView.dequeueReusableCell(withReuseIdentifier: sType.key, for: indexPath)
    }
    
    static func shouldSelectItemAt(_ indexPath: IndexPath, collectionView: UICollectionView) -> Bool {
        let cell = collectionView.cellForItem(at: indexPath)
        
        cell?.animateScaleTransform(x: 0.9, y: 0.9, duration: 0.1) { _ in
            cell?.animateScaleTransform(x: 1, y: 1, duration: 0.1)
        }
        
        return true
    }
    
    static func didHighlightItemAt(_ indexPath: IndexPath, collectionView: UICollectionView) {
        let cell = collectionView.cellForItem(at: indexPath)
               
        cell?.animateScaleTransform(x: 0.9, y: 0.9, duration: 0.1)
    }
    
    static func didUnhighlightItemAt(_ indexPath: IndexPath, collectionView: UICollectionView) {
        let cell = collectionView.cellForItem(at: indexPath)
               
        cell?.animateScaleTransform(x: 1, y: 1, duration: 0.1)
    }
}
