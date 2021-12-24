import Foundation

public func parseInput() -> Input {
    return .init(rooms: [
        .init(amphipod: .amber, cells: [.amber, .desert]),
        .init(amphipod: .bronze, cells: [.copper, .desert]),
        .init(amphipod: .copper, cells: [.bronze, .bronze]),
        .init(amphipod: .desert, cells: [.amber, .copper]),
    ])
}
