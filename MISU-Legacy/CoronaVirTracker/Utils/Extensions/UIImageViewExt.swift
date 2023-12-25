//
//  UIImageViewExt.swift
//  WishHook
//
//  Created by KNimtur on 9/18/19.
//  Copyright © 2019 WHAR. All rights reserved.
//

import UIKit

extension UIImageView: RequestUIController {
    func uniqeKeyForStore() -> String? {
        return self.getAddress()
    }
    
    func imageHeightToWidthMultiplier() -> CGFloat {
        return self.image?.imageHeightToWidthMultiplier() ?? 0
    }
    
    func imageWidthToHeightMultiplier() -> CGFloat {
        return self.image?.imageWidthToHeightMultiplier() ?? 0
    }
    
    static func makeImageView(_ imgName: String = "defaultImage", contentMode: UIView.ContentMode = .scaleAspectFit,
                              withRenderingMode: UIImage.RenderingMode? = nil, tintColor: UIColor? = nil) -> UIImageView {
        return makeImageView(UIImage(named: imgName), contentMode: contentMode, withRenderingMode: withRenderingMode, tintColor: tintColor)
    }
    
    static func makeImageView(_ image: UIImage?, contentMode: UIView.ContentMode = .scaleAspectFit,
                              withRenderingMode: UIImage.RenderingMode? = nil, tintColor: UIColor? = nil) -> UIImageView {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = contentMode
        img.clipsToBounds = true
        if let wrm = withRenderingMode, let tc = tintColor {
            img.image = image?.withRenderingMode(wrm)
            img.tintColor = tc
        } else {
            img.image = image
        }
        return img
    }
    
    static func createCustom(contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImageView {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFit
        img.clipsToBounds = true
        return img
    }
    
    @objc func openImageAction() {
        let vc = FullImageVC(image: self.image)
        controller()?.present(vc, animated: true)
    }
    
    func addOpenFullImageTapAction() {
        addTapRecognizer(self, action: #selector(openImageAction))
    }
    
    func setImage(url: String, resize: CGSize? = nil, defaultImageName: String = "misuLogo",
                  _ completion: ((_ success: Bool)->Void)? = nil) {
        prepareViewsBeforReqest(viewsToBlock: [], UIViewsToBlock: [self], activityView: self)
        let imgOp = ImageCM.shared.get(byLink: url, sessionTaskKey: self.getAddress()) { imageReq in
            self.enableViewsAfterReqest()
            DispatchQueue.main.async {
                if let scale = resize {
                    self.image = imageReq.scaleTo(scale)
                } else {
                    self.image = imageReq
                }
                completion?(true)
            }
        }
        
        if let img = imgOp {
            enableViewsAfterReqest()
            if let scale = resize {
                image = img.scaleTo(scale)
            } else {
                image = img
            }
            completion?(true)
            return
        }
        
        if let scale = resize {
            image = UIImage(named: defaultImageName)?.scaleTo(scale)
        } else {
            image = UIImage(named: defaultImageName)
        }
        
        completion?(false)
    }
    
    func setRounded() {
        let imageHeight = self.frame.height
        self.layer.cornerRadius = imageHeight / 2
        self.layer.masksToBounds = true
    }
    
    var contentClippingRect: CGRect {
        guard let image = image else { return bounds }
        guard contentMode == .scaleAspectFit else { return bounds }
        guard image.size.width > 0 && image.size.height > 0 else { return bounds }
        
        let scale: CGFloat
        if image.size.width > image.size.height {
            scale = bounds.width / image.size.width
        } else {
            scale = bounds.height / image.size.height
        }
        
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let x = (bounds.width - size.width) / 2.0
        let y = (bounds.height - size.height) / 2.0
        
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}
