//
//  ConfluxResponse.swift
//  
//
//  Created by xgblin on 2023/3/13.
//

import Foundation

public struct ConfluxRPCResult<T: Codable>: Codable {
    public let result: T?
    public let jsonrpc: String?
    public let id: Int
    public let error: ResultError?
}

public struct ResultError: Codable {
    public let code: Int
    public let message: String
}

public struct EstimateGasAndCollateral: Codable {
    public let gasLimit: String
    public let gasUsed: String
    public let storageCollateralized: String
}
