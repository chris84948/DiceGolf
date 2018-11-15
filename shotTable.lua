ShotTable = Object:extend()

function ShotTable:new(x, y)
    self.x = x
    self.y = y
    self.image = love.graphics.newImage("assets/shot_table.png")
    self.font = love.graphics.newFont("assets/consola.ttf", 20)
    self.holes = {}
end

function ShotTable:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, 1, 1)
    
    love.graphics.setFont(self.font)

    for hole, shots in ipairs(self.holes) do
        love.graphics.print(shots, self.x + 100 + (hole - 1) * 36.2, self.y + 50)
    end
end

function ShotTable:addHole(hole, shots)
    self.holes[hole] = shots
end