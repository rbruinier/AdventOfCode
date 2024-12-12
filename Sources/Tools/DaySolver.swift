import Foundation

public protocol DaySolver {
	associatedtype Part1Result: Equatable
	associatedtype Part2Result: Equatable

	var customFilename: String? { get }

	var dayNumber: Int { get }

	func parseInput(rawString: String) async

	func parseExpectedResults(rawString: String) async -> ExpectedResults

	func solvePart1() async -> Part1Result
	func solvePart2() async -> Part2Result

	func createVisualizer() -> Visualizer?
}

public struct YearSolver {
	let year: Int
	let days: [any DaySolver]

	public init(year: Int, days: [any DaySolver]) {
		self.year = year
		self.days = days
	}
}

public extension DaySolver {
	var customFilename: String? { nil }

	func createVisualizer() -> Visualizer? {
		nil
	}
}

public extension DaySolver {
	func parseExpectedResults(rawString: String) async -> ExpectedResults {
		let lines = rawString.allLines()

		guard lines.count == 2 else {
			preconditionFailure()
		}

		let result1: any Equatable
		let result2: any Equatable

		if lines[0].count >= 2, String(lines[0].first!) == "\"", String(lines[0].last!) == "\"" {
			result1 = String(lines[0][1 ..< lines[0].count - 1])
		} else {
			result1 = Int(lines[0]) ?? lines[0]
		}

		if lines[1].count >= 2, String(lines[1].first!) == "\"", String(lines[1].last!) == "\"" {
			result2 = String(lines[1][1 ..< lines[1].count - 1])
		} else {
			result2 = Int(lines[1]) ?? lines[1]
		}

		return ExpectedResults(part1: result1, part2: result2)
	}
}

public struct ExpectedResults {
	let part1: any Equatable
	let part2: any Equatable
}

private func == (_ lhs: some Equatable, _ rhs: some Equatable) -> Bool {
	if let lhsAsString = lhs as? String, let rhsAsString = rhs as? String {
		return lhsAsString == rhsAsString
	} else if let lhsAsInt = lhs as? Int, let rhsAsInt = rhs as? Int {
		return lhsAsInt == rhsAsInt
	} else {
		let lhsAsString = String(describing: lhs)
		let rhsAsString = String(describing: rhs)

		return lhsAsString == rhsAsString
	}
}

private func != (_ lhs: some Equatable, _ rhs: some Equatable) -> Bool {
	(lhs == rhs) == false
}

private struct Result {
	let part1Correct: Bool
	let part2Correct: Bool
}

private func solveDay(_ solver: any DaySolver, expectedResults: ExpectedResults) async -> Result {
	print("Solving day \(solver.dayNumber):")

	// part 1
	var startTime = mach_absolute_time()

	let result1 = await solver.solvePart1()

	var formattedDuration = String(format: "%.5f", getSecondsFromMachTimer(duration: mach_absolute_time() - startTime))

	let correctResult1 = expectedResults.part1 == result1

	print(" - part 1:")
	print("   -> result: \(result1) \(correctResult1 ? "✅" : "⛔")")

	if !correctResult1 {
		print("   -> expected result is: \(expectedResults.part1)")
	}

	print("   -> duration: \(formattedDuration) seconds")

	// part 2
	startTime = mach_absolute_time()

	let result2 = await solver.solvePart2()

	formattedDuration = String(format: "%.5f", getSecondsFromMachTimer(duration: mach_absolute_time() - startTime))

	let correctResult2 = expectedResults.part2 == result2

	print(" - part 2:")
	print("   -> result: \(result2) \(correctResult2 ? "✅" : "⛔")")

	if !correctResult2 {
		print(" -> ⛔️ part 2 expected result is: \(expectedResults.part2)")
	}

	print("   -> duration: \(formattedDuration) seconds")

	return .init(
		part1Correct: correctResult1,
		part2Correct: correctResult2
	)
}

public func solveYear(_ yearSolver: YearSolver, dayNumber: Int? = nil, bundle: Bundle) async {
	print("Advent of Code \(yearSolver.year) 🎄")

	print("Parsing inputs")

	let days: [any DaySolver]

	if let dayNumber {
		days = yearSolver.days.filter { $0.dayNumber == dayNumber }
	} else {
		days = yearSolver.days
	}

	print("Parsing expected results")

	var expectedResults: [Int: ExpectedResults] = [:]

	for day in days {
//		if let customInputLoader {
//			let rawString = customInputLoader(day, bundle)
//
//			await day.parseInput(rawString: rawString)
//		} else {
		await day.parseInput(rawString: getRawInputStringFor(day: day.dayNumber, year: yearSolver.year, in: bundle))
//		}

		expectedResults[day.dayNumber] = await day.parseExpectedResults(rawString: getRawExpectedResultsStringFor(day: day.dayNumber, year: yearSolver.year, in: bundle))
	}

	print("Start solving days")

	let startTime = mach_absolute_time()

	var timesPerDay: [Int: Double] = [:]
	var incorrectDays: [Int] = []

	for day in days {
		let dayStartTime = mach_absolute_time()

		let result = await solveDay(day, expectedResults: expectedResults[day.dayNumber]!)

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

//
// public func solveDays(_ allDays: [any DaySolver], dayNumber: Int? = nil, bundle: Bundle, customInputLoader: ((_ daySolver: any DaySolver, _ bundle: Bundle) -> String)? = nil) async {
//	print("Parsing inputs")
//
//	let days: [any DaySolver]
//
//	if let dayNumber {
//		days = allDays.filter { $0.dayNumber == dayNumber }
//	} else {
//		days = allDays
//	}
//
//	print("Parsing expected results")
//
//	var expectedResults: [Int: ExpectedResults] = [:]
//
//	for day in days {
//		if let customInputLoader {
//			let rawString = customInputLoader(day, bundle)
//
//			await day.parseInput(rawString: rawString)
//		} else {
//			await day.parseInput(rawString: getRawInputStringFor(day: day.dayNumber, year: day.year, in: bundle))
//		}
//
//		expectedResults[day.dayNumber] = await day.parseExpectedResults(rawString: getRawExpectedResultsStringFor(day: day.dayNumber, year: day.year, in: bundle))
//	}
//
//	print("Start solving days")
//
//	let startTime = mach_absolute_time()
//
//	var timesPerDay: [Int: Double] = [:]
//	var incorrectDays: [Int] = []
//
//	for day in days {
//		let dayStartTime = mach_absolute_time()
//
//		let result = await solveDay(day, expectedResults: expectedResults[day.dayNumber]!)
//
//		timesPerDay[day.dayNumber] = getSecondsFromMachTimer(duration: mach_absolute_time() - dayStartTime)
//
//		if result.part1Correct == false || result.part2Correct == false {
//			incorrectDays.append(day.dayNumber)
//		}
//	}
//
//	let formattedDuration = String(format: "%.4f", getSecondsFromMachTimer(duration: mach_absolute_time() - startTime))
//
//	print("⏱ Total running duration is \(formattedDuration) seconds")
//
//	if incorrectDays.isNotEmpty {
//		print("⛔️ There are incorrect days:")
//
//		for day in incorrectDays {
//			print(" -> Day \(day)")
//		}
//	}
//
//	if timesPerDay.count >= 3 {
//		print("🐌 Slowest days:")
//
//		for (day, duration) in timesPerDay.sorted(by: { $0.value > $1.value }).prefix(upTo: 3) {
//			print(String(format: " -> Day \(day) solved in %.4f seconds", duration))
//		}
//	}
// }
