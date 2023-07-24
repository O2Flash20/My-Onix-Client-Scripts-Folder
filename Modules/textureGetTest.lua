-- Made By O2Flash20 🙂

name = "Texture get test"
description = "tells you the texture you're looking at, hopefully"

sizeX = 100
sizeY = 100
positionX = 0
positionY = 100

importLib("logger")

blocks = {}
terrain_texture = {}

function postInit()
    network.get(
        "https://raw.githubusercontent.com/Mojang/bedrock-samples/main/resource_pack/blocks.json",
        "blocks.json"
    )

    network.get(
        "https://raw.githubusercontent.com/Mojang/bedrock-samples/main/resource_pack/textures/terrain_texture.json",
        "terrain_texture.json"
    )
end

function getTexture(x, y, z, direction)
    local blockSelected = dimension.getBlock(x, y, z)
    local blockName = blockSelected.name

    if blockName == "air" then return end

    if translations[blockName] then
        blockName = translations[blockName]
    end

    local textureFrom_blocks = blocks[blockName].textures
    if type(textureFrom_blocks) == "table" then
        textureFrom_blocks = textureFrom_blocks[direction]
    end

    local finalTextures
    if terrain_texture[textureFrom_blocks] == nil then
        finalTextures = "textures/blocks/" .. textureFrom_blocks
    else
        finalTextures = terrain_texture[textureFrom_blocks].textures
    end

    local output = ""
    if type(finalTextures) == "table" then
        log(finalTextures[blockSelected.data + 1])
        output = finalTextures[blockSelected.data + 1]
    else
        log(finalTextures)
        output = finalTextures
    end

    return output
end

function render()
    local posx, posy, posz = player.selectedPos()
    local face = player.selectedFace()

    local tex = getTexture(posx, posy, posz, "up")

    gfx.tquad(
        0, 100, 0, 1,
        100, 100, 1, 1,
        100, 0, 1, 0,
        0, 0, 0, 0,
        tex
    )
end

function onNetworkData(code, identifier, data)
    log(identifier)
    if identifier == "blocks.json" then
        blocks = jsonToTable(data)
    end
    if identifier == "terrain_texture.json" then
        terrain_texture = jsonToTable(data).texture_data
    end
end

translations = {
    concrete_powder = "concretePowder"
}

--! logs, tgas flipbook textures, tops of some slabs?
-- grass and leaves use the "carried" texture

faceToDirection = {}
faceToDirection[0] = "down"
faceToDirection[1] = "up"
faceToDirection[2] = "north"
faceToDirection[3] = "south"
faceToDirection[4] = "west"
faceToDirection[5] = "east"
