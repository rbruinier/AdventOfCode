import Foundation

final class Day14Solver: DaySolver {
    let dayNumber: Int = 14

    private var input: Input!

    private struct Input {
        let instructions: [Instruction]
    }

    private struct Instruction {
        let memoryId: Int

        let mask: Int64
        let maskValue: Int64

        let value: Int64
    }

    func solvePart1() -> Any {
        var memory: [Int: Int64] = [:]

        for instruction in input.instructions {
            let value = instruction.value

            var result: Int64 = 0
            for shifter: Int64 in 0 ..< 36 {
                var bit: Int64 = (value >> shifter) & 1

                if ((instruction.mask >> shifter) & 1) != 0 {
                    bit = (instruction.maskValue >> shifter) & 1
                }

                result |= bit << shifter
            }

            memory[instruction.memoryId] = result
        }

        return memory.values.reduce(0, +)
    }

    func solvePart2() -> Any {
        func createAllVariations(base: Int64, instruction: Instruction, bitShifters: [Int64]) -> [Int64] {
            var shifters = bitShifters

            guard let shifter = shifters.first else {
                return []
            }

            shifters.removeFirst()

            let version1 = base | (1 << shifter) // force 1
            let version2 = base & (0b11111111_11111111_11111111_11111111_1111 ^ (1 << shifter))

            return [version1, version2]
                + createAllVariations(base: version1, instruction: instruction, bitShifters: shifters)
                + createAllVariations(base: version2, instruction: instruction, bitShifters: shifters)
        }

        var memory: [Int64: Int64] = [:]

        for instruction in input.instructions {
            var memoryId = Int64(instruction.memoryId)

            var bitShifters: [Int64] = []

            for shifter: Int64 in 0 ..< 36 {
                if ((instruction.mask >> shifter) & 1) == 0 {
                    bitShifters.append(shifter)
                } else {
                    memoryId |= ((instruction.maskValue >> shifter) & 1) << shifter
                }
            }

            let memoryIds = createAllVariations(base: memoryId, instruction: instruction, bitShifters: bitShifters)

            for modifiedMemoryId in memoryIds {
                memory[modifiedMemoryId] = instruction.value
            }
        }

        return memory.values.reduce(0, +)
    }

    func parseInput(rawString: String) {
        let lines = rawString.allLines()

        var currentMask: Int64 = 0
        var currentMaskValue: Int64 = 0

        var instructions: [Instruction] = []

        for line in lines {
            let components = line.components(separatedBy: " = ")

            if components[0] == "mask" {
                currentMask = 0
                currentMaskValue = 0

                var shifter = 35

                for symbol in components[1] {
                    if symbol == "1" {
                        currentMask |= 1 << shifter
                        currentMaskValue |= 1 << shifter
                    } else if symbol == "0" {
                        currentMask |= 1 << shifter
                    }

                    shifter -= 1
                }
            } else {
                let mem = components[0]

                let lastIndex = mem.firstIndex(of: "]")!

                let memoryId = Int(String(mem[mem.index(mem.startIndex, offsetBy: 4) ..< lastIndex]))!
                let value = Int64(components[1])!

                instructions.append(.init(memoryId: memoryId, mask: currentMask, maskValue: currentMaskValue, value: value))
            }
        }

        input = .init(instructions: instructions)
    }
}
