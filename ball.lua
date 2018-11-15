Ball = Object:extend()

local _shotComplete, _calculateBounce, _calculateRoll

function Ball:new(x, y, courseRef)
    self.x = x
    self.y = y
    self.courseRef = courseRef
    
    self.radius = 5
    self.speedX = 0
    self.speedY = 0
    self.moveTime = 0
    self.moveTimeHalf = 0
    self.ballRadiusChanger = 0
    self.ballRadiusIncreaseDefault = 5
    self.ballRadiusIncrease = 0

    self.defaultMoveTime = 3
    self.initialMoveTime = 2
end

function Ball:update(dt)
    if self.speedX == 0 and self.speedY == 0 then
        return
    end

    if self.moveTime > 0 then
        self.moveTime = self.moveTime - dt
        self.ballRadiusChanger = math.sin((1 - (math.abs(self.moveTimeHalf - self.moveTime) / self.moveTimeHalf)) * math.pi / 2)
    elseif self.moveTime <= 0 and (self.speedX ~= 0 or self.speedY ~= 0) and self.bounces == 0 then
        _calculateBounce(self, self.courseRef:getCourseType(self.x, self.y))
    elseif math.abs(self.speedX) < 1 and math.abs(self.speedY) < 1 then
        _shotComplete(self)
    elseif self.moveTime < 0 then
        _calculateRoll(self, self.courseRef:getCourseType(self.x, self.y))
    end

    self.x = self.x + self.speedX * dt
    self.y = self.y + self.speedY * dt
end

function Ball:draw()
    love.graphics.circle("fill", self.x, self.y, self.radius + self.ballRadiusChanger * self.ballRadiusIncrease)
end


function Ball:setPixelScale(pixelsPerYard)
    self.pixelsPerYard = pixelsPerYard
end

function Ball:getPosX()
    return self.x
end

function Ball:getPosY()
    return self.y
end

function Ball:hit(distance, finalX, finalY)
    self.ballRadiusIncrease = self.ballRadiusIncreaseDefault
    self.shotPower = distance
    self.startX = self.x
    self.startY = self.y
    self.moveTime = self.initialMoveTime
    self.moveTimeHalf = self.moveTime / 2

    self.speedX = (finalX - self.x) / self.moveTime
    self.speedY = (finalY - self.y) / self.moveTime
    self.bounces = 0
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
        self.moveTime = self.initialMoveTime / 4
    elseif courseTypeID == Constants.course_fairway then
        self.ballRadiusIncrease = self.ballRadiusIncrease / 3
        self.speedX = self.speedX * 0.7
        self.speedY = self.speedY * 0.7
        self.moveTime = self.initialMoveTime / 5
    elseif courseTypeID == Constants.course_rough then
        self.ballRadiusIncrease = self.ballRadiusIncrease / 3
        self.speedX = self.speedX * 0.4
        self.speedY = self.speedY * 0.4
        self.moveTime = self.initialMoveTime / 8
    end  -- Sand/Water = no bounce

    self.bounces = 1
end

_calculateRoll = function(self, courseTypeID)
    if courseTypeID == Constants.course_green then
        self.speedX = self.speedX * 0.95
        self.speedY = self.speedY * 0.95
    elseif courseTypeID == Constants.course_fairway then
        self.speedX = self.speedX * 0.92
        self.speedY = self.speedY * 0.92
    else
        self.speedX = 0.1
        self.speedY = 0.1
    end
end