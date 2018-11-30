TextField = Object:extend()

function TextField:new(x, y, text, fontSize, originX, originY, color, backgroundColor, backgroundHeight)
    self.x = x
    self.y = y
    self.originX = originX or 0
    self.originY = originY or 0
    self.text = love.graphics.newText(love.graphics.newFont("assets/consola.ttf", fontSize), text)
    self.color = color
    self.backgroundColor = backgroundColor
    self.width = self.text:getWidth()
    self.height = self.text:getHeight()
    self.backgroundHeight = backgroundHeight or self.height + 10
end

function TextField:update(text)
    self.text:set(text)
    self.width = self.text:getWidth()
end

function TextField:clear()
    self:update("")
end

function TextField:draw()
    if self.backgroundColor ~= nil then
        love.graphics.setColor(self.backgroundColor)

        love.graphics.rectangle("fill", self.x - (self.originX * self.width + 10), self.y - (self.originY * self.height + 9), self.width + 20, self.backgroundHeight, 5, 5)

        if self.color == nil then
            love.graphics.setColor(defaultTextColor)
        end
    end

    if self.color ~= nil then
        love.graphics.setColor(self.color)
    end

    love.graphics.draw(self.text, self.x, self.y, 0, 1, 1, self.originX * self.width, self.originY * self.height)
    
    if self.color ~= nil then
        love.graphics.setColor(defaultTextColor)
    end
end

