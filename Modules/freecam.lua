-- Made By O2Flash20 🙂

name = "Freecam"
description = "A freecam script (what) (no way) (i made my own renderer in scripting)"

importLib("logger")
importLib("vectors")
importLib("blockToTexture")

testButton = 1
client.settings.addKeybind("Test Button", "testButton")

event.listen("KeyboardInput", function(key, down)
    if key == testButton and down then
        -- initialScan()
        ISINFREECAM = not ISINFREECAM
        facesFromGrid()
    end

    if ISINFREECAM then
        for i = 1, #trackedKeys do
            if trackedKeys[i] == key then
                trackedKeysDown[i] = down
                return true
            end
        end
    end
end)

ISINFREECAM = false
lastWasInFreecam = false

----------------v
chunkDiameter = 3
radius = (8 * chunkDiameter) / 2
Grid = {}
blocksToAddToGrid = {} -- {{x, y, z}, {x, y, z}, {x, y, z}}
function postInit()
    lastX, lastY, lastZ = player.position()
    lastcPos = { 0, 0, 0 }
end

BlockAddingSpeed = 5000
function update()
    px, py, pz = player.position()

    if ISINFREECAM then
        local diff = {
            math.floor(cPos[1]) - math.floor(lastcPos[1]),
            math.floor(cPos[2]) - math.floor(lastcPos[2]),
            math.floor(cPos[3]) - math.floor(lastcPos[3])
        }
        -- log(diff)
        scanWithMovement(diff[1], diff[2], diff[3])

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
        cPos = { px, py, pz }
        initialScan()
    end
    lastWasInFreecam = ISINFREECAM

    lastcPos = cPos
end

function initialScan()
    for x = -radius, radius, 1 do
        for y = -radius, radius, 1 do
            for z = -radius, radius, 1 do
                table.insert(blocksToAddToGrid, {
                    math.floor(cPos[1]) + x,
                    math.floor(cPos[2]) + y,
                    math.floor(cPos[3]) + z
                })
            end
        end
    end
end

