import Foundation

public struct Input {
    let riskLevels: [Int]

    let width: Int
    let height: Int

    func riskAt(_ coordinate: Coordinate) -> Int {
        return riskLevels[coordinate.y * width + coordinate.x]
    }

    func isValidCoordinate(_ coordinate: Coordinate) -> Bool {
        return coordinate.x >= 0 && coordinate.x < width && coordinate.y >= 0 && coordinate.y < height
    }
}

struct Coordinate: Equatable, Hashable {
    var x: Int
    var y: Int
}

enum Direction {
    case down
    case right
}

struct Path {
    var coordinates: [Coordinate]
    var sumOfRisk: Int
}

public func solutionFor(input: Input) -> Int {
    let startCoordinate = Coordinate(x: 0, y: 0)

    var minimumRiskGrid: [Int] = Array(repeating: Int.max, count: input.width * input.height)

    var stack: [Coordinate] = [startCoordinate]

    minimumRiskGrid[0] = input.riskAt(startCoordinate)

    // dijkstra
    while let cell = stack.first {
        _ = stack.removeFirst()

        let n = Coordinate(x: cell.x, y: cell.y - 1)
        let s = Coordinate(x: cell.x, y: cell.y + 1)
        let w = Coordinate(x: cell.x - 1, y: cell.y)
        let e = Coordinate(x: cell.x + 1, y: cell.y)

        let coordinates: [Coordinate] = [n, s, w, e].filter { input.isValidCoordinate($0) }

        let cellIndex = cell.y * input.width + cell.x

        for coordinate in coordinates {
            let coordinateIndex = coordinate.y * input.width + coordinate.x

            let newRisk = minimumRiskGrid[cellIndex] + input.riskAt(coordinate)

            if minimumRiskGrid[coordinateIndex] > newRisk {
                if minimumRiskGrid[coordinateIndex] != Int.max {
                    stack.removeAll(where: { innerCell in
                        innerCell == coordinate
                    })
                }

                minimumRiskGrid[coordinateIndex] = newRisk

                stack.append(coordinate)
            }
        }
    }

    return minimumRiskGrid.last! - input.riskAt(startCoordinate)
}
