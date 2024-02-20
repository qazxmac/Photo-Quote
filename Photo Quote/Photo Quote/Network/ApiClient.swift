//
//  ApiClient.swift
//  Photo Quote
//
//  Created by admin on 19/02/2024.
//

import Foundation
import Alamofire

let sessionManager: Session = {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = TimeInterval(Constant.REQUEST_TIME_OUT)
    let delegate = Session.default.delegate
    let manager = Session.init(configuration: configuration,
                               delegate: delegate,
                               startRequestsImmediately: true,
                               cachedResponseHandler: nil)
    return manager
}()

protocol ApiClientProtocol {
    func request<T: Request>(request: T, completion: @escaping (Result<ApiBase<T.Reponse>, APIError>) -> Void) where T.Reponse : Codable
}

final class ApiClient: ApiClientProtocol {

    let jsonClient: JsonClientProtocol = JsonClient()

    func request<T: Request>(request: T, completion: @escaping (Result<ApiBase<T.Reponse>, APIError>) -> Void) where T.Reponse : Codable {

        sessionManager.request(
            request.url,
            method: request.method,
            parameters: request.parameters,
            encoding: request.encoding,
            headers: request.httpHeaderFields
        )
        .cURLDescription { description in
            print("cURLDescription: \(description)")
        }
        .responseData { [weak self] response in

            if let error = response.error {
                completion(.failure(.unknownError(ResponseError(error.localizedDescription))))
                return
            }

            guard let data = response.data else {
                completion(.failure(.dataNotExist))
                return
            }

            guard let statusCode = response.response?.statusCode else {
                completion(.failure(.statusCodeNotExist))
                return
            }

            switch statusCode {
            case 200:

                guard let response = self?.jsonClient.jsonDecode(type: ApiBase<T.Reponse>.self, jsonData: data) else {
                    completion(.failure(.decodeError))
                    return
                }
                completion(.success(response))
            case 401:
                // Token expired 401 => required login by notification
                NotificationCenter.default.post(name: Notification.Name(NotificationKey.FORCE_LOGIN), object: nil)
            default:
                guard let error = self?.jsonClient.jsonDecode(type: APIErrorBase.self, jsonData: data),
                      let meta = error.meta else {
                    completion(.failure(.otherError(ResponseError(statusCode: statusCode, message: "Server error"))))
                    return
                }
                completion(.failure(.otherError(ResponseError(statusCode: meta.status, message: meta.message))))
            }
        }
    }
}
