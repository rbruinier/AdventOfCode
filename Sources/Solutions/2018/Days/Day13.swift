import Foundation
import Tools

final class Day13Solver: DaySolver {
	let dayNumber: Int = 13

	struct Input {
		let track: [Point2D: Segment]
		let robots: [Point2D: Robot]
	}

	enum CornerDirection {
		case left
		case right
	}

	enum Segment {
		case horizontal
		case vertical
		case corner(direction: CornerDirection)
		case intersection
	}

	struct Robot {
		let direction: Direction
		let nextTurn: Point2D.Degrees
	}

	private enum MoveResult {
		case ok(robots: [Point2D: Robot])
		case crashes(positions: Set<Point2D>, robots: [Point2D: Robot])
	}

	private func moveRobots(_ robots: [Point2D: Robot], track: [Point2D: Segment]) -> MoveResult {
		var robots = robots

		var newRobots: [Point2D: Robot] = [:]
		var crashPositions: Set<Point2D> = []

		let sortedRobotPositions = robots.keys.sorted(by: { lhs, rhs in
			if lhs.y < rhs.y {
				true
			} else if lhs.y > rhs.y {
				false
			} else {
				lhs.x < rhs.x
			}
		})

		for currentPosition in sortedRobotPositions {
			guard let robot = robots[currentPosition] else {
				continue
			}

			var newDirection: Direction = robot.direction
			var newNextTurn: Point2D.Degrees = robot.nextTurn

			switch track[currentPosition] {
			case nil: fatalError()
			case .vertical:
				switch robot.direction {
				case .north,
				     .south:
					break
				default: fatalError()
				}
			case .horizontal:
				switch robot.direction {
				case .west,
				     .east:
					break
				default: fatalError()
				}
			case .corner(let direction):
				switch robot.direction {
				case .west:
					switch direction {
					case .left:
						newDirection = .north
					case .right:
						newDirection = .south
					}
				case .east:
					switch direction {
					case .left:
						newDirection = .south
					case .right:
						newDirection = .north
					}
				case .north:
					switch direction {
					case .left:
						newDirection = .west
					case .right:
						newDirection = .east
					}
				case .south:
					switch direction {
					case .left:
						newDirection = .east
					case .right:
						newDirection = .west
					}

				default: fatalError()
				}
			case .intersection:
				newDirection = robot.direction.turned(degrees: robot.nextTurn)

				switch robot.nextTurn {
				case .twoSeventy:
					newNextTurn = .zero
				case .zero:
					newNextTurn = .ninety
				case .ninety:
					newNextTurn = .twoSeventy
				default: fatalError()
				}
			}

			let newPosition = currentPosition.moved(to: newDirection)

			if newRobots[newPosition] != nil || robots[newPosition] != nil {
				crashPositions.insert(newPosition)

				newRobots[newPosition] = nil // remove the "two" carts from the new robots
				robots[newPosition] = nil
			} else {
				newRobots[newPosition] = .init(direction: newDirection, nextTurn: newNextTurn)
			}

			// make sure we don't collision with old positions of this robot
			robots[currentPosition] = nil
		}

		if crashPositions.isEmpty {
			return .ok(robots: newRobots)
		} else {
			return .crashes(positions: crashPositions, robots: newRobots)
		}
	}

	private func printState(robots: [Point2D: Robot], track: [Point2D: Segment]) {
		let minY = track.keys.map(\.y).min()!
		let maxY = track.keys.map(\.y).max()!

		let minX = track.keys.map(\.x).min()!
		let maxX = track.keys.map(\.x).max()!

		for y in minY ... maxY {
			var line = ""

			for x in minX ... maxX {
				let point = Point2D(x: x, y: y)

				if let robot = robots[point] {
					switch robot.direction {
					case .north: line += "^"
					case .east: line += ">"
					case .south: line += "v"
					case .west: line += "<"
					default: fatalError()
					}
				} else {
					switch track[point] {
					case nil: line += " "
					case .intersection: line += "+"
					case .horizontal: line += "-"
					case .vertical: line += "|"
					case .corner(let direction):
						switch direction {
						case .left: line += "\\"
						case .right: line += "/"
						}
					}
				}
			}

			print(line)
		}
	}

	func solvePart1(withInput input: Input) -> String {
		var robots = input.robots

		while true {
			let result = moveRobots(robots, track: input.track)

			switch result {
			case .ok(let newRobots):
				robots = newRobots
			case .crashes(let positions, _):
				let position = positions.first!

				return "\(position.x),\(position.y)"
			}
		}
	}

	func solvePart2(withInput input: Input) -> String {
		var robots = input.robots

		while true {
			let result = moveRobots(robots, track: input.track)

			switch result {
			case .ok(let newRobots):
				robots = newRobots
			case .crashes(_, let newRobots):
				robots = newRobots

				if robots.isEmpty {
					fatalError()
				} else if robots.count == 1 {
					let position = robots.keys.first!

					return "\(position.x),\(position.y)"
				}
			}
		}
	}

	func parseInput(rawString: String) -> Input {
		var track: [Point2D: Segment] = [:]
		var robots: [Point2D: Robot] = [:]

		for (y, line) in rawString.allLines().enumerated() {
			for (x, char) in line.enumerated() {
				let point = Point2D(x: x, y: y)

				switch char {
				case "-": track[point] = .horizontal
				case "|": track[point] = .vertical
				case "\\": track[point] = .corner(direction: .left)
				case "/": track[point] = .corner(direction: .right)
				case "+": track[point] = .intersection
				case ">":
					track[point] = .horizontal
					robots[point] = .init(direction: .east, nextTurn: .twoSeventy)
				case "<":
					track[point] = .horizontal
					robots[point] = .init(direction: .west, nextTurn: .twoSeventy)
				case "^":
					track[point] = .vertical
					robots[point] = .init(direction: .north, nextTurn: .twoSeventy)
				case "v":
					track[point] = .vertical
					robots[point] = .init(direction: .south, nextTurn: .twoSeventy)
				case " ":
					break
				default: fatalError()
				}
			}
		}

		return .init(track: track, robots: robots)
	}
}
