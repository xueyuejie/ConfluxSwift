//
//  ConfluxError.swift
//  
//
//  Created by 薛跃杰 on 2023/3/13.
//

import Foundation

public enum ConfluxError: LocalizedError {
    case providerError(String)
    case otherError(String)
    case unknow
    
    public var errorDescription: String? {
        switch self {
        case .providerError(let message):
            return message
        case .otherError(let message):
            return message
        case .unknow:
            return "unknow"
        }
    }
}
