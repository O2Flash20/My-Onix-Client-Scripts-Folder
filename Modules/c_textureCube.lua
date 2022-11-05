name = "Cosmetic Texture Test"
description = "hello"

importLib("cosmeticTools")

function render3d()
    if player.perspective() == 0 then return end
    updateCosmeticTools()

    Obj = Object:new(0, 2, 0)
        :attachToHead()
    Cube:new(Obj, 0, 0, 0, 1, 10, 1)
        :renderTexture("textures/blocks/stone")
end