function scanWithMovement(diffX, diffY, diffZ)
    for x = 1, math.abs(diffX) do
        for y = -radius, radius do
            for z = -radius, radius do
                table.insert(blocksToAddToGrid, {
                    math.floor(cPos[1]) + math.sign(diffX) * (radius - x),
                    math.floor(cPos[2]) + y,
                    math.floor(cPos[3]) + z
                })
            end
        end
    end
    for y = 1, math.abs(diffY) do
        for x = -radius, radius do
            for z = -radius, radius do
                table.insert(blocksToAddToGrid, {
                    math.floor(cPos[1]) + x,
                    math.floor(cPos[2]) + math.sign(diffY) * (radius - y),
                    math.floor(cPos[3]) + z
                })
            end
        end
    end
    for z = 1, math.abs(diffZ) do
        for x = -radius, radius do
            for y = -radius, radius do
                table.insert(blocksToAddToGrid, {
                    math.floor(cPos[1]) + x,
                    math.floor(cPos[2]) + y,
                    math.floor(cPos[3]) + math.sign(diffZ) * (radius - z)
                })
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
    local chunkX = math.floor(cPos[1] / 8)
    local chunkY = math.floor(cPos[2] / 8)
    local chunkZ = math.floor(cPos[3] / 8)

    for i = -(chunkDiameter - 1) / 2, (chunkDiameter - 1) / 2 do
        for j = -(chunkDiameter - 1) / 2, (chunkDiameter - 1) / 2 do
            for k = -(chunkDiameter - 1) / 2, (chunkDiameter - 1) / 2 do
                if Grid[chunkX + i] ~= nil and Grid[chunkX + i][chunkY + j] ~= nil and Grid[chunkX + i][chunkY + j][chunkZ + k] ~= nil then -- the chunk exists
                    local thisChunkX = chunkX + i
                    local thisChunkY = chunkY + j
                    local thisChunkZ = chunkZ + k
                    local thisChunk = Grid[thisChunkX][thisChunkY][thisChunkZ]

                    local chunkToCamVec = vec:new(
                        thisChunkX * 8 - cPos[1],
                        thisChunkY * 8 - cPos[2],
                        thisChunkZ * 8 - cPos[3]
                    ):normalize()

                    if (i == 0 and k == 0) or chunkToCamVec:dot(vec:fromAngle(1, pyaw, ppitch)) > 0 then
                        for l = 0, 7 do
                            for m = 0, 7 do
                                for n = 0, 7 do
                                    if thisChunk ~= nil and thisChunk[l] ~= nil and thisChunk[l][m] ~= nil and thisChunk[l][m][n] ~= nil then -- the block in the chunk exists
                                        if thisChunk[l][m][n] ~= 0 then                                                                       -- it isn't air
                                            --this is a block that can be rendered
                                            local x = 8 * (chunkX + i) + l
                                            local y = 8 * (chunkY + j) + m
                                            local z = 8 * (chunkZ + k) + n

                                            -- check all blocks around this one, if it is visible, render a face there

                                            --! +- Z are wrong
                                            ---------------------------------------------------------------------------
                                            local upBlockIsInChunk, block = pcall(function()
                                                return thisChunk[l][m + 1][n]
                                            end)
                                            if upBlockIsInChunk then
                                                if block == 0 then
                                                    table.insert(facesToRender,
                                                        { x, y, z, { 0, 1, 0 }, thisChunk[l][m][n] })
                                                end
                                                --------------------
                                            else
                                                -- the block is in another chunk, so it is the lowest block of the chunk above\
                                                local blockAboveExists, block = pcall(function()
                                                    return Grid[thisChunkX]
                                                        [thisChunkY + 1][thisChunkZ][l][0][n]
                                                end)
                                                if blockAboveExists and block == 0 then
                                                    table.insert(facesToRender,
                                                        { x, y, z, { 0, 1, 0 }, thisChunk[l][m][n] })
                                                end
                                            end
                                            ---------------------------------------------------------------------------
                                            local downBlockIsInChunk, block = pcall(function()
                                                return thisChunk[l][m - 1][n]
                                            end)
                                            if downBlockIsInChunk then
                                                if block == 0 then
                                                    table.insert(facesToRender,
                                                        { x, y, z, { 0, -1, 0 }, thisChunk[l][m][n] })
                                                end
                                                --------------------
                                            else
                                                -- the block is in another chunk, so it is the highest block of the chunk below
                                                local blockBelowExists, block = pcall(function()
                                                    return Grid[thisChunkX]
                                                        [thisChunkY - 1][thisChunkZ][l][7][n]
                                                end)
                                                if blockBelowExists and block == 0 then
                                                    table.insert(facesToRender,
                                                        { x, y, z, { 0, -1, 0 }, thisChunk[l][m][n] })
                                                end
                                            end
                                            ---------------------------------------------------------------------------
                                            local leftBlockIsInChunk, block = pcall(function()
                                                return thisChunk[l - 1][m][n]
                                            end)
                                            if leftBlockIsInChunk then
                                                if block == 0 then
                                                    table.insert(facesToRender,
                                                        { x, y, z, { -1, 0, 0 }, thisChunk[l][m][n] })
                                                end
                                            else
                                                -- the block is in another chunk, so it is the rightmost block of the chunk to the left
                                                local blockLeftExists, block = pcall(function()
                                                    return Grid[thisChunkX - 1]
                                                        [thisChunkY][thisChunkZ][7][m][n]
                                                end)
                                                if blockLeftExists and block == 0 then
                                                    table.insert(facesToRender,
                                                        { x, y, z, { -1, 0, 0 }, thisChunk[l][m][n] })
                                                end
                                            end
                                            ---------------------------------------------------------------------------
                                            local rightBlockIsInChunk, block = pcall(function()
                                                return thisChunk[l + 1][m][n]
                                            end)
                                            if rightBlockIsInChunk then
                                                if block == 0 then
                                                    table.insert(facesToRender,
                                                        { x, y, z, { 1, 0, 0 }, thisChunk[l][m][n] })
                                                end
                                            else
                                                -- the block is in another chunk, so it is the leftmost block of the chunk to the right
                                                local blockRightExists, block = pcall(function()
                                                    return Grid[thisChunkX + 1]
                                                        [thisChunkY][thisChunkZ][0][m][n]
                                                end)
                                                if blockRightExists and block == 0 then
                                                    table.insert(facesToRender,
                                                        { x, y, z, { 1, 0, 0 }, thisChunk[l][m][n] })
                                                end
                                            end
                                            ---------------------------------------------------------------------------
                                            local frontBlockIsInChunk, block = pcall(function()
                                                return thisChunk[l][m][n + 1]
                                            end)
                                            if frontBlockIsInChunk then
                                                if block == 0 then
                                                    table.insert(facesToRender,
                                                        { x, y, z, { 0, 0, 1 }, thisChunk[l][m][n] })
                                                end
                                            else
                                                -- the block is in another chunk, so it is the backmost block of the chunk in front
                                                local blockFrontExists, block = pcall(function()
                                                    return Grid[thisChunkX]
                                                        [thisChunkY][thisChunkZ + 1][l][m][0]
                                                end)
                                                if blockFrontExists and block == 0 then
                                                    table.insert(facesToRender,
                                                        { x, y, z, { 0, 0, 1 }, thisChunk[l][m][n] })
                                                end
                                            end
                                            ---------------------------------------------------------------------------
                                            local backBlockIsInChunk, block = pcall(function()
                                                return thisChunk[l][m][n - 1]
                                            end)
                                            if backBlockIsInChunk then
                                                if block == 0 then
                                                    table.insert(facesToRender,
                                                        { x, y, z, { 0, 0, -1 }, thisChunk[l][m][n] })
                                                end
                                            else
                                                -- the block is in another chunk, so it is the frontmost block of the chunk in back
                                                local blockBackExists, block = pcall(function()
                                                    return Grid[thisChunkX]
                                                        [thisChunkY][thisChunkZ - 1][l][m][7]
                                                end)
                                                if blockBackExists and block == 0 then
                                                    table.insert(facesToRender,
                                                        { x, y, z, { 0, 0, -1 }, thisChunk[l][m][n] })
                                                end
                                            end
                                            ---------------------------------------------------------------------------
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
end

