-- Made by O2Flash20

name = "Lag Switch"
description = "Freezes your game for a bit."

event.listen("KeyboardInput", function(key, down)
    if down and key == 77 then
        for i = 1, 200, 1 do
            for j = 1, 200, 1 do
                for k = 1, 100, 1 do
                    dimension.getBlock(k, i, j)
                end
            end
        end
    end
end)
