-- Made by O2Flash20

name = "Lag Switch"
description = "Freezes your game for a bit."

local keyDown = false
event.listen("KeyboardInput", function(key, down)
    -- M
    if key == holdKey then
        keyDown = down
    end

    if key == pauseKey then sleep(pauseLength.value) end
end)

function update()
    if keyDown then sleep(slowness.value) end
end

local clock = os.clock
function sleep(n)
    local t0 = clock()
    while clock() - t0 <= n do
    end
end

client.settings.addAir(5)

holdKey = 0x4D
client.settings.addKeybind("Hold to Slow Key", "holdKey")
slowness = client.settings.addNamelessFloat("Slowness (seconds)", 0, 10, 1)

client.settings.addAir(5)

pauseKey = 0x4E
client.settings.addKeybind("Pause Key", "pauseKey")
pauseLength = client.settings.addNamelessFloat("Pause length (seconds)", 0, 120, 5)
