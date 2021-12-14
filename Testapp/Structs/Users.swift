// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let User = try User(json)

import Foundation

// MARK: - User
struct User: Codable {
    var userID: Int?
    var displayName: String?
    var avatarURL: String?
    
    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case displayName
        case avatarURL = "avatarUrl"
    }
}

// MARK: User convenience initializers and mutators

extension User {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(User.self, from: data)
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
        userID: Int?? = nil,
        displayName: String?? = nil,
        avatarURL: String?? = nil
    ) -> User {
        return User(
            userID: userID ?? self.userID,
            displayName: displayName ?? self.displayName,
            avatarURL: avatarURL ?? self.avatarURL
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
