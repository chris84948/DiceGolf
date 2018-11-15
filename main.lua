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

    num = 0
    player = Player(clubChangedEvent)
    shotTable = ShotTable(20, 110)
    shotTable:addHole(1, 4)
    fields = {
        TextField(390, 25, "To Die Fore", 60, 0.5, 0),
        TextField(40, 220, "Hole 1", 28),
        TextField(160, 220, "Par 4", 28),
        TextField(370, 220, "Shot 1", 28),
        TextField(500, 220, "376 Yards To Pin", 28),
        TextField(390, 445, "ROLL DICE", 28, 0.5, 0.5, {0.15, 0.15, 0.15, 1}),
        TextField(390, 590, "", 22, 0.5, 0),
        TextField(390, 630, "", 28, 0.5, 0),
    }

    clubSelector = SelectionControl(20, 290, "Club", function() return player:getClub():getName() end, function() player:getPreviousClub() end, 
                                    function() player:getNextClub() end, function() return player:canGetPreviousClub() end, function() return player:canGetNextClub() end)
    powerSelector = SelectionControl(275, 290, "Power", getNumber, lessThan_Clicked, greaterThan_Clicked, canLessThan, canGreaterThan)
    angleSelector = SelectionControl(530, 290, "Angle", getNumber, function() course:changeShotAngle(-1) end, function() course:changeShotAngle(1) end)

    diceButton = Button(140, 410, "buttons", 64, 0, diceButton_Clicked)
    diceHand = DiceHand(90, 500, 5, 70, rollComplete)

    spinner = Spinner(140, 674)

    course = CourseLoader:loadCourse(1, 780, 20)
    course:setShotPower(150)
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
        powerSelector:mouseReleased()
        clubSelector:mouseReleased()
        angleSelector:mouseReleased()
        diceHand:mouseReleased()
        diceButton:mouseReleased()
        spinner:mouseReleased()
    end
end

function clubChangedEvent()
    print("club changed motherfucker")
end

function rollComplete(score, description)
    local numRollsLeft = diceHand:getNumRollsLeft()
    if numRollsLeft == 0 then
        fields[Constants.field_rolls]:update("No More Rolls Left")
    elseif numRollsLeft == 1 then
        fields[Constants.field_rolls]:update(numRollsLeft .. " Roll Left - Click Dice To Hold")
    else
        fields[Constants.field_rolls]:update(numRollsLeft .. " Rolls Left - Click Dice To Hold")
    end

    fields[Constants.field_rollResult]:update("You Rolled " .. description .. ", Hit = ".. Ext.round(score * 100, 2) .. "%")
    spinner:show()
end


function getNumber()
    return "Num = " .. num
end

 function diceButton_Clicked()
    fields[Constants.field_rolls]:clear()
    fields[Constants.field_rollResult]:clear()
    diceHand:roll()
 end

 function lessThan_Clicked()
    num = num - 1
 end

 function greaterThan_Clicked()
    num = num + 1
 end

function canLessThan()
    if num <= 0 then
        return false
    else
        return true
    end
end

function canGreaterThan()
    if num >= 100 then
        return false
    else
        return true
    end
end