import Foundation

public func parseInput() -> Input {
    let rawData = try! String(contentsOfFile: Bundle.main.path(forResource: "input", ofType: "txt")!)

    var rawLines = rawData
        .components(separatedBy: CharacterSet.newlines)

    var scanners: [Scanner] = []

    while let line = rawLines.first {
        rawLines.removeFirst()

        guard line.isEmpty == false else {
            continue
        }

        let name = line
        var beacons: [Beacon] = []

        while let beaconLine = rawLines.first {
            rawLines.removeFirst()

            guard beaconLine.isEmpty == false else {
                break
            }

            let coordinates = beaconLine.components(separatedBy: ",").compactMap { Int($0) }

            beacons.append(.init(x: coordinates[0], y: coordinates[1], z: coordinates[2]))
        }

        scanners.append(.init(name: name, beacons: beacons))
    }

    return .init(scanners: scanners)
}
