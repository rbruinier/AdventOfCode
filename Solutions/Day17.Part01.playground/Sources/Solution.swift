import Foundation

public struct Input {
    let targetArea: [Int]
}

struct Coordinate {
    var x: Int
    var y: Int

    static func += (lhs: inout Coordinate, rhs: Coordinate) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }
}

typealias Vector = Coordinate

// returns maximum y in case of hit
func tryVelocity(_ originalVelocity: Vector, minX: Int, maxX: Int, minY: Int, maxY: Int) -> Int? {
    var origin = Coordinate(x: 0, y: 0)
    var velocity = originalVelocity

    var maximumY = Int.min

    while true {
        maximumY = max(maximumY, origin.y)

        origin += velocity

        velocity.x = max(0, velocity.x - 1)
        velocity.y -= 1

//        print("Origin: \(origin) & Velocity: \(velocity)")

        if velocity.x == 0 && origin.x < minX {
            return nil
        }

        if origin.x > maxX {
            return nil
        }

        if origin.y < minY {
            return nil
        }

        if (minX ... maxX).contains(origin.x) && (minY ... maxY).contains(origin.y) {
            return maximumY
        }
    }
}

public func solutionFor(input: Input) -> Int {
    let minX = input.targetArea[0]
    let maxX = input.targetArea[1]
    let minY = input.targetArea[2]
    let maxY = input.targetArea[3]

    var bestMaximumY = Int.min

    for y in 0 ... 1000 {
        for x in 0 ... 1000 {
            if let maximumY = tryVelocity(.init(x: x, y: y), minX: minX, maxX: maxX, minY: minY, maxY: maxY) {
                bestMaximumY = max(bestMaximumY, maximumY)
            }
        }
    }


    return bestMaximumY
}