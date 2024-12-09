import Foundation
import Tools

final class Day09Solver: DaySolver {
	let dayNumber: Int = 9

	let expectedPart1Result = 6291146824486
	let expectedPart2Result = 6307279963620

	private var input: Input!

	private struct DataBlock {
		enum BlockType: Equatable {
			case free
			case file(id: Int)
		}

		let blockType: BlockType
		let size: Int
	}

	private struct Input {
		let blocks: [Int]
	}

	/// Part 1
	private static func expandBlocksIntoFilemap(_ blocks: [Int]) -> [Int?] {
		var diskmap: [Int?] = []

		for (index, block) in blocks.enumerated() {
			let isFileBlock = index % 2 == 0

			for _ in 0 ..< block {
				if isFileBlock {
					diskmap.append(index / 2)
				} else {
					diskmap.append(nil)
				}
			}
		}

		return diskmap
	}

	/// Part 1
	private static func compactFilemap(_ originalFilemap: [Int?]) -> [Int] {
		var filemap = originalFilemap

		for index in (0 ..< originalFilemap.count).reversed() {
			guard let blockID = originalFilemap[index] else {
				continue
			}

			var replacedBlock = false

			for emptyIndex in 0 ..< index {
				if filemap[emptyIndex] == nil {
					filemap[emptyIndex] = blockID
					filemap[index] = nil
					replacedBlock = true
					break
				}
			}

			if !replacedBlock {
				break
			}
		}

		return filemap.compactMap { $0 }
	}

	/// Part 2
	private static func expandBlocksIntoDataBlocks(_ blocks: [Int]) -> [DataBlock] {
		var dataBlocks: [DataBlock] = []

		for (index, block) in blocks.enumerated() {
			let isFileBlock = index % 2 == 0

			if isFileBlock {
				dataBlocks.append(.init(blockType: .file(id: index / 2), size: block))
			} else {
				dataBlocks.append(.init(blockType: .free, size: block))
			}
		}

		return dataBlocks
	}

	/// Part 2
	private static func compactDataBlocks(_ originalDataBlocks: [DataBlock]) -> [DataBlock] {
		var dataBlocks = originalDataBlocks

		let identifiers: [Int] = dataBlocks.compactMap {
			guard case .file(let id) = $0.blockType else {
				return nil
			}

			return id
		}

		identifierLoop: for identifier in identifiers.reversed() {
			let originalIndex = dataBlocks.firstIndex(where: {
				guard case .file(let id) = $0.blockType else {
					return false
				}

				return id == identifier
			})!

			let fileDataBlock = dataBlocks[originalIndex]

			for newIndex in 0 ..< originalIndex {
				let newIndexDataBlock = dataBlocks[newIndex]

				switch newIndexDataBlock.blockType {
				case .free:
					let remainingSize = newIndexDataBlock.size - fileDataBlock.size

					if remainingSize < 0 {
						continue
					}

					dataBlocks[originalIndex] = .init(blockType: .free, size: fileDataBlock.size)

					if remainingSize == 0 {
						dataBlocks[newIndex] = fileDataBlock
					} else {
						dataBlocks[newIndex] = .init(blockType: .free, size: remainingSize)
						dataBlocks.insert(fileDataBlock, at: newIndex)
					}

					continue identifierLoop
				case .file:
					continue
				}
			}
		}

		return dataBlocks
	}

	/// Part 1 & 2
	private static func checksum(for filemap: [Int?]) -> Int {
		var checksum = 0

		for (index, blockID) in filemap.enumerated() {
			if let blockID {
				checksum += index * blockID
			}
		}

		return checksum
	}

	func solvePart1() -> Int {
		let filemap = Self.expandBlocksIntoFilemap(input.blocks)

		return Self.checksum(for: Self.compactFilemap(filemap))
	}

	func solvePart2() -> Int {
		var dataBlocks = Self.expandBlocksIntoDataBlocks(input.blocks)

		dataBlocks = Self.compactDataBlocks(dataBlocks)

		var checksumInput: [Int?] = []

		for dataBlock in dataBlocks {
			switch dataBlock.blockType {
			case .free:
				for _ in 0 ..< dataBlock.size {
					checksumInput.append(nil)
				}
			case .file(let id):
				for _ in 0 ..< dataBlock.size {
					checksumInput.append(id)
				}
			}
		}

		return Self.checksum(for: checksumInput)
	}

	func parseInput(rawString: String) {
		let blocks: [Int] = rawString.trimmingCharacters(in: .whitespacesAndNewlines).map { character in
			Int(String(character))!
		}

		input = .init(blocks: blocks)
	}
}
