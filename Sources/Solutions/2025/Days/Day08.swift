import Foundation
import Tools

final class Day08Solver: DaySolver {
	let dayNumber: Int = 8

	private var input: Input!

	struct Input {
		let boxes: [Box]
	}

	struct Box {
		let id: Int
		let position: Point3D
	}

	struct Line: Hashable {
		let a: Int
		let b: Int
	}

	struct Circuit {
		var boxIds: Set<Int> = []
	}

	/// we calculate this in part 1 and reuse it in part 2
	private var cachedSortedConnections: [Line] = []

	private func allConnectionsSortedByDistance(in boxes: [Box]) -> [Line] {
		var distances: [Line: Int] = [:]

		for i in 0 ..< boxes.count {
			for j in i + 1 ..< boxes.count {
				let a = boxes[i]
				let b = boxes[j]

				let delta = b.position - a.position

				// no sqrt as we don't need the actual distance anywhere, just relative to other connections
				let distance = (delta.x * delta.x) + (delta.y * delta.y) + (delta.z * delta.z)

				distances[Line(a: a.id, b: b.id)] = distance
			}
		}

		return distances.sorted(by: { $0.value > $1.value }).map(\.key)
	}

	@discardableResult
	private func solveNextConnection(with sortedConnections: inout [Line], circuits: inout [Circuit]) -> Line {
		let shortest = sortedConnections.removeLast()

		let aIndex = circuits.firstIndex(where: { $0.boxIds.contains(shortest.a) })
		let bIndex = circuits.firstIndex(where: { $0.boxIds.contains(shortest.b) })

		switch (aIndex, bIndex) {
		case (.none, .none):
			circuits.append(Circuit(boxIds: [shortest.a, shortest.b]))
		case (.some(let aIndex), .none):
			circuits[aIndex].boxIds.insert(shortest.b)
		case (.none, .some(let bIndex)):
			circuits[bIndex].boxIds.insert(shortest.a)
		case (.some(let aIndex), .some(let bIndex)):
			guard aIndex != bIndex else {
				return shortest
			}

			circuits[aIndex].boxIds.formUnion(circuits[bIndex].boxIds)
			circuits.remove(at: bIndex)
		}

		return shortest
	}

	func solvePart1(withInput input: Input) -> Int {
		cachedSortedConnections = allConnectionsSortedByDistance(in: input.boxes)

		var sortedConnections = cachedSortedConnections

		var circuits: [Circuit] = []

		var counter = 0
		while sortedConnections.isNotEmpty, counter < 1000 {
			defer {
				counter += 1
			}

			solveNextConnection(with: &sortedConnections, circuits: &circuits)
		}

		return circuits
			.map(\.boxIds.count)
			.sorted(by: >)
			.prefix(3)
			.reduce(1) { $0 * $1 }
	}

	func solvePart2(withInput input: Input) -> Int {
		var sortedConnections = cachedSortedConnections

		var circuits: [Circuit] = []

		while sortedConnections.isNotEmpty {
			let shortest = solveNextConnection(with: &sortedConnections, circuits: &circuits)

			if circuits.count == 1, circuits[0].boxIds.count == 1000 {
				let a = input.boxes[shortest.a]
				let b = input.boxes[shortest.b]

				return a.position.x * b.position.x
			}
		}

		preconditionFailure()
	}

	func parseInput(rawString: String) -> Input {
		let positions: [Point3D] = rawString.allLines().map { line in
			Point3D(commaSeparatedString: line)
		}

		let boxes: [Box] = positions.enumerated().map {
			Box(id: $0, position: $1)
		}

		return .init(boxes: boxes)
	}
}
