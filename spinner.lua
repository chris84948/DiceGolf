Spinner = Object:extend()

function Spinner:new(x, y, takeShotClicked)
    self.x = x
    self.y = y
    self.image = love.graphics.newImage("assets/spinner.png")
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()

    self.shotButton = Button(self.x, self.y + 16, "buttons", 64, 2, takeShotClicked)
    self.buttonText = TextField(self.x + 200, self.y + 51, "TAKE SHOT", 28, 0.5, 0.5, {0.15, 0.15, 0.15, 1})

    self.rotation = 0
    self.rotateSpeed = 0.7  -- rots/sec
    self.scale = 1
end

function Spinner:update(dt)
    if self.isVisible then
        self.rotation = (self.rotation + dt * self.rotateSpeed * 2 * math.pi) % (2 * math.pi)
    end
end

function Spinner:draw()
    if self.isVisible then
        love.graphics.draw(self.image, self.x + 400 + self.width / 2, self.y + self.height / 2, self.rotation, self.scale, self.scale, self.width / 2, self.height / 2)
        self.shotButton:draw()
        self.buttonText:draw()
    end
end

function Spinner:mousePressed(x, y)
    if self.isVisible then
        self.shotButton:mousePressed(x, y)
    end
end

function Spinner:mouseReleased()
    self.shotButton:mouseReleased()
end

function Spinner:hide()
    self.isVisible = false
end

function Spinner:show()
    if self.isVisible then
        return
    end
    
    self.rotation = 0
    self.isVisible = true
end