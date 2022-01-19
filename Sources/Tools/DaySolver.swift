import Foundation
import Darwin

public protocol DaySolver {
    var dayNumber: Int { get }

    func parseInput(rawString: String)
    
    func solvePart1() -> Any
    func solvePart2() -> Any
}

public func solveDay(_ solver: DaySolver) {
    print("Solving day \(solver.dayNumber)")

    // part 1
    var startTime = mach_absolute_time()

    var result = solver.solvePart1()

    var formattedDuration = String(format: "%.4f", getSecondsFromMachTimer(duration: mach_absolute_time() - startTime))

    print(" -> part 1: \(result). Solved in \(formattedDuration) seconds")

    // part 2
    startTime = mach_absolute_time()

    result = solver.solvePart2()

    formattedDuration = String(format: "%.4f", getSecondsFromMachTimer(duration: mach_absolute_time() - startTime))

    print(" -> part 2: \(result). Solved in \(formattedDuration) seconds")
}
