import Collections
import Foundation
import Tools

/// This solution first creates a weighted graph only including the start valve and the valves with output. This allows to ignore all other valves when branching
/// in our recursive scoring function. It appears there are only 15 valves with output, inlcuding the starting valve this leaves only 16 valves. This is nice because
/// we can easily pack the opened valves in a 16 bit (2 byte) bitmask. The index of the current valve also only takes 16 bits.
///
/// We also calculate the max value of the cache key and reserve an array for the cache, instead of using a dictionary this saves 50% time.
///
/// Details of memoization cache key can be found at the documentation of the `getMaximumOutput` function.
///
/// The two player works serially. It first runs every possible path of player 1 and when the time is up it will do the same for player 2. Serial or parallel doesn't matter
/// for the end result as long as we keep the starting (zero rate) path included so we always have a state where elephant reaches a valve before player 1.
final class Day16Solver: DaySolver {
	let dayNumber: Int = 16

	private var memoization: [Int] = [] // space is reserved in solvers

	struct Input {
		let valves: [Valve]
	}

	struct Valve: Equatable, Hashable {
		let id: String
		let rate: Int
		let connectedToIDs: [String]
	}

	private struct Edge: Hashable {
		let a: Int
		let b: Int
	}

	private struct ValveNetwork {
		let pathWeights: [Edge: Int]
		let valveOutputs: [Int]
		let startMinutes: Int
	}

	init() {}

	private func resolvePathsBetweenStartAndValvesWithOutputs(valves: [Valve], startValveIndex: Int) -> [Edge: [Int]] {
		var edges: Set<UnweightedGraph.Edge> = []

		for (a, valve) in valves.enumerated() {
			for connectionID in valve.connectedToIDs {
				let b = valves.firstIndex(where: { $0.id == connectionID })!

				let ids = [a, b].sorted()

				let edge = UnweightedGraph.Edge(a: ids.first!, b: ids.last!)

				edges.insert(edge)
			}
		}

		let graph = UnweightedGraph(
			elementsCount: valves.count,
			edges: Array(edges)
		)

		let valvesWithOutput: [Int] = valves.enumerated().compactMap { $1.rate > 0 ? $0 : nil }

		let relevantValves = [startValveIndex] + valvesWithOutput

		var shortestPathFromAToB: [Edge: [Int]] = [:]

		for i in 0 ..< relevantValves.count {
			for j in i + 1 ..< relevantValves.count {
				let path = BFS.shortestPathInGraph(graph, from: relevantValves[i], to: relevantValves[j])!

				shortestPathFromAToB[.init(a: relevantValves[i], b: relevantValves[j])] = path.pathIndices
				shortestPathFromAToB[.init(a: relevantValves[j], b: relevantValves[i])] = path.pathIndices.reversed()
			}
		}

		return shortestPathFromAToB
	}

	private func generateValveNetwork(valves: [Valve], startMinutes: Int) -> ValveNetwork {
		let startValveID = "AA"

		let valvesWithOutput: [Int] = valves.enumerated().compactMap { $1.rate > 0 ? $0 : nil }

		// step 1, get the shortest paths from the *relevant* valves (the start valve and all valves with an output; we don't care about the rest)
		let startValveIndex = valves.firstIndex(where: { $0.id == startValveID })!

		let shortestPathFromAToB = resolvePathsBetweenStartAndValvesWithOutputs(valves: valves, startValveIndex: startValveIndex)

		// remap to only have the start valve and the relevant valves (the ones with output, we don't care about the rest)
		var valveRatesByIndex: [Int] = []

		valveRatesByIndex.append(0) // assumption: starting valve has no output

		var oldToNewIndex: [Int: Int] = [startValveIndex: 0]

		for index in valvesWithOutput {
			oldToNewIndex[index] = valveRatesByIndex.count

			valveRatesByIndex.append(valves[index].rate)
		}

		var remappedWeightsFromAToB: [Edge: Int] = [:]

		for (edge, path) in shortestPathFromAToB {
			remappedWeightsFromAToB[.init(a: oldToNewIndex[edge.a]!, b: oldToNewIndex[edge.b]!)] = path.count - 1
		}

		return .init(pathWeights: remappedWeightsFromAToB, valveOutputs: valveRatesByIndex, startMinutes: startMinutes)
	}

