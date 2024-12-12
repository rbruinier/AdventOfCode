import Foundation
import Tools

final class Day23Solver: DaySolver {
	let dayNumber: Int = 23

	private var input: Input!

	private struct Input {
		let bots: [Nanobot]
	}

	private struct Nanobot {
		let position: Point3D
		let radius: Int
	}

	func solvePart1() -> Int {
		let biggestRadiusBot = input.bots.sorted(by: { $0.radius > $1.radius }).first!

		return input.bots.count {
			$0.position.manhattanDistance(from: biggestRadiusBot.position) <= biggestRadiusBot.radius
		}
	}

	private struct Cube: Equatable {
		let position: Point3D
		let size: Int
		
		init(position: Point3D, size: Int) {
			self.position = position
			self.size = size
		}

		func numberOfOverlaps(with bots: [Nanobot]) -> Int {
			let xRange = position.x ..< (position.x + size)
			let yRange = position.y ..< (position.y + size)
			let zRange = position.z ..< (position.z + size)
			
			return bots.count {
				// contained
				if xRange.contains($0.position.x), yRange.contains($0.position.y), zRange.contains($0.position.z) {
					return true
				}

				// check overlap by checking distances from the 6 sides
				let x1 = position.x
				let y1 = position.y
				let z1 = position.z

				let x2 = position.x + size - 1
				let y2 = position.y + size - 1
				let z2 = position.z + size - 1
				
				var distance = 0
				
				if $0.position.x < x1 {
					distance += x1 - $0.position.x
				} else if $0.position.x > x2 {
					distance += $0.position.x - x2
				}

				if $0.position.y < y1 {
					distance += y1 - $0.position.y
				} else if $0.position.y > y2 {
					distance += $0.position.y - y2
				}

				if $0.position.z < z1 {
					distance += z1 - $0.position.z
				} else if $0.position.z > z2 {
					distance += $0.position.z - z2
				}
				
				return distance <= $0.radius
			}
		}
		
		func numberOfContains(with bots: [Nanobot]) -> Int {
			let xRange = position.x ..< position.x + size
			let yRange = position.y ..< position.y + size
			let zRange = position.z ..< position.z + size

			return bots.count {
				xRange.contains($0.position.x) && yRange.contains($0.position.y) && zRange.contains($0.position.z)
			}
		}

		func subdivide() -> [Cube] {
			guard size >= 1 else {
				return []
			}
			
			let newSize = size / 2
			
			return [
				.init(position: .init(x: position.x, y: position.y, z: position.z), size: newSize),
				.init(position: .init(x: position.x + newSize, y: position.y, z: position.z), size: newSize),
				.init(position: .init(x: position.x, y: position.y + newSize, z: position.z), size: newSize),
				.init(position: .init(x: position.x + newSize, y: position.y + newSize, z: position.z), size: newSize),
				.init(position: .init(x: position.x, y: position.y, z: position.z + newSize), size: newSize),
				.init(position: .init(x: position.x + newSize, y: position.y, z: position.z + newSize), size: newSize),
				.init(position: .init(x: position.x, y: position.y + newSize, z: position.z + newSize), size: newSize),
				.init(position: .init(x: position.x + newSize, y: position.y + newSize, z: position.z + newSize), size: newSize),
			]
		}
	}

	func solvePart2() -> Int {
		let bots = input.bots

		// find a cube with pow of 2 size (so that it is perfectly divisible in 8 sub cubes) that contains all bots
		var uberCube = Cube(position: .zero, size: 1)
		
		while true {
			let contains = uberCube.numberOfContains(with: bots)
			
			if contains == bots.count {
				break
			}
			
			let newSize = uberCube.size * 2
			
			uberCube = Cube(position: .init(x: -newSize / 2, y: -newSize / 2, z: -newSize / 2), size: newSize)
		}
		
		struct Node: Equatable, Comparable {
			let cube: Cube
			
			let numberOfOverlap: Int
			
			static func < (_ lhs: Node, _ rhs: Node) -> Bool {
				if lhs.numberOfOverlap == rhs.numberOfOverlap {
					return lhs.cube.position.manhattanDistance(from: .zero) > rhs.cube.position.manhattanDistance(from: .zero)
				}
				
				return lhs.numberOfOverlap < rhs.numberOfOverlap
			}
		}

		var queue: PriorityQueue<Node> = .init(initialValues: [.init(cube: uberCube, numberOfOverlap: bots.count)])

		while let node = queue.pop() {
			if node.cube.size == 1 {
				return node.cube.position.manhattanDistance(from: .zero)
			}
			
			for subCube in node.cube.subdivide() {
				queue.push(.init(cube: subCube, numberOfOverlap: subCube.numberOfOverlaps(with: bots)))
			}
		}
		
		preconditionFailure()
	}

	func parseInput(rawString: String) {
		let bots: [Nanobot] = rawString.allLines().map { line in
			guard let parameters = line.getCapturedValues(pattern: #"pos=<(-?[0-9]*),(-?[0-9]*),(-?[0-9]*)>, r=([0-9]*)"#) else {
				preconditionFailure()
			}

			return .init(position: Point3D(x: Int(parameters[0])!, y: Int(parameters[1])!, z: Int(parameters[2])!), radius: Int(parameters[3])!)
		}

		input = .init(bots: bots)
	}
}
