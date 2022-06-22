import Foundation

struct VersionPlist: Decodable {
    let shortVersion: String
    let version: String
    let buildVersion: String

    enum CodingKeys: String, CodingKey {
        case shortVersion = "CFBundleShortVersionString"
        case version = "CFBundleVersion"
        case buildVersion = "ProductBuildVersion"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        shortVersion = try container.decode(String.self, forKey: .shortVersion)
        version = try container.decode(String.self, forKey: .version)
        buildVersion = try container.decode(String.self, forKey: .buildVersion)
    }
}

extension KeyedDecodingContainer {

    func decodeIfPresent(_ type: Double.Type, forKey key: K, transformFrom: String.Type) throws -> Double? {
        guard let value = try decodeIfPresent(transformFrom, forKey: key) else {
            return nil
        }
        return Double(value)
    }

    func decode(_ type: Double.Type, forKey key: K, transformFrom: String.Type) throws -> Double {
        let decodedString = try decode(transformFrom, forKey: key)
        guard let value = Double(decodedString) else {
            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "The string \(decodedString) is not representable as a \(type)")
        }

        return value
    }
}
