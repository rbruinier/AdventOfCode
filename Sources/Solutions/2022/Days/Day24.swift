import Collections
import Foundation
import Tools

final class Day24Solver: DaySolver {
    let dayNumber: Int = 24

    private var input: Input!

    private struct Input {
        let blizzards: [Point2D: [Direction]]

        let areaSize: Size

        let startPoint: Point2D
        let endPoint: Point2D
    }

    private enum Tile {
        case floor
        case wall
    }

    private func moveBlizzards(_ blizzards: [Point2D: [Direction]], areaSize: Size) -> [Point2D: [Direction]] {
        var newBlizzards: [Point2D: [Direction]] = [:]

        for (point, directions) in blizzards {
            for direction in directions {
                var nextPoint = point.moved(to: direction)

                if nextPoint.x == areaSize.width {
                    nextPoint.x = 0
                } else if nextPoint.x == -1 {
                    nextPoint.x = areaSize.width - 1
                }

                if nextPoint.y == areaSize.height {
                    nextPoint.y = 0
                } else if nextPoint.y == -1 {
                    nextPoint.y = areaSize.height - 1
                }

                newBlizzards[nextPoint] = newBlizzards[nextPoint, default: []] + [direction]
            }
        }

        return newBlizzards
    }

    private func shortestPath(from: Point2D, to: Point2D, startSteps: Int, cachedBlizzardStates: inout [Int: [Point2D: [Direction]]]) -> Int {
        struct State {
            let position: Point2D
            let steps: Int
        }

        var queue: Deque<State> = [
            .init(position: from, steps: startSteps)
        ]

        func hashFor(position: Point2D, blizzards: [Point2D: [Direction]]) -> Int {
            let blizzardPoints = Set(blizzards.keys)

            var hasher = Hasher()

            hasher.combine(position)
            hasher.combine(blizzardPoints)

            return hasher.finalize()
        }

        var visitedHashes: Set<Int> = [hashFor(position: from, blizzards: cachedBlizzardStates[startSteps]!)]

        while let state = queue.popFirst() {
            let nextStep = state.steps + 1

            let nextBlizzards: [Point2D: [Direction]]

            if cachedBlizzardStates[nextStep] != nil {
                nextBlizzards = cachedBlizzardStates[nextStep]!
            } else {
                nextBlizzards = moveBlizzards(
                    cachedBlizzardStates[state.steps]!,
                    areaSize: input.areaSize
                )

                cachedBlizzardStates[nextStep] = nextBlizzards
            }

            for nextPoint in state.position.neighbors() {
                if nextPoint == to {
                    print(visitedHashes.count)

                    return state.steps + 1
                }

                guard
                    (0 ..< input.areaSize.width).contains(nextPoint.x),
                    (0 ..< input.areaSize.height).contains(nextPoint.y),
                    nextBlizzards[nextPoint] == nil
                else {
                    continue
                }

                let hash = hashFor(position: nextPoint, blizzards: nextBlizzards)

                guard visitedHashes.contains(hash) == false else {
                    continue
                }

                visitedHashes.insert(hash)

                queue.append(
                    .init(
                        position: nextPoint,
                        steps: nextStep
                    )
                )
            }

            if nextBlizzards[state.position] == nil {
                queue.append(
                    .init(
                        position: state.position,
                        steps: nextStep
                    )
                )
            }
        }

        fatalError()
    }

    func solvePart1() -> Int {
        var cachedBlizzardStates: [Int: [Point2D: [Direction]]] = [0: input.blizzards]

        return shortestPath(from: input.startPoint, to: input.endPoint, startSteps: 0, cachedBlizzardStates: &cachedBlizzardStates)
    }

    func solvePart2() -> Int {
        var cachedBlizzardStates: [Int: [Point2D: [Direction]]] = [0: input.blizzards]

        var steps = shortestPath(from: input.startPoint, to: input.endPoint, startSteps: 0, cachedBlizzardStates: &cachedBlizzardStates)

        steps = shortestPath(from: input.endPoint, to: input.startPoint, startSteps: steps, cachedBlizzardStates: &cachedBlizzardStates)
        steps = shortestPath(from: input.startPoint, to: input.endPoint, startSteps: steps, cachedBlizzardStates: &cachedBlizzardStates)

        return steps
    }

    func parseInput(rawString: String) {
        let allLines = rawString.allLines()

        var blizzards: [Point2D: [Direction]] = [:]

        let width = allLines.first!.count - 2
        let height = allLines.count - 2

        for (y, line) in rawString.allLines().enumerated() {
            for (x, char) in line.enumerated() {
                let point = Point2D(x: x - 1, y: y - 1)

                switch char {
                case "<":
                    blizzards[point] = [.west]
                case ">":
                    blizzards[point] = [.east]
                case "^":
                    blizzards[point] = [.north]
                case "v":
                    blizzards[point] = [.south]
                case "#", ".":
                    break
                default:
                    fatalError()
                }
            }
        }

        input = .init(
            blizzards: blizzards,
            areaSize: .init(
                width: width,
                height: height
            ),
            startPoint: .init(x: 0, y: -1),
            endPoint: .init(x: width - 1, y: height)
        )
    }
}
