//
//  RawTransaction.swift
//  
//
//  Created by xgblin on 2023/3/9.
//

import Foundation
import BigInt

public struct RawTransaction {
    public let value: BigUInt
    public var from: Address? = nil
    public let to: Address
    public let gasPrice: BigUInt
    public let gasLimit: BigUInt
    public let nonce: BigUInt
    public let chainId: BigUInt
    public var storageLimit: BigUInt
    public var epochHeight: BigUInt
    public var data: Data
}

extension RawTransaction {
    public init?(value: BigUInt,from: String, to: String, gasPrice: BigUInt, gasLimit: BigUInt = BigUInt(0), nonce: BigUInt, data: Data = Data(), storageLimit: BigUInt = BigUInt(0), epochHeight: BigUInt = BigUInt(0), chainId: BigUInt = BigUInt(1029)) {
        guard let fromAddress = Address(string: from) else { return nil }
        guard let toAddress = Address(string: to) else { return nil }
        self.value = value
        self.from = fromAddress
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
