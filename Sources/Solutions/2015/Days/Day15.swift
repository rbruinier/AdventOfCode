import Foundation
import Tools

final class Day15Solver: DaySolver {
	let dayNumber: Int = 15

	private var input: Input!

	private struct Input {
		let ingredients: [Ingredient]
	}

	private struct Ingredient {
		let name: String

		let capacity: Int
		let durability: Int
		let flavor: Int
		let texture: Int
		let calories: Int
	}

	private struct Scoring {
		var capacity: Int = 0
		var durability: Int = 0
		var flavor: Int = 0
		var texture: Int = 0
		var calories: Int = 0
	}

	private func getScoresForIngredients(ingredients: [Ingredient], remainingTeaspoons: Int, currentScoring: Scoring, filterOnCalories: Bool) -> Int {
		if ingredients.isEmpty {
			if filterOnCalories, currentScoring.calories != 500 {
				return Int.min
			}

			return max(0, currentScoring.capacity)
				* max(0, currentScoring.durability)
				* max(0, currentScoring.flavor)
				* max(0, currentScoring.texture)
		}

		var bestScore = Int.min

		let currentIngredient = ingredients.first!

		for firstIngredientTeaspoonCount in 0 ... remainingTeaspoons {
			var scoring = currentScoring

			scoring.capacity += currentIngredient.capacity * firstIngredientTeaspoonCount
			scoring.durability += currentIngredient.durability * firstIngredientTeaspoonCount
			scoring.flavor += currentIngredient.flavor * firstIngredientTeaspoonCount
			scoring.texture += currentIngredient.texture * firstIngredientTeaspoonCount
			scoring.calories += currentIngredient.calories * firstIngredientTeaspoonCount

			let newRemainingTeaspoons = remainingTeaspoons - firstIngredientTeaspoonCount

			let score = getScoresForIngredients(
				ingredients: Array(ingredients[1 ..< ingredients.count]),
				remainingTeaspoons: newRemainingTeaspoons,
				currentScoring: scoring,
				filterOnCalories: filterOnCalories
			)

			if score > bestScore {
				bestScore = score
			}
		}

		return bestScore
	}

	func solvePart1() -> Int {
		let numberOfTeaspoons = 100

		return getScoresForIngredients(
			ingredients: Array(input.ingredients),
			remainingTeaspoons: numberOfTeaspoons,
			currentScoring: .init(),
			filterOnCalories: false
		)
	}

	func solvePart2() -> Int {
		let numberOfTeaspoons = 100

		return getScoresForIngredients(
			ingredients: Array(input.ingredients),
			remainingTeaspoons: numberOfTeaspoons,
			currentScoring: .init(),
			filterOnCalories: true
		)
	}

	func parseInput(rawString: String) {
		input = .init(ingredients: rawString.allLines().map { line in
			guard let parameters = line.getCapturedValues(pattern: #"([a-zA-Z]*): capacity (-?[0-9]*), durability (-?[0-9]*), flavor (-?[0-9]*), texture (-?[0-9]*), calories (-?[0-9]*)"#) else {
				fatalError()
			}

			let name = parameters[0]
			let capacity = Int(parameters[1])!
			let durability = Int(parameters[2])!
			let flavor = Int(parameters[3])!
			let texture = Int(parameters[4])!
			let calories = Int(parameters[5])!

			return .init(name: name, capacity: capacity, durability: durability, flavor: flavor, texture: texture, calories: calories)
		})
	}
}
