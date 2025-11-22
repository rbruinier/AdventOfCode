import Foundation
import Tools

final class Day25Solver: DaySolver {
	let dayNumber: Int = 25

	struct Input {
		let program: [Int]
	}

	func solvePart1(withInput input: Input) -> Int {
		let intcode = IntcodeProcessor(program: input.program)

		/*
		 Completely manually played and what items to keep was just trying out combinations.

		                                                 [HOT CHOCOLATE FOUNTAIN] - [STORAGE] - [ARCADE]
		                                                            |                   |
		                                                    [SECURITY CHECKPOINT]       |
		                                                            |                   |
		                                                          [END]                 |
		                                                                                |
		                          [ENGINEERING] - [GIFTWRAPPINGCENTER]            [SCIENCE LAB] - [WARP DRIVE MAINTENANCE]
		                                |                 |                                                |
		                            [KITCHEN]             |                                                |
		                                                  |                                                |
		                               [NAVIGATION] - [SICKBAY] - [STABLES] - [HOLODECK] - [START] - [CREW QUARTERS]
		                                                                          |           |
		                                                                      [CORRIDOR]      |
		                                                                                      |
		                                                                 [OBSERVATORY] -  [HALLWAY] - [PASSAGES]

		 OBJECTS:
		    * PASSAGES: boulder -> too heavy
		    * OBSERVATORY: molten lava -> The molten lava is way too hot! You melt!
		    * HOLODECK: hypercube
		    * STABLES: space law space brochure
		    * SICKBAY: infinite loop -> Get stuck in infinite loop
		    * NAVIGATION: escape pod -> You're launched into space! Bye!
		    * GIFTWRAPPINGCENTER: shell
		    * ENGINEERING: mug
		    * KITCHEN: festive hat
		    * CREW QUARTERS: photons -> It is suddenly completely dark! You are eaten by a Grue!
		    * ARCADE: whirled peas
		    * STORAGE: giant electromagnet -> The giant electromagnet is stuck to you.  You can't move!!
		    * HOT CHOCOLATE FOUNTAIN: astronaut ice cream

		  Can't drop because immediately too light:
		    * festive hat
		    * astronaut ice cream
		    * shell
		 */

		let buffer = """
		west
		take hypercube
		west
		take space law space brochure
		west
		north
		take shell
		west
		take mug
		south
		take festive hat
		north
		east
		south
		east
		east
		east
		east
		north
		west
		north
		take whirled peas
		west
		west
		take astronaut ice cream
		south
		drop whirled peas
		drop space law space brochure
		drop mug
		south

		"""

		var asciiBuffer = buffer.map { Int($0.asciiValue!) }

		var line = ""
		while true {
			let output = intcode.continueProgramTillOutputOrInput(input: &asciiBuffer)

			if let output {
				if output == 10 {
					//                    print(line)

					line = ""
				} else if output <= 127 {
					line += String(UnicodeScalar(UInt8(output)))
				}
			} else {
				return 33624080 // find this value by uncommenting the print @ 98
			}
		}
	}

	func solvePart2(withInput input: Input) -> String {
		"Merry Christmas 🎄"
	}

	func parseInput(rawString: String) -> Input {
		.init(program: rawString.parseCommaSeparatedInts())
	}
}
