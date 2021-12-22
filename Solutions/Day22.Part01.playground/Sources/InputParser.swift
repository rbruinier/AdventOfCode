import Foundation

public func parseInput() -> Input {
    let rawData = try! String(contentsOfFile: Bundle.main.path(forResource: "input", ofType: "txt")!)

    let rawLines = rawData
        .components(separatedBy: CharacterSet.newlines)
        .filter { $0.isEmpty == false }

    let steps: [Step] = rawLines.map {
        var minPoint = Point(x: Int.max, y: Int.max, z: Int.max)
        var maxPoint = Point(x: Int.min, y: Int.min, z: Int.min)

        let components = $0.components(separatedBy: " ")

        components[1]
            .components(separatedBy: ",")
            .forEach {
                let operands = $0.components(separatedBy: "=")
                let range = operands[1].components(separatedBy: "..")

                switch operands[0] {
                case "x":
                    minPoint.x = min(minPoint.x, Int(range[0])!)
                    maxPoint.x = max(maxPoint.x, Int(range[1])!)
                case "y":
                    minPoint.y = min(minPoint.y, Int(range[0])!)
                    maxPoint.y = max(maxPoint.y, Int(range[1])!)
                case "z":
                    minPoint.z = min(minPoint.z, Int(range[0])!)
                    maxPoint.z = max(maxPoint.z, Int(range[1])!)
                default:
                    fatalError()
                }
            }

        if components[0] == "on" {
            return .init(box: .init(minPoint: minPoint, maxPoint: maxPoint, sign: 1), isOn: true)
        } else {
            return .init(box: .init(minPoint: minPoint, maxPoint: maxPoint, sign: -1), isOn: false)
        }
    }

    return .init(steps: steps)
}
