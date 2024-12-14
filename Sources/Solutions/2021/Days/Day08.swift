import Foundation
import Tools

final class Day08Solver: DaySolver {
	let dayNumber: Int = 8

	struct Input {
		let entries: [Entry]
	}

	private enum Segment: String, CaseIterable, Equatable, CustomDebugStringConvertible {
		case a
		case b
		case c
		case d
		case e
		case f
		case g

		var debugDescription: String {
			rawValue
		}
	}

	private struct Digit: Equatable {
		let segments: Set<Segment>

		var nrOfSegments: Int {
			segments.count
		}

		static func == (lhs: Digit, rhs: Digit) -> Bool {
			lhs.segments.isSubset(of: rhs.segments) && rhs.segments.isSubset(of: lhs.segments)
		}
	}

	private struct Entry {
		let uniqueDigits: [Digit]
		let outputDigits: [Digit]
	}

	private func segments(in a: Digit, butNotIn b: [Digit]) -> [Segment] {
		let bSegments: Set<Segment> = Set(b.flatMap(\.segments))

		return a.segments.filter { bSegments.contains($0) == false }
	}

	private func segments(in a: Digit, andIn b: [Digit]) -> [Segment] {
		let bSegments: Set<Segment> = Set(b.flatMap(\.segments))

		return a.segments.filter { bSegments.contains($0) }
	}

	private func findDigitWithSegments(_ segments: Set<Segment>, in digits: [Digit]) -> Digit? {
		digits.first {
			$0.segments.isSubset(of: segments) && segments.isSubset(of: $0.segments)
		}
	}

	func solvePart1(withInput input: Input) -> Int {
		let occurencesOfOne = input.entries.reduce(0) { result, entry in
			result + entry.outputDigits.filter { $0.segments.count == 2 }.count
		}

		let occurencesOfFour = input.entries.reduce(0) { result, entry in
			result + entry.outputDigits.filter { $0.segments.count == 4 }.count
		}

		let occurencesOfSeven = input.entries.reduce(0) { result, entry in
			result + entry.outputDigits.filter { $0.segments.count == 3 }.count
		}

		let occurencesOfEight = input.entries.reduce(0) { result, entry in
			result + entry.outputDigits.filter { $0.segments.count == 7 }.count
		}

		return occurencesOfOne + occurencesOfFour + occurencesOfSeven + occurencesOfEight
	}

	func solvePart2(withInput input: Input) -> Int {
		var result = 0

		for entry in input.entries {
			let mustBeOne = entry.uniqueDigits.first(where: { $0.nrOfSegments == 2 })!
			let mustBeFour = entry.uniqueDigits.first(where: { $0.nrOfSegments == 4 })!
			let mustBeSeven = entry.uniqueDigits.first(where: { $0.nrOfSegments == 3 })!
			let mustBeEight = entry.uniqueDigits.first(where: { $0.nrOfSegments == 7 })!

			let cAndFSegment = Array(mustBeOne.segments)
			let bAndDSegment = segments(in: mustBeFour, butNotIn: [mustBeOne])

			// 968175

			var zeroSegmentsA: Set<Segment> = Set(Segment.allCases)
			var zeroSegmentsB: Set<Segment> = Set(Segment.allCases)

			zeroSegmentsA.remove(bAndDSegment[0])
			zeroSegmentsB.remove(bAndDSegment[1])

			let mustBeZero: Digit
			let bSegment: Segment
			let dSegment: Segment

			if let digit = findDigitWithSegments(zeroSegmentsA, in: entry.uniqueDigits) {
				mustBeZero = digit
				dSegment = bAndDSegment[0]
				bSegment = bAndDSegment[1]
			} else if let digit = findDigitWithSegments(zeroSegmentsB, in: entry.uniqueDigits) {
				mustBeZero = digit
				bSegment = bAndDSegment[0]
				dSegment = bAndDSegment[1]
			} else {
				fatalError("Does not match")
			}

			let mustBeFive = entry.uniqueDigits.first {
				$0.nrOfSegments == 5 && $0.segments.contains(bSegment)
			}!

			let cSegment: Segment
			let fSegment: Segment

			if mustBeFive.segments.contains(cAndFSegment[0]) {
				fSegment = cAndFSegment[0]
				cSegment = cAndFSegment[1]
			} else {
				cSegment = cAndFSegment[0]
				fSegment = cAndFSegment[1]
			}

			let mustBeSix = entry.uniqueDigits.first {
				$0.nrOfSegments == 6 && $0.segments.contains(fSegment) && $0.segments.contains(cSegment) == false
			}!

			let mustBeNine = entry.uniqueDigits.first {
				$0.nrOfSegments == 6 && $0.segments.contains(cSegment) && $0.segments.contains(fSegment) && $0.segments.contains(dSegment)
			}!

			let mustBeTwo = entry.uniqueDigits.first {
				$0.nrOfSegments == 5 && $0.segments.contains(cSegment) && $0.segments.contains(fSegment) == false
			}!

			let mustBeThree = entry.uniqueDigits.first {
				$0.nrOfSegments == 5 && $0.segments.contains(cSegment) && $0.segments.contains(fSegment)
			}!

			let mappedDigits: [Digit] = [
				mustBeZero, mustBeOne, mustBeTwo, mustBeThree, mustBeFour, mustBeFive, mustBeSix, mustBeSeven, mustBeEight, mustBeNine,
			]

			let number = entry.outputDigits.reduce(0) { result, digit in
				(result * 10) + mappedDigits.firstIndex { $0 == digit }!
			}

			result += number
		}

		return result
	}

	func parseInput(rawString: String) -> Input {
		let rawLines = rawString
			.components(separatedBy: CharacterSet.newlines)
			.filter { $0.isEmpty == false }

		var entries: [Entry] = []

		for rawLine in rawLines {
			let lineComponents = rawLine.components(separatedBy: " | ")

			let uniqueDigitsreturn lineComponents[0].components(separatedBy: CharacterSet.whitespaces)
			let fourDigitOuput = lineComponents[1].components(separatedBy: CharacterSet.whitespaces)

			let uniqueDigits: [Digit] = uniqueDigitsInput.map { digits in
				Digit(segments: Set(digits.compactMap { Segment(rawValue: String($0)) }))
			}

			let outputDigits: [Digit] = fourDigitOuput.map { digits in
				Digit(segments: Set(digits.compactMap { Segment(rawValue: String($0)) }))
			}

			entries.append(.init(uniqueDigits: uniqueDigits, outputDigits: outputDigits))
		}

		return .init(entries: entries)
	}
}
