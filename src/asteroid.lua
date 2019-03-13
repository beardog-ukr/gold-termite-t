local appdef_m = require("src/app_defaults")
local appdef = {}
appdef_m.getAppDefaults(appdef)

local log_m = require '../thirdparty/log_lua-master/log'

local Class = require "../thirdparty/hump.class"

local asdef_m = require("src/app_defaults")
local asdef = {}
asdef_m.getSpaceshipDefaults(asdef)

-- ===========================================================================

Asteroid = Class{
  init = function(self, x,y)
    self.centerX = x
    self.centerY = y
  end,
  angle = (math.pi/2) ,
  gameAreaX = 0          ,
  gameAreaY = 0          ,
  gameAreaWidth = 0      ,
  gameAreaHeight = 0     ,
  size = 30              ,
  movingTweenHandle = nil ,
}

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
end

-- ============================================================================

function Asteroid:setGameArea(x,y, width, height)
  self.gameAreaX = x
  self.gameAreaY = y

  self.gameAreaWidth = width
  self.gameAreaHeight = height
end
