import Foundation
import Tools

final class Day04Solver: DaySolver {
	let dayNumber: Int = 4

	struct Input {
		let passports: [Passport]
	}

	struct Passport {
		enum Item: String, RawRepresentable {
			case ecl
			case pid
			case eyr
			case hcl
			case byr
			case iyr
			case cid
			case hgt
		}

		let items: [Item: String]
	}

	func solvePart1(withInput input: Input) -> Int {
		let requiredItems: [Passport.Item] = [.ecl, .pid, .eyr, .hcl, .byr, .iyr, .hgt]

		let validPassports = input.passports.filter { passport in
			for requiredItem in requiredItems {
				if passport.items.keys.contains(requiredItem) == false {
					return false
				}
			}

			return true
		}

		return validPassports.count
	}

	func solvePart2(withInput input: Input) -> Int {
		let validPassports = input.passports.filter { passport in
			guard
				let byr = Int(passport.items[.byr] ?? "-"),
				let iyr = Int(passport.items[.iyr] ?? "-"),
				let eyr = Int(passport.items[.eyr] ?? "-"),
				let hgt = passport.items[.hgt],
				let hcl = passport.items[.hcl],
				let ecl = passport.items[.ecl],
				let pid = passport.items[.pid],
				(1920 ... 2002).contains(byr),
				(2010 ... 2020).contains(iyr),
				(2020 ... 2030).contains(eyr),
				hcl.count == 7,
				Int(hcl[hcl.index(hcl.startIndex, offsetBy: 1) ..< hcl.endIndex], radix: 16) != nil,
				["amb", "blu", "brn", "gry", "grn", "hzl", "oth"].contains(ecl),
				pid.count == 9,
				Int(pid) != nil
			else {
				return false
			}

			if hgt.hasSuffix("cm") {
				guard
					let length = Int(hgt[hgt.startIndex ..< hgt.index(hgt.endIndex, offsetBy: -2)]),
					(150 ... 193).contains(length)
				else {
					return false
				}
			} else if hgt.hasSuffix("in") {
				guard
					let length = Int(hgt[hgt.startIndex ..< hgt.index(hgt.endIndex, offsetBy: -2)]),
					(59 ... 76).contains(length)
				else {
					return false
				}
			} else {
				return false
			}

			return true
		}

		return validPassports.count
	}

	func parseInput(rawString: String) -> Input {
		let lines = rawString.allLines(includeEmpty: true)

		var passports: [Passport] = []
		var cachedPassportItems: [Passport.Item: String] = [:]
		for line in lines {
			if line.isEmpty {
				passports.append(.init(items: cachedPassportItems))

				cachedPassportItems.removeAll()

				continue
			}

			line.components(separatedBy: .whitespaces).forEach {
				let components = $0.components(separatedBy: ":")

				cachedPassportItems[.init(rawValue: components[0])!] = components[1]
			}
		}

		return .init(passports: passports)
	}
}
