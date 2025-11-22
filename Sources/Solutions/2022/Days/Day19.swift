import Foundation
import Tools

/// With the lessons learned during the struggle of day 16 this was quite doable although at the moment it takes significant time (~107 seconds) in total.
///
/// Memoization is used once again... all input could be packed in an 64 bit int so that is used as a key. Sadly the space is too big to initialize an
/// array with the full size like at day 16 so instead a dictionary is used, which is much slower.
///
/// The parameter ranges have been analysed by printing out max values for all key components. Same for the memoization capacity reservation which helps a bit with performance.
///
/// Some implemented pruning rules for the tree:
///  * if we can build a geode bot always build that and don't try anything else
///  * if we can always build a geode bot (the robot output is greater or equal than required resources) always try to build one
///  * else if time remaining is less than 5 only attempt to build a obsidian bot; this can probably be fine tuned further
///  * else go through all possible combinations of robot building priorities (not really pruning this step)
///  * if we can always build a geode or obsidian both (based on robots) we don't test the path where we don't build anything
///
/// There are more pruning rules to be discovered but it is sometimes hard to make sure these work for all input and not just mine.
///
/// Multithreading could also be a path to be explored as each blueprint can be examined in parallel, but RAM is needed. 4 GB is reserved for memoization at the moment.
final class Day19Solver: DaySolver {
	let dayNumber: Int = 19

	struct Input {
		let blueprints: [Blueprint]
	}

	private struct CountByMaterial {
		var ore: Int = 0
		var clay: Int = 0
		var obsidian: Int = 0
		var geode: Int = 0

		static var zero: CountByMaterial {
			.init()
		}
	}

	struct Blueprint {
		let id: Int
		var oreRobotOreCost: Int
		var clayRobotOreCost: Int
		var obsidianRobotOreCost: Int
		var obsidianRobotClayCost: Int
		var geodeRobotOreCost: Int
		var geodeRobotObsidianCost: Int
	}

	private enum Robot: Hashable {
		case ore
		case clay
		case obsidian
		case geode
	}

	private var globalScore = 0

	private var memoization: [Int: Int] = [:]
	private var counter = 0

	private var maxInventory = CountByMaterial()
	private var maxRobot = CountByMaterial()
	private var maxGeodesPerMinute: [Int: Int] = [:]

	private let logEnabled = false

	init() {}

