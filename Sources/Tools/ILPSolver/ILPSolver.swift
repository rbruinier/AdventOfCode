import Foundation

/// This solver is written by Claude Code. Summary:
/// 1. Gaussian elimination - Reduce the system to find which variables are "free" (can be chosen) vs "determined" (computed from others)
/// 2. If unique solution - Return it directly
/// 3. If multiple solutions - The free variables define a solution space. Search over integer values of free variables, compute the determined variables, and keep the valid solution with minimum sum
/// 4. Pruning - Skip branches early when they can't possibly yield non-negative integers
public enum ILPSolver {
	private struct Rational: Equatable {
		let num: Int
		let den: Int

		init(_ num: Int, _ den: Int = 1) {
			if den == 0 {
				self.num = num
				self.den = 0
			} else if num == 0 {
				self.num = 0
				self.den = 1
			} else {
				let g = Self.gcd(abs(num), abs(den))

				let sign = den < 0 ? -1 : 1

				self.num = sign * num / g
				self.den = sign * den / g
			}
		}

		private static func gcd(_ a: Int, _ b: Int) -> Int {
			b == 0 ? a : gcd(b, a % b)
		}

		var isZero: Bool { num == 0 }
		var isInteger: Bool { den == 1 }
		var intValue: Int { num / den }

		static func + (lhs: Rational, rhs: Rational) -> Rational {
			Rational(lhs.num * rhs.den + rhs.num * lhs.den, lhs.den * rhs.den)
		}

		static func - (lhs: Rational, rhs: Rational) -> Rational {
			Rational(lhs.num * rhs.den - rhs.num * lhs.den, lhs.den * rhs.den)
		}

		static func * (lhs: Rational, rhs: Rational) -> Rational {
			Rational(lhs.num * rhs.num, lhs.den * rhs.den)
		}

		static func / (lhs: Rational, rhs: Rational) -> Rational {
			Rational(lhs.num * rhs.den, lhs.den * rhs.num)
		}
	}

	/// Solves Ax = b for minimum sum of x, where x must be non-negative integers
	/// Returns nil if no solution exists
	public static func solve(matrix: [[Int]], targets: [Int]) -> [Int]? {
		let numRows = matrix.count
		let numCols = matrix[0].count

		// Build augmented matrix [A | I | b] for row reduction
		// We'll track which columns are pivot columns
		var aug: [[Rational]] = matrix.enumerated().map { i, row in
			row.map { Rational($0) } + [Rational(targets[i])]
		}

		var pivotCols: [Int] = []
		var pivotRow = 0

		// Gaussian elimination to reduced row echelon form
		for col in 0 ..< numCols {
			if pivotRow >= numRows {
				break // No more rows to process
			}

			// Find pivot in this column
			var maxRow = pivotRow
			for row in (pivotRow + 1) ..< numRows {
				if !aug[row][col].isZero, aug[maxRow][col].isZero {
					maxRow = row
				}
			}

			if aug[maxRow][col].isZero {
				continue // No pivot in this column, it's a free variable
			}

			// Swap rows
			aug.swapAt(pivotRow, maxRow)

			// Scale pivot row
			let scale = aug[pivotRow][col]
			for j in 0 ... numCols {
				aug[pivotRow][j] = aug[pivotRow][j] / scale
			}

			// Eliminate column in all other rows
			for row in 0 ..< numRows {
				if row != pivotRow, !aug[row][col].isZero {
					let factor = aug[row][col]
					for j in 0 ... numCols {
						aug[row][j] = aug[row][j] - factor * aug[pivotRow][j]
					}
				}
			}

			pivotCols.append(col)
			pivotRow += 1
		}

		// Check for inconsistency (row of form [0 0 ... 0 | nonzero])
		for row in pivotRow ..< numRows {
			if !aug[row][numCols].isZero {
				return nil // No solution
			}
		}

		// Identify free variables (columns without pivots)
		let freeVars = (0 ..< numCols).filter { !pivotCols.contains($0) }

		if freeVars.isEmpty {
			// Unique solution - extract it
			var solution = [Rational](repeating: Rational(0), count: numCols)
			for (i, col) in pivotCols.enumerated() {
				solution[col] = aug[i][numCols]
			}

			// Check if all are non-negative integers
			if solution.allSatisfy({ $0.isInteger && $0.num >= 0 }) {
				return solution.map(\.intValue)
			}
			return nil
		}

		// Multiple solutions - search over free variables
		// Express pivot variables in terms of free variables:
		// x_pivot[i] = aug[i][numCols] - sum(aug[i][freeVar] * x_freeVar)

		// We need bounds for free variables
		// From non-negativity: x_pivot >= 0 and x_free >= 0

		return searchFreeVariables(
			aug: aug,
			pivotCols: pivotCols,
			freeVars: freeVars,
			numCols: numCols
		)
	}

