//
//  JsonClient.swift
//  Photo Quote
//
//  Created by admin on 19/02/2024.
//

import Foundation

protocol JsonClientProtocol {
    func jsonEncode<T>(object: T) -> Data? where T: Codable
    func jsonDecode<T>(type: T.Type, jsonData: Data) -> T? where T: Codable
}

final class JsonClient: JsonClientProtocol {

    // Object => JSON Data
    func jsonEncode<T>(object: T) -> Data? where T: Codable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            return data
        } catch {
            print("jsonEncode error: \(error)")
            return nil
        }
    }

    // JSON Data => Object
    func jsonDecode<T>(type: T.Type, jsonData: Data) -> T? where T: Codable {
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: jsonData)
            return object
        } catch {
            print("jsonDecode error: \(error)")
            return nil
        }
    }

    // Object to dictionary
    func jsonEncodeToJSONDict<T>(type: T) -> String where T: Codable {
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(type)
                return String(data: data, encoding: .utf8) ?? ""
            } catch {
                return ""
            }
        }
}
