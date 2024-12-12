import Foundation
import Tools

final class Day25Solver: DaySolver {
	let dayNumber: Int = 25

	private var input: Input!

	private struct Input {
		let points: [Point4D]
	}
	
	private struct Point4D: Hashable {
		let x: Int
		let y: Int
		let z: Int
		let w: Int
		
		func manhattanDistance(from b: Point4D) -> Int {
			abs(b.x - x) + abs(b.y - y) + abs(b.z - z) + abs(b.w - w)
		}
	}
	
	private final class Constellation {
		var points: Set<Point4D>
		
		init(points: Set<Point4D>) {
			self.points = points
		}
		
		func contains(point pointB: Point4D) -> Bool {
			points.contains {
				$0.manhattanDistance(from: pointB) <= 3
			}
		}
		
		func mergeIn(constellation constellationB: Constellation) -> Bool {
			var didMerge = false
			
			let bPoints = constellationB.points
			
			for pointB in bPoints {
				if contains(point: pointB) {
					points.insert(pointB)
					constellationB.points.remove(pointB)
					
					didMerge = true
				}
			}
			
			return didMerge
		}
	}

	func solvePart1() -> Int {
		let constellations: [Constellation] = input.points.map { Constellation(points: Set([$0])) }
		
		// start by each point in its own constellation and then start merging them till there is nothing to merge
		while true {
			var didMerge = false
			
			for i in 0 ..< constellations.count {
				for j in i + 1 ..< constellations.count {
					didMerge = didMerge || constellations[i].mergeIn(constellation: constellations[j])
				}
			}
			
			if !didMerge {
				break
			}
		}
		
		return constellations.count { $0.points.isNotEmpty }
	}

	func solvePart2() -> String {
		"Merry Christmas 🎄"
	}

	func parseInput(rawString: String) {
		input = .init(points: rawString.allLines().map { line in
			let components = line.components(separatedBy: ",")
			
			return Point4D(x: Int(components[0])!, y: Int(components[1])!, z: Int(components[2])!, w: Int(components[3])!)
		})
	}
}
