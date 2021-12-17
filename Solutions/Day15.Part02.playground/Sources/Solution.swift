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

public func solutionFor(input: Input) -> Int {
    // credits to the idea to this reddit post: https://www.reddit.com/r/adventofcode/comments/rh5vgv/comment/hoppwtt/?utm_source=share&utm_medium=web2x&context=3

    var minimumRiskGrid: [Int] = Array(repeating: Int.max >> 1, count: input.width * input.height)

    minimumRiskGrid[0] = 0
    
    var computing = true

    while computing {
        computing = false

        print("Computing")

        for y in 0 ..< input.height {
            for x in 0 ..< input.width {
                let n = Coordinate(x: x, y: y - 1)
                let s = Coordinate(x: x, y: y + 1)
                let w = Coordinate(x: x - 1, y: y)
                let e = Coordinate(x: x + 1, y: y)

                let coordinates: [Coordinate] = [n, s, w, e].filter { input.isValidCoordinate($0) }

                let minNeighborRisk = coordinates.map { minimumRiskGrid[($0.y * input.width) + $0.x] }.min()!

                let potential = minNeighborRisk + input.riskAt(Coordinate(x: x, y: y))

                if potential < minimumRiskGrid[(y * input.width) + x] {
                    minimumRiskGrid[y * input.width + x]  = potential

                    computing = true
                }
            }
        }
    }

    return minimumRiskGrid.last!
}
