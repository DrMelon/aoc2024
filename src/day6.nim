import strutils
import algorithm
import sequtils
import nre
import sugar
import math

type GridMap = object 
  Map: seq[int]
  Width: int 
  Height: int 
  StartX: int 
  StartY: int
  
type Direction = enum 
  Up, Right, Down, Left
  
type Guard = object 
  Map: GridMap
  X: int
  Y: int 
  Dir: Direction
  UniqueVisitedTiles: seq[(int, int)]
  UniqueVisitedDirections: seq[Direction]
  FinishedSteps: bool
  InLoop: bool
  
proc GetDxDyForDirection(direction:Direction): (int, int) =
  if(direction == Direction.Up): return (0, -1)
  if(direction == Direction.Right): return (1, 0)
  if(direction == Direction.Down): return (0, 1)
  if(direction == Direction.Left): return (-1, 0)
  
proc TurnRight(direction:Direction): Direction = 
  if(direction == Direction.Up): return Direction.Right
  if(direction == Direction.Right): return Direction.Down 
  if(direction == Direction.Down): return Direction.Left
  if(direction == Direction.Left): return Direction.Up
  

  
proc TwoToOneIndex(x:int, y:int, w:int): int =
  x + (y*w)
  
proc OneToTwoIndex(index:int, w:int): (int,int) =
  let x = (index / w).int 
  let y = index mod w
  (x, y)
  
proc SetTile(map:var GridMap, x:int, y:int, tiledata:int) =
  map.Map[TwoToOneIndex(x, y, map.Width)] = tiledata
  
proc GetTile(map:GridMap, x:int, y:int) : int = 
  let idx = TwoToOneIndex(x, y, map.Width)
  if(x < 0 or x >= map.Width or y < 0 or y >= map.Height):
    return 0
  map.Map[idx]
  
proc ProcessInputDataIntoGridMap(inputData:string): GridMap = 
  let splitData = inputData.split("\n")
  let width = splitData[0].len 
  let height = splitData.len 
  let mapData = newSeq[int](width*height)

  var map = GridMap(Map: mapData, Width: width, Height: height, StartX: 0, StartY: 0)

  for x in 0..<width:
    for y in 0..<height:
      let tileVal = splitData[y][x]
      if(tileVal == '^'):
        map.StartX = x 
        map.StartY = y 
        map.SetTile(x, y, 0)
      if(tileVal == '.'):
        map.SetTile(x, y, 0)
      if(tileVal == '#'):
        map.SetTile(x, y, 1)
  
  map
  
proc GuardStep(guard: var Guard) = 
  # Is there a wall directly in front of us? If so, turn direction to the right.
  var (dx, dy) = GetDxDyForDirection(guard.Dir)
  if(guard.Map.GetTile(guard.X + dx, guard.Y + dy) != 0):
    guard.Dir = TurnRight(guard.Dir)
    return
  # Move along direction.
  guard.X = guard.X + dx 
  guard.Y = guard.Y + dy
  
  # If final position outside map, we're done.
  if(guard.X < 0 or guard.X >= guard.Map.Width):
    guard.FinishedSteps = true
    return 
  if(guard.Y < 0 or guard.Y >= guard.Map.Height):
    guard.FinishedSteps = true 
    return
  
  # Mark tile location if not yet visited.
  if(not guard.UniqueVisitedTiles.contains((guard.X, guard.Y))):
    guard.UniqueVisitedTiles.add((guard.X, guard.Y))
    guard.UniqueVisitedDirections.add(guard.Dir)
  else:
    let idx = guard.UniqueVisitedTiles.find((guard.X, guard.Y))
    if(guard.Dir == guard.UniqueVisitedDirections[idx]):
      guard.InLoop = true

proc starOne(filename:string): int =
  let inputData = readFile(filename)
  
  let map = ProcessInputDataIntoGridMap(inputData)
  var guard = Guard(Map: map, X: map.StartX, Y: map.StartY, Dir: Direction.Up, UniqueVisitedTiles: @[(map.StartX, map.StartY)], UniqueVisitedDirections: @[Direction.Up], FinishedSteps: false)
  
  while(not guard.FinishedSteps):
    guard.GuardStep()
  
  guard.UniqueVisitedTiles.len
  
proc starTwo(filename:string): int =
  let inputData = readFile(filename)
  
  var map = ProcessInputDataIntoGridMap(inputData)
  var testGuard = Guard(Map: map, X: map.StartX, Y: map.StartY, Dir: Direction.Up, UniqueVisitedTiles: @[(map.StartX, map.StartY)], UniqueVisitedDirections: @[Direction.Up], FinishedSteps: false)
  # The Test Guard gives us all *walkable positions* the guard could ever be on. This will speed up our 
  # iteration.
  while(not testGuard.FinishedSteps):
    testGuard.GuardStep()
  
  var loopCount = 0
    
  for i, (x, y) in testGuard.UniqueVisitedTiles:
    # Spawn a guard and place an obstacle at the chosen spot if it isn't already taken
    if(not (map.StartX == x and map.StartY == y)):
      map.SetTile(x, y, 2)
      var guard = Guard(Map: map, X: map.StartX, Y: map.StartY, Dir: Direction.Up, UniqueVisitedTiles: @[(map.StartX, map.StartY)], UniqueVisitedDirections: @[Direction.Up], FinishedSteps: false)
      # Run the simulation, looking for loops.
      # A loop is found when we touch a non-unique tile facing the same way we did first time we touched it
      while(not guard.FinishedSteps and not guard.InLoop):
        guard.GuardStep()
        
          
      # If we found a loop, add this position to the list
      if(guard.InLoop):
        loopCount += 1
        echo (i/testGuard.UniqueVisitedTiles.len)*100, "%, ", loopCount
    
      # Set the map tile back
      map.SetTile(x, y, 0)
  loopCount

# Main entry point.
echo "Advent of Code 2024, Day 6, Star 1!"
echo "Testing Star One..."
let testStarOne = starOne("data/day6/test.txt")
echo "Star One Test OK? ", testStarOne == 41
echo "Star One on Real Data..."
echo starOne("data/day6/starOneData.txt")
echo "Advent of Code 2024, Day 6, Star 2!"
echo "Testing Star Two..."
let testStarTwo = starTwo("data/day6/test.txt")
echo "Star Two Test OK? ", testStarTwo == 6
echo "Star Two on Real Data..."
echo starTwo("data/day6/starOneData.txt")