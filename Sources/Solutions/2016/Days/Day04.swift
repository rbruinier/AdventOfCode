import Foundation
import Tools

final class Day04Solver: DaySolver {
	let dayNumber: Int = 4

	private var input: Input!

	private struct Input {
		let entries: [Entry]
	}

	private var validEntries: [Entry]!

	private struct Entry {
		var name: String
		let sectorID: Int
		let checksum: String

		var isValid: Bool {
			var countPerCharacter: [Character: Int] = [:]

			for character in name where character != "-" {
				countPerCharacter[character, default: 0] += 1
			}

			let sorted = countPerCharacter.sorted(by: { lhs, rhs in
				if lhs.value == rhs.value {
					lhs.key < rhs.key
				} else {
					lhs.value > rhs.value
				}
			})

			for (character, _) in sorted[0 ..< 5] {
				if checksum.contains(character) == false {
					return false
				}
			}

			return true
		}

		var nameShifted: Entry {
			let name = name.map { character in
				guard character != "-" else {
					return "-"
				}

				let newCharacter = (((Int(character.asciiValue!) - 97) + sectorID) % 26) + 97

				return String(bytes: [UInt8(newCharacter)], encoding: .ascii)!
			}.joined()

			return .init(name: name, sectorID: sectorID, checksum: checksum)
		}
	}

	func solvePart1() -> Int {
		validEntries = input.entries.filter(\.isValid)

		return validEntries.map(\.sectorID).reduce(0, +)
	}

	func solvePart2() -> Int {
		let entries = validEntries.map(\.nameShifted)

		return entries.first(where: { $0.name == "northpole-object-storage" })!.sectorID
	}

	func parseInput(rawString: String) {
		input = .init(entries: rawString.allLines().map { line in
			let values = line.getCapturedValues(pattern: #"([a-z-]*)\-([0-9]*)\[([a-z]*)\]"#)!

			let name = values[0] // .replacingOccurrences(of: "-", with: "")

			return .init(name: name, sectorID: Int(values[1])!, checksum: values[2])
		})
	}
}
