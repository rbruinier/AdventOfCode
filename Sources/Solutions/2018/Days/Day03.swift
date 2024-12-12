import Foundation
import Tools

final class Day03Solver: DaySolver {
	let dayNumber: Int = 3

	private var input: Input!

	private struct Input {
		let claims: [Claim]
	}

	private struct Claim {
		let id: Int
		let area: Rect
	}

	func solvePart1() -> Int {
		let claims = input.claims

		var overlapCounter: [Point2D: Int] = [:]

		for claim in claims {
			for y in claim.area.topLeft.y ..< claim.area.bottomRight.y {
				for x in claim.area.topLeft.x ..< claim.area.bottomRight.x {
					overlapCounter[.init(x: x, y: y), default: 0] += 1
				}
			}
		}

		return overlapCounter.values.filter { $0 >= 2 }.count
	}

	func solvePart2() -> Int {
		let claims = input.claims

		outerLoop: for i in 0 ..< claims.count {
			for j in 0 ..< claims.count where i != j {
				if claims[i].area.intersects(claims[j].area) {
					continue outerLoop
				}
			}

			return claims[i].id
		}

		fatalError()
	}

	func parseInput(rawString: String) {
		input = .init(claims: rawString.allLines().map { line in
			let lineComponents = line.components(separatedBy: " @ ")

			let id = Int(lineComponents[0].replacingOccurrences(of: "#", with: ""))!

			let rectComponents = lineComponents[1].components(separatedBy: ": ")

			let topLeftPoint = Point2D(commaSeparatedString: rectComponents[0])

			let sizeComponents = rectComponents[1].components(separatedBy: "x")

			let size = Size(width: Int(sizeComponents[0])!, height: Int(sizeComponents[1])!)

			return .init(id: id, area: .init(origin: topLeftPoint, size: size))
		})
	}
}
