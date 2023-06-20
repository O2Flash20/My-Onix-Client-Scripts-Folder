-- Made By O2Flash20 🙂

name = "Freecam"
description = "A freecam script (what) (no way) (i made my own renderer in scripting)"

importLib("logger")
importLib("vectors")

testButton = 1
client.settings.addKeybind("Test Button", "testButton")

event.listen("KeyboardInput", function(key, down)
    if key == testButton and down then
        -- initialScan()
        ISINFREECAM = not ISINFREECAM
        facesFromGrid()
    end

    for i = 1, #trackedKeys do
        if trackedKeys[i] == key then
            trackedKeysDown[i] = down
            -- return true
        end
    end
end)

ISINFREECAM = false
lastWasInFreecam = false

--------------v
radius = (8 * 1) / 2
Grid = {}
blocksToAddToGrid = {} -- {{x, y, z}, {x, y, z}, {x, y, z}}
function postInit()
    lastX, lastY, lastZ = player.position()
end

BlockAddingSpeed = 5000
function update()
    px, py, pz = player.position()

    log({ #blocksToAddToGrid, #facesToRender, facesToRender[1] })

    if ISINFREECAM then
        diffX, diffY, diffZ = px - lastX, py - lastY, pz - lastZ
        scanWithMovement(diffX, diffY, diffZ)

        -- remove all faces and redo it
        facesToRender = {}
        facesFromGrid()

        -- putting blocks into the grid
        local blocksAdded = 0
        while #blocksToAddToGrid > 0 do
            if blocksAdded >= BlockAddingSpeed then break end
            blocksAdded = blocksAdded + 1

            local block = blocksToAddToGrid[#blocksToAddToGrid]
            addBlockToGrid(block[1], block[2], block[3])
            table.remove(blocksToAddToGrid, #blocksToAddToGrid)
        end
    end

    if ISINFREECAM and not lastWasInFreecam then
        initialScan()
    end

    lastWasInFreecam = ISINFREECAM

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

-- a helper for the loop in update
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

function facesFromGrid()
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
                                        -- client.execute(
                                        --     "execute /setblock " ..
                                        --     8 * (chunkX + i) + l .. " " ..
                                        --     8 * (chunkY + j) + m .. " " ..
                                        --     8 * (chunkZ + k) + n .. " " ..
                                        --     "dirt"
                                        -- )
                                        local x = 8 * (chunkX + i) + l
                                        local y = 8 * (chunkY + j) + m
                                        local z = 8 * (chunkZ + k) + n
                                        table.insert(facesToRender, { x, y, z, { 0, 1, 0 }, "nil" })
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

cameraPosition = { 0, 0, 0 }
-----------------w------a-----s-----d----space-z
trackedKeys = { 0x57, 0x41, 0x53, 0x44, 0x20, 0x5A }
trackedKeysDown = { false, false, false, false, false, false }
function moveCamera(amount, direction)
    local cam = vec:new(cameraPosition[1], cameraPosition[2], cameraPosition[3])
    if direction == "forward" then
        local toAdd = vec:fromAngle(amount, pyaw, 0)
        cam:add(toAdd)
        cameraPosition = cam.components
        return
    end
    if direction == "left" then
        local toAdd = vec:fromAngle(amount, pyaw - math.rad(90), 0)
        cam:add(toAdd)
        cameraPosition = cam.components
        return
    end
    if direction == "backward" then
        local toSub = vec:fromAngle(amount, pyaw, 0)
        cam:sub(toSub)
        cameraPosition = cam.components
        return
    end
    if direction == "right" then
        local toAdd = vec:fromAngle(amount, pyaw + math.rad(90), 0)
        cam:add(toAdd)
        cameraPosition = cam.components
        return
    end
    if direction == "up" then
        cameraPosition[2] = cameraPosition[2] + amount
    end
    if direction == "down" then
        cameraPosition[2] = cameraPosition[2] - amount
    end
end

-- {{x, y, z, direction, texture}, {...}}
facesToRender = {}
function render3d()
    local blocksSizes = 0.05

    pyaw, ppitch = player.rotation()
    pyaw = math.rad(pyaw + 90)
    -- log(cameraPosition)
    -- if trackedKeysDown[1] == true then moveCamera(blocksSizes / 4, "forward") end
    -- if trackedKeysDown[2] == true then moveCamera(blocksSizes / 4, "left") end
    -- if trackedKeysDown[3] == true then moveCamera(blocksSizes / 4, "backward") end
    -- if trackedKeysDown[4] == true then moveCamera(blocksSizes / 4, "right") end
    -- if trackedKeysDown[5] == true then moveCamera(blocksSizes / 4, "up") end
    -- if trackedKeysDown[6] == true then moveCamera(blocksSizes / 4, "down") end

    for i = 1, #facesToRender do
        local f = facesToRender[i]
        renderFace(f[1] * blocksSizes, f[2] * blocksSizes, f[3] * blocksSizes, f[4], blocksSizes, f[5])
    end
    -- facesToRender = {}

    -- for x = 1, 10 do
    --     for y = 1, 10 do
    --         for z = 1, 10 do
    --             renderFace(
    --                 x * blocksSizes - cameraPosition[1],
    --                 y * blocksSizes - cameraPosition[2],
    --                 z * blocksSizes - cameraPosition[3],
    --                 { 0, 1, 0 }, blocksSizes, "textures/blocks/netherite_block")
    --         end
    --     end
    -- end

    -- renderFace(2, 0, 0.5, { -1, 0, 0 }, 1, "textures/blocks/stone")
    -- renderFace(-1, 0, 0.5, { 1, 0, 0 }, 1, "textures/blocks/stone")
    -- renderFace(2, 0, 0.5, { -1, 0, 0 }, 1, "textures/blocks/stone")
    -- renderFace(2, 0, 0.5, { -1, 0, 0 }, 1, "textures/blocks/stone")
    -- renderFace(2, 0, 0.5, { -1, 0, 0 }, 1, "textures/blocks/stone")
    -- renderFace(2, 0, 0.5, { -1, 0, 0 }, 1, "textures/blocks/stone")
end

function renderFace(x, y, z, direction, size, texturePath)
    local s2 = size / 2

    if direction[1] == 1 then --right
        gfx.tquad(
            x + s2, y + s2, z - s2, 1, 0,
            x + s2, y + s2, z + s2, 1, 1,
            x + s2, y - s2, z + s2, 0, 1,
            x + s2, y - s2, z - s2, 0, 0,
            texturePath
        )
    end
    if direction[1] == -1 then --left
        gfx.tquad(
            x - s2, y - s2, z - s2, 0, 0,
            x - s2, y - s2, z + s2, 0, 1,
            x - s2, y + s2, z + s2, 1, 1,
            x - s2, y + s2, z - s2, 1, 0,
            texturePath
        )
    end

    if direction[2] == 1 then --up
        gfx.tquad(
            x - s2, y + s2, z - s2, 0, 0,
            x - s2, y + s2, z + s2, 0, 1,
            x + s2, y + s2, z + s2, 1, 1,
            x + s2, y + s2, z - s2, 1, 0,
            texturePath
        )
    end
    if direction[2] == -1 then --down
        gfx.tquad(
            x + s2, y - s2, z - s2, 1, 0,
            x + s2, y - s2, z + s2, 1, 1,
            x - s2, y - s2, z + s2, 0, 1,
            x - s2, y - s2, z - s2, 0, 0,
            texturePath
        )
    end

    -- ! for these two, the uvs might be inverted
    if direction[3] == 1 then --front
        gfx.tquad(
            x + s2, y + s2, z + s2, 1, 0,
            x - s2, y + s2, z + s2, 1, 1,
            x + s2, y - s2, z + s2, 0, 1,
            x - s2, y - s2, z + s2, 0, 0,
            texturePath
        )
    end
    if direction[3] == -1 then --back
        gfx.tquad(
            x - s2, y - s2, z - s2, 0, 0,
            x + s2, y - s2, z - s2, 0, 1,
            x - s2, y + s2, z - s2, 1, 1,
            x + s2, y + s2, z - s2, 1, 0,
            texturePath
        )
    end
end

--[[
    -- !too difficult to get the point to match up with in-game, maybe try again later
    function isPointOnScreen(x, y, z, cameraX, cameraY, cameraZ, yaw, pitch)
        local point = vec:new(x, y, z)
        local camera = vec:new(cameraX, cameraY, cameraZ)
        point:sub(camera)
        point:rotate(-yaw, pitch)
        -- log(point.components)
        -- point:add(camera)

        -- local output vec:new(point.x * (-1 / point.z), point.y * (-1 / point.z))
        local xOut = point.x * (-1 / point.z)
        local yOut = point.y * (-1 / point.z)

        -- xOut = xOut * sizeX + sizeX / 2
        -- yOut = yOut * sizeY + sizeY / 2
        xOut = xOut * 640 + 640 / 2
        yOut = yOut * 360 + 360 / 2
        return { xOut, yOut }
    end

    function projectPoint(x, y, z)
        local newX = x * (-1 / z)
        local newY = y * (-1 / z)

        -- go from normalized to space of the module
        newX = newX * sizeX + sizeX / 2
        newY = newY * sizeY + sizeY / 2

        return { newX, newY }
    end

    function render()
        local ppx, ppy, ppz = player.pposition()
        local pyaw, ppitch = player.rotation()
        local p = isPointOnScreen(1300, 80, -115, ppx, ppy, ppz, math.rad(pyaw), math.rad(ppitch))
        -- log(pyaw)
        gfx.rect(p[1], p[2], 10, 10)

        local q = isPointOnScreen(1200, 80, -115, ppx, ppy, ppz, math.rad(pyaw), math.rad(ppitch))
        -- log(pyaw)
        gfx.rect(q[1], q[2], 10, 10)

        local r = isPointOnScreen(1300, 100, -115, ppx, ppy, ppz, math.rad(pyaw), math.rad(ppitch))
        log(pyaw)
        gfx.rect(r[1], r[2], 10, 10)

        gfx.rect(629, 332, 10, 10)
    end
]]
