//
//  PrivateKey.swift
//  
//
//  Created by 薛跃杰 on 2023/3/15.
//

import Foundation
import Secp256k1Swift

public struct PrivateKey {
   public let raw: Data
   
   public init(raw: Data) {
       self.raw = raw
   }
   
   /// Publish key derived from private key
   public var publicKey: PublicKey? {
       return PublicKey(privateKey: self)
   }
   
   /// Sign signs provided hash data with private key by Elliptic Curve, Secp256k1
   ///
   /// - Parameter hash: hash in data format
   /// - Returns: signiture in data format
   /// - Throws: .cryptoError(.failedToSign) when failed to sign
   public func sign(hash: Data) -> Data? {
       let (serializedSignature,_) = SECP256K1.signForRecovery(hash: hash, privateKey: self.raw, useExtraVer: false)
       return serializedSignature
   }
}
