import Foundation

public struct Input {
    let entries: [Entry]
}

enum Segment: String, CaseIterable, Equatable, CustomDebugStringConvertible {
    case a, b, c, d, e, f, g

    var debugDescription: String {
        return self.rawValue
    }
}

struct Digit: Equatable {
    let segments: Set<Segment>

    var nrOfSegments: Int {
        segments.count
    }

    static func == (lhs: Digit, rhs: Digit) -> Bool {
        return lhs.segments.isSubset(of: rhs.segments) && rhs.segments.isSubset(of: lhs.segments)
    }
}

struct Entry {
    let uniqueDigits: [Digit]
    let outputDigits: [Digit]
}

public func solutionFor(input: Input) -> Int {
    func segments(in a: Digit, butNotIn b: [Digit]) -> [Segment] {
        let bSegments: Set<Segment> = Set(b.flatMap { $0.segments })

        return a.segments.filter { bSegments.contains($0) == false }
    }

    func segments(in a: Digit, andIn b: [Digit]) -> [Segment] {
        let bSegments: Set<Segment> = Set(b.flatMap { $0.segments })

        return a.segments.filter { bSegments.contains($0) }
    }

    func findDigitWithSegments(_ segments: Set<Segment>, in digits: [Digit]) -> Digit? {
        digits.first {
            $0.segments.isSubset(of: segments) && segments.isSubset(of: $0.segments)
        }
    }

    var result: Int = 0

    for entry in input.entries {
        let mustBeOne = entry.uniqueDigits.first(where: { $0.nrOfSegments == 2 } )!
        let mustBeFour = entry.uniqueDigits.first(where: { $0.nrOfSegments == 4 } )!
        let mustBeSeven = entry.uniqueDigits.first(where: { $0.nrOfSegments == 3 } )!
        let mustBeEight = entry.uniqueDigits.first(where: { $0.nrOfSegments == 7 } )!

        let cAndFSegment = Array(mustBeOne.segments)
        let bAndDSegment = segments(in: mustBeFour, butNotIn: [mustBeOne])

        // 968175
        
        var zeroSegmentsA: Set<Segment> = Set(Segment.allCases)
        var zeroSegmentsB: Set<Segment> = Set(Segment.allCases)

        zeroSegmentsA.remove(bAndDSegment[0])
        zeroSegmentsB.remove(bAndDSegment[1])

        let mustBeZero: Digit
        let bSegment: Segment
        let dSegment: Segment

        if let digit = findDigitWithSegments(zeroSegmentsA, in: entry.uniqueDigits) {
            mustBeZero = digit
            dSegment = bAndDSegment[0]
            bSegment = bAndDSegment[1]
        } else if let digit = findDigitWithSegments(zeroSegmentsB, in: entry.uniqueDigits) {
            mustBeZero = digit
            bSegment = bAndDSegment[0]
            dSegment = bAndDSegment[1]
        } else {
            fatalError("Does not match")
        }

        let mustBeFive = entry.uniqueDigits.first {
            $0.nrOfSegments == 5 && $0.segments.contains(bSegment)
        }!

        let cSegment: Segment
        let fSegment: Segment

        if mustBeFive.segments.contains(cAndFSegment[0]) {
            fSegment = cAndFSegment[0]
            cSegment = cAndFSegment[1]
        } else {
            cSegment = cAndFSegment[0]
            fSegment = cAndFSegment[1]
        }

        let mustBeSix = entry.uniqueDigits.first {
            $0.nrOfSegments == 6 && $0.segments.contains(fSegment) && $0.segments.contains(cSegment) == false
        }!

        let mustBeNine = entry.uniqueDigits.first {
            $0.nrOfSegments == 6 && $0.segments.contains(cSegment) && $0.segments.contains(fSegment) && $0.segments.contains(dSegment)
        }!

        let mustBeTwo = entry.uniqueDigits.first {
            $0.nrOfSegments == 5 && $0.segments.contains(cSegment) && $0.segments.contains(fSegment) == false
        }!

        let mustBeThree = entry.uniqueDigits.first {
            $0.nrOfSegments == 5 && $0.segments.contains(cSegment) && $0.segments.contains(fSegment)
        }!

        let mappedDigits: [Digit] = [
            mustBeZero, mustBeOne, mustBeTwo, mustBeThree, mustBeFour, mustBeFive, mustBeSix, mustBeSeven, mustBeEight, mustBeNine
        ]

        let number = entry.outputDigits.reduce(0) { result, digit in
            (result * 10) + mappedDigits.firstIndex { $0 == digit }!
        }

        print(number)

        result += number
    }

    return result
}
