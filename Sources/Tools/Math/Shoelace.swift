public enum Shoelace {
	public static func calculateArea(of coordinates: [Point2D], includeBorder: Bool = true) -> Int {
		guard coordinates.count >= 3 else {
			preconditionFailure()
		}

		var area = 0

		for index in 0 ..< coordinates.count {
			let nextIndex = (index + 1) % coordinates.count

			let c1 = coordinates[index]
			let c2 = coordinates[nextIndex]

			area += (c1.x * c2.y) - (c2.x * c1.y) + (includeBorder ? abs(c2.x - c1.x) + abs(c2.y - c1.y) : 0)
		}

		return area / 2 + (includeBorder ? 1 : 0)
	}
}
