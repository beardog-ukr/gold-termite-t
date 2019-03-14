local defm = require("src/app_defaults")
local ds = {}
defm.getAppDefaults(ds)

local log_m = require '../thirdparty/log_lua-master/log'

local HumpClass = require "../thirdparty/hump.class"

require "src/asteroid"
require "src/rocket"
require "src/spaceship"

-- ===========================================================================

AsteroidsGame = HumpClass{
  spaceship = nil,
  asteroids = {} ,
  rockets = {} ,
  mainTimer = nil,
  asteroidsUpdateTimeAcc = 0,
  gameFinished = false
}

function AsteroidsGame:init()
  self.mainTimer = require "../thirdparty/hump.timer"
  self.spaceship = Spaceship(750, 70, 0)

  local asteroidPositions = { {x=150, y=100, a=-math.pi},
                              {x= 80, y=550, a=math.pi/2}}
  for i=1,#asteroidPositions do
    self.asteroids[i] = Asteroid(asteroidPositions[i])
    self.asteroids[i]:restartMoving(self.mainTimer)
  end
end

-- ===========================================================================

function AsteroidsGame:drawSelf()
  local cww = love.graphics.getWidth(); -- current window width
  local cwh = love.graphics.getHeight();-- current window height

  -- clear screen
  love.graphics.setColor(ds.palette.emptyScreen)
  love.graphics.rectangle("fill", 0, 0, cww, cwh)

  -- draw objects
  self.spaceship:drawSelf()
  for i = 1, #self.asteroids do
    self.asteroids[i]:drawSelf()
  end
  for i = 1, #self.rockets do
    self.rockets[i]:drawSelf()
  end

  -- draw (restore) large borders
  love.graphics.setColor(ds.palette.emptyScreen)
  love.graphics.rectangle("fill", 0, 0, ds.largeFrameSize, cwh)
  love.graphics.rectangle("fill", ds.largeFrameSize + ds.gameAreaWidth, 0,
                          ds.largeFrameSize, cwh)
  love.graphics.rectangle("fill", ds.largeFrameSize, 0,
                          ds.gameAreaWidth, ds.largeFrameSize)
  love.graphics.rectangle("fill", ds.largeFrameSize, ds.largeFrameSize + ds.gameAreaHeight,
                          ds.gameAreaWidth, ds.largeFrameSize)

  --draw smaller borders
  love.graphics.setColor(ds.palette.gameAreaBorder)
  love.graphics.rectangle("fill",
                          ds.largeFrameSize - ds.smallFrameSize, ds.largeFrameSize - ds.smallFrameSize,
                          ds.gameAreaWidth + ds.smallFrameSize*2, ds.smallFrameSize)
  love.graphics.rectangle("fill",
                          ds.largeFrameSize - ds.smallFrameSize, ds.largeFrameSize + ds.gameAreaHeight,
                          ds.gameAreaWidth + ds.smallFrameSize*2, ds.smallFrameSize)
  love.graphics.rectangle("fill",
                          ds.largeFrameSize - ds.smallFrameSize, ds.largeFrameSize,
                          ds.smallFrameSize, ds.gameAreaHeight)
  love.graphics.rectangle("fill",
                          ds.largeFrameSize + ds.gameAreaWidth, ds.largeFrameSize,
                          ds.smallFrameSize, ds.gameAreaHeight)
end

function AsteroidsGame:processKeyPressed(key)
  if (key == "escape") then
    love.event.quit(0)
    return;
  end;

  if (self.gameFinished == true) then
    return
  end;

  if (key == "space") then
    local newIdx = #self.rockets +1
    self.rockets[newIdx] = Rocket(self.spaceship, self.mainTimer)
  else
    self.spaceship:processKeyPressed(key, self.mainTimer)
  end
end

-- ===========================================================================

local function areCirclesIntersecting(aX, aY, aRadius, bX, bY, bRadius)
  return (aX - bX)^2 + (aY - bY)^2 <= (aRadius + bRadius)^2
end

