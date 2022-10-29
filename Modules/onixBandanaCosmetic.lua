name = "Onix Bandana"
description = "A bandana cosmetic with the Onix logo."

importLib("cosmeticTools")

function render3d()
    if player.perspective() == 0 then return end

    updateCosmeticTools()

    enableShading()

    local Bandana = Object:new(0, 0.35, 0)
        :attachToHead()
    Cube:new(Bandana, 0, 0, 0, 0.5, 0.15, 0.5)
        :render({ 0, 100, 150 })

    local BandanaRopes = Object:new(0, 0.35, -0.25)
        :attachToHead()
        :rotateSelf(math.sin(os.clock()) / 10 + math.rad(-75), 0, 0)
    Cube:new(BandanaRopes, 0, 0, -0.25, 0.1, 0.005, 0.5)
        :rotateObject(0, math.rad(-25), 0)
        :render({ 0, 0, 50 })
    Cube:new(BandanaRopes, 0, 0, -0.1, 0.1, 0.005, 0.3)
        :rotateObject(0, math.rad(25), 0)
        :render({ 0, 0, 50 })

    local OnixLogo = Object:new(0, 0.35, 0.26)
        :attachToHead()
    -- inner circle
    Cube:new(OnixLogo, 0, 0, 0, 0.045, 0.045, 0.06)
        :render({ 0, 0, 100 })
    -- outer circle
    Cube:new(OnixLogo, 0, 0, -0.03, 0.09, 0.09, 0.09)
        :render({ 0, 255, 255 })
    Cube:new(OnixLogo, 0, 0, -0.025, 0.07, 0.1, 0.09)
        :render({ 0, 255, 255 })
    Cube:new(OnixLogo, 0, 0, -0.025, 0.1, 0.07, 0.09)
        :render({ 0, 255, 255 })
    -- ring
    Cube:new(OnixLogo, 0, 0, 0, 0.2, 0.03, 0.02)
        :rotateSelf(0, 0, math.rad(-30))
        :render({ 0, 0, 100 })
    Cube:new(OnixLogo, 0, 0, 0, 0.15, 0.04, 0.02)
        :rotateSelf(0, 0, math.rad(-30))
        :render({ 0, 0, 100 })
end
