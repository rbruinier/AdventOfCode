import Foundation
import Tools

final class Day07Solver: DaySolver {
	let dayNumber: Int = 7

	let expectedPart1Result = 253910319
	let expectedPart2Result = 0

	private var input: Input!

	private struct Input {
		let bets: [Bet]
	}

	private enum Card: Comparable, Equatable, CustomStringConvertible {
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

		var description: String {
			switch self {
			case ._2: "2"
			case ._3: "3"
			case ._4: "4"
			case ._5: "5"
			case ._6: "6"
			case ._7: "7"
			case ._8: "8"
			case ._9: "9"
			case .T: "T"
			case .J: "J"
			case .Q: "Q"
			case .K: "K"
			case .A: "A"
			}
		}
	}

	private enum Hand: Comparable, Equatable {
		case highCard
		case onePair
		case twoPair
		case threeOfAKind
		case fullHouse
		case fourOfAKind
		case fiveOfAKind
	}

	private struct Bet: Comparable, CustomStringConvertible {
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

		var description: String {
			"\(cards) -> \(hand)"
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

			if jokerEnabled, jokerCount > 0 {
				switch bestHand {
				case .highCard:
					switch jokerCount {
					case 1: bestHand = .onePair
					case 2: bestHand = .threeOfAKind
					case 3: bestHand = .fourOfAKind
					case 4: bestHand = .fiveOfAKind
					case 5: bestHand = .fiveOfAKind
					default: preconditionFailure()
					}
				case .onePair:
					switch jokerCount {
					case 1: bestHand = .threeOfAKind
					case 2: bestHand = .fourOfAKind
					case 3: bestHand = .fiveOfAKind
					default: preconditionFailure()
					}
				case .twoPair:
					switch jokerCount {
					case 1: bestHand = .fullHouse
					default: preconditionFailure()
					}
				case .threeOfAKind:
					switch jokerCount {
					case 1: bestHand = .fourOfAKind
					case 2: bestHand = .fiveOfAKind
					default: preconditionFailure()
					}
				case .fourOfAKind:
					switch jokerCount {
					case 1: bestHand = .fiveOfAKind
					default: preconditionFailure()
					}
				case .fullHouse,
				     .fiveOfAKind:
					preconditionFailure()
				}
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
