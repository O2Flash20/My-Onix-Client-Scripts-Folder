name = "Logger"
description = "Logs things better"

positionX = 500
positionY = 25
sizeX = 300
sizeY = 300

logs = {}

wRatio=0.5
client.settings.addFloat("Width", "wRatio", 0, 1)

tScale=1
client.settings.addFloat("Text Scale", "tScale", 0, 5)

showNumber = true
client.settings.addBool("Show log number", "showNumber")

backColor = {51, 51, 51}
client.settings.addColor("Background Color", "backColor")

foreColor = {255, 255, 255}
client.settings.addColor("Foreground Color", "foreColor")

font = gui.font()
function render()
    sizeX=(wRatio)*500
    sizeY=(-wRatio+1)*500

    gfx.color(backColor.r, backColor.g, backColor.b, backColor.a)
    gfx.rect(0, 0, sizeX, sizeY)

    heightLimit = math.floor(sizeY/((font.height+3)*tScale))

    for i = 1, #logs, 1 do
        if font.width(logs[i], tScale) > sizeX then
            table.insert(logs, i+1, string.sub(logs[i], math.floor((sizeX/font.width(logs[i], tScale))*#logs[i])+1, #logs[i]))
            logs[i] = string.sub(logs[i], 0, math.floor((sizeX/font.width(logs[i], tScale))*#logs[i]))
        end
    end

    while #logs>heightLimit do
        table.remove(logs, #logs)
    end

    start = 250
    for i = 1, #logs, 1 do
        gfx.color(foreColor.r, foreColor.g, foreColor.b, foreColor.a)
        gfx.text(0, (i-1)*(font.height+3)*tScale, logs[i], tScale)
    end
end

numLogs = 0
event.listen("LocalDataReceived",function (identifier, content)
    if identifier == "logMessage" then
        numLogs = numLogs + 1
        if showNumber then
            table.insert(logs, 1, "|"..numLogs.."| "..content)
        else
            table.insert(logs, 1, "_ "..content)
        end
    end
end)

-- USE FUNCTION log(input)

-- TO BE ABLE TO LOG IN ANOTHER MODULE, ADD THIS:
-- function getTable(a)output="{"for b=1,#a,1 do output=output..toString(a[b])if b~=#a then output=output..", "end end;output=output.."}"return output end;function toString(c)if type(c)=="string"then return[["]]..c..[["]]end;if type(c)=="table"then return getTable(c)end;if type(c)=="function"then return"FUNCTION"end;return tostring(c)end;function log(d)sendLocalData("logMessage",toString(d))end

-- OR THE NOT MINIFIED VERSION:
-- function getTable(table)
--     output = "{"
--     for i = 1, #table, 1 do
--         output = output..toString(table[i])
--         if i ~= #table then
--             output = output..", "
--         end
--     end
--     output = output.."}"
--     return output
-- end
-- function toString(input)
--     if type(input) == "string" then
--         return [["]]..input..[["]]
--     end
--     if type(input) == "table" then
--         return getTable(input)
--     end
--     if type(input) == "function" then
--         return "FUNCTION"
--     end
--     return tostring(input)
-- end
-- function log(message)
--     sendLocalData("logMessage", toString(message))
-- end