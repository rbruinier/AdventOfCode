import Foundation
import Tools
import CommonCrypto

final class Day05Solver: DaySolver {
    let dayNumber: Int = 5

    private var input: Input!

    private struct Input {
        let seed = "abbhdwsy"
    }

    // Optimized to only return the first 3 bytes of the hash (as we only need to check for five zero's)
    private func md5First3Bytes(with string: String) -> Int {
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
        var password = ""

        for i in 0 ..< 100_000_000 {
            let string = input.seed + String(i)

            let bytes = md5First3Bytes(with: string)

            if (bytes & 0xF0FFFF) == 0 {
                let hash = md5AsHex(with: string)

                password += hash[5]

                if password.count == 8 {
                    return password
                }
            }

        }

        fatalError()
    }

    func solvePart2() -> Any {
        var password = "________"
        var placedCount = 0

        for i in 0 ..< 100_000_000 {
            let string = input.seed + String(i)

            let bytes = md5First3Bytes(with: string)

            if (bytes & 0xF0FFFF) == 0 {
                let hash = md5AsHex(with: string)

                guard let position = Int(hash[5]), position <= 7 else {
                    continue
                }

                let character = hash[6]

                if password[position] == "_" {
                    password = password[0 ..< position] + character + password[position + 1 ..< password.count]

                    placedCount += 1

                    if placedCount == 8 {
                        return password
                    }
                }
            }
        }

        fatalError()
    }

    func parseInput(rawString: String) {
        input = .init()
    }
}
