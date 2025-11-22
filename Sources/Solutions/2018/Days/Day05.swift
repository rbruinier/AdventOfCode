import Foundation
import Tools

final class Day05Solver: DaySolver {
	let dayNumber: Int = 5

	struct Input {
		let polymer: [AsciiCharacter]
	}

	private func reactPolymer(_ polymer: [AsciiCharacter]) -> [AsciiCharacter] {
		var currentPolymer = polymer

		var index = 0
		while index < currentPolymer.count - 1 {
			if
				currentPolymer[index].caseInsensitiveEqualTo(currentPolymer[index + 1]),
				currentPolymer[index].isLowerCase != currentPolymer[index + 1].isLowerCase
			{
				currentPolymer.remove(at: index)
				currentPolymer.remove(at: index)

				index = max(0, index - 1)
			} else {
				index += 1
			}
		}

		return currentPolymer
	}

	func solvePart1(withInput input: Input) -> Int {
		reactPolymer(input.polymer).count
	}

	func solvePart2(withInput input: Input) -> Int {
		var lowestCount = Int.max

		for lowerCase in AsciiCharacter.a ... AsciiCharacter.z {
			var currentPolymer = input.polymer

			let upperCase = lowerCase.upperCased

			currentPolymer.removeAll(where: { $0 == lowerCase || $0 == upperCase })

			let count = reactPolymer(currentPolymer).count

			lowestCount = min(count, lowestCount)
		}

		return lowestCount
	}

	func parseInput(rawString: String) -> Input {
		.init(polymer: rawString.allLines().first!.map { AsciiCharacter($0)! })
	}
}
