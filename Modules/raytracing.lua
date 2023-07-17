name = "Ray Tracing Test"
description = "how bad can it possibly be"

importLib("logger")
importLib("vectors")

ResolutionW = 1920
ResolutionH = math.ceil(ResolutionW * (9 / 16))

gameFov = 46.80

verticalFov = math.rad(gameFov)
fov = 2 * math.atan((16 / 9) * (math.tan(verticalFov / 2)))

squareSpacing = 640 / ResolutionW

testBtn = client.settings.addNamelessKeybind("test button", 0x22)

currentlyRayTracing = false
event.listen("KeyboardInput", function(key, down)
    if key == testBtn.value and down then
        raytraceScene()
        -- coroutine.resume(rayTraceScene) --*
        -- currentlyRayTracing = true --*
    end
end)


outputBuffer = {}


function render2()
    px, py, pz = player.pposition()
    pyaw, ppitch = player.rotation()

    if #outputBuffer > 0 then
        for x = 0, ResolutionW - 1, 1 do
            for y = 0, ResolutionH - 1, 1 do
                -- for x = 0, #outputBuffer - 1 do --*
                --     for y = 0, #outputBuffer[#outputBuffer] - 1 do --*
                local col = outputBuffer[x + 1][y + 1]

                -- gfx2.color(0, 255, 255, col[1])

                -- local facingDir = col[2]
                -- local dirToCol = {}
                -- dirToCol[-1] = { 0, 0, 0, 0 }
                -- dirToCol[0] = { 0, 127, 0, 255 }
                -- dirToCol[1] = { 0, 255, 0, 255 }
                -- dirToCol[2] = { 0, 0, 127, 255 }
                -- dirToCol[3] = { 0, 0, 255, 255 }
                -- dirToCol[4] = { 127, 0, 0, 255 }
                -- dirToCol[5] = { 255, 0, 0, 255 }
                -- local thisColor = dirToCol[facingDir]
                -- gfx2.color(thisColor[1], thisColor[2], thisColor[3], 100)

                -- local shadowAmount = col[3]
                -- gfx2.color(0, 0, 0, shadowAmount * 100)
                -- gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing, squareSpacing)

                -- local isWater = col[4]
                -- gfx2.color(255, 255, 255, isWater * 255)
                -- gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing, squareSpacing)

                -- if col[1] == 1 then
                -- else
                --     gfx2.color(120, 220, 255, (col[1] ^ 2 / 1.2) * 255)
                --     gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing, squareSpacing)
                -- end

                -- gfx2.color(col[5], 0, 0, 255)
                gfx2.blur(x * squareSpacing, y * squareSpacing, squareSpacing, squareSpacing, col[5] / 75)

                -- gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing + 0.1, squareSpacing + 0.1)
            end
        end
    end

    -- for i = 1, 100, 1 do
    --     for j = 1, 100, 1 do
    --         gfx2.blur(i, j, 1, 1, i / 100)
    --     end
    -- end

    -- gfx2.fillRect(0, 0, 640, 10)
end

-- function update() --*
--     if currentlyRayTracing then --*
--         for i = 1, ResolutionH, 1 do --*
--             coroutine.resume(rayTraceScene) --*
--         end --*
--     end --*
-- end --*

function screenPixelToDirection(x, y)
    local tanF2 = math.tan(fov / 2)
    local tanZ2 = math.tan(verticalFov / 2)

    local xCoord = mapRange(x, 0, ResolutionW - 1, -tanF2, tanF2)
    local yCoord = mapRange(y, 0, ResolutionH - 1, tanZ2, -tanZ2)

    return vec:new(xCoord, yCoord, 1)
end

