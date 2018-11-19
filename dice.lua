Dice = Object:extend()

function Dice:new(x, y, diceNum, size, image, quads)
    self.x = x
    self.y = y
    self.diceNum = diceNum
    self.size = size
    self.image = image
    self.quads = quads

    self.number = 1
    self.numberForRolling = 1
    self.isRolling = false
    self.rollCountdown = 0
    self.isHeld = false
    self.isDisabled = true
    self.scale = 1    
end

function Dice:update(dt, updateCounter)
    if self.isRolling and self.rollCountdown > 0 then
        self.rollCountdown = self.rollCountdown - dt
        if updateCounter % 5 == 0 then
            self.numberForRolling = self.numberForRolling % 6 + 1
        end
    elseif self.isRolling then
        self.isRolling = false
    end
end

function Dice:draw()
    if self.isDisabled then
        love.graphics.draw(self.image, self.quads[self.number * 3], self.x, self.y, 0, self.scale, self.scale)
    elseif self.isHeld then
        love.graphics.draw(self.image, self.quads[self.number * 3 - 1], self.x, self.y, 0, self.scale, self.scale)
    elseif self.isRolling then
        love.graphics.draw(self.image, self.quads[self.numberForRolling * 3 - 2], self.x, self.y, 0, self.scale, self.scale)
    else
        love.graphics.draw(self.image, self.quads[self.number * 3 - 2], self.x, self.y, 0, self.scale, self.scale)
    end
end


function Dice:roll(delay)
    self.isDisabled = false
    self.isRolling = true
    self.rollCountdown = delay

    self.number = math.random(1, 6)
end

function Dice:getValue()
    return self.number
end

function Dice:isDiceHeld()
    return self.isHeld
end

function Dice:toggleHold()
    self.isHeld = not self.isHeld
end

function Dice:clearHold()
    self.isHeld = false
end

function Dice:disable()
    self.isDisabled = true
end

function Dice:isInBounds(x, y)
    if x >= self.x and x <= self.x + self.size and y >= self.y and y <= self.y + self.size then
        return true
    else
        return false
    end
end