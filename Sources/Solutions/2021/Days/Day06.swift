import Foundation
import Tools

final class Day06Solver: DaySolver {
    let dayNumber: Int = 6

    private var input: Input!

    private struct Input {
        let initialTimers: [Int]
    }

    private struct AgeGroup {
        var nrOfFish: Int = 0
    }

    private func runFor(iterations: Int) -> Int {
        var ageGroups: [AgeGroup] = Array(repeating: .init(), count: 9)

        for input in input.initialTimers {
            ageGroups[input].nrOfFish += 1
        }

        for _ in 0 ..< iterations {
            var newAgeGroups: [AgeGroup] = Array(repeating: .init(), count: 9)

            for age in stride(from: 8, through: 0, by: -1) {
                if age >= 1 {
                    newAgeGroups[age - 1].nrOfFish = ageGroups[age].nrOfFish
                } else {
                    newAgeGroups[8].nrOfFish = ageGroups[0].nrOfFish
                    newAgeGroups[6].nrOfFish += ageGroups[0].nrOfFish
                }
            }

            ageGroups = newAgeGroups
        }

        return ageGroups.reduce(0) { result, group in
            result + group.nrOfFish
        }
    }

    func solvePart1() -> Any {
        return runFor(iterations: 80)
    }

    func solvePart2() -> Any {
        return runFor(iterations: 256)
    }

    func parseInput(rawString: String) {
        let rawNumbers = rawString
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
            .compactMap { Int($0) }

        input = .init(initialTimers: rawNumbers)
    }
}
