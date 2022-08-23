name = "Fulldark"
description = "Fullbright but dark"

importLib("RenderThreeD.lua")

function render3d()
    gfx.color(0, 0, 0)

    x, y, z = player.position()

    cube(x - 6, y - 6, z - 6, 12)
    cubexyz(x - 1, y + 1, z - 1, 3, 3, 3)
end
