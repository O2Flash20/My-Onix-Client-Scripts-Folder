-- Made By O2Flash20 🙂
name = "Shadows"
description = "Real Time Shadows?!??!"

importLib("logger")

blankTexture = gfx2.createCpuRenderTarget(1, 1)
shouldUploadTexture = false
shouldSetTexture = true
function render2()
    if shouldSetTexture then
        gfx2.bindRenderTarget(blankTexture)
        gfx2.color(255, 255, 255)
        gfx2.fillRect(0, 0, 1, 1)

        gfx2.bindRenderTarget(nil)
        shouldUploadTexture = true
        shouldSetTexture = false
    end
end

radius = 10
resolution = 2
sunTimesToCheck = 4
blocksGrid = {}

-- ?
edgeSampleOffset = 0

blockCheckQueue = {}
function update()
    px, py, pz = player.position()

    if lastX then
        -- moved +x
        if lastX < px then
            for x = lastX + radius + 1, px + radius, 1 do
                for y = -radius + py, radius + py, 1 do
                    for z = -radius + pz, radius + pz, 1 do
                        table.insert(blockCheckQueue, { x, y, z })
                    end
                end
            end
        end
        -- moved -x
        if lastX > px then
            for x = lastX + radius - 1, px + radius, -1 do
                for y = -radius + py, radius + py, 1 do
                    for z = -radius + pz, radius + pz, 1 do
                        table.insert(blockCheckQueue, { x, y, z })
                    end
                end
            end
        end

        -- moved +y
        if lastY < py then
            for y = lastY + radius + 1, py + radius, 1 do
                for x = -radius + px, radius + px, 1 do
                    for z = -radius + pz, radius + pz, 1 do
                        table.insert(blockCheckQueue, { x, y, z })
                    end
                end
            end
        end
        -- moved -y
        if lastY > py then
            for y = lastY + radius - 1, py + radius, -1 do
                for x = -radius + px, radius + px, 1 do
                    for z = -radius + pz, radius + pz, 1 do
                        table.insert(blockCheckQueue, { x, y, z })
                    end
                end
            end
        end

        -- moved +z
        if lastZ < pz then
            for z = lastZ + radius + 1, pz + radius, 1 do
                for x = -radius + px, radius + px, 1 do
                    for y = -radius + py, radius + py, 1 do
                        table.insert(blockCheckQueue, { x, y, z })
                    end
                end
            end
        end
        -- moved -z
        if lastZ > pz then
            for z = lastZ + radius - 1, pz + radius, -1 do
                for x = -radius + px, radius + px, 1 do
                    for y = -radius + py, radius + py, 1 do
                        table.insert(blockCheckQueue, { x, y, z })
                    end
                end
            end
        end
    end

    lastX, lastY, lastZ = px, py, pz
end

