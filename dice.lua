Dice = Object:extend()

function Dice:new(x, y, size, image, diceQuads, holdQuads)
    self.x = x
    self.y = y
    self.size = size
    self.image = image
    self.diceQuads = diceQuads
    self.holdQuads = holdQuads

    self.number = 1
    self.numberForRolling = 1
    self.isRolling = false
    self.rollCountdown = 0
    self.isHeld = false
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
    if self.isHeld then
        love.graphics.draw(self.image, self.holdQuads[self.number], self.x, self.y, 0, self.scale, self.scale)
    elseif self.isRolling then
        love.graphics.draw(self.image, self.diceQuads[self.numberForRolling], self.x, self.y, 0, self.scale, self.scale)
    else
        love.graphics.draw(self.image, self.diceQuads[self.number], self.x, self.y, 0, self.scale, self.scale)
    end
end


function Dice:roll(delay)
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

function Dice:isInBounds(x, y)
    if x >= self.x and x <= self.x + self.size and y >= self.y and y <= self.y + self.size then
        return true
    else
        return false
    end
end