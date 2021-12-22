import Foundation

public struct Input {
    let lines: [Line]
}

public struct Line: CustomStringConvertible {
    var segments: [Segment]

    public var description: String {
        segments.map { $0.description }.joined()
    }

    var nextExplodingPair: Block? {
        var nestingLevel = 0

        var index = 0
        for segment in segments {
            if segment == .openBracket {
                nestingLevel += 1

                if nestingLevel >= 5 {
                    return .init(startIndex: index, endIndex: index + 5, segments: Array(segments[index ..< index + 5]))
                }
            } else if segment == .closeBracket {
                nestingLevel -= 1
            }

            index += 1
        }

        return nil
    }

    mutating func resolveFirstSplit() -> Bool {
        guard
            let splitIndex = segments.firstIndex(where: {
                if case .number(let number) = $0, number >= 10 {
                    return true
                } else {
                    return false
                }
            }),
            case .number(let number) = segments[splitIndex]
        else {
            return false
        }

        segments.remove(at: splitIndex)

        segments.insert(.closeBracket, at: splitIndex)
        segments.insert(.number(number: (number >> 1) + ((number & 1 == 1) ? 1 : 0)), at: splitIndex)
        segments.insert(.comma, at: splitIndex)
        segments.insert(.number(number: number >> 1), at: splitIndex)
        segments.insert(.openBracket, at: splitIndex)

        return true
    }

    @discardableResult
    mutating func addNumber(_ number: Int, toLeftOf originalIndex: Int) -> Bool {
        var index = originalIndex - 1

        while index >= 0 {
            if case .number(let targetNumber) = segments[index] {
                segments[index] = .number(number: targetNumber + number)

                return true
            }

            index -= 1
        }

        return false
    }

    @discardableResult
    mutating func addNumber(_ number: Int, toRightOf originalIndex: Int) -> Bool {
        var index = originalIndex

        while index < segments.count {
            if case .number(let targetNumber) = segments[index] {
                segments[index] = .number(number: targetNumber + number)

                return true
            }

            index += 1
        }

        return false
    }

    mutating func replaceBlockWithZero(_ block: Block) {
        segments.removeSubrange(block.startIndex ..< block.endIndex)
        segments.insert(.number(number: 0), at: block.startIndex)
    }

    mutating func addLine(_ lineB: Line) {
        segments.insert(.openBracket, at: 0)
        segments.append(.comma)
        segments.append(contentsOf: lineB.segments)
        segments.append(.closeBracket)
    }
}

struct Block: CustomStringConvertible {
    let startIndex: Int
    let endIndex: Int
    let segments: [Segment]

    var leftNumber: Int {
        if case .number(let number) = segments[1] {
            return number
        } else {
            fatalError()
        }
    }

    var rightNumber: Int {
        if case .number(let number) = segments[3] {
            return number
        } else {
            fatalError()
        }
    }

    var description: String {
        let joinedSegments = segments.map { $0.description }.joined()

        return "Block\n range: \(startIndex) ..< \(endIndex)\n segments: \(joinedSegments)"
    }
}

public enum Segment: Equatable, CustomStringConvertible {
    case openBracket
    case closeBracket
    case comma
    case number(number: Int)

    public var description: String {
        switch self {
        case .openBracket:
            return "["
        case .closeBracket:
            return "]"
        case .comma:
            return ","
        case .number(let number):
            return String(number)
        }
    }
}

indirect enum Node {
    case number(number: Int)
    case pair(a: Node, b: Node)

    var magnitude: Int {
        switch self {
        case .number(let number):
            return number
        case .pair(let a, let b):
            return 3 * a.magnitude + 2 * b.magnitude
        }
    }

    init(segments: inout [Segment]) {
        var nextSegment = segments.removeFirst()

        nextSegment = segments.first!

        let subNodeA: Node

        switch nextSegment {
        case .openBracket:
            subNodeA = Node(segments: &segments)
        case.number(let number):
            subNodeA = .number(number: number)

            segments.removeFirst()
        default:
            fatalError()
        }

        nextSegment = segments.removeFirst()

        nextSegment = segments.first!

        let subNodeB: Node

        switch nextSegment {
        case .openBracket:
            subNodeB = Node(segments: &segments)
        case.number(let number):
            subNodeB = .number(number: number)

            segments.removeFirst()
        default:
            fatalError()
        }

        nextSegment = segments.removeFirst()

        self = .pair(a: subNodeA, b: subNodeB)
    }
}

public func solutionFor(input: Input) -> Int {
    var sumLine: Line = input.lines.first!

    for originalLine in input.lines[1 ..< input.lines.endIndex] {
        sumLine.addLine(originalLine)

        var line = sumLine
        var lineIsModified = true

        while lineIsModified {
            lineIsModified = false

            while let explodingBlock = line.nextExplodingPair {
                line.addNumber(explodingBlock.leftNumber, toLeftOf: explodingBlock.startIndex)
                line.addNumber(explodingBlock.rightNumber, toRightOf: explodingBlock.endIndex)

                line.replaceBlockWithZero(explodingBlock)

                lineIsModified = true
            }

            if line.resolveFirstSplit() {
                lineIsModified = true
            }
        }

        sumLine = line
    }

    let rootNode = Node(segments: &sumLine.segments)

    return rootNode.magnitude
}