import Foundation
import Tools

final class Day11Solver: DaySolver {
	let dayNumber: Int = 11

	struct Input {
		let steps: [HexDirection]
	}

	func solvePart1(withInput input: Input) -> Int {
		var point = HexPoint.zero

		for step in input.steps {
			point = point.moved(to: step)
		}

		return point.manhattanDistance(from: .zero)
	}

	func solvePart2(withInput input: Input) -> Int {
		var point = HexPoint.zero
		var maxDistance = 0

		for step in input.steps {
			point = point.moved(to: step)

			maxDistance = max(maxDistance, point.manhattanDistance(from: .zero))
		}

		return maxDistance
	}

	func parseInput(rawString: String) -> Input {
		.init(steps: rawString.allLines().first!.components(separatedBy: ",").compactMap { raw in
			HexDirection(raw)
		})
	}
}

// extension Day11Solver {
//	func createVisualizer() -> Visualizer? {
//		StepsVisualizer(solver: self)
//	}
//
//	final class StepsVisualizer: Visualizer {
//		var dimensions: Size {
//			.init(width: 720, height: 720)
//		}
//
//		var frameDescription: String?
//
//		var isCompleted: Bool = false
//
//		let solver: DaySolver
//
//		init(solver: Day11Solver) {
//			self.solver = solver
//		}
//
//		private func drawHex(at offset: Vector2, radius: Double, with context: VisualizationContext) {
//			let a = 0.5 * radius
//			let b = 0.866025 * radius
//
//			let vertices: [Vector3] = [
//				Vector3(x: -a + offset.x, y: -b + offset.y, z: 0),
//				Vector3(x:  a + offset.x, y: -b + offset.y, z: 0),
//				Vector3(x:  radius + offset.x, y: 0 + offset.y, z: 0),
//				Vector3(x:  a + offset.x, y: b + offset.y, z: 0),
//				Vector3(x: -a + offset.x, y: b + offset.y, z: 0),
//				Vector3(x: -radius + offset.x, y: 0 + offset.y, z: 0)
//			]
//
//			let matrix: Matrix3 = .rotateX(radians: -1.0)
//
//			let transformed: [Vector3] = vertices.map {
//				matrix * $0
//			}
//
//			var z: Double = 200.0
//
//			let projected: [Vector2] = transformed.map {
//				.init(x: $0.x / ($0.z + z), y: $0.y / ($0.z + z)) * .init(x: 360, y: 360) + .init(x: 360, y: 360)
//			}
//
//			for i in 0 ..< vertices.count {
//				let from = i
//				let to = (i + 1) % vertices.count
//
//				let v1 = projected[from]
//				let v2 = projected[to]
//
//				context.drawAALine(from: v1, to: v2, color: .white)
//			}
//
////			let v1 = center + Vector2(x: -a, y: -b)
////			let v2 = center + Vector2(x:  a, y: -b)
////			let v3 = center + Vector2(x:  radius, y: 0)
////			let v4 = center + Vector2(x:  a, y: b)
////			let v5 = center + Vector2(x: -a, y: b)
////			let v6 = center + Vector2(x: -radius, y: 0)
////
////			context.drawAALine(from: v1, to: v2, color: .white)
////			context.drawAALine(from: v2, to: v3, color: .white)
////			context.drawAALine(from: v3, to: v4, color: .white)
////			context.drawAALine(from: v4, to: v5, color: .white)
////			context.drawAALine(from: v5, to: v6, color: .white)
////			context.drawAALine(from: v6, to: v1, color: .white)
//		}
//
//		func renderFrame(with context: VisualizationContext) {
//			context.startNewFrame()
//
//			drawHex(at: .init(x: 0, y: 0), radius: 100, with: context)
//			drawHex(at: .init(x: 150, y: (0.866025 * 100.0)), radius: 100, with: context)
//
//			isCompleted = true
//		}
//	}
// }
