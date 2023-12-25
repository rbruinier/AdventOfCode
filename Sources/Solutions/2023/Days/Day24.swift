import Foundation
import Tools

final class Day24Solver: DaySolver {
	let dayNumber: Int = 24

	let expectedPart1Result = 15593
	let expectedPart2Result = 757031940316991

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

		init(x: Double, y: Double, z: Double) {
			self.x = x
			self.y = y
			self.z = z
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

	func solvePart2() -> Int {
		// Solved with Python & Z3, see & run: Other/solveDay24Part2.py

		757031940316991
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
