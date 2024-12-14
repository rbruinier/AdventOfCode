import Foundation
import Tools

final class Day19Solver: DaySolver {
	let dayNumber: Int = 19

	private lazy var matrices: [Matrix] = {
		// base matrices
		let unitMatrix = Matrix(rows: [[1, 0, 0], [0, 1, 0], [0, 0, 1]])

		let z90Matrix = Matrix(rows: [[0, -1, 0], [1, 0, 0], [0, 0, 1]])
		let z180Matrix = Matrix(rows: [[-1, 0, 0], [0, -1, 0], [0, 0, 1]])
		let z270Matrix = Matrix(rows: [[0, 1, 0], [-1, 0, 0], [0, 0, 1]])

		let y90Matrix = Matrix(rows: [[0, 0, 1], [0, 1, 0], [-1, 0, 0]])
		let y180Matrix = Matrix(rows: [[-1, 0, 0], [0, 1, 0], [0, 0, -1]])
		let y270Matrix = Matrix(rows: [[0, 0, -1], [0, 1, 0], [1, 0, 0]])

		let x90Matrix = Matrix(rows: [[1, 0, 0], [0, 0, -1], [0, 1, 0]])
		let x180Matrix = Matrix(rows: [[1, 0, 0], [0, -1, 0], [0, 0, -1]])
		let x270Matrix = Matrix(rows: [[1, 0, 0], [0, 0, 1], [0, -1, 0]])

		return [
			unitMatrix,
			z90Matrix,
			z180Matrix,
			z270Matrix,
			y90Matrix,
			y180Matrix,
			y270Matrix,
			x90Matrix,
			x180Matrix,
			x270Matrix,
			x90Matrix * y90Matrix,
			x90Matrix * y180Matrix,
			x90Matrix * y270Matrix,
			x180Matrix * y90Matrix,
			x180Matrix * y270Matrix,
			x90Matrix * z90Matrix,
			x90Matrix * z180Matrix,
			x90Matrix * z270Matrix,
			x180Matrix * z90Matrix,
			x180Matrix * z270Matrix,
			x270Matrix * y270Matrix,
			y90Matrix * x270Matrix,
			y90Matrix * z270Matrix,
			z270Matrix * y270Matrix,
		]
	}()

	struct Input {
		let scanners: [Scanner]
	}

	private struct Vector: Equatable, Hashable {
		var x: Int
		var y: Int
		var z: Int

		init() {
			x = 0
			y = 0
			z = 0
		}

		init(x: Int, y: Int, z: Int) {
			self.x = x
			self.y = y
			self.z = z
		}

