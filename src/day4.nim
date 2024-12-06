import strutils
import algorithm
import sequtils
import nre

proc indexIntoStringListAs2D(stringList:seq[string], x:int, y:int, width:int, height:int): char =
  if(x < 0 or x >= width): return '_'
  if(y < 0 or y >= height): return '_'
  stringList[y][x]
  
proc walkToFindMAS(stringList:seq[string], startx:int, starty:int, width:int, height:int, dx:int, dy:int): bool = 
  indexIntoStringListAs2D(stringList, startx + dx, starty + dy, width, height) == 'M' and 
  indexIntoStringListAs2D(stringList, startx + (dx * 2), starty + (dy * 2), width, height) == 'A' and
  indexIntoStringListAs2D(stringList, startx + (dx * 3), starty + (dy * 3), width, height) == 'S'
  
proc isCenterOfX_MAS(stringList:seq[string], startx:int, starty:int, width:int, height:int): bool = 
  # Four possible configurations of X_MAS:
  # M S  M M  S S  S M
  #  A    A    A    A
  # M S  S S  M M  S M
  
  (walkToFindMAS(stringList, startx - 2, starty - 2, width, height, 1, 1) and walkToFindMAS(stringList, startx - 2, starty + 2, width, height, 1, -1)) or
  (walkToFindMAS(stringList, startx - 2, starty - 2, width, height, 1, 1) and walkToFindMAS(stringList, startx + 2, starty - 2, width, height, -1, 1)) or
  (walkToFindMAS(stringList, startx + 2, starty + 2, width, height, -1, -1) and walkToFindMAS(stringList, startx + 2, starty - 2, width, height, -1, 1)) or
  (walkToFindMAS(stringList, startx + 2, starty + 2, width, height, -1, -1) and walkToFindMAS(stringList, startx - 2, starty + 2, width, height, 1, -1))
  

proc starOne(filename:string): int =
  let inputData = readFile(filename)
  
  # Interpret the input data as a list of strings
  let stringList = inputData.split("\n")
  
  # Then we can use this list of strings like a 2D array and perform our wordsearch.
  # Go line by line, looking for X's. Then, whenever we find an X, we can walk along its neighbours to find all the XMAS's.
  var xmasCount = 0
  let width = stringList[0].len 
  let height = stringList.len 
  for y in 0 .. height:
    for x in 0 .. width:
      let curChar = indexIntoStringListAs2D(stringList, x, y, width, height)
      if(curChar == 'X'):
        # Found an X! Time to find MASes.
        if(walkToFindMAS(stringList, x, y, width, height, 0, 1)): xmasCount += 1 # Down
        if(walkToFindMAS(stringList, x, y, width, height, 0, -1)): xmasCount += 1 # Up
        if(walkToFindMAS(stringList, x, y, width, height, 1, 0)): xmasCount += 1 # Right
        if(walkToFindMAS(stringList, x, y, width, height, -1, 0)): xmasCount += 1 # Left
        if(walkToFindMAS(stringList, x, y, width, height, 1, 1)): xmasCount += 1 # DownRight
        if(walkToFindMAS(stringList, x, y, width, height, -1, 1)): xmasCount += 1 # DownLeft
        if(walkToFindMAS(stringList, x, y, width, height, 1, -1)): xmasCount += 1 # UpRight
        if(walkToFindMAS(stringList, x, y, width, height, -1, -1)): xmasCount += 1 # UpLeft
  
  return xmasCount
  
proc starTwo(filename:string): int =
  let inputData = readFile(filename)
  
  # Interpret the input data as a list of strings
  let stringList = inputData.split("\n")
  
  # Then we can use this list of strings like a 2D array and perform our wordsearch.
  # Go line by line, looking for X's. Then, whenever we find an X, we can walk along its neighbours to find all the XMAS's.
  var xmasCount = 0
  let width = stringList[0].len 
  let height = stringList.len 
  for y in 0 .. height:
    for x in 0 .. width:
      let curChar = indexIntoStringListAs2D(stringList, x, y, width, height)
      if(curChar == 'A'):
        # Found an A! Time to find X_MASes!
        if(isCenterOfX_MAS(stringList, x, y, width, height)): xmasCount += 1
        
  return xmasCount

# Main entry point.
echo "Advent of Code 2024, Day 4, Star 1!"
echo "Testing Star One..."
let testStarOne = starOne("data/day4/test.txt")
echo "Star One Test OK? ", testStarOne == 18
echo "Star One on Real Data..."
echo starOne("data/day4/starOneData.txt")
echo "Testing Star Two..."
let testStarTwo = starTwo("data/day4/test.txt")
echo "Star Two Test OK? ", testStarTwo == 9
echo "Star Two on Real Data..."
echo starTwo("data/day4/starOneData.txt")
