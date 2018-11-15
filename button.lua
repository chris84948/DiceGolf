Button = Object:extend()

function Button:new(x, y, imageName, quadHeight, quadPos, clicked, repeatTime)
    self.x = x
    self.y = y
    self.image = love.graphics.newImage("assets/" .. imageName .. ".png")
    self.clicked = clicked
    self.repeatTime = repeatTime or 0
    
    self.height = quadHeight
    self.width = self.image:getWidth()
    self.quad = love.graphics.newQuad(0, quadHeight * quadPos, self.width, self.height, self.image:getWidth(), self.image:getHeight())
    self.clickedQuad = love.graphics.newQuad(0, quadHeight * (quadPos + 1), self.width, self.height, self.image:getWidth(), self.image:getHeight())
    self.disabledQuad = love.graphics.newQuad(0, quadHeight * (quadPos + 2), self.width, self.height, self.image:getWidth(), self.image:getHeight())
    self.isEnabled = true
    self.repeatTimeNow = 0
    self.numRepeats = 3
end

function Button:update(dt)
    if self.repeatTime == 0 or not self.isEnabled or not self.mouseDown then
        return
    end

    self.repeatTimeNow = self.repeatTimeNow + dt

    if self.repeatTimeNow > self.repeatTime * self.numRepeats then
        self.clicked()

        if self.numRepeats > 1 then
            self.numRepeats = self.numRepeats - 0.5
        end
        self.repeatTimeNow = 0
    end
end

function Button:draw()
    if not self.isEnabled then
        love.graphics.draw(self.image, self.disabledQuad, self.x, self.y, 0, 1, 1)
    elseif self.mouseDown then
        love.graphics.draw(self.image, self.clickedQuad, self.x, self.y, 0, 1, 1)
    else
        love.graphics.draw(self.image, self.quad, self.x, self.y, 0, 1, 1)
    end
end

function Button:mousePressed(x, y)
    if self.mouseDown or not self.isEnabled then
        return
    elseif x < self.x or x > self.x + self.width or y < self.y or y > self.y + self.height then
        return
    end
    
    self.mouseDown = true
    self.clicked()
end

function Button:mouseReleased()
   self.mouseDown = false 
   self.numRepeats = 3
   self.repeatTimeNow = 0
end

function Button:setEnabled(isEnabled)
    self.isEnabled = isEnabled
end