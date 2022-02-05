import Foundation
import Tools
import CommonCrypto

final class Day04Solver: DaySolver {
    let dayNumber: Int = 4

    private var input: Input!

    private struct Input {
        let key = "bgvyzdsv"
    }

    private var cachedStartIndex = 0

    private func md5AsHex(with string: String) -> Int {
        // source: https://stackoverflow.com/a/32166735/898408
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        let messageData = string.data(using:.utf8)!

        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)

                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }

                return 0
            }
        }

        // just return the bytes we are interested in (first 3)
        return Int(digestData[2]) << 16 | Int(digestData[1]) << 8 | Int(digestData[0])
    }

    func solvePart1() -> Any {
        for i in cachedStartIndex ..< 1_000_000 {
            let number = md5AsHex(with: input.key  + String(i))

            if (number & 0xF0FFFF) == 0 {
                cachedStartIndex = i

                return i
            }
        }

        return 0
    }

    func solvePart2() -> Any {
        for i in cachedStartIndex ..< 10_000_000 {
            let number = md5AsHex(with: input.key  + String(i))

            if (number >> 0) & 0xFFFFFF == 0 {
                return i
            }
        }

        return 0
    }

    func parseInput(rawString: String) {
        input = .init()
    }
}
