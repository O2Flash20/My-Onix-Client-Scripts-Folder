-- Made By O2Flash20 🙂
name = "Better Visuals OLD"
description = "Auto exposure, lens flares, more???"

importLib("renderThreeD")
importLib("vectors")
importLib("logger")

blankTexture = gfx2.createCpuRenderTarget(1, 1)
shadowTexture = gfx2.createCpuRenderTarget(1, 1)
shouldUploadTexture = false
shouldSetTexture = true

function render2()
    if shouldSetTexture then
        gfx2.bindRenderTarget(blankTexture)
        gfx2.color(255, 255, 255)
        gfx2.fillRect(0, 0, 1, 1)

        gfx2.bindRenderTarget(shadowTexture)
        -- gfx2.color(0, 0, 0, 255)
        -- gfx2.fillRect(0, 0, 1, 1) --*maybe use this gradient for smooth shadows
        gfx2.color(0, 0, 0, 100)
        gfx2.fillRect(0, 1, 1, 1)
        -- gfx2.color(0, 0, 0, 0)
        -- gfx2.fillRect(0, 2, 1, 1)

        gfx2.bindRenderTarget(nil)
        shouldUploadTexture = true
        shouldSetTexture = false
    end
end

function findSettings()
    local mods = client.modules()
    local ppMod
    for i = 1, #mods, 1 do
        if mods[i].name == "Post Processing" then
            ppMod = mods[i]
        end
    end

    local brightnessSetting
    for i = 1, #ppMod.settings, 1 do
        if ppMod.settings[i].name == "Brightness Strength" then
            brightnessSetting = ppMod.settings[i]
        end
    end
    local contrastSetting
    for i = 1, #ppMod.settings, 1 do
        if ppMod.settings[i].name == "Contrast Strength" then
            contrastSetting = ppMod.settings[i]
        end
    end

    return brightnessSetting, contrastSetting
end

brightnessSetting = nil
contrastSetting = nil
function onEnable()
    brightnessSetting, contrastSetting = findSettings()
    px, py, pz = player.pposition()
end

nextBrightness = 1
nextContrast = 1
timeSinceUpdate = 0
i = 0
changeSlowness = 2
function update()
    i = i + 1
    if i % changeSlowness ~= 0 then return end
    timeSinceUpdate      = 0

    local px, py, pz     = player.pposition()
    local ex, ey, ez     = player.forwardPosition(1000)
    local hit            = dimension.raycast(px, py, pz, ex, ey, ez, 1000, true, true, true)
    local brightCheckVec = vec:new(hit.px - px, hit.py - py, hit.pz - pz)
    brightCheckVec:setMag(brightCheckVec:mag() - 1)

    local combinedBrightness = getVisualBrightness(
        math.floor(brightCheckVec.x + px),
        math.floor(brightCheckVec.y + py),
        math.floor(brightCheckVec.z + pz)
    )
    local maxBright          = 1.8
    local maxCont            = 0.5

    thisBrightness           = nextBrightness
    thisContrast             = nextContrast

    nextBrightness           = ((1 - maxBright) / 14) * combinedBrightness + maxBright
    nextContrast             = -(maxCont / 14) * combinedBrightness + maxCont
end

