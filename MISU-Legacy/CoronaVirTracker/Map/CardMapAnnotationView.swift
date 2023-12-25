//
//  CardMapAnnotationView.swift
//  CoronaVirTracker
//
//  Created by Dmitriy Kruglov on 3/19/20.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation
import Mapbox

class CardMapAnnotationView: MGLAnnotationView {
    let imageView: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        img.image = UIImage(named: "greenPoint")
        return img
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clear
        self.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        imageView.addShadow(radius: 2, offset: CGSize(width: 0, height: 0), opacity: 0.5, color: .black)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var type: ListStructEnum? {
        didSet {
            guard let tp = type else { return }
            
            imageView.image = tp.getImage()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.animateScaleTransform(x: 1.4, y: 1.4, duration: 0.1)
        } else {
            self.animateScaleTransform(x: 1, y: 1, duration: 0.1)
        }
    }
}
