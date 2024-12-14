import Foundation
import Tools

final class Day12Solver: DaySolver {
	let dayNumber: Int = 12

	struct Input {
		let rows: [Row]
	}

	enum State: Hashable {
		case operational
		case damaged
		case unknown
	}

	struct Row {
		let states: [State]
		let groups: [Int]
	}

	private struct MemoizationKey: Hashable {
		let key: Int

		init(states: [State], groups: [Int], isEndingAGroup: Bool) {
			var hasher = Hasher()

			hasher.combine(states)
			hasher.combine(groups)
			hasher.combine(isEndingAGroup)

			key = hasher.finalize()
		}
	}

	private typealias Memoization = [MemoizationKey: Int]

	private func numberOfValidArrangements(with arrangement: [State], groups: [Int], memoization: inout Memoization, isEndingAGroup: Bool = false) -> Int {
		let key = MemoizationKey(states: arrangement, groups: groups, isEndingAGroup: isEndingAGroup)

		if let cached = memoization[key] {
			return cached
		}

		// needed for memoization, so we can store it in the defer section
		var result = 0

		defer {
			memoization[key] = result
		}

		// if there are no states left and groups is empty we are good
		guard let firstState = arrangement.first else {
			result = groups.isEmpty ? 1 : 0

			return result
		}

		// if there are no groups left and there are no more damaged states we are good too
		guard let firstGroup = groups.first else {
			result = arrangement.contains(.damaged) ? 0 : 1

			return result
		}

		// if the first position is a operational state we can continue scanning the next states
		if firstState == .operational {
			result = numberOfValidArrangements(with: Array(arrangement[1 ..< arrangement.count]), groups: groups, memoization: &memoization)

			return result
		}

		// we now have either a unknown or damaged item as a first state

		// in case we we just finished a group we need to make sure the next isn't a damaged item, otherwise the group is too big and thus this is an invalid arrangement
		if isEndingAGroup {
			guard firstState != .damaged else {
				return 0
			}

			// we can keep on scanning as we are good, the question mark is turned into operational
			result = numberOfValidArrangements(with: Array(arrangement[1 ..< arrangement.count]), groups: groups, memoization: &memoization)

			return result
		}

		// make sure we have enough characters for the number of damaged we expect and check if that range only contains damaged or unknowns, in that case, yes, we found a group and it should be completed
		if firstGroup <= arrangement.count, !arrangement[0 ..< firstGroup].contains(.operational) {
			result += numberOfValidArrangements(
				with: Array(arrangement[firstGroup ..< arrangement.count]),
				groups: Array(groups[1 ..< groups.count]),
				memoization: &memoization,
				isEndingAGroup: true
			)
		}

		// if we have an unknown we run it again with the remaining states to see what else we can do
		if firstState == .unknown {
			result += numberOfValidArrangements(with: Array(arrangement[1 ..< arrangement.count]), groups: groups, memoization: &memoization)
		}

		return result
	}

	func solvePart1(withInput input: Input) -> Int {
		var memoization: Memoization = .init(minimumCapacity: 1_000_000)

		return input.rows.map {
			numberOfValidArrangements(with: $0.states, groups: $0.groups, memoization: &memoization)
		}.reduce(0, +)
	}

	func solvePart2(withInput input: Input) -> Int {
		var memoization: Memoization = .init(minimumCapacity: 1_000_000)

		return input.rows.map { row in
			var expandedArrangement: [State] = []
			var expandedGroups: [Int] = []

			for index in 0 ..< 5 {
				if index >= 1 {
					expandedArrangement.append(.unknown)
				}

				expandedArrangement.append(contentsOf: row.states)
				expandedGroups.append(contentsOf: row.groups)
			}

			return numberOfValidArrangements(with: expandedArrangement, groups: expandedGroups, memoization: &memoization)
		}.reduce(0, +)
	}

	func parseInput(rawString: String) -> Input {
		return .init(rows: rawString.allLines().map { line in
			let components = line.components(separatedBy: " ")

			let states: [State] = components[0].map {
				switch $0 {
				case ".": .operational
				case "#": .damaged
				case "?": .unknown
				default: preconditionFailure()
				}
			}

			return .init(states: states, groups: components[1].parseCommaSeparatedInts())
		})
	}
}
