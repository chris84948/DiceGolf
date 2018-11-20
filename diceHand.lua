DiceHand = Object:extend()

local _rollComplete, _getScoreAsDecimal, _isYahtzee, _isFourOfAKind, _isThreeOfAKind, _isFullHouse, _isSmallStraight, _isLargeStraight

function DiceHand:new(x, y, numDice, spacing, rollComplete)
    self.numDice = numDice
    self.diceSize = 64
    self.rollComplete = rollComplete

    local image = love.graphics.newImage("assets/dice.png")
    
    local diceQuads = {}
    for row = 0, 5 do
        for column = 0, 2 do
            table.insert(diceQuads, love.graphics.newQuad(column * self.diceSize, row * self.diceSize, self.diceSize, self.diceSize, image:getWidth(), image:getHeight()))
        end
    end

    self.dice = {}
    for i = 1, numDice do
        table.insert(self.dice, Dice(x + (i - 1) * (self.diceSize + spacing), y, i, self.diceSize, image, diceQuads))
    end

    self.maxRolls = 3
    self.numRollsLeft = self.maxRolls
    self.updateCounter = 0
    self.mouseDown = false
    self.rollDelay = 0.5
    self.rolling = false
    self.rollCompleteTime = 0
end

function DiceHand:update(dt)
    self.updateCounter = self.updateCounter + 1
    for i, dice in ipairs(self.dice) do
        dice:update(dt, self.updateCounter)
    end

    if self.rolling and self.rollCompleteTime > 0 then
        self.rollCompleteTime = self.rollCompleteTime - dt
    elseif self.rolling then
        self.rolling = false
        _rollComplete(self)
    end
end

function DiceHand:draw()
    for i, dice in ipairs(self.dice) do
        dice:draw()
    end
end


function DiceHand:roll()
    self.score = 0
    if self.numRollsLeft <= 0 then
        for i, dice in ipairs(self.dice) do
            dice:clearHold()
        end
        self.numRollsLeft = self.maxRolls
    end

    local numDiceRolled = 0
    for i, dice in ipairs(self.dice) do
        if not dice:isDiceHeld() then
            numDiceRolled = numDiceRolled + 1
            dice:roll(self.rollDelay * numDiceRolled)
        end
    end
    self.rollCompleteTime = numDiceRolled * self.rollDelay
    self.rolling = true

    self.numRollsLeft = self.numRollsLeft - 1
end

function DiceHand:reset()
    self.numRollsLeft = 0
    for i, dice in ipairs(self.dice) do
        dice:clearHold()
        dice:disable()
    end
end

function DiceHand:mousePressed(x, y)
    if self.mouseDown or self.numRollsLeft <= 0 then
        return
    end

    for i, dice in ipairs(self.dice) do
        if dice:isInBounds(x, y) then
            dice:toggleHold()
        end
    end
end

function DiceHand:mouseReleased(x, y)
    self.mouseDown = false
end

_rollComplete = function(self)
    local diceValues = {}
    local dicesTotal = 0
    for i, dice in ipairs(self.dice) do
        local diceValue = dice:getValue()
        table.insert(diceValues, diceValue)
        dicesTotal = dicesTotal + diceValue
    end

    table.sort(diceValues)

    local score, description = _getScoreAsDecimal(diceValues, dicesTotal, self.numDice)
    self.score = score
    self.rollComplete(score, description)
end

_getScoreAsDecimal = function(diceValues, dicesTotal, numDice)
    local numMatches, numMatches2 = _getNumSameDice(diceValues)
    
    if _isYahtzee(numMatches) then
        return 1.1, "Five Of A Kind"
    elseif _isFourOfAKind(numMatches) then
        return 1.0, "Four Of A Kind"
    elseif _isLargeStraight(diceValues) then
        return 1.0, "A Large Straight"
    elseif _isFullHouse(numMatches, numMatches2) then
        return 0.9, "A Full House"
    elseif _isThreeOfAKind(numMatches) then
        return 0.9, "Three Of A Kind"
    elseif _isSmallStraight(diceValues) then
        return 0.9, "A Small Straight"
    else
        return ((dicesTotal / numDice) / (6 * numDice)) * 3, "Some Dice"
    end
end

_isYahtzee = function(numMatches)
    if numMatches == 5 then
        return true
    else
        return false
    end
end

_isFourOfAKind = function(numMatches)
    if numMatches == 4 then
        return true
    else
        return false
    end
end

_isThreeOfAKind = function(numMatches)
    if numMatches == 3 then
        return true
    else
        return false
    end
end

_isFullHouse = function(numMatches, numMatches2)
    if numMatches == 3 and numMatches2 == 2 then
        return true
    else
        return false
    end
end

_isSmallStraight = function(diceValues)
    if (diceValues[1] == diceValues[2] - 1 and diceValues[2] == diceValues[3] - 1 and diceValues[3] == diceValues[4] - 1) or
       (diceValues[1] == diceValues[3] - 1 and diceValues[3] == diceValues[4] - 1 and diceValues[4] == diceValues[5] - 1) or
       (diceValues[1] == diceValues[2] - 1 and diceValues[2] == diceValues[4] - 1 and diceValues[4] == diceValues[5] - 1) or
       (diceValues[1] == diceValues[2] - 1 and diceValues[2] == diceValues[3] - 1 and diceValues[3] == diceValues[5] - 1) or
       (diceValues[2] == diceValues[3] - 1 and diceValues[3] == diceValues[4] - 1 and diceValues[4] == diceValues[5] - 1) then
        return true
    else
        return false
    end
end

_isLargeStraight = function(diceValues)
    if diceValues[1] == diceValues[2] - 1 and diceValues[2] == diceValues[3] - 1 and diceValues[3] == diceValues[4] - 1 and diceValues[4] == diceValues[5] - 1 then
        return true
    else
        return false
    end
end

_getNumSameDice = function(diceValues)
    local largestNum = 0
    local currentNum = 1

    for i = 1, #diceValues - 1 do
        if diceValues[i] == diceValues[i + 1] then
            currentNum = currentNum + 1
        else
            if currentNum > largestNum then
                largestNum = currentNum
                currentNum = 1
            end
        end
    end

    if currentNum > largestNum then
        return currentNum, largestNum
    else
        return largestNum, currentNum
    end
end