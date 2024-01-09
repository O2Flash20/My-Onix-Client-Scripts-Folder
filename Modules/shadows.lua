-- Made By O2Flash20 🙂
name = "Shadows"
description = "Real Time Shadows?!??!"

importLib("logger")

radius = 10
resolution = 2
sunTimesToCheck = 4
timeBetweenQuadUpdates = 0.1 --(seconds)
blocksCheckedPerFrame = 200
blocksGrid = {}

-- ?
edgeSampleOffset = 0

blockCheckQueue = {}
hasDoneInitialScan = false
function update()
    px, py, pz = player.position()

    if not hasDoneInitialScan then
        hasDoneInitialScan = true

        for x = -radius, radius do
            for y = -radius, radius do
                for z = -radius, radius do
                    table.insert(blockCheckQueue, { x + px, y + py, z + pz })
                end
            end
        end
    end

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
            for x = lastX - radius - 1, px - radius, -1 do
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
            for y = lastY - radius - 1, py - radius, -1 do
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
            for z = lastZ - radius - 1, pz - radius, -1 do
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
    -- log(#blockCheckQueue)
    if #blockCheckQueue > 0 then
        local blocksChecked = 0
        while blocksChecked < blocksCheckedPerFrame and #blockCheckQueue > 0 do
            local wasChecked = checkBlockFromQueue() --this also actually does the check, but returns if work was done
            if wasChecked then
                blocksChecked = blocksChecked + 1
            else
                blocksChecked = blocksChecked + 0.01 --if it wasnt a block that had quads, do them way faster
            end
        end
    end

    if not px or not py or not pz then return end
    -- update the quads to render list every so often
    t = t + dt
    if t >= timeBetweenQuadUpdates then
        t = 0
        quadsToRender = getQuadsNeaby()
    end

    gfx.tcolor(255, 255, 255, 100)
    gfx.tquadbatch(
        quadsToRender, "shadowTiles", false
    )
end

raycastOffset = 0.01
allQuads = {}
function checkBlockFromQueue()
    -- *Starts from the end
    local bx = blockCheckQueue[#blockCheckQueue][1]
    local by = blockCheckQueue[#blockCheckQueue][2]
    local bz = blockCheckQueue[#blockCheckQueue][3]

    if blocksGrid[bx] ~= nil and blocksGrid[bx][by] ~= nil and blocksGrid[bx][by][bz] ~= nil then --if this block has already been done, skip it
        table.remove(blockCheckQueue)
        return false
    end

    if isTransparent(bx, by, bz) then
        addToGrid(bx, by, bz, false)
        table.remove(blockCheckQueue)
        return false
    end

    -- now I know this is a block I have to check all the sides of
    thisBlockQuads = {} -- this table will contain a few time indices, and within them, all the quads that belong to this block that should be drawn at this time
    -- later, this will be added to the grid
    -- then, it will go through all these grid entries and put all the quads for the time it wants into one long table

    -- the block is new and is solid, so see which of its faces are exposed
    if isTransparent(bx + 1, by, bz) then
        local faceSampleInfo = {} --a 2d table, each element is a point that was sampled and contains {time: isInShadowAtThatTime}
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
        local faceSampleInfo = {} --a 2d table, each element is a point that was sampled and contains {time: isInShadowAtThatTime}
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
        local faceSampleInfo = {} --a 2d table, each element is a point that was sampled and contains {time: isInShadowAtThatTime}

        local numQuadsInShadow = {}
        for i = 1, sunTimesToCheck, 1 do
            numQuadsInShadow[i] = 0 --fill it with 0 to avoid errors later on
        end

        -- get all the samples of where the shadows will fall
        for i = 0, resolution, 1 do
            faceSampleInfo[i] = {}
            for j = 0, resolution, 1 do
                local sampleX = i / resolution
                local sampleY = j / resolution

                local sample = whenIsPointInShadow(sampleX + bx, by + 1 + raycastOffset, sampleY + bz, 3)
                for k = 1, #sample, 1 do --for each time, count up how many of the sample points are in shadow
                    if sample[k] then
                        numQuadsInShadow[k] = numQuadsInShadow[k] + 1
                    end
                end

                faceSampleInfo[i][j] = sample
            end
        end

        -- Now, make quads with faceSampleInfo
        for k = 1, sunTimesToCheck, 1 do
            if thisBlockQuads[k] == nil then
                thisBlockQuads[k] = {}
            end


            if numQuadsInShadow[k] == 0 then
                -- do nothing (no shadow here)
            elseif numQuadsInShadow[k] == (resolution + 1) * (resolution + 1) then --it's all shadow, so only render one quad for the whole face
                table.insert(thisBlockQuads[k], {
                    bx, by + 1 + raycastOffset, bz + 1,
                    0, 0.5,
                    bx + 1, by + 1 + raycastOffset, bz + 1,
                    0, 0.5,
                    bx + 1, by + 1 + raycastOffset, bz,
                    0, 0.5,
                    bx, by + 1 + raycastOffset, bz,
                    0, 0.5
                })
            else
                -- it's gonna require many different quads
                for i = 0, resolution - 1, 1 do
                    for j = 0, resolution - 1, 1 do
                        local topLeftIsShadow = faceSampleInfo[i][j + 1][k]
                        local topRightIsShadow = faceSampleInfo[i + 1][j + 1][k]
                        local bottomLeftIsShadow = faceSampleInfo[i][j][k]
                        local bottomRightIsShadow = faceSampleInfo[i + 1][j][k]

                        local uvs = uvCoordsFromCornerShadows(
                            topLeftIsShadow, topRightIsShadow, bottomLeftIsShadow, bottomRightIsShadow
                        )

                        local rightEdgeOffset = 0
                        local leftEdgeOffset = 0
                        if i == 0 then
                            leftEdgeOffset = -raycastOffset / 2
                        elseif i == resolution - 1 then
                            rightEdgeOffset = raycastOffset / 2
                        end

                        local topEgdeOffset = 0
                        local bottomEdgeOffset = 0
                        if j == 0 then
                            bottomEdgeOffset = -raycastOffset / 2
                        elseif j == resolution - 1 then
                            topEgdeOffset = raycastOffset / 2
                        end

                        table.insert(thisBlockQuads[k], {
                            i / resolution + bx + leftEdgeOffset,
                            by + 1 + raycastOffset,
                            (j + 1) / resolution + bz + topEgdeOffset,
                            uvs["tl"][1], uvs["tl"][2],
                            (i + 1) / resolution + bx + rightEdgeOffset,
                            by + 1 + raycastOffset,
                            (j + 1) / resolution + bz + topEgdeOffset,
                            uvs["tr"][1], uvs["tr"][2],
                            (i + 1) / resolution + bx + rightEdgeOffset,
                            by + 1 + raycastOffset,
                            j / resolution + bz + bottomEdgeOffset,
                            uvs["br"][1], uvs["br"][2],
                            i / resolution + bx + leftEdgeOffset,
                            by + 1 + raycastOffset,
                            j / resolution + bz + bottomEdgeOffset,
                            uvs["bl"][1], uvs["bl"][2],
                        })
                    end
                end
            end
        end
    end
    if isTransparent(bx, by - 1, bz) then --*this can only be in shadow
        local faceSampleInfo = {}         --a 2d table, each element is a point that was sampled and contains {time: isInShadowAtThatTime}
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
        local faceSampleInfo = {} --a 2d table, each element is a point that was sampled and contains {time: isInShadowAtThatTime}
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
        local faceSampleInfo = {} --a 2d table, each element is a point that was sampled and contains {time: isInShadowAtThatTime}
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
    table.remove(blockCheckQueue)
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
    -- log(x, y, z)
    for i = 1, sunTimesToCheck, 1 do
        local thisSunTime = ((i - 0.5) / (2 * sunTimesToCheck) + 0.75) % 1
        local thisSunAngle = -2 * math.pi * thisSunTime
        local thisSunDirX = math.sin(thisSunAngle)
        local thisSunDirY = math.cos(thisSunAngle)

        if (direction == 1 and thisSunDirX < 0) or (direction == 2 and thisSunDirX > 0) or direction == 4 then
            table.insert(times, true) --these must be in shadow, no need to check
        else
            -- if the x, y, or z coordinate is on an edge, you'll need to check twice, once on each side of the edge
            local numXToCheck = 1
            if x == math.floor(x) then numXToCheck = 2 end
            local numYToCheck = 1
            if y == math.floor(y) then numYToCheck = 2 end
            local numZToCheck = 1
            if z == math.floor(z) then numZToCheck = 2 end

            local isInShadow = false
            for j = 1, numXToCheck, 1 do
                for k = 1, numYToCheck, 1 do
                    for l = 1, numZToCheck, 1 do
                        local xSamplePos = 0.1 * ((2 * numXToCheck - 2) * j - (3 * numXToCheck - 3)) + x
                        local ySamplePos = 0.1 * ((2 * numYToCheck - 2) * k - (3 * numYToCheck - 3)) + y
                        local zSamplePos = 0.1 * ((2 * numZToCheck - 2) * l - (3 * numZToCheck - 3)) + z
                        if dimension.raycast(
                                xSamplePos, ySamplePos, zSamplePos,
                                xSamplePos + thisSunDirX * 100, ySamplePos + thisSunDirY * 100, zSamplePos
                            ).isBlock == true then
                            isInShadow = true
                            goto skipCheck
                        end
                    end
                end
            end
            ::skipCheck::

            table.insert(times, isInShadow)
        end
    end
    return times
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
    -- getting the closest time sample to the current time:
    local lowestSampleDist = 10000000
    local lowestSampleIndex = -1
    local thisTime = dimension.time()
    for i = 1, sunTimesToCheck do
        local thisSampleTime = ((i - 0.5) / (2 * sunTimesToCheck) + 0.75) % 1
        local timeDiff = math.abs(thisTime - thisSampleTime) --the difference between this sample's time and the actual time
        if (timeDiff < lowestSampleDist) then
            lowestSampleDist = timeDiff
            lowestSampleIndex = i
        end
    end

    -- lowestSampleIndex = 1

    local quads = {}
    for x = -radius + px, radius + px, 1 do
        for y = -radius + py, radius + py, 1 do
            for z = -radius + pz, radius + pz, 1 do
                if blocksGrid[x] and blocksGrid[x][y] and blocksGrid[x][y][z] and blocksGrid[x][y][z][lowestSampleIndex] then
                    -- log(blocksGrid[x][y][z])
                    for i = 1, #blocksGrid[x][y][z][lowestSampleIndex], 1 do
                        table.insert(quads, blocksGrid[x][y][z][lowestSampleIndex][i])
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
    local transparentTable = { 50, 523, 385, 20, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 79, 212, 213, 165, 9, 8, 415, 0, 102, 31, 175, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 106, 418, 127, 85, 188, 189, 190, 191, 192, 410, 411, 107, 183, 184, 185, 186, 187, 407, 408, 666 }
    local id = dimension.getBlock(x, y, z).id

    for i = 1, #transparentTable do
        if id == transparentTable[i] then
            return true
        end
    end

    return false
end

--[[
    in the block grid:
        nil: not yet checked
        false: is air
        a table: the shadow quads at times

TODO:
    make the quads on the ends stretched out a bit to cover the area that's emptly from hovering them away from the block
        kinda works, but if it's just always done, when blocks are flat next to eachother there will be a bit of overlap, and z-fighting between the blocks

    if all the quads on a face are black, just draw one black quad
        if they're all in light, draw nothing
        *do this for all faces (only +y is done right now)

    what if you're in a cave, or it's night?
        when gathering quads, check how many are in light
            if very few are, dont draw any at all

    things to make transparent: slabs, stairs, trapdoors, carpets, candles, snow, lanterns, item frame, cave vines, glass panes, azalea, fences, walls, fence gates, anvils, scaffolding, moss carpet, sweet berry bush
]]
