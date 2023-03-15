//
//  AddressType.swift
//  
//
//  Created by 薛跃杰 on 2023/3/15.
//

import Foundation

public enum AddressType {
    case user
    case builtin
    case contract
    
    var value: UInt8 {
        switch self {
        case .user:
            return 1
        case .builtin:
            return 0
        case .contract:
            return 8
        }
    }
    
    public func normalize(hash: Data) -> Data {
        var hashHex = hash.toHexString().cfxStripHexPrefix()
        let indexStart = hashHex.index(hashHex.startIndex, offsetBy: 1)
        hashHex = String(hashHex[indexStart...])
        hashHex = "\(self.value)\(hashHex)"
        return Data(hex: hashHex)
    }
}
