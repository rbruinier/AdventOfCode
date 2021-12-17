import Foundation

public func parseInput() -> Input {
    let rawData = try! String(contentsOfFile: Bundle.main.path(forResource: "input", ofType: "txt")!)

    let height = rawData.filter { $0.isNewline }.count

    print(height)

    let riskLevels: [Int] = rawData
        .compactMap { Int(String($0)) }

    let width = riskLevels.count / height

    return .init(riskLevels: riskLevels, width: width, height: height)
}
