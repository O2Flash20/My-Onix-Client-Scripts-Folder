name = "Projectile Motion grapher"
description = "to find the projectile physics"

file = nil
recording = false
time = 0

ox, oy, oz = nil, nil, nil

lastVal = nil
function render(dt)
    if recording then
        local px, py, pz = player.pposition()
        if px - ox ~= lastVal then
            io.write(time .. "," .. px - ox .. "\n")
            lastVal = px - ox
        end

        time = time + dt
    end
end

event.listen("KeyboardInput", function(key, down)
    if key == 90 and down then
        if not recording then
            file = io.open("projectileMotion.txt", "w")
            io.output(file)
            time = 0
            ox, oy, oz = player.pposition()
            print("recording")
        else
            io.close(file)
            print("not recording")
        end
        recording = not recording
    end
end)