cPos = { 0, 0, 0 }
-----------------w------a-----s-----d----space-z
trackedKeys = { 0x57, 0x41, 0x53, 0x44, 0x20, 0x5A }
trackedKeysDown = { false, false, false, false, false, false }
function moveCamera(amount, direction)
    local cam = vec:new(cPos[1], cPos[2], cPos[3])
    if direction == "forward" then
        local toAdd = vec:fromAngle(amount, pyaw, 0)
        cam:add(toAdd)
        cPos = cam.components
        return
    end
    if direction == "left" then
        local toAdd = vec:fromAngle(amount, pyaw - math.rad(90), 0)
        cam:add(toAdd)
        cPos = cam.components
        return
    end
    if direction == "backward" then
        local toSub = vec:fromAngle(amount, pyaw, 0)
        cam:sub(toSub)
        cPos = cam.components
        return
    end
    if direction == "right" then
        local toAdd = vec:fromAngle(amount, pyaw + math.rad(90), 0)
        cam:add(toAdd)
        cPos = cam.components
        return
    end
    if direction == "up" then
        cPos[2] = cPos[2] + amount
    end
    if direction == "down" then
        cPos[2] = cPos[2] - amount
    end
end

-- {{x, y, z, direction, texture}, {...}}
facesToRender = {}
function render3d(dt)
    local blocksSizes = 0.05

    ppx, ppy, ppz = player.pposition()
    pyaw, ppitch = player.rotation()
    pyaw = math.rad(pyaw + 90)
    ppitch = math.rad(-ppitch)

    if ISINFREECAM then
        if trackedKeysDown[1] == true then moveCamera(6 * dt, "forward") end
        if trackedKeysDown[2] == true then moveCamera(6 * dt, "left") end
        if trackedKeysDown[3] == true then moveCamera(6 * dt, "backward") end
        if trackedKeysDown[4] == true then moveCamera(6 * dt, "right") end
        if trackedKeysDown[5] == true then moveCamera(6 * dt, "up") end
        if trackedKeysDown[6] == true then moveCamera(6 * dt, "down") end

        for i = 1, #facesToRender do
            local f = facesToRender[i]
            renderFace(
                f[1] * blocksSizes + ppx - (cPos[1] * blocksSizes),
                f[2] * blocksSizes + ppy - (cPos[2] * blocksSizes),
                f[3] * blocksSizes + ppz - (cPos[3] * blocksSizes),
                f[4], blocksSizes, "textures/blocks/dirt" --!!
            )
            -- gfx.color(f[5], f[5], f[5])
            -- renderFaceC(
            --     f[1] * blocksSizes + ppx - (cPos[1] * blocksSizes),
            --     f[2] * blocksSizes + ppy - (cPos[2] * blocksSizes),
            --     f[3] * blocksSizes + ppz - (cPos[3] * blocksSizes),
            --     f[4], blocksSizes)
        end
    end

    renderFace(cPos[1], cPos[2], cPos[3], { 1, 0, 0 }, 0.5, "nil")
    renderFace(cPos[1], cPos[2], cPos[3], { -1, 0, 0 }, 0.5, "nil")
    renderFace(cPos[1], cPos[2], cPos[3], { 0, 1, 0 }, 0.5, "nil")
    renderFace(cPos[1], cPos[2], cPos[3], { 0, -1, 0 }, 0.5, "nil")
    renderFace(cPos[1], cPos[2], cPos[3], { 0, 0, 1 }, 0.5, "nil")
    renderFace(cPos[1], cPos[2], cPos[3], { 1, 0, -1 }, 0.5, "nil")

    -- renderFaceC(cPos[1], cPos[2], cPos[3], { 1, 0, 0 }, 0.5)
    -- renderFaceC(cPos[1], cPos[2], cPos[3], { -1, 0, 0 }, 0.5)
    -- renderFaceC(cPos[1], cPos[2], cPos[3], { 0, 1, 0 }, 0.5)
    -- renderFaceC(cPos[1], cPos[2], cPos[3], { 0, -1, 0 }, 0.5)
    -- renderFaceC(cPos[1], cPos[2], cPos[3], { 0, 0, 1 }, 0.5)
    -- renderFaceC(cPos[1], cPos[2], cPos[3], { 1, 0, -1 }, 0.5)
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

    if direction[3] == 1 then --front
        gfx.tquad(
            x + s2, y - s2, z + s2, 1, 0,
            x + s2, y + s2, z + s2, 1, 1,
            x - s2, y + s2, z + s2, 0, 1,
            x - s2, y - s2, z + s2, 0, 0,
            texturePath
        )
    end
    if direction[3] == -1 then --back
        gfx.tquad(
            x - s2, y - s2, z - s2, 0, 0,
            x - s2, y + s2, z - s2, 0, 1,
            x + s2, y + s2, z - s2, 1, 1,
            x + s2, y - s2, z - s2, 1, 0,
            texturePath
        )
    end
