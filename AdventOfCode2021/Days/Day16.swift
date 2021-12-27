import Foundation

final class Day16Solver: DaySolver {
    let dayNumber: Int = 16

    private var input: Input!

    private struct Input {
        let hexString: String
    }

    private struct Operator: Equatable {
        let subPackets: [Packet]
    }

    private struct Packet: Equatable {
        let version: Int
        let packetType: Int
        let value: Int
        let op: Operator?
    }

    private func parseBits(_ bits: inout [Int], count: Int) -> Int {
        var result = 0

        for _ in 0 ..< count {
            result = (result << 1) | bits.removeFirst()
        }

        return result
    }

    private func parseNumber(_ bits: inout [Int]) -> Int {
        var isLastGroup = false
        var number: Int = 0

        while isLastGroup == false {
            isLastGroup = parseBits(&bits, count: 1) == 0 ? true : false

            number = (number << 4) | parseBits(&bits, count: 4)
        }

        return number
    }

    private func parseOperator(_ bits: inout [Int], packetId: Int) -> (Operator, Int) {
        let lengthTypeId = parseBits(&bits, count: 1)

        var subPackets: [Packet] = []

        if lengthTypeId == 0 {
            let length = parseBits(&bits, count: 15)

            let startBitCount = bits.count

            while bits.count > (startBitCount - length) {
                subPackets.append(parsePacket(&bits))
            }
        } else {
            let numberOfSubPackets = parseBits(&bits, count: 11)

            for _ in 0 ..< numberOfSubPackets {
                subPackets.append(parsePacket(&bits))
            }
        }

        let value: Int
        switch packetId {
        case 0: // sum
            value = subPackets.reduce(0) { result, item in result + item.value}
        case 1: // product
            value = subPackets.reduce(1) { result, item in result * item.value}
        case 2: // minimum
            value = subPackets.map { $0.value }.min()!
        case 3: // maximum
            value = subPackets.map { $0.value }.max()!
        case 5: // greater than
            value = subPackets[0].value > subPackets[1].value ? 1 : 0
        case 6: // smaller than
            value = subPackets[0].value < subPackets[1].value ? 1 : 0
        case 7: // equal
            value = subPackets[0].value == subPackets[1].value ? 1 : 0
        default:
            fatalError("Not implemented")
        }

        return (.init(subPackets: subPackets), value)
    }

    private func parsePacket(_ bits: inout [Int]) -> Packet {
        let packetVersion = parseBits(&bits, count: 3)
        let packetId = parseBits(&bits, count: 3)

        if packetId == 4 {
            let number = parseNumber(&bits)

            return .init(version: packetVersion, packetType: packetId, value: number, op: nil)
        } else {
            let opAndValue = parseOperator(&bits, packetId: packetId)

            return .init(version: packetVersion, packetType: packetId, value: opAndValue.1, op: opAndValue.0)
        }
    }

    func solvePart1() -> Any {
        var bits = input.hexString.map { Int(String($0), radix: 16)! }.reduce(into: [Int]()) { result, value in
            result.append(value >> 3 & 1)
            result.append(value >> 2 & 1)
            result.append(value >> 1 & 1)
            result.append(value >> 0 & 1)
        }

        let rootPackage = parsePacket(&bits)

        var stack: [Packet] = [rootPackage]

        var versionSum = 0
        while let currentPacket = stack.popLast() {
            versionSum += currentPacket.version

            if let subPackets = currentPacket.op?.subPackets {
                stack.append(contentsOf: subPackets)
            }
        }

        return versionSum
    }

    func solvePart2() -> Any {
        var bits = input.hexString.map { Int(String($0), radix: 16)! }.reduce(into: [Int]()) { result, value in
            result.append(value >> 3 & 1)
            result.append(value >> 2 & 1)
            result.append(value >> 1 & 1)
            result.append(value >> 0 & 1)
        }

        let rootPackage = parsePacket(&bits)

        return rootPackage.value
    }

    func parseInput(rawString: String) {
        let rawLine = rawString
            .components(separatedBy: CharacterSet.whitespacesAndNewlines)
            .first!

        input = .init(hexString: rawLine)
    }
}
