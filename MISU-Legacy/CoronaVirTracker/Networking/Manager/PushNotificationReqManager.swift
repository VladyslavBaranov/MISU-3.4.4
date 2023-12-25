//
//  PushNotificationReqManager.swift
//  CoronaVirTracker
//
//  Created by WH ak on 11.08.2020.
//  Copyright © 2020 CVTCompany. All rights reserved.
//

import Foundation



struct PushNotificationReqManager {
    private let router = Router<PushNotificationReqApi>()
    static let shared = PushNotificationReqManager()
    private init() {}
    
    func setDevice(deviceId: String, completion: @escaping (_ success: Bool?,_ error: ErrorModel?)->()) {
        let modelToSend = PushNotificationReqModel(deviceId: deviceId)
        router.request(.setDevice(parameters: modelToSend.getParameters())) {
            data, response, error in
            
            if let error = error {
                completion(nil, ErrorModel(error: error.localizedDescription,
                                           infoForUser: NetworkError.requestTimeOut.localizedRaw))
            }
            
            if let response = response as? HTTPURLResponse {
                let result = ResponseHandler.handleNetworkResponse(response)
                
                switch result {
                case .success:
                    completion(true, nil)
                case .failure(let networkFailureError):
                    guard let responseData = data else {
                        completion(nil, ErrorModel(error: networkFailureError, infoForUser: "Error ...", statusCode: response.statusCode))
                        return
                    }
                    
                    ErrorParser(statusCode: response.statusCode, data: responseData)
                    
                    do {
                        let apiResponse = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                        completion(nil, ErrorModel(error: String(describing: apiResponse), infoForUser: apiResponse.error ?? "", statusCode: response.statusCode))
                    } catch {
                        completion(nil, ErrorModel(error: NetworkError.unableToDecode.localizedRaw, infoForUser: "Decode error ...", statusCode: response.statusCode))
                    }
                }
            }
        }
    }
}
