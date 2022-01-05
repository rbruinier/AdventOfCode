import Foundation

final class Day13Solver: DaySolver {
    let dayNumber: Int = 13

    private var input: Input!

    private struct Input {
        let earliestDepartureTime: Int
        let busIds: [Int?]
    }

    func solvePart1() -> Any {
        var bestBusId = 0
        var bestInterval = Int.max

        for busId in input.busIds.compactMap({ $0 }) {
            var busDepartureTime = (input.earliestDepartureTime / busId) * busId

            if busDepartureTime < input.earliestDepartureTime {
                busDepartureTime += busId
            }

            let interval = busDepartureTime - input.earliestDepartureTime

            if interval < bestInterval {
                bestInterval = interval
                bestBusId = busId
            }
        }

        return bestBusId * bestInterval
    }

    func solvePart2() -> Any {
        struct Bus {
            let minuteOffset: Int
            let interval: Int
        }

        let busses: [Bus] = input.busIds.enumerated().compactMap { element in
            guard let busId = element.element else {
                return nil
            }

            return .init(minuteOffset: element.offset, interval: busId)
        }

        func matchingTime(time: Int, bus: Bus) -> Bool {
            return ((time + bus.minuteOffset) % bus.interval) == 0
        }

        var baseDepartureTime = 0
        var currentInterval = busses[0].interval

        // no brute force:
        // we find the minimum interval and base departure time incrementally for each bus, as each can only
        // be matched anyway if all previous busses are aligned
        // note: we might be able to calculate the intervals also with the Diophantine equation?
        for bus in busses[1 ..< busses.endIndex] {
            var departureTime = baseDepartureTime
            var firstMatch: Int? = nil

            while true {
                departureTime += currentInterval

                if matchingTime(time: departureTime, bus: bus) {
                    if let firstMatch = firstMatch {
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

    func parseInput(rawString: String) {
        let lines = rawString.allLines()

        let earliestDepartureTime = Int(lines[0])!
        let busIds = lines[1].components(separatedBy: ",").map { Int(String($0)) }

        input = .init(earliestDepartureTime: earliestDepartureTime, busIds: busIds)
    }
}
