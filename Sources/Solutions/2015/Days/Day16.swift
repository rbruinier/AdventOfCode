import Foundation
import Tools

final class Day16Solver: DaySolver {
	let dayNumber: Int = 16

	private var input: Input!

	private struct Input {
		let aunts: [Aunt]
	}

	private struct Aunt {
		let name: String
		let items: [String: Int]
	}

	private let auntItems: [String: Int] = [
		"children": 3,
		"cats": 7,
		"samoyeds": 2,
		"pomeranians": 3,
		"akitas": 0,
		"vizslas": 0,
		"goldfish": 5,
		"trees": 3,
		"cars": 2,
		"perfumes": 1,
	]

	func solvePart1() -> Int {
		var bestAunt: Aunt!
		var bestScore = Int.min

		for aunt in input.aunts {
			var fullMatchCount = 0
			var semiMatchCount = 0

			for (item, number) in auntItems {
				if let auntItemNumber = aunt.items[item] {
					if number == auntItemNumber {
						fullMatchCount += 1
					}
				} else {
					if number == 0 {
						semiMatchCount += 1
					}
				}
			}

			let score = fullMatchCount + semiMatchCount

			if score > bestScore {
				bestAunt = aunt
				bestScore = score
			}
		}

		return Int(bestAunt.name.replacingOccurrences(of: "Sue ", with: ""))!
	}

	func solvePart2() -> Int {
		var bestAunt: Aunt!
		var bestScore = Int.min

		for aunt in input.aunts {
			var fullMatchCount = 0
			var semiMatchCount = 0

			for (item, number) in auntItems {
				if let auntItemNumber = aunt.items[item] {
					if ["cats", "trees"].contains(item) {
						if auntItemNumber > number {
							fullMatchCount += 1
						}
					} else if ["pomeranians", "goldfish"].contains(item) {
						if auntItemNumber < number {
							fullMatchCount += 1
						}
					} else {
						if number == auntItemNumber {
							fullMatchCount += 1
						}
					}
				} else {
					if number == 0 {
						semiMatchCount += 1
					}
				}
			}

			let score = fullMatchCount + semiMatchCount

			if score > bestScore {
				bestAunt = aunt
				bestScore = score
			}
		}

		return Int(bestAunt.name.replacingOccurrences(of: "Sue ", with: ""))!
	}

	func parseInput(rawString: String) {
		let aunts: [Aunt] = rawString.allLines().map { line in
			let components = line.components(separatedBy: ": ")

			let items: [String: Int] = Dictionary(
				uniqueKeysWithValues:
				components[1 ..< components.count]
					.joined(separator: ": ")
					.components(separatedBy: ", ")
					.map { itemString in
						let parts = itemString.components(separatedBy: ": ")

						return (key: parts[0], value: Int(parts[1])!)
					}
			)

			return .init(name: components[0], items: items)
		}

		input = .init(aunts: aunts)
	}
}
