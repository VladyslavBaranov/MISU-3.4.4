//
//  ChatVC.swift
//  CoronaVirTracker
//
//  Created by WH ak on 26.05.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

// MARK: - Components
class ChatVC: UICustomVC {
    let chatCollectionView: UICollectionView = .create(scrollDirection: .vertical, showsVerticalScrollIndicator: true, alwaysBounceVertical: true, isPagingEnabled: false, backgroundColor: UIColor.appDefault.lightGrey)
    let messageView: UIView = .createCustom(bgColor: .white)
    let messageTextView: UITextView = {
        let size = CGSize(width: "s".getSize(fontSize: 16).width+UIView().standartInset, height: "s".getSize(fontSize: 16).height+UIView().standartInset)
        let tf = UITextView(frame: CGRect(origin: .zero, size: size))
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.cornerRadius = tf.frame.height/2
        tf.addCustomBorder(radius: 1, color: .lightGray)
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textContainerInset = .init(top: tf.textContainerInset.top, left: tf.standartInset, bottom: tf.textContainerInset.bottom, right: tf.standartInset)
        tf.backgroundColor = .white
        tf.showsHorizontalScrollIndicator = false
        tf.returnKeyType = .next
        tf.originTextColor = tf.textColor
        tf.placeholder = NSLocalizedString("Message", comment: "")
        return tf
    }()
    let sendButton: UIButton = .createCustom(withImage: UIImage(named: "sendImage"), backgroundColor: .clear,
                                             contentEdgeInsets: .init(top: 5, left: 5, bottom: 5, right: 5),
                                             tintColor: UIColor.appDefault.red, shadow: false)
    let scrollDownButton: UIButton = .createCustom(withImage: UIImage(named: "ScrollDown"), backgroundColor: .white,
                                                   contentEdgeInsets: .init(top: CGFloat(16/3+3), left: 16/3,
                                                                            bottom: 16/3, right: 16/3),
                                                   tintColor: UIColor.appDefault.black)
    let addRecommendationButton: UIButton = .createCustom(withImage: UIImage(named: "AddRecomIcon") , backgroundColor: .clear,
                                                          contentEdgeInsets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8),
                                                          imageRenderingMode: .alwaysOriginal, cornerRadius: 0, shadow: false)
    let recommendationAllView: UIView = .createCustom(bgColor: .white)
    let lastRecomLabel: UILabel = .createTitle(text: "-", fontSize: 14, color: .lightGray, alignment: .left)
    
    var allRecom: [Message] = []
    var navigationViewTitle: String = ""
    var isJustShowView: Bool = false
    var scrollSizePosition: CGFloat = 0
    var isFirstApear: Bool = true
    var tapIndexPath: IndexPath?
    
    var chat: Chat = .init()
    var updateOneChatTimer: Timer?
    
    var isFirstUpdate: Bool = true
    var updateSyquence: Set<Int> = []
    
    init(chat: Chat) {
        super.init(nibName: nil, bundle: nil)
        self.chat = chat
        print("Init chat id: \(String(describing: chat.id)) count: \(chat.messages.count))")
    }
    
    init(list: [Message], navigationTitle navTt: String) {
        super.init(nibName: nil, bundle: nil)
        self.chat = .init(id: -1, participants: [], messages: list, lastMessageData: nil)
        navigationViewTitle = navTt
        isJustShowView = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// MARK: - View loads Overrides
extension ChatVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setUpTestData()
        setUpView()
        setUpMessageView()
        setUpCollectionView()
        setUpNavigationView()
        
        // End point for viewDidLoad if isJustShowView
        if isJustShowView { return }
        
        //updateMessagesIds()
        
        //ChatsSinglManager.shared.chatMessagesDelegate = self
        setUpAllRecommenView()
        /*
        UsersListManager.shared.getAllUsers(id: chatModel.getOther()?.id, one: true) { (list, error) in
            if var user = list?.first {
                user.username = self.chatModel.getOther()?.username
                DispatchQueue.main.async {
                    self.chatModel.updateOther(user)
                    self.setUpNavigationView()
                    //self.navigationItem.title = user.profile?.name ?? user.doctor?.fullName ?? "-"
                }
            }
        }*/
        //ChatsSinglManager.shared.startUpdateOneChat(chatId: chatModel.id)
        self.updateMessagesIds()
        if chat.participants.isEmpty {
            subTitleStartUpdate(id: 0)
            chat.updateSelfRequest {
                self.updateMessagesIds()
                self.subTitleEndUpdate(id: 0)
                self.updateParticipants()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isJustShowView { return }
        startRegularyUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //sendButton.makeRounded()
        messageTextView.cornerRadius = messageTextView.frame.height/2
        sendButton.customBottomAnchorConstraint?.constant = -(messageView.frame.height - sendButton.frame.height)/2
        //chatCollectionView.scrollToBottom()
        if isFirstApear {
            chatCollectionView.scrollToTop()
            scrollDownButton.animateFade(duration: 0.3)
            isFirstApear = false
        }
        
        //chatCollectionView.originScrollViewSize = chatCollectionView.contentSize
        //chatCollectionView.originScrollViewOffset = chatCollectionView.contentOffset
        
        // End point for viewDidAppear if isJustShowView
        if isJustShowView { return }
        updateRecomView()
        ///ChatsSinglManager.shared.chatMessagesDelegate = self
        ///ChatsSinglManager.shared.startUpdateOneChat(chatId: chatModel.id)
        ///ChatsSinglManager.shared.openedChat(chatModel)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // End point for viewWillDisappear if isJustShowView
        if isJustShowView { return }
        updateOneChatTimer?.invalidate()
        updateOneChatTimer = nil
        ///ChatsSinglManager.shared.openedChat(chatModel)
        ///ChatsSinglManager.shared.stopUpdateOneChat()
    }
}



// MARK: - ChatMessages Delegate
extension ChatVC {
    func updateParticipants() {
        subTitleStartUpdate(id: 1)
        _ = chat.updateParticipants {
            DispatchQueue.main.async {
                self.setUpNavigationView()
            }
            self.subTitleEndUpdate(id: 1)
        }
    }
    
    func updateMessagesIds() {
        isFirstUpdate ? subTitleStartUpdate(id: 2) : pass
        chat.updateMessegasIdsList { isUpdates in
            if self.isFirstUpdate {
                self.isFirstUpdate = false
                self.subTitleEndUpdate(id: 2)
            }
            if !isUpdates {
                return
            }
            DispatchQueue.main.async {
                self.chatCollectionView.reloadData()
            }
        }
        guard let cId = chat.id else { return }
        ChatManager.shared.readChat(id: cId) { success, error in
            // print("### readChat \(cId): \(String(describing: success))")
            // print("### readChat \(cId) error: \(String(describing: error))")
            ChatsSinglManager.shared.updateUnreadedChatsCount()
        }
    }
    
    func startRegularyUpdate() {
        updateOneChatTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
            self.updateMessagesIds()
        }
    }
}

    
    
