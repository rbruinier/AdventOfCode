import Foundation

public struct Input {
    let startPosition1: Int
    let startPosition2: Int
}

struct Dice {
    private var value = 1

    mutating func `throw`() -> Int {
        let result = value

        value += 1

        if value == 101 {
            value = 1
        }

        return result
    }
}

public func solutionFor(input: Input) -> Int {
    var position1 = input.startPosition1 - 1
    var position2 = input.startPosition2 - 1

    var score1: Int = 0
    var score2: Int = 0

    var diceCount = 0

    var dice = Dice()

    while true {
        position1 = (position1 + dice.throw() + dice.throw() + dice.throw()) % 10

        diceCount += 3
        score1 += position1 + 1

        if score1 >= 999 {
            break
        }

        position2 = (position2 + dice.throw() + dice.throw() + dice.throw()) % 10

        diceCount += 3
        score2 += position2 + 1

        if score2 >= 999 {
            break
        }
    }

    print("Dice count: \(diceCount)")

    print("Position and score 1: \(position1) & \(score1), 2: \(position2) & \(score2)")

    return diceCount * min(score1, score2)
}
