import Foundation
import Tools

/// Solves it with deterministic randomness, so bruteforcing and no clever algorithm implemented
final class Day22Solver: DaySolver {
	let dayNumber: Int = 22

	private var randomGenerator = SeededRandomNumberGenerator(seed: 0xDEAD_BEAF)

	struct Input {}

	private class Player {
		var hitPoints: Int
		var mana: Int

		var damage: Int
		var armor: Int

		var spentMana: Int = 0

		init(hitPoints: Int, mana: Int, damage: Int, armor: Int) {
			self.hitPoints = hitPoints
			self.mana = mana
			self.damage = damage
			self.armor = armor
		}
	}

	private class Spell {
		var caster: Player
		var opponent: Player

		var cost: Int { 0 }
		var timer = 0
		var identifier: String { "Unknown" }
		var startTimer: Int { 0 }

		var isActive: Bool {
			timer >= 1
		}

		init(caster: Player, opponent: Player) {
			self.caster = caster
			self.opponent = opponent
		}

		func canCast(budget: Int) -> Bool {
			budget >= cost
		}

		func activate() {
			timer = startTimer

			caster.mana -= cost
			caster.spentMana += cost
		}

		func execute() {
			guard timer >= 1 else {
				fatalError()
			}

			timer = max(0, timer - 1)
		}
	}

	private class MagicMissile: Spell {
		override var cost: Int { 53 }
		override var identifier: String { "Magic Missile" }

		override func activate() {
			super.activate()

			opponent.hitPoints -= 4
		}
	}

	private class Drain: Spell {
		override var cost: Int { 73 }
		override var identifier: String { "Drain" }

		override func activate() {
			super.activate()

			caster.hitPoints += 2
			opponent.hitPoints -= 2
		}
	}

	private class Shield: Spell {
		override var cost: Int { 113 }
		override var identifier: String { "Shield" }
		override var startTimer: Int { 6 }

		override func activate() {
			super.activate()

			caster.armor += 7
		}

		override func execute() {
			super.execute()

			if timer == 0 {
				caster.armor -= 7
			}
		}
	}

	private class Poison: Spell {
		override var cost: Int { 173 }
		override var identifier: String { "Poison" }
		override var startTimer: Int { 6 }

		override func execute() {
			super.execute()

			opponent.hitPoints -= 3
		}
	}

	private class Recharge: Spell {
		override var cost: Int { 229 }
		override var identifier: String { "Recharge" }
		override var startTimer: Int { 5 }

		override func execute() {
			super.execute()

			caster.mana += 101
		}
	}

	private enum Winner {
		case player
		case computer
	}

	private func playTurn(player: Player, computer: Player, hardMode: Bool, isPlayerTurn: Bool, activateSpells: [Spell], activeSpells: inout [Spell]) -> Winner? {
		if hardMode, isPlayerTurn {
			player.hitPoints -= 1

			if player.hitPoints <= 0 {
				return .computer
			}
		}

		var newActiveSpells: [Spell] = []

		for activeSpell in activeSpells {
			if activeSpell.isActive {
				activeSpell.execute()

				if computer.hitPoints <= 0 {
					return .player
				}

				if activeSpell.isActive {
					newActiveSpells.append(activeSpell)
				}
			}
		}

		for activateSpell in activateSpells {
			activateSpell.activate()

			if activateSpell.isActive {
				newActiveSpells.append(activateSpell)
			}
		}

		if computer.hitPoints <= 0 {
			return .player
		}

		activeSpells = newActiveSpells

		if isPlayerTurn == false {
			let damage = max(1, computer.damage - player.armor)

			player.hitPoints -= damage

			if player.hitPoints <= 0 {
				return .computer
			}
		}

		return nil
	}

	private func playGame(hardMode: Bool = false, minMana: Int) -> Int? {
		let player = Player(hitPoints: 50, mana: 500, damage: 0, armor: 0)
		let computer = Player(hitPoints: 55, mana: 0, damage: 8, armor: 0)

		let magicMissile = MagicMissile(caster: player, opponent: computer)
		let drain = Drain(caster: player, opponent: computer)
		let shield = Shield(caster: player, opponent: computer)
		let poison = Poison(caster: player, opponent: computer)
		let recharge = Recharge(caster: player, opponent: computer)

		var activeSpells: [Spell] = []

		gameLoop: while true {
			if player.spentMana > minMana {
				return nil
			}

			var availableSpells: [Spell?] = []

			if magicMissile.timer <= 1, magicMissile.canCast(budget: player.mana) {
				availableSpells.append(magicMissile)
			}

			if drain.timer <= 1, drain.canCast(budget: player.mana) {
				availableSpells.append(drain)
			}

			if shield.timer <= 1, shield.canCast(budget: player.mana) {
				availableSpells.append(shield)
			}

			if poison.timer <= 1, poison.canCast(budget: player.mana) {
				availableSpells.append(poison)
			}

			if recharge.timer <= 1, recharge.canCast(budget: player.mana) {
				availableSpells.append(recharge)
			}

			var result: Winner?

			if availableSpells.isNotEmpty, let randomSpell = availableSpells.randomElement(using: &randomGenerator)! {
				result = playTurn(player: player, computer: computer, hardMode: hardMode, isPlayerTurn: true, activateSpells: [randomSpell], activeSpells: &activeSpells)
			} else {
				result = playTurn(player: player, computer: computer, hardMode: hardMode, isPlayerTurn: true, activateSpells: [], activeSpells: &activeSpells)
			}

			if let result {
				if result == .player {
					return player.spentMana
				} else {
					return nil
				}
			}

			result = playTurn(player: player, computer: computer, hardMode: hardMode, isPlayerTurn: false, activateSpells: [], activeSpells: &activeSpells)

			if let result {
				if result == .player {
					return player.spentMana
				} else {
					return nil
				}
			}
		}
	}

	func solvePart1(withInput input: Input) -> Int {
		var minMana = Int.max

		for _ in 0 ..< 100_000 {
			if let mana = playGame(hardMode: false, minMana: minMana), mana < minMana {
				minMana = mana
			}
		}

		return minMana
	}

	func solvePart2(withInput input: Input) -> Int {
		var minMana = Int.max

		for _ in 0 ..< 100_000 {
			if let mana = playGame(hardMode: true, minMana: minMana), mana < minMana {
				minMana = mana
			}
		}

		return minMana
	}

	func parseInput(rawString: String) -> Input {
		return .init()
	}
}