	private static func searchFreeVariables(
		aug: [[Rational]],
		pivotCols: [Int],
		freeVars: [Int],
		numCols: Int
	)
	-> [Int]? {

		// Compute bounds for each free variable
		// With multiple free variables, computing tight independent bounds is complex.
		// We use conservative bounds based on max target values and let pruning handle the rest.

		let maxTarget = (0 ..< pivotCols.count).map { abs(aug[$0][numCols].num) }.max() ?? 1000

		var freeBounds: [(lower: Int, upper: Int)] = []

		for _ in freeVars {
			// Conservative bounds: 0 to max target value
			// The search with pruning will skip invalid combinations
			freeBounds.append((0, min(maxTarget * 2, 500)))
		}

		// Search over all combinations of free variables
		var bestSolution: [Int]? = nil
		var bestSum = Int.max

		func search(freeIndex: Int, freeValues: [Int]) {
			if freeIndex == freeVars.count {
				// Compute full solution
				var solution = [Rational](repeating: Rational(0), count: numCols)

				// Set free variables
				for (i, freeVar) in freeVars.enumerated() {
					solution[freeVar] = Rational(freeValues[i])
				}

				// Compute pivot variables
				for (i, pivotCol) in pivotCols.enumerated() {
					var val = aug[i][numCols]
					for (j, freeVar) in freeVars.enumerated() {
						val = val - aug[i][freeVar] * Rational(freeValues[j])
					}
					solution[pivotCol] = val
				}

				// Check validity and compute sum
				if solution.allSatisfy({ $0.isInteger && $0.num >= 0 }) {
					let sum = solution.reduce(0) { $0 + $1.intValue }
					if sum < bestSum {
						bestSum = sum
						bestSolution = solution.map(\.intValue)
					}
				}
				return
			}

			let (lower, upper) = freeBounds[freeIndex]
			guard lower <= upper else { return } // No valid range

			for val in lower ... upper {
				// Early pruning: check if current partial assignment can still yield valid solution
				var canPrune = false
				let partialFreeValues = freeValues + [val]

				for (i, _) in pivotCols.enumerated() {
					var partialVal = aug[i][numCols]
					for (j, freeVar) in freeVars.enumerated() {
						if j < partialFreeValues.count {
							partialVal = partialVal - aug[i][freeVar] * Rational(partialFreeValues[j])
						}
					}

					// Check if remaining free vars (all set to 0) would give negative
					// and if setting them to max wouldn't help
					var minPossible = partialVal
					var maxPossible = partialVal
					for j in (freeIndex + 1) ..< freeVars.count {
						let freeVar = freeVars[j]
						let coeff = aug[i][freeVar]
						let (lo, hi) = freeBounds[j]
						// contribution ranges from -coeff*hi to -coeff*lo
						if coeff.num > 0 {
							minPossible = minPossible - coeff * Rational(hi)
							maxPossible = maxPossible - coeff * Rational(lo)
						} else {
							minPossible = minPossible - coeff * Rational(lo)
							maxPossible = maxPossible - coeff * Rational(hi)
						}
					}

					// If max possible is still negative, prune this branch
					if maxPossible.num < 0 {
						canPrune = true
						break
					}
				}

				if !canPrune {
					search(freeIndex: freeIndex + 1, freeValues: partialFreeValues)
				}
			}
		}

		search(freeIndex: 0, freeValues: [])
		return bestSolution
	}
}