function pixelDirToWorldDir(pixelDir)
    local newPitch = math.atan(pixelDir.y) - math.rad(ppitch)
    local ZandYMagnitude = math.sqrt(pixelDir.y ^ 2 + 1)

    pixelDir:setComponent("y", ZandYMagnitude * math.sin(newPitch))
    pixelDir:setComponent("z", ZandYMagnitude * math.cos(newPitch))

    local xzPlaneOfDir = vec:new(pixelDir.x, pixelDir.z):rotate(math.rad(-pyaw - 180))
    pixelDir:setComponent("x", xzPlaneOfDir.x)
    pixelDir:setComponent("z", -xzPlaneOfDir.y)

    pixelDir:normalize()

    return pixelDir
end

function raytracePixel(x, y)
    local worldDir = pixelDirToWorldDir(screenPixelToDirection(x, y)):normalize()
    local dist = 1000

    local output = {}

    local hit = dimension.raycast(px, py, pz, px + worldDir.x * dist, py + worldDir.y * dist, pz + worldDir.z * dist)
    local sunDir = getSunDirection()

    --DEPTH-- [1]
    local distToCam = vec:new(hit.px, hit.py, hit.pz):dist(vec:new(px, py, pz))
    if hit.isBlock then
        table.insert(output, distToCam / dist)
    else
        table.insert(output, 1)
    end

    --NORMAL (in the form of the block face number)-- [2]
    if hit.isBlock then
        table.insert(output, hit.blockFace)
    else
        table.insert(output, -1)
    end

    --SUN SHADOWS-- [3]
    if hit.isBlock then
        local shadowDist = 100
        local toSunRaycast = dimension.raycast(
            hit.px, hit.py, hit.pz,
            hit.px + sunDir.x * shadowDist, hit.py + sunDir.y * shadowDist, hit.pz + sunDir.z * shadowDist
        )
        if toSunRaycast.isBlock then
            table.insert(output, 1)
        else
            table.insert(output, 0)
        end
    else
        table.insert(output, 0)
    end

    --WATER MASK-- [4]
    local hitW = dimension.raycast(px, py, pz, px + worldDir.x * dist, py + worldDir.y * dist, pz + worldDir.z * dist,
        dist, false, false, true)
    if hitW.isBlock then
        if dimension.getBlock(hitW.x, hitW.y, hitW.z).name == "water" then
            -- *use facing direction instead of just -worldDir.y
            table.insert(output, vec:new(worldDir.x, -worldDir.y, worldDir.z):dot(sunDir) ^ 100)
        else
            table.insert(output, 0)
        end
    else
        table.insert(output, 0)
    end

    --DEPTH OF FIELD BLUR MASK-- [5]
    local focalDistance = 100
    table.insert(output, math.abs(output[1] * dist - focalDistance))

    return output
end

function raytraceScene() --a coroutine?
    outputBuffer = {}
    for x = 0, ResolutionW - 1, 1 do
        table.insert(outputBuffer, {})
        for y = 0, ResolutionH - 1, 1 do
            table.insert(outputBuffer[x + 1], raytracePixel(x, y))
        end
    end
end

rayTraceScene = coroutine.create(function(...) --*
    ::start::
    coroutine.yield()

    outputBuffer = {}
    for x = 0, ResolutionW - 1, 1 do
        table.insert(outputBuffer, {})
        for y = 0, ResolutionH - 1, 1 do
            table.insert(outputBuffer[x + 1], raytracePixel(x, y))
            coroutine.yield()
        end
    end

    currentlyRayTracing = false
    goto start
end)

function getSunDirection()
    local time = -dimension.time() * 2 * math.pi
    return vec:new(math.sin(time), math.cos(time), 0)
end

function mapRange(value, inMin, inMax, outMin, outMax)
    return (outMax - outMin) * (value - inMin) / (inMax - inMin) + outMin
end

--[[
    blockFace:
        0: -y / no block
        1: +y
        2: -z
        3: +z
        4: -x
        5: +x
]]

--? smooth shadows
-- water shine waves
-- volumetric clouds
-- torch shadows
-- depth of field
