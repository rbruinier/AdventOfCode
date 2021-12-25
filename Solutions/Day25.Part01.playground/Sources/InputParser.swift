import Foundation

public func parseInput() -> Input {
    let rawData = try! String(contentsOfFile: Bundle.main.path(forResource: "input", ofType: "txt")!)

    let rawLines = rawData
        .components(separatedBy: CharacterSet.newlines)
        .filter { $0.isEmpty == false }

    var cells: [Cell] = []

    for rawLine in rawLines {
        cells.append(contentsOf: rawLine.map {
            switch $0 {
            case ".": return .empty
            case ">": return .eastbound
            case "v": return .southbound
            default: fatalError()
            }
        })
    }

    let width = cells.count / rawLines.count
    let height = rawLines.count

    return .init(cells: cells, width: width, height: height)
}
