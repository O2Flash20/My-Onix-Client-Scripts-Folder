-- Made By O2Flash20 🙂

name = "Cosmetics Pack V1"
description = "A collection of client-side cosmetics"

importLib("cosmeticTools")

SheathSource = Texture:newSource("textures/blocks/coal_block", 16, 16)
sheathTexture = Texture:new()
    :addImage(SheathSource, 0, 0, 16, 16)

BladeSource = Texture:newSource("textures/blocks/netherite_block", 16, 16)
bladeTexture = Texture:new()
    :addImage(BladeSource, 0, 2, 10, 14)

CrossGuardSource = Texture:newSource("textures/blocks/copper_block", 16, 16)
crossGuardTexture = Texture:new()
    :addImage(CrossGuardSource)

HandleSource = Texture:newSource("textures/blocks/prismarine_dark", 16, 16)
handleTexture = Texture:new()
    :addImage(HandleSource, 7, 0, 11, 16)

DetailSource = Texture:newSource("textures/blocks/copper_block", 16, 16)
detailTexture = Texture:new()
    :addImage(DetailSource, 9, 2, 11, 14)

function render3d()
    -- if player.perspective() == 0 then return end
    updateCosmeticTools()

    enableShading()
    setLightDirectionSun()

    KatanaSheath = Object:new(0.25, -0.3, 0)
        :attachToBody()

    -- KatanaSheath = Object:new(0, 0, 2)
    --     :attachToBody()

    -- sheath 1
    Cube:new(
        KatanaSheath,
        0, -0.2, 0,
        0.06, 0.8, 0.1
    )
        :rotateObject(45, 0, 0)
        :renderTexture(sheathTexture.texture)

    -- sheath 2
    Cube:new(
        KatanaSheath,
        0, -0.55, -0.02,
        0.06, 0.7, 0.1
    )
        :rotateObject(45, 0, 0)
        :renderTexture(sheathTexture.texture)

    -- blade
    Cube:new(
        KatanaSheath,
        0, 0.25, 0,
        0.02, 0.15, 0.08
    )
        :rotateObject(45, 0, 0)
        :renderTexture(bladeTexture.texture)

    -- crossguard
    Cube:new(
        KatanaSheath,
        0, 0.30, 0,
        0.15, 0.03, 0.2
    )
        :rotateObject(45, 0, 0)
        :renderTexture(crossGuardTexture.texture)

    -- handle
    Cube:new(
        KatanaSheath,
        0, 0.55, 0,
        0.07, 0.5, 0.09
    )
        :rotateObject(45, 0, 0)
        :renderTexture(handleTexture.texture)

    -- sheath detail
    Cube:new(
        KatanaSheath,
        0, -0.3, -0.01,
        0.07, 0.6, 0.05
    )
        :rotateSelf(math.rad(3), 0, 0)
        :rotateObject(45, 0, 0)
        :renderTexture(detailTexture.texture)
end

-- diamond sword or bow on back?
-- crown
-- mini you
