Ball = Object:extend()

local _shotComplete, _calculateBounce, _calculateRoll, _getTarget, _checkForHole, _getMinMoveTime

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

    self.roll_Green = 0.96
    self.roll_Fairway = 0.93

    self.minMoveTime = 1    -- 1s for 100yards
end

function Ball:update(dt)
    if self.speedX == 0 and self.speedY == 0 then
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
        _calculateBounce(self, self.courseRef:getCourseType(self.x, self.y))

    -- SHOT COMPLETE
    elseif math.abs(self.speedX) < 1 and math.abs(self.speedY) < 1 then
        _shotComplete(self)

    -- ROLL
    elseif self.moveTime < 0 then
        print("rolling", self.x, self.y)
        local courseType = self.courseRef:getCourseType(self.x, self.y)
        _calculateRoll(self, courseType, dt)
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
    self.isPutt = isPutt
    self.windSpeed = windSpeed

    if isPutt then
        self.bounces = 1
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
        self.speedX = distance * math.cos(angle)
        self.speedY = -distance * math.sin(angle)
    else
        self.speedX = (finalX - self.x) / self.moveTime
        self.speedY = (finalY - self.y) / self.moveTime
    end

    self.hitSpeedX = self.speedX
    self.hitSpeedY = self.speedY
end

_getMinMoveTime = function(self, distance)
    local moveTime = (distance / 100) * self.minMoveTime

    if moveTime < 1 then
        return 1
    elseif moveTime > 2 then
        return moveTime
    else
        return moveTime
    end
end

_shotComplete = function(self)
    self.speedX = 0
    self.speedY = 0
    self.moveTimeHalf = 0
    
    self.shotDistance = math.sqrt((self.x - self.startX) ^ 2 + (self.y - self.startY) ^ 2) / self.pixelsPerYard
    self.courseRef:shotComplete(self.shotDistance)
end

_calculateBounce = function(self, courseTypeID)
    if courseTypeID == Constants.course_green then
        self.ballRadiusIncrease = self.ballRadiusIncrease / 2.5
        self.speedX = self.speedX * 0.7
        self.speedY = self.speedY * 0.7
        self.moveTime = self.minMoveTime / 4
    elseif courseTypeID == Constants.course_fairway then
        self.ballRadiusIncrease = self.ballRadiusIncrease / 3
        self.speedX = self.speedX * 0.7
        self.speedY = self.speedY * 0.7
        self.moveTime = self.minMoveTime / 5
    elseif courseTypeID == Constants.course_rough then
        self.ballRadiusIncrease = self.ballRadiusIncrease / 3
        self.speedX = self.speedX * 0.4
        self.speedY = self.speedY * 0.4
        self.moveTime = self.minMoveTime / 8
    end  -- Sand/Water = no bounce

    self.hitSpeedX = self.speedX
    self.hitSpeedY = self.speedY
    self.bounces = 1
end

_calculateRoll = function(self, courseTypeID, dt)
    if courseTypeID == Constants.course_green then
        self.speedX = self.speedX - 0.5 * dt * self.hitSpeedX
        self.speedY = self.speedY - 0.5 * dt * self.hitSpeedY
        print(self.speedX, self.speedY)
    elseif courseTypeID == Constants.course_fairway then
        self.speedX = self.speedX - dt * self.hitSpeedX
        self.speedY = self.speedY - dt * self.hitSpeedY
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
    local isTooFast = self.isPutt and speed > 40 or speed > 20 

    if isOverHole and not isInAir and not isTooFast then
        self.courseRef:complete()
    elseif isOverHole and self.ballRadiusChanger < 0.1 then
        self.speedX = -self.speedX * 0.5
        self.speedY = -self.speedY * 0.5
        self.hitSpeedX = self.speedX
        self.hitSpeedY = self.speedY
    end
end