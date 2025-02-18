local Maze = require "maze"
local priorityqueue = require "maze.solvers.PriorityQueue"
_ENV = nil

--[[ return correct function based on mode selected ]]--
local function heuristics(mode)
  if mode == 'manhattan' then return manhattanDistance
  elseif mode == 'diagonal' then return diagonalDistance
  end
end

--[[ scan to search adjacent nodes ]]--
function nodeScan(maze, node)
  local neighbornodes = {}
  local directions = maze.directions
  x, y = maze:GetCoord(node)
  walls = maze.walls(node)
  
  for direction, wall in pairs(walls) do
    if wall:IsOpened() then
      table.insert(neighbornodes, maze[y + directions[direction]['y']][x + directions[direction]['x']])
    end
  end
  
  return neighbornodes
end

function diagonalDistance(...)
  local arg = {...}

  assert(#arg == 2)

  x = arg[1]
  y = arg[2]
  
  return 100 - math.sqrt(((x-17)^2)+((y-19)^2))
end

function manhattanDistance(...)
  local arg = {...}

  assert(#arg == 2)

  x = arg[1]
  y = arg[2]

  return 100 - math.abs(x-17) + math.abs(y-19)
end

function nodeInside(set, node)
  for _, el in pairs(set) do
    if el == node then return true end
  end

  return false
end

function generateFullPath(cameFrom)
  for _, n in pairs(cameFrom) do
    n.visited = true
  end
end

function run(maze, x, y, heuristic)
  local open = priorityqueue.new()
  local closed = {}
  local cameFrom = {}
  local gScore = {}
  local fScore = {}

  maze[x][y].visited = true
  gScore[maze[x][y]] = 0
  fScore[maze[x][y]] = heuristic(x, y)
  open:Add(maze[x][y], heuristic(x, y))

  while not open:Empty() do
    current, _ = open:Pop()

    if current.south:IsExit() then 
      table.insert(cameFrom, current)
      return cameFrom, true
    end

    table.insert(closed, current)

    for _, node in pairs(nodeScan(maze, current)) do

      gScore_att = gScore[current] + 1
      if nodeInside(closed, node) then goto continue end

      if not open:Search(node) then open:Add(node, heuristic(maze:GetCoord(node))) 
      elseif gScore_att >= gScore[node] then goto continue
      end
        
      table.insert(cameFrom, current)
      gScore[node] = gScore[current]
      fScore[node] = gScore[node] + heuristic(maze:GetCoord(node))

      ::continue::
    end
  end
  print('There is no exit!')
  return cameFrom, false 
end

function astar(maze, x, y, mode)
  assert(mode == 'manhattan' or 'diagonal')
  return run(maze, x, y, heuristics(mode))
end

return astar
