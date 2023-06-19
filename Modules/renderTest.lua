name = "render test"
description = "test whatever"

i = 0
function render3d(dt)
    px, py, pz = player.position()

    for i = 1, 10, 1 do
        for j = 1, 10, 1 do
            for k = 1, 10, 1 do
                gfx.tquad(
                    px + i, py + k, pz + j, 0, 0,
                    px + i, py + k, pz + j + 1, 0, 1,
                    px + i + 1, py + k, pz + j + 1, 1, 1,
                    px + i + 1, py + k, pz + j, 1, 0,
                    "textures/blocks/netherite_block"
                )
            end
        end
    end
end
