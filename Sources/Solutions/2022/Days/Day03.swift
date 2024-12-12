import Foundation
import Tools

final class Day03Solver: DaySolver {
	let dayNumber: Int = 3

	private var input: Input!

	private struct Input {
		let rucksacks: [Rucksack]
	}

	private struct Item: Hashable {
		let value: AsciiCharacter

		var priority: Int {
			if value.isLowerCase {
				1 + Int(value - AsciiCharacter.a)
			} else {
				27 + Int(value - AsciiCharacter.A)
			}
		}
	}

	private struct Rucksack {
		let aItems: [Item]
		let bItems: [Item]

		var allUniqueItems: [Item] {
			Array(Set(aItems + bItems))
		}

		var sharedItems: [Item] {
			let a = Set(aItems)
			let b = Set(bItems)

			return Array(a.intersection(b))
		}
	}

	init() {}

	func solvePart1() -> Int {
		input.rucksacks.reduce(0) {
			$0 + $1.sharedItems.map(\.priority).reduce(0, +)
		}
	}

	func solvePart2() -> Int {
		let nrOfGroups = input.rucksacks.count / 3

		var prioritySum = 0
		for groupIndex in 0 ..< nrOfGroups {
			let startIndex = groupIndex * 3
			let endIndex = startIndex + 3

			let rucksacks = input.rucksacks[startIndex ..< endIndex]

			var countByItem: [Item: Int] = [:]
			for rucksack in rucksacks {
				for item in rucksack.allUniqueItems {
					countByItem[item, default: 0] += 1
				}
			}

			prioritySum += countByItem.first(where: { $1 == 3 })!.key.priority
		}

		return prioritySum
	}

	func parseInput(rawString: String) {
		input = .init(rucksacks: rawString.allLines().map { line in
			let lineA = String(line[0 ..< line.count / 2])
			let lineB = String(line[line.count / 2 ..< line.count])

			return Rucksack(
				aItems: lineA.map { Item(value: AsciiCharacter($0)!) },
				bItems: lineB.map { Item(value: AsciiCharacter($0)!) }
			)
		})
	}
}
