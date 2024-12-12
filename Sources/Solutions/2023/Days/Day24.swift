import Foundation
import Tools

final class Day24Solver: DaySolver {
	let dayNumber: Int = 24

	private var input: Input!

	private struct Input {
		let hailstones: [Hailstone]
	}

	private struct Hailstone {
		var position: Point3D
		let velocity: Point3D
	}

	private struct Point3DDouble {
		let x: Double
		let y: Double
		let z: Double

		init(point3D: Point3D) {
			x = Double(point3D.x)
			y = Double(point3D.y)
			z = Double(point3D.z)
		}
	}

	private func intersect2D(a: Point3DDouble, av: Point3DDouble, b: Point3DDouble, bv: Point3DDouble) -> (x: Double, y: Double)? {
		let epsilon = 1e-9

		let m1 = av.y / av.x
		let m2 = bv.y / bv.x

		if abs(m2 - m1) < epsilon {
			return nil
		}

		let x = (m1 * a.x - m2 * b.x + b.y - a.y) / (m1 - m2)
		let y = (m1 * m2 * (b.x - a.x) + m2 * a.y - m1 * b.y) / (m2 - m1)

		return (x: x, y: y)
	}

	func solvePart1() -> Int {
		let hailstones = input.hailstones

		let range = Double(200_000_000_000_000) ... Double(400_000_000_000_000)

		var counter = 0
		for a in 0 ..< hailstones.count {
			for b in a + 1 ..< hailstones.count {
				let ha = hailstones[a]
				let hb = hailstones[b]

				let intersection = intersect2D(
					a: .init(point3D: ha.position),
					av: .init(point3D: ha.velocity),
					b: .init(point3D: hb.position),
					bv: .init(point3D: hb.velocity)
				)

				guard
					let intersection,
					!(ha.velocity.x < 0 && intersection.x > Double(ha.position.x)),
					!(ha.velocity.x > 0 && intersection.x < Double(ha.position.x)),
					!(hb.velocity.x < 0 && intersection.x > Double(hb.position.x)),
					!(hb.velocity.x > 0 && intersection.x < Double(hb.position.x))
				else {
					continue
				}

				counter += (range.contains(intersection.x) && range.contains(intersection.y)) ? 1 : 0
			}
		}

		return counter
	}

	/// First solve was with a python script (using Z3 equation solver) but I do prefer this neat solution so I have implemented this instead:
	/// https://www.reddit.com/r/adventofcode/comments/18pnycy/comment/keqf8uq/
	func solvePart2() -> Int {
		let range = 500

		var xSet: Set<Int> = []
		var ySet: Set<Int> = []
		var zSet: Set<Int> = []

		for aIndex in 0 ..< input.hailstones.count {
			for bIndex in aIndex + 1 ..< input.hailstones.count {
				let a = input.hailstones[aIndex]
				let b = input.hailstones[bIndex]

				if a.velocity.x == b.velocity.x {
					let distance = b.position.x - a.position.x

					let newXSet: Set<Int> = Set((-range ... range).compactMap { v in
						v != a.velocity.x && (distance % (v - a.velocity.x)) == 0 ? v : nil
					})

					xSet = xSet.isEmpty ? newXSet : xSet.intersection(newXSet)
				}

				if a.velocity.y == b.velocity.y {
					let distance = b.position.y - a.position.y

					let newYSet: Set<Int> = Set((-range ... range).compactMap { v in
						v != a.velocity.y && (distance % (v - a.velocity.y)) == 0 ? v : nil
					})

					ySet = ySet.isEmpty ? newYSet : ySet.intersection(newYSet)
				}

				if a.velocity.z == b.velocity.z {
					let distance = b.position.z - a.position.z

					let newZSet: Set<Int> = Set((-range ... range).compactMap { v in
						v != a.velocity.z && (distance % (v - a.velocity.z)) == 0 ? v : nil
					})

					zSet = zSet.isEmpty ? newZSet : zSet.intersection(newZSet)
				}
			}
		}

		let rockVelocity = Point3DDouble(point3D: .init(x: xSet.first!, y: ySet.first!, z: zSet.first!))

		let aPosition = Point3DDouble(point3D: input.hailstones[0].position)
		let aVelocity = Point3DDouble(point3D: input.hailstones[0].velocity)

		let bPosition = Point3DDouble(point3D: input.hailstones[1].position)
		let bVelocity = Point3DDouble(point3D: input.hailstones[1].velocity)

		let slopeA = (aVelocity.y - rockVelocity.y) / (aVelocity.x - rockVelocity.x)
		let slopeB = (bVelocity.y - rockVelocity.y) / (bVelocity.x - rockVelocity.x)
		let ca = aPosition.y - (slopeA * aPosition.x)
		let cb = bPosition.y - (slopeB * bPosition.x)

		let x = (cb - ca) / (slopeA - slopeB)
		let y = slopeA * x + ca
		let t = (x - aPosition.x) / (aVelocity.x - rockVelocity.x)
		let z = aPosition.z + (aVelocity.z - rockVelocity.z) * t

		return Int(x + y + z)

		// Previously solved with Python & Z3, see & run: Other/solveDay24Part2.py
		// return 757031940316991
	}

	func parseInput(rawString: String) {
		input = .init(hailstones: rawString.allLines().map { line in
			let components = line.components(separatedBy: " @ ")

			return .init(
				position: .init(commaSeparatedString: components[0].replacingOccurrences(of: " ", with: "")),
				velocity: .init(commaSeparatedString: components[1].replacingOccurrences(of: " ", with: ""))
			)
		})
	}
}
