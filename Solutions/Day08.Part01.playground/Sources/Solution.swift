import Foundation

public struct Input {
    let entries: [Entry]
}

enum Segment: String {
    case a, b, c, d, e, f, g
}

struct Digit {
    let segments: Set<Segment>
}

struct Entry {
    let uniqueDigits: [Digit]
    let outputDigits: [Digit]
}

let digits: [Digit] = [
    .init(segments: Set([.a, .b, .c, .e, .f, .g])), // 0 -> 6 segments
    .init(segments: Set([.c, .f])), // 1 -> 2 segments (UNIQUE)
    .init(segments: Set([.a, .c, .d, .e, .g])), // 2 -> 5 segments
    .init(segments: Set([.a, .c, .d, .f, .g])), // 3 -> 5 segments
    .init(segments: Set([.b, .c, .d, .f])), // 4 -> 4 segments (UNIQUE)
    .init(segments: Set([.a, .b, .d, .f, .g])), // 5 -> 5 segments
    .init(segments: Set([.a, .b, .d, .e, .f, .g])), // 6 -> 6 segments
    .init(segments: Set([.a, .c, .f])), // 7 -> 3 segments (UNIQUE)
    .init(segments: Set([.a, .b, .c, .d, .e, .f, .g])), // 8 -> 7 segments (UNIQUE)
    .init(segments: Set([.a, .b, .c, .d, .f, .g])), // 9 -> 6 segments
]

public func solutionFor(input: Input) -> Int {
    let occurencesOfOne = input.entries.reduce(0) { result, entry in
        result + entry.outputDigits.filter { $0.segments.count == 2 }.count
    }

    let occurencesOfFour = input.entries.reduce(0) { result, entry in
        result + entry.outputDigits.filter { $0.segments.count == 4 }.count
    }

    let occurencesOfSeven = input.entries.reduce(0) { result, entry in
        result + entry.outputDigits.filter { $0.segments.count == 3 }.count
    }

    let occurencesOfEight = input.entries.reduce(0) { result, entry in
        result + entry.outputDigits.filter { $0.segments.count == 7 }.count
    }

    return occurencesOfOne + occurencesOfFour + occurencesOfSeven + occurencesOfEight
}
