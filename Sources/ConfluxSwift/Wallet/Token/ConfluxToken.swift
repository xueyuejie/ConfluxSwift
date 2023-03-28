//
//  ConfluxToken.swift
//  
//
//  Created by xgblin on 2023/3/16.
//

import Foundation
import BigInt

public struct ConfluxToken {
    
    /// Represents a contract address of token
    public let contractAddress: String
    
    /// Represents a decimal specified in a token
    public let decimal: Int
    
    /// Represents a symbol of  token
    public let symbol: String
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - decimal: decimal specified in a contract
    ///   - symbol: symbol of token
    public init(contractAddress: String, decimal: Int, symbol: String) {
        self.contractAddress = contractAddress
        self.decimal = decimal
        self.symbol = symbol
    }
    
    /// Length of 256 bits
    private static var lengthOf256bits: Int {
        return 256 / 4
    }
    
    /// Generate transaction data for ERC20 token
    ///
    /// - Parameter:
    ///    - toAddress: address you are transfering to
    ///    - amount: amount to send
    /// - Returns: transaction data
    public func generateDataParameter(toAddress: String, amount: String) throws -> Data {
        let poweredAmount = try power(amount: amount)
        guard let data = ConfluxToken.ContractFunctions.transfer(address: toAddress, amount: poweredAmount).data else {
            throw ConfluxError.otherError("invalid toAddress")
        }
        return data
    }
    
    /// Power the amount by the decimal
    ///
    /// - Parameter:
    ///    - amount: amount in string format
    /// - Returns: BigInt value powered by (10 * decimal)
    private func power(amount: String) throws -> BigUInt {
        let components = amount.split(separator: ".")
        
        // components.count must be 1 or 2. this method accepts only integer or decimal value
        // like 1, 10, 100 or 1.15, 10.7777, 19.9999
        guard components.count == 1 || components.count == 2 else {
            throw ConfluxError.otherError("invalid contract token amout")
        }
        
        guard let integer = BigUInt(components[0], radix: 10) else {
            throw ConfluxError.otherError("invalid contract token amout")
        }
        
        let poweredInteger = integer * (BigUInt(10) * BigUInt(decimal))
        
        if components.count == 2 {
            let count = components[1].count
            
            guard count <= decimal else {
                throw ConfluxError.otherError("invalid contract token amout")
            }
            
            guard let digit = BigUInt(components[1], radix: 10) else {
                throw ConfluxError.otherError("invalid contract token amout")
            }
            
            let poweredDigit = digit * (BigUInt(10) * BigUInt(decimal - count))
            return poweredInteger + poweredDigit
        } else {
            return poweredInteger
        }
    }
    
    /// Pad left spaces out of 256bits with 0
    internal static func pad(string: String) -> String {
        var string = string
        while string.count != lengthOf256bits {
            string = "0" + string
        }
        return string
    }
}


extension ConfluxToken {
    public enum ContractFunctions {
        case balanceOf(address: String)
        case transfer(address: String, amount: BigUInt)
        case deposit(amount: BigUInt)
        case withdraw(amount: BigUInt)
        case decimals
        
        var methodSignature: Data {
            switch self {
            case .balanceOf:
                return generateSignature(method: "balanceOf(address)")
            case .transfer:
                return generateSignature(method: "transfer(address,uint256)")
            case .deposit:
                return generateSignature(method: "deposit(uint256 amount)")
            case .withdraw:
                return generateSignature(method: "withdraw(uint256 amount)")
            case .decimals:
                return generateSignature(method: "decimals()")
            }
        }
        
        private func generateSignature(method: String) -> Data {
            return method.data(using: .ascii)!.sha3(.keccak256)[0...3]
        }
        
        public var data: Data? {
            switch self {
            case .balanceOf(let address):
                guard let padAddress = Address(string: address) else {return nil}
                let noHexAddress = ConfluxToken.pad(string: padAddress.hexAddress.cfxStripHexPrefix())
                let result = Data(hex: methodSignature.toHexString() + noHexAddress)
                return result
            case .transfer(let toAddress, let poweredAmount):
                guard let address = Address(string: toAddress) else {return nil}
                let noHexAddress = ConfluxToken.pad(string: address.hexAddress.cfxStripHexPrefix())
                let amount = ConfluxToken.pad(string: poweredAmount.serialize().toHexString())
                return Data(hex: methodSignature.toHexString() + noHexAddress + amount)
            case .deposit(amount: let amount):
                let amount = ConfluxToken.pad(string: amount.serialize().toHexString())
                return Data(hex: amount)
            case .withdraw(amount: let amount):
                let amount = ConfluxToken.pad(string: amount.serialize().toHexString())
                return Data(hex: amount)
            case .decimals:
                return Data(hex: methodSignature.toHexString())
            }
        }
    }
}
