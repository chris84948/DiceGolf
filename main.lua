local _setEnabledOnSelectors, _refreshSelectors, _gameOver

function initialize()
    love.window.setMode(1200, 800)
    love.graphics.setBackgroundColor(0.15, 0.15, 0.15)
    love.window.setTitle("I Dice Big Putts")
    math.randomseed(os.time())
    
    Object = require("libs.classic.classic")
    Constants = require("constants")
    Debug = require("Debug")
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
    require("shotTableItem")
    require("selectionControl")
    require("player")
    require("club")
    require("windFlag")
    require("ballLie")
    require("githubLink")
    require("backgroundMusic")
    require("soundEffect")

    defaultTextColor = {0.9, 0.9, 0.9, 1}
    greenColor = { 0.302, 0.761, 0.545, 1 }
    redColor = { 0.761, 0.314, 0.302, 1 }
    love.graphics.setColor(defaultTextColor)

    backgroundMusic = BackgroundMusic()
    soundEffect = SoundEffect()
end

function love.load()
    initialize()
    
    courseNum = 1
    
    githubLink = GithubLink(10, 725)
    player = Player(clubChangedEvent)
    shotTable = ShotTable(20, 80)

    spinner = Spinner(140, 674, spinnerButton_Clicked)

    fields = {
        TextField(390, 25, "I Dice Big Putts", 40, 0.5, 0),
        TextField(30, 235, "Shot Num", 28),
        TextField(180, 235, "Distance To Pin", 28),
        TextField(390, 445, "ROLL DICE", 28, 0.5, 0.5, {0.15, 0.15, 0.15, 1}),
        TextField(390, 590, "", 22, 0.5, 0),    -- Num rolls left
        TextField(390, 630, "", 28, 0.5, 0),    -- Roll result

        TextField(980, 35, "Hole Num", 18, 0.5, 0),
        TextField(980, 10, "Course Name", 18, 0.5, 0),
    }

    ballLie = BallLie(500, 225)
    windFlag = WindFlag(600, 225)

    loadCourse(courseNum)

    clubSelector = SelectionControl(50, 305, "Club", function() return player:getClub().name end, 
                                                     function() player:getPreviousClub() end,
                                                     function() player:getNextClub() end,
                                                     function() return player:canGetPreviousClub() end, 
                                                     function() return player:canGetNextClub() end)
    powerSelector = SelectionControl(290, 305, "Power", function() return course:getShotPower() end, 
                                                        function() course:changeShotPower(-5) end, 
                                                        function() course:changeShotPower(5) end, 
                                                        function() return course:getShotPower() >= 5 end, 
                                                        function() return course:getShotPower() <= player:getClub().distance - 5 end, 0.5)
    angleSelector = SelectionControl(530, 305, "Angle", function() return Ext.round(course:getShotAngle(), 0) .. " deg" end, 
                                                        function() course:changeShotAngle(-1) end, 
                                                        function() course:changeShotAngle(1) end,
                                                        nil, nil, 0.3)

    diceButton = Button(140, 410, "buttons", 64, 0, diceButton_Clicked, 0, true)
    diceHand = DiceHand(150, 500, 5, 40, rollComplete)
    gameOverField = TextField(390, 500, "GAME OVER", 80, 0.5, 0.5, defaultTextColor, redColor, 88)
end

function love.update(dt)
    if gameOver then
        return
    end

    backgroundMusic:update(dt)
    windFlag:update(dt)
    diceHand:update(dt)
    powerSelector:update(dt)
    clubSelector:update(dt)
    angleSelector:update(dt)
    spinner:update(dt)
    course:update(dt)
end

function love.draw()
    if not gameOver then
        ballLie:draw()
        windFlag:draw()
        powerSelector:draw()
        clubSelector:draw()
        angleSelector:draw()
        diceHand:draw()
        diceButton:draw()
        spinner:draw()

        for i, field in ipairs(fields) do
            field:draw()
        end
    end
    
    githubLink:draw()
    shotTable:draw()


    course:draw()

    if gameOver then
        fields[Constants.field_title]:draw()
        fields[Constants.field_hole]:draw()
        fields[Constants.field_courseName]:draw()
        gameOverField:draw()
    end
end

