//
//  Request.swift
//  Photo Quote
//
//  Created by admin on 19/02/2024.
//

import Foundation
import Alamofire

protocol Request {
    associatedtype Reponse

    var token: String? { get }
    var baseURL: URL { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var url: URL { get }
    var parameters: Parameters { get }
    var httpHeaderFields: HTTPHeaders { get }
    var encoding: ParameterEncoding { get }
}

protocol TrustyApiConfigure: Request { }

extension TrustyApiConfigure {

    var token: String? {
        do {
            //return try Keychain(service: Bundle.main.bundleIdentifier!).get(Constant.TOKEN)
            return ""
        } catch {
            print("Failed get Keychain token")
            return nil
        }
    }

    var baseURL: URL {
        return URL(string: "https://api.quotable.io/quotes/random?limit=150")!
    }

    var encoding: ParameterEncoding {
        switch method {
        case .get, .delete:
            return URLEncoding.default
        case .post, .put:
            return JSONEncoding.default
        default:
            return URLEncoding.default
        }
    }

    var httpHeaderFields: HTTPHeaders {
        return [
            "Authorization": "Bearer " + (token ?? "")
        ]
    }
}

struct ResponseError: Decodable {
    let statusCode: Int?
    let message: String?

    init(_ statusCode: Int) {
        self.statusCode = statusCode
        self.message = nil
    }

    init(_ message: String) {
        self.statusCode = nil
        self.message = message
    }

    init(statusCode: Int, message: String) {
        self.statusCode = statusCode
        self.message = message
    }
}

enum APIError: Error {
    case badRequest(Data)
    case unAuthorized(Data)
    case serverError
    case dataNotExist
    case maintenance(Data)
    case statusCodeNotExist
    case decodeError
    case otherError(ResponseError)
    case unknownError(ResponseError)

    func getMessage() -> String? {
        switch self {
        case .otherError(let responseError):
            return responseError.message
        default:
            return nil
        }
    }
}
