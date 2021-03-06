Player = Object:extend()

local _selectClub

function Player:new(clubChanged)
    self.clubChanged = clubChanged
    
    self.clubs = {
        Club(230, "Driver"),
        Club(210, "3-Wood"),
        Club(190, "2-Iron"),
        Club(180, "3-Iron"),
        Club(170, "4-Iron"),
        Club(160, "5-Iron"),
        Club(150, "6-Iron"),
        Club(140, "7-Iron"),
        Club(130, "8-Iron"),
        Club(120, "9-Iron"),
        Club(110, "Pitch W"),
        Club(90, "Sand W"),
        Club(60, "Putter"),
    }
    self.selectedClubIndex = 1

    self.shotNum = 1
    self.shotsForEachCourse = {}
    self.canChangeClub = true
end

function Player:getClub()
    return self.clubs[self.selectedClubIndex]
end

function Player:getPreviousClub()
    self.selectedClubIndex = self.selectedClubIndex - 1
    self.clubChanged()
    return self:getClub()
end

function Player:getNextClub()
    self.selectedClubIndex = self.selectedClubIndex + 1
    self.clubChanged()
    return self:getClub()
end

function Player:canGetPreviousClub()
    if self.canChangeClub and self.selectedClubIndex > 1 then
        return true
    else
        return false
    end
end

function Player:canGetNextClub()
    if self.canChangeClub and self.selectedClubIndex < #self.clubs then
        return true
    else
        return false
    end
end

function Player:calculateClubForNextShot(distanceToPin, courseType)
    self.canChangeClub = true
    if courseType == Constants.course_green then
        self.canChangeClub = false
        return _selectClub(self, #self.clubs)
    
    elseif courseType == Constants.course_bunker then
        self.canChangeClub = false
        return _selectClub(self, #self.clubs - 1)
    end

    for i = 1, #self.clubs - 1 do
        if self.clubs[i].distance < distanceToPin then
            return _selectClub(self, i)
        end
    end

    return _selectClub(self, #self.clubs - 1)
end

function Player:shotComplete(isOutOfBounds)
    self.shotNum = self.shotNum + 1

    if isOutOfBounds then
        self.shotNum = self.shotNum + 1
    end
    
    return self.shotNum
end

function Player:isPutterSelected()
    return self:getClub().name == "Putter"
end

_selectClub = function(self, clubIndex)
    self.selectedClubIndex = clubIndex
    self.clubChanged()
    return self:getClub().distance
end