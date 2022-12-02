import Foundation
import Tools
import XCTest

final class MD5Tests: XCTestCase {
    func testMD5AsHex() {
        let result = md5AsHex(with: "ABCDEF")

        XCTAssertEqual(result, "8827a41122a5028b9808c7bf84b9fcf6")
    }

    func testMD5AsBytes() {
        let input: [UInt8] = "ABCDEF".data(using: .ascii)!.map { $0 }

        let result = md5AsBytes(with: input)
        let expectedResult = hexStringToBytes("8827a41122a5028b9808c7bf84b9fcf6")

        XCTAssertEqual(result, expectedResult)
    }

    private func hexStringToBytes(_ string: String) -> [UInt8] {
        guard string.count.isEven else {
            fatalError()
        }

        var result: [UInt8] = []

        for groupIndex in 0 ..< string.count / 2 {
            let index = groupIndex * 2

            let hexString = string[index ... index + 1]

            let value = UInt8(hexString, radix: 16)!

            result.append(value)
        }

        return result
    }
}
