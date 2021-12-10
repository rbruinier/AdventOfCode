import Foundation

public struct Input {
    let heightMap: [Int]

    let width: Int
    let height: Int
}

public func solutionFor(input: Input) -> Int {
    print(input)

    let heightMap = input.heightMap

    var lowPoints: [Int] = []

    for y in 0 ..< input.height {
        var index = y * input.width

        for x in 0 ..< input.width {
            let height = heightMap[index]

            if ((x == 0) || (heightMap[index - 1] > height))
                && ((x == (input.width - 1)) || (heightMap[index + 1] > height))
                && ((y == 0) || (heightMap[index - input.width] > height))
                && ((y == (input.height - 1)) || (heightMap[index + input.width] > height)) {
                lowPoints.append(height)
            }

            index += 1
        }
    }

    print(lowPoints)

    let sumOfRiskLevel = lowPoints.reduce(0) { result, height in result + height + 1 }

    return sumOfRiskLevel
}
