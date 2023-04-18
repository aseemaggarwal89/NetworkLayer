//
//  APIResponse.swift
//  ConnectUp
//
//  Created by Aseem Aggarwal on 27/02/22.
//

import Foundation

struct APIData<T> {
    let statusCode: Int
    let body: T
}

extension Decodable {
    init(jsonData: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: jsonData)
    }
}

extension APIData where T == Data {
    func decode<T>(model: T.Type) throws -> APIData<T> {
        guard let decodableType = model as? Decodable.Type else {
            throw APIError.decodingFailure(error: "Data Type is not decodable type")
        }

        let decodedJSON = try decodableType.init(jsonData: body)
        return APIData<T>(statusCode: self.statusCode,
                              body: decodedJSON as! T)
    }

    func decode<BodyType: Decodable>(to type: BodyType.Type) throws -> APIData<BodyType> {
        let decodedJSON = try JSONDecoder().decode(BodyType.self, from: body)
        return APIData<BodyType>(statusCode: self.statusCode,
                                     body: decodedJSON)
    }
}
