import XCTest
@testable import ConfluxSwift

final class ConfluxSwiftTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
    }
    
    func testKeypairExample() throws {
        do {
            let keypair = try ConfluxKeypair(privateKey: Data(hex: "0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"))
            debugPrint(keypair.privateKey.toHexString())
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
}
