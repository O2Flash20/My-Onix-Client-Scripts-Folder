name = "Ray Tracing Test"
description = "how bad can it possibly be"

importLib("logger")
importLib("vectors")

ResolutionW = 192
ResolutionH = math.ceil(ResolutionW * (9 / 16))

gameFov = 86

-- idk, seems about right
fov = math.rad(247.0858 + (8.55627 - 247.0858) / (1 + (gameFov / 97.78112) ^ 1.295414))
verticalFov = 2 * math.atan(math.tan(fov / 2), 16 / 9)

-- seems about right
squareSpacing = 643.2 / ResolutionW

testBtn = client.settings.addNamelessKeybind("test button", 0x22)

event.listen("KeyboardInput", function(key, down)
    if key == testBtn.value and down then
        raytraceScene()
        -- blurredBuffer = blurBuffer(outputBuffer, ResolutionW, ResolutionH, 480, 270)
    end
end)


outputBuffer = {}
-- blurredBuffer = {}


function render2()
    px, py, pz = player.pposition()
    pyaw, ppitch = player.rotation()

    if #outputBuffer > 0 then
        for x = 0, ResolutionW - 1, 1 do
            for y = 0, ResolutionH - 1, 1 do
                local col = outputBuffer[x + 1][y + 1]
                gfx2.color(0, 255, 255, col[1])

                gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing + 0.1, squareSpacing + 0.1)
            end
        end
    end

    -- if #blurredBuffer > 0 then
    --     for x = 0, 480, 1 do
    --         for y = 0, 270, 1 do
    --             local col = blurredBuffer[x + 1][y + 1]
    --             gfx2.color(0, 255, 255, col[1])

    --             gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing + 0.1, squareSpacing + 0.1)
    --         end
    --     end
    -- end
end

-- function render3d()
--     if #outputBuffer > 0 then
--         for x = 0, ResolutionW - 1, 1 do
--             for y = 0, ResolutionH - 1, 1 do
--                 local dir = pixelDirToWorldDir(screenPixelToDirection(x, y))
--                 gfx.line(px, py, pz, px + dir.x, py + dir.y, pz + dir.z)
--             end
--         end
--     end
-- end

function isLookingAtBlock(dirVec)
    local dist = 10
    local rayCast = dimension.raycast(px, py, pz, px + dirVec.x * dist, py + dirVec.y * dist, pz + dirVec.z * dist)
    return rayCast.isBlock
end

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

    local hit = dimension.raycast(px, py, pz, px + worldDir.x * dist, py + worldDir.y * dist, pz + worldDir.z * dist)
    local distToCam = vec:new(hit.px, hit.py, hit.pz):dist(vec:new(px, py, pz))
    if hit.isBlock then
        return { distToCam, distToCam, distToCam, 255 }
    else
        return { 255, 255, 255, 255 }
    end
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

-- ! kills performance even more
function blurBuffer(outputBuffer, inResX, inResY, outResX, outResY)
    local outScaling = outResX / inResX
    local maxDistanceToSamplePoints = 2 * outScaling + math.sqrt(2 * outScaling ^ 2)

    local output = {}

    for x = 0, outResX - 1, 1 do
        table.insert(output, {})
        for y = 0, outResY - 1, 1 do
            log("hi")
            local topLeftPoint = outputBuffer[math.floor(x / outScaling) + 1][math.floor(y / outScaling) + 1] or
                { 0, 0, 0, 0, 0 }
            local bottomLeftPoint = outputBuffer[math.floor(x / outScaling) + 1][math.ceil(y / outScaling) + 1] or
                { 0, 0, 0, 0, 0 }
            local topRightPoint = outputBuffer[math.ceil(x / outScaling) + 1][math.floor(y / outScaling) + 1] or
                { 0, 0, 0, 0, 0 }
            local bottomRightPoint = outputBuffer[math.ceil(x / outScaling) + 1][math.ceil(y / outScaling) + 1] or
                { 0, 0, 0, 0, 0 }

            local posWithinSquare = vec:new(x % outScaling / outScaling, y % outScaling / outScaling)
            local topLeftDist = posWithinSquare:dist(vec:new(0, 0))
            local bottomLeftDist = posWithinSquare:dist(vec:new(0, 1))
            local topRightDist = posWithinSquare:dist(vec:new(1, 0))
            local bottomRightDist = posWithinSquare:dist(vec:new(1, 1))

            local thisPoint = {}
            for i = 1, #topLeftPoint, 1 do
                table.insert(
                    thisPoint,
                    topLeftPoint[i] * (topLeftDist / maxDistanceToSamplePoints) +
                    bottomLeftPoint[i] * (bottomLeftDist / maxDistanceToSamplePoints) +
                    topRightPoint[i] * (topRightDist / maxDistanceToSamplePoints) +
                    bottomRightPoint[i] * (bottomRightDist / maxDistanceToSamplePoints)
                )
            end
            table.insert(output[x + 1], thisPoint)
        end
    end

    return output
end

function mapRange(value, inMin, inMax, outMin, outMax)
    return (outMax - outMin) * (value - inMin) / (inMax - inMin) + outMin
end

-- ? each pixel of outputBuffer has information like {normalX, normalY, normalZ, depth, etc?}
-- * possibly draw 1920x1080 pixels by box blurring the raytraced points
