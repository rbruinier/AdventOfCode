import CryptoKit
import Foundation
import Tools

final class Day04Solver: DaySolver {
	let dayNumber: Int = 4

	private var input: Input!

	private struct Input {
		let key = "bgvyzdsv"
	}

	private var cachedStartIndex = 0

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

	func solvePart1() -> Int {
		for i in cachedStartIndex ..< 1_000_000 {
			let number = md5First3Bytes(with: input.key + String(i))

			if (number & 0xF0FFFF) == 0 {
				cachedStartIndex = i

				return i
			}
		}

		return 0
	}

	func solvePart2() -> Int {
		for i in cachedStartIndex ..< 10_000_000 {
			let number = md5First3Bytes(with: input.key + String(i))

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
