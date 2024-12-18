import Foundation
import Tools

final class Day04Solver: DaySolver {
	let dayNumber: Int = 4

	struct Input {
		let events: [Event]
	}

	enum EventType {
		case beginsShift(id: Int)
		case fallsAsleep
		case wakesUp
	}

	struct Event {
		let timestamp: Int
		let type: EventType
	}

	private struct Shift: Hashable {
		let guardID: Int
		var asleepMinutes: [Int] = []
	}

	private func resolveGuardShifts(byEvents events: [Event]) -> [Int: [Shift]] {
		var shiftsPerGuard: [Int: [Shift]] = [:]

		var currentShift: Shift?
		var currentSleepStartMinute: Int?

		for event in events {
			switch event.type {
			case .beginsShift(let newGuardID):
				if let currentShift {
					shiftsPerGuard[currentShift.guardID, default: []].append(currentShift)
				}

				currentShift = Shift(guardID: newGuardID)
				currentSleepStartMinute = nil
			case .fallsAsleep:
				currentSleepStartMinute = event.timestamp % 60
			case .wakesUp:
				guard currentShift != nil, currentSleepStartMinute != nil else {
					fatalError()
				}

				for minute in currentSleepStartMinute! ..< (event.timestamp % 60) {
					currentShift!.asleepMinutes.append(minute)
				}

				currentSleepStartMinute = nil
			}
		}

		if let currentShift {
			shiftsPerGuard[currentShift.guardID, default: []].append(currentShift)
		}

		return shiftsPerGuard
	}

	func solvePart1(withInput input: Input) -> Int {
		let shiftsPerGuard = resolveGuardShifts(byEvents: input.events)

		// find guard with most minutes asleep
		var guardsSleepMinutes: [Int: Int] = [:]

		for (guardID, shifts) in shiftsPerGuard {
			guardsSleepMinutes[guardID] = shifts.reduce(0) { $0 + $1.asleepMinutes.count }
		}

		let sleepiestGuardID = guardsSleepMinutes.sorted(by: { $0.value > $1.value }).first!.key

		// find minute with most sleeps for this guard
		var asleepMinuteCounter: [Int: Int] = [:]

		for shift in shiftsPerGuard[sleepiestGuardID]! {
			for minute in shift.asleepMinutes {
				asleepMinuteCounter[minute, default: 0] += 1
			}
		}

		let bestMinute = asleepMinuteCounter.sorted(by: { $0.value > $1.value }).first!.key

		return sleepiestGuardID * bestMinute
	}

	func solvePart2(withInput input: Input) -> Int {
		let shiftsPerGuard = resolveGuardShifts(byEvents: input.events)

		var perMinuteGuardCounters: [Int: [Int: Int]] = [:]

		for (guardID, shifts) in shiftsPerGuard {
			for shift in shifts {
				for minute in shift.asleepMinutes {
					var guardCounters = perMinuteGuardCounters[minute, default: [:]]

					guardCounters[guardID, default: 0] += 1

					perMinuteGuardCounters[minute] = guardCounters
				}
			}
		}

		var bestGuardID: Int?
		var bestMinute: Int?
		var bestAmount: Int?

		for (minute, guardCounters) in perMinuteGuardCounters {
			guard let guardID = guardCounters.sorted(by: { $0.value > $1.value }).first?.key else {
				continue
			}

			let amount = guardCounters[guardID]!

			if bestAmount == nil || (bestAmount != nil && amount > bestAmount!) {
				bestAmount = amount
				bestGuardID = guardID
				bestMinute = minute
			}
		}

		return bestGuardID! * bestMinute!
	}

	func parseInput(rawString: String) -> Input {
		func parseTimestamp(_ values: [String]) -> Int {
			let month = Int(values[0])!
			let day = Int(values[1])!
			let hour = Int(values[2])!
			let minute = Int(values[3])!

			let dayCount = 24 * 60
			let monthCount = 31 * dayCount

			return (month * monthCount) + (day * dayCount) + (hour * 60) + minute
		}

		let events: [Event] = rawString.allLines().map { line in
			if let values = line.getCapturedValues(pattern: ##"\[1518-([0-9]*)-([0-9]*) ([0-9]*):([0-9]*)\] Guard \#([0-9]*) begins shift"##) {
				.init(timestamp: parseTimestamp(values), type: .beginsShift(id: Int(values[4])!))
			} else if let values = line.getCapturedValues(pattern: #"\[1518-([0-9]*)-([0-9]*) ([0-9]*):([0-9]*)\] falls asleep"#) {
				.init(timestamp: parseTimestamp(values), type: .fallsAsleep)
			} else if let values = line.getCapturedValues(pattern: #"\[1518-([0-9]*)-([0-9]*) ([0-9]*):([0-9]*)\] wakes up"#) {
				.init(timestamp: parseTimestamp(values), type: .wakesUp)
			} else {
				fatalError()
			}
		}

		return .init(events: events.sorted(by: { $0.timestamp < $1.timestamp }))
	}
}
