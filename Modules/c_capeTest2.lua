name = "Capes Lib Test"
description = "Making capes using the lib"

importLib("cosmeticTools")
importLib('logger')

enableShading()
setLightDirectionSun()

function update()
    updateCapes()
end

function render3d()
    if player.perspective() == 0 then return end
    updateCosmeticTools()

    local Cape = Object:new(0, 0, 0)
        :attachAsCape()
    Cube:new(Cape, 0, -0.45, -0.15, 0.6, 0.95, 0.05)
        :render({ 255, 0, 0 })
end
