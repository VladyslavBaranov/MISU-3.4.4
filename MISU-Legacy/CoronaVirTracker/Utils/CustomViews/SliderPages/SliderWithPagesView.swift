//
//  SliderWithPagesView.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 13.02.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit

class SliderWithPagesNewView: UIView {
    let collectionView: UICollectionView = .create()
    let pageController: UIPageControl = {
        let pc: UIPageControl = .init()
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    var dataSource: [UIView] = [] {
        didSet {
            collectionView.reloadData()
            pageController.numberOfPages = dataSource.count
        }
    }
    
    let cellId = "cellId"
    
    var currentPage: Int {
        return pageController.currentPage
    }
    
    var dragDelegate: DragDelegate?
    
    init(data: [UIView] = []) {
        super.init(frame: .zero)
        dataSource = data
        setUpSub()
    }
    
    func nextPage() {
        pageController.currentPage += 1
        collectionView.scrollToItem(at: IndexPath(item: pageController.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    func goToPage(_ index: Int) {
        guard index < dataSource.count else { return }
        pageController.currentPage = index
        collectionView.scrollToItem(at: IndexPath(item: pageController.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    func setUpSub() {
        addSubview(collectionView)
        addSubview(pageController)
        
        collectionView.register(PageOneViewVCCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: pageController.topAnchor, constant: -standartInset).isActive = true

        pageController.numberOfPages = dataSource.count
        pageController.pageIndicatorTintColor = UIColor.lightGray.withAlphaComponent(0.5)
        pageController.currentPageIndicatorTintColor = .gray
        pageController.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        pageController.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        pageController.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        pageController.addTarget(self, action: #selector(changePage(_:)), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SliderWithPagesNewView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let index = collectionView.visibleIndexPaths().last?.item else { return }
        pageController.currentPage = index
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let prev = scrollView.touchBeganLocation else {
            scrollView.touchBeganLocation = scrollView.contentOffset
            return
        }
        if scrollView.contentOffset.x > prev.x {
            dragDelegate?.scrollDidDragWith(direction: .right, scrollView: scrollView)
        } else if scrollView.contentOffset.x < prev.x {
            dragDelegate?.scrollDidDragWith(direction: .left, scrollView: scrollView)
        }
        
        if scrollView.contentOffset.y > prev.y {
            dragDelegate?.scrollDidDragWith(direction: .up, scrollView: scrollView)
        } else if scrollView.contentOffset.y < prev.y {
            dragDelegate?.scrollDidDragWith(direction: .down, scrollView: scrollView)
        }
        
        //print("### \(scrollView.dragDirection)") //.contentOffset.y)")
        
        scrollView.touchBeganLocation = scrollView.contentOffset
    }
    
    
    @objc func changePage(_ sender: UIPageControl) -> () {
        print("### sender.currentPage \(sender.currentPage)")
        collectionView.scrollToItem(at: IndexPath(row: sender.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? PageOneViewVCCell
        return cell ?? collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? PageOneViewVCCell)?.setUp(mainView: dataSource[safe: indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}


struct SliderDataStruct {
    let image: UIImage?
    let text: String
    let additional: UIView? = nil
}

class SliderWithPagesView: UIView {
    let collectionView: UICollectionView = .create()
    let pageController: UIPageControl = {
        let pc: UIPageControl = .init()
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    var dataSource: [SliderDataStruct] = []
    
    let cellId = "cellId"
    
    var currentPage: Int {
        return pageController.currentPage
    }
    
    init(data: [SliderDataStruct] = []) {
        super.init(frame: .zero)
        dataSource = data
        setUpSub()
    }
    
    func nextPage() {
        pageController.currentPage += 1
        collectionView.scrollToItem(at: IndexPath(item: pageController.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    func setUpSub() {
        addSubview(collectionView)
        addSubview(pageController)
        
        collectionView.register(PageVCCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: pageController.topAnchor, constant: -standartInset).isActive = true

        pageController.numberOfPages = dataSource.count
        pageController.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.5)
        pageController.currentPageIndicatorTintColor = .white
        pageController.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        pageController.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        pageController.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        pageController.addTarget(self, action: #selector(changePage(_:)), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SliderWithPagesView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let index = collectionView.visibleIndexPaths().last?.item else { return }
        pageController.currentPage = index
    }
    
    @objc func changePage(_ sender: UIPageControl) -> () {
        print("### sender.currentPage \(sender.currentPage)")
        collectionView.scrollToItem(at: IndexPath(row: sender.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? PageVCCell
        return cell ?? collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? PageVCCell)?.data = dataSource[safe: indexPath.item]
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
