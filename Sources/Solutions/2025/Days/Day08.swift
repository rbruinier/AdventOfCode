import Foundation
import Tools

final class Day08Solver: DaySolver {
	let dayNumber: Int = 8

	private var input: Input!

	struct Input {
		let boxes: [Point3D]
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

	private func allConnectionsSortedByDistance(in boxes: [Point3D]) -> [Line] {
		let numberOfEntries = boxes.count * (boxes.count - 1) / 2
		
		var distances: [Line: Int] = Dictionary(minimumCapacity: numberOfEntries)

		for i in 0 ..< boxes.count {
			for j in i + 1 ..< boxes.count {
				let delta = boxes[j] - boxes[i]

				// no sqrt as we don't need the actual distance anywhere, just relative to other connections
				let distance = (delta.x * delta.x) + (delta.y * delta.y) + (delta.z * delta.z)

				distances[Line(a: i, b: j)] = distance
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

		var sortedConnections = Array(cachedSortedConnections.suffix(1000))

		var circuits: [Circuit] = []

		while sortedConnections.isNotEmpty {
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

				return a.x * b.x
			}
		}

		preconditionFailure()
	}

	func parseInput(rawString: String) -> Input {
		let boxes: [Point3D] = rawString.allLines().map { line in
			Point3D(commaSeparatedString: line)
		}

		return .init(boxes: boxes)
	}
}
