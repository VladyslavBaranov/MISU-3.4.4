//
//  FullImageVC.swift
//  CoronaVirTracker
//
//  Created by Dmytro Kruhlov on 03.12.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class FullImageVC: UIViewController {
    let titleLabel: UILabel = .createTitle(text: "Title", fontSize: 18, color: .black, alignment: .center)
    let imageView: UIImageView = .makeImageView(contentMode: .scaleAspectFit)
    
    init(image img: UIImage?) {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        imageView.image = img
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// MARK: - View loads Overrides
extension FullImageVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUp()
    }
}



// MARK: - Touches Overrides
extension FullImageVC {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if touches.count == 1 {
            let touchCustomView: UIView = (imageView.transform.a > 1.1 || imageView.transform.b > 1.1) ? imageView : view
            touchCustomView.touchBeganLocation = touches.first?.location(in: touchCustomView)
            return
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if touches.count == 1, let tch = touches.first {
            let touchCustomView: UIView = (imageView.transform.a > 1.1 || imageView.transform.b > 1.1) ? imageView : view
            var newX = touchCustomView.frame.origin.x + tch.location(in: touchCustomView).x - (touchCustomView.touchBeganLocation?.x ?? 0)
            var newY = touchCustomView.frame.origin.y + tch.location(in: touchCustomView).y - (touchCustomView.touchBeganLocation?.y ?? 0)
            
            if view.dragDirection == nil {
                view.dragDirection = abs(newX) > abs(newY) ? .horizontal : .vertical
            }
            
            if imageView.transform.a > 1.1 || imageView.transform.b > 1.1 {
                imageView.animateMoveFrameOrigin(x: newX, y: newY, duration: 0)
            } else {
                newX = view.dragDirection == .horizontal ? newX : 0
                newY = view.dragDirection == .vertical ? newY : 0
                view.animateMoveFrameOrigin(x: newX, y: newY, duration: 0)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchesEndedCustom()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touchesEndedCustom()
    }
    
    func touchesEndedCustom() {
        view.dragDirection = nil
        tryDissmisAfterDrag()
        if imageView.transform.a > 1.1 || imageView.transform.b > 1.1 {
            moveImageToBorders()
        } else {
            view.animateMoveFrameOrigin(x: 0, y: 0, duration: 0.1)
        }
    }
    
    var valueXToDissmis: CGFloat { get { return 130 } }
    var valueYToDissmis: CGFloat { get { return 80 } }
    
    func tryDissmisAfterDrag() {
        if view.frame.origin.x > valueXToDissmis || view.frame.origin.y > valueXToDissmis ||
           view.frame.origin.x < -valueYToDissmis || view.frame.origin.y < -valueYToDissmis {
            dismiss(animated: true)
        }
    }
    
    func enableZoom() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(_:)))
        tapGesture.numberOfTapsRequired = 2
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(pinchGesture)
        imageView.addGestureRecognizer(tapGesture)
    }
    
    func moveImageToBorders() {
        var newX = imageView.frame.origin.x > 0 ? 0 : imageView.frame.origin.x
        var newY = imageView.frame.origin.y > 0 ? 0 : imageView.frame.origin.y
        
        if imageView.frame.origin.x < -(imageView.frame.width-view.frame.width) {
            newX = -(imageView.frame.width-view.frame.width)
        }
        if imageView.frame.origin.y < -(imageView.frame.height-view.frame.height) {
            newY = -(imageView.frame.height-view.frame.height)
        }
        
        imageView.animateMoveFrameOrigin(x: newX, y: newY, duration: 0.1)
    }

    @objc func startZooming(_ sender: UIPinchGestureRecognizer) {
        let scaleResult = sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)
        guard let scale = scaleResult, scale.a > 1, scale.d > 1 else { return }
        sender.view?.transform = scale
        sender.scale = 1
        moveImageToBorders()
    }
    
    @objc func doubleTapAction(_ sender: UITapGestureRecognizer) {
        guard let sView = sender.view else { return }
        if sView.transform.a > 1.5 || sView.transform.b > 1.5 {
            sView.animateScaleTransform(x: 1, y: 1, duration: 0.3)
        } else {
            sView.animateScaleTransform(x: 2, y: 2, duration: 0.3)
        }
    }
}



// MARK: - SetUp Views
extension FullImageVC {
    func setUp() {
        view.backgroundColor = .black
        
        view.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        enableZoom()
    }
}
