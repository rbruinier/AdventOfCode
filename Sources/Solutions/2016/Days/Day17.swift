import Foundation
import Tools

final class Day17Solver: DaySolver {
	let dayNumber: Int = 17

	struct Input {
		let passcode: String
	}

	private func findPath(position: Point2D, passcode: String, pathSoFar: String, paths: inout [String]) {
		if position == Point2D(x: 3, y: 3) {
			paths.append(pathSoFar)

			return
		}

		let hash = md5AsHex(with: passcode + pathSoFar)

		let openCharacters: [String] = ["b", "c", "d", "e", "f"]

		if openCharacters.contains(hash[0]), position.y > 0 { // up
			findPath(position: position.moved(to: .north), passcode: passcode, pathSoFar: pathSoFar + "U", paths: &paths)
		}

		if openCharacters.contains(hash[1]), position.y < 3 { // down
			findPath(position: position.moved(to: .south), passcode: passcode, pathSoFar: pathSoFar + "D", paths: &paths)
		}

		if openCharacters.contains(hash[2]), position.x > 0 { // left
			findPath(position: position.moved(to: .west), passcode: passcode, pathSoFar: pathSoFar + "L", paths: &paths)
		}

		if openCharacters.contains(hash[3]), position.x < 3 { // right
			findPath(position: position.moved(to: .east), passcode: passcode, pathSoFar: pathSoFar + "R", paths: &paths)
		}
	}

	func solvePart1(withInput input: Input) -> String {
		var paths: [String] = []

		findPath(position: Point2D(x: 0, y: 0), passcode: input.passcode, pathSoFar: "", paths: &paths)

		return paths.min(by: { $0.count < $1.count }) ?? "NOT FOUND"
	}

	func solvePart2(withInput input: Input) -> Int {
		var paths: [String] = []

		findPath(position: Point2D(x: 0, y: 0), passcode: input.passcode, pathSoFar: "", paths: &paths)

		guard let path = paths.max(by: { $0.count < $1.count }) else {
			fatalError()
		}

		return path.count
	}

	func parseInput(rawString: String) -> Input {
		.init(passcode: "qljzarfv")
	}
}
