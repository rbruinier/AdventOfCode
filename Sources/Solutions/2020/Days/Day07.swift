import Foundation
import Tools

final class Day07Solver: DaySolver {
	let dayNumber: Int = 7

	private var input: Input!

	private struct Input {
		let bags: [String: Bag]
	}

	private struct Bag {
		let id: String

		let subBags: [String: Int]
	}

	private func bag(_ bag: Bag, canContain bagID: String, allBags: [String: Bag]) -> Bool {
		if bag.subBags.keys.contains(bagID) {
			return true
		}

		for subBagID in bag.subBags.keys {
			let subBag = allBags[subBagID]!

			if self.bag(subBag, canContain: bagID, allBags: allBags) {
				return true
			}
		}

		return false
	}

	private func subBagCountFor(bag: Bag, allBags: [String: Bag]) -> Int {
		if bag.subBags.isEmpty {
			return 0
		}

		var sum = 0
		for (subBagID, quantity) in bag.subBags {
			let subBag = allBags[subBagID]!

			sum += quantity + (quantity * subBagCountFor(bag: subBag, allBags: allBags))
		}

		return sum
	}

	func solvePart1() -> Int {
		input.bags.values.filter {
			bag($0, canContain: "shiny gold bag", allBags: input.bags)
		}.count
	}

	func solvePart2() -> Int {
		let bag = input.bags["shiny gold bag"]!

		return subBagCountFor(bag: bag, allBags: input.bags)
	}

	func parseInput(rawString: String) {
		let lines = rawString.allLines()

		var bags: [String: Bag] = [:]

		lines.forEach {
			let components = $0.components(separatedBy: " contain ")

			let bagID = components[0].replacingOccurrences(of: "bags", with: "bag")

			var subBags: [String: Int] = [:]
			for rule in components[1].components(separatedBy: ", ") {
				if rule == "no other bags." {
					break
				}

				let quantity = Int(String(rule.first!))!
				let containedBagID = rule[rule.index(rule.startIndex, offsetBy: 2) ..< rule.endIndex]
					.replacingOccurrences(of: "bags", with: "bag")
					.replacingOccurrences(of: ".", with: "")

				subBags[containedBagID] = quantity
			}

			bags[bagID] = .init(id: bagID, subBags: subBags)
		}

		input = .init(bags: bags)
	}
}
