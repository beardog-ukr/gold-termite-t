local appdef_m = require("src/app_defaults")
local appdef = {}
appdef_m.getAppDefaults(appdef)

local log_m = require '../thirdparty/log_lua-master/log'

local Class = require "../thirdparty/hump.class"

local asdef_m = require("src/app_defaults")
local asdef = {}
asdef_m.getAsteroidDefaults(asdef)

-- ===========================================================================

Asteroid = Class{
  angle = (math.pi/2) ,
  gameAreaX = 0          ,
  gameAreaY = 0          ,
  gameAreaWidth = 0      ,
  gameAreaHeight = 0     ,
  size = 30              ,
  movingTweenHandle = nil ,
  type = 2 ,
}

function Asteroid:init(params)
  self.centerX = params.x
  self.centerY = params.y
  self.angle = params.a
end

-- ============================================================================

local function drawAsteroid(ctx, gameAreaX, gameAreaY)
  local scx = ctx.centerX + gameAreaX -- ship's center X
  local scy = ctx.centerY + gameAreaY -- ship's center Y
  love.graphics.setColor(asdef.mainColor)
  love.graphics.circle("fill", scx, scy, ctx.size)

  local defLineWidth = love.graphics.getLineWidth()
  love.graphics.setLineWidth(ctx.size/5)
  love.graphics.setColor(asdef.secondaryColor)
  love.graphics.arc("fill", scx, scy, ctx.size,
                    ctx.angle + (math.pi/12), ctx.angle - (math.pi/12))
  love.graphics.setLineWidth(defLineWidth)
end

function Asteroid:drawSelf()
  drawAsteroid(self, self.gameAreaX, self.gameAreaY)

  if ((self.centerX) > (self.gameAreaWidth - appdef.maxObjectSize/2)) then
    -- log_m.trace("need more draw at left")
    local xmod = self.gameAreaX - self.centerX - (self.gameAreaWidth - self.centerX)
    drawAsteroid(self, xmod, self.gameAreaY)
  end

  if ((self.centerX) < (appdef.maxObjectSize/2)) then
    -- log_m.trace("need more draw at right")
    local xmod = self.gameAreaX + self.gameAreaWidth
    drawAsteroid(self, xmod, self.gameAreaY)
  end

  if ((self.centerY) > (self.gameAreaHeight - appdef.maxObjectSize/2)) then
    -- log_m.trace("need more draw to down")
    local ymod = self.gameAreaY - self.centerY - (self.gameAreaHeight - self.centerY)
    drawAsteroid(self, self.gameAreaX, ymod)
  end

  if ((self.centerY) < (appdef.maxObjectSize/2)) then
    -- log_m.trace("crossing north border, redraw at south")
    local ymod = self.gameAreaY + self.gameAreaHeight
    drawAsteroid(self, self.gameAreaX, ymod)
  end
end

-- ============================================================================

local function rebalanceCenterCoordinates(ctx)
  if (ctx.centerX < 0) then
    ctx.centerX = ctx.gameAreaWidth + ctx.centerX
  end
  if (ctx.centerY < 0) then
    log_m.trace("rebalanced after north Y")
    ctx.centerY = ctx.gameAreaHeight + ctx.centerY
  end

  if (ctx.centerX > ctx.gameAreaWidth) then
    ctx.centerX = ctx.centerX - ctx.gameAreaWidth
  end
  if (ctx.centerY > ctx.gameAreaHeight) then
    log_m.trace("rebalanced after south Y")
    ctx.centerY = ctx.centerY - ctx.gameAreaHeight
  end
end

function Asteroid:restartMoving(mainTimer)

  rebalanceCenterCoordinates(self)

  local acm = (asdef.moveLeapLength * self.size)
  local acxm = math.cos(self.angle) * acm -- asteroid's center X modifier
  local acym = math.sin(self.angle) * acm -- asteroid's center Y modifier
  local newCX = self.centerX + acxm;
  local newCY = self.centerY + acym;

  local newTimer = mainTimer.tween(asdef.speedInterval, self,
                                   {centerX = newCX, centerY = newCY})
  if (self.movingTweenHandle) then
    mainTimer.cancel(self.movingTweenHandle)
  end
  self.movingTweenHandle = newTimer
end

-- ============================================================================

function Asteroid:setGameArea(x,y, width, height)
  self.gameAreaX = x
  self.gameAreaY = y

  self.gameAreaWidth = width
  self.gameAreaHeight = height
end

-- ============================================================================

local function setupCloneCommon(ctx, clone)
  clone.type = 1 

  clone.gameAreaX = ctx.gameAreaX
  clone.gameAreaY = ctx.gameAreaY 

  clone.gameAreaWidth = ctx.gameAreaWidth
  clone.gameAreaHeight = ctx.gameAreaHeight

  clone.size = ctx.size/2
end

function Asteroid:setupCloneA(clone)
  setupCloneCommon(self, clone)

  clone.angle = self.angle - math.pi/2
  clone.centerX = self.centerX + (math.cos(self.angle) * self.size *0.5)
  clone.centerY = self.centerY + (math.sin(self.angle) * self.size *0.5)
end

function Asteroid:setupCloneB(clone)
  setupCloneCommon(self, clone)

  clone.angle = self.angle + math.pi/2
  local bAngle = self.angle - math.pi
  clone.centerX = self.centerX + (math.cos(bAngle) * self.size *0.5)
  clone.centerY = self.centerY + (math.sin(bAngle) * self.size *0.5)
end
