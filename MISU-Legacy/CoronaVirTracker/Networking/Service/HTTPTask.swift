//
//  HTTPTask.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 9/2/19.
//  Copyright © 2019 WHAR. All rights reserved.
//

import Foundation

public enum HTTPTask {
    case request
    
    case requestURL(urlParameters: Parameters?)
    
    case requestBodyJson(bodyParameters: Parameters?)
    
    case requestMultiPartFormDataFiles(files: Files?)
    
    case requestBodyFormData(bodyParameters: Parameters?)
    
    case requestBodyMultiPartFormData(bodyParameters: Parameters?)
    
    case requestBodyJsonUrl(bodyParameters: Parameters?, urlParameters: Parameters?)
    
    case requestBodyMultiPartFormDataFiles(bodyParameters: Parameters?, files: Files?)
}

