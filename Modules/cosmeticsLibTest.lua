name = "Cosmetics Test"
description = "test module for cosmeticTools"

importLib("cosmeticTools")
importLib("logger")

function render3d()
    if player.perspective() == 0 then return end

    updateCosmeticTools()

    enableShading()

    local Backpack = Object:new(0, 0.05, -0.19)
        :attachToBody()
    Cube:new(Backpack, 0, 0, 0, 0.4, 0.5, 0.15)
        :render({ 0, 25, 100 })
    Cube:new(Backpack, 0, -0.05, -0.05, 0.39, 0.35, 0.15)
        :render({ 0, 50, 150 })


    local Bandana = Object:new(0, 0.35, 0)
        :attachToHead()
    Cube:new(Bandana, 0, 0, 0, 0.5, 0.15, 0.5)
        :render({ 0, 0, 100 })


    local BandanaRopes = Object:new(0, 0.35, -0.25)
        :attachToHead()
        :rotateSelf(math.sin(os.clock()) / 10 + math.rad(-75), 0, 0)
    Cube:new(BandanaRopes, 0, 0, -0.25, 0.1, 0.005, 0.5)
        :rotateObject(0, math.rad(-25), 0)
        :render({ 0, 0, 50 })
    Cube:new(BandanaRopes, 0, 0, -0.1, 0.1, 0.005, 0.3)
        :rotateObject(0, math.rad(25), 0)
        :render({ 0, 0, 50 })


    local OnixPlanet = Object:new(0, 1, 0)
        :attachToPlayer()
        :rotateSelf(os.clock(), os.clock(), os.clock())
    Cube:new(OnixPlanet, 0, 0, 0, 0.4, 0.4, 0.4)
        :render({ 0, 200, 200 })

    for i = 1, 8, 1 do
        Cube:new(OnixPlanet, 0, 0, 0.5, 0.45, 0.01, 0.1)
            :rotateObject(0, math.rad(i * 45) + os.clock(), 0)
            :render({ 0, 0, 100 })
    end

    local Amogus = Object:new(0, 0, 1)
        :attachToBody()
        :rotateAttachment(math.sin(4 * os.clock()) / 10, 0, 0)
    Cube:new(Amogus, 0, 0, 0, 0.3, 0.4, 0.3)
        :render({ 255, 0, 0 })
    Cube:new(Amogus, 0, 0, -0.15, 0.2, 0.3, 0.2)
        :render({ 200, 0, 0 })
    Cube:new(Amogus, 0, 0.05, 0.1, 0.25, 0.15, 0.2)
        :render({ 0, 255, 255 })

    Cube:new(Amogus, 0.1, -0.2, 0, 0.15, 0.2, 0.15)
        :rotateObject(math.sin(10 * os.clock()) / 5, 0, 0)
        :render({ 255, 0, 0 })
    Cube:new(Amogus, -0.1, -0.2, 0, 0.15, 0.2, 0.15)
        :rotateObject(math.sin(10 * os.clock() + 3) / 5, 0, 0)
        :render({ 255, 0, 0 })
end
