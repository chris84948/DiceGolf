Tile = Object:extend()

function Tile:new(x, y, image, quad, tileNum)
    self.x = x
    self.y = y
    self.image = image
    self.quad = quad
    self.tileNum = tileNum

    self.scale = 1
end

function Tile:draw()
    love.graphics.draw(self.image, self.quad, self.x, self.y, 0, self.scale, self.scale)
end


function Tile:getCourseType()
    return self.tileNum
end