	/**
	 Recursive function moving through all possible moves for a player whilst taking remaining time into account.

	 Memoization is used to optimize this. To have an efficient memoization cache we use Ints as cache keys. To make this possible we pack
	 all relevant parameters into a single int:

	 * currentValveIndex = 0 ..< 15 -> 4 bits << 0
	 * openedValvesMask = bitmask = 0 ..< 65535 -> 16 bits -> << 4
	 * remainingTime = 0 ..< 30 -> 5 bits -> << 20
	 * player = 0 ... 1 -> 1 bit << 25

	 total bits = 26, max value = 2^26 = 67.108.864
	 */
	private func getMaximumOutput(currentValveIndex: Int, openedValvesMask: Int, remainingTime: Int, player: Int, network: ValveNetwork) -> Int {
		let cacheKey: Int = (currentValveIndex << 0) | (openedValvesMask << 4) | (remainingTime << 20) | (player << 25)

		if memoization[cacheKey] != -1 {
			return memoization[cacheKey]
		}

		if remainingTime <= 1 { // we bail when remaining time is less or equal to 1, not enough time to gain any extra output
			if player == 1 {
				return getMaximumOutput(
					currentValveIndex: 0,
					openedValvesMask: openedValvesMask,
					remainingTime: network.startMinutes,
					player: player - 1,
					network: network
				)
			} else {
				return 0
			}
		}

		var maxScore = 0

		if ((openedValvesMask >> currentValveIndex) & 1) == 0, network.valveOutputs[currentValveIndex] > 0 {
			let score = max(0, (remainingTime - 1) * network.valveOutputs[currentValveIndex])

			maxScore = max(
				maxScore,
				score + getMaximumOutput(
					currentValveIndex: currentValveIndex,
					openedValvesMask: openedValvesMask | (1 << currentValveIndex),
					remainingTime: remainingTime - 1,
					player: player,
					network: network
				)
			)
		}

		for targetIndex in 0 ..< network.valveOutputs.count where currentValveIndex != targetIndex {
			let steps = network.pathWeights[.init(a: currentValveIndex, b: targetIndex)]!

			if remainingTime - steps <= 1 {
				continue
			}

			maxScore = max(
				maxScore,
				getMaximumOutput(
					currentValveIndex: targetIndex,
					openedValvesMask: openedValvesMask,
					remainingTime: remainingTime - steps,
					player: player,
					network: network
				)
			)
		}

		memoization[cacheKey] = maxScore

		return maxScore
	}

	func solvePart1(withInput input: Input) -> Int {
		memoization = Array(repeating: -1, count: 68_000_000)

		let valveNetwork = generateValveNetwork(valves: input.valves, startMinutes: 30)

		return getMaximumOutput(
			currentValveIndex: 0,
			openedValvesMask: 0,
			remainingTime: valveNetwork.startMinutes,
			player: 0,
			network: valveNetwork
		)
	}

	func solvePart2(withInput input: Input) -> Int {
		memoization = Array(repeating: -1, count: 68_000_000)

		let valveNetwork = generateValveNetwork(valves: input.valves, startMinutes: 26)

		return getMaximumOutput(
			currentValveIndex: 0,
			openedValvesMask: 0,
			remainingTime: valveNetwork.startMinutes,
			player: 1,
			network: valveNetwork
		)
	}

	func parseInput(rawString: String) -> Input {
		return .init(valves: rawString.allLines().map { line in
			let splittedLine = line.components(separatedBy: "; ")

			let valveArguments = splittedLine[0].getCapturedValues(pattern: #"Valve ([A-Z]*) has flow rate=([0-9]*)"#)!

			let valveID = valveArguments[0]
			let rate = Int(valveArguments[1])!

			let tunnelComponents = splittedLine[1].components(separatedBy: " ")

			var connectedToIDs: [String] = []

			for index in 4 ..< tunnelComponents.count {
				connectedToIDs.append(tunnelComponents[index].replacingOccurrences(of: ",", with: ""))
			}

			return Valve(id: valveID, rate: rate, connectedToIDs: connectedToIDs)
		})
	}
}
