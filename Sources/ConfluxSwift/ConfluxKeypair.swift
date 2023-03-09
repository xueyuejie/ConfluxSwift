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
import TweetNacl

public struct ConfluxKeypair {
    public var mnemonics: String?
    public var privateKey: Data
    public var publicKey: Data
    
    public init(privateKey: Data) throws {
        self.privateKey = privateKey
        let pubKey = secp256
        let pubKey = try NaclSign.KeyPair.keyPair(fromSecretKey: privateKey).publicKey
        self.publicKey = Data()
    }
    
    public init(seed: Data) throws {
        let privateKey = try NaclSign.KeyPair.keyPair(fromSeed: seed[0..<32]).secretKey
        try self.init(privateKey: privateKey)
    }
    
    public init(mnemonics: String, path: String) throws {
        guard let mnemonicSeed = BIP39.seedFromMmemonics(mnemonics) else {
            throw Error.invalidMnemonic
        }
    }
    
    public static func randomKeyPair() throws -> ConfluxKeypair {
        guard let mnemonic = try? BIP39.generateMnemonics(bitsOfEntropy: 128) else{
            throw SolanaKeyPair.Error.invalidMnemonic
        }
        return try SolanaKeyPair(mnemonics: mnemonic, path: SolanaMnemonicPath.PathType.Ed25519.default)
    }
}
