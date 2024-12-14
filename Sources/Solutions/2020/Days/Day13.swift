import Foundation
import Tools

final class Day13Solver: DaySolver {
	let dayNumber: Int = 13

	struct Input {
		let earliestDepartureTime: Int
		let busIDs: [Int?]
	}

	func solvePart1(withInput input: Input) -> Int {
		var bestBusID = 0
		var bestInterval = Int.max

		for busID in input.busIDs.compactMap({ $0 }) {
			var busDepartureTime = (input.earliestDepartureTime / busID) * busID

			if busDepartureTime < input.earliestDepartureTime {
				busDepartureTime += busID
			}

			let interval = busDepartureTime - input.earliestDepartureTime

			if interval < bestInterval {
				bestInterval = interval
				bestBusID = busID
			}
		}

		return bestBusID * bestInterval
	}

	func solvePart2(withInput input: Input) -> Int {
		struct Bus {
			let minuteOffset: Int
			let interval: Int
		}

		let busses: [Bus] = input.busIDs.enumerated().compactMap { element in
			guard let busID = element.element else {
				return nil
			}

			return .init(minuteOffset: element.offset, interval: busID)
		}

		func matchingTime(time: Int, bus: Bus) -> Bool {
			((time + bus.minuteOffset) % bus.interval) == 0
		}

		var baseDepartureTime = 0
		var currentInterval = busses[0].interval

		// no brute force:
		// we find the minimum interval and base departure time incrementally for each bus, as each can only
		// be matched anyway if all previous busses are aligned
		// note: we might be able to calculate the intervals also with the Diophantine equation?
		for bus in busses[1 ..< busses.endIndex] {
			var departureTime = baseDepartureTime
			var firstMatch: Int?

			while true {
				departureTime += currentInterval

				if matchingTime(time: departureTime, bus: bus) {
					if let firstMatch {
						currentInterval = departureTime - firstMatch

						break
					} else {
						firstMatch = departureTime
						baseDepartureTime = departureTime
					}
				}
			}
		}

		return baseDepartureTime
	}

	func parseInput(rawString: String) -> Input {
		let lines = rawString.allLines()

		let earliestDepartureTime = Int(lines[0])!
		let busIDs = lines[1].components(separatedBy: ",").map { Int(String($0)) }

		return .init(earliestDepartureTime: earliestDepartureTime, busIDs: busIDs)
	}
}
