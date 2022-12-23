import Darwin
import Foundation

public protocol DaySolver {
    associatedtype Part1Result: Equatable
    associatedtype Part2Result: Equatable

    var dayNumber: Int { get }
    var year: Int { get }

    func parseInput(rawString: String)

    func solvePart1() -> Part1Result
    func solvePart2() -> Part2Result

    func createVisualizer() -> Visualizer?
}

public protocol TestableDaySolver: DaySolver {
    var expectedPart1Result: Part1Result { get }
    var expectedPart2Result: Part2Result { get }
}

public extension DaySolver {
    func createVisualizer() -> Visualizer? {
        nil
    }
}

private func solveDay(_ solver: any DaySolver) {
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

public func solveDays(_ days: [any DaySolver], bundle: Bundle) {
	print("Parsing inputs")

	days.forEach { day in
		day.parseInput(rawString: getRawInputStringFor(day: day.dayNumber, in: bundle))
	}

	print("Start solving days")

	let startTime = mach_absolute_time()

	days.forEach { day in
		solveDay(day)
	}

	let formattedDuration = String(format: "%.4f", getSecondsFromMachTimer(duration: mach_absolute_time() - startTime))

	print("Total running duration is \(formattedDuration) seconds")
}
