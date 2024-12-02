import strutils
import algorithm
import sequtils

proc splitLocationPairs(locationListPairs:seq[string]): (seq[int], seq[int]) =
  var leftSideList: seq[int]
  var rightSideList: seq[int]
  for pair in locationListPairs:
    let splitPair = pair.split("   ");
    let left = parseInt(splitPair[0])
    let right = parseInt(splitPair[1])
    leftSideList.add(left)
    rightSideList.add(right)
  
  (leftSideList, rightSideList)

proc starOne(filename:string): int =
  let inputData = readFile(filename)

  # Split input data into list of pairs.
  let locationListPairs = inputData.split("\n")

  # Split input data into two lists.
  let splitLists = splitLocationPairs(locationListPairs)
  var leftList = splitLists[0]
  var rightList = splitLists[1]
  
  # Sort the lists from smallest number to largest.
  leftList.sort()
  rightList.sort()
  
  var distanceList: seq[int]
   
  # Get the difference for each pair of numbers.
  for i in 0..<leftList.len:
    distanceList.add(abs(rightList[i] - leftList[i]))

  # Sum up the differences.
  let summedDistances = foldl(distanceList, a + b)
  summedDistances


proc starTwo(filename:string): int =
  let inputData = readFile(filename)
  
  # Split input data into list of pairs.
  let locationListPairs = inputData.split("\n")
  
  # Split input data into two lists.
  let splitLists = splitLocationPairs(locationListPairs)
  var leftList = splitLists[0]
  var rightList = splitLists[1]
  
  # For each item in the left-side list,
  # find the number of times it appears in the right side list 
  # and multiply its value by that. Store that in a list.
  var similarityScoreList: seq[int]  
  
  for i in 0..<leftList.len:
    let leftItem = leftList[i]
    let countInRightList = rightList.filterIt(it == leftItem).len
    similarityScoreList.add(leftItem * countInRightList)

  # Then sum those "similarity scores".
  let summedSimilarities = foldl(similarityScoreList, a + b)
  summedSimilarities



# Main entry point.
echo "Advent of Code 2024, Day 1, Star 1!"
echo "Testing Star One..."
let testStarOne = starOne("data/day1/test.txt")
echo "Star One Test OK? ", testStarOne == 11
echo "Star One on Real Data..."
echo starOne("data/day1/starOneData.txt")
echo "Testing Star Two..."
let testStarTwo = starTwo("data/day1/test.txt")
echo "Star Two Test OK? ", testStarTwo == 31
echo "Star Two on Real Data..."
echo starTwo("data/day1/starOneData.txt")
