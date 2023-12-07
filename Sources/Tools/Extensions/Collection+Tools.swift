// Created by Robert Bruinier

import Foundation

public extension Collection {
	var isNotEmpty: Bool {
		!isEmpty
	}
}

public extension Collection where Element: Hashable {
	func occurrences() -> [Element: Int] {
		var occurrencesDictionary: [Element: Int] = [:]

		for element in self {
			occurrencesDictionary[element, default: 0] += 1
		}

		return occurrencesDictionary
	}
}