	private func bestScore(blueprint: Blueprint, timeRemaining: Int, robots: CountByMaterial, inventory: CountByMaterial) -> Int {
		if timeRemaining <= 0 {
			if logEnabled {
				if inventory.obsidian > maxInventory.obsidian || inventory.geode > maxInventory.geode || inventory.ore > maxInventory.ore || inventory.clay > maxInventory.clay {
					maxInventory.obsidian = max(maxInventory.obsidian, inventory.obsidian)
					maxInventory.geode = max(maxInventory.geode, inventory.geode)
					maxInventory.clay = max(maxInventory.clay, inventory.clay)
					maxInventory.ore = max(maxInventory.ore, inventory.ore)

					print("New max inventory:\n\(maxInventory)")
				}

				if robots.obsidian > maxRobot.obsidian || robots.geode > maxRobot.geode || robots.ore > maxRobot.ore || robots.clay > maxRobot.clay {
					maxRobot.obsidian = max(maxRobot.obsidian, robots.obsidian)
					maxRobot.geode = max(maxRobot.geode, robots.geode)
					maxRobot.clay = max(maxRobot.clay, robots.clay)
					maxRobot.ore = max(maxRobot.ore, robots.ore)

					print("New max robots:\n\(maxRobot)")
				}
			}

			return inventory.geode + robots.geode
		}

		// designed this by printing max values for each of the parameters:
		//
		// time remaining: 0 ... 31 -> 5 bits = 0
		// ore robots -> 0 ... 512 -> 9 bits = 5
		// clay robots -> 0 ... 512 -> 9 bits = 14
		// obsidian robots -> 0 ... 63 -> 6 bits = 23
		// geode robots -> 0 ... 31 -> 5 bits = 29
		// inventory ore -> 0 ... 255-> 8 bits = 34
		// inventory clay -> 0 ... 255 -> 8 bits = 42
		// inventory obsidian -> 0 ... 255 -> 8 bits = 50
		// inventory geode -> 0 ... 63 -> 6 bits = 56 -> 62

		let cacheKey = timeRemaining
			| (robots.ore << 5)
			| (robots.clay << 14)
			| (robots.obsidian << 23)
			| (robots.geode << 29)
			| (inventory.ore << 34)
			| (inventory.clay << 42)
			| (inventory.obsidian << 50)
			| (inventory.geode << 56)

		if let value = memoization[cacheKey] {
			return value
		}

		if (robots.geode + 1) < maxGeodesPerMinute[timeRemaining, default: 0] {
			memoization[cacheKey] = 0

			return 0
		}

		maxGeodesPerMinute[timeRemaining] = max(maxGeodesPerMinute[timeRemaining, default: 0], robots.geode)

		// 1. spend
		// 2. collect
		// 3. robot is ready

		var newInventory = inventory

		newInventory.ore += robots.ore
		newInventory.clay += robots.clay
		newInventory.obsidian += robots.obsidian
		newInventory.geode += robots.geode

		let robotPriorityPermutations: [[Robot]]

		let canMakeGeode = (inventory.ore >= blueprint.geodeRobotOreCost && inventory.obsidian >= blueprint.geodeRobotObsidianCost)
		let canMakeObsidian = (inventory.ore >= blueprint.obsidianRobotOreCost && inventory.clay >= blueprint.obsidianRobotClayCost)
		let canMakeClay = inventory.ore >= blueprint.clayRobotOreCost
		let canMakeOre = inventory.ore >= blueprint.oreRobotOreCost

		let canAlwaysMakeGeode = (robots.ore >= blueprint.geodeRobotOreCost && robots.obsidian >= blueprint.geodeRobotObsidianCost)
		let canAlwaysMakeObsidian = (robots.ore >= blueprint.obsidianRobotOreCost && robots.clay >= blueprint.obsidianRobotClayCost)

		if canAlwaysMakeGeode || canMakeGeode {
			// in case we get enough resources per turn to build a geode robot we can skip all other permutations
			robotPriorityPermutations = [[.geode]]
		} else if timeRemaining < 5 {
			if canMakeObsidian {
				robotPriorityPermutations = [[.obsidian]]
			} else {
				robotPriorityPermutations = []
			}
		} else {
			robotPriorityPermutations = [
				[.obsidian, .clay, .ore],
				[.obsidian, .ore, .clay],
				[.clay, .obsidian, .ore],
				[.clay, .ore, .obsidian],
				[.ore, .obsidian, .clay],
				[.ore, .clay, .obsidian],
			]
		}

		var maxScore = 0
		for robotPriority in robotPriorityPermutations {
			robotLoop: for robot in robotPriority {
				switch robot {
				case .geode:
					if canMakeGeode {
						var adjustedInventory = newInventory
						var adjustedRobots = robots

						adjustedInventory.ore -= blueprint.geodeRobotOreCost
						adjustedInventory.obsidian -= blueprint.geodeRobotObsidianCost

						adjustedRobots.geode += 1

						maxScore = max(
							maxScore,
							bestScore(blueprint: blueprint, timeRemaining: timeRemaining - 1, robots: adjustedRobots, inventory: adjustedInventory)
						)

						break robotLoop
					}
				case .obsidian:
					if canMakeObsidian {
						var adjustedInventory = newInventory
						var adjustedRobots = robots

						adjustedInventory.ore -= blueprint.obsidianRobotOreCost
						adjustedInventory.clay -= blueprint.obsidianRobotClayCost

						adjustedRobots.obsidian += 1

						maxScore = max(
							maxScore,
							bestScore(blueprint: blueprint, timeRemaining: timeRemaining - 1, robots: adjustedRobots, inventory: adjustedInventory)
						)

						break robotLoop
					}
				case .clay:
					if canMakeClay {
						var adjustedInventory = newInventory
						var adjustedRobots = robots

						adjustedInventory.ore -= blueprint.clayRobotOreCost

						adjustedRobots.clay += 1

						maxScore = max(
							maxScore,
							bestScore(blueprint: blueprint, timeRemaining: timeRemaining - 1, robots: adjustedRobots, inventory: adjustedInventory)
						)

						break robotLoop
					}
				case .ore:
					if canMakeOre {
						var adjustedInventory = newInventory
						var adjustedRobots = robots

						adjustedInventory.ore -= blueprint.oreRobotOreCost

						adjustedRobots.ore += 1

						maxScore = max(
							maxScore,
							bestScore(blueprint: blueprint, timeRemaining: timeRemaining - 1, robots: adjustedRobots, inventory: adjustedInventory)
						)

						break robotLoop
					}
				}
			}
		}

		//		 do not do an empty run if we generate enough resources already to always buy a geode or obsidian
		if !canAlwaysMakeGeode, !canAlwaysMakeObsidian {
			maxScore = max(
				maxScore,
				bestScore(blueprint: blueprint, timeRemaining: timeRemaining - 1, robots: robots, inventory: newInventory)
			)
		}

		memoization[cacheKey] = maxScore

		return maxScore
	}

