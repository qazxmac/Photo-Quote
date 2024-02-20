//
//  ApiBase.swift
//  Photo Quote
//
//  Created by admin on 19/02/2024.
//

import Foundation

struct ApiBase<T: Codable>: Codable {
    var data: [T]
    let meta: Meta

    enum CodingKeys: String, CodingKey {
        case data
        case meta
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        meta = try container.decode(Meta.self, forKey: .meta)
        // Check data type Single or Array
        data = []
        // Decode with Single object
        do {
            let decodeDataSingleType = try container.decode(T.self, forKey: .data)
            data.append(decodeDataSingleType)
        } catch {
            print("Single object decode error: \(error.localizedDescription)")
            // Decode with Array
            do {
                data = try container.decode([T].self, forKey: .data)
            } catch {
                print("Array decode error: \(error.localizedDescription)")
            }
        }
    }
}

struct Meta: Codable {
    let status: Int
    let message: String
    let pagination: Pagination
}

struct Pagination: Codable {
    let perPage: Int
    let currentPage: Int
    let lastPage: Int
    let from: Int
    let to: Int
    let total: Int

    enum CodingKeys: String, CodingKey {
        case perPage = "per_page"
        case currentPage = "current_page"
        case lastPage = "last_page"
        case from
        case to
        case total
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        perPage = try container.decode(Int.self, forKey: .perPage)
        currentPage = try container.decode(Int.self, forKey: .currentPage)
        lastPage = try container.decode(Int.self, forKey: .lastPage)
        from = try container.decode(Int.self, forKey: .from)
        to = try container.decode(Int.self, forKey: .to)
        total = try container.decode(Int.self, forKey: .total)
    }
}
