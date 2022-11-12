name = "Texture Sphere Test"
description = "panem velim"

importLib("cosmeticTools")

function render3d()
    if player.perspective() == 0 then return end
    updateCosmeticTools()

    local Obj = Object:new(0, 1, 0)
        :attachToHead()
    Sphere:new(Obj, 0, 0, 0, 0.5)
        :setDetail("Normal")
        :renderTexture("textures/blocks/planks_oak")
    -- :renderTexture("redGradient")
end
