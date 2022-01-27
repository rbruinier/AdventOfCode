import Foundation
import Tools
import Collections

final class Day20Solver: DaySolver {
    let dayNumber: Int = 20

    private var input: Input!

    private struct Input {
        let tiles: [Point2D: Tile]

        let min: Point2D
        let max: Point2D

        init(tiles: [Point2D: Tile]) {
            self.tiles = tiles

            min = .init(x: tiles.keys.map { $0.x }.min()!, y: tiles.keys.map { $0.y }.min()!)
            max = .init(x: tiles.keys.map { $0.x }.max()!, y: tiles.keys.map { $0.y }.max()!)
        }
    }

    private enum PortalSide {
        case unknown
        case inner
        case outer
    }

    private enum Tile: Equatable {
        case empty
        case start
        case end
        case wall
        case portal(id: String, side: PortalSide)
    }

    private func printTiles(_ tiles: [Point2D: Tile], min: Point2D, max: Point2D) {
        for y in min.y ... max.y {
            var line = ""

            for x in min.x ... max.x {
                switch tiles[.init(x: x, y: y)] {
                case nil: line += "  "
                case .empty: line += ".."
                case .start: line += "SS"
                case .end: line += "EE"
                case .wall: line += "##"
                case .portal(let id, let side):
                    switch side {
                    case .unknown, .outer:
                        line += id
                    case .inner:
                        line += id.lowercased()
                    }

                    if id.count == 1 {
                        line += " "
                    }
                }

                line += " "
            }

            print(line)
        }
    }

    private func processTiles(_ originalTiles: [Point2D: Tile], min: Point2D, max: Point2D) -> [Point2D: Tile] {
        var tiles = originalTiles

        for y in min.y ... max.y {
            for x in min.x ... max.x {
                switch tiles[.init(x: x, y: y)] {
                case nil: break
                case .empty: break
                case .start: break
                case .end: break
                case .wall: break
                case .portal(let id1, _):
                    if case let .portal(id2, _) = tiles[.init(x: x + 1, y: y)] { // horizontal
                        let combinedId = id1 + id2

                        if tiles[.init(x: x + 2, y: y)] == .empty { // on the left
                            if combinedId == "AA" || combinedId == "ZZ" {
                                tiles[.init(x: x + 2, y: y)] = combinedId == "AA" ? .start : .end
                                tiles[.init(x: x, y: y)] = nil
                                tiles[.init(x: x + 1, y: y)] = nil
                            } else {
                                tiles[.init(x: x + 1, y: y)] = .portal(id: id1 + id2, side: x == 0 ? .outer : .inner)
                                tiles[.init(x: x, y: y)] = nil
                            }
                        } else if tiles[.init(x: x - 1, y: y)] == .empty { // on the right
                            if combinedId == "AA" || combinedId == "ZZ" {
                                tiles[.init(x: x - 1, y: y)] = combinedId == "AA" ? .start : .end
                                tiles[.init(x: x, y: y)] = nil
                                tiles[.init(x: x + 1, y: y)] = nil
                            } else {
                                tiles[.init(x: x, y: y)] = .portal(id: id1 + id2, side: (x + 1) == max.x ? .outer : .inner)
                                tiles[.init(x: x + 1, y: y)] = nil
                            }
                        } else {
                            fatalError()
                        }
                    } else if case let .portal(id2, _) = tiles[.init(x: x, y: y + 1)] { // vertical
                        let combinedId = id1 + id2

                        if tiles[.init(x: x, y: y + 2)] == .empty {
                            if combinedId == "AA" || combinedId == "ZZ" {
                                tiles[.init(x: x, y: y + 2)] = combinedId == "AA" ? .start : .end
                                tiles[.init(x: x, y: y)] = nil
                                tiles[.init(x: x, y: y + 1)] = nil
                            } else {
                                tiles[.init(x: x, y: y + 1)] = .portal(id: id1 + id2, side: y == 0 ? .outer : .inner)
                                tiles[.init(x: x, y: y)] = nil
                            }
                        } else if tiles[.init(x: x, y: y - 1)] == .empty {
                            if combinedId == "AA" || combinedId == "ZZ" {
                                tiles[.init(x: x, y: y - 1)] = combinedId == "AA" ? .start : .end
                                tiles[.init(x: x, y: y)] = nil
                                tiles[.init(x: x, y: y + 1)] = nil
                            } else {
                                tiles[.init(x: x, y: y)] = .portal(id: id1 + id2, side: (y + 1) == max.y ? .outer : .inner)
                                tiles[.init(x: x, y: y + 1)] = nil
                            }
                        } else {
                            fatalError()
                        }
                    }
                }
            }
        }

        return tiles
    }

    private func pointForTile(_ tile: Tile, tiles: [Point2D: Tile]) -> Point2D? {
        return tiles.first(where: {
            $0.value == tile
        })?.key
    }

    private struct PortalPair: Hashable, Equatable {
        let id: String

        let targetPoint1: Point2D
        let targetPoint2: Point2D
    }

