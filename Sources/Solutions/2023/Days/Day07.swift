import Foundation
import Tools

final class Day07Solver: DaySolver {
	let dayNumber: Int = 7

	struct Input {
		let bets: [Bet]
	}

	enum Card: Comparable, Equatable {
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

	enum Hand: Comparable, Equatable, Hashable {
		case highCard
		case onePair
		case twoPair
		case threeOfAKind
		case fullHouse
		case fourOfAKind
		case fiveOfAKind
	}

	struct Bet: Comparable {
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
				return lhs.cards < rhs.cards
			}

			// assume there are no identical hands as it is not described in the rules
			preconditionFailure()
		}

		static func calculateHand(withCards cards: [Card], jokerEnabled: Bool) -> Hand {
			func mapHand(_ hand: Hand, numberOfJokers: Int) -> Hand {
				if numberOfJokers == 0 {
					return hand
				}

				switch hand {
				case .fiveOfAKind: return .fiveOfAKind
				case .fourOfAKind: return .fiveOfAKind
				case .fullHouse: return .fiveOfAKind
				case .threeOfAKind: return .fourOfAKind
				case .twoPair: return numberOfJokers == 1 ? .fullHouse : .fourOfAKind
				case .onePair: return .threeOfAKind
				case .highCard: return .onePair
				}
			}

			let occurrences = cards.occurrences()
			let jokerCount = jokerEnabled ? occurrences[.J, default: 0] : 0

			switch occurrences.count {
			case 5: return mapHand(.highCard, numberOfJokers: jokerCount)
			case 4: return mapHand(.onePair, numberOfJokers: jokerCount)
			case 3:
				switch occurrences.values.max() {
				case 3: return mapHand(.threeOfAKind, numberOfJokers: jokerCount)
				case 2: return mapHand(.twoPair, numberOfJokers: jokerCount)
				case 1: return mapHand(.highCard, numberOfJokers: jokerCount)
				default: preconditionFailure()
				}
			case 2:
				switch occurrences.values.max() {
				case 4: return mapHand(.fourOfAKind, numberOfJokers: jokerCount)
				case 3: return mapHand(.fullHouse, numberOfJokers: jokerCount)
				case 2: return mapHand(.onePair, numberOfJokers: jokerCount)
				case 1: return mapHand(.highCard, numberOfJokers: jokerCount)
				default: preconditionFailure()
				}
			case 1: return mapHand(.fiveOfAKind, numberOfJokers: jokerCount)
			case 0: return mapHand(.highCard, numberOfJokers: jokerCount)
			default: preconditionFailure()
			}
		}
	}

	func solvePart1(withInput input: Input) -> Int {
		let sortedBets = input.bets.sorted()

		var totalScore = 0
		for (index, bet) in sortedBets.enumerated() {
			totalScore += (index + 1) * bet.bid
		}

		return totalScore
	}

	func solvePart2(withInput input: Input) -> Int {
		let jokerEnabledBets = input.bets.map { Bet(cards: $0.cards, bid: $0.bid, jokerEnabled: true) }

		let sortedBets = jokerEnabledBets.sorted()

		var totalScore = 0
		for (index, bet) in sortedBets.enumerated() {
			totalScore += (index + 1) * bet.bid
		}

		return totalScore
	}

	func parseInput(rawString: String) -> Input {
		let bets: [Bet] = rawString.allLines().map { line in
			let components = line.components(separatedBy: " ")

			let cards = components[0].map { Card(string: String($0)) }
			let bid = Int(components[1])!

			return Bet(cards: cards, bid: bid, jokerEnabled: false)
		}

		return .init(bets: bets)
	}
}
