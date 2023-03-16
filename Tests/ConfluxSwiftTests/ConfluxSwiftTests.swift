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
    
    func testClient() throws {
        let reqeustExpectation = expectation(description: "Tests")
        let client = ConfluxClient(url: URL(string: "https://test.confluxrpc.com")!)
        DispatchQueue.global().async {
            do {
                let result = try client.getNextNonce(address: "cfxtest:aasm4c231py7j34fghntcfkdt2nm9xv1tu6jd3r1s7").wait()
                debugPrint(result)
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
        wait(for: [reqeustExpectation], timeout: 30)
    }
    
    func testEstimateGasAndCollateral() throws {
        let reqeustExpectation = expectation(description: "Tests")
        let client = ConfluxClient(url: URL(string: "https://main.confluxrpc.com")!)
        DispatchQueue.global().async {
            do {
                let transaction = RawTransaction(value: BigInt(1900000000), from: "cfx:aamnw6ffth13kr6tpwkk00yam6r62jwu7erykmhh3m", to: "cfx:aamjy3abae3j0ud8ys0npt38ggnunk5r4ps2pg8vcc", gasPrice: 22, gasLimit: 222, nonce: 148)
                let result = try client.estimateGasAndCollateral(rawTransaction: transaction!).wait()
                debugPrint(result.gasLimit)
                debugPrint(result.gasUsed)
                debugPrint(result.storageCollateralized)
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
        wait(for: [reqeustExpectation], timeout: 30)
    }
}