thisBrightness = nil
thisContrast = nil
function render(dt)
    if not timeSinceUpdate or not changeSlowness then return end
    timeSinceUpdate         = timeSinceUpdate + dt
    brightnessSetting.value = map(timeSinceUpdate, 0, 0.11 * changeSlowness, thisBrightness, nextBrightness)
    contrastSetting.value   = map(timeSinceUpdate, 0, 0.11 * changeSlowness, thisContrast, nextContrast)

    local sunDir            = getSunDir()
    local midX, midY        = gfx.worldToScreen(sunDir[1] * 1000000000, sunDir[2] * 1000000000, 0)

    px, py, pz              = player.pposition()
    if dimension.raycast(px, py, pz, px + getSunDir()[1] * 1000, py + getSunDir()[2] * 1000, pz).isBlock then
        return
    end

    local sunCoords = getSunCoords()
    local trX, trY  = gfx.worldToScreen(
        sunCoords.topRight[1] * 1000000000,
        sunCoords.topRight[2] * 1000000000,
        sunCoords.topRight[3] * 1000000000
    )
    local tlX, tlY  = gfx.worldToScreen(
        sunCoords.topLeft[1] * 1000000000,
        sunCoords.topLeft[2] * 1000000000,
        sunCoords.topLeft[3] * 1000000000
    )
    local brX, brY  = gfx.worldToScreen(
        sunCoords.bottomRight[1] * 1000000000,
        sunCoords.bottomRight[2] * 1000000000,
        sunCoords.bottomRight[3] * 1000000000
    )
    local blX, blY  = gfx.worldToScreen(
        sunCoords.bottomLeft[1] * 1000000000,
        sunCoords.bottomLeft[2] * 1000000000,
        sunCoords.bottomLeft[3] * 1000000000
    )

    local w         = gui.width()
    local h         = gui.height()
    if midX and midY and trX and trY and tlX and tlY and brX and brY and blX and blY then
        gfx.tcolor(255, 255, 255, 255)
        gfx.tquad(
            (tlX - midX) * 10 + midX, (tlY - midY) * 10 + midY, 0, 0,
            (trX - midX) * 10 + midX, (trY - midY) * 10 + midY, 1, 0,
            (brX - midX) * 10 + midX, (brY - midY) * 10 + midY, 1, 1,
            (blX - midX) * 10 + midX, (blY - midY) * 10 + midY, 0, 1,
            "betterVisuals/sunFlares.png"
        )

        gfx.tcolor(0, 0, 100, 100)
        gfx.tquad(
            (tlX - w / 2) / 2 + w / 2, (tlY - h / 2) / 2 + h / 2,
            0, 0,
            (trX - w / 2) / 2 + w / 2, (trY - h / 2) / 2 + h / 2,
            1, 0,
            (brX - w / 2) / 2 + w / 2, (brY - h / 2) / 2 + h / 2,
            1, 1,
            (blX - w / 2) / 2 + w / 2, (blY - h / 2) / 2 + h / 2,
            0, 1,
            "betterVisuals/squareFlare.png"
        )
        gfx.tcolor(0, 0, 100, 100)
        gfx.tquad(
            (((tlX - midX) * 0.3 + midX) - w / 2) * 0.6 + w / 2, (((tlY - midY) * 0.3 + midY) - h / 2) * 0.6 + h / 2,
            0, 0,
            (((trX - midX) * 0.3 + midX) - w / 2) * 0.6 + w / 2, (((trY - midY) * 0.3 + midY) - h / 2) * 0.6 + h / 2,
            1, 0,
            (((brX - midX) * 0.3 + midX) - w / 2) * 0.6 + w / 2, (((brY - midY) * 0.3 + midY) - h / 2) * 0.6 + h / 2,
            1, 1,
            (((blX - midX) * 0.3 + midX) - w / 2) * 0.6 + w / 2, (((blY - midY) * 0.3 + midY) - h / 2) * 0.6 + h / 2,
            0, 1,
            "betterVisuals/squareFlare.png"
        )

        gfx.tcolor(100, 255, 100, 255)
        gfx.tquad(
            (((tlX - midX) * 0.9 + midX) - w / 2) * 0.35 + w / 2, (((tlY - midY) * 0.9 + midY) - h / 2) * 0.35 + h / 2,
            0, 0,
            (((trX - midX) * 0.9 + midX) - w / 2) * 0.35 + w / 2, (((trY - midY) * 0.9 + midY) - h / 2) * 0.35 + h / 2,
            1, 0,
            (((brX - midX) * 0.9 + midX) - w / 2) * 0.35 + w / 2, (((brY - midY) * 0.9 + midY) - h / 2) * 0.35 + h / 2,
            1, 1,
            (((blX - midX) * 0.9 + midX) - w / 2) * 0.35 + w / 2, (((blY - midY) * 0.9 + midY) - h / 2) * 0.35 + h / 2,
            0, 1,
            "betterVisuals/squareFlare.png"
        )

        gfx.tcolor(181, 113, 17, 150)
        gfx.tquad(
            -tlX + w, -tlY + h,
            0, 0,
            -trX + w, -trY + h,
            1, 0,
            -brX + w, -brY + h,
            1, 1,
            -blX + w, -blY + h,
            0, 1,
            "betterVisuals/squareFlare.png"
        )
        gfx.tcolor(181, 113, 17, 100)
        gfx.tquad(
            -((tlX - midX) * 3 + midX) + w, -((tlY - midY) * 3 + midY) + h,
            0, 0,
            -((trX - midX) * 3 + midX) + w, -((trY - midY) * 3 + midY) + h,
            1, 0,
            -((brX - midX) * 3 + midX) + w, -((brY - midY) * 3 + midY) + h,
            1, 1,
            -((blX - midX) * 3 + midX) + w, -((blY - midY) * 3 + midY) + h,
            0, 1,
            "betterVisuals/squareFlare.png"
        )

        gfx.tcolor(52, 152, 17, 150)
        gfx.tquad(
            -(tlX - w / 2) * 3 + w / 2, -(tlY - h / 2) * 3 + h / 2,
            0, 0,
            -(trX - w / 2) * 3 + w / 2, -(trY - h / 2) * 3 + h / 2,
            1, 0,
            -(brX - w / 2) * 3 + w / 2, -(brY - h / 2) * 3 + h / 2,
            1, 1,
            -(blX - w / 2) * 3 + w / 2, -(blY - h / 2) * 3 + h / 2,
            0, 1,
            "betterVisuals/squareFlare.png"
        )
        gfx.tcolor(52, 152, 17, 50)
        gfx.tquad(
            -(((tlX - midX) * 2.5 + midX) - w / 2) * 10 + w / 2, -(((tlY - midY) * 2.5 + midY) - h / 2) * 10 + h / 2,
            0, 0,
            -(((trX - midX) * 2.5 + midX) - w / 2) * 10 + w / 2, -(((trY - midY) * 2.5 + midY) - h / 2) * 10 + h / 2,
            1, 0,
            -(((brX - midX) * 2.5 + midX) - w / 2) * 10 + w / 2, -(((brY - midY) * 2.5 + midY) - h / 2) * 10 + h / 2,
            1, 1,
            -(((blX - midX) * 2.5 + midX) - w / 2) * 10 + w / 2, -(((blY - midY) * 2.5 + midY) - h / 2) * 10 + h / 2,
            0, 1,
            "betterVisuals/squareFlare.png"
        )
    end
