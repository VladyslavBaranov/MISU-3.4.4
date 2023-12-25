//
//  ChatTextViewDelegateExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 04.06.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension ChatVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.isPlaceholder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        if textView.numberOfLines() <= textView.maxNumberOfLines || estimatedSize.height < textView.frame.height {
            textView.animateConstraint(textView.customHeightAnchorConstraint, constant: estimatedSize.height, duration: 0.1)
        }
        
        if textView.text.isEmpty {
            addRecommendationButton.animateShow(duration: 0.3)
        } else {
            addRecommendationButton.animateFade(duration: 0.3)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.placeholderIfNeeded()
    }
}
