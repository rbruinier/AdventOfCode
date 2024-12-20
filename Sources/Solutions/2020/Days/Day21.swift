import Foundation
import Tools

final class Day21Solver: DaySolver {
	let dayNumber: Int = 21

	struct Input {
		let foods: [Food]
	}

	struct Food {
		let ingredients: [String]
		let allergens: [String]
	}

	private func solve(with foods: [Food]) -> (matches: [String: String], remainingIngredients: Set<String>, countPerIngredient: [String: Int]) {
		var ingredientsPerAllergen: [String: Set<String>] = [:]
		var countPerIngredient: [String: Int] = [:]
		var remainingIngredients: Set<String> = Set()
		var matches: [String: String] = [:]

		for food in foods {
			for allergen in food.allergens {
				if let existingIngredientsForAllergen = ingredientsPerAllergen[allergen] {
					ingredientsPerAllergen[allergen] = existingIngredientsForAllergen.intersection(food.ingredients)
				} else {
					ingredientsPerAllergen[allergen] = Set(food.ingredients)
				}
			}

			for ingredient in food.ingredients {
				remainingIngredients.insert(ingredient)
				countPerIngredient[ingredient, default: 0] += 1
			}
		}

		while true {
			guard let match = ingredientsPerAllergen.first(where: { $0.value.count == 1 }) else {
				break
			}

			let ingredient = match.value.first!

			matches[match.key] = ingredient
			remainingIngredients.remove(ingredient)
			ingredientsPerAllergen.removeValue(forKey: match.key)

			ingredientsPerAllergen = ingredientsPerAllergen.mapValues {
				var values = $0

				values.remove(ingredient)

				return values
			}
		}

		return (matches: matches, remainingIngredients: remainingIngredients, countPerIngredient: countPerIngredient)
	}

	func solvePart1(withInput input: Input) -> Int {
		let solution = solve(with: input.foods)

		return solution.remainingIngredients.reduce(0) { result, ingredient in
			result + solution.countPerIngredient[ingredient]!
		}
	}

	func solvePart2(withInput input: Input) -> String {
		let solution = solve(with: input.foods)

		return solution.matches.sorted(by: { $0.key < $1.key })
			.map(\.value)
			.joined(separator: ",")
	}

	func parseInput(rawString: String) -> Input {
		var foods: [Food] = []

		for line in rawString.allLines() {
			let parts = line.components(separatedBy: " (contains ")

			let ingredients = parts[0].components(separatedBy: .whitespaces)
			let allergens = parts[1].replacingOccurrences(of: ")", with: "").components(separatedBy: ", ")

			foods.append(.init(ingredients: ingredients, allergens: allergens))
		}

		return .init(foods: foods)
	}
}
