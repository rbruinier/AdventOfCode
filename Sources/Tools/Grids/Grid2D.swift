import Foundation

public struct Grid2D<Tile: Hashable & Sendable>: Hashable, Sendable {
	public var tiles: [[Tile]]
	public let dimensions: Size

	public func hash(into hasher: inout Hasher) {
		hasher.combine(tiles)
	}

	public init(tiles: [[Tile]], dimensions: Size) {
		self.tiles = tiles
		self.dimensions = dimensions
	}
	
	public func isSafe(position: Point2D) -> Bool {
		(0 ..< dimensions.height).contains(position.y) && (0 ..< dimensions.width).contains(position.x)
	}
	
	public subscript(y: Int, x: Int) -> Tile {
		tiles[y][x]
	}
	
	public subscript(point: Point2D) -> Tile {
		tiles[point.y][point.x]
	}

	public subscript(safe point: Point2D) -> Tile? {
		tiles[safe: point.y]?[safe: point.x]
	}
}

// MARK: - CustomStringConvertible

extension Grid2D: CustomStringConvertible where Tile: CustomStringConvertible {
	public var description: String {
		var result = ""

		for row in tiles {
			for tile in row {
				result += tile.description
			}

			result += "\n"
		}

		return result
	}
}

public extension String {
	func parseGrid2D<Tile: RawRepresentable<String>>() -> Grid2D<Tile> {
		let lines = allLines()

		let dimensions = Size(width: lines.first!.count, height: lines.count)

		var tiles: [[Tile]] = .init(repeating: [], count: dimensions.height)

		for (y, line) in allLines().enumerated() {
			for (_, character) in line.enumerated() {
				guard let tile = Tile(rawValue: String(character)) else {
					preconditionFailure()
				}

				tiles[y].append(tile)
			}
		}

		return .init(tiles: tiles, dimensions: dimensions)
	}

	func parseGrid2D<Tile>(_ mapping: (_ character: String, _ point: Point2D) -> Tile?) -> Grid2D<Tile> {
		let lines = allLines()

		let dimensions = Size(width: lines.first!.count, height: lines.count)

		var tiles: [[Tile]] = .init(repeating: [], count: dimensions.height)

		for (y, line) in allLines().enumerated() {
			for (x, character) in line.enumerated() {
				let point = Point2D(x: x, y: y)

				guard let tile = mapping(String(character), point) else {
					preconditionFailure()
				}

				tiles[y].append(tile)
			}
		}

		return .init(tiles: tiles, dimensions: dimensions)
	}
}
