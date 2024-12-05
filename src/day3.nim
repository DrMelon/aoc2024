import strutils
import algorithm
import sequtils
import nre

proc starOne(filename:string): int =
  let inputData = readFile(filename)
  
  # Scan through data for regex matching mul(X,Y) instructions
  let mulInstructionRegex = re"mul\(([0-9]{1,3}),([0-9]{1,3})\)"
  
  # Using the matches, perform the mul calculations. Use capture groups to pull out the info.
  var mulOperation:seq[int]
  for regexMatch in findIter(inputData, mulInstructionRegex):
    let mulResult = parseInt(regexMatch.captures[0]) * parseInt(regexMatch.captures[1])
    mulOperation.add(mulResult)
  
  # Add them all up
  foldl(mulOperation, a + b)
  
proc starTwo(filename:string): int =
  let inputData = readFile(filename)
  
  # Scan through data for regex matching mul(X,Y) instructions and "don't()" and "do()" instructions
  let multiInstructionRegex = re"(mul\(([0-9]{1,3}),([0-9]{1,3})\))|(don't\(\))|(do\(\))"
  
  # Using the matches, perform the mul calculations. Use capture groups to pull out the info.
  var mulOperation:seq[int]
  var mulEnabled:bool = true
  for regexMatch in findIter(inputData, multiInstructionRegex):
    if(regexMatch.match.contains("mul") and mulEnabled):
      let mulResult = parseInt(regexMatch.captures[1]) * parseInt(regexMatch.captures[2])
      mulOperation.add(mulResult)
    if(regexMatch.match.contains("do()")):
      mulEnabled = true
    if(regexMatch.match.contains("don't()")):
      mulEnabled = false
  
  # Add them all up
  foldl(mulOperation, a + b)


# Main entry point.
echo "Advent of Code 2024, Day 3, Star 1!"
echo "Testing Star One..."
let testStarOne = starOne("data/day3/test.txt")
echo "Star One Test OK? ", testStarOne == 161
echo "Star One on Real Data..."
echo starOne("data/day3/starOneData.txt")
echo "Testing Star Two..."
let testStarTwo = starTwo("data/day3/test2.txt")
echo "Star Two Test OK? ", testStarTwo == 48
echo "Star Two on Real Data..."
echo starTwo("data/day3/starOneData.txt")
