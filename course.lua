Course = Object:extend()

local _dottedLine

function Course:new(x, y, hole, width, height, tileSize, customProps, shotCompleteExec, courseCompleteExec)
    self.x = x
    self.y = y
    self.hole = hole
    self.tileWidth = width
    self.tileHeight = height
    self.tileSize = tileSize
    self.shotCompleteExec = shotCompleteExec
    self.courseCompleteExec = courseCompleteExec
    self.lengthInYards = customProps[1].value
    self.par = customProps[2].value

    self.width = width * tileSize
    self.height = height * tileSize
    self.tileImage = love.graphics.newImage("assets/tiles.png")
    self.numTiles = self.tileImage:getWidth() / tileSize
    self.tileObjectImage = love.graphics.newImage("assets/tile_objects.png")
    self.takingShot = false
    self.angleOffset = 0
    self.isComplete = false
    self.angleOffset = 0
    self.angleOffsetTemp = 0

    self.outOfBoundsField = TextField(x + self.width * 0.5, y + self.height * 0.5, "OUT OF BOUNDS", 32, 0.5, 0.5, { 1, 1, 1, 1 }, { 1, 0, 0, 1})
    self.showOutOfBounds = false
    self.outOfBoundsTime = 3
    self.outOfBoundsCur = 0
    self.outOfBoundsShotComplete = nil

    self.quads = {}

    for i = 0, (self.tileImage:getWidth() / self.tileSize) - 1 do
        table.insert(self.quads, love.graphics.newQuad(i * self.tileSize, 0, self.tileSize, self.tileSize, self.tileImage:getWidth(), self.tileImage:getHeight()))
    end

    for i = 0, (self.tileObjectImage:getHeight() / self.tileSize) - 1 do
        for j = 0, (self.tileObjectImage:getWidth() / self.tileSize) - 1 do
            table.insert(self.quads, love.graphics.newQuad(j * self.tileSize, i * self.tileSize, self.tileSize, self.tileSize, self.tileObjectImage:getWidth(), self.tileObjectImage:getHeight()))
        end
    end
end

function Course:update(dt)
    self.ball:update(dt)

    if self.showOutOfBounds then
        if self.outOfBoundsCur < self.outOfBoundsTime then
            self.outOfBoundsCur = self.outOfBoundsCur + dt
        else
            self.showOutOfBounds = false
            self.shotCompleteExec(self.outOfBoundsShotCompleteParams[1], self.outOfBoundsShotCompleteParams[2], self.outOfBoundsShotCompleteParams[3])
        end
    end
end

function Course:draw()
    for i, tile in ipairs(self.tiles) do
        tile:draw()
    end

    for i, tile in ipairs(self.tileObjects) do
        tile:draw()
    end

    if not self.isComplete and not self.showOutOfBounds then
        self.ball:draw()
    end

    if not self.takingShot and not self.showOutOfBounds then
        love.graphics.line(self.ball:getPixelX(), self.ball:getPixelY(), self.targetX + self.x, self.targetY + self.y)
    end

    if self.showOutOfBounds then
        self.outOfBoundsField:draw()
    end
end

function Course:setTileData(tiles)
    self.tiles = { }
    for x = 1, self.tileWidth do
        for y = 1, self.tileHeight do
            local index = (y - 1) * self.tileWidth + x
            if tiles[index] > 0 then
                self.tiles[(y - 1) * self.tileWidth + x] = Tile(self.x + (x - 1) * self.tileSize, self.y + (y - 1) * self.tileSize, self.tileImage, self.quads[tiles[index]], tiles[index])
            end
        end
    end 
end

function Course:setTileObjectData(tiles)
    self.tileObjects = { }
    for x = 1, self.tileWidth do
        for y = 1, self.tileHeight do
            local index = (y - 1) * self.tileWidth + x
            if tiles[index] > 0 then
                table.insert(self.tileObjects, Tile(self.x + (x - 1) * self.tileSize, self.y + (y - 1) * self.tileSize, self.tileObjectImage, self.quads[tiles[index]], tiles[index]))
            end
        end
    end 