// MARK: - Other methods
extension ChatVC {
    func subTitleStartUpdate(id: Int) {
        updateSyquence.insert(id)
        DispatchQueue.main.async {
            self.navigationItemSubTitle = NSLocalizedString("Updating...", comment: "")
        }
    }
    
    func subTitleEndUpdate(id: Int) {
        updateSyquence.remove(id)
        if !updateSyquence.isEmpty { return }
        DispatchQueue.main.async {
            self.navigationItemSubTitle = ""
        }
    }
    
    func updateRecomView() {
        ///allRecom = chatModel.messages.filter({ $0.recommendation })
        if allRecom.isEmpty {
            recommendationAllView.animateFade(duration: 0.1)
            if chatCollectionView.customTopAnchorConstraint?.isActive == true { return }
            recommendationAllView.animateChangeConstraints(deactivate: recommendationAllView.customBottomAnchorConstraint, activate: chatCollectionView.customTopAnchorConstraint, duration: 0.1)
        } else {
            lastRecomLabel.text = allRecom.first?.text ?? "-"
            recommendationAllView.animateShow(duration: 0.1)
            if recommendationAllView.customBottomAnchorConstraint?.isActive == true { return }
            recommendationAllView.animateChangeConstraints(deactivate: chatCollectionView.customTopAnchorConstraint, activate: recommendationAllView.customBottomAnchorConstraint, duration: 0.1)
        }
    }
    
    func collectionRegisterCells() {
        chatCollectionView.register(MyMessageViewCell.self, forCellWithReuseIdentifier: ChatCellsIdsEnum.myMessageCellId.rawValue)
        chatCollectionView.register(OtherMessageViewCell.self, forCellWithReuseIdentifier: ChatCellsIdsEnum.recipientMessageCellId.rawValue)
        //chatCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: ChatCellsIdsEnum.chatCellId.rawValue)
        chatCollectionView.register(RecommendationViewCell.self, forCellWithReuseIdentifier: ChatCellsIdsEnum.recommendationCellId.rawValue)
        chatCollectionView.register(InvitationViewCell.self, forCellWithReuseIdentifier: ChatCellsIdsEnum.invitationCellId.rawValue)
        chatCollectionView.register(ChatMessageCustomViewCell.self, forCellWithReuseIdentifier: "empty")
    }
}



