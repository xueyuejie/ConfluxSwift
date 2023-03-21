import XCTest
import BigInt
@testable import ConfluxSwift

final class ConfluxSwiftTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
    }
    
    func testKeypairExample() throws {
        do {
            let keypair = try ConfluxKeypair(privateKey: Data(hex: "e21f5531e3a36255da98b9da7a2dff944b99fd46d2a770c5fd81cc759b29376f"), netId: 1029)
            debugPrint(keypair.publicKey.toHexString())
            debugPrint(keypair.address.address)
//            debugPrint(Address(data: Data(hex: "106d49f8505410eb4e671d51f7d96d2c87807b09"), netId: 1029).address)
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
    
    func testClientExample() throws {
        let reqeustExpectation = expectation(description: "Tests")
        let client = ConfluxClient(url: URL(string: "https://main.confluxrpc.com")!)
        DispatchQueue.global().async {
            do {
                let result = try client.getGasPrice().wait()
                debugPrint(result)
                reqeustExpectation.fulfill()
            } catch let error {
                debugPrint(error.localizedDescription)
                reqeustExpectation.fulfill()
            }
        }
        wait(for: [reqeustExpectation], timeout: 30)
    }
    
    func testEstimateGasAndCollateralExample() throws {
        let reqeustExpectation = expectation(description: "Tests")
        let client = ConfluxClient(url: URL(string: "https://main.confluxrpc.com")!)
        DispatchQueue.global().async {
            do {
                let transaction = RawTransaction(value: BigInt(1900000000), from: "cfx:aamnw6ffth13kr6tpwkk00yam6r62jwu7erykmhh3m", to: "cfx:aamjy3abae3j0ud8ys0npt38ggnunk5r4ps2pg8vcc", gasPrice: 22, gasLimit: 222, nonce: 148)
                let result = try client.estimateGasAndCollateral(rawTransaction: transaction!).wait()
                debugPrint(result.gasLimit)
                debugPrint(result.gasUsed)
                debugPrint(result.storageCollateralized)
                reqeustExpectation.fulfill()
            } catch let error {
                debugPrint(error.localizedDescription)
                reqeustExpectation.fulfill()
            }
        }
        wait(for: [reqeustExpectation], timeout: 30)
    }
    
    func testTokenBalanceExample() throws {
        let reqeustExpectation = expectation(description: "Tests")
        let client = ConfluxClient(url: URL(string: "https://main.confluxrpc.com")!)
        DispatchQueue.global().async {
            do {
                let result = try client.getTokenBalance(address: "cfx:aamnw6ffth13kr6tpwkk00yam6r62jwu7erykmhh3m", contractAddress: "cfx:acf2rcsh8payyxpg6xj7b0ztswwh81ute60tsw35j7").wait()
                debugPrint(result)
                reqeustExpectation.fulfill()
            } catch let error {
                debugPrint(error.localizedDescription)
                reqeustExpectation.fulfill()
            }
        }
        wait(for: [reqeustExpectation], timeout: 30)
    }
    
    func testSignExample() throws {
        do {
            let data = "Hello World".data(using: .utf8)!
            let keypair = try ConfluxKeypair(privateKey: Data(hex: "0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"), netId: 1029)
            let signature = try keypair.sign(message: data)
            XCTAssertEqual(signature.toHexString(), "6e913e2b76459f19ebd269b82b51a70e912e909b2f5c002312efc27bcc280f3c29134d382aad0dbd3f0ccc9f0eb8f1dbe3f90141d81574ebb6504156b0d7b95f01")
        } catch let error {
            debugPrint(error.localizedDescription)
        }
    }
}
