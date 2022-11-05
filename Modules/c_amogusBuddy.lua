name = "Amogus Cosmetic"
description = "Gives you a little amogus friend."

importLib("cosmeticTools")
importLib("logger")

function render3d()
    if player.perspective() == 0 then return end
    updateCosmeticTools()

    enableShading()

    setShadowDarkness(0.3)

    setLightDirectionSun()

    AmogusBody = Object:new(0.4, 0.55, 0)
        :attachToBody()
    -- body
    Sphere:new(AmogusBody, 0, 0, 0, 0.15)
        :setDetail("Low")
        :setStretch(0.9, 1.2, 0.85)
        :render({ 255, 0, 0 })
    -- legs
    for i = -1, 1, 2 do
        Sphere:new(AmogusBody, i / 15, -0.12, 0, 0.06)
            :setDetail("Low")
            :setStretch(1, 2.1, 1.6)
            :rotateObject(math.sin(i * os.clock() * 5) / 5, 0, 0)
            :render({ 150, 0, 0 })
    end
    -- visor
    Sphere:new(AmogusBody, 0, 0.05, 0.11, 0.05)
        :setDetail("Low")
        :setStretch(1.8, 1.3, 0.9)
        :render({ 0, 255, 255 })
end
