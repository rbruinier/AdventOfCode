import Foundation
import Tools

/// Tried to solve part 2 with quadratic equations but got quite messy as we usually only work with ints. Instead just simulate particles and stop after a certain amount of cycles without collisions.
/// Appears that happens rather soon.
final class Day20Solver: DaySolver {
	let dayNumber: Int = 20

	struct Input {
		let particles: [Particle]
	}

	struct Particle {
		var position: Point3D
		var velocity: Point3D
		var acceleration: Point3D
	}

	func solvePart1(withInput input: Input) -> Int {
		// we should not need to simulate anything, instead whatever has the lowest total acceleration should be closest on the long term

		let particles = input.particles

		var nearestParticleIndex = 0
		var lowestAcceleration = particles[0].acceleration.manhattanDistance(from: .zero)

		for (index, particle) in particles.enumerated() {
			let acceleration = particle.acceleration.manhattanDistance(from: .zero)

			if acceleration < lowestAcceleration {
				lowestAcceleration = acceleration
				nearestParticleIndex = index
			}
		}

		return nearestParticleIndex
	}

	func solvePart2(withInput input: Input) -> Int {
		var particles = input.particles

		var particleIndicesToRemove: Set<Int> = []

		var noChangeCounter = 0
		while true {
			particleIndicesToRemove.removeAll()

			for i in 0 ..< particles.count {
				for j in i + 1 ..< particles.count {
					if particles[i].position == particles[j].position {
						particleIndicesToRemove.insert(i)
						particleIndicesToRemove.insert(j)
					}
				}
			}

			particles = particles.enumerated().filter {
				particleIndicesToRemove.contains($0.offset) == false
			}.map(\.element)

			for i in 0 ..< particles.count {
				particles[i].velocity += particles[i].acceleration
				particles[i].position += particles[i].velocity
			}

			if particleIndicesToRemove.isNotEmpty {
				noChangeCounter = 0
			} else {
				noChangeCounter += 1
			}

			if noChangeCounter == 20 {
				return particles.count
			}
		}
	}

	func parseInput(rawString: String) -> Input {
		func parsePoint3D(_ data: String) -> Point3D {
			Point3D(commaSeparatedString: data[3 ..< data.count - 1])
		}

		return .init(particles: rawString.allLines().map { line in
			let parts = line.components(separatedBy: ", ")

			return Particle(
				position: parsePoint3D(parts[0]),
				velocity: parsePoint3D(parts[1]),
				acceleration: parsePoint3D(parts[2])
			)
		})
	}
}
