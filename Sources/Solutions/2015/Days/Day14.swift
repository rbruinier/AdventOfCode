import Foundation
import Tools

final class Day14Solver: DaySolver {
	let dayNumber: Int = 14

	private var input: Input!

	private struct Input {
		let reindeer: [Reindeer]
	}

	private struct Reindeer {
		let name: String
		let speed: Int
		let duration: Int
		let rest: Int
	}

	private func calculateDistanceTraveled(for reindeer: Reindeer, time: Int) -> Int {
		let totalCycleDuration = reindeer.duration + reindeer.rest

		let nrOfCompleteCycles = time / totalCycleDuration
		let cycleRemainder = time % totalCycleDuration

		return ((nrOfCompleteCycles * reindeer.duration) + min(cycleRemainder, reindeer.duration)) * reindeer.speed
	}

	func solvePart1() -> Int {
		let time = 2503

		var best: (name: String, distance: Int) = (name: "", distance: Int.min)

		for reindeer in input.reindeer {
			let distance = calculateDistanceTraveled(for: reindeer, time: time)

			if distance > best.distance {
				best = (name: reindeer.name, distance: distance)
			}
		}

		return best.distance
	}

	func solvePart2() -> Int {
		let time = 2503

		var scores: [String: Int] = [:]

		for seconds in 1 ... time {
			var best: (name: String, distance: Int) = (name: "", distance: Int.min)

			for reindeer in input.reindeer {
				let distance = calculateDistanceTraveled(for: reindeer, time: seconds)

				if distance > best.distance {
					best = (name: reindeer.name, distance: distance)
				}
			}

			scores[best.name, default: 0] += 1
		}

		return scores.sorted(by: { $0.value > $1.value }).first!.value
	}

	func parseInput(rawString: String) {
		let reindeer: [Reindeer] = rawString.allLines().map { line in
			guard let parameters = line.getCapturedValues(pattern: #"([a-zA-Z]*) can fly ([0-9]*) km/s for ([0-9]*) seconds, but then must rest for ([0-9]*) seconds*"#) else {
				fatalError()
			}

			let name = parameters[0]
			let speed = Int(parameters[1])!
			let duration = Int(parameters[2])!
			let rest = Int(parameters[3])!

			return .init(name: name, speed: speed, duration: duration, rest: rest)
		}

		input = .init(reindeer: reindeer)
	}
}
