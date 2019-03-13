local function getAppDefaults(ctx)
  ctx.cellSize = 20
  ctx.cellDiscance = 6
  ctx.rowsCount = 25
  ctx.columnsCount = 35

  ctx.largeFrameSize = 40
  ctx.smallFrameSize = 5

  ctx.maxObjectSize = 60

  ctx.gameAreaWidth = ctx.cellSize*ctx.columnsCount + ctx.cellDiscance*(ctx.columnsCount-1)
  ctx.gameAreaHeight = ctx.cellSize*ctx.rowsCount + ctx.cellDiscance*(ctx.rowsCount-1)

  ctx.windowWidth = ctx.gameAreaWidth + ctx.largeFrameSize*2
  ctx.windowHeight = ctx.gameAreaHeight + ctx.largeFrameSize*2

  ctx.palette = {}
  ctx.palette.emptyScreen = {0.5, 0.5, 0.8, 1} --
  ctx.palette.gameAreaBorder = {0.1, 0.1, 0.1, 1}

end

local function getSpaceshipDefaults(ctx)
  ctx.mainColor = {0.1,0.4,0.4,1}
  ctx.secondaryColor = {0.8,0.8,0.8,1}
  ctx.flameColor = {0.8,0.2,0.1,1}
  ctx.speedInterval = 3 -- ... seconds to move to new point
  ctx.moveLeapLength = 2 -- after one keypress ship will move this value multiplied to radius
end

local function getAsteroidDefaults(ctx)
  ctx.mainColor = {0.7,0.7,0.3,1}
  ctx.secondaryColor = {0.5, 0.5, 0.8, 1}
  ctx.speedInterval = 3 -- ... seconds to move to new point
  ctx.moveLeapLength = 1 -- after one keypress ship will move this value multiplied to radius
end

local function getRocketDefaults(ctx)
  ctx.mainColor = {0.8,0.2,0.3,1}
  ctx.speedInterval = 3 -- ... seconds to move to new point
  ctx.moveLeapLength = 6 -- after one keypress ship will move this value multiplied to radius
end

-- ===========================================================================

return {
  getAppDefaults = getAppDefaults,
  getAsteroidDefaults = getAsteroidDefaults,
  getRocketDefaults = getRocketDefaults,
  getSpaceshipDefaults = getSpaceshipDefaults,
}
