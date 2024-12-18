import BigNumber
import Collections
import Foundation
import Tools

final class Day22Solver: DaySolver {
	let dayNumber: Int = 22

	struct Input {
		let steps: [Step]
	}

	enum Step {
		case reverse
		case cut(n: Int)
		case increment(n: Int)
	}

	private func reverse(deck: [Int]) -> [Int] {
		deck.reversed()
	}

	private func cut(deck: [Int], n: Int) -> [Int] {
		if n >= 0 {
			Array(deck[n ..< deck.count] + deck[0 ..< n])
		} else {
			Array(deck[deck.count + n ..< deck.count] + deck[0 ..< deck.count + n])
		}
	}

	private func increment(deck: [Int], n: Int) -> [Int] {
		var dequeDeck = Deque(deck)
		var newDeck: [Int] = Array(repeating: 0, count: deck.count)

		var index = 0

		while dequeDeck.isNotEmpty {
			newDeck[index] = dequeDeck.removeFirst()

			index = (index + n) % deck.count
		}

		return newDeck
	}

	func solvePart1(withInput input: Input) -> Int {
		var deck: [Int] = []

		for i in 0 ... 10006 {
			deck.append(i)
		}

		for step in input.steps {
			switch step {
			case .reverse:
				deck = reverse(deck: deck)
			case .cut(let n):
				deck = cut(deck: deck, n: n)
			case .increment(let n):
				deck = increment(deck: deck, n: n)
			}

			//            print("\(step): \(deck)")
		}

		return deck.firstIndex(of: 2019)!
	}

	func solvePart2(withInput input: Input) -> String {
		// source: https://www.reddit.com/r/adventofcode/comments/ee0rqi/2019_day_22_solutions/fbnifwk/

		func modPower(_ x: BInt, _ y: BInt, _ m: BInt) -> BInt {
			if y == 0 {
				return 1
			}

			var p = modPower(x, y / 2, m) % m

			p = (p * p) % m

			return (y % 2 == 0) ? p : (x * p) % m
		}

		func modInverse(_ a: BInt, _ m: BInt) -> BInt {
			modPower(a, m - 2, m)
		}

		let deckSize = BInt(119315717514047)
		let loopSize = BInt(101741582076661)

		let X = BInt(2020)

		func apply(steps: [Step], index originalIndex: BInt) -> BInt {
			var index = originalIndex

			for step in input.steps.reversed() {
				switch step {
				case .reverse:
					index = deckSize - index - 1
				case .cut(let n):
					index = (index + deckSize + BInt(n)) % deckSize
				case .increment(let n):
					index = modInverse(BInt(n), deckSize) * index % deckSize
				}
			}

			return index
		}

		let Y = apply(steps: input.steps, index: 2020)
		let Z = apply(steps: input.steps, index: Y)

		let A: BInt = (Y - Z) * modInverse(X - Y, deckSize) % deckSize
		let B: BInt = (Y - A * X) % deckSize

		return String((modPower(A, loopSize, deckSize) * X + (modPower(A, loopSize, deckSize) - 1) * modInverse(A - 1, deckSize) * B) % deckSize)
	}

	func parseInput(rawString: String) -> Input {
		var invalidNumberCharacterSet = NSCharacterSet.decimalDigits

		invalidNumberCharacterSet.insert("-")

		invalidNumberCharacterSet = invalidNumberCharacterSet.inverted

		let steps: [Step] = rawString.allLines().map { line in
			if line.starts(with: "deal with increment") {
				Step.increment(n: Int(line.trimmingCharacters(in: invalidNumberCharacterSet))!)
			} else if line.starts(with: "cut") {
				Step.cut(n: Int(line.trimmingCharacters(in: invalidNumberCharacterSet))!)
			} else {
				Step.reverse
			}
		}

		return .init(steps: steps)
	}
}
