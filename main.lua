function initialize()
    love.window.setMode(1200, 800)

    Object = require("libs.classic.classic")
    Constants = require("constants")
    Json = require("libs.json.json")
    CourseLoader = require("courseLoader")
    require("tile")
    require("course")
    require("ball")
end

function love.load()
    initialize()

    course = CourseLoader:loadCourse(1, 0, 0)
end

function love.update(dt)
    course:update(dt)
end

function love.draw()
    course:draw()
end


function love.keypressed(key)
    if key == "escape" then
        love.event.push("quit")
    elseif key == "space" then
        course:hitBall()
    end
end