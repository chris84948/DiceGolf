local CourseLoader = {}
local _loadObjectLayer

function CourseLoader:loadCourse(num, x, y, shotComplete, courseComplete)
    local filename = "courses/course" .. 1 .. ".json"
    local jsonString, _ = love.filesystem.read(filename)
    local courseTable = Json.decode(jsonString)

    local course = Course(x, y, num, courseTable.width, courseTable.height, courseTable.tileheight, courseTable.properties, shotComplete, courseComplete)
    
    for i, layer in ipairs(courseTable.layers) do
        if string.upper(layer.name) == "TILE LAYER 1" then
            course:setTileData(layer.data)
        elseif string.upper(layer.name) == "TILE LAYER 2" then
            course:setTileObjectData(layer.data)
        elseif string.find(string.upper(layer.name), "OBJECT") then
            _loadObjectLayer(course, layer)
        end
    end

    course:loadComplete()
    return course
end

_loadObjectLayer = function(course, layer)
    for i, object in ipairs(layer.objects) do
        if string.find(string.upper(object.name), "TEE") then
            course:setTee(object.x, object.y)
        elseif string.find(string.upper(object.name), "HOLE") then
            course:setHole(object.x, object.y)
        end
    end
end

return CourseLoader