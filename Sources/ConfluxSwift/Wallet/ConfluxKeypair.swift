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
    public var privateKey: PrivateKey
    public var publicKey: Data
    public var address: Address
    
    public init(privateKey: Data, netId: Int) throws {
        guard let pubKey = SECP256K1.privateToPublic(privateKey: privateKey, compressed: false) else {
            throw ConfluxKeypairError.invalidPrivateKey
        }
        
        self.privateKey = PrivateKey(raw: privateKey)
        self.publicKey = Data(pubKey.bytes[1..<pubKey.count])
        self.address = Address(publicKey: self.publicKey, netId: netId)
    }
    
    public init(seed: Data, netId: Int, path: String) throws {
        guard let hdnode = HDNode(seed: seed),
              let derivedNode = hdnode.derive(path: "\(path)/0"),
              let privateKey = derivedNode.privateKey else {
            throw ConfluxKeypairError.invalidSeed
        }
        try self.init(privateKey: privateKey, netId: netId)
    }
    
    public init(mnemonics: String, netId: Int, path: String = "m/44'/503'/0'/0") throws {
        guard let mnemonicSeed = BIP39.seedFromMmemonics(mnemonics) else {
            throw ConfluxKeypairError.invalidMnemonic
        }
        try self.init(seed: mnemonicSeed, netId: netId, path: path)
    }
    
    public static func randomKeyPair(netId: Int) throws -> ConfluxKeypair {
        guard let mnemonic = try? BIP39.generateMnemonics(bitsOfEntropy: 128) else{
            throw ConfluxKeypairError.invalidMnemonic
        }
        return try ConfluxKeypair(mnemonics: mnemonic, netId: netId)
    }
}

// MARK: - Sign

extension ConfluxKeypair {
    public func sign(message: Data) throws -> Data {
        let hash = message.sha3(.keccak256)
        guard let retrunSignature = privateKey.sign(hash: hash) else {
            throw ConfluxKeypairError.invalidMessage
        }
        return retrunSignature
    }
    
    public func sign(transaction: RawTransaction, chanId: Int = 1029) throws -> Data {
        let signer = EIP155Signer(chainID: chanId)
        let data = try signer.sign(transaction, privateKey: self.privateKey)
        return data
    }

    public func signVerify(message: Data, signature: Data) -> Bool {
        guard let publickey = SECP256K1.recoverPublicKey(hash: message, signature: signature), publickey == self.publicKey else {
            return false
        }
        return true
    }
}

// MARK: Error
public enum ConfluxKeypairError: String, LocalizedError {
    case invalidMnemonic
    case invalidDerivePath
    case invalidSeed
    case invalidPrivateKey
    case invalidMessage
    case unknown
    
    public var errorDescription: String? {
        return "ConfluxKeypairError.\(rawValue)"
    }
}
