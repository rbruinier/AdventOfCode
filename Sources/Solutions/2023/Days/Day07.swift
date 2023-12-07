import Foundation
import Tools

final class Day07Solver: DaySolver {
	let dayNumber: Int = 7

	let expectedPart1Result = 253910319
	let expectedPart2Result = 254083736

	private var input: Input!

	private struct Input {
		let bets: [Bet]
	}

	private enum Card: Comparable, Equatable {
		case _2
		case _3
		case _4
		case _5
		case _6
		case _7
		case _8
		case _9
		case T
		case J
		case Q
		case K
		case A

		init(string: String) {
			switch string {
			case "2": self = ._2
			case "3": self = ._3
			case "4": self = ._4
			case "5": self = ._5
			case "6": self = ._6
			case "7": self = ._7
			case "8": self = ._8
			case "9": self = ._9
			case "T": self = .T
			case "J": self = .J
			case "Q": self = .Q
			case "K": self = .K
			case "A": self = .A
			default: preconditionFailure()
			}
		}
	}

	private enum Hand: Comparable, Equatable, Hashable {
		case highCard
		case onePair
		case twoPair
		case threeOfAKind
		case fullHouse
		case fourOfAKind
		case fiveOfAKind
	}

	private struct Bet: Comparable {
		let cards: [Card]
		let bid: Int

		let hand: Hand

		let jokerEnabled: Bool

		init(cards: [Card], bid: Int, jokerEnabled: Bool) {
			self.cards = cards
			self.bid = bid
			self.jokerEnabled = jokerEnabled

			hand = Self.calculateHand(withCards: cards, jokerEnabled: jokerEnabled)
		}

		static func < (_ lhs: Bet, _ rhs: Bet) -> Bool {
			if lhs.hand != rhs.hand {
				return lhs.hand < rhs.hand
			}

			if lhs.jokerEnabled {
				for cardIndex in 0 ... 4 {
					if lhs.cards[cardIndex] != rhs.cards[cardIndex] {
						let lhsCard = lhs.cards[cardIndex]
						let rhsCard = rhs.cards[cardIndex]

						if lhsCard == .J, rhsCard != .J {
							return true
						} else if rhsCard == .J, lhsCard != .J {
							return false
						} else {
							return lhs.cards[cardIndex] < rhs.cards[cardIndex]
						}
					}
				}
			} else {
				for cardIndex in 0 ... 4 {
					if lhs.cards[cardIndex] != rhs.cards[cardIndex] {
						return lhs.cards[cardIndex] < rhs.cards[cardIndex]
					}
				}
			}

			// assume there are no identical hands as it is not described in the rules
			preconditionFailure()
		}

		static func calculateHand(withCards cards: [Card], jokerEnabled: Bool) -> Hand {
			let sortedCards = cards.sorted()

			var previousCard: Card?
			var currentSeriesCard: Card?
			var bestHand: Hand = .highCard
			var jokerCount = 0

			for card in sortedCards {
				let isJoker = jokerEnabled && card == .J

				defer {
					if !isJoker {
						previousCard = card
					}
				}

				if isJoker {
					jokerCount += 1

					continue
				}

				if previousCard == card {
					if let currentSeriesCard, currentSeriesCard == previousCard {
						switch bestHand {
						case .onePair: bestHand = .threeOfAKind
						case .twoPair: bestHand = .fullHouse
						case .threeOfAKind: bestHand = .fourOfAKind
						case .fourOfAKind: bestHand = .fiveOfAKind
						default: preconditionFailure()
						}
					} else {
						switch bestHand {
						case .highCard: bestHand = .onePair
						case .onePair: bestHand = .twoPair
						case .twoPair: bestHand = .twoPair
						case .threeOfAKind: bestHand = .fullHouse
						default: preconditionFailure()
						}
					}

					currentSeriesCard = card
				} else {
					currentSeriesCard = nil

					continue
				}
			}

			if jokerCount > 0 {
				struct BestHandJokerCombo: Hashable {
					let hand: Hand
					let jokerCount: Int
				}

				let mapping: [BestHandJokerCombo: Hand] = [
					.init(hand: .highCard, jokerCount: 1): .onePair,
					.init(hand: .highCard, jokerCount: 2): .threeOfAKind,
					.init(hand: .highCard, jokerCount: 3): .fourOfAKind,
					.init(hand: .highCard, jokerCount: 4): .fiveOfAKind,
					.init(hand: .highCard, jokerCount: 5): .fiveOfAKind,
					.init(hand: .onePair, jokerCount: 1): .threeOfAKind,
					.init(hand: .onePair, jokerCount: 2): .fourOfAKind,
					.init(hand: .onePair, jokerCount: 3): .fiveOfAKind,
					.init(hand: .twoPair, jokerCount: 1): .fullHouse,
					.init(hand: .threeOfAKind, jokerCount: 1): .fourOfAKind,
					.init(hand: .threeOfAKind, jokerCount: 2): .fiveOfAKind,
					.init(hand: .fourOfAKind, jokerCount: 1): .fiveOfAKind,
				]

				bestHand = mapping[.init(hand: bestHand, jokerCount: jokerCount)]!
			}

			return bestHand
		}
	}

	func solvePart1() -> Int {
		let sortedBets = input.bets.sorted()

		var totalScore = 0
		for (index, bet) in sortedBets.enumerated() {
			totalScore += (index + 1) * bet.bid
		}

		return totalScore
	}

	func solvePart2() -> Int {
		let jokerEnabledBets = input.bets.map { Bet(cards: $0.cards, bid: $0.bid, jokerEnabled: true) }

		let sortedBets = jokerEnabledBets.sorted()

		var totalScore = 0
		for (index, bet) in sortedBets.enumerated() {
			totalScore += (index + 1) * bet.bid
		}

		return totalScore
	}

	func parseInput(rawString: String) {
		let bets: [Bet] = rawString.allLines().map { line in
			let components = line.components(separatedBy: " ")

			let cards = components[0].map { Card(string: String($0)) }
			let bid = Int(components[1])!

			return Bet(cards: cards, bid: bid, jokerEnabled: false)
		}

		input = .init(bets: bets)
	}
}
