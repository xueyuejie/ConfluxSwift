//
//  PublicKey.swift
//  
//
//  Created by xgblin on 2023/3/15.
//

import Foundation
import Secp256k1Swift

public class PublicKey {
    public let raw: Data
    
    public init(raw: Data) {
        self.raw = raw
    }
    
    public convenience init?(privateKey: PrivateKey) {
        guard let pubkey = PublicKey.from(data: privateKey.raw, compressed: false) else {
            return nil
        }
        self.init(raw: Data(pubkey.bytes[1..<pubkey.count]))
    }
    
    /// Generates public key from specified private key,
    ///
    /// - Parameters: data of private key and compressed
    /// - Returns: Public key in data format
    public static func from(data: Data, compressed: Bool) -> Data? {
        return SECP256K1.privateToPublic(privateKey: data, compressed: compressed)
    }
}
