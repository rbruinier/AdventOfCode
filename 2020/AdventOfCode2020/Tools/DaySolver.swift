import Foundation
import Darwin

protocol DaySolver {
    var dayNumber: Int { get }

    func parseInput(rawString: String)
    
    func solvePart1() -> Any
    func solvePart2() -> Any
}

enum Part {
    case part1
    case part2
}

func solveDay(_ solver: DaySolver, parts: [Part] = [.part1, .part2]) {
    print("Solving day \(solver.dayNumber)")

    if parts.contains(.part1) {
        let startTime = mach_absolute_time()

        let result = solver.solvePart1()

        let formattedDuration = String(format: "%.4f", getSecondsFromMachTimer(duration: mach_absolute_time() - startTime))

        print(" -> part 1: \(result). Solved in \(formattedDuration) seconds")
    }

    if parts.contains(.part2) {
        let startTime = mach_absolute_time()

        let result = solver.solvePart2()

        let formattedDuration = String(format: "%.4f", getSecondsFromMachTimer(duration: mach_absolute_time() - startTime))

        print(" -> part 2: \(result). Solved in \(formattedDuration) seconds")
    }
}
