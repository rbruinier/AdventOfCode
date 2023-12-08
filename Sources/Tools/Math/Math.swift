import Foundation

public func mod(_ a: Int, _ n: Int) -> Int {
	let r = a % n

	return r >= 0 ? r : r + n
}

public extension Int {
	var sign: Int {
		if self < 0 {
			return -1
		} else if self > 0 {
			return 1
		}

		return 0
	}
}

public extension Int {
	var isPrime: Bool {
		if self <= 1 {
			return false
		}

		if self <= 3 {
			return true
		}

		var i = 2
		while i * i <= self {
			if self % i == 0 {
				return false
			}

			i = i + 1
		}

		return true
	}
}

public enum Math {
	/// Finds the Greatest Common Factor (GCF) of two integers using the Euclidean Algorithm.
	///
	/// The Greatest Common Factor (GCF), also known as the Greatest Common Divisor (GCD), is a mathematical
	/// concept that refers to the largest positive integer that divides two or more numbers without leaving a remainder.
	///
	/// - Parameters:
	///		- x: The first integer.
	///		- y: The second integer.
	///
	/// - Returns: The greatest common factor of the two input integers. If either input is zero, the absolute value of the non-zero input is returned. If both inputs are zero, zero is returned.
	public static func greatestCommonFactor(_ x: Int, _ y: Int) -> Int {
		// Ensure non-negative values for the inputs
		var a = 0
		var b = max(x, y)
		var r = min(x, y)

		// Apply the Euclidean Algorithm to find the GCF
		while r != 0 {
			a = b
			b = r

			// Update variables for the next iteration
			r = a % b
		}

		return b
	}

	/// Calculates the Least Common Multiple (LCM) of two integers.
	///
	/// The Least Common Multiple (LCM) is a mathematical concept that refers to the smallest positive integer that is divisible
	/// by two or more numbers without leaving a remainder. It is also known as the Lowest Common Multiple or Smallest Common
	/// Multiple.
	///
	/// - Parameters:
	///		- a: The first integer.
	///		- b: The second integer.
	///
	/// - Returns: The least common multiple of the two input integers. If either input is zero, the LCM is considered zero. If both inputs are zero, zero is returned.
	public static func leastCommonMultiple(for a: Int, and b: Int) -> Int {
		a / greatestCommonFactor(a, b) * b
	}

	/// Finds the Least Common Multiple (LCM) for an array of integers.
	///
	///	The Least Common Multiple (LCM) is a mathematical concept that refers to the smallest positive integer that is divisible
	/// by two or more numbers without leaving a remainder. It is also known as the Lowest Common Multiple or Smallest Common
	/// Multiple.

	/// - Parameters:
	/// 	- values: An array of integers for which the LCM needs to be calculated.
	///
	/// - Returns: The least common multiple of the input integers. If the array has fewer than two unique values, the first unique value is returned. If the array is empty, 0 is returned.
	public static func leastCommonMultiple(for values: [Int]) -> Int {
		let uniqueValues = Array(Set(values))

		guard uniqueValues.count >= 2 else {
			return uniqueValues.first ?? 0
		}

		// Initialize the current LCM with the LCM of the first two unique values
		var currentLcm = leastCommonMultiple(for: uniqueValues[0], and: uniqueValues[1])

		// Iterate through the remaining unique values in the array and update the current LCM
		for value in uniqueValues[2 ..< uniqueValues.count] {
			currentLcm = leastCommonMultiple(for: currentLcm, and: value)
		}

		return currentLcm
	}

	/// Calculates the sum of divisors (divisor sigma function) for a given integer.
	///
	/// The sum of divisors of a positive integer is the sum of all positive integers that divide the given integer (including 1 and the integer itself).
	///
	/// Source: https://www.geeksforgeeks.org/sum-of-all-proper-divisors-of-a-natural-number/
	/// Source: https://reference.wolfram.com/language/ref/DivisorSigma.html
	///
	/// - Parameters:
	///		- n: The input integer for which the sum of divisors is to be calculated.
	///
	/// - Returns: The sum of divisors of the input integer. If the input is less than or equal to 0, 0 is returned.
	public static func divisorSigma(n: Int) -> Int {
		// Ensure non-negative values for the input
		guard n > 0 else {
			return 0
		}

		var sum = 0

		// Iterate through divisors up to the square root of n
		for i in 1 ... max(1, Int(Double(n).squareRoot())) where n % i == 0 {
			// Add the divisor to the sum
			sum += i

			// If i is not equal to n / i, add the corresponding divisor
			if i != n / i {
				sum += n / i
			}
		}

		return sum
	}
}
