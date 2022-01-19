import Foundation
import Tools

final class Day11Solver: DaySolver {
    let dayNumber: Int = 11

    private var input: Input!

    private struct Input {
        let octopi: [Octopus]

        let width: Int
        let height: Int
    }

    private struct Octopus {
        var energyLevel: Int
    }

    private func incrementAt(y: Int, x: Int, width: Int, height: Int, octopi: inout [Octopus]) {
        let level = octopi[(y * width) + x].energyLevel + 1

        if level <= 10 {
            octopi[(y * width) + x].energyLevel = level
        }

        guard level == 10 else {
            return
        }

        for innerY in max(y - 1, 0) ... min(y + 1, height - 1) {
            for innerX in max(x - 1, 0) ... min(x + 1, width - 1) {
                if innerY == y && innerX == x {
                    continue
                }

                incrementAt(y: innerY, x: innerX, width: width, height: height, octopi: &octopi)
            }
        }
    }

    private func executeStep(octopi: inout [Octopus]) -> Int {
        // phase 1 is incrementing
        for y in 0 ..< input.height {
            for x in 0 ..< input.width {
                incrementAt(y: y, x: x, width: input.width, height: input.height, octopi: &octopi)
            }
        }

        var numberOfFlashes = 0

        // phase 2 is flashing and resetting
        for y in 0 ..< input.height {
            for x in 0 ..< input.width {
                if octopi[(y * input.width) + x].energyLevel >= 10 {
                    numberOfFlashes += 1

                    octopi[(y * input.width) + x].energyLevel = 0
                }
            }
        }

        return numberOfFlashes
    }

    func solvePart1() -> Any {
        var octopi = input.octopi

        var totalNumberOfFlashes = 0

        for _ in 0 ..< 100 {
            totalNumberOfFlashes += executeStep(octopi: &octopi)
        }

        return totalNumberOfFlashes
    }

    func solvePart2() -> Any {
        var octopi = input.octopi

        for step in 0 ..< Int.max {
            let numberOfFlashes = executeStep(octopi: &octopi)

            if numberOfFlashes == input.octopi.count {
                return step + 1
            }
        }

        return -1
    }

    func parseInput(rawString: String) {
        let height = rawString.filter { $0.isNewline }.count

        let octopi: [Octopus] = rawString
            .compactMap { Int(String($0)) }
            .map(Octopus.init(energyLevel:))

        let width = octopi.count / height

        input = .init(octopi: octopi, width: width, height: height)
    }
}
