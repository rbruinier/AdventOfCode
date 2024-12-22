import Foundation
import Tools

final class Day22Solver: DaySolver {
	let dayNumber: Int = 22

	struct Input {
		let secrets: [Int]
	}

	private static func nextSecretNumber(for secret: Int) -> Int {
		var result = (secret ^ (secret * 64)) % 16777216

		result = (result ^ (result / 32)) % 16777216

		return (result ^ (result * 2048)) % 16777216
	}

	private static func sequenceAndPricesFor(secret startSecret: Int) -> (sequence: [Int], prices: [Int]) {
		var previousPrice = startSecret % 10
		var secret = startSecret

		var sequence: [Int] = .init(repeating: 0, count: 2000)
		var prices: [Int] = .init(repeating: 0, count: 2000)

		for index in 0 ..< 2000 {
			secret = Self.nextSecretNumber(for: secret)

			let price = secret % 10

			sequence[index] = price - previousPrice
			prices[index] = price

			previousPrice = price
		}

		return (sequence: sequence, prices: prices)
	}

	func solvePart1(withInput input: Input) -> Int {
		var result = 0

		for startSecret in input.secrets {
			var secret = startSecret

			for _ in 0 ..< 2000 {
				secret = Self.nextSecretNumber(for: secret)
			}

			result += secret
		}

		return result
	}

	func solvePart2(withInput input: Input) async -> Int {
		// precalculate all sequences and prices for each secret and its 2000 iterations
		var allSequences: [[Int]] = []
		var allPrices: [[Int]] = []

		for secret in input.secrets {
			let (sequence, prices) = Self.sequenceAndPricesFor(secret: secret)

			allSequences.append(sequence)
			allPrices.append(prices)
		}

		// note: index is a pattern of 4 elements but for performance reasons we use a hash of the pattern as key in the dictionary
		var global: [Int: Int] = [:]

		for (sequence, prices) in zip(allSequences, allPrices) {
			var foundPatternHashes: Set<Int> = []

			// we walk through the complete sequence and keep track of price per unique pattern
			for i in 0 ..< sequence.count - 4 {
				let pattern: [Int] = [sequence[i], sequence[i + 1], sequence[i + 2], sequence[i + 3]]

				let hash = pattern.hashValue

				if !foundPatternHashes.contains(hash) {
					foundPatternHashes.insert(hash)

					// we add the price per unique pattern into the global dictionary indexed by the hash of the pattern
					global[hash, default: 0] += prices[i + 3]
				}
			}
		}

		// return the highest value found
		return global.values.max()!
	}

	func parseInput(rawString: String) -> Input {
		.init(secrets: rawString.allLines().map { Int($0)! })
	}
}
