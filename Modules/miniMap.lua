name = "Mini Map"
description = "good performance?????"

importLib("MinimapBlockTools.lua")

sizeX = 100
sizeY = 100
positionX = 0
positionY = 100

radius = 50
client.settings.addInt("Radius", "radius", 0, 150)
checkLimit = 50
client.settings.addInt("Height", "checkLimit", 0, 100)

worldMap = {}
firstFrame = true
function render(deltaTime)
    UpdateMapTools()

    px, py, pz = player.position() --GLOBAL
    drawColor = { 0, 0, 0 }

    if firstFrame then
        -- fill the full screen on the first time
        for i = -radius, radius, 1 do
            for j = -radius, radius, 1 do
                getBlock(px + i, pz + j)
            end
        end

        firstFrame = false
    end

    -- drawing the ui
    for i = -radius, radius, 1 do
        for j = -radius, radius, 1 do
            local blockPosX = px + i
            local blockPosZ = pz + j

            local worldMapEntry
            if worldMap[blockPosX] then worldMapEntry = worldMap[blockPosX][blockPosZ] end
            if (worldMapEntry) then
                if drawColor[1] == worldMapEntry[1] and drawColor[2] == worldMapEntry[2] and
                    drawColor[3] == worldMapEntry[3] then
                    -- color already right, do nothing
                else
                    gfx.color(worldMapEntry[1], worldMapEntry[2], worldMapEntry[3])
                    drawColor = { worldMapEntry[1], worldMapEntry[2], worldMapEntry[3] }
                end
            else
                if drawColor[1] == 51 and drawColor[2] == 51 and drawColor[3] == 51 then
                    -- color already right, do nothing
                else
                    gfx.color(51, 51, 51)
                    drawColor = { 51, 51, 51 }
                end
            end
            gfx.rect(
                (i + radius) * (sizeX / (radius * 2)), (j + radius) * (sizeY / (radius * 2)),
                (sizeX / (radius * 2)), (sizeY / (radius * 2))
            )
        end
    end

    -- drawing the arrow
    -- local gridSize = sizeX / (radius * 2)
    -- log(gridSize)
    -- yaw, pitch = player.rotation()
    -- gfx.color(255, 0, 0)
    -- x1, y1, x2, y2, x3, y3, x4, y4 = directionLine(math.rad(yaw + 90), 13,
    --     ((gridSize / 2) * sizeX / gridSize) - sizeX / gridSize / 2,
    --     (gridSize / 2) * sizeX / gridSize - sizeX / gridSize / 2)
    -- gfx.triangle(x1 + sizeX / 2, y1 + sizeX / 2, x2 + sizeX / 2, y2 + sizeX / 2, x3 + sizeX / 2, y3 + sizeX / 2)
    -- gfx.triangle(x4 + sizeX / 2, y4 + sizeX / 2, x3 + sizeX / 2, y3 + sizeX / 2, x2 + sizeX / 2, y2 + sizeX / 2)

    -- directionTriangle(math.rad(yaw + 90), 13, ((gridSize / 2) * sizeX / gridSize) - sizeX / gridSize / 2,
    --     (gridSize / 2) * sizeX / gridSize - sizeX / gridSize / 2)
end

function update()
    if lastPos == nil then
        px, py, pz = player.position()
        lastPos = { px, pz }
    end

    -- when move
    if math.abs(px - lastPos[1]) < 40 and math.abs(pz - lastPos[2]) < 40 then
        -- log({ math.abs(px - lastPos[1]), math.abs(pz - lastPos[2]) })
        if px > lastPos[1] then
            -- moved right, load right
            for i = 1, px - lastPos[1], 1 do
                for j = -radius, radius, 1 do
                    getBlock(px + radius - i, pz + j)
                end
            end
        end
        if px < lastPos[1] then
            -- moved left, load left
            for i = 1, lastPos[1] - px, 1 do
                for j = -radius, radius, 1 do
                    getBlock(px - radius + i, pz + j)
                end
            end
        end
        if pz > lastPos[2] then
            -- moved up, load up
            for i = 1, pz - lastPos[2], 1 do
                for j = -radius, radius, 1 do
                    getBlock(px + j, pz + radius - i)
                end
            end
        end
        if pz < lastPos[2] then
            -- moved down, load down
            for i = 1, lastPos[2] - pz, 1 do
                for j = -radius, radius, 1 do
                    getBlock(px + j, pz - radius + i)
                end
            end
        end
    else
        -- redo all spots on the map
        -- for i = -radius, radius, 1 do
        --     for j = -radius, radius, 1 do
        --         getBlock(px + i, pz + j)
        --     end
        -- end
    end

    lastPos = { px, pz } --GLOBAL
end

-- gets the block at the calculated y position and adds it to the worldMap table
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

    if worldMap[x] then
        worldMap[x][z] = getColor(dimension.getBlock(x, yLevel, z))
    else
        local zArray = {}
        zArray[z] = getColor(dimension.getBlock(x, yLevel, z))
        worldMap[x] = zArray
    end
end

function getColor(block)
    return getMapColorId(block.id, block.data)
end

-- function directionLine(a, l, x0, y0)
--     widthDiv = 20

--     x01 = x0 + l * math.cos(a)
--     y01 = y0 + l * math.sin(a)

--     a1 = a + math.rad(90)

--     x1 = x01 + (l / widthDiv) * math.cos(a1)
--     y1 = y01 + (l / widthDiv) * math.sin(a1)

--     x2 = x0 + (l / widthDiv) * math.cos(a1)
--     y2 = y0 + (l / widthDiv) * math.sin(a1)

--     a2 = a - math.rad(90)

--     x3 = x01 + (l / widthDiv) * math.cos(a2)
--     y3 = y01 + (l / widthDiv) * math.sin(a2)

--     x4 = x0 + (l / widthDiv) * math.cos(a2)
--     y4 = y0 + (l / widthDiv) * math.sin(a2)

--     return x2, y2, x1, y1, x4, y4, x3, y3
-- end

-- function directionTriangle(a, l, x0, y0)
--     x2, y2, x1, y1, x4, y4, x3, y3 = directionLine(a, l, x0, y0)

--     x5 = x1 + (l / 5) * math.cos(a + 90)
--     y5 = y1 + (l / 5) * math.sin(a + 90)

--     x6 = x3 + (l / 5) * math.cos(a - 90)
--     y6 = y3 + (l / 5) * math.sin(a - 90)

--     x7 = x01 + (l / 3) * math.cos(a)
--     y7 = y01 + (l / 3) * math.sin(a)

--     gfx.color(255, 0, 0)
--     gfx.triangle(x6 + sizeX / 2, y6 + sizeX / 2, x5 + sizeX / 2, y5 + sizeX / 2, x7 + sizeX / 2, y7 + sizeX / 2)
-- end

-- function generate_key_list(t)
--     local keys = {}
--     for k, v in pairs(t) do
--         keys[#keys + 1] = k
--     end
--     return keys
-- end
