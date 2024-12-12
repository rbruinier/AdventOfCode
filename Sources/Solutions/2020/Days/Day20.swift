import Foundation
import Tools

final class Day20Solver: DaySolver {
	let dayNumber: Int = 20

	private var input: Input!

	private let combinations: [(rotation: Point2D.Degrees, flip: Flip)] = [
		(rotation: .zero, flip: .none),
		(rotation: .ninety, flip: .none),
		(rotation: .oneEighty, flip: .none),
		(rotation: .twoSeventy, flip: .none),
		(rotation: .zero, flip: .vertical),
		(rotation: .ninety, flip: .vertical),
		(rotation: .oneEighty, flip: .vertical),
		(rotation: .twoSeventy, flip: .vertical),
		(rotation: .zero, flip: .horizontal),
		(rotation: .ninety, flip: .horizontal),
		(rotation: .oneEighty, flip: .horizontal),
		(rotation: .twoSeventy, flip: .horizontal),
	]

	private struct Input {
		let tiles: [Int: Tile]
	}

	private struct Tile {
		let id: Int

		let pixels: [Bool]

		let borders: [[Bool]]

		init(id: Int, pixels: [Bool]) {
			self.id = id
			self.pixels = pixels

			borders = Self.getBorders(from: pixels)
		}

		private static func getBorders(from pixels: [Bool]) -> [[Bool]] {
			var borders: [[Bool]] = []

			let borderIndices: [(startIndex: Int, inc: Int, side: Side)] = [
				(startIndex: 0, inc: 1, side: .north),
				(startIndex: 9, inc: 10, side: .east),
				(startIndex: 90, inc: 1, side: .south),
				(startIndex: 0, inc: 10, side: .west),
			]

			for borderIndex in borderIndices {
				var border: [Bool] = []

				border.reserveCapacity(10)

				var index = borderIndex.startIndex
				for _ in 0 ..< 10 {
					border.append(pixels[index])

					index += borderIndex.inc
				}

				borders.append(border)
			}

			return borders
		}
	}

	private enum Flip {
		case none
		case horizontal
		case vertical
	}

	private enum Side {
		case north
		case east
		case south
		case west
	}

	private struct Match {
		let lhs: Tile
		let rhs: Tile

		let lhsSide: Int
		let rhsSide: Int
	}

	private func matchTiles(lhs: Tile, rhs: Tile) -> [Match] {
		var matches: [Match] = []

		let lhsBorders = lhs.borders
		let rhsBorders = rhs.borders

		for lhsBorderIndex in 0 ..< 4 {
			let lhsBorder = lhsBorders[lhsBorderIndex]

			for rhsBorderIndex in 0 ..< 4 {
				let rhsBorder = rhsBorders[rhsBorderIndex]

				if lhsBorder == rhsBorder || lhsBorder == rhsBorder.reversed() {
					matches.append(.init(lhs: lhs, rhs: rhs, lhsSide: lhsBorderIndex, rhsSide: rhsBorderIndex))
				}
			}
		}

		return matches
	}

	private func allMatchesByTile() -> [Int: [Match]] {
		var matchesByTile: [Int: [Match]] = [:]

		for (lhsTileID, lhs) in input.tiles {
			for (rhsTileID, rhs) in input.tiles {
				guard lhsTileID != rhsTileID else {
					continue
				}

				let matches = matchTiles(lhs: lhs, rhs: rhs)

				if matches.isNotEmpty {
					matchesByTile[lhs.id, default: []].append(contentsOf: matches)
				}
			}
		}

		return matchesByTile
	}

	private func renderTile(_ tile: Tile, pixels: inout [Bool], tileX: Int, tileY: Int, nrOfTilesPerDimension: Int) {
		for y in 1 ..< 9 {
			var sourceIndex = (y * 10) + 1
			var targetIndex = (((tileY * 8) + y - 1) * nrOfTilesPerDimension * 8) + (tileX * 8)

			for _ in 1 ..< 9 {
				pixels[targetIndex] = tile.pixels[sourceIndex]

				sourceIndex += 1
				targetIndex += 1
			}
		}
	}

	private func flipPixels(_ originalPixels: [Bool], width: Int, height: Int, flip: Flip) -> [Bool] {
		var pixels: [Bool] = Array(repeating: false, count: width * height)

		var targetIndex = 0
		for y in 0 ..< height {
			var sourceIndex: Int
			let sourceInc: Int

			switch flip {
			case .none:
				sourceIndex = y * width
				sourceInc = 1
			case .horizontal:
				sourceIndex = (y * width) + width - 1
				sourceInc = -1
			case .vertical:
				sourceIndex = (height - 1 - y) * width
				sourceInc = 1
			}

			for _ in 0 ..< width {
				pixels[targetIndex] = originalPixels[sourceIndex]

				sourceIndex += sourceInc
				targetIndex += 1
			}
		}

		return pixels
	}

	private func rotatePixels(_ originalPixels: [Bool], width: Int, height: Int, degrees: Point2D.Degrees) -> [Bool] {
		var pixels: [Bool] = Array(repeating: false, count: width * height)

		var targetIndex = 0
		for y in 0 ..< height {
			var sourceIndex: Int
			let sourceInc: Int

			switch degrees {
			case .zero,
			     .threeSixty:
				sourceIndex = y * width
				sourceInc = 1
			case .twoSeventy:
				sourceIndex = height - 1 - y
				sourceInc = width
			case .oneEighty:
				sourceIndex = ((height - y) * width) - 1
				sourceInc = -1
			case .ninety:
				sourceIndex = ((height - 1) * width) + y
				sourceInc = -width
			}

			for _ in 0 ..< width {
				pixels[targetIndex] = originalPixels[sourceIndex]

				sourceIndex += sourceInc
				targetIndex += 1
			}
		}

		return pixels
	}