    private func allPortalPairs(tiles: [Point2D: Tile]) -> [String: PortalPair] {
        var pointsById: [String: [Point2D]] = [:]

        for (point, tile) in tiles {
            if case let .portal(id, _) = tile {
                pointsById[id, default: []] += [point]
            }
        }

        var pairs: [String: PortalPair] = [:]

        for (id, points) in pointsById {
            guard points.count == 2 else {
                fatalError()
            }

            let targetPoint1: Point2D
            let targetPoint2: Point2D

            if tiles[points[0] + .init(x: 1, y: 0)] == .empty {
                targetPoint1 = points[0] + .init(x: 1, y: 0)
            } else if tiles[points[0] + .init(x: -1, y: 0)] == .empty {
                targetPoint1 = points[0] + .init(x: -1, y: 0)
            } else if tiles[points[0] + .init(x: 0, y: -1)] == .empty {
                targetPoint1 = points[0] + .init(x: 0, y: -1)
            } else if tiles[points[0] + .init(x: 0, y: 1)] == .empty {
                targetPoint1 = points[0] + .init(x: 0, y: 1)
            } else {
                fatalError()
            }

            if tiles[points[1] + .init(x: 1, y: 0)] == .empty {
                targetPoint2 = points[1] + .init(x: 1, y: 0)
            } else if tiles[points[1] + .init(x: -1, y: 0)] == .empty {
                targetPoint2 = points[1] + .init(x: -1, y: 0)
            } else if tiles[points[1] + .init(x: 0, y: -1)] == .empty {
                targetPoint2 = points[1] + .init(x: 0, y: -1)
            } else if tiles[points[1] + .init(x: 0, y: 1)] == .empty {
                targetPoint2 = points[1] + .init(x: 0, y: 1)
            } else {
                fatalError()
            }

            pairs[id] = .init(id: id, targetPoint1: targetPoint1, targetPoint2: targetPoint2)
        }

        return pairs
    }

    func solvePart1() -> Any {
        var tiles = input.tiles

        tiles = processTiles(tiles, min: input.min, max: input.max)

//        printTiles(tiles, min: input.min, max: input.max)

        let startPoint = pointForTile(.start, tiles: tiles)!
        let endPoint = pointForTile(.end, tiles: tiles)!

        let portalPairs = allPortalPairs(tiles: tiles)

        // breadth–first search for shortest path
        var tileQueue: Deque<(point: Point2D, distance: Int)> = [(point: startPoint, distance: 0)]
        var visitedTiles: Set<Point2D> = Set()

        while let tile = tileQueue.first {
            tileQueue.removeFirst()

            if tile.point == endPoint {
                return tile.distance
            }

            visitedTiles.insert(tile.point)

            let neighborPoints = tile.point.neighbors()

            for neighborPoint in neighborPoints where visitedTiles.contains(neighborPoint) == false {
                switch tiles[neighborPoint] {
                case nil, .start, .wall: break
                case .empty, .end:
                    tileQueue.append((point: neighborPoint, distance: tile.distance + 1))
                case .portal(let id, _):
                    let portalPair = portalPairs[id]!

                    let targetPoint: Point2D

                    if portalPair.targetPoint1 == tile.point {
                        targetPoint = portalPair.targetPoint2
                    } else if portalPair.targetPoint2 == tile.point {
                        targetPoint = portalPair.targetPoint1
                    } else {
                        fatalError()
                    }

                    if visitedTiles.contains(targetPoint) == false {
                        tileQueue.append((point: targetPoint, distance: tile.distance + 1))
                    }
                }
            }
        }

        return 0
    }

    func solvePart2() -> Any {
        var tiles = input.tiles

        tiles = processTiles(tiles, min: input.min, max: input.max)

//        printTiles(tiles, min: input.min, max: input.max)

        let startPoint = pointForTile(.start, tiles: tiles)!
        let endPoint = pointForTile(.end, tiles: tiles)!

        let portalPairs = allPortalPairs(tiles: tiles)

        // breadth–first search for shortest path
        var tileQueue: Deque<(point: Point2D, distance: Int, level: Int)> = [(point: startPoint, distance: 0, level: 0)]
        var visitedTilesPerLevel: [Int: Set<Point2D>] = [0: Set()]

        while let tile = tileQueue.first {
            tileQueue.removeFirst()

            if tile.point == endPoint {
                if tile.level == 0 {
                    return tile.distance
                } else {
                    continue
                }
            }

            visitedTilesPerLevel[tile.level, default: Set()].insert(tile.point)

            let neighborPoints = tile.point.neighbors()

            for neighborPoint in neighborPoints where visitedTilesPerLevel[tile.level]!.contains(neighborPoint) == false {
                switch tiles[neighborPoint] {
                case nil, .start, .wall: break
                case .empty:
                    tileQueue.append((point: neighborPoint, distance: tile.distance + 1, level: tile.level))
                case .end:
                    if tile.level == 0 {
                        tileQueue.append((point: neighborPoint, distance: tile.distance + 1, level: tile.level))
                    }
                case .portal(let id, let side):
                    if tile.level == 0 && side == .outer {
                        break
                    }

                    let portalPair = portalPairs[id]!

                    let targetPoint: Point2D

                    if portalPair.targetPoint1 == tile.point {
                        targetPoint = portalPair.targetPoint2
                    } else if portalPair.targetPoint2 == tile.point {
                        targetPoint = portalPair.targetPoint1
                    } else {
                        fatalError()
                    }

                    let newLevel = tile.level + (side == .inner ? 1 : -1)

                    if visitedTilesPerLevel[newLevel, default: Set()].contains(targetPoint) == false {
                        tileQueue.append((point: targetPoint, distance: tile.distance + 1, level: newLevel))
                    }
                }
            }
        }

        return 0
    }

    func parseInput(rawString: String) {
        let lines = rawString.allLines()

        var tiles: [Point2D: Tile] = [:]
        for y in 0 ..< lines.count {
            let line = lines[y]

            for x in 0 ..< line.count {
                let tile: Tile

                switch line[x ... x] {
                case ".": tile = .empty
                case "#": tile = .wall
                case "A" ... "Z": tile = .portal(id: line[x ... x], side: .unknown)
                case " ": continue
                default: fatalError()
                }

                tiles[.init(x: x, y: y)] = tile
            }
        }

        input = .init(tiles: tiles)
    }
}
