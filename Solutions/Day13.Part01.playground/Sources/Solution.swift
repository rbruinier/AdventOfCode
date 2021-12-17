import Foundation

public struct Input {
    let coordinates: [Coordinate]

    let folds: [Fold]

    let width: Int
    let height: Int
}

public enum Fold {
    case horizontal(y: Int)
    case vertical(x: Int)
}

public struct Coordinate {
    let x: Int
    let y: Int
}

struct Grid: CustomDebugStringConvertible {
    let width: Int
    let height: Int

    var items: [Bool]

    init(width: Int, height: Int) {
        self.width = width
        self.height = height

        items = Array(repeating: false, count: width * height)
    }

    mutating func mark(at coordinate: Coordinate) {
        items[coordinate.y * width + coordinate.x] = true
    }

    mutating func apply(fold: Fold) -> Grid {
        switch fold {
        case .vertical(let foldX):
            var newGrid = Grid(width: foldX, height: height)

            for y in 0 ..< height {
                for x in foldX ..< width {
                    let offset = x - foldX
                    let targetX = (foldX - offset)

                    if targetX < 0 {
                        break
                    }

                    if items[y * width + x] || items[y * width + targetX] {
                        newGrid.mark(at: .init(x: targetX, y: y))
                    }
                }
            }

            return newGrid
        case .horizontal(let foldY):
            var newGrid = Grid(width: width, height: foldY)

            for y in foldY ..< height {
                let offset = y - foldY
                let targetY = (foldY - offset)

                if targetY < 0 {
                    break
                }

                for x in 0 ..< width {
                    if items[y * width + x] || items[targetY * width + x] {
                        newGrid.mark(at: .init(x: x, y: targetY))
                    }
                }
            }

            return newGrid
        }
    }

    var debugDescription: String {
        var result = ""

        for y in 0 ..< height {
            for x in 0 ..< width {
                result += items[y * width + x] ? "#" : "."
            }

            result += "\n"
        }

        return result
    }
}

public func solutionFor(input: Input) -> Int {
    var grid = Grid(width: input.width, height: input.height)

    for coordinate in input.coordinates {
        grid.mark(at: coordinate)
    }

    for fold in input.folds {
        grid = grid.apply(fold: fold)
    }

    print(grid)

    return grid.items.filter { $0 }.count
}
