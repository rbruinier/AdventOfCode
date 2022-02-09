import Foundation
import Tools

final class Day11Solver: DaySolver {
    let dayNumber: Int = 11

    private var input: Input!

    private struct Input {
        let password: String
    }

    func isValid(password: [UInt8]) -> Bool {
        var containsIncrementalSet = false
        
        var incrementCount = 0
        
        var foundPairs: Set<UInt8> = []
        
        guard password.contains { invalidCharacters.contains($0) } == false else {
            return false
        }
        
        for index in 1 ..< 8 {
            /*
             - Passwords must include one increasing straight of at least three letters, like abc, bcd, cde, and so on, up to xyz. They cannot skip letters; abd doesn't count.
             - Passwords may not contain the letters i, o, or l, as these letters can be mistaken for other characters and are therefore confusing.
             - Passwords must contain at least two different, non-overlapping pairs of letters, like aa, bb, or zz.
             */
            
            if password[index] == password[index - 1] + 1 {
                incrementCount += 1
            } else {
                incrementCount = 0
            }
            
            if incrementCount == 2 {
                containsIncrementalSet = true
            }
            
            if password[index] == password[index - 1] {
                foundPairs.insert(password[index])
            }
        }
        
        return containsIncrementalSet && foundPairs.count >= 2
    }

    private let invalidCharacters: [UInt8] = [105, 108, 111]

    func increment(password: [UInt8]) -> [UInt8] {
        let a: UInt8 = 97
        let z: UInt8 = 122
                
        var result = password
        
        for index in (0 ..< 8).reversed() {
            let newValue = password[index] + 1
            
            if invalidCharacters.contains(newValue) {
                result[index] = newValue + 1
                
                break
            } else if newValue > z {
                result[index] = a
            } else {
                result[index] = newValue
                
                break
            }
        }
        
        return result
    }
    
    private var cachedPart1Password: String!
    
    func solvePart1() -> Any {
        var password: [UInt8] = input.password.map { $0.asciiValue! }
        
        while true {
            if isValid(password: password) {
                break
            }
            
            password = increment(password: password)
        }
        
        cachedPart1Password = password.map { String(Character(.init($0))) }.joined()
        
        return cachedPart1Password!
    }

    func solvePart2() -> Any {
        var password: [UInt8] = cachedPart1Password.map { $0.asciiValue! }
        
        password = increment(password: password)

        while true {
            if isValid(password: password) {
                break
            }
            
            password = increment(password: password)
        }
        
        return password.map { String(Character(.init($0))) }.joined()
    }

    func parseInput(rawString: String) {
        input = .init(password: rawString.allLines().first!)
    }
}
