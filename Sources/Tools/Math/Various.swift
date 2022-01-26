import Foundation

public func sign(_ value: Int) -> Int {
    if value < 0 {
        return -1
    } else if value > 0 {
        return 1
    }

    return 0
}

public func greatestCommonFactor(_ x: Int, _ y: Int) -> Int {
    var a = 0
    var b = max(x, y)
    var r = min(x, y)

    while r != 0 {
        a = b
        b = r

        r = a % b
    }

    return b
}

public func leastCommonMultiplier(for a: Int, and b: Int) -> Int {
    return a / greatestCommonFactor(a, b) * b
}

public func leastCommonMultiplier(for values: [Int]) -> Int {
    let uniqueValues = Array(Set(values))

    guard uniqueValues.count >= 2 else {
        return uniqueValues.first ?? 0
    }

    var currentLcm = leastCommonMultiplier(for: uniqueValues[0], and: uniqueValues[1])

    for value in uniqueValues[2 ..< uniqueValues.count] {
        currentLcm = leastCommonMultiplier(for: currentLcm, and: value)
    }

    return currentLcm
}
