import Foundation
import Tools

final class Day19Solver: DaySolver {
	let dayNumber: Int = 19

	private var input: Input!

	private struct Input {
		let workflows: [String: Workflow]
		let parts: [Part]
	}

	private enum PartPiece: String, RawRepresentable {
		case x
		case m
		case a
		case s
	}

	private struct Part {
		let ratings: [PartPiece: Int]

		var sum: Int {
			ratings.values.reduce(0, +)
		}
	}

	private enum Conditional {
		case smallerThan(piece: PartPiece, value: Int, destination: Destination)
		case greaterThan(piece: PartPiece, value: Int, destination: Destination)
		case unconditionally(destination: Destination)
	}

	private enum Destination {
		case workflow(id: String)
		case accepted
		case rejected

		init(rawValue: String) {
			switch rawValue {
			case "A": self = .accepted
			case "R": self = .rejected
			default: self = .workflow(id: rawValue)
			}
		}
	}

	private struct Workflow {
		var conditions: [Conditional]
	}

	private struct Ranges {
		var valid: [PartPiece: ClosedRange<Int>] = [:]

		init() {
			valid[.x] = 1 ... 4000
			valid[.m] = 1 ... 4000
			valid[.a] = 1 ... 4000
			valid[.s] = 1 ... 4000
		}

		var product: Int {
			valid.values.map(\.count).reduce(1, *)
		}

		struct Split {
			let passingRanges: Ranges
			let remainingRanges: Ranges
		}

		func split(piece: PartPiece, below splitIndex: Int) -> Split {
			let originalRange = valid[piece]!

			var passingRanges = self
			var remainingRanges = self

			passingRanges.valid[piece]! = originalRange.lowerBound ... splitIndex - 1
			remainingRanges.valid[piece]! = splitIndex ... originalRange.upperBound

			return .init(passingRanges: passingRanges, remainingRanges: remainingRanges)
		}

		func split(piece: PartPiece, above splitIndex: Int) -> Split {
			let originalRange = valid[piece]!

			var passingRanges = self
			var remainingRanges = self

			passingRanges.valid[piece]! = splitIndex + 1 ... originalRange.upperBound
			remainingRanges.valid[piece]! = originalRange.lowerBound ... splitIndex

			return .init(passingRanges: passingRanges, remainingRanges: remainingRanges)
		}
	}

	private func isAccepted(part: Part, workflows: [String: Workflow], destination: Destination, conditionsIndex: Int = 0) -> Int {
		let startWorkflowID: String

		switch destination {
		case .accepted: return part.sum
		case .rejected: return 0
		case .workflow(let id): startWorkflowID = id
		}

		let workflow = input.workflows[startWorkflowID]!
		let condition = workflow.conditions[conditionsIndex]

		switch condition {
		case .unconditionally(let destination):
			return isAccepted(part: part, workflows: workflows, destination: destination)
		case .greaterThan(let piece, let value, let destination):
			if part.ratings[piece]! > value {
				return isAccepted(part: part, workflows: workflows, destination: destination)
			} else {
				return isAccepted(part: part, workflows: workflows, destination: .workflow(id: startWorkflowID), conditionsIndex: conditionsIndex + 1)
			}
		case .smallerThan(let piece, let value, let destination):
			if part.ratings[piece]! < value {
				return isAccepted(part: part, workflows: workflows, destination: destination)
			} else {
				return isAccepted(part: part, workflows: workflows, destination: .workflow(id: startWorkflowID), conditionsIndex: conditionsIndex + 1)
			}
		}
	}

	private func solveRanges(_ ranges: Ranges, workflows: [String: Workflow], destination: Destination, conditionIndex: Int = 0) -> Int {
		let startWorkflowID: String

		switch destination {
		case .accepted: return ranges.product
		case .rejected: return 0
		case .workflow(let id): startWorkflowID = id
		}

		let workflow = input.workflows[startWorkflowID]!
		let condition = workflow.conditions[conditionIndex]

		switch condition {
		case .unconditionally(let destination):
			return solveRanges(ranges, workflows: workflows, destination: destination)
		case .greaterThan(let piece, let value, let destination):
			let split = ranges.split(piece: piece, above: value)

			return solveRanges(split.passingRanges, workflows: workflows, destination: destination)
				+ solveRanges(split.remainingRanges, workflows: workflows, destination: .workflow(id: startWorkflowID), conditionIndex: conditionIndex + 1)
		case .smallerThan(let piece, let value, let destination):
			let split = ranges.split(piece: piece, below: value)

			return solveRanges(split.passingRanges, workflows: workflows, destination: destination)
				+ solveRanges(split.remainingRanges, workflows: workflows, destination: .workflow(id: startWorkflowID), conditionIndex: conditionIndex + 1)
		}
	}

	func solvePart1() -> Int {
		input.parts.map { isAccepted(part: $0, workflows: input.workflows, destination: .workflow(id: "in")) }.reduce(0, +)
	}

	func solvePart2() -> Int {
		solveRanges(.init(), workflows: input.workflows, destination: .workflow(id: "in"))
	}

	func parseInput(rawString: String) {
		var workflows: [String: Workflow] = [:]
		var parts: [Part] = []

		var parsingWorkflows = true
		for line in rawString.allLines(includeEmpty: true) {
			if line.isEmpty {
				parsingWorkflows = false

				continue
			}

			if parsingWorkflows {
				let components = line.components(separatedBy: "{")

				let workflowID = components[0]
				var conditions: [Conditional] = []

				for rawConditional in components[1].dropLast().components(separatedBy: ",") {
					if let parameters = rawConditional.getCapturedValues(pattern: #"([a-z]*)<([0-9]*):([a-zA-Z]*)"#) {
						conditions.append(.smallerThan(piece: .init(rawValue: parameters[0])!, value: Int(parameters[1])!, destination: .init(rawValue: parameters[2])))
					} else if let parameters = rawConditional.getCapturedValues(pattern: #"([a-z]*)>([0-9]*):([a-zA-Z]*)"#) {
						conditions.append(.greaterThan(piece: .init(rawValue: parameters[0])!, value: Int(parameters[1])!, destination: .init(rawValue: parameters[2])))
					} else {
						conditions.append(.unconditionally(destination: .init(rawValue: rawConditional)))
					}
				}

				workflows[workflowID] = .init(conditions: conditions)
			} else {
				let parameters = line.getCapturedValues(pattern: #"\{x=([0-9]*),m=([0-9]*),a=([0-9]*),s=([0-9]*)\}"#)!

				parts.append(.init(ratings: [
					.x: Int(parameters[0])!,
					.m: Int(parameters[1])!,
					.a: Int(parameters[2])!,
					.s: Int(parameters[3])!,
				]))
			}
		}

		input = .init(workflows: workflows, parts: parts)
	}
}
