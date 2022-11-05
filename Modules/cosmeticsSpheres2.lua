name = "spher"
description = "testing spheres in cosmetics"

importLib("cosmeticTools")
importLib("logger")

function render3d()
    if player.perspective() == 0 then return end
    updateCosmeticTools()

    enableShading()

    -- local Obj = Object:new(0, 1.2, 0)
    --     :attachToHead()
    -- Sphere:new(Obj, 0, 0, 0, 1)
    --     :setDetail("Normal")
    --     :rotateSelf(0, os.clock(), 0)
    --     :setStretch(2, 1, 0.6)
    --     :render({ 255, 0, 255 })

    -- setLightDirection(math.sin(os.clock()), 0, math.cos(os.clock()))
    setLightDirection(-1, 0, 0)

    local Crown = Object:new(0, 0.35, 0)
        :attachToHead()
    Cube:new(Crown, 0, 0, 0, 0.55, 0.2, 0.55)
        :render({ 255, 255, 0 })

    for i = 1, 4, 1 do
        Cube:new(Crown, 0.25, 0, 0, 0.1, 0.3, 0.1)
            :rotateObject(0, math.rad(i * 90), 0)
            :render({ 255, 255, 0 })
        Sphere:new(Crown, 0.3, 0, 0, 0.05)
            :setDetail("Low")
            :rotateObject(0, math.rad(i * 90), 0)
            :setStretch(1, 1, 3)
            :render({ 255, 0, 50 })
    end
end
