local _setEnabledOnSelectors

function initialize()
    love.window.setMode(1200, 800)
    love.graphics.setBackgroundColor(0.15, 0.15, 0.15)
    defaultTextColor = {0.9, 0.9, 0.9, 1}
    love.graphics.setColor(defaultTextColor)
    math.randomseed(os.time())

    Object = require("libs.classic.classic")
    Constants = require("constants")
    Json = require("libs.json.json")
    CourseLoader = require("courseLoader")
    Ext = require("ext")
    require("tile")
    require("course")
    require("ball")
    require("diceHand")
    require("dice")
    require("spinner")
    require("button")
    require("textField")
    require("shotTable")
    require("selectionControl")
    require("player")
    require("club")
end

function love.load()
    initialize()

    courseNum = 1
    player = Player(clubChangedEvent)
    shotTable = ShotTable(20, 110)
    fields = {
        TextField(390, 25, "I Dice Big Putts", 60, 0.5, 0),
        TextField(40, 220, "Hole Num", 28),
        TextField(160, 220, "Par Num", 28),
        TextField(370, 220, "Shot Num", 28),
        TextField(500, 220, "Distance To Pin", 28),
        TextField(390, 445, "ROLL DICE", 28, 0.5, 0.5, {0.15, 0.15, 0.15, 1}),
        TextField(390, 590, "", 22, 0.5, 0),
        TextField(390, 630, "", 28, 0.5, 0),
    }

    loadCourse(courseNum)

    clubSelector = SelectionControl(50, 290, "Club", function() return player:getClub().name end, 
                                                     function() player:getPreviousClub() end,
                                                     function() player:getNextClub() end,
                                                     function() return player:canGetPreviousClub() end, 
                                                     function() return player:canGetNextClub() end)
    powerSelector = SelectionControl(290, 290, "Power", function() return course:getShotPower() end, 
                                                        function() course:changeShotPower(-5) end, 
                                                        function() course:changeShotPower(5) end, 
                                                        function() return course:getShotPower() >= 5 end, 
                                                        function() return course:getShotPower() <= player:getClub().distance - 5 end, 0.5)
    angleSelector = SelectionControl(530, 290, "Angle", function() return Ext.round(course:getShotAngle(), 0) .. " deg" end, 
                                                        function() course:changeShotAngle(-0.5) end, 
                                                        function() course:changeShotAngle(0.5) end,
                                                        nil, nil, 0.3)

    diceButton = Button(140, 410, "buttons", 64, 0, diceButton_Clicked, diceButton_MouseReleased, true)
    diceHand = DiceHand(150, 500, 5, 40, rollComplete)

    spinner = Spinner(140, 674, function() course:takeShot(diceHand.score, spinner:stopRotationAndGetError(), player:isPutterSelected()) end)
end

function love.update(dt)
    diceHand:update(dt)
    powerSelector:update(dt)
    clubSelector:update(dt)
    angleSelector:update(dt)
    spinner:update(dt)
    course:update(dt)
end

function love.draw()
    shotTable:draw()
    powerSelector:draw()
    clubSelector:draw()
    angleSelector:draw()
    diceHand:draw()
    diceButton:draw()
    spinner:draw()

    for i, field in ipairs(fields) do
        field:draw()
    end

    course:draw()
end


function love.keypressed(key)
    if key == "escape" then
        love.event.push("quit")
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        powerSelector:mousePressed(x, y)
        clubSelector:mousePressed(x, y)
        angleSelector:mousePressed(x, y)
        diceHand:mousePressed(x, y)
        diceButton:mousePressed(x, y)
        spinner:mousePressed(x, y)
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if button == 1 then
        powerSelector:mouseReleased(x, y)
        clubSelector:mouseReleased(x, y)
        angleSelector:mouseReleased(x, y)
        diceHand:mouseReleased(x, y)
        diceButton:mouseReleased(x, y)
        spinner:mouseReleased(x, y)
    end
end

function diceButton_Clicked()
    fields[Constants.field_rolls]:clear()
    fields[Constants.field_rollResult]:clear()
    _setEnabledOnSelectors(false)
    diceButton:setEnabled(false)
    
    diceHand:roll()
end

function clubChangedEvent()
    course:setShotPower(player:getClub().distance)
    if powerSelector and clubSelector then
        powerSelector:refresh()
        clubSelector:refresh()
    end
end

function rollComplete(score, description)
    if diceHand.numRollsLeft > 0 then
        diceButton:setEnabled(true)
    end

    if diceHand.numRollsLeft == 0 then
        fields[Constants.field_rolls]:update("No More Rolls Left")
    elseif diceHand.numRollsLeft == 1 then
        fields[Constants.field_rolls]:update(diceHand.numRollsLeft .. " Roll Left - Click Dice To Hold")
    else
        fields[Constants.field_rolls]:update(diceHand.numRollsLeft .. " Rolls Left - Click Dice To Hold")
    end

    fields[Constants.field_rollResult]:update("You Rolled " .. description .. ", Hit = ".. Ext.round(score * 100, 2) .. "%")
    spinner:show()
end

function shotComplete(distanceHit, distanceToPin)
    _setEnabledOnSelectors(true)
    diceHand:reset()
    diceButton:setEnabled(true)
    player:calculateClubForNextShot(distanceToPin, course:isOnGreen())

    spinner:hide()
    fields[Constants.field_rolls]:clear()
    fields[Constants.field_rollResult]:clear()
    fields[Constants.field_shot]:update("Shot " .. player:shotComplete())
    fields[Constants.field_distance]:update(Ext.round(distanceToPin, 0) .. " Yards To Pin")
end

function loadCourse(courseNum) 
    course = CourseLoader:loadCourse(courseNum, 780, 20, function(distance, distanceToPin) shotComplete(distance, distanceToPin) end, courseComplete)
    course:setShotPower(player:calculateClubForNextShot(course.lengthInYards, false))

    fields[Constants.field_distance]:update(Ext.round(course.lengthInYards, 0) .. " Yards To Pin")
    fields[Constants.field_shot]:update("Shot " .. player.shotNum)

    fields[Constants.field_hole]:update("Hole " .. course.hole)
    fields[Constants.field_par]:update("Par " .. course.par)
end

function courseComplete()
    shotComplete(0, 0)

    shotTable:addHole(courseNum, player.shotNum)
    player.shotNum = 1

    courseNum = courseNum + 1
    loadCourse(courseNum)    
end

_setEnabledOnSelectors = function(isEnabled)
    clubSelector:setEnabled(isEnabled)
    powerSelector:setEnabled(isEnabled)
    angleSelector:setEnabled(isEnabled)
end