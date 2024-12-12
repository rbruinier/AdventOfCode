import Foundation
import Tools

final class Day12Solver: DaySolver {
	let dayNumber: Int = 12

	private var input: Input!

	private struct Input {
		let json: String
	}

	private func sumOfAllDigits(in content: Any, exludeRed: Bool = false) -> Int {
		var sum = 0

		if let asInt = content as? Int {
			sum += asInt
		} else if let asDictionary = content as? [String: Any] {
			if exludeRed == false || (asDictionary.values.contains(where: { $0 as? String == "red" }) == false) {
				for (_, value) in asDictionary {
					sum += sumOfAllDigits(in: value, exludeRed: exludeRed)
				}
			}
		} else if let asArray = content as? [Any] {
			for value in asArray {
				sum += sumOfAllDigits(in: value, exludeRed: exludeRed)
			}
		}

		return sum
	}

	func solvePart1() -> Int {
		let content = try! JSONSerialization.jsonObject(with: input.json.data(using: .ascii)!, options: [])

		return sumOfAllDigits(in: content)
	}

	func solvePart2() -> Int {
		let content = try! JSONSerialization.jsonObject(with: input.json.data(using: .ascii)!, options: [])

		return sumOfAllDigits(in: content, exludeRed: true)
	}

	func parseInput(rawString: String) {
		input = .init(json: rawString.trimmingCharacters(in: .whitespacesAndNewlines))
	}
}
