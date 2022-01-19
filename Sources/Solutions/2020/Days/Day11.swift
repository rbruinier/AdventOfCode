import Foundation
import Tools

final class Day11Solver: DaySolver {
    let dayNumber: Int = 11

    private var input: Input!

    private struct Input {
        let states: [State]

        let width: Int
        let height: Int
    }

    private enum State {
        case floor
        case empty
        case occupied
    }

    private func processStatesPart1(_ originalStates: [State], width: Int, height: Int) -> (states: [State], modified: Bool) {
        var states = originalStates
        var modified = false

        var index = 0
        for y in 0 ..< height {
            for x in 0 ..< width {
                defer {
                    index += 1
                }

                guard originalStates[index] != .floor else {
                    continue
                }

                var sum = 0

                for innerY in max(0, y - 1) ... min(height - 1, y + 1) {
                    for innerX in max(0, x - 1) ... min(width - 1, x + 1) {
                        guard (innerY == y && innerX == x) == false else {
                            continue
                        }

                        sum += (originalStates[innerY * width + innerX] == .occupied) ? 1 : 0
                    }
                }

                if originalStates[index] == .empty && sum == 0 {
                    states[index] = .occupied

                    modified = true
                } else if originalStates[index] == .occupied && sum >= 4 {
                    states[index] = .empty

                    modified = true
                }
            }
        }

        return (states: states, modified: modified)
    }

    private func processStatesPart2(_ originalStates: [State], width: Int, height: Int) -> (states: [State], modified: Bool) {
        let directions: [(x: Int, y: Int)] = [
            (x: -1, y: -1),
            (x: 0, y: -1),
            (x: 1, y: -1),
            (x: -1, y: 0),
            (x: 1, y: 0),
            (x: -1, y: 1),
            (x: 0, y: 1),
            (x: 1, y: 1)
        ]

        var states = originalStates
        var modified = false

        var index = 0
        for y in 0 ..< height {
            for x in 0 ..< width {
                defer {
                    index += 1
                }

                guard originalStates[index] != .floor else {
                    continue
                }

                var sum = 0

                for direction in directions {
                    var currentX = x
                    var currentY = y

                    while true {
                        currentX += direction.x
                        currentY += direction.y

                        guard currentX >= 0 && currentY >= 0 && currentX < width && currentY < height else {
                            break
                        }

                        let state = originalStates[currentY * width + currentX]

                        sum += state == .occupied ? 1 : 0

                        if state != .floor {
                            break
                        }
                    }
                }

                if originalStates[index] == .empty && sum == 0 {
                    states[index] = .occupied

                    modified = true
                } else if originalStates[index] == .occupied && sum >= 5 {
                    states[index] = .empty

                    modified = true
                }
            }
        }

        return (states: states, modified: modified)
    }

    func solvePart1() -> Any {
        var states = input.states

        var stepCount = 0
        while true {
            stepCount += 1

            let result = processStatesPart1(states, width: input.width, height: input.height)

            if result.modified == false {
                return result.states.reduce(0) { result, state in
                    result + ((state == .occupied) ? 1 : 0)
                }
            }

            states = result.states
        }
    }

    func solvePart2() -> Any {
        var states = input.states

        var stepCount = 0
        while true {
            stepCount += 1

            let result = processStatesPart2(states, width: input.width, height: input.height)

            if result.modified == false {
                return result.states.reduce(0) { result, state in
                    result + ((state == .occupied) ? 1 : 0)
                }
            }

            states = result.states
        }
    }

    func parseInput(rawString: String) {
        let lines = rawString.allLines()

        let states: [State] = rawString.compactMap {
            switch $0 {
            case "L": return .empty
            case ".": return .floor
            default: return nil
            }
        }

        let width = states.count / lines.count
        let height = lines.count

        input = .init(states: states, width: width, height: height)
    }
}
