//
//  UIStackViewExt.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 08.11.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension UIStackView {
    static func createCustom(_ arrangedSubviews: [UIView] = [],
                             axis: NSLayoutConstraint.Axis = .horizontal,
                             distribution: UIStackView.Distribution = .equalSpacing,
                             spacing: CGFloat = 8,
                             alignment: UIStackView.Alignment = .center) -> UIStackView {
        let st = UIStackView(arrangedSubviews: arrangedSubviews)
        st.translatesAutoresizingMaskIntoConstraints = false
        st.axis = axis
        st.distribution = distribution
        st.alignment = alignment
        st.spacing = spacing
        return st
    }
}
