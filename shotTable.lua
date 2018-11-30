ShotTable = Object:extend()

function ShotTable:new(x, y)
    self.x = x
    self.y = y
    self.image = love.graphics.newImage("assets/shot_table.png")
    self.font = love.graphics.newFont("assets/consola.ttf", 23)
    self.holes = {}

    self.parTotal = 0
    self.score = 0

    self.xOffset = 121
    self.distBetweenHoles = 61.849
    self.holeOffset = 11
    self.parOffset = 49
    self.scoreOffset = 88
    self.totalOffset = 10
end

function ShotTable:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, 1, 1)
    love.graphics.setFont(self.font)
    
    for hole, shotItem in ipairs(self.holes) do
        love.graphics.setColor(shotItem.color)
        love.graphics.print(shotItem.shotsTaken, self.x + self.xOffset + (hole - 1) * self.distBetweenHoles, self.y + self.scoreOffset)
    end
    
    if self.showTotal then
        love.graphics.setColor(self.scoreColor)
        love.graphics.print(self.score, self.x + self.xOffset + 9 * self.distBetweenHoles + self.totalOffset, self.y + self.scoreOffset)
    end
    
    love.graphics.setColor(defaultTextColor)
    for hole, shotItem in ipairs(self.holes) do
        love.graphics.print(hole, self.x + self.xOffset + (hole - 1) * self.distBetweenHoles, self.y + self.holeOffset)
        love.graphics.print(shotItem.par, self.x + self.xOffset + (hole - 1) * self.distBetweenHoles, self.y + self.parOffset)
    end

    if self.showTotal then
        love.graphics.print(self.parTotal, self.x + self.xOffset + 9 * self.distBetweenHoles + self.totalOffset, self.y + self.parOffset)
    end
end

function ShotTable:addHole(hole, shotItem)
    self.holes[hole] = shotItem

    self.parTotal = self.parTotal + shotItem.par
    self.score = self.score + shotItem.shotsTaken
    print(self.parTotal, self.score)

    if hole == 9 then
        if self.score < self.parTotal then
            self.scoreColor = greenColor
        elseif self.score == self.parTotal then
            self.scoreColor = defaultTextColor
        elseif self.score > self.parTotal then
            self.scoreColor = redColor
        end

        self.showTotal = true
    end
end