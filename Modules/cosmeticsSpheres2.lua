name = "spher"
description = "testing spheres in cosmetics"

importLib("cosmeticTools")
importLib("logger")

function render3d()
    if player.perspective() == 0 then return end
    updateCosmeticTools()

    local Obj = Object:new(0, 1, 0)
        :attachToHead()
    Sphere:new(Obj, math.sin(os.clock()), math.sin(os.clock()), math.sin(os.clock()), 1)
        :setDetail("Normal")
        :render()
end
