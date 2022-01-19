import Foundation
import Tools

// todo: improve performance by implementing a stack as removeFirst is slow

final class Day22Solver: DaySolver {
    let dayNumber: Int = 22

    private var input: Input!

    private struct Input {
        let player1: Player
        let player2: Player
    }

    private struct Player {
        let cards: [Int]
    }

    private struct GameState: Hashable, Equatable {
        let player1Cards: [Int]
        let player2Cards: [Int]
    }

    private func playGame(player1Cards: [Int], player2Cards: [Int], gameId: inout Int, allowRecursion: Bool) -> (winner: Int, winnerCards: [Int]) {
        var gameStates: Set<GameState> = Set()

        var cards1 = player1Cards
        var cards2 = player2Cards

        var round = 1
        while cards1.isNotEmpty && cards2.isNotEmpty {
            let gameState = GameState(player1Cards: cards1, player2Cards: cards2)

            guard gameStates.contains(gameState) == false else {
                return (winner: 1, winnerCards: cards1)
            }

            gameStates.insert(gameState)

            let player1Card = cards1.removeFirst()
            let player2Card = cards2.removeFirst()

            let winner: Int

            if allowRecursion, cards1.count >= player1Card && cards2.count >= player2Card {
                // branch
                let newGameCards1 = Array(cards1[0 ..< player1Card])
                let newGameCards2 = Array(cards2[0 ..< player2Card])

                gameId += 1

                winner = playGame(player1Cards: newGameCards1, player2Cards: newGameCards2, gameId: &gameId, allowRecursion: allowRecursion).winner
            } else {
                winner = player1Card > player2Card ? 1 : 2
            }

            if winner == 1 {
                cards1.append(player1Card)
                cards1.append(player2Card)
            } else {
                cards2.append(player2Card)
                cards2.append(player1Card)
            }

            round += 1
        }

        if cards1.isNotEmpty {
            return (winner: 1, winnerCards: cards1)
        } else {
            return (winner: 2, winnerCards: cards2)
        }
    }

    public func solvePart1() -> Any {
        var gameId = 1

        let winnerCards = playGame(player1Cards: input.player1.cards, player2Cards: input.player2.cards, gameId: &gameId, allowRecursion: false).winnerCards

        var score = 0
        for (index, card) in winnerCards.enumerated() {
            score += (winnerCards.count - index) * card
        }

        return score
    }

    func solvePart2() -> Any {
        var gameId = 1

        let winnerCards = playGame(player1Cards: input.player1.cards, player2Cards: input.player2.cards, gameId: &gameId, allowRecursion: true).winnerCards

        var score = 0
        for (index, card) in winnerCards.enumerated() {
            score += (winnerCards.count - index) * card
        }

        return score
    }

    func parseInput(rawString: String) {
        var lines = rawString.allLines(includeEmpty: true)

        lines.removeFirst() // player 1

        var cards1: [Int] = []
        while lines.first?.isNotEmpty ?? false {
            cards1.append(Int(lines.removeFirst())!)
        }

        lines.removeFirst() // empty line
        lines.removeFirst() // player 2

        var cards2: [Int] = []
        while lines.first?.isNotEmpty ?? false {
            cards2.append(Int(lines.removeFirst())!)
        }

        input = .init(player1: .init(cards: cards1), player2: .init(cards: cards2))
    }
}
