import Foundation
import Tools

final class Day25Solver: DaySolver {
	let dayNumber: Int = 25

	private var input: Input!

	private struct Input {
		let cardPublicKey: Int
		let doorPublicKey: Int
	}

	private func loopSizeFor(publicKey: Int) -> Int? {
		var value = 1

		// captain brute force to the rescue
		for loopSize in 1 ... 1_000_000_000 {
			value = (value * 7) % 20201227

			if value == publicKey {
				return loopSize
			}
		}

		return nil
	}

	private func transform(subjectNumber: Int, loopSize: Int) -> Int {
		var value = 1

		for _ in 0 ..< loopSize {
			value *= subjectNumber
			value %= 20201227
		}

		return value
	}

	func solvePart1() -> Int {
		guard
			let cardLoopSize = loopSizeFor(publicKey: input.cardPublicKey),
			let doorLoopSize = loopSizeFor(publicKey: input.doorPublicKey)
		else {
			fatalError()
		}

		let cardEncryptionKey = transform(subjectNumber: input.cardPublicKey, loopSize: doorLoopSize)
		let doorEncryptionKey = transform(subjectNumber: input.doorPublicKey, loopSize: cardLoopSize)

		if cardEncryptionKey != doorEncryptionKey {
			fatalError()
		}

		return cardEncryptionKey
	}

	func solvePart2() -> String {
		"Merry Christmas 🎄"
	}

	func parseInput(rawString: String) {
		input = .init(cardPublicKey: 6929599, doorPublicKey: 2448427)
	}
}
