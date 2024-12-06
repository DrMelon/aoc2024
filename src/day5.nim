import strutils
import algorithm
import sequtils
import nre
import sugar
import math

type Rule = tuple 
  before: int 
  after: int

type Entry = object 
  entryData: seq[int]
  
proc satisfiesRule(entry:Entry, rule:Rule): bool =
  # Skip this rule if it's irrelevant
  if(not entry.entryData.contains(rule.before) or not entry.entryData.contains(rule.after)): return true
  # Otherwise, find the index of the before and after and see if they're in the right order
  let indexOfBefore = entry.entryData.find(rule.before)
  let indexOfAfter = entry.entryData.find(rule.after)
  indexOfBefore < indexOfAfter
  
proc satisfiesAllRules(entry:Entry, rules:seq[Rule]): bool = 
  if rules.anyIt(not satisfiesRule(entry, it)): return false
  true
    
proc correctWrongEntry(wrongentry:Entry, rules:seq[Rule]): Entry =
  var goodEntry = Entry(entryData:wrongentry.entryData)
  
  goodEntry
  

proc processInputData(inputData:string): (seq[Entry], seq[Rule]) =   
  let splitData = inputData.split("\n\n")
  let rules = collect:
    for data in splitData[0].split("\n"):
      let ruleSplit = data.split("|")
      let rule:Rule = (before: parseInt(ruleSplit[0]), after: parseInt(ruleSplit[1]))
      rule
  let entries = collect: 
    for data in splitData[1].split("\n"):
      let entrySplit = data.split(",")
      let entryData = collect:
        for entryVal in entrySplit: 
          parseInt(entryVal)
      Entry(entryData: entryData)

  (entries, rules)

proc starOne(filename:string): int =
  let inputData = readFile(filename)
  
  let (entries, rules) = processInputData(inputData)
  
  # Data processed, figure out which ones already have the rules in the right order
  # and add their middlemost values together
  var runningCount: int = 0
  for entry in entries:
    if(satisfiesAllRules(entry, rules)):
      runningCount += entry.entryData[ceil((entry.entryData.len - 1)/2).int]
    
  runningCount
  
proc starTwo(filename:string): int =
  let inputData = readFile(filename)
  
  let (entries, rules) = processInputData(inputData)
  
  # Data processed, figure out which ones are incorrect.
  let incorrectEntries = entries.filterIt(not satisfiesAllRules(it, rules))
  
  # Now that we have the incorrect entries, we can use the rules to correct them by reordering elements.
  let fixedEntries = incorrectEntries.mapIt(correctWrongEntry(it, rules))
  
  # Then sum up the center page values again.
  var runningCount: int = 0
  for entry in fixedEntries:
    runningCount += entry.entryData[ceil((entry.entryData.len - 1)/2).int]
    
  runningCount
  


# Main entry point.
echo "Advent of Code 2024, Day 5, Star 1!"
echo "Testing Star One..."
let testStarOne = starOne("data/day5/test.txt")
echo "Star One Test OK? ", testStarOne == 143
echo "Star One on Real Data..."
echo starOne("data/day5/starOneData.txt")
echo "Testing Star Two..."
let testStarTwo = starTwo("data/day5/test.txt")
echo "Star Two Test OK? ", testStarTwo == 123
echo "Star Two on Real Data..."
echo starTwo("data/day5/starOneData.txt")