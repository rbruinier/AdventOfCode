import Foundation
import Tools

final class Day21Solver: DaySolver {
	let dayNumber: Int = 21

	private var input: Input!

	private struct Input {
		let program: [Int]
	}

	func solvePart1() -> Int {
		var metaProgram = """
		# we certainly want to jump if the A (next item) is empty
		NOT A J

		# we also jump if C (3 steps) is ahead
		NOT C T
		OR  T J

		# but we make sure D is safe to land to prevent early jumps
		AND D J

		WALK
		"""

		// this allows for including empty lines in program and using # for comment lines, easier to program
		metaProgram = metaProgram.allLines().filter { $0.starts(with: "#") == false }.joined(separator: "\n") + "\n"

		let intcode = IntcodeProcessor(program: input.program)

		let asciiBuffer = metaProgram.map { Int($0.asciiValue!) }

		let result = intcode.executeProgram(input.program, input: asciiBuffer)

		if result.output.last! > 127 {
			return result.output.last!
		}

		return 0
	}

	func solvePart2() -> Int {
		var metaProgram = """
		# we certainly want to jump if the A (next item) is empty
		NOT A J

		# we also jump if B (2 steps) is ahead
		NOT B T
		OR  T J

		# we also jump if C (3 steps) is ahead
		NOT C T
		OR  T J

		# but we make sure D is safe to land to prevent early jumps
		AND D J

		# we also want to make sure that the spot after landing is not empty with another empty spot 4 spots ahead (#####.#.##...####)
		OR  D T
		AND E T
		OR  H T
		AND T J

		RUN
		"""

		// this allows for including empty lines in program and using # for comment lines, easier to program
		metaProgram = metaProgram.allLines().filter { $0.starts(with: "#") == false }.joined(separator: "\n") + "\n"

		let intcode = IntcodeProcessor(program: input.program)

		let asciiBuffer = metaProgram.map { Int($0.asciiValue!) }

		let result = intcode.executeProgram(input.program, input: asciiBuffer)

		//        let string = result.output.compactMap {
		//            if $0 <= 127 {
		//                return String(UnicodeScalar(UInt8($0)))
		//            } else {
		//                return nil
		//            }
		//        }.joined()
//
		//        print(string)

		if result.output.last! > 127 {
			return result.output.last!
		}

		return 0
	}

	func parseInput(rawString: String) {
		input = .init(program: rawString.parseCommaSeparatedInts())
	}
}
