Ball = Object:extend()

local _shotComplete, _calculateBounce, _calculateRoll, _getTarget, _checkForHole, _getMinMoveTime, _isOutOfBounds, _calculateWaterHazardPosition

function Ball:new(x, y, courseRef)
    self.courseX = courseRef.x
    self.courseY = courseRef.y
    self.x = x
    self.y = y
    self.courseRef = courseRef
    self.holeX, self.holeY = courseRef:getHole()
    
    self.radius = 5
    self.speedX = 0
    self.speedY = 0
    self.moveTime = 0
    self.moveTimeHalf = 0
    self.ballRadiusChanger = 0
    self.ballRadiusIncreaseDefault = 5
    self.ballRadiusIncrease = 0

    self.previousX = 0
    self.previousY = 0

    self.roll_Green = 0.96
    self.roll_Fairway = 0.93

    self.minMoveTime = 1    -- 1s for 100yards
end

function Ball:update(dt)
    if not self.takingShot then
        return
    end

    -- IN THE AIR
    if self.moveTime > 0 then
        self.moveTime = self.moveTime - dt
        self.speedX = self.speedX + dt * 4 * self.windSpeed -- calculate wind

        if not self.isPutt then
            self.ballRadiusChanger = math.sin((1 - (math.abs(self.moveTimeHalf - self.moveTime) / self.moveTimeHalf)) * math.pi / 2)
        end

    -- BOUNCE
    elseif self.moveTime <= 0 and (self.speedX ~= 0 or self.speedY ~= 0) and self.bounces == 0 then
        _calculateBounce(self, self.courseRef:getCourseType())

    -- SHOT COMPLETE
    elseif math.abs(self.speedX) < 1 and math.abs(self.speedY) < 1 then
        _shotComplete(self, Constants.shotComplete)

    -- ROLL
    elseif self.moveTime < 0 then
        _calculateRoll(self, self.courseRef:getCourseType(), dt)
    end


    if _isOutOfBounds(self) then
        _shotComplete(self, Constants.shotComplete_OutOfBounds)
    end

    self.x = self.x + self.speedX * dt
    self.y = self.y + self.speedY * dt

    _checkForHole(self)
end

function Ball:draw()
    love.graphics.circle("fill", self.courseRef.x + self.x, self.courseRef.y + self.y, self.radius + self.ballRadiusChanger * self.ballRadiusIncrease)
end

function Ball:getPixelX()
    return self.x + self.courseRef.x
end

function Ball:getPixelY()
    return self.y + self.courseRef.y
end

function Ball:setPixelScale(pixelsPerYard)
    self.pixelsPerYard = pixelsPerYard
end

function Ball:hit(distance, angle, windSpeed, isPutt)
    if isPutt then
        soundEffect:playPutt()
    else
        soundEffect:playSwing()
    end

    self.isPutt = isPutt
    self.windSpeed = windSpeed

    if isPutt then
        self.bounces = 1
        self.moveTime = -1
    else
        self.ballRadiusIncrease = self.ballRadiusIncreaseDefault
        self.moveTime = _getMinMoveTime(self, distance)
        self.moveTimeHalf = self.moveTime / 2
        self.bounces = 0
    end
    
    self.shotPower = distance
    self.startX = self.x
    self.startY = self.y

    local finalX, finalY = _getTarget(self, distance, angle)

    if isPutt then
        self.speedX = 1.1 * distance * math.cos(angle)
        self.speedY = -1.1 * distance * math.sin(angle)
    else
        self.speedX = (finalX - self.x) / self.moveTime
        self.speedY = (finalY - self.y) / self.moveTime
    end

    self.hitSpeedX = self.speedX
    self.hitSpeedY = self.speedY
    self.takingShot = true
end

_getMinMoveTime = function(self, distance)
    local moveTime = (distance / 100) * self.minMoveTime

    if moveTime < 1 then
        return 1
    elseif moveTime > 3 then
        return 3
    else
        return moveTime
    end
end

