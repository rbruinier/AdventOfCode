import Foundation

public protocol DaySolver {
	associatedtype Part1Result: Equatable
	associatedtype Part2Result: Equatable

	associatedtype Input: Any

	var customFilename: String? { get }

	var dayNumber: Int { get }

	func parseInput(rawString: String) async -> Input

	func parseExpectedResults(rawString: String) async -> ExpectedResults

	func solvePart1(withInput input: Input) async -> Part1Result
	func solvePart2(withInput input: Input) async -> Part2Result

	func createVisualizer() -> Visualizer?
}

public struct YearSolver {
	fileprivate struct AnySolver {
		let dayNumber: Int
		let solve: (_ bundle: Bundle) async -> Result
	}

	let year: Int

	fileprivate var solvers: [AnySolver] = []

	public init(year: Int) {
		self.year = year
	}

	public mutating func addSolver(_ daySolver: some DaySolver) {
		solvers.append(.init(
			dayNumber: daySolver.dayNumber,
			solve: { [year] bundle in
				await solveDay(daySolver, year: year, bundle: bundle)
			}
		))
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

private func solveDay(_ solver: some DaySolver, year: Int, bundle: Bundle) async -> Result {
	print("Solving day \(solver.dayNumber):")

	print(" - parsing input and expected results")

	let input = await solver.parseInput(rawString: getRawInputStringFor(day: solver.dayNumber, year: year, in: bundle))
	let expectedResults = await solver.parseExpectedResults(rawString: getRawExpectedResultsStringFor(day: solver.dayNumber, year: year, in: bundle))

	// part 1
	var startTime = mach_absolute_time()

	let result1 = await solver.solvePart1(withInput: input)

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

	let result2 = await solver.solvePart2(withInput: input)

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

	print("Start solving days")

	let startTime = mach_absolute_time()

	var timesPerDay: [Int: Double] = [:]
	var incorrectDays: [Int] = []

	for daySolver in yearSolver.solvers.filter({ dayNumber != nil ? $0.dayNumber == dayNumber! : true }) {
		let dayStartTime = mach_absolute_time()

		let result = await daySolver.solve(bundle)

		timesPerDay[daySolver.dayNumber] = getSecondsFromMachTimer(duration: mach_absolute_time() - dayStartTime)

		if result.part1Correct == false || result.part2Correct == false {
			incorrectDays.append(daySolver.dayNumber)
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
