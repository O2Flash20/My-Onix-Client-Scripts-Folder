name = "Mini Map"
description = "good performance?????"

importLib("logger.lua")
importLib("MinimapBlockTools.lua")

sizeX = 100
sizeY = 100
positionX = 0
positionY = 100

worldMap = {}
radius = 30
function render(deltaTime)
    UpdateMapTools()

    px, py, pz = player.position() --GLOBAL

    -- drawing the ui
    for i = -radius, radius, 1 do
        for j = -radius, radius, 1 do
            local blockPosX = px + i
            local blockPosZ = pz + j
            local worldMapEntry = worldMap[toString(blockPosX) .. "," .. toString(blockPosZ)]
            if (worldMapEntry) then
                gfx.color(worldMapEntry[1], worldMapEntry[2], worldMapEntry[3])
            else
                gfx.color(51, 51, 51)
            end
            gfx.rect(
                (i + radius) * (sizeX / (radius * 2)), (j + radius) * (sizeY / (radius * 2)),
                (sizeX / (radius * 2)), (sizeY / (radius * 2))
            )
        end
    end
end

function update()
    -- px, py, pz = player.position()

    -- worldMap[toString(px) .. "," .. toString(pz)] = getColor(dimension.getBlock(px, py - 1, pz))
    -- getBlock(px, pz)

    if (py == 69) then
        for i = -radius, radius, 1 do
            for j = -radius, radius, 1 do
                getBlock(px + i, pz + j)
            end
        end
    end
end

-- gets the block at the calculated y position and adds it to the worldMap table
checkLimit = 10
function getBlock(x, z)
    local yLevel = py
    local i = 0

    function getIsEdge()
        return dimension.getBlock(x, yLevel, z).name ~= "air" and dimension.getBlock(x, yLevel + 1, z).name == "air"
    end

    while getIsEdge() == false do
        if i > checkLimit then break end

        if dimension.getBlock(x, yLevel, z).name == "air" then
            -- go down
            yLevel = yLevel - 1
        else
            -- go up
            yLevel = yLevel + 1
        end
        i = i + 1
    end

    worldMap[toString(x) .. "," .. toString(z)] = getColor(dimension.getBlock(x, yLevel, z))
    log({ x, yLevel, z })
end

function getColor(block)
    return getMapColorId(block.id, block.data)
end

function generate_key_list(t)
    local keys = {}
    for k, v in pairs(t) do
        keys[#keys + 1] = k
    end
    return keys
end
