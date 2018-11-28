BallLie = Object:extend()

function BallLie:new(x, y)
    self.x = x
    self.y = y
    self.image = love.graphics.newImage("assets/lie.png")

    self.quads = {}
    self.quadSize = 50
    for i = 0, self.image:getWidth() / self.quadSize - 1 do
        table.insert(self.quads, love.graphics.newQuad(i * self.quadSize, 0, self.quadSize, self.quadSize, self.image:getWidth(), self.image:getHeight()))
    end

    self.quadIndex = 1
end

function BallLie:set(courseType)
    self.quadIndex = courseType + 1
end

function BallLie:setOnTee()
    self.quadIndex = 1
end

function BallLie:draw()
    love.graphics.draw(self.image, self.quads[self.quadIndex], self.x, self.y, 0, 1, 1)
end