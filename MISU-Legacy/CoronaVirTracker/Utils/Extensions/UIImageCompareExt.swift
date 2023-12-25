//
//  UIImageCompareExt.swift
//  CoronaVirTracker
//
//  Created by WH ak on 04.07.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

extension UIImage {
    func compare(with img: UIImage?) -> Bool {
        let selfImgData = self.pngData()
        let imgData = img?.pngData()
        return selfImgData == imgData
    }
    
    func scaleTo(_ newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
    
    func scaleTo(_ newWidthAndHeight: CGFloat) -> UIImage {
        return scaleTo(CGSize(width: newWidthAndHeight, height: newWidthAndHeight))
    }
    
    func scaleProportionalyTo(height: CGFloat) -> UIImage {
        return scaleTo(CGSize(width: height*imageWidthToHeightMultiplier(), height: height))
    }
    
    func imageHeightToWidthMultiplier() -> CGFloat {
        return self.size.height/self.size.width
    }
    
    func imageWidthToHeightMultiplier() -> CGFloat {
        return self.size.width/self.size.height
    }
    
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}
