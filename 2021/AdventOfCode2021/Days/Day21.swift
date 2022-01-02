import Foundation

final class Day21Solver: DaySolver {
    let dayNumber: Int = 21

    private var input: Input!

    private struct Input {
        let startPosition1: Int
        let startPosition2: Int
    }

    private struct Dice {
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

    private struct GameState: Equatable, Hashable {
        let startPosition1: Int
        let startPosition2: Int

        let score1: Int
        let score2: Int
    }

    private struct Wins {
        var player1: Int
        var player2: Int

        static func += (lhs: inout Wins, rhs: Wins) {
            lhs.player1 += rhs.player1
            lhs.player2 += rhs.player2
        }

        var swapped: Wins {
            .init(player1: player2, player2: player1)
        }
    }

    private func iterateAllOptionsForTurn(currentPlayerStartPosition: Int, currentPlayerScore: Int, otherPlayerStartPosition: Int, otherPlayerScore: Int, cache: inout [GameState: Wins]) -> Wins {
        if currentPlayerScore >= 21 {
            return .init(player1: 1, player2: 0)
        } else if otherPlayerScore >= 21 {
            return .init(player1: 0, player2: 1)
        }

        let cacheKey = GameState(startPosition1: currentPlayerStartPosition, startPosition2: otherPlayerStartPosition, score1: currentPlayerScore, score2: otherPlayerScore)

        if let cachedWins = cache[cacheKey] {
            return cachedWins
        }

        var wins = Wins(player1: 0, player2: 0)

        for diceValue1 in 1 ... 3 {
            for diceValue2 in 1 ... 3 {
                for diceValue3 in 1 ... 3 {
                    let newPosition = (currentPlayerStartPosition + diceValue1 + diceValue2 + diceValue3) % 10
                    let newScore = currentPlayerScore + newPosition + 1

                    // toggle player
                    wins += iterateAllOptionsForTurn(
                        currentPlayerStartPosition: otherPlayerStartPosition,
                        currentPlayerScore: otherPlayerScore,
                        otherPlayerStartPosition: newPosition,
                        otherPlayerScore: newScore,
                        cache: &cache).swapped
                }
            }
        }

        cache[cacheKey] = wins

        return wins
    }

    func solvePart1() -> Any {
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

        return diceCount * min(score1, score2)
    }

    func solvePart2() -> Any {
        let position1 = input.startPosition1 - 1
        let position2 = input.startPosition2 - 1

        // we don't care about paths, only about results, we can cache almost every option as many universes will be the same
        // still 3 throws, so every turn branches into 3 * 3 * 3 = 27 options per player

        var cache: [GameState: Wins] = [:]

        let wins = iterateAllOptionsForTurn(currentPlayerStartPosition: position1,
                                            currentPlayerScore: 0,
                                            otherPlayerStartPosition: position2,
                                            otherPlayerScore: 0,
                                            cache: &cache)

        return max(wins.player1, wins.player2)
    }

    func parseInput(rawString: String) {
        input = .init(startPosition1: 3, startPosition2: 10)
    }
}
