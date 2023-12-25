//
//  ErrorParser.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 12/3/19.
//  Copyright © 2019 WHAR. All rights reserved.
//

import Foundation

func ErrorParser(statusCode: Int, data: Data) {
    print("-----ERROR-----")
    print("status: \(statusCode)")
    
    print(String(data: data, encoding: .utf8) ?? "Data empty ...")
    do {
        let response = try JSONDecoder().decode(Dictionary<String, String>.self, from: data)
        print("Resp err StrStr: \(response)")
    } catch {
        
    }
    do {
        let response = try JSONDecoder().decode(Dictionary<String, Dictionary<String,[String]>>.self, from: data)
        print("Resp err StrStrStr: \(response)")
    } catch {
        
    }
    
    print("-----END-----")
}
