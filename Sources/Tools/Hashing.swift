import CommonCrypto
import Foundation

public func md5AsHex(with string: String) -> String {
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

    return digestData.map { String(format: "%02hhx", $0) }.joined()
}

public func md5AsBytes(with bytes: [UInt8]) -> [UInt8] {
    var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
    let messageData = Data(bytes: bytes, count: bytes.count)

    _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
        messageData.withUnsafeBytes { messageBytes -> UInt8 in
            if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                let messageLength = CC_LONG(messageData.count)

                CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
            }

            return 0
        }
    }

    return [UInt8](digestData)
}
