# Dijkstra Algorithm Documentation

The Dijkstra algorithm presented here is a fundamental example of its application.

## Priority Queue

This implementation utilizes a priority queue from the Tools package. The queue is generic, accommodating different node types.

## Handling Visited States

We need to store weights for visited "states". In general a visited state is a point/node in a grid or graph but if
there are additional rules that decide on future path options it is required to include those in the state. For example if
we have a 2d grid and the path has the rules that a certain direction can be taken only a certain amount of times in a row
we need to encode this into the state:

```
private struct UniqueState: Hashable {
	let point: Point2D
	let direction: Direction
	let directionCount: Int
}
```

The hash value of this type acts as a lookup key for the weights of previously visited states.

## Queue Nodes

Queue nodes in this context include a weight value and implement the Comparable protocol. This enables the priority 
queue to appropriately order newly added nodes:


```
private struct QueueNode: Comparable {
	let point: Point2D
	let direction: Direction
	let directionCount: Int
	let weight: Int

	static func < (lhs: QueueNode, rhs: QueueNode) -> Bool {
		lhs.weight < rhs.weight
	}
}
```

## Example: Finding the Optimal Path in a Grid

In the following example, the goal is to navigate from the top left corner of a grid to the bottom right with the least total 
weight. Additionally, a rule is imposed: a direction can only be repeated a maximum of maxRepeating times in a row.

```
private func solve(withGrid grid: [[Int]], maxRepeating: Int) -> Int {
	let size = Size(width: grid[0].count, height: grid.count)

	let a = Point2D(x: 0, y: 0)
	let b = Point2D(x: size.width - 1, y: size.height - 1)

	var priorityQueue = PriorityQueue<QueueNode>(isAscending: true)

	var weights: [Int: Int] = [
		UniqueState(point: .zero, direction: .east, directionCount: 0).hashValue: 0,
	]

	priorityQueue.push(.init(point: a, direction: .east, directionCount: 0, weight: 0))

	while let solution = priorityQueue.pop() {
		if solution.point == b {
			return solution.weight
		}

		guard let currentWeight = weights[UniqueState(point: solution.point, direction: solution.direction, directionCount: solution.directionCount).hashValue] else {
			preconditionFailure()
		}

		let newDirections: [Direction]

		let lastDirection = solution.direction

		if solution.directionCount >= maxRepeating {
			newDirections = [
				lastDirection.left,
				lastDirection.right,
			]
		} else {
			newDirections = [
				lastDirection.left,
				lastDirection,
				lastDirection.right,
			]
		}

		for newDirection in newDirections {
			let newPoint = solution.point.moved(to: newDirection)

			guard (0 ..< size.width).contains(newPoint.x) && (0 ..< size.height).contains(newPoint.y) else {
				continue
			}

			let directionCount = (newDirection == solution.direction) ? (solution.directionCount + 1) : 1

			let stateHash = UniqueState(point: newPoint, direction: newDirection, directionCount: directionCount).hashValue

			let oldWeight = weights[stateHash]

			let combinedWeight = currentWeight + grid[newPoint.y][newPoint.x]

			if oldWeight == nil || combinedWeight < oldWeight! {
				weights[stateHash] = combinedWeight

				priorityQueue.push(
					QueueNode(
						point: newPoint,
						direction: newDirection,
						directionCount: directionCount,
						weight: combinedWeight
					)
				)
			}
		}
	}

	preconditionFailure()
}
```
