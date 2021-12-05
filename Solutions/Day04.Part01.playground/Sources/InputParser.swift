import Foundation

public func parseInput() -> Input {
    let rawData = try! String(contentsOfFile: Bundle.main.path(forResource: "input", ofType: "txt")!)

    let index = rawData.firstIndex(of: "\n")!

    let drawnNumbers = String(rawData[rawData.startIndex ..< index])
        .components(separatedBy: ",")
        .compactMap { Int($0) }

    let rawBoardNumbers = String(rawData[index ..< rawData.endIndex])
        .components(separatedBy: CharacterSet.whitespacesAndNewlines)
        .compactMap { Int($0) }

    var boards: [Board] = []

    for startIndex in stride(from: 0, to: rawBoardNumbers.count, by: 25) {
        let board: Board = .init(numbers: Array(rawBoardNumbers[startIndex ..< (startIndex + 25)]))

        boards.append(board)
    }

    return .init(drawnNumbers: drawnNumbers, boards: boards)
}