end

function getSunDir()
    local time = -dimension.time() * 2 * math.pi
    return { math.sin(time), math.cos(time), 0 }
end

function getSunCoords()
    local time = -dimension.time() * 2 * math.pi
    return {
        mid = { math.sin(time), math.cos(time), 0 },
        topRight = { math.sin(time + 0.085), math.cos(time + 0.085), 0.085 },
        topLeft = { math.sin(time + 0.085), math.cos(time + 0.085), -0.085 },
        bottomRight = { math.sin(time - 0.085), math.cos(time - 0.085), 0.085 },
        bottomLeft = { math.sin(time - 0.085), math.cos(time - 0.085), -0.085 },
    }
end

function getVisualBrightness(x, y, z)
    local t = math.abs(dimension.time() - 0.5) * 2
    local sunBrightness
    if t < 0.45 then
        sunBrightness = 3.5
    elseif t > 0.6 then
        sunBrightness = 14
    else
        sunBrightness = 70 * t - 28
    end

    local blockLight, skyLight = dimension.getBrightness(
        math.floor(x),
        math.floor(y),
        math.floor(z)
    )

    skyLight = math.min(sunBrightness, skyLight)
    return math.clamp(blockLight + skyLight, 0, 14)
end

-- maps a value from one range to another
function map(val, min1, max1, min2, max2)
    return (val - min1) * (max2 - min2) / (max1 - min1) + min2
end

