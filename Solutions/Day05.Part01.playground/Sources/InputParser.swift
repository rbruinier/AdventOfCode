import Foundation

public func parseInput() -> Input {
    let rawData = try! String(contentsOfFile: Bundle.main.path(forResource: "input", ofType: "txt")!)

    var largestX: Int = 0
    var largestY: Int = 0

    let lines: [Line] = rawData
        .components(separatedBy: CharacterSet.newlines)
        .compactMap { (line: String) -> Line? in
            guard line.isEmpty == false else {
                return nil
            }
            
            let coordinates = line
                .components(separatedBy: " -> ")
                .map { (rawCoordinate: String) -> (Int, Int) in
                    let numbers = rawCoordinate.components(separatedBy: ",")

                    return (Int(numbers[0])!, Int(numbers[1])!)
                }

            largestX = max(largestX, max(coordinates[0].0, coordinates[1].0))
            largestY = max(largestY, max(coordinates[0].1, coordinates[1].1))

            return Line(x1: coordinates[0].0, y1: coordinates[0].1, x2: coordinates[1].0, y2: coordinates[1].1)
        }

    return .init(lines: lines, gridWidth: largestX + 1, gridHeight: largestY + 1)
}
