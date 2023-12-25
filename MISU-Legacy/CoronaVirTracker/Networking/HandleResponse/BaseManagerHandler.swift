//
//  BaseManagerHandler.swift
//  MyNUWEE
//
//  Created by Dmytro Kruhlov on 28.12.2020.
//

import Foundation

protocol BaseManagerHandler { }

extension BaseManagerHandler {
    
    // MARK: - Typealiases
    typealias SuccessHandleCompletion<T: Decodable> = (_ data: Data?, _ response: HTTPURLResponse)->(result: T?, error: HandledErrorModel?)
    typealias SuccessDataHandleCompletion = (_ data: Data?, _ response: HTTPURLResponse)->(data: Data?, error: HandledErrorModel?)
    typealias FailureHandleCompletion = (_ data: Data?, _ networkFailureError: String, _ response: HTTPURLResponse) -> HandledErrorModel
    typealias Success200Completion = (_ success: Bool,_ error: HandledErrorModel?)->()
    typealias ResultDataCompletion = (_ data: Data?,_ error: HandledErrorModel?)->()
    typealias ResultCompletion<T: Decodable> = (_ result: T? ,_ error: HandledErrorModel?)->()
    
    
    
    // MARK: - Response Handlers
    func handleResponse<T: Decodable>(data: Data?, response: URLResponse?, error: Error?,
                                      successHandleCompletion: SuccessHandleCompletion<T> = defaultSuccessHandleCompletion(),
                                      failureCompletion: FailureHandleCompletion = defaultFailureHandleCompletion,
                                      completion: ResultCompletion<T>? = nil) {
        if let error = error {
            let errorMoodel = HandledErrorModel(message: error.localizedDescription)
            completion?(nil, errorMoodel)
            return
        }
        
        if let response = response as? HTTPURLResponse {
            let result = ResponseHandler.handleNetworkResponse(response)
            
            switch result {
            case .success:
                let successResult = successHandleCompletion(data, response)
                completion?(successResult.result, successResult.error)
            case .failure(let networkFailureError):
                let failureResult = failureCompletion(data, networkFailureError, response)
                completion?(nil, failureResult)
                return
            }
        }
    }
    
    func handleResponse(data: Data?, response: URLResponse?, error: Error?,
                        failureCompletion: FailureHandleCompletion = defaultFailureHandleCompletion,
                        success200Completion: Success200Completion? = nil) {
        if let error = error {
            let errorMoodel = HandledErrorModel(message: error.localizedDescription)
            success200Completion?(false, errorMoodel)
            return
        }
        
        if let response = response as? HTTPURLResponse {
            let result = ResponseHandler.handleNetworkResponse(response)
            
            switch result {
            case .success:
                success200Completion?(true, nil)
            case .failure(let networkFailureError):
                let failureResult = failureCompletion(data, networkFailureError, response)
                success200Completion?(false, failureResult)
                return
            }
        }
    }
    
    func handleResponse(data: Data?, response: URLResponse?, error: Error?,
                        successHandleCompletion: SuccessDataHandleCompletion = defaultDataSuccessHandleCompletion,
                        failureCompletion: FailureHandleCompletion = defaultFailureHandleCompletion,
                        resultDataCompletion: ResultDataCompletion? = nil) {
        if let error = error {
            let errorMoodel = HandledErrorModel(message: error.localizedDescription)
            resultDataCompletion?(nil, errorMoodel)
            return
        }
        
        if let response = response as? HTTPURLResponse {
            let result = ResponseHandler.handleNetworkResponse(response)
            
            switch result {
            case .success:
                let responseData = successHandleCompletion(data, response)
                resultDataCompletion?(responseData.data, responseData.error)
            case .failure(let networkFailureError):
                let failureResult = failureCompletion(data, networkFailureError, response)
                resultDataCompletion?(nil, failureResult)
                return
            }
        }
    }
    
    
    
    // MARK: - Default Completions
    static func defaultSuccessHandleCompletion<T: Decodable>() -> SuccessHandleCompletion<T> {
        return { data, response in
            guard let responseData = data else {
                return (result: nil,
                        error: HandledErrorModel(statusCode: response.statusCode, message: NetworkError.noData.rawValue))
            }
            do {
                //ErrorParser(data: responseData)
                let apiResponse = try JSONDecoder().decode(T.self, from: responseData)
                return (result: apiResponse, error: nil)
            } catch {
                return (result: nil, error: HandledErrorModel(statusCode: response.statusCode,
                                                              message: NetworkError.unableToDecode.localizedRaw))
            }
        }
    }
    
    
    
    static var defaultDataSuccessHandleCompletion: SuccessDataHandleCompletion {
        return { data, response in
            guard let responseData = data else {
                return (data: nil, error: HandledErrorModel(statusCode: response.statusCode, message: NetworkError.noData.rawValue))
            }
            return (responseData, nil)
        }
    }
    
    
    
    static var defaultFailureHandleCompletion: FailureHandleCompletion {
        return { data, networkFailureError, response in
            guard let responseData = data else {
                return HandledErrorModel(statusCode: response.statusCode, message: networkFailureError)
            }
            do {
                let apiResponse = try JSONDecoder().decode(HandledErrorModel.self, from: responseData)
                return apiResponse
            } catch {
                return HandledErrorModel(statusCode: response.statusCode, message: NetworkError.unableToDecode.localizedRaw)
            }
        }
    }
    
    func debugSuccessHandleCompletion<T: Decodable>() -> SuccessHandleCompletion<T> {
        return { data, response in
            guard let responseData = data else {
                return (result: nil,
                        error: HandledErrorModel(statusCode: response.statusCode, message: NetworkError.noData.rawValue))
            }
            do {
                ErrorParser(statusCode: response.statusCode, data: responseData)
                let apiResponse = try JSONDecoder().decode(T.self, from: responseData)
                return (result: apiResponse, error: nil)
            } catch {
                return (result: nil, error: HandledErrorModel(statusCode: response.statusCode,
                                                              message: NetworkError.unableToDecode.localizedRaw))
            }
        }
    }
    
    var debugFailureHandleCompletion: FailureHandleCompletion {
        return { data, networkFailureError, response in
            guard let responseData = data else {
                return HandledErrorModel(statusCode: response.statusCode, message: networkFailureError)
            }
            do {
                ErrorParser(statusCode: response.statusCode, data: responseData)
                let apiResponse = try JSONDecoder().decode(HandledErrorModel.self, from: responseData)
                return apiResponse
            } catch {
                return HandledErrorModel(statusCode: response.statusCode, message: NetworkError.unableToDecode.localizedRaw)
            }
        }
    }
}
