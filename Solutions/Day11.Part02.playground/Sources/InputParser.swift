import Foundation

public func parseInput() -> Input {
    let rawData = try! String(contentsOfFile: Bundle.main.path(forResource: "input", ofType: "txt")!)

    let height = rawData.filter { $0.isNewline }.count

    print(height)
    
    let octopi: [Octopus] = rawData
        .compactMap { Int(String($0)) }
        .map(Octopus.init(energyLevel:))

    let width = octopi.count / height

    return .init(octopi: octopi, width: width, height: height)
}
