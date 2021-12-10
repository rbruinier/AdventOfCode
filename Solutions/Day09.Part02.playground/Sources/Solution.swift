import Foundation

public struct Input {
    let heightMap: [Int]

    let width: Int
    let height: Int
}

//Flood-fill (node):
//  1. Set Q to the empty queue or stack.
//  2. Add node to the end of Q.
//  3. While Q is not empty:
//  4.   Set n equal to the first element of Q.
//  5.   Remove first element from Q.
//  6.   If n is Inside:
//         Set the n
//         Add the node to the west of n to the end of Q.
//         Add the node to the east of n to the end of Q.
//         Add the node to the north of n to the end of Q.
//         Add the node to the south of n to the end of Q.
//  7. Continue looping until Q is exhausted.
//  8. Return.

struct Coordinate: Equatable, Hashable {
    let x: Int
    let y: Int
}

// basic flood fill: https://en.wikipedia.org/wiki/Flood_fill#Moving_the_recursion_into_a_data_structure
func floodFill(input: Input, coordinate: Coordinate) -> [Coordinate] {
    var handled: Set<Coordinate> = Set()

    var q: [Coordinate] = [coordinate]

    var fields: Set<Coordinate> = Set()

    print("Floodfill: \(coordinate)")

    while q.isEmpty == false {
        let n = q.removeFirst()

        handled.insert(n)

        guard input.heightMap[(n.y * input.width) + n.x] < 9 else {
            continue
        }

        fields.insert(n)

        if n.x > 0 { // west
            let west = Coordinate(x: n.x - 1, y: n.y)

            if handled.contains(west) == false {
                q.append(west)
            }
        }

        if n.x < (input.width - 1) { // east
            let east = Coordinate(x: n.x + 1, y: n.y)

            if handled.contains(east) == false {
                q.append(east)
            }
        }

        if n.y > 0 { // north
            let north = Coordinate(x: n.x, y: n.y - 1)

            if handled.contains(north) == false {
                q.append(north)
            }
        }

        if n.y < (input.height - 1) { // south
            let south = Coordinate(x: n.x, y: n.y + 1)

            if handled.contains(south) == false {
                q.append(south)
            }
        }
    }

    return Array(fields)
}

public func solutionFor(input: Input) -> Int {
    print(input)

    let heightMap = input.heightMap

    var lowPoints: [Coordinate] = []

    for y in 0 ..< input.height {
        var index = y * input.width

        for x in 0 ..< input.width {
            let height = heightMap[index]

            if ((x == 0) || (heightMap[index - 1] > height))
                && ((x == (input.width - 1)) || (heightMap[index + 1] > height))
                && ((y == 0) || (heightMap[index - input.width] > height))
                && ((y == (input.height - 1)) || (heightMap[index + input.width] > height)) {

                lowPoints.append(Coordinate(x: x, y: y))
            }

            index += 1
        }
    }

//    print(lowPoints)

    var allBasinSizes: [Int] = []

    for lowPoint in lowPoints {
        let fields = floodFill(input: input, coordinate: lowPoint)

        let heights = fields.map { input.heightMap[$0.y * input.width + $0.x] }

        allBasinSizes.append(heights.count)
    }

    allBasinSizes.sort(by: { $0 > $1 })



//    let sumOfRiskLevel = lowPoints.reduce(0) { result, height in result + height + 1 }

    return allBasinSizes[0] * allBasinSizes[1] * allBasinSizes[2]
}
