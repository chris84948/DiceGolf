Course = Object:extend()

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
end

function Course:draw()
    for i, tile in ipairs(self.tiles) do
        tile:draw()
    end

    for i, tile in ipairs(self.tileObjects) do
        tile:draw()
    end

    if not self.isComplete then
        self.ball:draw()
    end

    if not self.takingShot then
        love.graphics.line(self.ball.x, self.ball.y, self.targetX, self.targetY)
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
    self.teeX = self.x + x
    self.teeY = self.y + y

    self.ball = Ball(self.teeX, self.teeY, self)
end

function Course:setHole(x, y)
    self.holeX = self.x + x
    self.holeY = self.y + y
end

function Course:getHole()
    return self.holeX, self.holeY
end

function Course:loadComplete()
    self.pixelsPerYard = math.sqrt((self.teeX - self.holeX) ^ 2 + (self.teeY - self.holeY) ^ 2) / self.lengthInYards
    self.ball:setPixelScale(self.pixelsPerYard)
end

function Course:getShotPower()
    return self.shotPower
end

function Course:setShotPower(shotPower)
    self.shotPower = shotPower
    self:calculateTarget()
end

function Course:changeShotPower(powerDifference)
    self.setShotPower(self.shotPower + powerDifference)
end

function Course:takeShot(powerMultiplier, errorAngle, isPutt)
    self.takingShot = true
    self.ball:hit(self.shotPowerInPixels * powerMultiplier, self.angle + errorAngle, isPutt)
end

function Course:calculateTarget()
    local diffX = self.holeX - self.ball.x
    local diffY = self.holeY - self.ball.y
    
    self.distanceToPin = math.sqrt(diffX ^ 2 + diffY ^ 2)
    self.shotPowerInPixels = self.pixelsPerYard * self.shotPower
    self.angle = math.atan2(-diffY, diffX) + self.angleOffset

    local targetX = self.ball.x + self.shotPowerInPixels * math.cos(self.angle)
    local targetY = self.ball.y - self.shotPowerInPixels * math.sin(self.angle)

    if targetX >= 0 and targetX <= (self.x + self.width) and targetY >= 0 and targetY <= (self.y + self.height) then
        self.targetX = targetX
        self.targetY = targetY
    end
end

function Course:getCourseType(x, y)
    local courseTileX = math.ceil(x / self.tileSize)
    local courseTileY = math.ceil(y / self.tileSize)

    return self.tiles[(courseTileY - 1) * self.tileWidth + courseTileX]:getCourseType()
end

function Course:isOnGreen()
    local courseType = self:getCourseType(self.ball:getRelativeXY())

    if courseType == Constants.course_green then
        return true
    else
        return false
    end
end

function Course:shotComplete(distance)
    self.angleOffset = 0
    self.takingShot = false
    self:calculateTarget(self)
    self.shotCompleteExec(distance, self.distanceToPin / self.pixelsPerYard)
end

function Course:getShotAngle()
    return self.angle * (180 / math.pi)
end

function Course:changeShotAngle(angleChange)
    self.angleOffset = self.angleOffset - (angleChange * (math.pi / 180))
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