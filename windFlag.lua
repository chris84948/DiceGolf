WindFlag = Object:extend()

function WindFlag:new(x, y)
    self.x = x
    self.y = y

    self.image = love.graphics.newImage("assets/flags.png")

    self.quads = {}
    self.quadSize = 50
    for i = 0, 16 do
        table.insert(self.quads, love.graphics.newQuad(i * self.quadSize, 0, self.quadSize, self.quadSize, self.image:getWidth(), self.image:getHeight()))
    end

    self.updateTime = 0
    self.currentTime = 0
    self.scaleX = 1
    self.offsetX = 0
end

function WindFlag:update(dt)
    self.currentTime = self.currentTime + dt

    if self.updateTime == 0 or self.currentTime < self.updateTime then
        return
    end

    self.currentTime = 0

    local windSpeed = math.abs(self.windSpeed)
    if windSpeed == 1 and self.quadIndex == 15 then
        self.quadIndex = 16
    elseif windSpeed == 1 then
        self.quadIndex = 15
    end

    if windSpeed == 2 and self.quadIndex == 13 then
        self.quadIndex = 14
    elseif windSpeed == 2 then
        self.quadIndex = 13
    end

    if windSpeed == 3 then
        self.quadIndex = (self.quadIndex % 12) + 1
    end
end

function WindFlag:draw()
    love.graphics.draw(self.image, self.quads[self.quadIndex], self.x + self.offsetX, self.y, 0, self.scaleX, 1)
end

function WindFlag:setRandomWindSpeed()
    self:setWindSpeed(math.random(-3, 3))
end

function WindFlag:setWindSpeed(windSpeed)
    self.windSpeed = windSpeed

    if windSpeed > 0 then
        self.scaleX = -1
        self.offsetX = self.quadSize * 2
    else
        self.scaleY = 1
        self.offsetX = 0
    end

    if math.abs(windSpeed) == 0 then
        self.quadIndex = 17
        self.updateTime = 0 
    elseif math.abs(windSpeed) == 1 then
        self.quadIndex = 15
        self.updateTime = 0.3
    elseif math.abs(windSpeed) == 2 then
        self.quadIndex = 13
        self.updateTime = 0.3
    else
        self.quadIndex = 1
        self.updateTime = 0.1
    end

    self.currentTime = 0
end

function WindFlag:getWindSpeed()
    return self.windSpeed
end