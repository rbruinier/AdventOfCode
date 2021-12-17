import Foundation

public func parseInput() -> Input {
    let rawData = try! String(contentsOfFile: Bundle.main.path(forResource: "input", ofType: "txt")!)

    var coordinates: [Coordinate] = []
    var folds: [Fold] = []

    rawData
        .components(separatedBy: CharacterSet.newlines)
        .forEach { rawLine in
            if rawLine.contains(",") {
                let components = rawLine.components(separatedBy: ",")

                let x = Int(components[0])!
                let y = Int(components[1])!

                coordinates.append(.init(x: x, y: y))
            } else if rawLine.contains("fold along y") {
                let components = rawLine.components(separatedBy: "=")

                let y = Int(components[1])!

                folds.append(.horizontal(y: y))
            } else if rawLine.contains("fold along x") {
                let components = rawLine.components(separatedBy: "=")

                let x = Int(components[1])!

                folds.append(.vertical(x: x))
            }
        }

    let width = coordinates.map(\.x).max()! + 1
    let height = coordinates.map(\.y).max()! + 1

    return .init(coordinates: coordinates, folds: folds, width: width, height: height)
}
