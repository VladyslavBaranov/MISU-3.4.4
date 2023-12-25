//
//  NetworkError.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 9/4/19.
//  Copyright © 2019 WHAR. All rights reserved.
//

import UIKit

public enum NetworkError: String, Error {
    
    // errors before sending request
    case parametersNil = "Parameters were nil ..."
    case encodingFailed = "Parameter encoding failed ..."
    case encodingJsonFailed = "Parameter encoding in json failed ..."
    case encodingMultiPartFormDataFailed = "Parameter encoding in MultiPartFormData failed ..."
    case missingURL = "URL is nil ..."
    case baseURLNil = "BaseURL could not be configured ..."
    
    // sending errors
    case requestTimeOut = "Please check your network connection ..."
    
    // errors from response
    case unsuppMediaType = "Unsupported media type ..."
    case authError = "Authentication Error ..."
    case badRequest = "Bad request ..."
    case outdated = "The url you requested is outdated ..."
    case failed = "Network request failed ..."
    case noData = "Response returned with no data to decode ..."
    case unableToDecode = "Could not decode the response ..."
    
    var localizedRaw: String {
        return NSLocalizedString(rawValue, comment: "")
    }
}
