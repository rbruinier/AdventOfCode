import Collections
import Foundation
import Tools

final class Day18Solver: DaySolver {
	let dayNumber: Int = 18
	
	struct Input {
		let tiles: [Point2D: Tile]
	}

	enum Tile: Equatable {
		case empty
		case entrance
		case wall
		case key(id: String)
		case door(id: String)
	}

	private struct PathIdentifier: Hashable, Equatable {
		let a: String
		let b: String

		init(a: String, b: String) {
			let sorted = [a, b].sorted()

			self.a = sorted.first!
			self.b = sorted.last!
		}
	}

	private func printTiles(_ tiles: [Point2D: Tile]) {
		let minX = tiles.keys.map(\.x).min()!
		let minY = tiles.keys.map(\.y).min()!

		let maxX = tiles.keys.map(\.x).max()!
		let maxY = tiles.keys.map(\.y).max()!

		for y in minY ... maxY {
			var line = ""

			for x in minX ... maxX {
				switch tiles[.init(x: x, y: y)] {
				case nil: line += "?"
				case .empty: line += "."
				case .entrance: line += "@"
				case .wall: line += "#"
				case .key(let id): line += id
				case .door(let id): line += id.uppercased()
				}
			}

			print(line)
		}
	}

	private func pointForTile(_ tile: Tile, tiles: [Point2D: Tile]) -> Point2D? {
		tiles.first(where: {
			$0.value == tile
		})?.key
	}

	private func allKeys(in tiles: [Point2D: Tile]) -> [String] {
		tiles.compactMap {
			if case .key(let id) = $0.value {
				id
			} else {
				nil
			}
		}.sorted()
	}

	private func shortestPath(from: Point2D, to: Point2D, tiles: [Point2D: Tile]) -> (requiredKeys: [String], distance: Int)? {
		// breadth–first search for shortest path
		var tileQueue: Deque<(point: Point2D, distance: Int, requiredKeys: [String])> = [(point: from, distance: 0, requiredKeys: [])]
		var visitedTiles: Set<Point2D> = Set()

		while let tile = tileQueue.first {
			tileQueue.removeFirst()

			if tile.point == to {
				return (requiredKeys: Array(Set(tile.requiredKeys)).sorted(), distance: tile.distance)
			}

			visitedTiles.insert(tile.point)

			let neighborPoints = tile.point.neighbors()

			for neighborPoint in neighborPoints where visitedTiles.contains(neighborPoint) == false {
				switch tiles[neighborPoint] {
				case nil,
				     .wall: break
				case .empty,
				     .entrance:
					tileQueue.append((point: neighborPoint, distance: tile.distance + 1, requiredKeys: tile.requiredKeys))
				case .key(let id):
					if neighborPoint == to {
						tileQueue.append((point: neighborPoint, distance: tile.distance + 1, requiredKeys: tile.requiredKeys))
					} else {
						tileQueue.append((point: neighborPoint, distance: tile.distance + 1, requiredKeys: tile.requiredKeys + [id]))
					}
				case .door(let id):
					tileQueue.append((point: neighborPoint, distance: tile.distance + 1, requiredKeys: tile.requiredKeys + [id]))
				}
			}
		}

		return nil
	}

	private func allShortestPathsWithRequiredKeys(entrancePoint: Point2D, allKeys: [String], tiles: [Point2D: Tile]) -> [PathIdentifier: (requiredKeys: [String], distance: Int)] {
		var shortestPaths: [PathIdentifier: (requiredKeys: [String], distance: Int)] = [:]

		var reachableKeys: [String] = []

		for key in allKeys {
			let keyPoint = pointForTile(.key(id: key), tiles: tiles)!

			if let result = shortestPath(from: entrancePoint, to: keyPoint, tiles: tiles) {
				shortestPaths[.init(a: "@", b: key)] = result

				reachableKeys.append(key)
			}
		}

		for aIndex in 0 ..< reachableKeys.count {
			let a = reachableKeys[aIndex]
			let aPoint = pointForTile(.key(id: a), tiles: tiles)!

			for bIndex in aIndex + 1 ..< reachableKeys.count {
				let b = reachableKeys[bIndex]
				let bPoint = pointForTile(.key(id: b), tiles: tiles)!

				if let result = shortestPath(from: aPoint, to: bPoint, tiles: tiles) {
					shortestPaths[.init(a: a, b: b)] = result
				}
			}
		}

		return shortestPaths
	}

	private func allReachableKeys(fromKey: String, shortestPaths: [PathIdentifier: (requiredKeys: [String], distance: Int)], allKeys: [String], pickedUpKeys: [String], tiles: [Point2D: Tile]) -> [(key: String, distance: Int)] {
		var reachableKeys: [(key: String, distance: Int)] = []

		for key in allKeys where key != fromKey && pickedUpKeys.contains(key) == false {
			guard let shortestPath = shortestPaths[.init(a: fromKey, b: key)] else {
				continue
			}

			let hasAllRequiredKeys = shortestPath.requiredKeys.allSatisfy {
				pickedUpKeys.contains($0)
			}

			guard hasAllRequiredKeys else {
				continue
			}

			reachableKeys.append((key: key, distance: shortestPath.distance))
		}

		return reachableKeys
	}

