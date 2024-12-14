import Foundation
import Tools

// Part one brute force, part two by using the quadratic equation
final class Day06Solver: DaySolver {
	let dayNumber: Int = 6

	struct Input {
		let races: [Race]
	}

	struct Race {
		let time: Int
		let distance: Int
	}

	func solvePart1(withInput input: Input) -> Int {
		var result = 1

		for race in input.races {
			var winCounter = 0

			for holdTime in 1 ..< race.time {
				let moveTime = race.time - holdTime
				let distance = moveTime * holdTime

				if distance > race.distance {
					winCounter += 1
				}
			}

			result *= winCounter
		}

		return result
	}

	func solvePart2(withInput input: Input) -> Int {
		let totalTime = Int(input.races.map(\.time).map { String($0) }.joined())!
		let totalDistance = Int(input.races.map(\.distance).map { String($0) }.joined())!

		// (totalTime - Th) * Th > totalDistance
		// Th^2 - totalTime*Th - totalDistance > 0

		let b = -totalTime
		let c = totalDistance
		let d = sqrt(Double((b * b) - (4 * c)))

		let w1 = (-b + Int(floor(d))) / 2
		let w2 = (-b - Int(ceil(d))) / 2

		return w1 - w2
	}

	func parseInput(rawString: String) -> Input {
		let timesLine = rawString.allLines()[0].components(separatedBy: ": ")[1].trimmingCharacters(in: .whitespaces)
		let distancesLine = rawString.allLines()[1].components(separatedBy: ": ")[1].trimmingCharacters(in: .whitespaces)

		let times = timesLine.components(separatedBy: " ").map { $0.trimmingCharacters(in: .whitespaces) }.compactMap(Int.init)
		let distances = distancesLine.components(separatedBy: " ").map { $0.trimmingCharacters(in: .whitespaces) }.compactMap(Int.init)

		guard times.count == distances.count else {
			preconditionFailure()
		}

		return .init(races: zip(times, distances).map { Race(time: $0, distance: $1) })
	}
}
