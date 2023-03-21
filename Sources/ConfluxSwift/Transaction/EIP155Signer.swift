//
//  EIP155Signer.swift
//  
//
//  Created by xgblin on 2023/3/15.
//

import Foundation
import CryptoSwift
import Secp256k1Swift

public struct EIP155Signer {
    
    private let chainID: Int
    
    public init(chainID: Int) {
        self.chainID = chainID
    }
    
    public func sign(_ rawTransaction: RawTransaction, privateKey: PrivateKey) throws -> Data {
        let transactionHash = try hash(rawTransaction: rawTransaction)
        guard let signiture = privateKey.sign(hash: transactionHash),
              let unmarshaledSignature = calculateRSV(signature: signiture) else {
            throw ConfluxError.otherError("sign error")
        }
        let tranArr = [rawTransaction.nonce,
                       rawTransaction.gasPrice,
                       rawTransaction.gasLimit,
                       rawTransaction.to.data,
                       rawTransaction.value,
                       rawTransaction.storageLimit,
                       rawTransaction.epochHeight,
                       rawTransaction.chainId,
                       rawTransaction.data] as [Any]
        
        let rlp = try RLP.encode([
            tranArr,
            unmarshaledSignature.v,
            unmarshaledSignature.r,
            unmarshaledSignature.s
        ])
        return rlp
    }
    public func hash(rawTransaction: RawTransaction) throws -> Data {
        let data = try encode(rawTransaction: rawTransaction)
        return data.sha3(.keccak256)
    }
    
    public func encode(rawTransaction: RawTransaction) throws -> Data {
        let toEncode: [Any] = [
            rawTransaction.nonce,
            rawTransaction.gasPrice,
            rawTransaction.gasLimit,
            rawTransaction.to.data,
            rawTransaction.value,
            rawTransaction.storageLimit,
            rawTransaction.epochHeight,
            rawTransaction.chainId,
            rawTransaction.data,
        ]
        let result = try RLP.encode(toEncode)
        return result
    }
    
    // cfx use
    public func calculateRSV(signature: Data) -> SECP256K1.UnmarshaledSignature? {
        return SECP256K1.unmarshalSignature(signatureData: signature)
    }
    
    // eth use
    /*  public func calculateRSV(signature: Data) -> (r: BInt, s: BInt, v: BInt) {
     return (
     r: BInt(str: signature[..<32].toHexString(), radix: 16)!,
     s: BInt(str: signature[32..<64].toHexString(), radix: 16)!,
     v: BInt(signature[64]) + (chainID == 0 ? 27 : (35 + 2 * chainID))
     )
     } */
    
    //    public func calculateSignature(r: BigInt, s: BigInt, v: BigInt) -> Data {
    //        let isOldSignitureScheme = [27, 28].contains(v)
    //        let suffix = isOldSignitureScheme ? v - 27 : v - 35 - 2 * chainID
    //        let sigHexStr = hex64Str(r) + hex64Str(s) + suffix.asString(withBase: 16)
    //        return Data(hex: sigHexStr)
    //    }
}
