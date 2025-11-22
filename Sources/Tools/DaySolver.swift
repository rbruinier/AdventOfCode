import Foundation

public typealias CustomInputReader = (_ day: any DaySolver, _ bundle: Bundle) -> String

public protocol DaySolver {
	associatedtype Part1Result: Equatable
	associatedtype Part2Result: Equatable

	associatedtype Input: Any

	var numberOfParts: Int { get }

	var customFilename: String? { get }

	var dayNumber: Int { get }

	func parseInput(rawString: String) async -> Input

	func solvePart1(withInput input: Input) async -> Part1Result
	func solvePart2(withInput input: Input) async -> Part2Result

	func createVisualizer() -> Visualizer?

	func solvePart(_ part: Int, withInput input: Input) async -> any Equatable
}

public extension DaySolver {
	var numberOfParts: Int {
		2
	}

	func solvePart(_ part: Int, withInput input: Input) async -> any Equatable {
		switch part {
		case 1: await solvePart1(withInput: input)
		case 2: await solvePart2(withInput: input)
		default: fatalError()
		}
	}
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

	public mutating func addSolver(_ daySolver: some DaySolver, customInputReader: CustomInputReader? = nil) {
		solvers.append(.init(
			dayNumber: daySolver.dayNumber,
			solve: { [year] bundle in
				await solveMultiPartDay(daySolver, year: year, bundle: bundle, customInputReader: customInputReader)
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

func parseExpectedResults(rawString: String) async -> ExpectedResults {
	ExpectedResults(
		parts: rawString.allLines().map { line in
			if line.count >= 2, String(line.first!) == "\"", String(line.last!) == "\"" {
				String(line[1 ..< line.count - 1])
			} else {
				Int(line) ?? line
			}
		}
	)
}

public struct ExpectedResults {
	let parts: [any Equatable]
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
	let partsCorrect: [Bool]
}

private func solveMultiPartDay(_ solver: some DaySolver, year: Int, bundle: Bundle, customInputReader: CustomInputReader? = nil) async -> Result {
	print("Solving day \(solver.dayNumber):")

	print(" - parsing input and expected results")

	let rawString: String

	if let customInputReader {
		rawString = customInputReader(solver, bundle)
	} else {
		rawString = getRawInputStringFor(day: solver.dayNumber, year: year, in: bundle)
	}

	let input = await solver.parseInput(rawString: rawString)
	let expectedResults = await parseExpectedResults(rawString: getRawExpectedResultsStringFor(day: solver.dayNumber, year: year, in: bundle))

	var partsCorrect: [Bool] = []

	for partIndex in 1 ... solver.numberOfParts {
		guard let expectedResult = expectedResults.parts[safe: partIndex - 1] else {
			preconditionFailure("Missing expected result for part \(partIndex)")
		}

		let startTime = mach_absolute_time()

		let result = await solver.solvePart(partIndex, withInput: input)

		let formattedDuration = String(format: "%.5f", getSecondsFromMachTimer(duration: mach_absolute_time() - startTime))

		let correctResult = result == expectedResult

		print(" - part 1:")
		print("   -> result: \(result) \(correctResult ? "✅" : "⛔")")

		if !correctResult {
			print("   -> expected result is: \(expectedResult)")
		}

		partsCorrect.append(correctResult)

		print("   -> duration: \(formattedDuration) seconds")
	}

	return Result(partsCorrect: partsCorrect)
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

		if result.partsCorrect.contains(false) {
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
