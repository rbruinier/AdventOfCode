import Foundation

public func parseInput() -> Input {
    let rawData = try! String(contentsOfFile: Bundle.main.path(forResource: "input", ofType: "txt")!)

    let height = rawData.filter { $0.isNewline }.count

    print(height)
    
    let heights: [Int] = rawData
        .compactMap { Int(String($0)) }

    let width = heights.count / height

    return .init(heightMap: heights, width: width, height: height)
}
