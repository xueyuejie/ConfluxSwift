//
//  Address.swift
//  
//
//  Created by 薛跃杰 on 2023/3/9.
//

import Foundation
import CryptoSwift
public struct Address {
    public let raw: AddressRaw
    public let netId: Int
    public let base32String: String
    
    var prefix: String {
        switch netId {
        case 1:
            return "cfxtest"
        case 1029:
            return "cfx"
        default:
            return "net\(netId)"
        }
    }
    
    var string: String {
        return "\(prefix):\(base32String))"
    }
    
    public init(data: Data, netId: Int) {
        self.raw = AddressRaw(data: data)
        self.netId = netId
//        let base32Data = Data(hex: "00" + EIP55.encode(data))
        self.base32String = ""
//        Base32Swift.base32Encode(base32Data)
    }
    
    
    public init?(string: String) {
        let strings = string.components(separatedBy: ":")
        switch strings.first! {
        case "cfxtest":
            self.netId = 1
        case "cfx":
            self.netId = 1029
        default:
            let idString = strings.first!.replacingOccurrences(of: "net", with: "")
            guard let id = Int(idString) else {
                return nil
            }
            self.netId = id
        }
        self.base32String = strings[1]
//        guard let bytes = Base32Swift.base32Decode(base32String) else {
//            return nil
//        }
        self.raw = AddressRaw(data: Data())
    }
    
}

public struct AddressRaw {
    public let data: Data
    public let string: String

    
    public init(data: Data) {
        self.data = data
        self.string = EIP55.encode(data)
    }
    
    public init(hex: String) {
        self.data = Data()
        self.string = hex
    }
}

extension AddressRaw: Codable {
    private enum CodingKeys: String, CodingKey {
        case data
        case string
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decode(Data.self, forKey: .data)
        string = try container.decode(String.self, forKey: .string)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data, forKey: .data)
        try container.encode(string, forKey: .string)
    }
}
