import Foundation
import Tools

final class Day21Solver: DaySolver {
	let dayNumber: Int = 21

	// we get part 2 for free in part 1 so we cache it
	var maximumLoosingCost = Int.min

	struct Input {
		let weapons: [Item]
		let armors: [Item]
		let rings: [Item]

		let computer = Player(hitPoints: 103, damageScore: 9, armorScore: 2)
	}

	private struct Item {
		let name: String
		let cost: Int
		let damage: Int
		let armor: Int
	}

	private struct Player {
		var hitPoints: Int = 100

		var damageScore: Int
		var armorScore: Int

		var cost: Int

		init(weapon: Item, armor: Item?, rings: [Item]) {
			damageScore = weapon.damage + rings.map(\.damage).reduce(0, +)
			armorScore = (armor?.armor ?? 0) + rings.map(\.armor).reduce(0, +)

			cost = weapon.cost + (armor?.cost ?? 0) + rings.map(\.cost).reduce(0, +)
		}

		init(hitPoints: Int, damageScore: Int, armorScore: Int) {
			self.hitPoints = hitPoints
			self.damageScore = damageScore
			self.armorScore = armorScore

			cost = 0
		}
	}

	func solvePart1(withInput input: Input) -> Int {
		let weapons = input.weapons
		let armors: [Item?] = input.armors + [nil]
		let rings = input.rings

		let ringCombinations = rings.subsets(minLength: 0, maxLength: 2)

		var minimumCost = Int.max

		for weapon in weapons {
			for armor in armors {
				for ringCombination in ringCombinations {
					let player = Player(weapon: weapon, armor: armor, rings: ringCombination)
					let computer = input.computer

					// no need to emulate the game, we can calculate turns for each
					let playerTurns = ceil(Double(player.hitPoints) / Double(max(1, computer.damageScore - player.armorScore)))
					let computerTurns = ceil(Double(computer.hitPoints) / Double(max(1, player.damageScore - computer.armorScore)))

					if playerTurns >= computerTurns {
						minimumCost = min(minimumCost, player.cost)
					} else {
						maximumLoosingCost = max(maximumLoosingCost, player.cost)
					}
				}
			}
		}

		return minimumCost
	}

	func solvePart2(withInput input: Input) -> Int {
		maximumLoosingCost
	}

	func parseInput(rawString: String) -> Input {
		return Input(
			weapons: [
				.init(name: "Dagger", cost: 8, damage: 4, armor: 0),
				.init(name: "Shortsword", cost: 10, damage: 5, armor: 0),
				.init(name: "Warhammer", cost: 25, damage: 6, armor: 0),
				.init(name: "Longsword", cost: 40, damage: 7, armor: 0),
				.init(name: "Greataxe", cost: 74, damage: 8, armor: 0),
			],
			armors: [
				.init(name: "Leather", cost: 13, damage: 0, armor: 1),
				.init(name: "Chainmail", cost: 31, damage: 0, armor: 2),
				.init(name: "Splintmail", cost: 53, damage: 0, armor: 3),
				.init(name: "Bandedmail", cost: 75, damage: 0, armor: 4),
				.init(name: "Platemail", cost: 102, damage: 0, armor: 5),
			],
			rings: [
				.init(name: "Damage +1", cost: 25, damage: 1, armor: 0),
				.init(name: "Damage +2", cost: 50, damage: 2, armor: 0),
				.init(name: "Damage +3", cost: 100, damage: 3, armor: 0),
				.init(name: "Defense +1", cost: 20, damage: 0, armor: 1),
				.init(name: "Defense +2", cost: 40, damage: 0, armor: 2),
				.init(name: "Defense +3", cost: 80, damage: 0, armor: 3),
			]
		)
	}
}
