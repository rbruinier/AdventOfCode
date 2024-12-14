import Foundation
import Tools

final class Day22Solver: DaySolver {
	let dayNumber: Int = 22

	struct Input {
		let nodes: [Point2D: Node]
	}

	private struct Node: Equatable {
		let size: Int
		var used: Int

		var available: Int {
			size - used
		}
	}

	private func availableTargetNodes(for nodeA: Node, at pointA: Point2D) -> [Point2D: Node] {
		if nodeA.used == 0 {
			return [:]
		}

		var viableTargets: [Point2D: Node] = [:]

		for (pointB, nodeB) in input.nodes where pointA != pointB && nodeA.used <= nodeB.available {
			viableTargets[pointB] = nodeB
		}

		return viableTargets
	}

	func solvePart1(withInput input: Input) -> Int {
		var viablePairs = 0

		for (pointA, nodeA) in input.nodes where nodeA.used > 0 {
			viablePairs += availableTargetNodes(for: nodeA, at: pointA).count
		}

		return viablePairs
	}

	func solvePart2(withInput input: Input) -> Int {
		// this one needs to be solved by hand (confirmed this by checking AoC reddit):

		// 1. print the complete maze, mark empty nodes and nodes that can't be moved so they stand out
		// 2. this shows that there is one empty node and various unmovable nodes that form a wall
		// 3. from now on it is basically a sliding puzzle (see: https://en.wikipedia.org/wiki/Sliding_puzzle)
		// 4. solved this by drawing in a PNG on top of the print of step 1
		// 5. see drawing Other/Day22.Part2.png

		//		let nodes = input.nodes
//
		//		let maxX = nodes.keys.map { $0.x }.max()!
		//		let maxY = nodes.keys.map { $0.y }.max()!
//
		//		for y in 0 ... maxY {
		//			var line: String = ""
//
		//			for x in 0 ... maxX {
		//				let node = nodes[.init(x: x, y: y)]!
//
		//				if node.used == 0 {
		//					line += "__/\(node.size)"
		//				} else {
		//					let viablePairs = availableTargetNodes(for: node, at: .init(x: x, y: y))
//
		//					line += viablePairs.isEmpty ? "--/--" : "\(node.used)/\(node.size)"
		//				}
//
		//				line += " "
		//			}
//
		//			print(line)
		//		}

		185
	}

	func parseInput(rawString: String) -> Input {
		var nodes: [Point2D: Node] = [:]

		rawString.allLines().forEach { line in
			let components = line.components(separatedBy: .whitespaces).filter { $0 != "" }

			let name = components[0]
			let size = Int(components[1].replacingOccurrences(of: "T", with: ""))!
			let used = Int(components[2].replacingOccurrences(of: "T", with: ""))!

			let arguments = name.getCapturedValues(pattern: #"/dev/grid/node-x([0-9]*)-y([0-9]*)"#)!

			let x = Int(arguments[0])!
			let y = Int(arguments[1])!

			nodes[.init(x: x, y: y)] = Node(size: size, used: used)
		}

		return .init(nodes: nodes)
	}
}