// MARK: - Button methods
extension ChatVC: RequestUIController {
    func uniqeKeyForStore() -> String? {
        return view.getAddress()
    }
    
    @objc func openAllRecom() {
        let chatMessagesList = ChatVC(list: allRecom, navigationTitle: NSLocalizedString("All Recommendations", comment: ""))
        navigationController?.pushViewController(chatMessagesList, animated: true)
    }
    
    @objc func addRecomButtonAction() {
        //print("### addRecomButtonAction tap")
        
        let crRec = CreateRecommendationView(frame: view.frame)
        crRec.parentVC = self
        crRec.show { [self] _ in
            guard let recModel = crRec.reccmmendationModel else { return }
            let newMessage = recModel.getMessageModel()
            chat.sendMessage(newMessage)
            chatCollectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
            chatCollectionView.scrollToTop()
            
            guard let cId = chat.id else { return }
            prepareViewsBeforReqest(viewsToBlock: [], activityButton: addRecommendationButton)
            ChatManager.shared.send(message: recModel, chatId: cId) { (success, error) in
                enableViewsAfterReqest()
                print("Send Recommendation: \(String(describing: success))")
                print("Send Recommendation: \(String(describing: error))")
                if success != nil {
                    self.chat.removeTemp(newMessage)
                }
                if let er = error {
                    ModalMessagesController.shared.show(message: er.message, type: .error)
                }
            }
        }
    }
    
    @objc func scrollDownButtonAction() {
        print("Did tap scroll to bottom ...")
        chatCollectionView.scrollToTop()
    }
    
    @objc func callNavButtonAction() {
        //print("### callNavButtonAction \(String(describing: chat.other))")
        guard let number = chat.other?.number else {
            ModalMessagesController.shared.show(message: NSLocalizedString("The user did not specify the number", comment: ""), type: .warning)
            return
        }
        guard let numURL = URL(string: "tel://" + number) else { return }
        UIApplication.shared.open(numURL)
    }
    
    @objc func otherNavButtonAction() {
        guard let familyDoc = chat.other else { return }
        let vc = ProfileVC(familyDoc, isCurrent: false)
        navigationController?.pushViewController(vc, animated: true)
        return
    }
    
    @objc func sendButtonAction() {
        guard var txt = messageTextView.text, txt != messageTextView.placeholder else { return }
        txt.clearEmptyEntersAndSpaces()
        if txt.isEmpty {
            messageTextView.text = ""
            textViewDidChange(messageTextView)
            return
        }
        
        let messegeToSend = SendMessage(sender: UCardSingleManager.shared.user.id, message: txt)
        let newMessage = messegeToSend.getMessageModel()
        chat.sendMessage(newMessage)
        chatCollectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
        chatCollectionView.scrollToTop()
        
        guard let cId = chat.id else { return }
        ChatManager.shared.send(message: messegeToSend, chatId: cId) { (success, error) in
            //print("### Send message: \(String(describing: success))")
            //print("### Send message: \(String(describing: error))")
            if success != nil {
                self.chat.removeTemp(newMessage)
            }
            if let er = error {
                ModalMessagesController.shared.show(message: er.message, type: .error)
            }
        }
        
        messageTextView.text = ""
        textViewDidChange(messageTextView)
    }
}



// MARK: - keyboard observer methods
extension ChatVC {
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        moveMessageViewBottomAchor(constant: -keyboardFrame.height)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        moveMessageViewBottomAchor()
    }
    
    func moveMessageViewBottomAchor(constant: CGFloat = 0 ,duration: Double = 0.3) {
        messageView.animateConstraint(messageView.customBottomAnchorConstraint, constant: constant, duration: duration)
    }
}



