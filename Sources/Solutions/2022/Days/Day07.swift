import Foundation
import Tools

final class Day07Solver: DaySolver {
	let dayNumber: Int = 7

	private var input: Input!

	private struct Input {
		let terminalLines: [TerminalLine]
	}

	private enum Command: CustomStringConvertible {
		case cdRoot
		case cdBack
		case cd(folder: String)

		var description: String {
			switch self {
			case .cdRoot: "cd /"
			case .cdBack: "cd .."
			case .cd(let folder): "cd \(folder)"
			}
		}
	}

	private enum Listing: CustomStringConvertible {
		case dir(name: String)
		case file(name: String, size: Int)

		var description: String {
			switch self {
			case .dir(let name): "dir \(name)"
			case .file(let name, let size): "\(name) \(size)"
			}
		}
	}

	private enum TerminalLine: CustomStringConvertible {
		case command(command: Command)
		case listing(listing: Listing)

		var description: String {
			switch self {
			case .command(let command): command.description
			case .listing(let listing): listing.description
			}
		}
	}

	private struct File {
		let name: String
		let size: Int
	}

	private class FileNode {
		var name: String

		var parentNode: FileNode?

		var directories: [FileNode] = []
		var files: [File] = []

		private var cachedSize: Int?

		init(name: String, parentNode: FileNode?) {
			self.name = name
			self.parentNode = parentNode
		}

		func size(recursive: Bool = true) -> Int {
			if let cachedSize {
				return cachedSize
			}

			cachedSize = files.map(\.size).reduce(0, +) + directories.reduce(0) { $0 + $1.size(recursive: recursive) }

			return cachedSize!
		}
	}

	init() {}

	private func createFileStructure(fromTerminalLines terminalLines: [TerminalLine]) -> FileNode {
		let rootNode = FileNode(name: "/", parentNode: nil)

		var currentNode = rootNode

		for terminalLine in input.terminalLines {
			switch terminalLine {
			case .command(let command):
				switch command {
				case .cdRoot:
					currentNode = rootNode
				case .cdBack:
					currentNode = currentNode.parentNode!
				case .cd(let name):
					currentNode = currentNode.directories.first(where: { $0.name == name })!
				}
			case .listing(let listing):
				switch listing {
				case .dir(let name):
					currentNode.directories.append(.init(name: name, parentNode: currentNode))
				case .file(let name, let size):
					currentNode.files.append(.init(name: name, size: size))
				}
			}
		}

		return rootNode
	}

	func solvePart1() -> Int {
		let rootNode = createFileStructure(fromTerminalLines: input.terminalLines)

		func findDirectoriesWithMaximumSize(startNode: FileNode, result: inout Int) {
			for directory in startNode.directories {
				let size = directory.size(recursive: true)

				if size < 100_000 {
					result += size
				}

				findDirectoriesWithMaximumSize(startNode: directory, result: &result)
			}
		}

		var sum = 0

		findDirectoriesWithMaximumSize(startNode: rootNode, result: &sum)

		return sum
	}

	func solvePart2() -> Int {
		let rootNode = createFileStructure(fromTerminalLines: input.terminalLines)

		let totalDiskSpace = 70_000_000
		let freeSpaceRequired = 30_000_000
		let currentFreeSpace = totalDiskSpace - rootNode.size(recursive: true)
		let minimumDirectorySize = freeSpaceRequired - currentFreeSpace

		func findBestDirectorySizeToDelete(startNode: FileNode, result: inout Int) {
			for directory in startNode.directories {
				let size = directory.size(recursive: true)

				if size < minimumDirectorySize {
					continue
				}

				if size < result {
					result = size
				}

				findBestDirectorySizeToDelete(startNode: directory, result: &result)
			}
		}

		var bestSize = Int.max

		findBestDirectorySizeToDelete(startNode: rootNode, result: &bestSize)

		return bestSize
	}

	func parseInput(rawString: String) {
		let terminalLines: [TerminalLine] = rawString.allLines().compactMap { line in
			if line == "$ cd /" {
				.command(command: .cdRoot)
			} else if line == "$ cd .." {
				.command(command: .cdBack)
			} else if line == "$ ls" {
				nil
			} else if let values = line.getCapturedValues(pattern: #"\$ cd (.*)"#) {
				.command(command: .cd(folder: values[0]))
			} else if let values = line.getCapturedValues(pattern: #"dir (.*)"#) {
				.listing(listing: .dir(name: values[0]))
			} else if let values = line.getCapturedValues(pattern: #"([0-9]*) (.*)"#) {
				.listing(listing: .file(name: values[1], size: Int(values[0])!))
			} else {
				fatalError()
			}
		}

		input = .init(terminalLines: terminalLines)
	}
}