function render3d()
    if shouldUploadTexture then
        gfx.uploadImage("blank", blankTexture.cpuTexture)
        gfx.uploadImage("shadowTexture", shadowTexture.cpuTexture)
        shouldUploadTexture = false
    end

    gfx.color(0, 0, 0, 100)
    -- gfx.tcolor(0, 0, 0, 200)
    for i = 1, #shadowQuads, 1 do
        gfx.quad(
            shadowQuads[i][1][1], shadowQuads[i][1][2], shadowQuads[i][1][3],
            shadowQuads[i][2][1], shadowQuads[i][2][2], shadowQuads[i][2][3],
            shadowQuads[i][3][1], shadowQuads[i][3][2], shadowQuads[i][3][3],
            shadowQuads[i][4][1], shadowQuads[i][4][2], shadowQuads[i][4][3],
            true
        )

        -- gfx.tquad(
        --     testFaces[i][1][1], testFaces[i][1][2], testFaces[i][1][3], 0, 0,
        --     testFaces[i][2][1], testFaces[i][2][2], testFaces[i][2][3], 0, 0,
        --     testFaces[i][3][1], testFaces[i][3][2], testFaces[i][3][3], 0, 0,
        --     testFaces[i][4][1], testFaces[i][4][2], testFaces[i][4][3], 0, 0,
        --     "blank"
        -- )
        -- gfx.tquad(
        --     testFaces[i][4][1], testFaces[i][4][2], testFaces[i][4][3], 0, 0,
        --     testFaces[i][3][1], testFaces[i][3][2], testFaces[i][3][3], 0, 0,
        --     testFaces[i][2][1], testFaces[i][2][2], testFaces[i][2][3], 0, 0,
        --     testFaces[i][1][1], testFaces[i][1][2], testFaces[i][1][3], 0, 0,
        --     "blank"
        -- )
    end

    for i = 1, 5, 1 do
        coroutine.resume(getBlocks)
    end
    if numRadiiCompleted > 1 then
        getExposedFacesFromQueue(5, numRadiiCompleted - 1)
        exposedFacesToShadowQuads(1)
        -- log(#exposedFaces)
    end
end

-- ?
testFaces = {}
event.listen("KeyboardInput", function(key, down)
    if key == 75 and down then
        -- testFaces = getShadowQuads(getExposedFaces(10))
        testFaces = getShadowQuadsRes(getExposedFaces(10), 5)
    end
end)
-- ?
function getExposedFaces(radius)
    local px, py, pz = player.position()

    local blocks = {}
    for x = 1, radius * 2, 1 do
        table.insert(blocks, {})
        for y = 1, radius * 2, 1 do
            table.insert(blocks[x], {})
            for z = 1, radius * 2, 1 do
                table.insert(
                    blocks[x][y],
                    not isTransparent(
                        px + x - radius,
                        py + y - radius,
                        pz + z - radius
                    )
                )
            end
        end
    end

    local faces = {}
    for x = 2, radius * 2 - 1, 1 do
        for y = 2, radius * 2 - 1, 1 do
            for z = 2, radius * 2 - 1, 1 do
                if blocks[x][y][z] then -- if the last thing in the returned table is true, the face is facing in the positive direction
                    if not blocks[x + 1][y][z] then
                        table.insert(faces, { px + x - radius + 1, py + y - radius + 0.5, pz + z - radius + 0.5, true })
                    end
                    if not blocks[x - 1][y][z] then
                        table.insert(faces, { px + x - radius, py + y - radius + 0.5, pz + z - radius + 0.5, false })
                    end
                    if not blocks[x][y + 1][z] then
                        table.insert(faces, { px + x - radius + 0.5, py + y - radius + 1, pz + z - radius + 0.5, true })
                    end
                    if not blocks[x][y - 1][z] then
                        table.insert(faces, { px + x - radius + 0.5, py + y - radius, pz + z - radius + 0.5, false })
                    end
                    if not blocks[x][y][z + 1] then
                        table.insert(faces, { px + x - radius + 0.5, py + y - radius + 0.5, pz + z - radius + 1, true })
                    end
                    if not blocks[x][y][z - 1] then
                        table.insert(faces, { px + x - radius + 0.5, py + y - radius + 0.5, pz + z - radius, false })
                    end
                end
            end
        end
    end
    return faces
end

exposedFaceCheckQueue = {}

blocksGrid = {}
gridR = 10
numRadiiCompleted = 1
getBlocks = coroutine.create(function()
    ::start::
    centerX, centerY, centerZ = player.position()
    table.insert(exposedFaceCheckQueue, {})
    for x = centerX - gridR, centerX + gridR, 1 do
        blocksGrid[x] = {}
        for y = centerY - gridR, centerY + gridR, 1 do
            blocksGrid[x][y] = {}
            for z = centerZ - gridR, centerZ + gridR do
                if (not isTransparent(x, y, z)) then
                    blocksGrid[x][y][z] = true
                    table.insert(exposedFaceCheckQueue[numRadiiCompleted], { x, y, z })
                else
                    blocksGrid[x][y][z] = false
                end
                coroutine.yield()
            end
        end
    end
    numRadiiCompleted = numRadiiCompleted + 1
    goto start
end)

exposedFaces = {}
function getExposedFacesFromQueue(numBlocksToCheck, queueNumToCheck)
    for i = 1, math.min(numBlocksToCheck, #exposedFaceCheckQueue[queueNumToCheck]), 1 do
        local thisBlock = exposedFaceCheckQueue[queueNumToCheck][i]
        local x = thisBlock[1]
        local y = thisBlock[2]
        local z = thisBlock[3]

        if blocksGrid[x + 1] and blocksGrid[x + 1][y] and not blocksGrid[x + 1][y][z] then
            table.insert(exposedFaces, { x + 1, y + 0.5, z + 0.5, true })
        end
        if blocksGrid[x - 1] and blocksGrid[x - 1][y] and not blocksGrid[x - 1][y][z] then
            table.insert(exposedFaces, { x, y + 0.5, z + 0.5, false })
        end
        if blocksGrid[x][y + 1] and not blocksGrid[x][y + 1][z] then
            table.insert(exposedFaces, { x + 0.5, y + 1, z + 0.5, true })
        end
        if blocksGrid[x][y - 1] and not blocksGrid[x][y - 1][z] then
            table.insert(exposedFaces, { x + 0.5, y, z + 0.5, false })
        end
        if blocksGrid[x][y] and not blocksGrid[x][y][z + 1] then
            table.insert(exposedFaces, { x + 0.5, y + 0.5, z + 1, true })
        end
        if blocksGrid[x][y] and not blocksGrid[x][y][z - 1] then
            table.insert(exposedFaces, { x + 0.5, y + 0.5, z, false })
        end
    end

    for i = 1, math.min(numBlocksToCheck, #exposedFaceCheckQueue[queueNumToCheck] - 1), 1 do
        table.remove(exposedFaceCheckQueue[queueNumToCheck], i)
    end
end

shadowQuads = {}
function exposedFacesToShadowQuads(resolution)
    local sun = getSunCoords()
    local faces = exposedFaces

    for i = 1, #exposedFaces do
        --helps z-fighting
        local offset = 0
        local o = 0.01
        if faces[i][4] then
            offset = o
        else
            offset = -o
        end

        if math.floor(faces[i][1]) == faces[i][1] then --it's an x face
            for y = 1, resolution, 1 do
                for z = 1, resolution, 1 do
                    local yOffset = (y - 0.5) / resolution - 0.5
                    local zOffset = (z - 0.5) / resolution - 0.5
                    if dimension.raycast(
                            faces[i][1] + offset, faces[i][2] + yOffset, faces[i][3] + zOffset,
                            faces[i][1] + sun.mid[1] * 10000, faces[i][2] + yOffset + sun.mid[2] * 10000, faces[i][3] + zOffset + sun.mid[3] * 10000
                        ).isBlock then
                        local negY = (y - 1) / resolution - 0.5
                        local posY = y / resolution - 0.5
                        local negZ = (z - 1) / resolution - 0.5
                        local posZ = z / resolution - 0.5
                        table.insert(shadowQuads, {
                            { faces[i][1] + offset, faces[i][2] + posY + o, faces[i][3] + posZ + o },
                            { faces[i][1] + offset, faces[i][2] + posY + o, faces[i][3] + negZ - o },
                            { faces[i][1] + offset, faces[i][2] + negY - o, faces[i][3] + negZ - o },
                            { faces[i][1] + offset, faces[i][2] + negY - o, faces[i][3] + posZ + o },
                        })
                    end
                end
            end
        elseif math.floor(faces[i][2]) == faces[i][2] then --it's a y face
            for x = 1, resolution, 1 do
                for z = 1, resolution, 1 do
                    local xOffset = (x - 0.5) / resolution - 0.5
                    local zOffset = (z - 0.5) / resolution - 0.5
                    if dimension.raycast(
                            faces[i][1] + xOffset, faces[i][2] + offset, faces[i][3] + zOffset,
                            faces[i][1] + xOffset + sun.mid[1] * 10000, faces[i][2] + sun.mid[2] * 10000, faces[i][3] + zOffset + sun.mid[3] * 10000
                        ).isBlock then
                        local negX = (x - 1) / resolution - 0.5
                        local posX = x / resolution - 0.5
                        local negZ = (z - 1) / resolution - 0.5
                        local posZ = z / resolution - 0.5
                        table.insert(shadowQuads, {
                            { faces[i][1] + negX - o, faces[i][2] + offset, faces[i][3] + posZ + o },
                            { faces[i][1] + posX + o, faces[i][2] + offset, faces[i][3] + posZ + o },
                            { faces[i][1] + posX + o, faces[i][2] + offset, faces[i][3] + negZ - o },
                            { faces[i][1] + negX - o, faces[i][2] + offset, faces[i][3] + negZ - o },
                        })
                    end
                end
            end
        elseif math.floor(faces[i][3]) == faces[i][3] then --it's a z face
            for x = 1, resolution, 1 do
                for y = 1, resolution, 1 do
                    local xOffset = (x - 0.5) / resolution - 0.5
                    local yOffset = (y - 0.5) / resolution - 0.5
                    if dimension.raycast(
                            faces[i][1] + xOffset, faces[i][2] + yOffset, faces[i][3] + offset,
                            faces[i][1] + xOffset + sun.mid[1] * 10000, faces[i][2] + yOffset + sun.mid[2] * 10000, faces[i][3] + sun.mid[3] * 10000
                        ).isBlock then
                        local negX = (x - 1) / resolution - 0.5
                        local posX = x / resolution - 0.5
                        local negY = (y - 1) / resolution - 0.5
                        local posY = y / resolution - 0.5
                        table.insert(shadowQuads, {
                            { faces[i][1] + negX - o, faces[i][2] + posY + o, faces[i][3] + offset },
                            { faces[i][1] + posX + o, faces[i][2] + posY + o, faces[i][3] + offset },
                            { faces[i][1] + posX + o, faces[i][2] + negY - o, faces[i][3] + offset },
                            { faces[i][1] + negX - o, faces[i][2] + negY - o, faces[i][3] + offset },
                        })
                    end
                end
            end
        end
    end
    exposedFaces = {}
end

-- !old
function getShadowQuads(faces)
    local sun = getSunCoords()

    local shadowQuads = {}
    for i = 1, #faces, 1 do
        if dimension.raycast(
                faces[i][1], faces[i][2], faces[i][3],
                faces[i][1] + sun.mid[1] * 10000, faces[i][2] + sun.mid[2] * 10000, faces[i][3] + sun.mid[3] * 10000
            ).isBlock then
            --helps z-fighting
            local offset = 0
            local o = 0.01
            if faces[i][4] then
                offset = o
            else
                offset = -o
            end

            if math.floor(faces[i][1]) == faces[i][1] then --it's an x face
                table.insert(shadowQuads, {
                    { faces[i][1] + offset, faces[i][2] + 0.5 + o, faces[i][3] + 0.5 + o },
                    { faces[i][1] + offset, faces[i][2] + 0.5 + o, faces[i][3] - 0.5 - o },
                    { faces[i][1] + offset, faces[i][2] - 0.5 - o, faces[i][3] - 0.5 - o },
                    { faces[i][1] + offset, faces[i][2] - 0.5 - o, faces[i][3] + 0.5 + o },
                })
            elseif math.floor(faces[i][2]) == faces[i][2] then --it's a y face
                table.insert(shadowQuads, {
                    { faces[i][1] - 0.5 - o, faces[i][2] + offset, faces[i][3] + 0.5 + o },
                    { faces[i][1] + 0.5 + o, faces[i][2] + offset, faces[i][3] + 0.5 + o },
                    { faces[i][1] + 0.5 + o, faces[i][2] + offset, faces[i][3] - 0.5 - o },
                    { faces[i][1] - 0.5 - o, faces[i][2] + offset, faces[i][3] - 0.5 - o },
                })
            elseif math.floor(faces[i][3]) == faces[i][3] then --it's a z face
                table.insert(shadowQuads, {
                    { faces[i][1] - 0.5 - o, faces[i][2] + 0.5 + o, faces[i][3] + offset },
                    { faces[i][1] + 0.5 + o, faces[i][2] + 0.5 + o, faces[i][3] + offset },
                    { faces[i][1] + 0.5 + o, faces[i][2] - 0.5 - o, faces[i][3] + offset },
                    { faces[i][1] - 0.5 - o, faces[i][2] - 0.5 - o, faces[i][3] + offset },
                })
            end
        end
    end

    return shadowQuads
end

-- ?
function getShadowQuadsRes(faces, resolution)
    local sun = getSunCoords()

    local shadowQuads = {}

    for i = 1, #faces do
        --helps z-fighting
        local offset = 0
        local o = 0.01
        if faces[i][4] then
            offset = o
        else
            offset = -o
        end

        if math.floor(faces[i][1]) == faces[i][1] then --it's an x face
            for y = 1, resolution, 1 do
                for z = 1, resolution, 1 do
                    local yOffset = (y - 0.5) / resolution - 0.5
                    local zOffset = (z - 0.5) / resolution - 0.5
                    if dimension.raycast(
                            faces[i][1] + offset, faces[i][2] + yOffset, faces[i][3] + zOffset,
                            faces[i][1] + sun.mid[1] * 10000, faces[i][2] + yOffset + sun.mid[2] * 10000, faces[i][3] + zOffset + sun.mid[3] * 10000
                        ).isBlock then
                        local negY = (y - 1) / resolution - 0.5
                        local posY = y / resolution - 0.5
                        local negZ = (z - 1) / resolution - 0.5
                        local posZ = z / resolution - 0.5
                        table.insert(shadowQuads, {
                            { faces[i][1] + offset, faces[i][2] + posY + o, faces[i][3] + posZ + o },
                            { faces[i][1] + offset, faces[i][2] + posY + o, faces[i][3] + negZ - o },
                            { faces[i][1] + offset, faces[i][2] + negY - o, faces[i][3] + negZ - o },
                            { faces[i][1] + offset, faces[i][2] + negY - o, faces[i][3] + posZ + o },
                        })
                    end
                end
            end
        elseif math.floor(faces[i][2]) == faces[i][2] then --it's a y face
            for x = 1, resolution, 1 do
                for z = 1, resolution, 1 do
                    local xOffset = (x - 0.5) / resolution - 0.5
                    local zOffset = (z - 0.5) / resolution - 0.5
                    if dimension.raycast(
                            faces[i][1] + xOffset, faces[i][2] + offset, faces[i][3] + zOffset,
                            faces[i][1] + xOffset + sun.mid[1] * 10000, faces[i][2] + sun.mid[2] * 10000, faces[i][3] + zOffset + sun.mid[3] * 10000
                        ).isBlock then
                        local negX = (x - 1) / resolution - 0.5
                        local posX = x / resolution - 0.5
                        local negZ = (z - 1) / resolution - 0.5
                        local posZ = z / resolution - 0.5
                        table.insert(shadowQuads, {
                            { faces[i][1] + negX - o, faces[i][2] + offset, faces[i][3] + posZ + o },
                            { faces[i][1] + posX + o, faces[i][2] + offset, faces[i][3] + posZ + o },
                            { faces[i][1] + posX + o, faces[i][2] + offset, faces[i][3] + negZ - o },
                            { faces[i][1] + negX - o, faces[i][2] + offset, faces[i][3] + negZ - o },
                        })
                    end
                    -- end
                end
            end
        elseif math.floor(faces[i][3]) == faces[i][3] then --it's a z face
            for x = 1, resolution, 1 do
                for y = 1, resolution, 1 do
                    local xOffset = (x - 0.5) / resolution - 0.5
                    local yOffset = (y - 0.5) / resolution - 0.5
                    if dimension.raycast(
                            faces[i][1] + xOffset, faces[i][2] + yOffset, faces[i][3] + offset,
                            faces[i][1] + xOffset + sun.mid[1] * 10000, faces[i][2] + yOffset + sun.mid[2] * 10000, faces[i][3] + sun.mid[3] * 10000
                        ).isBlock then
                        local negX = (x - 1) / resolution - 0.5
                        local posX = x / resolution - 0.5
                        local negY = (y - 1) / resolution - 0.5
                        local posY = y / resolution - 0.5
                        table.insert(shadowQuads, {
                            { faces[i][1] + negX - o, faces[i][2] + posY + o, faces[i][3] + offset },
                            { faces[i][1] + posX + o, faces[i][2] + posY + o, faces[i][3] + offset },
                            { faces[i][1] + posX + o, faces[i][2] + negY - o, faces[i][3] + offset },
                            { faces[i][1] + negX - o, faces[i][2] + negY - o, faces[i][3] + offset },
                        })
                    end
                end
            end
        end
    end

    return shadowQuads
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

-- TODO have the coroutine do one full box first, then send the ones to get the exposed faces and shadow quads once one is done

-- !make (oak) leaves not be invisible to shadows
-- !make fences invisible to shadows

-- check if each corner of the sun is visible and dim lens flare accordingly
-- godrays: rays in all directions originating from where the light source is, but only show when the sun's being partially blocked
