import Foundation
import Tools

final class Day07Solver: DaySolver {
	let dayNumber: Int = 7

	struct Input {
		// can begin letter -> needs to be finished set of letters
		let relations: [String: Set<String>]
	}

	/// Resolves open start nodes and adds them to the relations.
	private func allRelationsAndEndNode(relations: [String: Set<String>], originalRelations: [String: Set<String>]) -> [String: Set<String>] {
		var relations = originalRelations

		// collect all letters
		var allLetters: Set<String> = []

		for (beginLetter, needsToBeFinishedLetters) in relations {
			allLetters.insert(beginLetter)

			allLetters = allLetters.union(needsToBeFinishedLetters)
		}

		let possibleStartNodes = allLetters.filter { relations.keys.contains($0) == false }

		for possibleStartNode in possibleStartNodes {
			relations[possibleStartNode] = []
		}

		return relations
	}

	private func processNodesForPart1(relations: [String: Set<String>]) -> String {
		var openNodes: Set<String> = []

		var result = ""

		while true {
			var candidates: Set<String> = []

			for (node, needsToBeOpenNodes) in relations where openNodes.contains(node) == false {
				if needsToBeOpenNodes.filter({ openNodes.contains($0) }).count == needsToBeOpenNodes.count {
					candidates.insert(node)
				}
			}

			if candidates.isEmpty {
				break
			}

			let openedNode = candidates.sorted().first!

			result += openedNode

			openNodes.insert(openedNode)
		}

		return result
	}

	private func processNodesForPart2(relations: [String: Set<String>], nrOfWorkers: Int, extraTime: Int) -> Int {
		// open nodes and timestamp when they are actually open
		var openNodes: [String: Int] = [:]

		var totalTime = 0

		var workerTimers: [Int] = Array(repeating: 0, count: nrOfWorkers)

		while openNodes.count < relations.count {
			let lowestTime = workerTimers.sorted().first!

			// fast forward to next available time
			totalTime += lowestTime

			for i in 0 ..< nrOfWorkers {
				workerTimers[i] = max(0, workerTimers[i] - lowestTime)
			}

			var candidates: Set<String> = []

			for (node, needsToBeOpenNodes) in relations where openNodes.keys.contains(node) == false {
				if
					needsToBeOpenNodes.filter({
						guard let finishTime = openNodes[$0] else {
							return false
						}

						return totalTime >= finishTime
					}).count == needsToBeOpenNodes.count
				{
					candidates.insert(node)
				}
			}

			if candidates.isEmpty {
				if lowestTime == 0 {
					// if we have no candidates and there is work in the pipeline we fast forward
					let newLowestNonZeroTimer = workerTimers.filter { $0 > 0 }.sorted().first!

					totalTime += newLowestNonZeroTimer

					for i in 0 ..< nrOfWorkers {
						workerTimers[i] = max(0, workerTimers[i] - newLowestNonZeroTimer)
					}
				}

				continue
			}

			let openedNode = candidates.sorted().first!

			let timeCostOfNode = extraTime + Int((openedNode.first!.asciiValue! - AsciiCharacter.A) + 1)

			workerTimers[workerTimers.firstIndex(of: 0)!] = timeCostOfNode
			openNodes[openedNode] = totalTime + timeCostOfNode
		}

		return openNodes.values.max()!
	}

	func solvePart1(withInput input: Input) -> String {
		let relations = allRelationsAndEndNode(relations: input.relations, originalRelations: input.relations)

		return processNodesForPart1(relations: relations)
	}

	func solvePart2(withInput input: Input) -> Int {
		let relations = allRelationsAndEndNode(relations: input.relations, originalRelations: input.relations)

		return processNodesForPart2(relations: relations, nrOfWorkers: 5, extraTime: 60)
	}

	func parseInput(rawString: String) -> Input {
		.init(relations: rawString.allLines().reduce(into: [String: Set<String>]()) { result, line in
			let arguments = line.getCapturedValues(pattern: #"Step ([A-Z]*) must be finished before step ([A-Z]*) can begin."#)!

			result[arguments[1], default: []].insert(arguments[0])
		})
	}
}
