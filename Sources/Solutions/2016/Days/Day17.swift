import Foundation
import Tools

final class Day17Solver: DaySolver {
	let dayNumber: Int = 17

	private var input: Input!

	private struct Input {
		let passcode: String
	}

	private func findPath(position: Point2D, pathSoFar: String, paths: inout [String]) {
		if position == Point2D(x: 3, y: 3) {
			paths.append(pathSoFar)

			return
		}

		let hash = md5AsHex(with: input.passcode + pathSoFar)

		let openCharacters: [String] = ["b", "c", "d", "e", "f"]

		if openCharacters.contains(hash[0]), position.y > 0 { // up
			findPath(position: position.moved(to: .north), pathSoFar: pathSoFar + "U", paths: &paths)
		}

		if openCharacters.contains(hash[1]), position.y < 3 { // down
			findPath(position: position.moved(to: .south), pathSoFar: pathSoFar + "D", paths: &paths)
		}

		if openCharacters.contains(hash[2]), position.x > 0 { // left
			findPath(position: position.moved(to: .west), pathSoFar: pathSoFar + "L", paths: &paths)
		}

		if openCharacters.contains(hash[3]), position.x < 3 { // right
			findPath(position: position.moved(to: .east), pathSoFar: pathSoFar + "R", paths: &paths)
		}
	}

	func solvePart1() -> String {
		var paths: [String] = []

		findPath(position: Point2D(x: 0, y: 0), pathSoFar: "", paths: &paths)

		return paths.min(by: { $0.count < $1.count }) ?? "NOT FOUND"
	}

	func solvePart2() -> Int {
		var paths: [String] = []

		findPath(position: Point2D(x: 0, y: 0), pathSoFar: "", paths: &paths)

		guard let path = paths.max(by: { $0.count < $1.count }) else {
			fatalError()
		}

		return path.count
	}

	func parseInput(rawString: String) {
		input = .init(passcode: "qljzarfv")
	}
}