end

function Course:setTee(x, y)
    self.teeX = x
    self.teeY = y

    self.ball = Ball(self.teeX, self.teeY, self)
end

function Course:setHole(x, y)
    self.holeX = x
    self.holeY = y
end

function Course:getHole()
    return self.holeX, self.holeY
end

function Course:loadComplete()
    self.pixelsPerYard = math.sqrt((self.teeX - self.holeX) ^ 2 + (self.teeY - self.holeY) ^ 2) / self.lengthInYards
    self.ball:setPixelScale(self.pixelsPerYard)
    self:calculateTarget()
end

function Course:getShotPower()
    return self.shotPower
end

function Course:setShotPower(shotPower)
    self.shotPower = shotPower
    self:calculateTarget()
end

function Course:takeShot(powerMultiplier, errorAngle, windSpeed, isPutt)
    self.takingShot = true
    
    local courseType = self:getCourseType()
    if courseType == Constants.course_rough then
        powerMultiplier = powerMultiplier * 0.8
    end

    self.ball:hit(self.shotPowerInPixels * powerMultiplier, self.angle + errorAngle, windSpeed, isPutt)
end

function Course:calculateTarget()
    local diffX = self.holeX - self.ball.x
    local diffY = self.holeY - self.ball.y
    
    self.distanceToPinInPixels = math.sqrt(diffX ^ 2 + diffY ^ 2)
    self.shotPowerInPixels = self.pixelsPerYard * (self.shotPower or 100)
    
    local angle = math.atan2(-diffY, diffX) + self.angleOffsetTemp
    local targetX = self.ball.x + self.shotPowerInPixels * math.cos(angle)
    local targetY = self.ball.y - self.shotPowerInPixels * math.sin(angle)
    
    if targetX >= 0 and targetX <= self.width and targetY >= 0 and targetY <= self.height then
        self.angle = angle
        self.angleOffset = self.angleOffsetTemp
        self.targetX = targetX
        self.targetY = targetY
    end
end

function Course:getCourseType()
    local courseTileX = math.ceil(self.ball.x / self.tileSize)
    local courseTileY = math.ceil(self.ball.y / self.tileSize)

    return self.tiles[(courseTileY - 1) * self.tileWidth + courseTileX]:getCourseType()
end

function Course:getDistanceToPin()
    return self.distanceToPinInPixels / self.pixelsPerYard
end

function Course:shotComplete(distance, status)
    self.angleOffset = 0
    self.angleOffsetTemp = 0
    self.takingShot = false
    self:calculateTarget(angleOffset)

    if status == Constants.shotComplete_OutOfBounds or status == Constants.shotComplete_Water then
        -- Delay shot complete until warning is shown
        self.outOfBoundsShotCompleteParams = { distance, self.distanceToPinInPixels / self.pixelsPerYard, true }
        self.outOfBoundsField:update(Constants.shotComplete_Messages[status])
        self.showOutOfBounds = true
    else
        self.shotCompleteExec(distance, self.distanceToPinInPixels / self.pixelsPerYard, false)
    end
end

function Course:getShotAngle()
    local angle = self.angle * (180 / math.pi)

    if angle < 0 then
        return angle + 360
    elseif angle > 360 then
        return angle - 360
    else
        return angle
    end
end

function Course:changeShotAngle(angleChange)
    self.angleOffsetTemp = (self.angleOffset - (angleChange * (math.pi / 180))) % (math.pi * 2)
    print("self.angleOffsetTemp = " .. self.angleOffsetTemp)
    self:calculateTarget()
end

function Course:changeShotPower(powerChange)
    self.shotPower = self.shotPower + powerChange
    self:calculateTarget()
end

function Course:complete()
    self.isComplete = true
    self.courseCompleteExec()
end