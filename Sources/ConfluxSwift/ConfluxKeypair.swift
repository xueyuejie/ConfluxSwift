//
//  ConfluxKeypair.swift
//  
//
//  Created by 薛跃杰 on 2023/3/9.
//

import Foundation
import BIP32Swift
import CryptoSwift
import BIP39swift
import Secp256k1Swift

public struct ConfluxKeypair {
    public var mnemonics: String?
    public var privateKey: Data
    public var publicKey: Data
    public var address: Address
    
    public init(privateKey: Data) throws {
        guard let pubKey = SECP256K1.privateToPublic(privateKey: privateKey, compressed: false) else {
            throw ConfluxKeypairError.invalidPrivateKey
        }
        
        self.privateKey = privateKey
        self.publicKey = Data(pubKey.bytes[1..<pubKey.count])
        let addressData = pubKey.sha3(.keccak256).suffix(20)
        self.address = Address(data: addressData, netId: 1029)
    }
    
    public init(seed: Data, path: String) throws {
        guard let hdnode = HDNode(seed: seed),
              let derivedNode = hdnode.derive(path: "\(path)/0"),
              let privateKey = derivedNode.privateKey else {
            throw ConfluxKeypairError.invalidSeed
        }
        try self.init(privateKey: privateKey)
    }
    
    public init(mnemonics: String, path: String = "m/44'/503'/0'/0") throws {
        guard let mnemonicSeed = BIP39.seedFromMmemonics(mnemonics) else {
            throw ConfluxKeypairError.invalidMnemonic
        }
        try self.init(seed: mnemonicSeed, path: path)
    }
    
    public static func randomKeyPair() throws -> ConfluxKeypair {
        guard let mnemonic = try? BIP39.generateMnemonics(bitsOfEntropy: 128) else{
            throw ConfluxKeypairError.invalidMnemonic
        }
        return try ConfluxKeypair(mnemonics: mnemonic)
    }
}

// MARK: Error
public enum ConfluxKeypairError: String, LocalizedError {
    case invalidMnemonic
    case invalidDerivePath
    case invalidSeed
    case invalidPrivateKey
    case unknown
    
    public var errorDescription: String? {
        return "ConfluxKeypairError.\(rawValue)"
    }
}
