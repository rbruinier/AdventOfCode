import Collections
import Foundation
import Tools

final class Day09Solver: DaySolver {
	let dayNumber: Int = 9

	struct Input {
		let routes: [Route]
	}

	struct Route {
		let a: String
		let b: String
		let distance: Int
	}

	private struct Node {
		let id: String

		var connections: [String: Int] = [:]
	}

	// cache for part 2
	private var minimumDistance = Int.max
	private var maximumDistance = Int.min

	private func shortestAndLongestRoute(from start: String, nodes: [String: Node]) -> (min: Int, max: Int) {
		var queue: Deque<(location: String, distance: Int, explored: [String])> = [(start, 0, [])]

		var minimumDistance = Int.max
		var maximumDistance = Int.min

		while var item = queue.first {
			queue.removeFirst()

			item.explored.append(item.location)

			if item.explored.count == nodes.count {
				minimumDistance = min(minimumDistance, item.distance)
				maximumDistance = max(maximumDistance, item.distance)
			}

			let cityRoutes = nodes[item.location]!

			for (destination, distance) in cityRoutes.connections where item.explored.contains(destination) == false {
				queue.append((destination, item.distance + distance, item.explored))
			}
		}

		return (min: minimumDistance, max: maximumDistance)
	}

	func solvePart1(withInput input: Input) -> Int {
		let routes = input.routes

		var nodes: [String: Node] = [:]
		var locations: Set<String> = []

		for route in routes {
			nodes[route.a, default: .init(id: route.a)].connections[route.b] = route.distance
			nodes[route.b, default: .init(id: route.b)].connections[route.a] = route.distance

			locations.insert(route.a)
			locations.insert(route.b)
		}

		for start in locations {
			let result = shortestAndLongestRoute(from: start, nodes: nodes)

			minimumDistance = min(minimumDistance, result.min)
			maximumDistance = max(maximumDistance, result.max)
		}

		return minimumDistance
	}

	func solvePart2(withInput input: Input) -> Int {
		maximumDistance
	}

	func parseInput(rawString: String) -> Input {
		var routes: [Route] = []

		rawString.allLines().forEach { line in
			guard let parameters = line.getCapturedValues(pattern: #"([a-zA-Z]*) to ([a-zA-Z]*) = ([0-9]*)"#) else {
				fatalError()
			}

			routes.append(.init(a: parameters[0], b: parameters[1], distance: Int(parameters[2])!))
		}

		return .init(routes: routes)
	}
}