local function checkCrashConflicts(ctx, itemX, y, size)
  local result = false
  for i=1,#ctx.asteroids do
    result = areCirclesIntersecting(ctx.asteroids[i].centerX,
                                    ctx.asteroids[i].centerY,
                                    ctx.asteroids[i].size,
                                    itemX,y,size)
    if (result == true) then
      log_m.trace("Detected conflict with asteroid #" .. i)
      break
    end
  end
  return result
end

local function checkAllCrashConflicts(ctx)
  -- most common case, spaceship in the middle
  local result = checkCrashConflicts(ctx,
                                     ctx.spaceship.centerX, ctx.spaceship.centerY,
                                     ctx.spaceship.size)
  if (result == true) then
    return result
  end;

  -- spaceship over south border moved to north
  if ((ctx.spaceship.centerY) > (ctx.spaceship.gameAreaHeight - ds.maxObjectSize/2)) then
    local ymod = ctx.spaceship.centerY - ctx.spaceship.gameAreaHeight
    log_m.trace("Also check against y=" .. ymod .. " (" .. ctx.spaceship.centerY .. ")")
    result = checkCrashConflicts(ctx,
                                 ctx.spaceship.centerX, ymod,
                                 ctx.spaceship.size)
  end

  if (result == true) then
    return result
  end;

  -- spaceship over north border moved to south
  if ((ctx.spaceship.centerY) < (ds.maxObjectSize/2)) then
    local ymod = ctx.spaceship.centerY + ctx.spaceship.gameAreaHeight
    result = checkCrashConflicts(ctx,
                                 ctx.spaceship.centerX, ymod,
                                 ctx.spaceship.size)
  end

  if (result == true) then
    return result
  end;

  -- spaceship over east border moved to west
  if ((ctx.spaceship.centerX) > (ctx.spaceship.gameAreaWidth - ds.maxObjectSize/2)) then
    local xmod = ctx.spaceship.centerX - ctx.spaceship.gameAreaWidth
    result = checkCrashConflicts(ctx, xmod, ctx.spaceship.centerY, 
                                 ctx.spaceship.size)
  end
  
  if (result == true) then
    return result
  end;

  -- spaceship over west border moved to east
  if ((ctx.spaceship.centerX) < (ds.maxObjectSize/2)) then
    local xmod = ctx.spaceship.centerX + ctx.spaceship.gameAreaWidth
    result = checkCrashConflicts(ctx, xmod, ctx.spaceship.centerY, 
                                 ctx.spaceship.size)
  end
  
  if (result == true) then
    return result
  end;

  return result
end

function AsteroidsGame:processUpdate(diffTime)
  if (self.gameFinished == true) then
    return;
  end

  self.mainTimer.update(diffTime)
  self.asteroidsUpdateTimeAcc = self.asteroidsUpdateTimeAcc + diffTime
  if (self.asteroidsUpdateTimeAcc > 3.5) then
    -- log_m.trace("restarting asteroids")
    for i=1,#self.asteroids do
      self.asteroids[i]:restartMoving(self.mainTimer)
      self.asteroidsUpdateTimeAcc = 0
    end

    local newRockets = {}
    local newRocketsIdx = 1;
    for i=1,#self.rockets do
      if (self.rockets[i].active < 0.05) then
        self.mainTimer.cancel(self.rockets[i].movingTweenHandle)
        self.rockets[i] = nil
        log_m.trace("removed rocket #" .. i)
      else
        newRockets[newRocketsIdx] = self.rockets[i]
        newRocketsIdx = newRocketsIdx +1
      end
    end
    self.rockets = newRockets
  end

  self.gameFinished = checkAllCrashConflicts(self)
  if (self.gameFinished == true) then
    log_m.trace("Game over, stopping timer")
    self.mainTimer:clear()
  end
end

-- ===========================================================================

function AsteroidsGame:setGameArea(x,y, width, height)
  self.spaceship:setGameArea(ds.largeFrameSize, ds.largeFrameSize,
                             ds.gameAreaWidth, ds.gameAreaHeight)
  for i = 1, #self.asteroids do
    self.asteroids[i]:setGameArea(ds.largeFrameSize, ds.largeFrameSize,
                                  ds.gameAreaWidth, ds.gameAreaHeight)
  end
end
