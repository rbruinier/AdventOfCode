import Collections
import Foundation
import Tools

final class Day14Solver: DaySolver {
	let dayNumber: Int = 14

	private typealias Hash = [UInt8]

	struct Input {
		let salt = "ihaygndm"
	}

	private func firstTripletCharacter(in hash: Hash) -> UInt8? {
		var repeatCount = 1

		for i in 1 ..< 32 {
			if hash[i - 1] == hash[i] {
				repeatCount += 1
			} else {
				repeatCount = 1
			}

			if repeatCount == 3 {
				return hash[i]
			}
		}

		return nil
	}

	private func containsFiveInARow(of character: UInt8, in hash: Hash) -> Bool {
		var repeatCount = 0

		for i in 0 ..< 32 {
			if hash[i] == character {
				repeatCount += 1
			} else {
				repeatCount = 0
			}

			if repeatCount == 5 {
				return true
			}
		}

		return false
	}

	func solvePart1(withInput input: Input) -> Int {
		var hashQueue: Deque<Hash> = []

		var index = 0
		for _ in 0 ... 1000 {
			hashQueue.append(md5AsBytes(with: [UInt8]("\(input.salt)\(index)".data(using: .ascii)!)).asNibbles)

			index += 1
		}

		var searchIndex = 0
		var numberOfKeys = 0
		while true {
			let hash = hashQueue.popFirst()!

			if let tripletCharacter = firstTripletCharacter(in: hash) {
				if
					hashQueue.contains(where: { hash in
						containsFiveInARow(of: tripletCharacter, in: hash)
					})
				{
					numberOfKeys += 1

					if numberOfKeys == 64 {
						return searchIndex
					}
				}
			}

			hashQueue.append(md5AsBytes(with: [UInt8]("\(input.salt)\(index)".data(using: .ascii)!)).asNibbles)

			index += 1
			searchIndex += 1
		}
	}

	func solvePart2(withInput input: Input) -> Int {
		func calcHash(for string: String) -> Hash {
			var value = md5AsBytes(with: [UInt8](string.data(using: .ascii)!))

			for _ in 0 ..< 2016 {
				value = md5AsBytes(with: value.bytesAsHexAscii)
			}

			return value.asNibbles
		}

		var hashQueue: Deque<Hash> = []

		var index = 0
		for _ in 0 ... 1000 {
			hashQueue.append(calcHash(for: "\(input.salt)\(index)"))

			index += 1
		}

		var searchIndex = 0
		var numberOfKeys = 0
		while true {
			let hash = hashQueue.popFirst()!

			if let tripletCharacter = firstTripletCharacter(in: hash) {
				if
					hashQueue.contains(where: { hash in
						containsFiveInARow(of: tripletCharacter, in: hash)
					})
				{
					numberOfKeys += 1

					if numberOfKeys == 64 {
						return searchIndex
					}
				}
			}

			hashQueue.append(calcHash(for: "\(input.salt)\(index)"))

			index += 1
			searchIndex += 1
		}
	}

	func parseInput(rawString: String) -> Input {
		.init()
	}
}
