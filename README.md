# Advent of Code

Why not join the fun 🎄

Links to the solutions:

 * [2023](Sources/Solutions/2023/Days) - work in progress
 * [2022](Sources/Solutions/2022/Days) - finished on 25-12-2022 (runs in 121.72 seconds)
 * [2021](Sources/Solutions/2021/Days) - finished on 25-12-2021 (runs in 33.50 seconds)
 * [2020](Sources/Solutions/2020/Days) - finished on 15-01-2022 (runs in 12.29 seconds)
 * [2019](Sources/Solutions/2019/Days) - finished on 02-02-2022 (runs in 4.71 seconds)
 * [2018](Sources/Solutions/2018/Days) - work in progress; day 1 to 13 finished
 * [2017](Sources/Solutions/2017/Days) - finished on 31-12-2022 (runs in 18.89 seconds)
 * [2016](Sources/Solutions/2016/Days) - finished on 20-11-2022 (runs in 83.53 seconds)
 * [2015](Sources/Solutions/2015/Days) - finished on 20-02-2022 (runs in 4.99 seconds)
 
 Timing is done on a 2021 M1 Pro with 32 GB RAM.
 
# 3rd party frameworks

 * Swift Collections: For the Deque type allowing for faster popping of first elements from collections (vs arrays).
 * Swift-BigInt: for day 22 of 2019.

# Custom Tools

## AsciiString

Manipulating strings in Swift is pretty slow because of unicode support. AsciiString uses one byte per character
and allows for much better performance when accessing elements and iterating characters. For AoC we only need Ascii 
support anyway.

On UInt8 some static vars are available with ascii values for common characters used in AoC.

## String Extensions

- `asAsciiArray` -> [UInt8]: Converts string to ascii values in byte array.
- `allLines(includeEmpty: Bool = false)` -> [String] -> Returns all lines in the String as an array of Strings.
- `parseCommaSeparatedInts(filterInvalid: Bool = true)` -> [Int]: Turns a comma separated integer list into an array of integers.
- `getCapturedValues` -> [String]?: All captures regex values into an array of Strings.

## MD5

In older AoC challenges md5 is often needed.

1. There is the slow `md5AsHex` function available to return a hash as a hex string.
2. `md5AsBytes` is faster as it does not convert the resulting hash to a string but instead returns the raw bytes.

## Predictable Randomness

Use `SeededRandomNumberGenerator` to generate predictable random numbers.

## Direction

Use the `Direction` for north, east, south and west navigation.

- `left` gives the direction when turning 90 degrees left
- `right` gives the direction when turning 90 degrees right
- `opposite` gives the direction when turning 180 degrees

## Point2D

Use the `Point2D` type for storing 2D integer coordinates.

- `x` and `y` are the coordinates
- `moved(to: Direction, steps: Int = 1)` will move the coordinates in the given direction, with the given number of steps.
For example x = 3, y = 5 move to .right with 3 steps will result in x = 6, y = 5.
- `neighbors` will give the four neighboring coordinates of the current Point2D (in the north, east, south, west direction).
- Various operators `+`, `-`, `*`, `+=`, `-=` and `*=` are available.
 
 ## Point3D
 
 Same as `Point3D` but expanded to 3 dimensions: `x`, `y` and `z`.
 
 Currently does not have much more functionality. Can be expanded when needed.
 
 ## HexPoint & HexDirection
 
 A type that supports coordinates and navigation on a grid made out of hexagons.
 
 * `q`, `r` and `s` are the coordinates
 
## Data Structures

### Looped Linked List Set

Generic `LoopedLinkedListSet` is a not yet fully realized (but functional enough) looped linked list for unique values. 
 
### WeightedGraph

A type to store elements and edges of a graph.

### BFS

The BFS type wraps two solvers using the BFS algorithm.

- visitAllElementsInGraph(graph: WeightedGraph, startingAtIndex: Int, returnToStart: Bool) tries to visit all elements in 
a WeightedGraph at least once with the shortest possible path.
- shortestPathInGraph(graph: UnweightedGraph, from a: Int, to b: Int) tries to find the shortest path in a 
graph between two points.
- shortestPathInGraph(graph: WeightedGraph, from a: Int, to b: Int) tries to find the path with the lowest weight
in a graph between two points.
- shortestPathInGrid(grid: some BFSGrid, from: Point2D, to: Point2D) will try to find the shortest possible path
between two points in a 2D grid. It is up to the caller to implement the BFSGrid protocol so that it can provide
available neighbors for a point in the grid.
 
## Array & ArraySlice Extensions

- `mostCommonElement` -> Element: finds most common element in an array
- `leastCommonElement` -> Element: finds the least common element in an array
- `negate` & `negated`: Toggle all boolean elements in a Bool Array
- `combinationsWithoutRepetition(length: Int)` -> [[Element]]: returns all combinations of length elements of an array,
for example `[1,2,3,4,5], length 4` = [[1, 2, 3, 4], [1, 2, 3, 5], [1, 2, 4, 5], [1, 3, 4, 5], [2, 3, 4, 5]]
- `permutations` -> [[Element]]: Returns all permutations of an array using the heap algorithm.
- `subsets(minLength: Int, maxLength: Int)` -> [[Element]]: Returns all subsets of given lengths of an array.
