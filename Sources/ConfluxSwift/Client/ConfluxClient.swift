//
//  ConfluxClient.swift
//  
//
//  Created by 薛跃杰 on 2023/3/13.
//

import Foundation
import PromiseKit
import BigInt

public class ConfluxClient: ConfluxBaseClient {
    
    public func getEpochNumber() -> Promise<Int> {
        return Promise<Int> { seal in
            sendRPC(method: "cfx_epochNumber").done { (result: String) in
                guard let number = Int(result.lowercased().cfxStripHexPrefix(), radix: 16) else {
                    seal.reject(ConfluxError.unknow)
                    return
                }
                seal.fulfill(number)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func getBalance(address: String) -> Promise<BigInt> {
        return Promise<BigInt> { seal in
            sendRPC(method: "cfx_getBalance", params: [address]).done { (result: String) in
                guard let number = BigInt(result.lowercased().cfxStripHexPrefix(), radix: 16) else {
                    seal.reject(ConfluxError.unknow)
                    return
                }
                seal.fulfill(number)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func getNextNonce(address: String) -> Promise<Int> {
        return Promise<Int> { seal in
             sendRPC(method: "cfx_getNextNonce", params: [address]).done { (result: String) in
                guard let number = Int(result.lowercased().cfxStripHexPrefix(), radix: 16) else {
                    seal.reject(ConfluxError.unknow)
                    return
                }
                seal.fulfill(number)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func sendRawTransaction(rawTransaction: String) -> Promise<String> {
       return sendRPC(method: "cfx_sendRawTransaction", params: [rawTransaction])
    }
    
    public func estimateGasAndCollateral(rawTransaction: RawTransaction) -> Promise<String> {
        let parameters = [
            "from": rawTransaction.from?.address ?? "",
            "to": rawTransaction.to.address,
            "gas": rawTransaction.gasLimit,
            "gasPrice": rawTransaction.gasPrice,
            "nonce": rawTransaction.nonce,
            "value": rawTransaction.value,
            "data": rawTransaction.data.toHexString()
        ] as? [String: Any]
        return sendRPC(method:  "cfx_estimateGasAndCollateral", params: [parameters ?? [String: Any]()])
    }
}
