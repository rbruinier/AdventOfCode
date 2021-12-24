import Foundation

public func parseInput() -> Input {
    return .init(rooms: [
        .init(amphipod: .amber, cells: [.amber, .desert, .desert, .desert]),
        .init(amphipod: .bronze, cells: [.copper, .copper, .bronze, .desert]),
        .init(amphipod: .copper, cells: [.bronze, .bronze, .amber, .bronze]),
        .init(amphipod: .desert, cells: [.amber, .amber, .copper, .copper]),
    ])
}
