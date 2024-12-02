import strutils
import algorithm
import sequtils

type ReportState = enum 
  unknown, safe, unsafe_baddelta, unsafe_switch

type Report = object 
  values: seq[int]
  state: ReportState
  

proc splitReportList(inputData:string): seq[Report] =
  let reportData = inputData.split("\n")
  var reportList: seq[Report]
  for data in reportData:
    let values = data.split(" ").mapIt(parseInt(it))
    let report = Report(values: values, state: ReportState.unknown)
    reportList.add(report)

  reportList
  
proc evaluateReportSafetyStarOne(report:Report): ReportState =
  # Walk through report values and establish the "direction" of flow.
  var direction = 0
  for i in 0..<report.values.len:
    let curValue = report.values[i]
    if(i < report.values.len - 1):
      let nextValue = report.values[i + 1]
      var newDirection = nextValue - curValue
      if(direction == 0): direction = newDirection
      if(abs(newDirection) > 3 or abs(newDirection) < 1): return ReportState.unsafe_baddelta
      if(newDirection > 0 and direction < 0): return ReportState.unsafe_switch 
      if(newDirection < 0 and direction > 0): return ReportState.unsafe_switch 
      
  ReportState.safe 
  
proc evaluateReportSafetyStarTwo(report:Report): ReportState =
  # If the report is unsafe by star one standards,
  # remove a single value and try again.
  # Do this for all possible values until safety is found.
  
  let reportSafety = evaluateReportSafetyStarOne(report)
  if(reportSafety == ReportState.safe): return ReportState.safe 
  
  for i in 0..<report.values.len:
    # Try with missing value
    var newReport = report
    newReport.values.delete(i)
    let newReportSafety = evaluateReportSafetyStarOne(newReport)
    if(newReportSafety == ReportState.safe): return ReportState.safe 

  # Otherwise fall back to the safety state that would have been reported anyway.    
  return reportSafety

proc starOne(filename:string): int =
  let inputData = readFile(filename)

  # Split input data into list of reports
  var reportList = splitReportList(inputData)
  
  # Evaluate the safety of each report
  for report in reportList.mitems:
    report.state = evaluateReportSafetyStarOne(report)
    
  # Count the number of safe reports 
  let safeCount = reportList.filterIt(it.state == ReportState.safe).len 
  
  safeCount
  
proc starTwo(filename:string): int =
  let inputData = readFile(filename)

  # Split input data into list of reports
  var reportList = splitReportList(inputData)
  
  # Evaluate the safety of each report
  for report in reportList.mitems:
    report.state = evaluateReportSafetyStarTwo(report)
    
  # Count the number of safe reports 
  let safeCount = reportList.filterIt(it.state == ReportState.safe).len 
  
  safeCount
  

# Main entry point.
echo "Advent of Code 2024, Day 2, Star 1!"
echo "Testing Star One..."
let testStarOne = starOne("data/day2/test.txt")
echo "Star One Test OK? ", testStarOne == 2
echo "Star One on Real Data..."
echo starOne("data/day2/starOneData.txt")
echo "Testing Star Two..."
let testStarTwo = starTwo("data/day2/test.txt")
echo "Star Two Test OK? ", testStarTwo == 4
echo "Star Two on Real Data..."
echo starTwo("data/day2/starOneData.txt")
