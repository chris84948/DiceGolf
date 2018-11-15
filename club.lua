Club = Object:extend()

function Club:new(distance, name)
    self.distance = distance
    self.name = name
end

function Club:getDistance()
    return self.distance
end

function Club:getName()
    return self.name
end