//
//  Router.swift
//  WishHook
//
//  Created by Dmitriy Kruglov on 9/3/19.
//  Copyright © 2019 WHAR. All rights reserved.
//

import Foundation

class Router<EndPoint: EndPointType>: NetworkRouter {
    private var task: URLSessionTask?
    var timeoutInterval: TimeInterval = 21
    
    
    //-------------------------------------------------------------------------------------------
    // MARK: - sending request
    //-------------------------------------------------------------------------------------------
    
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion) {
        let session = URLSession.shared
        do {
            let request = try self.buildRequest(from: route)
            task = session.dataTask(with: request, completionHandler: { data, response, error in
                completion(data, response, error)
            })
        } catch {
            completion(nil, nil, error)
        }
        self.task?.resume()
    }
    
    
    //-------------------------------------------------------------------------------------------
    // MARK: - cancel request
    //-------------------------------------------------------------------------------------------
    
    func cancel() {
        self.task?.cancel()
    }
    
    
    //-------------------------------------------------------------------------------------------
    // MARK: - build request
    //-------------------------------------------------------------------------------------------
    
    fileprivate func buildRequest(from route: EndPoint) throws -> URLRequest {
        var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: timeoutInterval)
        request.httpMethod = route.httpMethod.rawValue
        
        self.addAdditionalHeaders(route.headers, request: &request)
        
        do {
            switch route.task {
            
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            case .requestURL(let urlParameters):
                try self.configureUrl(urlParameters: urlParameters, request: &request)
                
            case .requestBodyJson(let bodyParameters):
                try self.configureBodyJson(bodyParameters: bodyParameters, request: &request)
                
            case .requestBodyFormData(let bodyParameters):
                try self.configureBodyFormData(bodyParameters: bodyParameters, request: &request)
                
            case .requestBodyMultiPartFormData(let bodyParameters):
                try self.configureBodyMultiPartFormData(bodyParameters: bodyParameters, files: nil, request: &request)
            
            case .requestBodyMultiPartFormDataFiles(let bodyParameters, let files):
                try self.configureBodyMultiPartFormData(bodyParameters: bodyParameters, files: files, request: &request)
            
            case .requestMultiPartFormDataFiles(let files):
                try self.configureMultiPartFormDataFiles(files: files, request: &request)
                
            case .requestBodyJsonUrl(let bodyParameters, let urlParameters):
                try self.configureBodyJson(bodyParameters: bodyParameters, request: &request)
                try self.configureUrl(urlParameters: urlParameters, request: &request)
            }
            return request
        } catch {
            throw error
        }
    }
    
    
    //-------------------------------------------------------------------------------------------
    // MARK: - configure parameters
    //-------------------------------------------------------------------------------------------
    
    fileprivate func configureUrl(urlParameters: Parameters?, request: inout URLRequest) throws {
        do {
            if let urlParameters = urlParameters {
                try URLParameterEncoder.encode(urlRequest: &request, with: urlParameters)
            }
        } catch {
            throw error
        }
    }
    
    fileprivate func configureBodyJson(bodyParameters: Parameters?, request: inout URLRequest) throws {
        do {
            if let bodyParameters = bodyParameters {
                try JSONParameterEncoder.encode(urlRequest: &request, with: bodyParameters)
            }
        } catch {
            throw error
        }
    }
    
    fileprivate func configureBodyFormData(bodyParameters: Parameters?, request: inout URLRequest) throws {
        do {
            if let bodyParameters = bodyParameters {
                try FormDataParameterEncoding.encode(urlRequest: &request, with: bodyParameters)
            }
        } catch {
            throw error
        }
    }
    
    fileprivate func configureBodyMultiPartFormData(bodyParameters: Parameters?, files: Files?, request: inout URLRequest) throws {
        do {
            if let bodyParameters = bodyParameters {
                try MultiPartFormDataParameterEncoding.encode(urlRequest: &request, with: bodyParameters, files: files)
            }
        } catch {
            throw error
        }
    }
    
    fileprivate func configureMultiPartFormDataFiles(files: Files?, request: inout URLRequest) throws {
        do {
            if let files = files {
                try MultiPartFormDataParameterEncoding.encode(urlRequest: &request, with: nil, files: files)
            }
        } catch {
            throw error
        }
    }
    
    //-------------------------------------------------------------------------------------------
    // MARK: - adding additional headers
    //-------------------------------------------------------------------------------------------
    
    fileprivate func addAdditionalHeaders (_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}
