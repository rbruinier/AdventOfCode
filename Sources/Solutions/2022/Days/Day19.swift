import Foundation
import Tools

final class Day19Solver: DaySolver {
    let dayNumber: Int = 19

    private var input: Input!

    private struct Input {
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

    private struct Blueprint {
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

        //		if robots.geode < maxGeodeRobotsPerMinute[timeRemaining, default: 0] {
        //			memoization[cacheKey] = 0
//
        //			return 0
        //		}
//
        //		maxGeodeRobotsPerMinute[timeRemaining] = robots.geode

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
            var possibleRobots: [Robot] = Array()

            possibleRobots.reserveCapacity(4)

            if canMakeObsidian {
                possibleRobots.append(.obsidian)
            }

            robotPriorityPermutations = possibleRobots.permutations
        } else {
            var possibleRobots: [Robot] = Array()

            possibleRobots.reserveCapacity(4)

            if canMakeObsidian {
                possibleRobots.append(.obsidian)
            }

            if canMakeOre {
                possibleRobots.append(.ore)
            }

            if canMakeClay {
                possibleRobots.append(.clay)
            }

            robotPriorityPermutations = possibleRobots.permutations
        }

        var maxScore = 0
        for robotPriority in robotPriorityPermutations {
            robotLoop: for robot in robotPriority {
                switch robot {
                case .geode:
                    if inventory.obsidian >= blueprint.geodeRobotObsidianCost, inventory.ore >= blueprint.geodeRobotOreCost {
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
                    if inventory.clay >= blueprint.obsidianRobotClayCost, inventory.ore >= blueprint.obsidianRobotOreCost {
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
                    if inventory.ore >= blueprint.clayRobotOreCost {
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
                    if inventory.ore >= blueprint.oreRobotOreCost {
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

        //		if robotWasBuilt == false {
        //		if timeRemainin

        //		 do not do an empty run if we generate enough resources already to always buy a robot
        if canAlwaysMakeGeode || canAlwaysMakeObsidian // || canMakeOre || canAlwaysMakeObsidian || canAlwaysMakeClay
        {
        } else {
            maxScore = max(
                maxScore,
                bestScore(blueprint: blueprint, timeRemaining: timeRemaining - 1, robots: robots, inventory: newInventory)
            )
        }

        memoization[cacheKey] = maxScore

        return maxScore
    }

    func solvePart1() -> Any {
        var sumOfQualityLevels = 0

        for blueprint in input.blueprints {
            if logEnabled {
                print("Solving \(blueprint.id)")
            }

            memoization = [:]
            maxGeodesPerMinute = [:]

            let score = bestScore(blueprint: blueprint, timeRemaining: 23, robots: .init(ore: 1), inventory: .zero)

            if logEnabled {
                print(" score = \(score)")
            }

            sumOfQualityLevels += score * blueprint.id
        }

        return sumOfQualityLevels
    }

    func solvePart2() -> Any {
        var product = 1

        for blueprint in input.blueprints.prefix(3) {
            if logEnabled {
                print("Solving \(blueprint.id)")
            }

            memoization = [:]
            maxGeodesPerMinute = [:]

            let score = bestScore(blueprint: blueprint, timeRemaining: 31, robots: .init(ore: 1), inventory: .zero)

            if logEnabled {
                print(" score = \(score)")
            }

            product *= score
        }

        return product
    }

    func parseInput(rawString: String) {
        input = .init(blueprints: rawString.allLines().map { line in
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
