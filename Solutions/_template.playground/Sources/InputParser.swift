import Foundation

public func parseInput() -> Input {
    let rawData = try! String(contentsOfFile: Bundle.main.path(forResource: "input", ofType: "txt")!)

//    let rawNumbers = rawData
//        .components(separatedBy: CharacterSet.whitespacesAndNewlines)
//        .compactMap { Int($0) }

    return .init()
}