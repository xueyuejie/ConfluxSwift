//
//  Address.swift
//  
//
//  Created by 薛跃杰 on 2023/3/9.
//

import Foundation
import CryptoSwift
public struct Address {
    public static let cfxAddressLength = 42
    private static let checksumLength = 8
    
    public let address: String
    public let hexAddress: String
    public let netId: Int
    public let data: Data
    
    public init(data: Data, netId: Int) {
        self.address = Address.encodeData(data: data, netId: netId)
        self.hexAddress = data.toHexString()
        self.netId = netId
        self.data = data
    }
    
    public init(publicKey: Data, netId: Int) {
        let addressData = publicKey.sha3(.keccak256).suffix(20)
        self.init(data: addressData, netId: netId)
    }
    
    public init?(string: String) {
        guard let hexAddress = Address.decode(cfxAddress: string),
              let prefix = string.components(separatedBy: ":").first,
              let net = Address.decodeNetId(prefix: prefix),
              let addressStr = Address.encodeHex(hexAddress: hexAddress, netId: net) else {
            return nil
        }
        self.hexAddress = hexAddress
        self.netId = net
        self.address = addressStr
        self.data = Data(hex: hexAddress)
    }
}

extension Address {
    
    public static func encodeHex(hexAddress: String, netId: Int) -> String? {
        if hexAddress.isEmpty {
            return nil
         }
         return encodeData(data: Data(hex: hexAddress), netId: netId)
     }
    
    public static func encodeData(data: Data, netId: Int) -> String {
        let chainPrefix = Address.encodeNetId(netId: netId)
        var payloadData = Data(repeating: 0, count: 1)
        payloadData.append(data)
        let payload = ConfluxBase32.encode(payloadData)
        return "\(chainPrefix):\(payload)\(Address.createCheckSum(chainPrefix: chainPrefix, payload: payload))"
    }
    
    public static func haveNetworkPrefix(cfxAddressStr: String) -> Bool {
        let cfxAddresslower = cfxAddressStr.lowercased()
        return cfxAddresslower.hasPrefix("cfx") || cfxAddresslower.hasPrefix("cfxtest") || cfxAddresslower.hasPrefix("net")
    }
    
    public static func decode(cfxAddress: String) -> String? {
        if cfxAddress.isEmpty || !haveNetworkPrefix(cfxAddressStr: cfxAddress) {
            return nil
        }
        let cfxAddressStr = cfxAddress.lowercased()
        let parts = cfxAddressStr.components(separatedBy: ":")
        if (parts.count < 2) {
            return nil
        }
        let network = parts.first!
        let payloadWithSum = parts[parts.count-1]
        if (!ConfluxBase32.isValid(base32Str: payloadWithSum)) {
            return nil
        }
        if (payloadWithSum.count != cfxAddressLength) {
            return nil
        }
        let sum = String(payloadWithSum.suffix(checksumLength))
        let payload = String(payloadWithSum.prefix(payloadWithSum.count - checksumLength))
        if sum != createCheckSum(chainPrefix: network, payload: payload) {
            return nil
        }
        guard let raw = ConfluxBase32.decode(payload) else {
            return nil
        }
        let rawData = raw[2..<raw.count]
        return rawData.toHexString()
    }
}

extension Address {
    private static func encodeNetId(netId: Int) -> String {
        switch netId {
        case 1:
            return "cfxtest"
        case 1029:
            return "cfx"
        default:
            return "net\(netId)"
        }
    }
    
    private static func decodeNetId(prefix: String) -> Int? {
          let prefix = prefix.lowercased()
          switch (prefix) {
              case "cfx":
                  return 1029
              case "cfxtest":
                  return 1
              default:
              if !prefix.hasPrefix("net") {
                  return nil
              }
              let net = Int(prefix.suffix(prefix.count - 3))
              return net
          }
      }
    
    private static func createCheckSum(chainPrefix: String, payload: String) -> String{
        let prefixData = prefixToWords(prefix: chainPrefix)
        let delimiterData = Data(repeating: 0, count: 1)
        let payloadData = ConfluxBase32.decodeWords(base32Words: payload)!
        var modData = Data()
        modData.append(prefixData)
        modData.append(delimiterData)
        modData.append(payloadData)
        modData.append(Data(repeating: 0, count: 8))
        let n = polyMod(data: modData);
        return ConfluxBase32.encode(checksumBytes(data: n))
    }
    
    private static func prefixToWords(prefix: String) -> Data {
        var result = prefix.data(using: .utf8)!
        for i in 0..<result.count {
            result[i] = result.bytes[i] & UInt8(0x1f)
        }
        return result
    }
    
    private static func checksumBytes(data: Int64) -> Data {
        return Data([
            UInt8((data >> 32) & 0xff),
            UInt8((data >> 24) & 0xff),
            UInt8((data >> 16) & 0xff),
            UInt8((data >> 8) & 0xff),
            UInt8((data) & 0xff)
        ])
    }
    
    private static func polyMod(data: Data) -> Int64 {
        var c: Int64 = 1
        for datum in data.bytes{
            let c0 = UInt8(c >> 35)
            c = Int64((c & Int64(0x07ffffffff)) << 5) ^ Int64(datum)
            if ((c0 & 0x01) != 0) {c ^= Int64(0x98f2bc8e61)}
            if ((c0 & 0x02) != 0) {c ^= Int64(0x79b76d99e2)}
            if ((c0 & 0x04) != 0) {c ^= Int64(0xf33e5fb3c4)}
            if ((c0 & 0x08) != 0) {c ^= Int64(0xae2eabe2a8)}
            if ((c0 & 0x10) != 0) {c ^= Int64(0x1e4f43e470)}
        }
        return c ^ 1
    }
}

extension Address: Codable {
    private enum CodingKeys: String, CodingKey {
        case data
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.decode(Data.self, forKey: .data)
        self.init(data: data, netId: 1029)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(data, forKey: .data)
    }
}
