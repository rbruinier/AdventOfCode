import Foundation

public func parseInput() -> Input {
    let rawData = try! String(contentsOfFile: Bundle.main.path(forResource: "input", ofType: "txt")!)

    let height = rawData.filter { $0.isNewline }.count

    let riskLevels: [Int] = rawData
        .compactMap { Int(String($0)) }

    var completeRiskLevels: [Int] = Array(repeating: 0, count: riskLevels.count * 25)

    let width = riskLevels.count / height

    let fullHeight = height * 5
    let fullWidth = width * 5

    for y in 0 ..< height {
        for x in 0 ..< width {
            let originalRiskLevel = riskLevels[y * width + x]

            for repeatingY in 0 ..< 5 {
                let actualY = y + (repeatingY * height)

                for repeatingX in 0 ..< 5 {
                    let actualX = x + (repeatingX * width)

                    let newRisk = (((originalRiskLevel + repeatingY + repeatingX) - 1) % 9) + 1

                    completeRiskLevels[actualY * fullWidth + actualX] = newRisk
                }
            }
        }
    }

    return .init(riskLevels: completeRiskLevels, width: fullWidth, height: fullHeight)
}
