//
//  RawTransaction.swift
//  
//
//  Created by 薛跃杰 on 2023/3/9.
//

import Foundation
import BigInt

public struct RawTransaction {
    public let value: BigInt
    public let to: Address
    public let gasPrice: Int
    public let gasLimit: Int
    public let nonce: Int
    public let chainId: Int
    public let storageLimit: BigInt
    public let epochHeight: BigInt
    public let data: Data
}

extension RawTransaction {
    public init?(value: BigInt, to: String, gasPrice: Int, gasLimit: Int, nonce: Int, storageLimit: BigInt, epochHeight: BigInt, chainId: Int) {
        guard let toAddress = Address(string: to) else { return nil }
        self.value = value
        self.to = toAddress
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.nonce = nonce
        self.chainId = chainId
        self.storageLimit = storageLimit
        self.epochHeight = epochHeight
        self.data = Data()
    }
    
    public init?(drip: BigInt, to: String, gasPrice: Int, gasLimit: Int, nonce: Int, data: Data = Data(), storageLimit: BigInt, epochHeight: BigInt, chainId: Int) {
        guard let toAddress = Address(string: to) else { return nil }
        self.value = drip
        self.to = toAddress
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.nonce = nonce
        self.chainId = chainId
        self.storageLimit = storageLimit
        self.epochHeight = epochHeight
        self.data = data
    }
}

extension RawTransaction: Codable {
    private enum CodingKeys: String, CodingKey {
        case value
        case to
        case gasPrice
        case gasLimit
        case nonce
        case chainId
        case storageLimit
        case epochHeight
        case data
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(BigInt.self, forKey: .value)
        to = try container.decode(Address.self, forKey: .to)
        gasPrice = try container.decode(Int.self, forKey: .gasPrice)
        gasLimit = try container.decode(Int.self, forKey: .gasLimit)
        nonce = try container.decode(Int.self, forKey: .nonce)
        chainId = try container.decode(Int.self, forKey: .chainId)
        storageLimit = try container.decode(BigInt.self, forKey: .storageLimit)
        epochHeight = try container.decode(BigInt.self, forKey: .epochHeight)
        data = try container.decode(Data.self, forKey: .data)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(to, forKey: .to)
        try container.encode(gasPrice, forKey: .gasPrice)
        try container.encode(gasLimit, forKey: .gasLimit)
        try container.encode(nonce, forKey: .nonce)
        try container.encode(chainId, forKey: .chainId)
        try container.encode(storageLimit, forKey: .storageLimit)
        try container.encode(epochHeight, forKey: .epochHeight)
        try container.encode(data, forKey: .data)
    }
    
}
