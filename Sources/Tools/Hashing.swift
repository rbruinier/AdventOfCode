import CryptoKit
import Foundation

public func md5AsHex(with string: String) -> String {
	let messageData = string.data(using: .utf8)!

	let result = CryptoKit.Insecure.MD5.hash(data: messageData)

	return result.map { String(format: "%02hhx", $0) }.joined()
}

public func md5AsBytes(with bytes: [UInt8]) -> [UInt8] {
	let result = CryptoKit.Insecure.MD5.hash(data: bytes)

	return result.map { $0 }
}
