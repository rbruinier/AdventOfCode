import Foundation
import Tools

final class Day07Solver: DaySolver {
	let dayNumber: Int = 7

	struct Input {
		let programs: [String: Program]
	}

	struct Program {
		let id: String
		let weight: Int
		let holding: [String]
	}

	private var rootProgramID: String!

	func solvePart1(withInput input: Input) -> String {
		let programs = input.programs

		for subProgramID in programs.keys {
			if programs.values.contains(where: { $0.holding.contains(subProgramID) }) == false {
				rootProgramID = subProgramID

				return subProgramID
			}
		}

		fatalError()
	}

	private struct Node {
		let program: Program

		var childNodes: [Node] = []

		var combinedWeight: Int {
			childNodes.map(\.combinedWeight).reduce(into: program.weight) { $0 += $1 }
		}

		var mostCommonChildWeight: Int? {
			var weightCounter: [Int: Int] = [:]

			for childNode in childNodes {
				let weight = childNode.combinedWeight

				weightCounter[weight, default: 0] += 1
			}

			return weightCounter.sorted(by: { $0.value > $1.value }).first?.key
		}

		var isUnbalanced: Bool {
			!isBalanced
		}

		var isBalanced: Bool {
			if childNodes.isEmpty {
				return true
			}

			let baseWeight = childNodes[0].combinedWeight

			for childNode in childNodes[1 ..< childNodes.count] {
				if childNode.combinedWeight != baseWeight {
					return false
				}
			}

			return true
		}

		init(program: Program, allPrograms: [String: Program]) {
			self.program = program

			for subProgramID in program.holding {
				childNodes.append(Node(program: allPrograms[subProgramID]!, allPrograms: allPrograms))
			}
		}

		func findUnbalancedNode() -> Node? {
			guard isUnbalanced else {
				return nil
			}

			for childNode in childNodes where childNode.isUnbalanced {
				return childNode.findUnbalancedNode() ?? childNode
			}

			return self
		}

		func findChildNodesWithUnMatchedWeight(_ weight: Int) -> Node? {
			childNodes.first(where: { $0.combinedWeight != weight })
		}
	}

	func solvePart2(withInput input: Input) -> Int {
		let programs = input.programs

		let rootNode = Node(program: programs[rootProgramID]!, allPrograms: programs)

		let unbalancedNode = rootNode.findUnbalancedNode()!

		let mostCommonWeight = unbalancedNode.mostCommonChildWeight!

		let oddNode = unbalancedNode.findChildNodesWithUnMatchedWeight(mostCommonWeight)!

		let newWeight = oddNode.program.weight - (oddNode.combinedWeight - mostCommonWeight)

		return newWeight
	}

	func parseInput(rawString: String) -> Input {
		let programs: [String: Program] = rawString.allLines().map { line in
			let components = line.components(separatedBy: " ")

			let id = components[0]
			let weight = Int(String(components[1][1 ..< components[1].count - 1]))!
			var subIDs: [String] = []

			if components.count >= 3 {
				for i in 3 ..< components.count {
					subIDs.append(String(components[i].replacingOccurrences(of: ",", with: "")))
				}
			}

			return (id, Program(id: id, weight: weight, holding: subIDs))
		}.reduce(into: [:]) { $0[$1.0] = $1.1 }

		return .init(programs: programs)
	}
}
