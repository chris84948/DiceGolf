GithubLink = Object:extend()

function GithubLink:new(x, y)
    self.x = x
    self.y = y

    self.image = love.graphics.newImage("assets/github.png")
end

function GithubLink:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, 2, 2)
end

function GithubLink:mousePressed(x, y)
    if x > self.x and x < self.x + 64 and y > self.y and y < self.y + 64 then
        self.mouseDown = true
        love.system.openURL("https://github.com/chris84948/DiceGolf")
    end
end

function GithubLink:mouseReleased()
    self.mouseDown = false
end