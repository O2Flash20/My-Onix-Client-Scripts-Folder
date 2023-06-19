name = "Freecam"
description = "A freecam script (what) (no way) (i made my own renderer in scripting)"

importLib("logger")

testButton = 1
client.settings.addKeybind("Test Button", "testButton")
event.listen("KeyboardInput", function(key, down)
    if key == testButton and down then
        -- initialScan()
        gridTest()
    end
end)

--------------v
radius = (8 * 3) / 2
Grid = {}
blocksToAddToGrid = {} -- {{x, y, z}, {x, y, z}, {x, y, z}}
function postInit()
    lastX, lastY, lastZ = player.position()
end

BlockAddingSpeed = 5000
function update()
    px, py, pz = player.position()
    log(#blocksToAddToGrid)
    -- log(#Grid)

    diffX, diffY, diffZ = px - lastX, py - lastY, pz - lastZ
    scanWithMovement(diffX, diffY, diffZ)

    local blocksAdded = 0
    while #blocksToAddToGrid > 0 do
        if blocksAdded >= BlockAddingSpeed then break end
        blocksAdded = blocksAdded + 1

        local block = blocksToAddToGrid[#blocksToAddToGrid]
        addBlockToGrid(block[1], block[2], block[3])
        table.remove(blocksToAddToGrid, #blocksToAddToGrid)
    end


    lastX, lastY, lastZ = px, py, pz
end

function initialScan()
    for x = -radius, radius, 1 do
        for y = -radius, radius, 1 do
            for z = -radius, radius, 1 do
                table.insert(blocksToAddToGrid, { px + x, py + y, pz + z })
            end
        end
    end
end

function scanWithMovement(diffX, diffY, diffZ)
    for x = 1, math.abs(diffX) do
        for y = -radius, radius do
            for z = -radius, radius do
                table.insert(blocksToAddToGrid, { px + math.sign(diffX) * (radius - x), py + y, pz + z })
            end
        end
    end
    for y = 1, math.abs(diffY) do
        for x = -radius, radius do
            for z = -radius, radius do
                table.insert(blocksToAddToGrid, { px + x, py + math.sign(diffY) * (radius - y), pz + z })
            end
        end
    end
    for z = 1, math.abs(diffZ) do
        for x = -radius, radius do
            for y = -radius, radius do
                table.insert(blocksToAddToGrid, { px + x, py + y, pz + math.sign(diffZ) * (radius - z) })
            end
        end
    end
end

function math.sign(num)
    if num >= 0 then
        return 1
    end
    if num < 0 then
        return -1
    end
end

function addBlockToGrid(x, y, z)
    local chunkX = math.floor(x / 8)
    local chunkY = math.floor(y / 8)
    local chunkZ = math.floor(z / 8)

    local inChunkX = math.floor(x % 8)
    local inChunkY = math.floor(y % 8)
    local inChunkZ = math.floor(z % 8)

    -- If the spot in the grid is already filled in, no need to add it again
    local thisBlockExists, block = pcall(function()
        return Grid[chunkX][chunkY][chunkZ][inChunkX][inChunkY][inChunkZ]
    end)
    if thisBlockExists and type(block) == "number" then return end
    --------------------------------------

    if Grid[chunkX] == nil then
        Grid[chunkX] = {}
    end
    if Grid[chunkX][chunkY] == nil then
        Grid[chunkX][chunkY] = {}
    end
    if Grid[chunkX][chunkY][chunkZ] == nil then
        Grid[chunkX][chunkY][chunkZ] = {}
    end
    if Grid[chunkX][chunkY][chunkZ][inChunkX] == nil then
        Grid[chunkX][chunkY][chunkZ][inChunkX] = {}
    end
    if Grid[chunkX][chunkY][chunkZ][inChunkX][inChunkY] == nil then
        Grid[chunkX][chunkY][chunkZ][inChunkX][inChunkY] = {}
    end
    Grid[chunkX][chunkY][chunkZ][inChunkX][inChunkY][inChunkZ] = dimension.getBlock(x, y, z).id
end

function gridTest()
    local chunkX = math.floor(px / 8)
    local chunkY = math.floor(py / 8)
    local chunkZ = math.floor(pz / 8)


    for i = -radius, radius do
        for j = -radius, radius do
            for k = -radius, radius do
                if Grid[chunkX + i] ~= nil and Grid[chunkX + i][chunkY + j] ~= nil and Grid[chunkX + i][chunkY + j][chunkZ + k] ~= nil then -- the chunk exists
                    local thisChunk = Grid[chunkX + i][chunkY + j][chunkZ + k]

                    for l = 0, 8 do
                        for m = 0, 8 do
                            for n = 0, 8 do
                                if thisChunk ~= nil and thisChunk[l] ~= nil and thisChunk[l][m] ~= nil and thisChunk[l][m][n] ~= nil then -- the block in the chunk exists
                                    if thisChunk[l][m][n] ~= 0 then                                                                       -- it isn't air
                                        --this is a block that can be rendered
                                        client.execute(
                                            "execute /setblock " ..
                                            8 * (chunkX + i) + l .. " " ..
                                            8 * (chunkY + j) + m .. " " ..
                                            8 * (chunkZ + k) + n .. " " ..
                                            "dirt"
                                        )
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