	func solvePart1(withInput input: Input) -> Int {
		var sumOfQualityLevels = 0

		var maxMemoizationSize = 0

		memoization.reserveCapacity(50_000_000)

		for blueprint in input.blueprints {
			if logEnabled {
				print("Solving \(blueprint.id)")
			}

			memoization.removeAll(keepingCapacity: true)
			maxGeodesPerMinute = [:]

			let score = bestScore(blueprint: blueprint, timeRemaining: 23, robots: .init(ore: 1), inventory: .zero)

			if logEnabled {
				print(" score = \(score)")
			}

			sumOfQualityLevels += score * blueprint.id

			maxMemoizationSize = max(maxMemoizationSize, memoization.count)
		}

		if logEnabled {
			print(maxMemoizationSize)
		}

		return sumOfQualityLevels
	}

	func solvePart2(withInput input: Input) -> Int {
		var product = 1

		var maxMemoizationSize = 0

		memoization.reserveCapacity(150_000_000)

		for blueprint in input.blueprints.prefix(3) {
			if logEnabled {
				print("Solving \(blueprint.id)")
			}

			memoization.removeAll(keepingCapacity: true)
			maxGeodesPerMinute = [:]

			let score = bestScore(blueprint: blueprint, timeRemaining: 31, robots: .init(ore: 1), inventory: .zero)

			if logEnabled {
				print(" score = \(score)")
			}

			maxMemoizationSize = max(maxMemoizationSize, memoization.count)

			product *= score
		}

		if logEnabled {
			print(maxMemoizationSize)
		}

		return product
	}

	func parseInput(rawString: String) -> Input {
		.init(blueprints: rawString.allLines().map { line in
			let values = line.getCapturedValues(pattern: #"Blueprint ([0-9]*): Each ore robot costs ([0-9]*) ore. Each clay robot costs ([0-9]*) ore. Each obsidian robot costs ([0-9]*) ore and ([0-9]*) clay. Each geode robot costs ([0-9]*) ore and ([0-9]*) obsidian."#)!

			return Blueprint(
				id: Int(values[0])!,
				oreRobotOreCost: Int(values[1])!,
				clayRobotOreCost: Int(values[2])!,
				obsidianRobotOreCost: Int(values[3])!,
				obsidianRobotClayCost: Int(values[4])!,
				geodeRobotOreCost: Int(values[5])!,
				geodeRobotObsidianCost: Int(values[6])!
			)
		})
	}
}
