import Foundation
import Tools

final class Day16Solver: DaySolver {
	let dayNumber: Int = 16

	struct Input {
		let samples: [Sample]
		let programLines: [[Int]]
	}

	struct Sample {
		let beforeRegisterValues: [Int]
		let afterRegisterValues: [Int]

		let operationAndOperands: [Int]
	}

	private enum Operation: CaseIterable {
		case addr
		case addi
		case mulr
		case muli
		case banr
		case bani
		case borr
		case bori
		case setr
		case seti
		case gtir
		case gtri
		case gtrr
		case eqir
		case eqri
		case eqrr

		func executeOn(registers: [Int], operands: [Int]) -> [Int] {
			var result = registers

			let srcAIndex = operands[0]
			let srcBIndex = operands[1]
			let destIndex = operands[2]

			let aValue = operands[0]
			let bValue = operands[1]

			switch self {
			case .addr: result[destIndex] = registers[srcAIndex] + registers[srcBIndex]
			case .addi: result[destIndex] = registers[srcAIndex] + bValue
			case .mulr: result[destIndex] = registers[srcAIndex] * registers[srcBIndex]
			case .muli: result[destIndex] = registers[srcAIndex] * bValue
			case .banr: result[destIndex] = registers[srcAIndex] & registers[srcBIndex]
			case .bani: result[destIndex] = registers[srcAIndex] & bValue
			case .borr: result[destIndex] = registers[srcAIndex] | registers[srcBIndex]
			case .bori: result[destIndex] = registers[srcAIndex] | bValue
			case .setr: result[destIndex] = registers[srcAIndex]
			case .seti: result[destIndex] = aValue
			case .gtir: result[destIndex] = aValue > registers[srcBIndex] ? 1 : 0
			case .gtri: result[destIndex] = registers[srcAIndex] > bValue ? 1 : 0
			case .gtrr: result[destIndex] = registers[srcAIndex] > registers[srcBIndex] ? 1 : 0
			case .eqir: result[destIndex] = aValue == registers[srcBIndex] ? 1 : 0
			case .eqri: result[destIndex] = registers[srcAIndex] == bValue ? 1 : 0
			case .eqrr: result[destIndex] = registers[srcAIndex] == registers[srcBIndex] ? 1 : 0
			}

			return result
		}
	}

	private func testOperation(_ operation: Operation, withNumber operationNumber: Int, samples: [Sample]) -> Bool {
		for sample in samples where sample.operationAndOperands[0] == operationNumber {
			let after = operation.executeOn(registers: sample.beforeRegisterValues, operands: Array(sample.operationAndOperands[1 ... 3]))

			if after != sample.afterRegisterValues {
				return false
			}
		}

		return true
	}

	private func deduceOperations(_ operations: [Operation], availableNumbers: Set<Int>, samples: [Sample], matchingOperations: [Int: Operation] = [:]) -> [Int: Operation] {
		guard let operation = operations.first else {
			return matchingOperations
		}

		for operationNumber in availableNumbers where testOperation(operation, withNumber: operationNumber, samples: samples) {
			// we branch all fitting options in a search tree
			var newMatchingOperations = matchingOperations

			newMatchingOperations[operationNumber] = operation

			let result = deduceOperations(
				Array(operations[1 ..< operations.count]),
				availableNumbers: availableNumbers.filter { $0 != operationNumber },
				samples: samples,
				matchingOperations: newMatchingOperations
			)

			// exit if we found all 16 matches
			if result.count == 16 {
				return result
			}
		}

		return [:]
	}

	func solvePart1(withInput input: Input) -> Int {
		var matchingSamplesCounter = 0

		for sample in input.samples {
			var matchingOperationCounter = 0

			for operation in Operation.allCases {
				let after = operation.executeOn(registers: sample.beforeRegisterValues, operands: Array(sample.operationAndOperands[1 ... 3]))

				if after == sample.afterRegisterValues {
					matchingOperationCounter += 1
				}
			}

			if matchingOperationCounter >= 3 {
				matchingSamplesCounter += 1
			}
		}

		return matchingSamplesCounter
	}

	func solvePart2(withInput input: Input) -> Int {
		// as many operations could be multiple operation numbers we have to try all combinations
		let operands = deduceOperations(Operation.allCases, availableNumbers: Set(0 ... 15), samples: input.samples)

		var registers: [Int] = [0, 0, 0, 0]

		for programLine in input.programLines {
			registers = operands[programLine[0]]!.executeOn(registers: registers, operands: Array(programLine[1 ... 3]))
		}

		return registers[0]
	}

	func parseInput(rawString: String) -> Input {
		let lines = rawString.allLines()

		var lineIndex = 0
		var samples: [Sample] = []
		var programLines: [[Int]] = []

		while lineIndex < lines.count {
			if let beforeMatch = lines[lineIndex].getCapturedValues(pattern: #"Before: \[([0-9]*), ([0-9]*), ([0-9]*), ([0-9]*)\]"#) {
				let operationAndOperandsMatch = lines[lineIndex + 1].getCapturedValues(pattern: #"([0-9]*) ([0-9]*) ([0-9]*) ([0-9]*)"#)!
				let afterMatch = lines[lineIndex + 2].getCapturedValues(pattern: #"After:  *\[([0-9]*), ([0-9]*), ([0-9]*), ([0-9]*)\]"#)!

				samples.append(.init(
					beforeRegisterValues: beforeMatch.compactMap(Int.init),
					afterRegisterValues: afterMatch.compactMap(Int.init),
					operationAndOperands: operationAndOperandsMatch.compactMap(Int.init)
				))

				lineIndex += 3
			} else {
				guard let operationAndOperandsMatch = lines[lineIndex].getCapturedValues(pattern: #"([0-9]*) ([0-9]*) ([0-9]*) ([0-9]*)"#) else {
					preconditionFailure()
				}

				programLines.append(operationAndOperandsMatch.compactMap(Int.init))

				lineIndex += 1
			}
		}

		return .init(samples: samples, programLines: programLines)
	}
}
