name = "Capes Lib Test"
description = "Making capes using the lib"

importLib("cosmeticTools")

CapeTexture = Texture:newSource("OnixCape", 64, 32)
capeTextureBack = Texture:new()
    :addImage(CapeTexture, 12, 1, 21, 16) -- image 1

capeTextureFront = Texture:new()
    :addImage(CapeTexture, 12, 1, 21, 16)--  image 1
    :addImage(CapeTexture, 12, 3, 21, 14)--  image 2
    :addImage(CapeTexture, 12, 5, 21, 13) -- image 3

capeTextureSides = Texture:new()
    :addImage(CapeTexture, 0, 1, 0, 16) --   image 1

Stone = Texture:newSource("textures/blocks/stone", 16, 16)
Wood = Texture:newSource("textures/blocks/planks_oak", 16, 16)
AnimatedTexture = Texture:new()
    :addImage(Stone)--1
    :addImage(Wood)-- 2
    :addFrame(1, 1)
    :addFrame(2, 0.1)

function update()
    updateCapes()
    updateTextures()

    -- speed reactive cape
    if velX then
        local speed = math.clamp(math.floor(math.sqrt(velX ^ 2 + velY ^ 2 + velZ ^ 2) * 2) + 1, 1, 3)
        capeTextureFront:setFrame(speed)
    end

    capeTextureBack:setFrame(1)
    capeTextureSides:setFrame(1)
end

function render3d()
    if player.perspective() == 0 then return end
    updateCosmeticTools()

    local Cape = Object:new(0, 0, 0)
        :attachAsCape()
    Cube:newCape(Cape)
        :renderTexture(capeTextureBack.texture, capeTextureFront.texture,
            capeTextureSides.texture, capeTextureSides.texture, capeTextureSides.texture, capeTextureSides.texture
        )

    local Block = Object:new(0, 2, 0)
        :attachToPlayer()
    Cube:new(Block, 0, 0, 0, 1, 1, 1)
        :renderTexture(AnimatedTexture.texture)

    Sphere:new(Block, 1, 0, 0, 0.4)
        :renderTexture(capeTextureFront.texture)
end
