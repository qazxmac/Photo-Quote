//
//  APIErrorBase.swift
//  Photo Quote
//
//  Created by admin on 19/02/2024.
//

import Foundation

struct APIErrorBase: Codable {
    let meta: Meta?

    enum CodingKeys: String, CodingKey {
        case meta
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            meta = try container.decode(Meta.self, forKey: .meta)
        } catch {
            meta = nil
            print("Single object decode error: \(error.localizedDescription)")
        }
    }
}
