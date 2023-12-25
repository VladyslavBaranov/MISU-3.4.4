//
//  PrivacyPolicyVC.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 20.11.2021.
//  Copyright © 2021 CVTCompany. All rights reserved.
//

import UIKit
import WebKit

class PrivacyPolicyVC: UIViewController, WKNavigationDelegate, RequestUIController {
    var webView: WKWebView?
    var mainURL = "https://sites.google.com/view/misu-privacypolicy"
    
    override func loadView() {
        super.loadView()
        webView = WKWebView()
        webView?.navigationDelegate = self
        view = webView
        prepareViewsBeforReqest(activityView: view, activityButtonColor: .gray)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let wv = webView else {
            ModalMessagesController.shared.show(message: "Error, check data and try again ...", type: .error)
            return
        }
        // print("###$^ \(Locale.current.languageCode)")
        if let lc = Locale.current.languageCode, CustomLanguageCode.allKeys.contains(lc) {
            mainURL += "/" + lc
        }
        
        guard let url = URL(string: mainURL) else { return }
        wv.load(URLRequest(url: url))
        wv.allowsBackForwardNavigationGestures = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        enableViewsAfterReqest()
    }
    
    func uniqeKeyForStore() -> String? {
        return view.getAddress()
    }
}
