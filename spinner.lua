Spinner = Object:extend()

function Spinner:new(x, y, takeShotClicked)
    self.x = x
    self.y = y
    self.image = love.graphics.newImage("assets/spinner.png")
    self.imageGreen = love.graphics.newImage("assets/spinner_putt.png")
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()

    self.shotButton = Button(self.x, self.y + 16, "buttons", 64, 3, takeShotClicked)
    self.buttonText = TextField(self.x + 180, self.y + 51, "TAKE SWING", 28, 0.5, 0.5, {0.15, 0.15, 0.15, 1})

    self.rotation = 0
    self.isRotating = true
    self.rotateSpeed = 0.8  -- rots/sec
    self.scale = 1
    self.isOnGreen = false
end

function Spinner:update(dt)
    if self.isVisible and self.isRotating then
        self.rotation = (self.rotation + dt * self.rotateSpeed * 2 * math.pi) % (2 * math.pi)
    end
end

function Spinner:draw()
    if self.isVisible then
        if self.isOnGreen then
            love.graphics.draw(self.imageGreen, self.x + 400 + self.width / 2, self.y + self.height / 2, self.rotation, self.scale, self.scale, self.width / 2, self.height / 2)
        else
            love.graphics.draw(self.image, self.x + 400 + self.width / 2, self.y + self.height / 2, self.rotation, self.scale, self.scale, self.width / 2, self.height / 2)
        end
        self.shotButton:draw()
        self.buttonText:draw()
    end
end

function Spinner:mousePressed(x, y)
    if self.isVisible then
        self.shotButton:mousePressed(x, y)
    end
end

function Spinner:mouseReleased(x, y)
    self.shotButton:mouseReleased(x, y)
end

function Spinner:hide()
    self.isVisible = false
end

function Spinner:show()
    if self.isVisible then
        return
    end
    
    self.rotation = 0
    self.isRotating = true
    self.isVisible = true
end

function Spinner:stopRotationAndGetError()
    self.isRotating = false
    local rotInDegrees = self.rotation * (180 / math.pi)
    print(rotInDegrees)

    if self.isOnGreen then
        if rotInDegrees >= 209 and rotInDegrees <= 335 then
            return 0
        else
            return -(math.random() * 5 + 2) * (math.pi / 180)
        end
    else
        if rotInDegrees >= 92 and rotInDegrees < 209 then
            return -(math.random() * 20 + 20) * (math.pi / 180)
        elseif rotInDegrees >= 209 and rotInDegrees < 253 then
            return -(math.random() * 10 + 10) * (math.pi / 180)
        elseif rotInDegrees >= 253 and rotInDegrees < 269 then
            return -(math.random() * 5 + 2) * (math.pi / 180)
        elseif rotInDegrees >= 269 and rotInDegrees <= 275 then
            return 0
        elseif rotInDegrees > 275 and rotInDegrees <= 290 then
            return (math.random() * 5 + 2) * (math.pi / 180)
        elseif rotInDegrees > 290 and rotInDegrees <= 335 then
            return (math.random() * 10 + 10) * (math.pi / 180)
        else -- final segment 336 - 91
            return (math.random() * 20 + 20) * (math.pi / 180)
        end
    end
end