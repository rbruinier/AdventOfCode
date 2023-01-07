import Foundation
import Tools

final class Day04Solver: DaySolver {
    let dayNumber: Int = 4

    let expectedPart1Result = 14346
    let expectedPart2Result = 5705

    private var input: Input!

    private struct Input {
        let events: [Event]
    }

    private enum EventType {
        case beginsShift(id: Int)
        case fallsAsleep
        case wakesUp
    }

    private struct Event {
        let timestamp: Int
        let type: EventType
    }

    private struct Shift: Hashable {
        let guardId: Int
        var asleepMinutes: [Int] = []
    }

    private func resolveGuardShifts(byEvents events: [Event]) -> [Int: [Shift]] {
        var shiftsPerGuard: [Int: [Shift]] = [:]

        var currentShift: Shift?
        var currentSleepStartMinute: Int?

        for event in events {
            switch event.type {
            case .beginsShift(let newGuardId):
                if let currentShift {
                    shiftsPerGuard[currentShift.guardId, default: []].append(currentShift)
                }

                currentShift = Shift(guardId: newGuardId)
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
            shiftsPerGuard[currentShift.guardId, default: []].append(currentShift)
        }

        return shiftsPerGuard
    }

    func solvePart1() -> Int {
        let shiftsPerGuard = resolveGuardShifts(byEvents: input.events)

        // find guard with most minutes asleep
        var guardsSleepMinutes: [Int: Int] = [:]

        for (guardId, shifts) in shiftsPerGuard {
            guardsSleepMinutes[guardId] = shifts.reduce(0) { $0 + $1.asleepMinutes.count }
        }

        let sleepiestGuardId = guardsSleepMinutes.sorted(by: { $0.value > $1.value }).first!.key

        // find minute with most sleeps for this guard
        var asleepMinuteCounter: [Int: Int] = [:]

        for shift in shiftsPerGuard[sleepiestGuardId]! {
            for minute in shift.asleepMinutes {
                asleepMinuteCounter[minute, default: 0] += 1
            }
        }

        let bestMinute = asleepMinuteCounter.sorted(by: { $0.value > $1.value }).first!.key

        return sleepiestGuardId * bestMinute
    }

    func solvePart2() -> Int {
        let shiftsPerGuard = resolveGuardShifts(byEvents: input.events)

        var perMinuteGuardCounters: [Int: [Int: Int]] = [:]

        for (guardId, shifts) in shiftsPerGuard {
            for shift in shifts {
                for minute in shift.asleepMinutes {
                    var guardCounters = perMinuteGuardCounters[minute, default: [:]]

                    guardCounters[guardId, default: 0] += 1

                    perMinuteGuardCounters[minute] = guardCounters
                }
            }
        }

        var bestGuardId: Int?
        var bestMinute: Int?
        var bestAmount: Int?

        for (minute, guardCounters) in perMinuteGuardCounters {
            guard let guardId = guardCounters.sorted(by: { $0.value > $1.value }).first?.key else {
                continue
            }

            let amount = guardCounters[guardId]!

            if bestAmount == nil || (bestAmount != nil && amount > bestAmount!) {
                bestAmount = amount
                bestGuardId = guardId
                bestMinute = minute
            }
        }

        return bestGuardId! * bestMinute!
    }

    func parseInput(rawString: String) {
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
                return .init(timestamp: parseTimestamp(values), type: .beginsShift(id: Int(values[4])!))
            } else if let values = line.getCapturedValues(pattern: #"\[1518-([0-9]*)-([0-9]*) ([0-9]*):([0-9]*)\] falls asleep"#) {
                return .init(timestamp: parseTimestamp(values), type: .fallsAsleep)
            } else if let values = line.getCapturedValues(pattern: #"\[1518-([0-9]*)-([0-9]*) ([0-9]*):([0-9]*)\] wakes up"#) {
                return .init(timestamp: parseTimestamp(values), type: .wakesUp)
            } else {
                fatalError()
            }
        }

        input = .init(events: events.sorted(by: { $0.timestamp < $1.timestamp }))
    }
}
