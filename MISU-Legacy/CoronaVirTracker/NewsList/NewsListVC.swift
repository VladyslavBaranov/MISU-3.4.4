//
//  NewsListViewController.swift
//  CoronaVirTracker
//
//  Created by WH ak on 25.04.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - Components
class NewsListVC: UIViewController {
    let newsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = true
        cv.showsHorizontalScrollIndicator = false
        cv.alwaysBounceVertical = true
        cv.alwaysBounceHorizontal = false
        cv.backgroundColor = UIColor.appDefault.lightGrey
        
        return cv
    }()
    
    var newsDataList: [NewModel] = []
    var newsPDList: NewPaginatedModel = .init()
    
}



// MARK: - Methods
extension NewsListVC: RequestUIController {
    func uniqeKeyForStore() -> String? {
        return view.getAddress()
    }
    
    func setUpCollectionView() {
        view.addSubview(newsCollectionView)
        
        newsCollectionView.delegate = self
        newsCollectionView.dataSource = self
        
        newsCollectionView.register(NewsViewCell.self, forCellWithReuseIdentifier: NewsCellIds.additionalNews.rawValue)
        
        newsCollectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        newsCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        newsCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        newsCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
    
    func setUpNavigationView() {
        navigationItem.title = NSLocalizedString("News", comment: "")
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func updateNewsList() {
        let proccess = StandartAlertUtils.startAndReturnActivityProcessViewOn(center: newsCollectionView, style: .medium, color: .gray)
        NewsManager.shared.getAllNews { (news, error) in
            //print(news)
            if let n = news, !n.isEmpty {
                self.newsDataList = n
                self.sortNews()
            }
            
            if let er = error {
                print(er)
            }
            DispatchQueue.main.async {
                StandartAlertUtils.stopActivityProcessView(activityIndicator: proccess)
                self.newsCollectionView.reloadData()
            }
        }
    }
    
    func updatePaginatedList() {
        if newsPDList.currentPage == newsPDList.pages, newsPDList.currentPage != 0 { return }
        
        prepareViewsBeforReqest(activityView: newsCollectionView)
        NewsManager.shared.getPaginNews(newModel: newsPDList) { (newsPModel, error) in
            self.enableViewsAfterReqest()
            if let newList = newsPModel {
                //print("### newPDList: \(self.newsPDList.currentPage), \(newList.pages)")
                newList.currentPage = self.newsPDList.currentPage + 1
                newList.list = self.newsPDList.list + newList.list
                self.newsPDList = newList
                DispatchQueue.main.async {
                    self.newsCollectionView.reloadData()
                }
            }
            
            if let er = error {
                print("newPDList ERROR: \(er)")
                ModalMessagesController.shared.show(message: er.message, type: .error)
            }
        }
    }
    
    func sortNews(order: ComparisonResult = .orderedDescending) {
        newsDataList.sort { (first, second) -> Bool in
            guard let firstDate = first.date?.toDate() else { return false }
            guard let secondDate = second.date?.toDate() else { return true }
            
            if firstDate.compare(secondDate) == order {
                return true
            }
            return false
        }
    }
}



// MARK: - View loads Overrides
extension NewsListVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCollectionView()
        setUpNavigationView()
        //updateNewsList()
        updatePaginatedList()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //updateNewsList()
        setUpNavigationView()
    }
}



// MARK: - Scrolling methods
extension NewsListVC {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let yDownToRefresh: CGFloat = -80
        if scrollView.contentOffset.y < yDownToRefresh {
            //updateNewsList()
            updatePaginatedList()
        }
    }
}
