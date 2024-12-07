import Foundation

public protocol DaySolver {
	associatedtype Part1Result: Equatable
	associatedtype Part2Result: Equatable

	var customFilename: String? { get }

	var dayNumber: Int { get }
	var year: Int { get }

	var expectedPart1Result: Part1Result { get }
	var expectedPart2Result: Part2Result { get }

	func parseInput(rawString: String) async

	func solvePart1() async -> Part1Result
	func solvePart2() async -> Part2Result

	func createVisualizer() -> Visualizer?
}

public extension DaySolver {
	var customFilename: String? { nil }

	func createVisualizer() -> Visualizer? {
		nil
	}
}

private func == (_ lhs: some Equatable, _ rhs: some Equatable) -> Bool {
	if let lhsAsString = lhs as? String, let rhsAsString = rhs as? String {
		lhsAsString == rhsAsString
	} else if let lhsAsInt = lhs as? Int, let rhsAsInt = rhs as? Int {
		lhsAsInt == rhsAsInt
	} else {
		fatalError()
	}
}

private func != (_ lhs: some Equatable, _ rhs: some Equatable) -> Bool {
	(lhs == rhs) == false
}

private struct Result {
	let part1Correct: Bool
	let part2Correct: Bool
}

private func solveDay(_ solver: any DaySolver) async -> Result {
	print("Solving day \(solver.dayNumber):")

	// part 1
	var startTime = mach_absolute_time()

	let result1 = await solver.solvePart1()

	var formattedDuration = String(format: "%.5f", getSecondsFromMachTimer(duration: mach_absolute_time() - startTime))

	print(" -> part 1: \(result1). Solved in \(formattedDuration) seconds")

	if solver.expectedPart1Result != result1 {
		print(" -> ⛔️ part 1 expected result is: \(solver.expectedPart1Result).")
	}

	// part 2
	startTime = mach_absolute_time()

	let result2 = await solver.solvePart2()

	formattedDuration = String(format: "%.5f", getSecondsFromMachTimer(duration: mach_absolute_time() - startTime))

	print(" -> part 2: \(result2). Solved in \(formattedDuration) seconds")

	if solver.expectedPart2Result != result2 {
		print(" -> ⛔️ part 2 expected result is: \(solver.expectedPart2Result).")
	}

	return .init(
		part1Correct: solver.expectedPart1Result == result1,
		part2Correct: solver.expectedPart2Result == result2
	)
}

public func solveDays(_ allDays: [any DaySolver], dayNumber: Int? = nil, bundle: Bundle, customInputLoader: ((_ daySolver: any DaySolver, _ bundle: Bundle) -> String)? = nil) async {
	print("Parsing inputs")

	let days: [any DaySolver]

	if let dayNumber {
		days = allDays.filter { $0.dayNumber == dayNumber }
	} else {
		days = allDays
	}

	for day in days {
		if let customInputLoader {
			await day.parseInput(rawString: customInputLoader(day, bundle))
		} else {
			await day.parseInput(rawString: getRawInputStringFor(day: day.dayNumber, in: bundle))
		}
	}

	print("Start solving days")

	let startTime = mach_absolute_time()

	var timesPerDay: [Int: Double] = [:]
	var incorrectDays: [Int] = []

	for day in days {
		let dayStartTime = mach_absolute_time()

		let result = await solveDay(day)

		timesPerDay[day.dayNumber] = getSecondsFromMachTimer(duration: mach_absolute_time() - dayStartTime)

		if result.part1Correct == false || result.part2Correct == false {
			incorrectDays.append(day.dayNumber)
		}
	}

	let formattedDuration = String(format: "%.4f", getSecondsFromMachTimer(duration: mach_absolute_time() - startTime))

	print("⏱ Total running duration is \(formattedDuration) seconds")

	if incorrectDays.isNotEmpty {
		print("⛔️ There are incorrect days:")

		for day in incorrectDays {
			print(" -> Day \(day)")
		}
	}

	if timesPerDay.count >= 3 {
		print("🐌 Slowest days:")

		for (day, duration) in timesPerDay.sorted(by: { $0.value > $1.value }).prefix(upTo: 3) {
			print(String(format: " -> Day \(day) solved in %.4f seconds", duration))
		}
	}
}
