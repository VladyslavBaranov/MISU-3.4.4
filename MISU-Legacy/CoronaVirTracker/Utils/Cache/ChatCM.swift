//
//  ChatCM.swift
//  CoronaVirTracker
//
//  Created by WH ak on 04.07.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import UIKit

class ChatCM {
    private let discCacheFileName = "MISU_Chat_Cache_\(UCardSingleManager.shared.user.id)"
    private let newDiscCacheFileName = "MISU_Chat_New_Cache_\(UCardSingleManager.shared.user.id)"
    var cached: [ChatModel] {
        get {
            return getFromDisk()
        }
        
        set(newValue) {
            //print("### \(newValue.count)")
            saveToDisk(cached: newValue)
        }
    }
    
    var cachedChat: [Int:Chat] {
        get {
            return getFromDisk()
        }
        
        set(newValue) {
            //print("### \(newValue.count)")
            saveToDisk(cached: newValue)
        }
    }
    
    static let shared: ChatCM = ChatCM()
    private init() {
        //getFromDisk()
    }
}

extension ChatCM {
    func saveToDisk(cached _cached: [ChatModel], using fileManager: FileManager = .default) {
        let folderURLs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)

        let fileURL = folderURLs[0].appendingPathComponent(discCacheFileName + ".cache")
        guard let data = try? JSONEncoder().encode(_cached) else {
            print("ERROR ChatCM JSONEncoder ...")
            return
        }
        do {
            try data.write(to: fileURL)
        } catch {
            print("ERROR ChatCM write ...")
        }
        //try? data.write(to: fileURL)
    }
    
    func getFromDisk(using fileManager: FileManager = .default) -> [ChatModel] {
        let folderURLs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)

        let fileURL = folderURLs[0].appendingPathComponent(discCacheFileName + ".cache")
        guard let data = try? Data(contentsOf: fileURL, options: .alwaysMapped) else {
            print("ERROR ChatCM Get from disk ...")
            return []
        }
        guard let cacheFromDisk = try? JSONDecoder().decode([ChatModel].self, from: data) else {
            print("ERROR ChatCM JSONDecoder ...")
            return []
        }
        //print("### Get from cache SUCCESS \(cacheFromDisk) ...")
        return cacheFromDisk
    }
    
    func saveToDisk(cached _cached: [Int:Chat], using fileManager: FileManager = .default) {
        let folderURLs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)

        let fileURL = folderURLs[0].appendingPathComponent(newDiscCacheFileName + ".cache")
        guard let data = try? JSONEncoder().encode(_cached) else {
            print("ERROR ChatCM JSONEncoder ...")
            return
        }
        do {
            try data.write(to: fileURL)
            //print("### Write to cache SUCCESS ...")
        } catch {
            print("ERROR ChatCM write ...")
        }
    }
    
    func getFromDisk(using fileManager: FileManager = .default) -> [Int:Chat] {
        let folderURLs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)

        let fileURL = folderURLs[0].appendingPathComponent(newDiscCacheFileName + ".cache")
        guard let data = try? Data(contentsOf: fileURL, options: .alwaysMapped) else {
            print("ERROR new ChatCM Get from disk ...")
            return [:]
        }
        guard let cacheFromDisk = try? JSONDecoder().decode([Int:Chat].self, from: data) else {
            print("ERROR new ChatCM JSONDecoder ...")
            return [:]
        }
        print("### Get from cache SUCCESS \(cacheFromDisk.count) ...")
        return cacheFromDisk
    }
    
    func clearCache() {
        cached = []
        cachedChat = [:]
    }
    
    func getSize() -> UInt64? {
        let folderURLs = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)

        let fileURL = folderURLs[0].appendingPathComponent(discCacheFileName + ".cache")
        guard let fileAttr = try? FileManager.default.attributesOfItem(atPath: fileURL.path) else { return nil }
        return fileAttr[FileAttributeKey.size] as? UInt64
    }
    
    func getChatSize() -> UInt64? {
        let folderURLs = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)

        let fileURL = folderURLs[0].appendingPathComponent(newDiscCacheFileName + ".cache")
        guard let fileAttr = try? FileManager.default.attributesOfItem(atPath: fileURL.path) else { return nil }
        return fileAttr[FileAttributeKey.size] as? UInt64
    }
}