// MARK: - scrollView Methods
extension ChatVC {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        calculateScrollSizePosition()
        haveToShowScrollDownButton()
    }
    
    func calculateScrollSizePosition() {
        if self.chatCollectionView.contentSize.height > self.chatCollectionView.frame.size.height {
            let diff = self.chatCollectionView.contentSize.height - self.chatCollectionView.frame.size.height
            scrollSizePosition = diff - self.chatCollectionView.contentOffset.y
            //self.chatCollectionView.scrollTo(y: diff-scrollSizePosition, animated: false)
        } else {
            scrollSizePosition = 0
            //self.chatCollectionView.scrollTo(y: 0, animated: false)
        }
        scrollSizePosition = scrollSizePosition < 0 ? 0 : scrollSizePosition
    }
    
    func haveToShowScrollDownButton() {
        if self.chatCollectionView.contentOffset.y <= view.standartInset {
            scrollDownButton.animateFade(duration: 0.3)
        } else {
            scrollDownButton.animateShow(duration: 0.3)
        }
    }
}



// MARK: - SetUp Methods
extension ChatVC {
    func setUpAllRecommenView() {
        view.addSubview(recommendationAllView)
        recommendationAllView.addSubview(lastRecomLabel)
        let titleLabel: UILabel = .createTitle(text: NSLocalizedString("Doctor recommendations", comment: ""), fontSize: 14, color: .gray, alignment: .left)
        let lineView: UIView = .createCustom(bgColor: UIColor.appDefault.red)
        lineView.cornerRadius = 2
        recommendationAllView.addSubview(lineView)
        recommendationAllView.addSubview(titleLabel)
        
        recommendationAllView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        recommendationAllView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        recommendationAllView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        recommendationAllView.heightAnchor.constraint(greaterThanOrEqualToConstant: view.standartInset).isActive = true
        
        lineView.leadingAnchor.constraint(equalTo: recommendationAllView.leadingAnchor, constant: view.standartInset).isActive = true
        lineView.topAnchor.constraint(equalTo: recommendationAllView.topAnchor, constant: view.standartInset/2).isActive = true
        lineView.bottomAnchor.constraint(equalTo: recommendationAllView.bottomAnchor, constant: -view.standartInset/2).isActive = true
        lineView.widthAnchor.constraint(equalToConstant: 3).isActive = true
        lineView.setContentCompressionResistancePriority(.init(1), for: .vertical)
        lineView.setContentHuggingPriority(.init(1), for: .vertical)
        
        titleLabel.topAnchor.constraint(equalTo: recommendationAllView.topAnchor, constant: view.standartInset/2).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: lineView.trailingAnchor, constant: view.standartInset).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: recommendationAllView.trailingAnchor, constant: -view.standartInset).isActive = true
        
        lastRecomLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: view.standartInset/2).isActive = true
        lastRecomLabel.leadingAnchor.constraint(equalTo: lineView.trailingAnchor, constant: view.standartInset).isActive = true
        lastRecomLabel.trailingAnchor.constraint(equalTo: recommendationAllView.trailingAnchor, constant: -view.standartInset).isActive = true
        lastRecomLabel.bottomAnchor.constraint(equalTo: recommendationAllView.bottomAnchor, constant: -view.standartInset/2).isActive = true
        
        view.bringSubviewToFront(recommendationAllView)
        recommendationAllView.addCustomShadow()
        recommendationAllView.addTapRecognizer(self, action: #selector(openAllRecom))
        recommendationAllView.animateFade(duration: 0.1)
        
        recommendationAllView.customBottomAnchorConstraint = chatCollectionView.topAnchor.constraint(equalTo: recommendationAllView.bottomAnchor)
        recommendationAllView.customBottomAnchorConstraint?.isActive = false
    }
    
    func setUpView() {
        view.backgroundColor = UIColor.white
        view.addEndEditTapRecognizer()
        view.gestureRecognizers?.forEach({ recog in
            recog.delegate = self
        })
    }
    
    func setUpCollectionView() {
        view.addSubview(chatCollectionView)
        
        chatCollectionView.delegate = self
        chatCollectionView.dataSource = self
        
        view.sendSubviewToBack(chatCollectionView)
        collectionRegisterCells()
        
        chatCollectionView.customTopAnchorConstraint = chatCollectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        chatCollectionView.customTopAnchorConstraint?.isActive = true
        chatCollectionView.bottomAnchor.constraint(equalTo: messageView.topAnchor).isActive = true
        chatCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        chatCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        chatCollectionView.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        view.bringSubviewToFront(scrollDownButton)
    }
    
    func setUpMessageView() {
        view.addSubview(messageView)
        messageView.addSubview(messageTextView)
        messageView.addSubview(sendButton)
        
        messageView.addShadow(radius: 0.25, offset: .init(width: 0, height: -1), opacity: 0.1, color: .black)
        messageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        messageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        messageView.heightAnchor.constraint(greaterThanOrEqualToConstant: view.standartInset).isActive = true
        messageView.customBottomAnchorConstraint = messageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        messageView.customBottomAnchorConstraint?.isActive = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
        view.addSubview(scrollDownButton)
        scrollDownButton.bottomAnchor.constraint(equalTo: messageView.topAnchor, constant: -messageView.standartInset).isActive = true
        scrollDownButton.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: -messageView.standartInset).isActive = true
        scrollDownButton.heightAnchor.constraint(equalToConstant: scrollDownButton.minHeight).isActive = true
        scrollDownButton.widthAnchor.constraint(equalToConstant: scrollDownButton.minWidth).isActive = true
        scrollDownButton.addTarget(self, action: #selector(scrollDownButtonAction), for: .touchUpInside)
        
        messageTextView.delegate = self
        messageTextView.topAnchor.constraint(equalTo: messageView.topAnchor, constant: view.standartInset/2).isActive = true
        messageTextView.leadingAnchor.constraint(equalTo: messageView.leadingAnchor, constant: view.standartInset).isActive = true
        messageTextView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -view.standartInset/2).isActive = true
        messageTextView.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: -view.standartInset/2).isActive = true
        let constHeightTextView = "s".getSize(fontSize: messageTextView.font?.pointSize).height+view.standartInset
        messageTextView.customHeightAnchorConstraint = messageTextView.heightAnchor.constraint(equalToConstant: constHeightTextView)
        messageTextView.customHeightAnchorConstraint?.isActive = true
        
        if UCardSingleManager.shared.user.doctor != nil, !isJustShowView {
            messageView.addSubview(addRecommendationButton)
            addRecommendationButton.trailingAnchor.constraint(equalTo: messageTextView.trailingAnchor).isActive = true
            addRecommendationButton.centerYAnchor.constraint(equalTo: messageTextView.centerYAnchor).isActive = true
            addRecommendationButton.heightAnchor.constraint(equalToConstant: addRecommendationButton.minHeight).isActive = true
            addRecommendationButton.widthAnchor.constraint(equalToConstant: addRecommendationButton.minWidth).isActive = true
            
            addRecommendationButton.addTarget(self, action: #selector(addRecomButtonAction), for: .touchUpInside)
        }
        
        sendButton.trailingAnchor.constraint(equalTo: messageView.trailingAnchor, constant: -view.standartInset/2).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: sendButton.minHeight).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: sendButton.minWidth).isActive = true
        let constBottomSendButton = -(constHeightTextView + messageTextView.standartInset-sendButton.minHeight)/2
        sendButton.customBottomAnchorConstraint = sendButton.bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: constBottomSendButton)
        sendButton.customBottomAnchorConstraint?.isActive = true
        sendButton.addTarget(self, action: #selector(sendButtonAction), for: .touchUpInside)
        
        view.layoutIfNeeded()
        
        scrollDownButton.cornerRadius = scrollDownButton.frame.height/2
        scrollDownButton.addCustomShadow()
        
        if isJustShowView {
            sendButton.isEnabled = false
            messageTextView.isEditable = false
        }
    }
    
    func setUpNavigationView() {
        if isJustShowView {
            //navigationItem.title = navigationViewTitle
            navigationItemTitle = navigationViewTitle
            navigationController?.setNavigationBarHidden(false, animated: true)
            return
        }
        if chat.other?.profile == nil && chat.other?.doctor == nil {
            return
        }
        
        //navigationItem.title = chat.other?.profile?.name ?? chat.other?.doctor?.fullName ?? "-"
        navigationItemTitle = chat.other?.profile?.name ?? chat.other?.doctor?.fullName ?? "-"
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        let profImageUrl = chat.other?.profile?.imageURL ?? chat.other?.doctor?.imageURL
        let profImage = ImageCM.shared.get(byLink: profImageUrl) ?? UIImage(named: "patientDefImage")
        
        let callButton = UIBarButtonItem.menuButton(target: self, action: #selector(callNavButtonAction), tintColor: UIColor.appDefault.red, image: UIImage(named: "callToOther"), size: CGSize(width: navigationBarHeight*0.7, height: navigationBarHeight*0.7))
        let otherProfileButton = UIBarButtonItem.menuButton(.custom, target: self, action: #selector(otherNavButtonAction), image: profImage, size: CGSize(width: navigationBarHeight*0.9, height: navigationBarHeight*0.9), isRoundet: true)
        navigationItem.setRightBarButtonItems([callButton, otherProfileButton], animated: true)
        
        navigationItem.titleView?.addTapRecognizer(self, action: #selector(otherNavButtonAction))
    }
}