	func solvePart1(withInput input: Input) -> Int {
		let tiles = input.tiles

		//        printTiles(tiles)

		let allKeys = allKeys(in: tiles)

		let entrancePoint = pointForTile(.entrance, tiles: tiles)!

		// pre calculate all shortest paths and the required keys for each path, later we can quickly look up possible paths from any k to any other taking
		// already collected keys into account
		let shortestPaths = allShortestPathsWithRequiredKeys(entrancePoint: entrancePoint, allKeys: allKeys, tiles: tiles)

		// now we have a graph and can use Dijkstra to solve the rest
		struct Explored: Hashable, Equatable {
			let key: String
			let pickedUpKeys: [String]
		}

		var queue: Deque<Explored> = [.init(key: "@", pickedUpKeys: [])]
		var distanceByExplored: [Explored: Int] = [queue.first!: 0]
		var explored: Set<Explored> = Set()

		while let item = queue.first {
			queue.removeFirst()

			let itemDistance = distanceByExplored[item]!

			if item.pickedUpKeys.count == allKeys.count {
				return itemDistance
			}

			explored.insert(.init(key: item.key, pickedUpKeys: item.pickedUpKeys))

			let reachableKeys = allReachableKeys(fromKey: item.key, shortestPaths: shortestPaths, allKeys: allKeys, pickedUpKeys: item.pickedUpKeys, tiles: tiles)

			for reachableKey in reachableKeys {
				let pickedUpKeys = (item.pickedUpKeys + [reachableKey.key]).sorted()
				let newDistance = itemDistance + reachableKey.distance

				let exploredItem = Explored(key: reachableKey.key, pickedUpKeys: pickedUpKeys)

				let isInQueue = queue.contains(exploredItem)

				if explored.contains(exploredItem) == false, isInQueue == false {
					queue.append(exploredItem)
					distanceByExplored[exploredItem] = newDistance
				} else if isInQueue, distanceByExplored[exploredItem]! > newDistance {
					distanceByExplored[exploredItem] = newDistance
				}
			}
		}

		fatalError()
	}

	func solvePart2(withInput input: Input) -> Int {
		var tiles = input.tiles

		let originalEntrancePoint = pointForTile(.entrance, tiles: tiles)!

		let newEntryPoints: [Point2D] = [
			originalEntrancePoint + .init(x: -1, y: -1),
			originalEntrancePoint + .init(x: 1, y: -1),
			originalEntrancePoint + .init(x: -1, y: 1),
			originalEntrancePoint + .init(x: 1, y: 1),
		]

		for point in newEntryPoints {
			tiles[point] = .entrance
		}

		tiles[originalEntrancePoint + .init(x: 0, y: 0)] = .wall
		tiles[originalEntrancePoint + .init(x: -1, y: 0)] = .wall
		tiles[originalEntrancePoint + .init(x: 1, y: 0)] = .wall
		tiles[originalEntrancePoint + .init(x: 0, y: -1)] = .wall
		tiles[originalEntrancePoint + .init(x: 0, y: 1)] = .wall

		//        printTiles(tiles)

		let allKeys = allKeys(in: tiles)

		struct Robot {
			let shortestPaths: [PathIdentifier: (requiredKeys: [String], distance: Int)]
			let allKeys: [String]
		}

		// pre calculate all shortest paths and the required keys for each path, later we can quickly look up possible paths from any k to any other taking
		// already collected keys into account
		let robots: [Robot] = newEntryPoints.map {
			let shortestPaths = allShortestPathsWithRequiredKeys(entrancePoint: $0, allKeys: allKeys, tiles: tiles)

			var allRobotKeys: Set<String> = Set()

			for (path, _) in shortestPaths {
				allRobotKeys.insert(path.a)
				allRobotKeys.insert(path.b)
			}

			allRobotKeys.remove("@")

			return .init(shortestPaths: shortestPaths, allKeys: Array(allRobotKeys))
		}

		// now we have a graph and can use Dijkstra to solve the rest
		struct Explored: Hashable, Equatable {
			let keys: [String]
			let pickedUpKeys: [String]
		}

		let item = Explored(keys: ["@", "@", "@", "@"], pickedUpKeys: [])

		var queue: Deque<Explored> = [item]
		var distanceByExplored: [Explored: Int] = [item: 0]

		var explored: Set<Explored> = Set()

		while let item = queue.first {
			queue.removeFirst()

			let itemDistance = distanceByExplored[item]!

			if item.pickedUpKeys.count == allKeys.count {
				return itemDistance
			}

			explored.insert(item)

			for robotID in 0 ..< 4 {
				let robot = robots[robotID]
				let robotKey = item.keys[robotID]

				let reachableKeys = allReachableKeys(fromKey: robotKey, shortestPaths: robot.shortestPaths, allKeys: robot.allKeys, pickedUpKeys: item.pickedUpKeys, tiles: tiles)

				for reachableKey in reachableKeys {
					let pickedUpKeys = (item.pickedUpKeys + [reachableKey.key]).sorted()
					let newDistance = itemDistance + reachableKey.distance

					var newKeys = item.keys

					newKeys[robotID] = reachableKey.key

					let exploredItem = Explored(keys: newKeys, pickedUpKeys: pickedUpKeys)

					let isInQueue = queue.contains(exploredItem)

					if explored.contains(exploredItem) == false, isInQueue == false {
						queue.append(exploredItem)
						distanceByExplored[exploredItem] = newDistance
					} else if isInQueue, distanceByExplored[exploredItem]! > newDistance {
						distanceByExplored[exploredItem] = newDistance
					}
				}
			}
		}

		fatalError()
	}

	func parseInput(rawString: String) -> Input {
		let lines = rawString.allLines()

		var tiles: [Point2D: Tile] = [:]
		for y in 0 ..< lines.count {
			let line = lines[y]

			for x in 0 ..< line.count {
				let tile: Tile

				switch line[x ... x] {
				case ".": tile = .empty
				case "@": tile = .entrance
				case "#": tile = .wall
				case "a" ... "z": tile = .key(id: line[x ... x])
				case "A" ... "Z": tile = .door(id: line[x ... x].lowercased())
				default: fatalError()
				}

				tiles[.init(x: x, y: y)] = tile
			}
		}

		return .init(tiles: tiles)
	}
}