t = 0
quadsToRender = {}
function render3d(dt)
    if shouldUploadTexture then
        gfx.uploadImage("blank", blankTexture.cpuTexture)
        shouldUploadTexture = false
    end

    log(#blockCheckQueue)
    if #blockCheckQueue > 0 then
        local blocksChecked = 0
        while blocksChecked < 5 and #blockCheckQueue > 0 do
            local wasChecked = checkBlockFromQueue() --this also actually does the check, but returns if work was done
            if wasChecked then
                blocksChecked = blocksChecked + 1
            else --if it wasnt a block that had quads, do them way faster
                blocksChecked = blocksChecked + 0.1
            end
        end
    end

    -- update the quads to render list every so often
    t = t + dt
    if t > 1 then
        t = 0
        quadsToRender = getQuadsNeaby()
    end

    gfx.tcolor(255, 255, 255, 100)
    gfx.tquadbatch(
        quadsToRender, "shadowTiles", false
    )

    -- log(getQuadsNeaby())
end

raycastOffset = 0.01
allQuads = {}
function checkBlockFromQueue()
    local bx = blockCheckQueue[1][1]
    local by = blockCheckQueue[1][2]
    local bz = blockCheckQueue[1][3]

    if blocksGrid[bx] ~= nil and blocksGrid[bx][by] ~= nil and blocksGrid[bx][by][bz] ~= nil then
        table.remove(blockCheckQueue, 1)
        return false
    end --if this block has already been done, skip it

    if isTransparent(bx, by, bz) then
        addToGrid(bx, by, bz, false)
        table.remove(blockCheckQueue, 1)
        return false --true says that this coordinate wasnt already filled in
    end

    -- now I know this is a block I have to check all the sides of
    thisBlockQuads = {} -- this table will contain a few time indices, and within them, all the quads that belong to this block that should be drawn at this time
    -- later, this will be added to the grid
    -- then, it will go through all these grid entries and put all the quads for the time it wants into one long table

    -- the block is new and is solid, so see which of its faces are exposed
    if isTransparent(bx + 1, by, bz) then
        faceSampleInfo = {} --a 2d table, each element is a point that was sampled and contains {time: isInShadowAtThatTime}
        for i = 0, resolution, 1 do
            faceSampleInfo[i] = {}
            for j = 0, resolution, 1 do
                local sampleX = i / resolution
                local sampleY = j / resolution

                faceSampleInfo[i][j] = whenIsPointInShadow(bx + 1 + raycastOffset, sampleX + by, sampleY + bz, 1)
            end
        end

        -- now, make quads with faceSampleInfo
        for i = 0, resolution - 1, 1 do
            for j = 0, resolution - 1, 1 do
                for k = 1, sunTimesToCheck, 1 do
                    local topLeftIsShadow = faceSampleInfo[i][j + 1][k]
                    local topRightIsShadow = faceSampleInfo[i + 1][j + 1][k]
                    local bottomLeftIsShadow = faceSampleInfo[i][j][k]
                    local bottomRightIsShadow = faceSampleInfo[i + 1][j][k]

                    local uvs = uvCoordsFromCornerShadows(
                        topLeftIsShadow, topRightIsShadow, bottomLeftIsShadow, bottomRightIsShadow
                    )

                    if thisBlockQuads[k] == nil then
                        thisBlockQuads[k] = {}
                    end

                    table.insert(thisBlockQuads[k], {
                        bx + 1 + raycastOffset, i / resolution + by, j / resolution + bz,
                        uvs["bl"][1], uvs["bl"][2],
                        bx + 1 + raycastOffset, (i + 1) / resolution + by, j / resolution + bz,
                        uvs["br"][1], uvs["br"][2],
                        bx + 1 + raycastOffset, (i + 1) / resolution + by, (j + 1) / resolution + bz,
                        uvs["tr"][1], uvs["tr"][2],
                        bx + 1 + raycastOffset, i / resolution + by, (j + 1) / resolution + bz,
                        uvs["tl"][1], uvs["tl"][2]
                    })
                end
            end
        end
    end
    if isTransparent(bx - 1, by, bz) then
        faceSampleInfo = {} --a 2d table, each element is a point that was sampled and contains {time: isInShadowAtThatTime}
        for i = 0, resolution, 1 do
            faceSampleInfo[i] = {}
            for j = 0, resolution, 1 do
                local sampleX = i / resolution
                local sampleY = j / resolution

                faceSampleInfo[i][j] = whenIsPointInShadow(bx - raycastOffset, sampleX + by, sampleY + bz, 2)
            end
        end

        -- now, make quads with faceSampleInfo
        for i = 0, resolution - 1, 1 do
            for j = 0, resolution - 1, 1 do
                for k = 1, sunTimesToCheck, 1 do
                    local topLeftIsShadow = faceSampleInfo[i][j + 1][k]
                    local topRightIsShadow = faceSampleInfo[i + 1][j + 1][k]
                    local bottomLeftIsShadow = faceSampleInfo[i][j][k]
                    local bottomRightIsShadow = faceSampleInfo[i + 1][j][k]

                    local uvs = uvCoordsFromCornerShadows(
                        topLeftIsShadow, topRightIsShadow, bottomLeftIsShadow, bottomRightIsShadow
                    )

                    if thisBlockQuads[k] == nil then
                        thisBlockQuads[k] = {}
                    end

                    table.insert(thisBlockQuads[k], {
                        bx - raycastOffset, i / resolution + by, (j + 1) / resolution + bz,
                        uvs["tl"][1], uvs["tl"][2],
                        bx - raycastOffset, (i + 1) / resolution + by, (j + 1) / resolution + bz,
                        uvs["tr"][1], uvs["tr"][2],
                        bx - raycastOffset, (i + 1) / resolution + by, j / resolution + bz,
                        uvs["br"][1], uvs["br"][2],
                        bx - raycastOffset, i / resolution + by, j / resolution + bz,
                        uvs["bl"][1], uvs["bl"][2],
                    })
                end
            end
        end
    end
    if isTransparent(bx, by + 1, bz) then
        faceSampleInfo = {} --a 2d table, each element is a point that was sampled and contains {time: isInShadowAtThatTime}
        for i = 0, resolution, 1 do
            faceSampleInfo[i] = {}
            for j = 0, resolution, 1 do
                local sampleX = i / resolution
                local sampleY = j / resolution

                faceSampleInfo[i][j] = whenIsPointInShadow(sampleX + bx, by + 1 + raycastOffset, sampleY + bz, 3)
            end
        end

        -- now, make quads with faceSampleInfo
        for i = 0, resolution - 1, 1 do
            for j = 0, resolution - 1, 1 do
                for k = 1, sunTimesToCheck, 1 do
                    local topLeftIsShadow = faceSampleInfo[i][j + 1][k]
                    local topRightIsShadow = faceSampleInfo[i + 1][j + 1][k]
                    local bottomLeftIsShadow = faceSampleInfo[i][j][k]
                    local bottomRightIsShadow = faceSampleInfo[i + 1][j][k]

                    local uvs = uvCoordsFromCornerShadows(
                        topLeftIsShadow, topRightIsShadow, bottomLeftIsShadow, bottomRightIsShadow
                    )

                    if thisBlockQuads[k] == nil then
                        thisBlockQuads[k] = {}
                    end

                    table.insert(thisBlockQuads[k], {
                        i / resolution + bx, by + 1 + raycastOffset, (j + 1) / resolution + bz,
                        uvs["tl"][1], uvs["tl"][2],
                        (i + 1) / resolution + bx, by + 1 + raycastOffset, (j + 1) / resolution + bz,
                        uvs["tr"][1], uvs["tr"][2],
                        (i + 1) / resolution + bx, by + 1 + raycastOffset, j / resolution + bz,
                        uvs["br"][1], uvs["br"][2],
                        i / resolution + bx, by + 1 + raycastOffset, j / resolution + bz,
                        uvs["bl"][1], uvs["bl"][2],
                    })
                end
            end
        end
    end
    if isTransparent(bx, by - 1, bz) then --*this can only be in shadow
        faceSampleInfo = {}               --a 2d table, each element is a point that was sampled and contains {time: isInShadowAtThatTime}
        for i = 0, resolution, 1 do
            faceSampleInfo[i] = {}
            for j = 0, resolution, 1 do
                local sampleX = i / resolution
                local sampleY = j / resolution

                faceSampleInfo[i][j] = whenIsPointInShadow(sampleX + bx, by - raycastOffset, sampleY + bz, 4)
            end
        end

        -- now, make quads with faceSampleInfo
        for i = 0, resolution - 1, 1 do
            for j = 0, resolution - 1, 1 do
                for k = 1, sunTimesToCheck, 1 do
                    local topLeftIsShadow = faceSampleInfo[i][j + 1][k]
                    local topRightIsShadow = faceSampleInfo[i + 1][j + 1][k]
                    local bottomLeftIsShadow = faceSampleInfo[i][j][k]
                    local bottomRightIsShadow = faceSampleInfo[i + 1][j][k]

                    local uvs = uvCoordsFromCornerShadows(
                        topLeftIsShadow, topRightIsShadow, bottomLeftIsShadow, bottomRightIsShadow
                    )

                    if thisBlockQuads[k] == nil then
                        thisBlockQuads[k] = {}
                    end

                    table.insert(thisBlockQuads[k], {
                        i / resolution + bx, by - raycastOffset, j / resolution + bz,
                        uvs["bl"][1], uvs["bl"][2],
                        (i + 1) / resolution + bx, by - raycastOffset, j / resolution + bz,
                        uvs["br"][1], uvs["br"][2],
                        (i + 1) / resolution + bx, by - raycastOffset, (j + 1) / resolution + bz,
                        uvs["tr"][1], uvs["tr"][2],
                        i / resolution + bx, by - raycastOffset, (j + 1) / resolution + bz,
                        uvs["tl"][1], uvs["tl"][2],
                    })
                end
            end
        end
    end
    if isTransparent(bx, by, bz + 1) then
        faceSampleInfo = {} --a 2d table, each element is a point that was sampled and contains {time: isInShadowAtThatTime}
        for i = 0, resolution, 1 do
            faceSampleInfo[i] = {}
            for j = 0, resolution, 1 do
                local sampleX = i / resolution
                local sampleY = j / resolution

                faceSampleInfo[i][j] = whenIsPointInShadow(sampleX + bx, sampleY + by, bz + raycastOffset + 1, 5)
            end
        end

        -- now, make quads with faceSampleInfo
        for i = 0, resolution - 1, 1 do
            for j = 0, resolution - 1, 1 do
                for k = 1, sunTimesToCheck, 1 do
                    local topLeftIsShadow = faceSampleInfo[i][j + 1][k]
                    local topRightIsShadow = faceSampleInfo[i + 1][j + 1][k]
                    local bottomLeftIsShadow = faceSampleInfo[i][j][k]
                    local bottomRightIsShadow = faceSampleInfo[i + 1][j][k]

                    local uvs = uvCoordsFromCornerShadows(
                        topLeftIsShadow, topRightIsShadow, bottomLeftIsShadow, bottomRightIsShadow
                    )

                    if thisBlockQuads[k] == nil then
                        thisBlockQuads[k] = {}
                    end

                    table.insert(thisBlockQuads[k], {
                        i / resolution + bx, j / resolution + by, bz + 1 + raycastOffset,
                        uvs["bl"][1], uvs["bl"][2],
                        (i + 1) / resolution + bx, j / resolution + by, bz + 1 + raycastOffset,
                        uvs["br"][1], uvs["br"][2],
                        (i + 1) / resolution + bx, (j + 1) / resolution + by, bz + 1 + raycastOffset,
                        uvs["tr"][1], uvs["tr"][2],
                        i / resolution + bx, (j + 1) / resolution + by, bz + 1 + raycastOffset,
                        uvs["tl"][1], uvs["tl"][2],
                    })
                end
            end
        end
    end
    if isTransparent(bx, by, bz - 1) then
        faceSampleInfo = {} --a 2d table, each element is a point that was sampled and contains {time: isInShadowAtThatTime}
        for i = 0, resolution, 1 do
            faceSampleInfo[i] = {}
            for j = 0, resolution, 1 do
                local sampleX = i / resolution
                local sampleY = j / resolution

                faceSampleInfo[i][j] = whenIsPointInShadow(sampleX + bx, sampleY + by, bz - raycastOffset, 6)
            end
        end

        -- now, make quads with faceSampleInfo
        for i = 0, resolution - 1, 1 do
            for j = 0, resolution - 1, 1 do
                for k = 1, sunTimesToCheck, 1 do
                    local topLeftIsShadow = faceSampleInfo[i][j + 1][k]
                    local topRightIsShadow = faceSampleInfo[i + 1][j + 1][k]
                    local bottomLeftIsShadow = faceSampleInfo[i][j][k]
                    local bottomRightIsShadow = faceSampleInfo[i + 1][j][k]

                    local uvs = uvCoordsFromCornerShadows(
                        topLeftIsShadow, topRightIsShadow, bottomLeftIsShadow, bottomRightIsShadow
                    )

                    if thisBlockQuads[k] == nil then
                        thisBlockQuads[k] = {}
                    end

                    table.insert(thisBlockQuads[k], {
                        i / resolution + bx, (j + 1) / resolution + by, bz - raycastOffset,
                        uvs["tl"][1], uvs["tl"][2],
                        (i + 1) / resolution + bx, (j + 1) / resolution + by, bz - raycastOffset,
                        uvs["tr"][1], uvs["tr"][2],
                        (i + 1) / resolution + bx, j / resolution + by, bz - raycastOffset,
                        uvs["br"][1], uvs["br"][2],
                        i / resolution + bx, j / resolution + by, bz - raycastOffset,
                        uvs["bl"][1], uvs["bl"][2],
                    })
                end
            end
        end
    end

    addToGrid(bx, by, bz, thisBlockQuads)
    table.remove(blockCheckQueue, 1)
    return true
end

--[[
    directions:
    +x: 1
    -x: 2
    +y: 3
    -y: 4
    +z: 5
    -z: 6
]]
function whenIsPointInShadow(x, y, z, direction)
    local times = {}
    for i = 1, sunTimesToCheck, 1 do
        local thisSunTime = ((i - 0.5) / sunTimesToCheck + 0.75) % 1
        local thisSunAngle = -2 * math.pi * thisSunTime
        local thisSunDirX = math.sin(thisSunAngle)
        local thisSunDirY = math.cos(thisSunAngle)

        if (direction == 1 and thisSunDirX < 0) or (direction == 2 and thisSunDirX > 0) or direction == 4 then
            table.insert(times, true)
        else
            table.insert(times, dimension.raycast(x, y, z, x + thisSunDirX * 100, y + thisSunDirY * 100, z).isBlock)
        end
    end
    return times
end

function whenIsEdgePointInShadow(x, y, z, direction)

end

function uvCoordsFromCornerShadows(tl, tr, bl, br)
    local uvs = {}

    -- two next to eachother in shadow
    if tl and tr and (not bl) and (not br) then
        uvs["tl"] = { 0, 0.5 }
        uvs["tr"] = { 0.5, 0.5 }
        uvs["bl"] = { 0, 0 }
        uvs["br"] = { 0.5, 0 }
    elseif bl and br and (not tl) and (not tr) then
        uvs["tl"] = { 0, 0 }
        uvs["tr"] = { 0.5, 0 }
        uvs["bl"] = { 0, 0.5 }
        uvs["br"] = { 0.5, 0.5 }
    elseif tl and bl and (not tr) and (not br) then
        uvs["tl"] = { 0, 0.5 }
        uvs["tr"] = { 0, 0 }
        uvs["bl"] = { 0.5, 0.5 }
        uvs["br"] = { 0.5, 0 }
    elseif tr and br and (not tl) and (not bl) then
        uvs["tl"] = { 0, 0 }
        uvs["tr"] = { 0, 0.5 }
        uvs["bl"] = { 0.5, 0 }
        uvs["br"] = { 0.5, 0.5 }

        -- Only one in light
    elseif tr and tl and bl and (not br) then
        uvs["tl"] = { 0, 0.5 }
        uvs["tr"] = { 0.5, 0.5 }
        uvs["bl"] = { 0, 1 }
        uvs["br"] = { 0.5, 1 }
    elseif tr and tl and br and (not bl) then
        uvs["tl"] = { 0.5, 0.5 }
        uvs["tr"] = { 0, 0.5 }
        uvs["bl"] = { 0.5, 1 }
        uvs["br"] = { 0, 1 }
    elseif tr and br and bl and (not tl) then
        uvs["tl"] = { 0.5, 1 }
        uvs["tr"] = { 0, 1 }
        uvs["bl"] = { 0.5, 0.5 }
        uvs["br"] = { 0, 0.5 }
    elseif br and tl and bl and (not tr) then
        uvs["tl"] = { 0, 1 }
        uvs["tr"] = { 0.5, 1 }
        uvs["bl"] = { 0, 0.5 }
        uvs["br"] = { 0.5, 0.5 }

        -- only one in shadow
    elseif (not tr) and (not tl) and (not bl) and br then
        uvs["tl"] = { 1, 1 }
        uvs["tr"] = { 0.5, 1 }
        uvs["bl"] = { 1, 0.5 }
        uvs["br"] = { 0.5, 0.5 }
    elseif (not tr) and (not tl) and (not br) and bl then
        uvs["tl"] = { 0.5, 1 }
        uvs["tr"] = { 1, 1 }
        uvs["bl"] = { 0.5, 0.5 }
        uvs["br"] = { 1, 0.5 }
    elseif (not tr) and (not br) and (not bl) and tl then
        uvs["tl"] = { 0.5, 0.5 }
        uvs["tr"] = { 1, 0.5 }
        uvs["bl"] = { 0.5, 1 }
        uvs["br"] = { 1, 1 }
    elseif (not br) and (not tl) and (not bl) and tr then
        uvs["tl"] = { 1, 0.5 }
        uvs["tr"] = { 0.5, 0.5 }
        uvs["bl"] = { 1, 1 }
        uvs["br"] = { 0.5, 1 }

        -- two opposites in shadow
    elseif bl and tr and (not tl) and (not br) then
        uvs["tl"] = { 0.5, 0 }
        uvs["tr"] = { 1, 0 }
        uvs["bl"] = { 0.5, 0.5 }
        uvs["br"] = { 1, 0.5 }
    elseif tl and br and (not bl) and (not tr) then
        uvs["tl"] = { 1, 0 }
        uvs["tr"] = { 0.5, 0 }
        uvs["bl"] = { 1, 0.5 }
        uvs["br"] = { 0.5, 0.5 }

        -- not in shadow at all
    elseif (not tr) and (not tl) and (not br) and (not bl) then
        uvs["tl"] = { 0, 0 }
        uvs["tr"] = { 0, 0 }
        uvs["bl"] = { 0, 0 }
        uvs["br"] = { 0, 0 }

        -- all in shadow
    else
        uvs["tl"] = { 0, 0.5 }
        uvs["tr"] = { 0, 0.5 }
        uvs["bl"] = { 0, 0.5 }
        uvs["br"] = { 0, 0.5 }
    end

    return uvs
end

function getQuadsNeaby()
    local quads = {}
    for x = -radius + px, radius + px, 1 do
        for y = -radius + py, radius + py, 1 do
            for z = -radius + pz, radius + pz, 1 do
                if blocksGrid[x] and blocksGrid[x][y] and blocksGrid[x][y][z] and blocksGrid[x][y][z][1] then
                    -- log(blocksGrid[x][y][z])
                    for i = 1, #blocksGrid[x][y][z][1], 1 do
                        table.insert(quads, blocksGrid[x][y][z][1][i])
                    end
                end
            end
        end
    end
    return quads
end

function addToGrid(x, y, z, content)
    if blocksGrid[x] == nil then blocksGrid[x] = {} end
    if blocksGrid[x][y] == nil then blocksGrid[x][y] = {} end
    blocksGrid[x][y][z] = content
end

function isTransparent(x, y, z)
    local transparentTable = { 20, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 79, 212, 213, 165, 9, 415, 0, 18, 102, 31, 175, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 106, 418, 127, 85, 188, 189, 190, 191, 192, 410, 411, 107, 183, 184, 185, 186, 187, 407, 408 }
    local id = dimension.getBlock(x, y, z).id

    for i = 1, #transparentTable do
        if id == transparentTable[i] then
            return true
        end
    end

    return false
end

-- ?make the raycasts inside the face a bit, so that they arent on the verge of hitting blocks in front of them

--[[
    in the block grid:
        nil: not yet checked
        false: is air
        a table: the shadow quads at times

TODO:
    for edge sample points, check a bit to each side of the edge and only make it in shadow if all are in shadow, to have smooth shadows more realistically

    better method of scanning when the player moves, becasue i think it skips things when moving diagonally
        and if you teleport, it will try to fill in the area

    do an initial scan of the volume when the player loads in

    implement different times of day (instead of always using the first one calculated)

    make the quads on the ends stretched out a bit to cover the area that's emptly from hovering them away from the block

    when a lot of things in the queue give back false, it stutters when removing thousands of thing on the same frame
        maybe instead, do a speed check, and only add blocks to the queue if you're going slow enough to appreciate them

    if all the quads on a face are black, just draw one black quad
        if they're all in light, draw nothing

    what if you're in a cave, or it's night?
]]