		static func + (lhs: Vector, rhs: Vector) -> Vector {
			.init(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
		}

		static func - (lhs: Vector, rhs: Vector) -> Vector {
			.init(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
		}

		static func * (lhs: Vector, rhs: Matrix) -> Vector {
			.init(
				x: lhs.x * rhs.rows[0][0] + lhs.y * rhs.rows[1][0] + lhs.z * rhs.rows[2][0],
				y: lhs.x * rhs.rows[0][1] + lhs.y * rhs.rows[1][1] + lhs.z * rhs.rows[2][1],
				z: lhs.x * rhs.rows[0][2] + lhs.y * rhs.rows[1][2] + lhs.z * rhs.rows[2][2]
			)
		}
	}

	private typealias Point = Vector
	private typealias Beacon = Point

	private struct Matrix: Equatable, Hashable {
		var rows: [[Int]] = Array(repeating: Array(repeating: 0, count: 3), count: 3)

		static func * (lhs: Matrix, rhs: Matrix) -> Matrix {
			var result = Matrix()

			for row in 0 ... 2 {
				for column in 0 ... 2 {
					result.rows[row][column] =
						lhs.rows[row][0] * rhs.rows[0][column] +
						lhs.rows[row][1] * rhs.rows[1][column] +
						lhs.rows[row][2] * rhs.rows[2][column]
				}
			}

			return result
		}
	}

	private struct Scanner {
		let name: String
		let beacons: [Beacon]
	}

	private struct Match {
		let matchingLhsBeacons: [Beacon]
		let rhsOffset: Vector
		let rhsMatrix: Matrix
	}

	private struct Relation: Equatable, Hashable {
		let lhsIndex: Int
		let rhsIndex: Int

		let offset: Vector
		let matrix: Matrix

		static func == (lhs: Relation, rhs: Relation) -> Bool {
			(lhs.lhsIndex, lhs.rhsIndex) == (rhs.lhsIndex, rhs.rhsIndex)
		}

		func hash(into hasher: inout Hasher) {
			hasher.combine(lhsIndex)
			hasher.combine(rhsIndex)
		}
	}

	// we can cache all the hard work done in part 1 to solve part 2
	private var cachedResult: [Int: (scanner: Point, beacons: [Beacon])] = [:]

	private func matchBeacons(lhs: Scanner, rhs: Scanner, matrices: [Matrix]) -> Match? {
		for matrix in matrices {
			// rotate to relative space
			let rotatedRhsBeacons = rhs.beacons.map { $0 * matrix }

			// 1. we are gonna loop through all lhs beacons
			//  1.1 then loop through all rotated rhs beacons
			//  1.2 calculate offset between these two
			//   1.2.1 then we loop again through all lhs beacons
			//    1.2.1.1 then we loop through all rotated and translated (with offset) rhs beacons
			//    1.2.1.2 match? if so add to array
			//   1.2.2 if we have at least twelve matches we return the found beacons
			for lhsBeacon in lhs.beacons {
				for rhsBeacon in rotatedRhsBeacons {
					let offset = lhsBeacon - rhsBeacon

					let translatedRhsBeacons = rotatedRhsBeacons.map { $0 + offset }

					var matchingBeacons: [Beacon] = []

					for innerLhsBeacon in lhs.beacons {
						for innerRhsBeacon in translatedRhsBeacons {
							if innerLhsBeacon == innerRhsBeacon {
								matchingBeacons.append(innerLhsBeacon)
							}
						}
					}

					if matchingBeacons.count >= 12 {
						return .init(matchingLhsBeacons: matchingBeacons, rhsOffset: offset, rhsMatrix: matrix)
					}
				}
			}
		}

		return nil
	}

	private func transformInfoForScannerIndex(scannerIndex: Int, from relations: Set<Relation>, scanners: [Scanner]) -> (scanner: Point, beacons: [Beacon]) {
		guard scannerIndex != 0 else {
			return (scanner: .init(), beacons: [])
		}

		var path: [Int] = [scannerIndex]

		var visitedRelations: Set<Relation> = Set()

		var currentScannerIndex = scannerIndex
		while true {
			// try lhs parent & rhs child
			if let relationParentIsLhs = relations.first(where: { $0.rhsIndex == currentScannerIndex && visitedRelations.contains($0) == false }) {
				path.insert(relationParentIsLhs.lhsIndex, at: 0)

				if relationParentIsLhs.lhsIndex == 0 {
					break
				}

				visitedRelations.insert(relationParentIsLhs)

				currentScannerIndex = relationParentIsLhs.lhsIndex

				continue
			}

			// try rhs parent & lhs child
			if let relationParentIsRhs = relations.first(where: { $0.lhsIndex == currentScannerIndex && visitedRelations.contains($0) == false }) {
				path.insert(relationParentIsRhs.rhsIndex, at: 0)

				if relationParentIsRhs.rhsIndex == 0 {
					break
				}

				visitedRelations.insert(relationParentIsRhs)

				currentScannerIndex = relationParentIsRhs.rhsIndex

				continue
			}

			if path.count >= 2 {
				// back tracking
				path.removeFirst()

				currentScannerIndex = path.first!
			} else {
				fatalError("No valid path found to scanner 0 :(")
			}
		}

		var scannerLocation = Point()
		var beacons = scanners[scannerIndex].beacons

		for index in 1 ..< path.count {
			let currentScannerIndex = path[path.count - index]
			let previousScannerIndex = path[path.count - index - 1]

			// guaranteed match as we know there is an relationship between the two scanners
			let match = matchBeacons(lhs: scanners[previousScannerIndex], rhs: scanners[currentScannerIndex], matrices: matrices)!

			scannerLocation = scannerLocation * match.rhsMatrix + match.rhsOffset
			beacons = beacons.map { $0 * match.rhsMatrix + match.rhsOffset }
		}

		return (scanner: scannerLocation, beacons: beacons)
	}

	func solvePart1(withInput input: Input) -> Int {
		let scanners = input.scanners

		var relations: Set<Relation> = Set()

		for lhsScannerIndex in 0 ..< scanners.count {
			for rhsScannerIndex in lhsScannerIndex + 1 ..< scanners.count {
				guard
					let match = matchBeacons(
						lhs: input.scanners[lhsScannerIndex],
						rhs: input.scanners[rhsScannerIndex],
						matrices: matrices
					)
				else {
					continue
				}

				relations.insert(.init(lhsIndex: lhsScannerIndex, rhsIndex: rhsScannerIndex, offset: match.rhsOffset, matrix: match.rhsMatrix))
			}
		}

		var uniqueBeacons: Set<Beacon> = Set()

		for scannerIndex in 0 ..< scanners.count {
			let transformed = transformInfoForScannerIndex(scannerIndex: scannerIndex, from: relations, scanners: scanners)

			cachedResult[scannerIndex] = transformed

			transformed.beacons.forEach {
				uniqueBeacons.insert($0)
			}
		}

		return uniqueBeacons.count
	}

	func solvePart2(withInput input: Input) -> Int {
		let scanners = input.scanners

		var scannerLocations: [Point] = []

		for scannerIndex in 0 ..< scanners.count {
			scannerLocations.append(cachedResult[scannerIndex]!.scanner)
		}

		var maxDistance = 0
		for lhsScannerIndex in 0 ..< scannerLocations.count {
			for rhsScannerIndex in 1 ..< scannerLocations.count {
				let distanceVector = scannerLocations[rhsScannerIndex] - scannerLocations[lhsScannerIndex]

				let distance = abs(distanceVector.x) + abs(distanceVector.y) + abs(distanceVector.z)

				maxDistance = max(distance, maxDistance)
			}
		}

		return maxDistance
	}

	func parseInput(rawString: String) -> Input {
		var rawLines = rawString
			.components(separatedBy: CharacterSet.newlines)

		var scanners: [Scanner] = []

		while let line = rawLines.first {
			rawLines.removeFirst()

			guard line.isEmpty == false else {
				continue
			}

			let name = line
			var beacons: [Beacon] = []

			while let beaconLine = rawLines.first {
				rawLines.removeFirst()

				guard beaconLine.isEmpty == false else {
					break
				}

				let coordinates = beaconLine.components(separatedBy: ",").compactMap { Int($0) }

				beacons.append(.init(x: coordinates[0], y: coordinates[1], z: coordinates[2]))
			}

			scanners.append(.init(name: name, beacons: beacons))
		}

		return .init(scanners: scanners)
	}
}
