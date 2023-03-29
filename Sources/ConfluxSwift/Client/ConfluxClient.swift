//
//  ConfluxClient.swift
//  
//
//  Created by xgblin on 2023/3/13.
//

import Foundation
import PromiseKit
import BigInt

public class ConfluxClient: ConfluxBaseClient {
    
    public func getEpochNumber() -> Promise<Int> {
        return Promise<Int> { seal in
            sendRPC(method: "cfx_epochNumber").done { (result: String) in
                seal.fulfill(Int(result.lowercased().cfxStripHexPrefix(), radix: 16) ?? 0)
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
    
    public func getTokenBalance(address: String, contractAddress: String) -> Promise<BigInt> {
        return Promise<BigInt> { seal in
            guard let data = ConfluxToken.ContractFunctions.balanceOf(address: address).data else {
                seal.reject(ConfluxError.otherError("invalid address"))
                return
            }
            let dataHex = data.toHexString().addPrefix("0x")
            call(to: contractAddress, data: dataHex).done { result in
                seal.fulfill(BigInt(result.lowercased().cfxStripHexPrefix(), radix: 16) ?? BigInt.zero)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    func getTokenDecimal(contractAddress: String) -> Promise<Int>  {
        return Promise<Int> { seal in
            guard let data = ConfluxToken.ContractFunctions.decimals.data else {
                seal.reject(ConfluxError.otherError("invalid address"))
                return
            }
            call(to: contractAddress, data: data.toHexString().addPrefix("0x")).done { result in
                seal.fulfill(Int(result.lowercased().cfxStripHexPrefix(), radix: 16) ?? 0)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func getNextNonce(address: String) -> Promise<Int64> {
        return Promise<Int64> { seal in
             sendRPC(method: "cfx_getNextNonce", params: [address]).done { (result: String) in
                guard let number = Int64(result.lowercased().cfxStripHexPrefix(), radix: 16) else {
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
    
    public func getGasPrice() -> Promise<String> {
        return Promise<String> { seal in
             sendRPC(method: "cfx_gasPrice").done { (result: String) in
                 guard let number = BigInt(result.lowercased().cfxStripHexPrefix(), radix: 16)?.description else {
                    seal.reject(ConfluxError.unknow)
                    return
                }
                seal.fulfill(number)
            }.catch { error in
                seal.reject(error)
            }
        }
    }
    
    public func estimateGasAndCollateral(transaction: RawTransaction) -> Promise<EstimateGasAndCollateral> {
        return Promise<EstimateGasAndCollateral> { seal in
            var parameters = [
                "to": transaction.to.address,
                "value": String(transaction.value, radix: 16).addPrefix("0x"),
                "data": transaction.data.toHexString().addPrefix("0x")
            ] as? [String: Any]
            sendRPC(method:  "cfx_estimateGasAndCollateral", params: [parameters ?? [String: Any]()]).done { (result: EstimateGasAndCollateral) in
                seal.fulfill(EstimateGasAndCollateral(
                    gasLimit: BigInt(result.gasLimit.cfxStripHexPrefix(), radix: 16)?.description ?? "0",
                    gasUsed: BigInt(result.gasUsed.cfxStripHexPrefix(), radix: 16)?.description ?? "0",
                    storageCollateralized: BigInt(result.storageCollateralized.cfxStripHexPrefix(), radix: 16)?.description ?? "0")
                )
            }.catch { error in
                seal.reject(error)
            }
        }
    }
}
