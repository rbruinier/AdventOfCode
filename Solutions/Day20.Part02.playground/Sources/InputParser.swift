import Foundation

public func parseInput() -> Input {
    let rawData = try! String(contentsOfFile: Bundle.main.path(forResource: "input", ofType: "txt")!)

    var rawLines = rawData
        .components(separatedBy: CharacterSet.newlines)
        .filter { $0.isEmpty == false }

    let enhancementMapping: [Int] = rawLines.first!.compactMap { $0 == "#" ? 1 : 0 }

    rawLines.removeFirst()

    let pixels: [Int] = rawLines.joined().compactMap { $0 == "#" ? 1 : ($0 == "." ? 0 : nil) }

    let height = rawLines.count
    let width = pixels.count / height

    assert(enhancementMapping.count == 512)
    assert(width == height)

    return .init(enhancementMapping: enhancementMapping, bitmap: .init(pixels: pixels, width: width, height: height))
}
