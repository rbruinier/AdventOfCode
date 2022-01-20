import Foundation
import Tools

final class Day10Solver: DaySolver {
    let dayNumber: Int = 10

    private var input: Input!

    private struct Input {
        let asteroids: [Point2D]

        let width: Int
        let height: Int
    }

    private var matchesPerAsteroid: [Point2D: [Point2D]]!
    private var bestMatch: Point2D!

    func solvePart1() -> Any {
        matchesPerAsteroid = [:]

        bestMatch = input.asteroids.first!

        for asteroidA in input.asteroids {
            matchesPerAsteroid[asteroidA] = []

            for asteroidB in input.asteroids where asteroidA != asteroidB {
                let offset = asteroidB - asteroidA
                let length = offset.x * offset.x + offset.y * offset.y

                let angle = atan2(Double(offset.y), Double(offset.x))

                // check if there are other asteroids in the same line with shorter distance
                var isBlocked = false
                for asteroidC in input.asteroids where asteroidC != asteroidA && asteroidC != asteroidB {
                    let subOffset = asteroidC - asteroidA

                    let subAngle = atan2(Double(subOffset.y), Double(subOffset.x))

                    if angle != subAngle {
                        continue
                    }

                    guard sign(offset.x) == sign(subOffset.x) && sign(offset.y) == sign(subOffset.y) else {
                        continue
                    }

                    let subLength = subOffset.x * subOffset.x + subOffset.y * subOffset.y

                    if subLength < length {
                        isBlocked = true

                        break
                    }
                }

                if isBlocked == false {
                    matchesPerAsteroid[asteroidA]!.append(asteroidB)
                }
            }

            if matchesPerAsteroid[asteroidA]!.count > matchesPerAsteroid[bestMatch]!.count {
                bestMatch = asteroidA
            }
        }

        return matchesPerAsteroid[bestMatch]!.count
    }

    func solvePart2() -> Any {
        func degrees(_ x: Double, _ y: Double) -> Double {
            var degrees = Double.pi * 0.5 + (atan2(y, x)).remainder(dividingBy: Double.pi * 2.0)

            if degrees < 0 {
                degrees += Double.pi * 2.0
            }

            return degrees
        }

        // 1. group asteroids by angle in relation to base asteroid
        // 2. then sort the group by distance, closest first
        // 3. loop through angles and pop first of groups each round

        var asteroidsByAngle: [Double: [Point2D]] = [:]

        for asteroid in input.asteroids where asteroid != bestMatch {
            let offset = Point2D(x: asteroid.x - bestMatch.x, y: asteroid.y - bestMatch.y)

            let angle = degrees(Double(offset.x), Double(offset.y))

            asteroidsByAngle[angle, default: []].append(asteroid)
        }

        for angle in asteroidsByAngle.keys {
            asteroidsByAngle[angle] = asteroidsByAngle[angle]?.sorted(by: { lhs, rhs in
                let lhsOffset = Point2D(x: lhs.x - bestMatch.x, y: lhs.y - bestMatch.y)
                let rhsOffset = Point2D(x: rhs.x - bestMatch.x, y: rhs.y - bestMatch.y)

                return (lhsOffset.x * lhsOffset.x + lhsOffset.y * lhsOffset.y) < (rhsOffset.x * rhsOffset.x + rhsOffset.y * rhsOffset.y)
            })
        }

        while true {
            var counter = 1
            for angle in asteroidsByAngle.keys.sorted() {
                var matches = asteroidsByAngle[angle]!

                if let asteroid = matches.first {
                    if counter == 200 {
                        return asteroid.x * 100 + asteroid.y
                    }

                    matches.removeFirst()

                    asteroidsByAngle[angle] = matches
                }

                counter += 1
            }
        }
    }

    func parseInput(rawString: String) {
        let lines = rawString.allLines()

        let height = lines.count
        let width = lines.first!.count

        var asteroids: [Point2D] = []

        for y in 0 ..< height {
            let line = lines[y]

            for x in 0 ..< width {
                if line[x ... x] != "." {
                    asteroids.append(.init(x: x, y: y))
                }
            }
        }

        input = .init(asteroids: asteroids, width: width, height: height)
    }
}
