local Ext = {}

Ext.round = function(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

Ext.min = function(num1, num2)
    if math.abs(num1) < math.abs(num2) then
        return num1
    else
        return num2
    end
end

return Ext