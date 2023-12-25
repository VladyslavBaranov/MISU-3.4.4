//
//  ImageCM.swift
//  CoronaVirTracker
//
//  Created by WH ak on 04.07.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class ImageCM {
    private var cached: [ImageCacheModel] = []
    private let userDefCachedKey = "42userDefCachedKey42_gydg7wg76gd327eg"
    private let discCacheFileName = "MISU_Cache"
    private var sessionTasks: [String:URLSessionTask] = [:]
    
    static let shared: ImageCM = ImageCM()
    private init() {
        getFromDisk()
    }
}

extension ImageCM {
    func cancelTask(key: String?) {
        guard let k = key else { return }
        sessionTasks[k]?.cancel()
    }
    
    func saveTask(_ task: URLSessionTask?, key: String?) {
        guard let t = task, let k = key else { return }
        sessionTasks.updateValue(t, forKey: k)
    }
}

extension ImageCM {
    func get(byLink opLink: String?, sessionTaskKey: String? = nil, completion: ((UIImage)->Void)? = nil) -> UIImage? {
        cancelTask(key: sessionTaskKey)
        guard let byLink = opLink else { return nil }
        let link = LinkUtils.getCleanImagePath(link: byLink)
        
        
        
        if let cachedData = cached.first(where: {$0.key == link})?.value, let cachedImage = UIImage(data: cachedData) {
            //print("### Get from cache SUCCESS \(link) ...")
            return cachedImage
        }
        
        let task = ImagesManager.shared.getAndReturnBy(link: link) { (imageData, errors) in
            if let data = imageData, let image = UIImage(data: data) {
                self.set(image: image, by: link)
                completion?(image)
            }
        }
        
        saveTask(task, key: sessionTaskKey)
        
        return nil
    }
    
    private func set(image: UIImage, by link: String) {
        guard let data = image.jpegData(compressionQuality: 1) else { return }
        cached.append(.init(key: link, value: data))
        saveToDisk()
    }
    
    func saveToDisk(using fileManager: FileManager = .default) {
        let folderURLs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)

        let fileURL = folderURLs[0].appendingPathComponent(discCacheFileName + ".cache")
        guard let data = try? JSONEncoder().encode(cached) else { return }
        try? data.write(to: fileURL)
    }
    
    func getFromDisk(using fileManager: FileManager = .default) {
        let folderURLs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)

        let fileURL = folderURLs[0].appendingPathComponent(discCacheFileName + ".cache")
        guard let data = try? Data(contentsOf: fileURL, options: .alwaysMapped) else {
            //print("### Get from disk cache ERROR ...")
            return
        }
        guard let cacheFromDisk = try? JSONDecoder().decode([ImageCacheModel].self, from: data) else {
            //print("### Cache decoding ERROR ...")
            return
        }
        //print("### Get from cache SUCCESS \(cacheFromDisk) ...")
        cached = cacheFromDisk
    }
    
    func clear() {
        cached = []
        saveToDisk()
    }
    
    func getSize() -> UInt64? {
        let folderURLs = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)

        let fileURL = folderURLs[0].appendingPathComponent(discCacheFileName + ".cache")
        guard let fileAttr = try? FileManager.default.attributesOfItem(atPath: fileURL.path) else { return nil }
        return fileAttr[FileAttributeKey.size] as? UInt64
    }
    
    func covertToString(size: UInt64) -> String {
        var convertedValue: Double = Double(size)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }
}