_shotComplete = function(self, status)
    if status == Constants.shotComplete_OutOfBounds then
        self.x = self.startX
        self.y = self.startY
        self.shotDistance = 0
    elseif status == Constants.shotComplete_Water then
        soundEffect:playSplash()
        _calculateWaterHazardPosition(self)
        self.shotDistance = 0
    else
        self.shotDistance = math.sqrt((self.x - self.startX) ^ 2 + (self.y - self.startY) ^ 2) / self.pixelsPerYard
    end

    self.speedX = 0
    self.speedY = 0
    self.moveTime = 0
    self.moveTimeHalf = 0
    self.ballRadiusChanger = 0

    self.courseRef:shotComplete(self.shotDistance, status)
    self.takingShot = false
end

_calculateWaterHazardPosition = function(self)
    local numLoops = 0
    while (self.courseRef:getCourseType() == Constants.course_water and numLoops < 1000) do
        self.x = self.x - self.speedX * 0.01
        self.y = self.y - self.speedY * 0.01
        numLoops = numLoops + 1
    end

    self.y = self.y + 3
end

_calculateBounce = function(self, courseTypeID)
    if courseTypeID == Constants.course_green then
        self.ballRadiusIncrease = self.ballRadiusIncrease / 2
        self.speedX = self.speedX * 0.8
        self.speedY = self.speedY * 0.8
        self.moveTime = self.minMoveTime / 4
    elseif courseTypeID == Constants.course_fairway then
        self.ballRadiusIncrease = self.ballRadiusIncrease / 3
        self.speedX = self.speedX * 0.7
        self.speedY = self.speedY * 0.7
        self.moveTime = self.minMoveTime / 5
    elseif courseTypeID == Constants.course_rough then
        self.ballRadiusIncrease = self.ballRadiusIncrease / 4
        self.speedX = self.speedX * 0.4
        self.speedY = self.speedY * 0.4
        self.moveTime = self.minMoveTime / 8
    elseif courseTypeID == Constants.course_water then
        _shotComplete(self, Constants.shotComplete_Water)
    end  -- Sand/Water = no bounce

    self.hitSpeedX = self.speedX
    self.hitSpeedY = self.speedY
    self.bounces = 1
end

_calculateRoll = function(self, courseTypeID, dt)
    if courseTypeID == Constants.course_green then
        self.speedX = self.speedX - Ext.min(0.7 * dt * self.hitSpeedX, self.speedX)
        self.speedY = self.speedY - Ext.min(0.7 * dt * self.hitSpeedY, self.speedY)
    elseif courseTypeID == Constants.course_fairway then
        self.speedX = self.speedX - Ext.min(dt * self.hitSpeedX, self.speedX)
        self.speedY = self.speedY - Ext.min(dt * self.hitSpeedY, self.speedY)
    elseif courseTypeID == Constants.course_water then
        _shotComplete(self, Constants.shotComplete_Water)
    else
        self.speedX = 0.1
        self.speedY = 0.1
    end
end

_getTarget = function(self, distance, angle)
    local targetX = self.x + distance * math.cos(angle)
    local targetY = self.y - distance * math.sin(angle)
    return targetX, targetY
end

_checkForHole = function(self)
    local isOverHole = self.x >= self.holeX - 6 and self.x <= self.holeX + 6 and self.y >= self.holeY - 4 and self.y <= self.holeY + 4
    local isInAir = self.ballRadiusChanger > 0  -- This can be for a hit or a bounce, but it's above ground
    local speed = math.sqrt(self.speedX ^ 2 + self.speedY ^ 2)
    local isTooFast = self.isPutt and speed > 50 or speed > 25

    if isOverHole and not isInAir and not isTooFast then
        self.courseRef:complete()
    elseif isOverHole and self.ballRadiusChanger < 0.1 and not self.isPutt then
        self.speedX = -self.speedX * 0.5
        self.speedY = -self.speedY * 0.5
        self.hitSpeedX = self.speedX
        self.hitSpeedY = self.speedY
    end
end

_isOutOfBounds = function(self)
    if self.x < 0 or self.x > self.courseRef.width or self.y < 0 or self.y > self.courseRef.height then -- Out of course
        return true
    else
        return false
    end
end