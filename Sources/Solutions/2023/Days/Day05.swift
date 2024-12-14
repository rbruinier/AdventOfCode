import Collections
import Foundation
import Tools

/*
 First solved part 2 brute-force and that took 90 seconds. Nice to have the correct answer but performance is also important
 so instead I built a solver based on finding overlapping ranges, recursively down the layers.
 */
final class Day05Solver: DaySolver {
	let dayNumber: Int = 5

	struct Input {
		let seeds: [Int]
		var allRanges: [[Mapping]]
	}

	struct Mapping {
		let destinationRange: ClosedRange<Int>
		let sourceRange: ClosedRange<Int>
	}

	private func mapValue(_ value: Int, withRanges ranges: [Mapping]) -> Int {
		for range in ranges {
			if range.sourceRange.contains(value) {
				return value - range.sourceRange.lowerBound + range.destinationRange.lowerBound
			}
		}

		return value
	}

	private func mapSeedRange(_ seedRange: ClosedRange<Int>, withRanges allRanges: [[Mapping]]) -> [ClosedRange<Int>] {
		guard let ranges = allRanges.first else {
			preconditionFailure()
		}

		var remainingRanges: Deque<ClosedRange<Int>> = [seedRange]
		var mappedSeedRanges: [ClosedRange<Int>] = []

		remainingRangesLoop: while let remainingRange = remainingRanges.popFirst() {
			for range in ranges where range.sourceRange.overlaps(remainingRange) {
				// whatever is below this range we clip it
				if remainingRange.lowerBound < range.sourceRange.lowerBound {
					remainingRanges.append(remainingRange.lowerBound ... range.sourceRange.lowerBound - 1)
				}

				// whatever is above this range we clip it
				if remainingRange.upperBound > range.sourceRange.upperBound {
					remainingRanges.append(range.sourceRange.upperBound + 1 ... remainingRange.upperBound)
				}

				let remainingLowerbound = max(remainingRange.lowerBound, range.sourceRange.lowerBound) - range.sourceRange.lowerBound + range.destinationRange.lowerBound
				let remainingUpperbound = min(remainingRange.upperBound, range.sourceRange.upperBound) - range.sourceRange.lowerBound + range.destinationRange.lowerBound

				let newSeedRange = remainingLowerbound ... remainingUpperbound

				if allRanges.count == 1 {
					mappedSeedRanges.append(newSeedRange)
				} else {
					mappedSeedRanges.append(contentsOf: mapSeedRange(newSeedRange, withRanges: Array(allRanges[1 ..< allRanges.count])))
				}

				continue remainingRangesLoop
			}

			// apparently there was no hit, the range wont be mapped
			if allRanges.count == 1 {
				mappedSeedRanges.append(remainingRange)
			} else {
				mappedSeedRanges.append(contentsOf: mapSeedRange(remainingRange, withRanges: Array(allRanges[1 ..< allRanges.count])))
			}
		}

		return mappedSeedRanges
	}

	func solvePart1(withInput input: Input) -> Int {
		let allRanges = input.allRanges

		var locations: [Int] = []

		for seed in input.seeds {
			var mappedValue = seed

			for mappings in allRanges {
				mappedValue = mapValue(mappedValue, withRanges: mappings)
			}

			locations.append(mappedValue)
		}

		return locations.min()!
	}

	func solvePart2(withInput input: Input) -> Int {
		let allRanges = input.allRanges

		var seedRanges: [ClosedRange<Int>] = []

		for index in stride(from: 0, to: input.seeds.count, by: 2) {
			seedRanges.append(
				input.seeds[index] ... (input.seeds[index] + input.seeds[index + 1] - 1)
			)
		}

		var minValue = Int.max

		for seedRange in seedRanges {
			let locationRanges = mapSeedRange(seedRange, withRanges: allRanges)

			minValue = min(minValue, locationRanges.map(\.lowerBound).min()!)
		}

		return minValue
	}

	func parseInput(rawString: String) -> Input {
		var groupIndex = 0

		var seeds: [Int] = []
		var allRanges: [[Mapping]] = .init(repeating: [], count: 7)

		func readMapping(fromLine line: String) -> Mapping? {
			let components = line.components(separatedBy: " ")

			guard 
				components.count == 3,
				let destinationStart = Int(components[0]),
				let sourceStart = Int(components[1]),
				let length = Int(components[2]),
				length > 0
			else {
				return nil
			}

			return Mapping(
				destinationRange: destinationStart ... (destinationStart + length - 1),
				sourceRange: sourceStart ... (sourceStart + length - 1)
			)
		}

		for originalLine in rawString.allLines(includeEmpty: true) {
			if originalLine.isEmpty {
				groupIndex += 1

				continue
			}

			let line = originalLine.trimmingCharacters(in: .whitespacesAndNewlines)

			switch groupIndex {
			case 0: seeds = line.components(separatedBy: ": ")[1].components(separatedBy: " ").compactMap(Int.init)
			case 1 ... 7:
				if let mapping = readMapping(fromLine: line) {
					allRanges[groupIndex - 1].append(mapping)
				}
			default: preconditionFailure()
			}
		}

		return .init(
			seeds: seeds,
			allRanges: allRanges
		)
	}
}
