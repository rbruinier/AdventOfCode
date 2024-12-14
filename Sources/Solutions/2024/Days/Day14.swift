import Foundation
import Tools

final class Day14Solver: DaySolver {
	let dayNumber: Int = 14

	struct Robot {
		var position: Point2D
		let velocity: Point2D
	}

	struct Input {
		let robots: [Robot]
	}

	private func moveRobots(_ robots: inout [Robot], size: Size) {
		for i in 0 ..< robots.count {
			var robot = robots[i]

			robot.position.x = mod(robot.position.x + robot.velocity.x, size.width)
			robot.position.y = mod(robot.position.y + robot.velocity.y, size.height)

			robots[i] = robot
		}
	}

	func solvePart1(withInput input: Input) -> Int {
		let size = Size(width: 101, height: 103)

		var robots = input.robots

		for _ in 0 ..< 100 {
			moveRobots(&robots, size: size)
		}

		let quadrantWidth = size.width / 2
		let quadrantHeight = size.height / 2

		let leftQuadrantX = (0 ..< quadrantWidth)
		let rightQuadrantX = (size.width - quadrantWidth ..< size.width)

		let topQuadrantY = (0 ..< quadrantHeight)
		let bottomQuadrantY = (size.height - quadrantHeight ..< size.height)

		let quadrants: [(x: Range<Int>, y: Range<Int>)] = [
			(x: leftQuadrantX, y: topQuadrantY),
			(x: rightQuadrantX, y: topQuadrantY),
			(x: leftQuadrantX, y: bottomQuadrantY),
			(x: rightQuadrantX, y: bottomQuadrantY),
		]

		var result = 1
		for quadrant in quadrants {
			let count = robots.count { quadrant.x.contains($0.position.x) && quadrant.y.contains($0.position.y) }

			result *= count
		}

		return result
	}

	private func printRobots(_ robots: [Robot], size: Size) {
		for y in 0 ..< size.height {
			var line = ""

			for x in 0 ..< size.width {
				let isRobot = robots.contains(where: { $0.position.x == x && $0.position.y == y })

				line += isRobot ? "*" : "."
			}

			print(line)
		}
	}

	func solvePart2(withInput input: Input) -> Int {
		let size = Size(width: 101, height: 103)

		var robots = input.robots

		for second in 0 ..< 10000 {
			let robotPositions: Set<Point2D> = Set(robots.map(\.position))

			robotLoop: for robot in robots {
				var nextPosition = robot.position

				// find a line of 10 robots in place
				for _ in 0 ..< 10 {
					nextPosition.move(to: .east)

					let isRobot = robotPositions.contains(nextPosition)

					if !isRobot {
						continue robotLoop
					}
				}

//				printRobots(robots, size: size)

				return second
			}

			moveRobots(&robots, size: size)
		}

		preconditionFailure()
	}

	func parseInput(rawString: String) -> Input {
		var robots: [Robot] = []

		for line in rawString.allLines() {
			// p=0,4 v=3,-3

			let components = line.split(separator: " ")

			let position = components[0].split(separator: "=")[1].split(separator: ",").map { Int($0)! }
			let velocity = components[1].split(separator: "=")[1].split(separator: ",").map { Int($0)! }

			robots.append(.init(position: .init(x: position[0], y: position[1]), velocity: .init(x: velocity[0], y: velocity[1])))
		}

		return .init(robots: robots)
	}
}
