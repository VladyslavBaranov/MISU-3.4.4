//
//  ChatsListVC.swift
//  CoronaVirTracker
//
//  Created by WH ak on 26.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - Components
class ChatsListVC: UIViewController {
    let listCollectionView: UICollectionView = {
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
    
    var chatsList: [ChatModel] = []
    var chatsPList:  ChatsThreadsPM = .init()
    
    var chats: [Chat] = UserDefaultsUtils.getChatIds() {
        didSet {
            UserDefaultsUtils.safeChatIds(chats: chats)
        }
    }
}



// MARK: - View loads Overrides
extension ChatsListVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ChatsSinglManager.shared.delegate = self
        
        setUpView()
        setUpNavigationView()
        setUpCollectionView()
        
        //getAllChats()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getAllChats(isBegin: true)
    }
}



// MARK: - Other methods
extension ChatsListVC: RequestUIController {
    func uniqeKeyForStore() -> String? {
        return view.getAddress()
    }
    
    func getAllChats(isBegin: Bool) {
        prepareViewsBeforReqest(viewsToBlock: [], activityView: listCollectionView)
        ChatManager.shared.getChatIdsList { chats_, error in
            self.enableViewsAfterReqest()
            
            print("### getChatIdsList \(String(describing: chats_?.count))")
            print("### getChatIdsList error \(String(describing: error))")
            
            if let ch = chats_ {
                self.chats = ch
                DispatchQueue.main.async {
                    self.listCollectionView.reloadData()
                }
            }
        }
        
        /*ChatsSinglManager.shared.updateAllChats {
        }*/
        
        /*isBegin ? chatsPList = .init() : pass
        
        if chatsPList.currentPage == chatsPList.pages, chatsPList.currentPage != 0 { return }
        
        prepareViewsBeforReqest(viewsToBlock: [], activityView: listCollectionView)
        ChatManager.shared.allPaginated(chatModel: chatsPList) { (result_, error_) in
            self.enableViewsAfterReqest()
            
            print("### result_ \(String(describing: result_?.currentPage)) \(String(describing: result_?.pages)) \(String(describing: result_?.threads.count)) \(String(describing: result_))")
            print("### r error \(String(describing: error_))")
            
            if let cl = result_ {
                cl.currentPage = self.chatsPList.currentPage + 1
                self.chatsPList.threads.append(contentsOf: cl.threads)
                cl.threads = self.chatsPList.threads
                self.chatsPList = cl
                
                DispatchQueue.main.async {
                    self.listCollectionView.reloadData()
                }
            }
        }*/
    }
    
    func collectionRegisterCells() {
        listCollectionView.register(ChatViewCell.self, forCellWithReuseIdentifier: ChatCellsIdsEnum.chatCellId.rawValue)
    }
    
    @objc func createNewChatAction() {
        let selectRecipientView = SelectSomeOneToSendView(frame: view.frame)
        selectRecipientView.setUpCompletionSelected { userToSend in
            ChatsSinglManager.shared.createChatWith(userToSend) { chatOp in
                guard let chat = chatOp else { return }
                DispatchQueue.main.async {
                    let ch = ChatsSinglManager.shared.getChatBy(id: chat.id ?? -123)
                    if ch == nil {
                        ChatsSinglManager.shared.setChat(chat)
                    }
                    let vc = ChatVC(chat: ch ?? chat)
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        selectRecipientView.show()
        return
    }
}



// MARK: - ChatsSinglMAnager Delegate
extension ChatsListVC: ChatsSinglManagerDelegate {
    func chatsListUpdated() {
        /*DispatchQueue.main.async {
            self.chatsList = ChatsSinglManager.shared.chatsList
            self.listCollectionView.reloadData()
        }*/
    }
}




// MARK: - Scrolling methods
extension ChatsListVC {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let yDownToRefresh: CGFloat = -80
        if scrollView.contentOffset.y < yDownToRefresh {
            getAllChats(isBegin: true)
        }
    }
}



// MARK: - SetUp Methods
extension ChatsListVC {
    func setUpView() {
        view.backgroundColor = UIColor.white
    }
    
    func setUpNavigationView() {
        navigationItem.title = NSLocalizedString("All Chats", comment: "")
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        let addNewChat = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(createNewChatAction))
        navigationItem.rightBarButtonItem = addNewChat
        navigationItem.rightBarButtonItem?.tintColor = .black
    }
    
    func setUpCollectionView() {
        view.addSubview(listCollectionView)
        
        listCollectionView.delegate = self
        listCollectionView.dataSource = self
        
        collectionRegisterCells()
        
        listCollectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        listCollectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        listCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        listCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    }
}
