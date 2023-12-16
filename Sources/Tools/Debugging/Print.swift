import Foundation

public enum PrintTools {
	public static func printPathInPoints(_ points: Set<Point2D>) {
		guard points.isNotEmpty else {
			print("empty path")

			return
		}

		let maxX = points.map(\.x).max()!
		let maxY = points.map(\.y).max()!

		for y in 0 ... maxY {
			var line = ""
			for x in 0 ... maxX {
				if points.contains(.init(x: x, y: y)) {
					line += "#"
				} else {
					line += "."
				}
			}

			print(line)
		}
	}
}
