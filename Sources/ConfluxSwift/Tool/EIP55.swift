//
//  EIP55.swift
//  
//
//  Created by xgblin on 2023/3/15.
//

import Foundation
import CryptoSwift

public struct EIP55 {
    public static func encode(_ data: Data) -> String {
        let address = data.toHexString()
        let hash = address.data(using: .ascii)!.sha3(.keccak256).toHexString()
        
        var resultStr = zip(address, hash)
        .map { a, h -> String in
            switch (a, h) {
            case ("0", _), ("1", _), ("2", _), ("3", _), ("4", _), ("5", _), ("6", _), ("7", _), ("8", _), ("9", _):
                return String(a)
            case (_, "8"), (_, "9"), (_, "a"), (_, "b"), (_, "c"), (_, "d"), (_, "e"), (_, "f"):
                return String(a).uppercased()
            default:
                return String(a).lowercased()
            }
        }
        .joined()
        resultStr = "1" + resultStr.dropFirst()
        return resultStr
    }
}
