local appdef_m = require("src/app_defaults")
local appdef = {}
appdef_m.getAppDefaults(appdef)

local log_m = require '../thirdparty/log_lua-master/log'

local Class = require "../thirdparty/hump.class"

local ssdef_m = require("src/app_defaults")
local ssdef = {}
ssdef_m.getSpaceshipDefaults(ssdef)

-- ===========================================================================

local sskb = {} -- spaceship key bindings
sskb.kGo = "w"
sskb.kFire = "space"
sskb.kLeft = "a"
sskb.kRight = "d"

-- ===========================================================================

Spaceship = Class{
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
  flagIsMoving = 0
}

-- ============================================================================

local function startMove(ctx, mainTimer)
  ctx.flagIsMoving = 1

  local scm = (ssdef.moveLeapLength * ctx.size)
  local scxm = math.cos(ctx.angle) * scm -- ship's center X modifier
  local scym = math.sin(ctx.angle) * scm -- ship's center Y modifier
  local newCX = ctx.centerX + scxm;
  local newCY = ctx.centerY + scym;

  local newTimer = mainTimer.tween(ssdef.speedInterval, ctx,
                                   {centerX = newCX, centerY = newCY, flagIsMoving = 0})
  if (ctx.movingTweenHandle) then
    mainTimer.cancel(ctx.movingTweenHandle)
  end
  ctx.movingTweenHandle = newTimer
end

function Spaceship:processKeyPressed(keyPressed, mainTimer)
  if (sskb.kGo == keyPressed) then
    -- log_m.trace("will do move ")
    startMove(self, mainTimer)
  elseif (sskb.kLeft == keyPressed) then
    self.angle = self.angle - (math.pi/10)
  elseif (sskb.kRight == keyPressed) then
    self.angle = self.angle + (math.pi/10)

  end
end

-- ============================================================================

local function drawSpaceShip(ctx, gameAreaX, gameAreaY)
  local scx = ctx.centerX + gameAreaX -- ship's center X
  local scy = ctx.centerY + gameAreaY -- ship's center Y
  love.graphics.setColor(ssdef.mainColor)
  love.graphics.circle("fill", scx, scy, ctx.size)

  local wrm = ctx.size*0.6
  local wcmx = math.cos(ctx.angle) * wrm
  local wcmy = math.sin(ctx.angle) * wrm
  love.graphics.setColor(ssdef.secondaryColor)
  love.graphics.circle("fill", scx + wcmx, scy + wcmy, ctx.size/5)

  if (ctx.flagIsMoving > 0.01) then
        -- log_m.trace("mf =  " .. self.flagIsMoving)
    local defLineWidth = love.graphics.getLineWidth()
    love.graphics.setLineWidth(ctx.size/5)
    love.graphics.setColor(ssdef.flameColor)
    love.graphics.arc("fill", scx, scy, ctx.size,
                      ctx.angle + (math.pi*1.25), ctx.angle + (math.pi*0.75))
    love.graphics.setLineWidth(defLineWidth)
  end
end

function Spaceship:drawSelf()
  drawSpaceShip(self, self.gameAreaX, self.gameAreaY)

  if ((self.centerX) > (self.gameAreaWidth - appdef.maxObjectSize/2)) then
    -- log_m.trace("need more draw at left")
    local xmod = self.gameAreaX - self.centerX - (self.gameAreaWidth - self.centerX)
    drawSpaceShip(self, xmod, self.gameAreaY)
  end

  if ((self.centerX) < (appdef.maxObjectSize/2)) then
    -- log_m.trace("need more draw at right")
    local xmod = self.gameAreaX + self.gameAreaWidth
    drawSpaceShip(self, xmod, self.gameAreaY)
  end

  if ((self.centerY) > (self.gameAreaHeight - appdef.maxObjectSize/2)) then
    -- log_m.trace("need more draw to down")
    local ymod = self.gameAreaY - self.centerY - (self.gameAreaHeight - self.centerY)
    drawSpaceShip(self, self.gameAreaX, ymod)
  end

  if ((self.centerY) < (appdef.maxObjectSize/2)) then
    -- log_m.trace("need more draw to up")
    local ymod = self.gameAreaY + self.gameAreaHeight
    drawSpaceShip(self, self.gameAreaX, ymod)
  end
end

-- ============================================================================

function Spaceship:setGameArea(x,y, width, height)
  self.gameAreaX = x
  self.gameAreaY = y

  self.gameAreaWidth = width
  self.gameAreaHeight = height
end
