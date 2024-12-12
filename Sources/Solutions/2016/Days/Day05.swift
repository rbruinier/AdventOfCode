import CryptoKit
import Foundation
import Tools

final class Day05Solver: DaySolver {
	let dayNumber: Int = 5

	private var input: Input!

	private struct Input {
		let seed = "abbhdwsy"
	}

	// Optimized to only return the first 3 bytes of the hash (as we only need to check for five zero's)
	private func md5First3Bytes(with string: String) -> Int {
		let digest = Insecure.MD5.hash(data: string.data(using: .ascii)!)

		var result = 0
		for (index, value) in digest.makeIterator().enumerated() {
			result |= Int(value) << (8 * index)

			if index == 2 {
				break
			}
		}

		return result
	}

	func solvePart1() -> String {
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

	func solvePart2() -> String {
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
