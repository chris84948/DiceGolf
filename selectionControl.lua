SelectionControl = Object:extend()

local _lessThan_Clicked, _greaterThan_Clicked, _updateButtonEnabledStates

function SelectionControl:new(x, y, title, getSelection, previousSelectExec, nextSelectExec, canPreviousSelectExec, canNextSelectExec, repeatSpeed)
    self.x = x
    self.y = y
    self.getSelection = getSelection
    self.previousSelectExec = previousSelectExec
    self.nextSelectExec = nextSelectExec
    self.canPreviousSelectExec = canPreviousSelectExec
    self.canNextSelectExec = canNextSelectExec
    self.repeatSpeed = repeatSpeed or 0.5

    self.title = TextField(self.x + 105, self.y, title,  28, 0.5, 0)
    self.selectionValue = TextField(self.x + 105, self.y + 40, getSelection(), 28, 0.5, 0)

    self.lessThanButton = Button(self.x, self.y + 30, "arrows", 41, 0, function() _lessThan_Clicked(self) end, self.repeatSpeed)
    self.greaterThanButton = Button(self.x + 169, self.y + 30, "arrows", 41, 3, function() _greaterThan_Clicked(self) end, self.repeatSpeed)

    self.getSelection()
    _updateButtonEnabledStates(self)
end

function SelectionControl:update(dt)
    self.lessThanButton:update(dt)
    self.greaterThanButton:update(dt)
end

function SelectionControl:draw()
    self.title:draw()
    self.selectionValue:draw()
    self.lessThanButton:draw()
    self.greaterThanButton:draw()
end

function SelectionControl:mousePressed(x, y)
    self.lessThanButton:mousePressed(x, y)
    self.greaterThanButton:mousePressed(x, y)
end

function SelectionControl:mouseReleased(x, y)
    self.lessThanButton:mouseReleased(x, y)
    self.greaterThanButton:mouseReleased(x, y)
end

function SelectionControl:refresh()
    self.selectionValue:update(self.getSelection())
    _updateButtonEnabledStates(self)
end

function SelectionControl:setEnabled(isEnabled)
    self.lessThanButton:setEnabled(isEnabled)
    self.greaterThanButton:setEnabled(isEnabled)
end

_lessThan_Clicked = function(self)
    self.previousSelectExec()
    self.selectionValue:update(self.getSelection())
    _updateButtonEnabledStates(self)
end

_greaterThan_Clicked = function(self)
    self.nextSelectExec()
    self.selectionValue:update(self.getSelection())
    _updateButtonEnabledStates(self)
end

_updateButtonEnabledStates = function(self)
    if self.canPreviousSelectExec ~= nil then
        self.lessThanButton:setEnabled(self.canPreviousSelectExec())
    end
    if self.canNextSelectExec ~= nil then
        self.greaterThanButton:setEnabled(self.canNextSelectExec())
    end
end