TextField = Object:extend()

function TextField:new(x, y, text, fontSize, originX, originY, color)
    self.x = x
    self.y = y
    self.originX = originX or 0
    self.originY = originY or 0
    self.text = love.graphics.newText(love.graphics.newFont("assets/consola.ttf", fontSize), text)
    self.color = color
    self.width = self.text:getWidth()
    self.height = self.text:getHeight()
end

function TextField:update(text)
    self.text:set(text)
    self.width = self.text:getWidth()
end

function TextField:clear()
    self:update("")
end

function TextField:draw()
    if self.color ~= nil then
        love.graphics.setColor(self.color)
    end

    love.graphics.draw(self.text, self.x, self.y, 0, 1, 1, self.originX * self.width, self.originY * self.height)
    
    if self.color ~= nil then
        love.graphics.setColor(defaultTextColor)
    end
end

