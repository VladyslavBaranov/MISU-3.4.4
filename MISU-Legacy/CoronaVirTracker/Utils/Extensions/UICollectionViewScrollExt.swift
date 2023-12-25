//
//  UICollectionViewScrollExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 06.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension UICollectionView {
    static func create(
        scrollDirection: UICollectionView.ScrollDirection = .horizontal,
        showsVerticalScrollIndicator: Bool = false,
        showsHorizontalScrollIndicator: Bool = false,
        alwaysBounceVertical: Bool = false,
        alwaysBounceHorizontal: Bool = false,
        isPagingEnabled: Bool = true,
        backgroundColor: UIColor = .clear
    ) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = scrollDirection
        
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        cv.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        cv.alwaysBounceVertical = alwaysBounceVertical
        cv.alwaysBounceHorizontal = alwaysBounceHorizontal
        cv.isPagingEnabled = isPagingEnabled
        cv.backgroundColor = backgroundColor
        return cv
    }
    
    func scrollToTop(y: CGFloat = 0, animated: Bool = true) {
        self.setContentOffset(CGPoint(x: 0, y: y), animated: animated)
    }
    
    func scrollToBottom(y: CGFloat = 0, animated: Bool = true) {
        let contentHeight = self.contentSize.height
        let frameAfterInserts = self.frame.size.height - self.contentInset.top - self.contentInset.bottom
        
        if contentHeight > frameAfterInserts {
            self.setContentOffset(CGPoint(x: 0, y: contentHeight-self.frame.size.height+y), animated: animated)
        }
    }
    
    func scrollTo(y: CGFloat = 0, animated: Bool = true) {
        self.setContentOffset(CGPoint(x: 0, y: y > 0 ? y : 0), animated: animated)
    }
    
    func insertCells(preCount: Int, afterCount: Int, section: Int = 0) {
        var indexestoInsert: [IndexPath] = []
        if afterCount - preCount <= 0 {
            self.reloadData()
            return
        }
        
        (preCount...afterCount-1).forEach { index in
            indexestoInsert.append(IndexPath(item: index, section: section))
        }
        
        self.insertItems(at: indexestoInsert)
    }
    
    func scrollToSafe(x: CGFloat = 0, y: CGFloat = 0, animated: Bool = true) {
        var x = x < 0 ? 0 : x
        x = x > self.contentSize.width-self.frame.size.width ? self.contentSize.width-self.frame.size.width : x
        
        var y = y < 0 ? 0 : y
        y = y > self.contentSize.height-self.frame.size.height ? self.contentSize.height-self.frame.size.height : y
        self.setContentOffset(CGPoint(x: x, y: y), animated: animated)
    }
    
    func isLast(item: Int, inSection: Int) -> Bool {
        return item == self.numberOfItems(inSection: inSection)-1
    }
    
    func visibleIndexPaths() -> [IndexPath] {
        var visibleIP: [IndexPath] = []
        self.visibleCells.forEach { cell in
            if let vIP = self.indexPath(for: cell) { visibleIP.append(vIP)}
        }
        return visibleIP
    }
}
