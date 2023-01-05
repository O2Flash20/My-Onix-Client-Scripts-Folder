name = "Cosmetics Lib Custom Capes"
description = "An example script for the cosmetics library."

importLib("cosmeticTools")

capeTexture = Texture:newSource("OnixCape.png", 64, 32)

capeTextureBack = Texture:new()
    :addImage(capeTexture, 12, 1, 21, 16)
capeTextureFront = Texture:new()
    :addImage(capeTexture, 1, 1, 10, 16)
capeTextureLeft = Texture:new()
    :addImage(capeTexture, 0, 1, 1, 17)
capeTextureRight = Texture:new()
    :addImage(capeTexture, 11, 0, 12, 17)
capeTextureTop = Texture:new()
    :addImage(capeTexture, 1, 0, 11, 1)
capeTextureBottom = Texture:new()
    :addImage(capeTexture, 12, 1, 22, 1)

function update()
    updateCapes() -- needed for the cape
    updateTextures() -- needed for textures
end

function render3d()
    if player.perspective() == 0 then return end -- doesn't render the cosmetics if you're in first person
    updateCosmeticTools() -- updates useful globals

    local Cape = Object:new(0, 0, 0)
        :attachAsCape()
    Cube:newCape(Cape)
        :renderTexture(
            capeTextureBack.texture,
            capeTextureFront.texture,
            capeTextureLeft.texture,
            capeTextureRight.texture,
            capeTextureTop.texture,
            capeTextureBottom.texture
        )

end
