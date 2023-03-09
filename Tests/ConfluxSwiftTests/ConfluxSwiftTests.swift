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
}
