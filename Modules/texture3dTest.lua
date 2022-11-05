name = "Texture Test"
description = "Testing new 3d textures."

function render3d()
    gfx.ttriangle(
        0, 100, 0, 0, 0,
        0, 101, 1, 1, 0,
        1, 100, 0, 1, 1,
        "textures/map/map_background"
    )
end
