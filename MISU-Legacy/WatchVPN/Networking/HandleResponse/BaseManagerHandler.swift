//
//  BaseManagerHandler.swift
//  MyNUWEE
//
//  Created by Dmytro Kruhlov on 28.12.2020.
//

import Foundation

protocol BaseManagerHandler { }

extension BaseManagerHandler {
    typealias SuccessHandleCompletion<T: Decodable> = (_ data: Data?, _ response: HTTPURLResponse)->(result: T?, error: HandledErrorModel?)
    typealias FailureHandleCompletion = (_ data: Data?, _ networkFailureError: String, _ response: HTTPURLResponse) -> HandledErrorModel
    typealias Success200Completion = (_ success: Bool,_ error: HandledErrorModel?)->()
    typealias ResultCompletion<T: Decodable> = (_ result: T? ,_ error: HandledErrorModel?)->()
    
    
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
                                                              message: NetworkError.unableToDecode.rawValue))
            }
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
                return HandledErrorModel(statusCode: response.statusCode, message: NetworkError.unableToDecode.rawValue)
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
                ErrorParser(data: responseData)
                let apiResponse = try JSONDecoder().decode(T.self, from: responseData)
                return (result: apiResponse, error: nil)
            } catch {
                return (result: nil, error: HandledErrorModel(statusCode: response.statusCode,
                                                              message: NetworkError.unableToDecode.rawValue))
            }
        }
    }
    
    var debugFailureHandleCompletion: FailureHandleCompletion {
        return { data, networkFailureError, response in
            guard let responseData = data else {
                return HandledErrorModel(statusCode: response.statusCode, message: networkFailureError)
            }
            do {
                ErrorParser(data: responseData)
                let apiResponse = try JSONDecoder().decode(HandledErrorModel.self, from: responseData)
                return apiResponse
            } catch {
                return HandledErrorModel(statusCode: response.statusCode, message: NetworkError.unableToDecode.rawValue)
            }
        }
    }
}
