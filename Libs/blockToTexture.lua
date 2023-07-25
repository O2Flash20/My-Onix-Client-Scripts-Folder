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

function getTexture(x, y, z, face)
    local blockSelected = dimension.getBlock(x, y, z)
    local blockName = blockSelected.name
    local direction = faceToDirection[face]

    if blockName == "air" or blockName == "client_request_placeholder_block" then return end

    if toBlocksTranslations[blockName] then
        blockName = toBlocksTranslations[blockName]
    end


    local textureFrom_blocks
    if blocks[blockName].carried_textures then
        textureFrom_blocks = blocks[blockName].carried_textures
    else
        textureFrom_blocks = blocks[blockName].textures
    end
    if type(textureFrom_blocks) == "table" then
        if textureFrom_blocks.side then
            if dataAndFaceToTextureSide[blockSelected.data] then
                textureFrom_blocks = textureFrom_blocks[dataAndFaceToTextureSide[blockSelected.data][face]]
            else
                textureFrom_blocks = textureFrom_blocks["up"]
            end
        else
            textureFrom_blocks = textureFrom_blocks[direction]
        end
    end

    local finalTextures
    if terrain_texture[textureFrom_blocks] == nil then
        finalTextures = "textures/blocks/" .. textureFrom_blocks
    else
        if textureFrom_blocks == "grass_carried" then
            finalTextures = "textures/blocks/grass_carried.png"
        else
            finalTextures = terrain_texture[textureFrom_blocks].textures
        end
    end

    local output = ""
    if type(finalTextures) == "table" then
        if string.find(textureFrom_blocks, "log_") then
            output = finalTextures[logIDToNumber[blockSelected.id]]
        elseif string.find(textureFrom_blocks, "log2_") then
            log("hi")
            output = finalTextures[log2IDToNumber[blockSelected.id]]
        else
            output = finalTextures[blockSelected.data + 1]
        end
    else
        output = finalTextures
    end

    return output
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

toBlocksTranslations = {
    concrete_powder = "concretePowder",
    birch_log = "log",
    oak_log = "log",
    spruce_log = "log",
    jungle_log = "log",
    acacia_log = "log2",
    dark_oak_log = "log2"
}

logIDToNumber = {}
logIDToNumber[17] = 1
logIDToNumber[824] = 2
logIDToNumber[825] = 3
logIDToNumber[826] = 4

log2IDToNumber = {}
logIDToNumber[162] = 1
logIDToNumber[827] = 2

faceToDirection = {}
faceToDirection[0] = "down"
faceToDirection[1] = "up"
faceToDirection[2] = "north"
faceToDirection[3] = "south"
faceToDirection[4] = "west"
faceToDirection[5] = "east"

dataAndFaceToTextureSide = {}

dataAndFaceToTextureSide[0] = {}
dataAndFaceToTextureSide[0][0] = "down"
dataAndFaceToTextureSide[0][1] = "up"
dataAndFaceToTextureSide[0][2] = "side"
dataAndFaceToTextureSide[0][3] = "side"
dataAndFaceToTextureSide[0][4] = "side"
dataAndFaceToTextureSide[0][5] = "side"

dataAndFaceToTextureSide[1] = {}
dataAndFaceToTextureSide[1][0] = "side"
dataAndFaceToTextureSide[1][1] = "side"
dataAndFaceToTextureSide[1][2] = "side"
dataAndFaceToTextureSide[1][3] = "side"
dataAndFaceToTextureSide[1][4] = "down"
dataAndFaceToTextureSide[1][5] = "up"

dataAndFaceToTextureSide[2] = {}
dataAndFaceToTextureSide[2][0] = "side"
dataAndFaceToTextureSide[2][1] = "side"
dataAndFaceToTextureSide[2][2] = "down"
dataAndFaceToTextureSide[2][3] = "up"
dataAndFaceToTextureSide[2][4] = "side"
dataAndFaceToTextureSide[2][5] = "side"
