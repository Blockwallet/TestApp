//
//  Activities.swift
//  Testapp
//
//  Created by Lucas Karlsson on 2021-12-11.
//  Copyright © 2021 Testapp. All rights reserved.
//

// This file was generated from JSON Schema using quicktype.

import Foundation

// MARK: - ActivitiesStruct
struct ActivitiesStruct: Codable {
    var oldest: String?
    var activities: [Activity]?
}

// MARK: ActivitiesStruct convenience initializers and mutators

extension ActivitiesStruct {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ActivitiesStruct.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        oldest: String?? = nil,
        activities: [Activity]?? = nil
    ) -> ActivitiesStruct {
        return ActivitiesStruct(
            oldest: oldest ?? self.oldest,
            activities: activities ?? self.activities
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Activity
struct Activity: Codable {
    var message: String?
    var amount: Double?
    var userID: Int?
    var timestamp: String?
    
    enum CodingKeys: String, CodingKey {
        case message, amount
        case userID = "userId"
        case timestamp
    }
}

// MARK: Activity convenience initializers and mutators

extension Activity {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Activity.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        message: String?? = nil,
        amount: Double?? = nil,
        userID: Int?? = nil,
        timestamp: String?? = nil
    ) -> Activity {
        return Activity(
            message: message ?? self.message,
            amount: amount ?? self.amount,
            userID: userID ?? self.userID,
            timestamp: timestamp ?? self.timestamp
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Helper functions for creating encoders and decoders

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}
