import Foundation
import Tools

final class Day24Solver: DaySolver {
	let dayNumber: Int = 24

	struct Input {
		let immunityArmy: Army
		let infectionArmy: Army
	}

	enum AttackType: String, CustomStringConvertible {
		case slashing
		case bludgeoning
		case fire
		case cold
		case radiation

		var description: String {
			rawValue
		}
	}

	// class as we need we need to update values in realtime when handling the unit loss in a loop
	final class Group: Hashable {
		let id: Int

		let hitPoints: Int
		var attackDamage: Int
		let initiative: Int
		let weaknesses: [AttackType]
		let immunities: [AttackType]
		let attackType: AttackType

		var units: Int

		var effectivePower: Int {
			units * attackDamage
		}

		init(group: Group) {
			id = group.id
			hitPoints = group.hitPoints
			attackDamage = group.attackDamage
			initiative = group.initiative
			weaknesses = group.weaknesses
			immunities = group.immunities
			attackType = group.attackType
			units = group.units
		}

		init(id: Int, hitPoints: Int, attackDamage: Int, initiative: Int, weaknesses: [AttackType], immunities: [AttackType], attackType: AttackType, units: Int) {
			self.id = id
			self.hitPoints = hitPoints
			self.attackDamage = attackDamage
			self.initiative = initiative
			self.weaknesses = weaknesses
			self.immunities = immunities
			self.attackType = attackType
			self.units = units
		}

		static func == (_ lhs: Group, _ rhs: Group) -> Bool {
			lhs.id == rhs.id
		}

		func hash(into hasher: inout Hasher) {
			hasher.combine(id)
		}
	}

	struct Army {
		var groups: Set<Group>
	}

	private func potentialDamage(of group: Group, on enemyGroup: Group) -> Int {
		// The damage an attacking group deals to a defending group depends on the attacking group's attack type and the
		// defending group's immunities and weaknesses. By default, an attacking group would deal damage equal to its effective
		// power to the defending group. However, if the defending group is immune to the attacking group's attack type, the
		// defending group instead takes no damage; if the defending group is weak to the attacking group's attack type, the defending
		// group instead takes double damage.

		if enemyGroup.immunities.contains(group.attackType) {
			return 0
		}

		return group.effectivePower * (enemyGroup.weaknesses.contains(group.attackType) ? 2 : 1)
	}

	private func findGroupToAttack(for group: Group, in enemyGroups: Set<Group>) -> Group? {
		// The attacking group chooses to target the group in the enemy army to which it would deal the most damage (after accounting
		// for weaknesses and immunities, but not accounting for whether the defending group has enough units to actually receive all
		// of that damage). If an attacking group is considering two defending groups to which it would deal equal damage, it chooses
		// to target the defending group with the largest effective power; if there is still a tie, it chooses the defending group with
		// the highest initiative. If it cannot deal any defending groups damage, it does not choose a target. Defending groups can only
		// be chosen as a target by one attacking group.

		let first = enemyGroups.sorted(by: { lhs, rhs in
			let lhsDamage = potentialDamage(of: group, on: lhs)
			let rhsDamage = potentialDamage(of: group, on: rhs)

			if lhsDamage == rhsDamage {
				if lhs.effectivePower == rhs.effectivePower {
					return lhs.initiative > rhs.initiative
				} else {
					return lhs.effectivePower > rhs.effectivePower
				}
			} else {
				return lhsDamage > rhsDamage
			}
		}).first

		guard let first else {
			return nil
		}

		if potentialDamage(of: group, on: first) == 0 {
			return nil
		}

		return first
	}

	private func orderAttackingGroupsInAttackingOrder(groups: Set<Group>) -> [Group] {
		// In decreasing order of effective power, groups choose their targets; in a tie, the group with the higher initiative
		// chooses first.

		groups.sorted(by: { lhs, rhs in
			if lhs.effectivePower == rhs.effectivePower {
				lhs.initiative > rhs.initiative
			} else {
				lhs.effectivePower > rhs.effectivePower
			}
		})
	}

	private func doFight(withImmunityArmy immunityArmy: inout Army, andInfectionArmy infectionArmy: inout Army) -> Int {
		enum AttackPair: Comparable {
			case immunityOnInfection(immunityGroup: Group, infectionGroup: Group)
			case infectionOnImmunity(infectionGroup: Group, immunityGroup: Group)

			var attacker: Group {
				switch self {
				case .immunityOnInfection(let immunityGroup, _):
					immunityGroup
				case .infectionOnImmunity(let infectionGroup, _):
					infectionGroup
				}
			}

			var defender: Group {
				switch self {
				case .immunityOnInfection(_, let infectionGroup):
					infectionGroup
				case .infectionOnImmunity(_, let immunityGroup):
					immunityGroup
				}
			}

			static func < (_ lhs: AttackPair, _ rhs: AttackPair) -> Bool {
				lhs.attacker.initiative > rhs.attacker.initiative
			}
		}

		// phase 1 is scheduling all attacks
		var scheduledAttacks: [AttackPair] = []

		var remainingInfectionGroups = infectionArmy.groups
		for immunityGroup in orderAttackingGroupsInAttackingOrder(groups: immunityArmy.groups) {
			if let infectionGroup = findGroupToAttack(for: immunityGroup, in: remainingInfectionGroups) {
				scheduledAttacks.append(.immunityOnInfection(immunityGroup: immunityGroup, infectionGroup: infectionGroup))

				remainingInfectionGroups.remove(infectionGroup)
			}
		}

		var remainingImmunityGroups = immunityArmy.groups
		for infectionGroup in orderAttackingGroupsInAttackingOrder(groups: infectionArmy.groups) {
			if let immunityGroup = findGroupToAttack(for: infectionGroup, in: remainingImmunityGroups) {
				scheduledAttacks.append(.infectionOnImmunity(infectionGroup: infectionGroup, immunityGroup: immunityGroup))

				remainingImmunityGroups.remove(immunityGroup)
			}
		}

		// phase 2 is executing the attacks
		scheduledAttacks.sort()

		var totalUnitsKilled = 0
		for attack in scheduledAttacks {
			let attacker = attack.attacker
			let defender = attack.defender

			let potentialDamage = potentialDamage(of: attacker, on: defender)
			let units = min(potentialDamage / defender.hitPoints, defender.units)

			defender.units -= units
			totalUnitsKilled += units
		}

		// prune defeated groups
		immunityArmy.groups = immunityArmy.groups.filter { $0.units > 0 }
		infectionArmy.groups = infectionArmy.groups.filter { $0.units > 0 }

		return totalUnitsKilled
	}

