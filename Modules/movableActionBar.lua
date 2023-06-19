name = "Movable Action Bar"
description = "Allows you to move the action bar around."

positionX = 6
positionY = 60
sizeX = 35
sizeY = 10
scale = 1.0

client.settings.addNamelessCategory("Visual Settings")
textColor = client.settings.addNamelessColor("Text Color", { 255, 255, 255, 255 })
backgroundColor = client.settings.addNamelessColor("Background Color", { 0, 0, 0, 127 })
roundness = client.settings.addNamelessFloat("Background Radius", 0, 20, 0)
roundnessQuality = client.settings.addNamelessFloat("Background Roundness Quality", 0, 20, 0)
paddingX = client.settings.addNamelessFloat("Padding X", 0, 20, 3)
paddingY = client.settings.addNamelessFloat("Padding Y", 0, 20, 3)

client.settings.addNamelessCategory("Display Settings")
displayTime = client.settings.addNamelessFloat("Display Time", 0.1, 10, 3)
fadeTime = client.settings.addNamelessFloat("Fade Time", 0.1, 10, 1)
keepCentered = client.settings.addNamelessBool("Keep Centered", false)

currentTitle = ""

event.listen("TitleChanged", function(text, titleType)
    if titleType == "actionbar" then
        currentTitle = text
        return true
    end
end)

time = os.clock()

function render(deltaTime)
    if currentTitle ~= "" then
        local opacity = getOpacity()

        if time + displayTime.value < os.clock() then
            currentTitle = ""
            time = os.clock()
        end
        local textWidth = gui.font().width(currentTitle)
        local boxWidth = textWidth + paddingX.value
        local boxHeight = 10 + paddingY.value
        gfx.color(backgroundColor.r, backgroundColor.g, backgroundColor.b, opacity)
        gfx.roundRect(0, 0, boxWidth, boxHeight, roundness.value, roundnessQuality.value)
        if not keepCentered.value then
            gfx.color(textColor.r, textColor.g, textColor.b, opacity)
            gfx.text(paddingX.value / 2, paddingY.value / 2, currentTitle)
        else
            gfx.color(textColor.r, textColor.g, textColor.b, opacity)
            gfx.text((boxWidth - textWidth) / 2, paddingY.value / 2, currentTitle)
            positionX = (gui.width() / 2) - (boxWidth / 2)
        end
        sizeX = boxWidth
        sizeY = boxHeight
    else
        time = os.clock()
    end
end

function getOpacity()
    local y = 0

    local x = os.clock() - time
    local t = displayTime.value
    local a = fadeTime.value

    if a < x and x <= t - a then
        y = 1
    end

    if 0 <= x and x <= a / 2 then
        y = (4 / a ^ 3) * x ^ 3
    end
    if a / 2 < x and x <= a then
        y = -(1 / (2 * (-a / 2) ^ 3)) * (x - a) ^ 3 + 1
    end

    if t - a < x and x <= t - (a / 2) then
        y = (1 / (2 * (-a / 2) ^ 3)) * (x - (t - a)) ^ 3 + 1
    end
    if t - (a / 2) < x and x <= t then
        y = -(4 / a ^ 3) * (x - t) ^ 3
    end

    return y * 255
end
