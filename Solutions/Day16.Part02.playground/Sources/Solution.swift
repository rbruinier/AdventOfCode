import Foundation

public struct Input {
    let hexString: String
}

struct Operator: Equatable {
    let subPackets: [Packet]
}

struct Packet: Equatable {
    let version: Int
    let packetType: Int
    let value: Int
    let op: Operator?
}

func parseBits(_ bits: inout [Int], count: Int) -> Int {
    var result = 0

    for _ in 0 ..< count {
        result = (result << 1) | bits.removeFirst()
    }

    return result
}

func parseNumber(_ bits: inout [Int]) -> Int {
    var isLastGroup = false
    var number: Int = 0

    while isLastGroup == false {
        isLastGroup = parseBits(&bits, count: 1) == 0 ? true : false

        number = (number << 4) | parseBits(&bits, count: 4)
    }

    return number
}

func parseOperator(_ bits: inout [Int], packetId: Int) -> (Operator, Int) {
    let lengthTypeId = parseBits(&bits, count: 1)

    var subPackets: [Packet] = []

    if lengthTypeId == 0 {
        let length = parseBits(&bits, count: 15)

        print("Operator sub packets length: \(length)")

        let startBitCount = bits.count

        while bits.count > (startBitCount - length) {
            subPackets.append(parsePacket(&bits))
        }
    } else {
        let numberOfSubPackets = parseBits(&bits, count: 11)

        print("Operator sub packets count: \(numberOfSubPackets)")

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

func parsePacket(_ bits: inout [Int]) -> Packet {
    let packetVersion = parseBits(&bits, count: 3)
    let packetId = parseBits(&bits, count: 3)

    print("Packet version: \(packetVersion)")
    print("Packet id: \(packetId)")

    if packetId == 4 {
        let number = parseNumber(&bits)

        return .init(version: packetVersion, packetType: packetId, value: number, op: nil)
    } else {
        let opAndValue = parseOperator(&bits, packetId: packetId)

        return .init(version: packetVersion, packetType: packetId, value: opAndValue.1, op: opAndValue.0)
    }
}

public func solutionFor(input: Input) -> Int {
    print("Hex String: \(input.hexString)")

    var bits = input.hexString.map { Int(String($0), radix: 16)! }.reduce(into: [Int]()) { result, value in
        result.append(value >> 3 & 1)
        result.append(value >> 2 & 1)
        result.append(value >> 1 & 1)
        result.append(value >> 0 & 1)
    }

    let rootPackage = parsePacket(&bits)

    return rootPackage.value
}