	func solvePart1(withInput input: Input) -> Int {
		var immunityArmy = Army(groups: Set(input.immunityArmy.groups.map { Group(group: $0) }))
		var infectionArmy = Army(groups: Set(input.infectionArmy.groups.map { Group(group: $0) }))

		while immunityArmy.groups.isNotEmpty, infectionArmy.groups.isNotEmpty {
			let totalUnitsKilled = doFight(withImmunityArmy: &immunityArmy, andInfectionArmy: &infectionArmy)

			if totalUnitsKilled == 0 {
				break
			}
		}

		if immunityArmy.groups.isNotEmpty {
			return immunityArmy.groups.map(\.units).reduce(0, +)
		} else {
			return infectionArmy.groups.map(\.units).reduce(0, +)
		}
	}

	func solvePart2(withInput input: Input) -> Int {
		// brute force testing works well enough
		var boost = 0

		while true {
			var immunityArmy = Army(groups: Set(input.immunityArmy.groups.map { Group(group: $0) }))
			var infectionArmy = Army(groups: Set(input.infectionArmy.groups.map { Group(group: $0) }))

			for immunityGroup in immunityArmy.groups {
				immunityGroup.attackDamage += boost
			}

			var totalUnitsKilled = 0
			while immunityArmy.groups.isNotEmpty, infectionArmy.groups.isNotEmpty {
				totalUnitsKilled = doFight(withImmunityArmy: &immunityArmy, andInfectionArmy: &infectionArmy)

				// stagnant match
				if totalUnitsKilled == 0 {
					break
				}
			}

			if totalUnitsKilled != 0, immunityArmy.groups.isNotEmpty {
				return immunityArmy.groups.map(\.units).reduce(0, +)
			} else {
				boost += 1
			}
		}
	}

	func parseInput(rawString: String) -> Input {
		let lines = rawString.allLines()

		var parsingImmuneSystem = false

		func parseWeaknessesAndImmunities(from text: String) -> (weaknesses: [AttackType], immunities: [AttackType]) {
			var weaknesses: [AttackType] = []
			var immunities: [AttackType] = []

			let components = text.components(separatedBy: "; ")

			for component in components {
				if component.hasPrefix("weak to") {
					weaknesses = component[8 ..< component.count].components(separatedBy: ", ").map { AttackType(rawValue: $0)! }
				} else if component.hasPrefix("immune to") {
					immunities = component[10 ..< component.count].components(separatedBy: ", ").map { AttackType(rawValue: $0)! }
				} else {
					preconditionFailure()
				}
			}

			return (weaknesses: weaknesses, immunities: immunities)
		}

		var immunityGroups: Set<Group> = []
		var infectionGroups: Set<Group> = []

		for line in lines {
			if line == "Immune System:" {
				parsingImmuneSystem = true
			} else if line == "Infection:" {
				parsingImmuneSystem = false
			} else if let arguments = line.getCapturedValues(pattern: #"([0-9]*) units each with ([0-9]*) hit points \(([^)]+)\) with an attack that does ([0-9]*) ([a-z]*) damage at initiative ([0-9]*)"#) {
				let weaknessesAndImmunities = parseWeaknessesAndImmunities(from: arguments[2])

				let group = Group(
					id: 1 + (parsingImmuneSystem ? immunityGroups.count : infectionGroups.count),
					hitPoints: Int(arguments[1])!,
					attackDamage: Int(arguments[3])!,
					initiative: Int(arguments[5])!,
					weaknesses: weaknessesAndImmunities.weaknesses,
					immunities: weaknessesAndImmunities.immunities,
					attackType: AttackType(rawValue: arguments[4])!,
					units: Int(arguments[0])!
				)

				if parsingImmuneSystem {
					immunityGroups.insert(group)
				} else {
					infectionGroups.insert(group)
				}
			} else if let arguments = line.getCapturedValues(pattern: #"([0-9]*) units each with ([0-9]*) hit points with an attack that does ([0-9]*) ([a-z]*) damage at initiative ([0-9]*)"#) {
				let group = Group(
					id: 1 + (parsingImmuneSystem ? immunityGroups.count : infectionGroups.count),
					hitPoints: Int(arguments[1])!,
					attackDamage: Int(arguments[2])!,
					initiative: Int(arguments[4])!,
					weaknesses: [],
					immunities: [],
					attackType: AttackType(rawValue: arguments[3])!,
					units: Int(arguments[0])!
				)

				if parsingImmuneSystem {
					immunityGroups.insert(group)
				} else {
					infectionGroups.insert(group)
				}
			} else {
				preconditionFailure()
			}
		}

		return .init(immunityArmy: .init(groups: immunityGroups), infectionArmy: .init(groups: infectionGroups))
	}
}
