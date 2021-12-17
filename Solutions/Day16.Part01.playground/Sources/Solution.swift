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
    let number: Int?
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

func parseOperator(_ bits: inout [Int]) -> Operator {
    let lengthTypeId = parseBits(&bits, count: 1)

    if lengthTypeId == 0 {
        let length = parseBits(&bits, count: 15)

        print("Operator sub packets length: \(length)")

        let startBitCount = bits.count

        var subPackets: [Packet] = []
        while bits.count > (startBitCount - length) {
            subPackets.append(parsePacket(&bits))
        }

        return .init(subPackets: subPackets)
    } else {
        let numberOfSubPackets = parseBits(&bits, count: 11)

        print("Operator sub packets count: \(numberOfSubPackets)")

        var subPackets: [Packet] = []
        for _ in 0 ..< numberOfSubPackets {
            subPackets.append(parsePacket(&bits))
        }

        return .init(subPackets: subPackets)
    }
}

func parsePacket(_ bits: inout [Int]) -> Packet {
    let packetVersion = parseBits(&bits, count: 3)
    let packetId = parseBits(&bits, count: 3)

    print("Packet version: \(packetVersion)")
    print("Packet id: \(packetId)")

    if packetId == 4 {
        let number = parseNumber(&bits)

        return .init(version: packetVersion, packetType: packetId, number: number, op: nil)
    } else {
        let op = parseOperator(&bits)

        return .init(version: packetVersion, packetType: packetId, number: nil, op: op)
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
