Course = Object:extend()

function Course:new(x, y, width, height, tileSize, lengthInYards)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.tileSize = tileSize
    self.lengthInYards = lengthInYards

    self.tileImage = love.graphics.newImage("assets/tiles.png")
    self.numTiles = self.tileImage:getWidth() / tileSize
    self.tileObjectImage = love.graphics.newImage("assets/tile_objects.png")
    self.takingShot = false

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

    self.ball:draw()

    if not self.takingShot then
        love.graphics.line(self.ball:getPosX(), self.ball:getPosY(), self.targetX, self.targetY)
    end
end


function Course:setTileData(tiles)
    self.tiles = { }
    for x = 1, self.width do
        for y = 1, self.height do
            local index = (y - 1) * self.width + x
            if tiles[index] > 0 then
                self.tiles[(y - 1) * self.width + x] = Tile(self.x + (x - 1) * self.tileSize, self.y + (y - 1) * self.tileSize, self.tileImage, self.quads[tiles[index]], tiles[index])
            end
        end
    end 
end

function Course:setTileObjectData(tiles)
    self.tileObjects = { }
    for x = 1, self.width do
        for y = 1, self.height do
            local index = (y - 1) * self.width + x
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

function Course:loadComplete()
    self.pixelsPerYard = math.sqrt((self.teeX - self.holeX) ^ 2 + (self.teeY - self.holeY) ^ 2) / self.lengthInYards
    self.shotPowerInPixels = self.pixelsPerYard * 150
    self.ball:setPixelScale(self.pixelsPerYard)
    
    self:calculateTarget()
end

function Course:hitBall()
    self.takingShot = true
    self.ball:hit(self.shotPowerInPixels, self.targetX, self.targetY)
end

function Course:calculateTarget()
    local diffX = self.holeX - self.ball:getPosX()
    local diffY = math.abs(self.holeY - self.ball:getPosY())

    local angle = math.atan2(diffY, diffX)
    self.targetX = self.ball:getPosX() + self.shotPowerInPixels * math.cos(angle)
    self.targetY = self.ball:getPosY() - self.shotPowerInPixels * math.sin(angle)
end

function Course:getCourseType(x, y)
    local courseTileX = math.ceil(x / self.tileSize)
    local courseTileY = math.ceil(y / self.tileSize)

    return self.tiles[(courseTileY - 1) * self.width + courseTileX]:getCourseType()
end


function Course:shotComplete(distance) 
    self.takingShot = false
    self:calculateTarget(self)
end