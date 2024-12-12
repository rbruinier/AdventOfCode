import Foundation

public extension String {
	func allLines(includeEmpty: Bool = false) -> [String] {
		var lines = components(separatedBy: .newlines)

		if includeEmpty == false {
			lines = lines.filter(\.isNotEmpty)
		}

		return lines
	}

	func parseCommaSeparatedInts(filterInvalid: Bool = true) -> [Int] {
		let items = components(separatedBy: ",")

		if filterInvalid {
			return items.compactMap { Int(String($0).trimmingCharacters(in: .whitespacesAndNewlines)) }
		} else {
			return items.map { Int(String($0))! }
		}
	}

	/// Parses the complete string as a 2D grid with coordinates starting at 0, 0.
	/// - Parameter mapping: The mapping function to turn a character into a tile. Return nil for an empty tile to decrease the size of the final dictionary.
	/// - Returns: A dictionary containing tiles by `Point2D`
	func parseGrid<Tile>(_ mapping: (_ character: String, _ point: Point2D) -> Tile?) -> [Point2D: Tile] {
		var grid: [Point2D: Tile] = [:]

		for (y, line) in allLines().enumerated() {
			for (x, character) in line.enumerated() {
				let point = Point2D(x: x, y: y)

				if let tile = mapping(String(character), point) {
					grid[point] = tile
				}
			}
		}

		return grid
	}
}