	private func getMatchedTileFor(side: Int, lhs: Tile, matches: [Match]) -> Tile? {
		for match in matches {
			let rhs = match.rhs

			for combination in combinations {
				let tile = Tile(id: rhs.id, pixels: flipPixels(
					rotatePixels(rhs.pixels, width: 10, height: 10, degrees: combination.rotation),
					width: 10,
					height: 10,
					flip: combination.flip
				))

				if lhs.borders[side] == tile.borders[(side + 2) % 4] {
					return tile
				}
			}
		}

		return nil
	}

	private func findMonsterInPixels(_ pixels: inout [Bool], points: [Point2D], width: Int, height: Int) -> Bool {
		for y in 0 ..< height - 3 {
			for x in 0 ..< width - 19 {
				var isMatch = true

				for point in points {
					let pixelX = x + point.x
					let pixelY = y + point.y

					if pixels[pixelY * width + pixelX] == false {
						isMatch = false

						break
					}
				}

				if isMatch {
					for point in points {
						let pixelX = x + point.x
						let pixelY = y + point.y

						pixels[pixelY * width + pixelX] = false
					}

					return true
				}
			}
		}

		return false
	}

	func solvePart1() -> Int {
		let matchesByTile: [Int: [Match]] = allMatchesByTile()

		let cornerTiles = matchesByTile
			.filter { $0.value.count == 2 }
			.map { input.tiles[$0.key]! }

		return cornerTiles.reduce(1) { result, tile in
			result * tile.id
		}
	}

	func solvePart2() -> Int {
		let matchesByTile: [Int: [Match]] = allMatchesByTile()

		let topLeftCorner = matchesByTile
			.first { $0.value.count == 2
				&& (1 ... 2).contains($0.value[0].lhsSide)
				&& (1 ... 2).contains($0.value[1].lhsSide)
			}
			.map { input.tiles[$0.key]! }!

		var finalTiles: [Tile] = []

		finalTiles.append(topLeftCorner)

		let nrOfTilesPerDimension = Int(Double(input.tiles.count).squareRoot())

		// first do top row, by matching lhs east and rhs west
		for x in 1 ..< nrOfTilesPerDimension {
			let lhs = finalTiles[x - 1]

			let eastTile = getMatchedTileFor(side: 1, lhs: lhs, matches: matchesByTile[lhs.id]!)!

			finalTiles.append(eastTile)
		}

		// now we do remaining rows, matching lhs south and rhs north
		for y in 1 ..< nrOfTilesPerDimension {
			for x in 0 ..< nrOfTilesPerDimension {
				let lhs = finalTiles[((y - 1) * nrOfTilesPerDimension) + x]

				let southTile = getMatchedTileFor(side: 2, lhs: lhs, matches: matchesByTile[lhs.id]!)!

				finalTiles.append(southTile)
			}
		}

		// now we render all in final image where each tile is 8 x 8 as we remove all borders
		var pixels: [Bool] = Array(repeating: false, count: input.tiles.count * 64)

		for (index, tile) in finalTiles.enumerated() {
			let x = index % nrOfTilesPerDimension
			let y = index / nrOfTilesPerDimension

			renderTile(tile, pixels: &pixels, tileX: x, tileY: y, nrOfTilesPerDimension: nrOfTilesPerDimension)
		}

		//   01234567890123456789
		// 0                   #
		// 1 #    ##    ##    ###
		// 2  #  #  #  #  #  #

		let points: [Point2D] = [
			.init(x: 18, y: 0),
			.init(x: 0, y: 1),
			.init(x: 5, y: 1),
			.init(x: 6, y: 1),
			.init(x: 11, y: 1),
			.init(x: 12, y: 1),
			.init(x: 17, y: 1),
			.init(x: 18, y: 1),
			.init(x: 19, y: 1),
			.init(x: 1, y: 2),
			.init(x: 4, y: 2),
			.init(x: 7, y: 2),
			.init(x: 10, y: 2),
			.init(x: 13, y: 2),
			.init(x: 16, y: 2),
		]

		let size = nrOfTilesPerDimension * 8

		var foundSnake = false
		var sourcePixels = pixels

		repeat {
			foundSnake = false

			for combination in combinations {
				var testPixels = rotatePixels(sourcePixels, width: size, height: size, degrees: combination.rotation)

				testPixels = flipPixels(testPixels, width: size, height: size, flip: combination.flip)

				if findMonsterInPixels(&testPixels, points: points, width: size, height: size) {
					sourcePixels = testPixels

					foundSnake = true
				}
			}
		} while
			foundSnake == true

		return sourcePixels.filter { $0 }.count
	}

	func parseInput(rawString: String) {
		var tiles: [Int: Tile] = [:]

		var lines = rawString.allLines()

		while lines.isNotEmpty {
			let tileID = Int(lines.removeFirst().components(separatedBy: .whitespaces)[1].replacingOccurrences(of: ":", with: ""))!
			var pixels: [Bool] = []

			pixels.reserveCapacity(100)

			for _ in 0 ..< 10 {
				pixels.append(contentsOf: lines.removeFirst().map { $0 == "#" ? true : false })
			}

			tiles[tileID] = .init(id: tileID, pixels: pixels)
		}

		input = .init(tiles: tiles)
	}
}