function loadCourse(courseNum) 
    course = CourseLoader:loadCourse(courseNum, 780, 60, shotComplete, courseComplete)
    course:setShotPower(player:calculateClubForNextShot(course:getDistanceToPin(), false))
    windFlag:setRandomWindSpeed()
    ballLie:setOnTee()
    spinner.isOnGreen = false

    fields[Constants.field_distance]:update(Ext.round(course:getDistanceToPin(), 0) .. " Yards To Pin")
    fields[Constants.field_shot]:update("Shot " .. player.shotNum)

    fields[Constants.field_hole]:update("Hole " .. course.hole .. "   Par " .. course.par .. "   " .. course.lengthInYards .. " Yards")
    fields[Constants.field_courseName]:update(Constants.courseNames[courseNum])
end

function love.keypressed(key)
    if key == "escape" then
        love.event.push("quit")
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 and not gameOver then
        githubLink:mousePressed(x, y)
        powerSelector:mousePressed(x, y)
        clubSelector:mousePressed(x, y)
        angleSelector:mousePressed(x, y)
        diceHand:mousePressed(x, y)
        diceButton:mousePressed(x, y)
        spinner:mousePressed(x, y)
    end
end

function love.mousereleased(x, y, button, istouch, presses)
    if button == 1 and not gameOver then
        githubLink:mouseReleased()
        powerSelector:mouseReleased(x, y)
        clubSelector:mouseReleased(x, y)
        angleSelector:mouseReleased(x, y)
        diceHand:mouseReleased(x, y)
        diceButton:mouseReleased(x, y)
        spinner:mouseReleased(x, y)
    end
end

function diceButton_Clicked()
    if gameOver then
        return
    end

    fields[Constants.field_rolls]:clear()
    fields[Constants.field_rollResult]:clear()
    _setEnabledOnSelectors(false)
    diceButton:setEnabled(false)
    
    soundEffect:startRolling()
    diceHand:roll()
end

function spinnerButton_Clicked()
    if gameOver then
        return
    end
    
    diceButton:setEnabled(false)
    course:takeShot((Debug.TurnOffDiceScore and 1.0) or diceHand.score, 
                    (Debug.TurnOffStrokeError and 0) or spinner:stopRotationAndGetError(), 
                    (Debug.TurnOffWindSpeed and 0) or windFlag:getWindSpeed(), 
                    player:isPutterSelected())
end

function clubChangedEvent()
    course:setShotPower(player:getClub().distance)
    if powerSelector and clubSelector then
        powerSelector:refresh()
        clubSelector:refresh()
    end
end

function rollComplete(score, description)
    soundEffect:stopRolling()
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

function shotComplete(distanceHit, distanceToPin, isOutOfBounds)
    _setEnabledOnSelectors(true)
    diceHand:reset()
    diceButton:setEnabled(true)
    player:calculateClubForNextShot(distanceToPin, course:getCourseType())
    angleSelector:refresh()

    if distanceToPin < player:getClub().distance then
        course:setShotPower(math.ceil(distanceToPin / 5) * 5)
        powerSelector:refresh()
    end

    spinner:hide()
    fields[Constants.field_rolls]:clear()
    fields[Constants.field_rollResult]:clear()
    fields[Constants.field_shot]:update("Shot " .. player:shotComplete(isOutOfBounds))
    fields[Constants.field_distance]:update(Ext.round(distanceToPin, 0) .. " Yards To Pin")

    windFlag:setRandomWindSpeed()
    ballLie:set(course:getCourseType())
    spinner.isOnGreen = course:getCourseType() == Constants.course_green
end

function courseComplete()
    shotComplete(0, 0)
    shotTable:addHole(courseNum, ShotTableItem(course.par, player.shotNum))
    
    if courseNum == 9 then
        gameOver = true
        _gameOver()
        return
    end

    player.shotNum = 1
    courseNum = courseNum + 1
    loadCourse(courseNum)    

    course:setShotPower(player:calculateClubForNextShot(course.lengthInYards, false))
    _refreshSelectors()

    soundEffect:playHole()
end

_setEnabledOnSelectors = function(isEnabled)
    clubSelector:setEnabled(isEnabled)
    powerSelector:setEnabled(isEnabled)
    angleSelector:setEnabled(isEnabled)
end

_refreshSelectors = function()
    clubSelector:refresh()
    powerSelector:refresh()
    angleSelector:refresh()
end

_gameOver = function()
    _setEnabledOnSelectors(false)
    diceHand:reset()
    diceButton:setEnabled(false)
    spinner:hide()
end