import Foundation
import Tools

final class Day02Solver: DaySolver {
	let dayNumber: Int = 2

	struct Input {
		let passwords: [Password]
	}

	struct Password {
		var policyRange: ClosedRange<Int>
		var policyCharacter: String

		var password: String

		var isValidWithPolicy1: Bool {
			policyRange.contains(password.filter { String($0) == policyCharacter }.count)
		}

		var isValidWithPolicy2: Bool {
			let matchCount: Int = ((String(password[password.index(password.startIndex, offsetBy: policyRange.lowerBound - 1)]) == policyCharacter) ? 1 : 0)
				+ ((String(password[password.index(password.startIndex, offsetBy: policyRange.upperBound - 1)]) == policyCharacter) ? 1 : 0)

			return matchCount == 1
		}
	}

	func solvePart1(withInput input: Input) -> Int {
		input.passwords.filter(\.isValidWithPolicy1).count
	}

	func solvePart2(withInput input: Input) -> Int {
		input.passwords.filter(\.isValidWithPolicy2).count
	}

	func parseInput(rawString: String) -> Input {
		let capturePattern = #"([0-9]*)-([0-9]*) ([a-z]*): ([a-z]*)"#
		let captureRegex = try! NSRegularExpression(pattern: capturePattern, options: [])

		let passwords: [Password] = rawString.allLines().compactMap { line in
			guard let match = captureRegex.matches(in: line, options: [], range: NSRange(line.startIndex ..< line.endIndex, in: line)).first else {
				return nil
			}

			let policyRangeLowerBounds = Int(line[Range(match.range(at: 1), in: line)!])!
			let policyRangeUpperBounds = Int(line[Range(match.range(at: 2), in: line)!])!
			let policyCharacter = String(line[Range(match.range(at: 3), in: line)!])
			let password = String(line[Range(match.range(at: 4), in: line)!])

			return .init(policyRange: policyRangeLowerBounds ... policyRangeUpperBounds, policyCharacter: policyCharacter, password: password)
		}

		return .init(passwords: passwords)
	}
}
