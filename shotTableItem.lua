ShotTableItem = Object:extend()

function ShotTableItem:new(par, shotsTaken)
    self.par = par
    self.shotsTaken = shotsTaken
    
    if shotsTaken == par then
        self.color = defaultTextColor
    elseif shotsTaken < par then
        self.color = greenColor
    elseif shotsTaken > par then
        self.color = redColor
    end
end