end

-- function renderFaceC(x, y, z, direction, size)
--     local s2 = size / 2

--     if direction[1] == 1 then --right
--         gfx.quad(
--             x + s2, y + s2, z - s2,
--             x + s2, y + s2, z + s2,
--             x + s2, y - s2, z + s2,
--             x + s2, y - s2, z - s2
--         )
--     end
--     if direction[1] == -1 then --left
--         gfx.quad(
--             x - s2, y - s2, z - s2,
--             x - s2, y - s2, z + s2,
--             x - s2, y + s2, z + s2,
--             x - s2, y + s2, z - s2
--         )
--     end

--     if direction[2] == 1 then --up
--         gfx.quad(
--             x - s2, y + s2, z - s2,
--             x - s2, y + s2, z + s2,
--             x + s2, y + s2, z + s2,
--             x + s2, y + s2, z - s2
--         )
--     end
--     if direction[2] == -1 then --down
--         gfx.quad(
--             x + s2, y - s2, z - s2,
--             x + s2, y - s2, z + s2,
--             x - s2, y - s2, z + s2,
--             x - s2, y - s2, z - s2
--         )
--     end

--     if direction[3] == 1 then --front
--         gfx.quad(
--             x + s2, y - s2, z + s2,
--             x + s2, y + s2, z + s2,
--             x - s2, y + s2, z + s2,
--             x - s2, y - s2, z + s2
--         )
--     end
--     if direction[3] == -1 then --back
--         gfx.quad(
--             x - s2, y - s2, z - s2,
--             x - s2, y + s2, z - s2,
--             x + s2, y + s2, z - s2,
--             x + s2, y - s2, z - s2
--         )
--     end
-- end

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

-- TODO: blockChanged stuff
