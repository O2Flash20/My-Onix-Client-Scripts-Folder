name = "Ray Tracing Test"
description = "how bad can it possibly be"

importLib("logger")
importLib("vectors")

ResolutionW = 1920
ResolutionH = math.ceil(ResolutionW * (9 / 16))

gameFov = 80.40

verticalFov = math.rad(gameFov)
fov = 2 * math.atan((16 / 9) * (math.tan(verticalFov / 2)))

squareSpacing = 640 / ResolutionW

testBtn = client.settings.addNamelessKeybind("test button", 0x22)

currentlyRayTracing = false
event.listen("KeyboardInput", function(key, down)
    if key == testBtn.value and down then
        raytraceScene()
    end
end)


outputBuffer = {}

time = 0
function render2(dt)
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

                local isWater = col[4]
                gfx2.color(255, 255, 255, isWater * 255)
                gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing, squareSpacing)

                -- if col[1] == 1 then
                -- else
                --     gfx2.color(120, 220, 255, (col[1] ^ 2 / 1.2) * 255)
                --     gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing, squareSpacing)
                -- end

                -- gfx2.blur(x * squareSpacing, y * squareSpacing, squareSpacing, squareSpacing, col[5] / 75)

                -- gfx2.color(255, 255, 255, col[6])
                -- gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing + 0.1, squareSpacing + 0.1)

                -- gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing + 0.1, squareSpacing + 0.1)
            end
        end
    end


    ---- 3d fbm demo
    -- time = time + dt
    -- for i = 1, 20, 1 do
    --     for j = 1, 20, 1 do
    --         local val = contrast(fbmNoise3d(i, j, time * 2), 0.75) * 255
    --         gfx2.color(val, val, val)
    --         gfx2.fillRect(i * 10, j * 10, 10, 10)
    --     end
    -- end

    -- for i = 1, 20, 1 do
    --     for j = 1, 20, 1 do
    --         local normal = fbmNoiseNormal2d(i, j):mult(255)
    --         gfx2.color(normal.x, normal.y, 0)
    --         gfx2.fillRect(i * 10, j * 10, 10, 10)
    --     end
    -- end
end

-- function update()
--     raytraceScene()
-- end

-- function render3d()
--     local playerToOrigin = vec:new(-px, -py, -pz)
--     local reflected = reflectVector3d(playerToOrigin, vec:new(1, 1, 0))
--     gfx.line(px, py, pz, 0, 0, 0)
--     gfx.line(0, 0, 0, reflected.x, reflected.y, reflected.z)
-- end

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
            -- *maybe use ridge noise? maybe go back to using normals?

            -- local waterNormal = fbmNoiseNormal2d(hitW.x, hitW.z)
            -- local reflected = reflectVector3d(worldDir, waterNormal)
            -- local reflected = reflectVector3d(worldDir, vec:new(0, 1, 0))

            -- local dot = vec:new(worldDir.x, -worldDir.y, worldDir.z):dot(sunDir)
            -- -- local dot = reflected:dot(sunDir)
            -- if dot > 0.7 then
            --     table.insert(output, dot)
            -- else
            --     table.insert(output, 0)
            -- end

            table.insert(
                output,
                (vec:new(worldDir.x, -worldDir.y, worldDir.z):dot(sunDir) ^ 20) *
                contrast(fbmNoise2d(hitW.px * 5, hitW.pz * 5), 0.7)
            )

            -- table.insert(output, contrast(reflected:dot(sunDir) ^ 5, 0.7))
        else
            table.insert(output, 0)
        end
    else
        table.insert(output, 0)
    end

    --DEPTH OF FIELD BLUR MASK-- [5]
    local focalDistance = 100
    table.insert(output, math.abs(output[1] * dist - focalDistance))

    --CLOUD MAP-- [6]
    local cloudPlaneY = 200
    local distToCloudPlane = cloudPlaneY - py
    if not hitW.isBlock or math.abs(hitW.y - py) > math.abs(cloudPlaneY - py) then -- hit the cloud plane
        if distToCloudPlane * worldDir.y < 0 then                                  -- ray is not facing the sky, end here
            table.insert(output, 0)
        else
            local cloudPlaneXHit = px + (worldDir.x * (distToCloudPlane / worldDir.y))
            local cloudPlaneZHit = pz + (worldDir.z * (distToCloudPlane / worldDir.y))

            table.insert(output,
                contrast(fbmNoise2d(cloudPlaneXHit / 20, cloudPlaneZHit / 20), 0.8) *
                fbmNoise2d(cloudPlaneXHit / 2, cloudPlaneZHit / 4) * 255
            )
        end
    else
        table.insert(output, 0)
    end

    return output
end

function raytraceScene()
    outputBuffer = {}
    for x = 0, ResolutionW - 1, 1 do
        table.insert(outputBuffer, {})
        for y = 0, ResolutionH - 1, 1 do
            table.insert(outputBuffer[x + 1], raytracePixel(x, y))
        end
    end
end

function getSunDirection()
    local time = -dimension.time() * 2 * math.pi
    return vec:new(math.sin(time), math.cos(time), 0)
end

function mapRange(value, inMin, inMax, outMin, outMax)
    return (outMax - outMin) * (value - inMin) / (inMax - inMin) + outMin
end

function fract(x)
    return x - math.floor(x)
end

function mix(val1, val2, factor)
    return val1 * (1 - factor) + val2 * factor
end

-- might not need
function reflectVector3d(vec, normal)
    normal:normalize()
    local dot = vec:dot(normal)

    return vec:copy():sub(normal:mult(2 * dot))
end

-- takes a number from 0-1, contrast is (0-1), 1 being black and white, 0 being all gray
function contrast(x, contrast)
    local n = -1.2 * math.log(contrast, 0.2) + 0.5

    return (0.5 / (0.5 - n)) * x - (0.5 * n) / (0.5 - n)
end

function pseudoRandom(x)
    function f(a)
        return 50.343 * fract(x * 0.3180 + 0.113)
    end

    return fract(f(x) ^ 2 * fract((f(x) * f(f(x)))))
end

function pseudoRandom2d(x, y)
    return pseudoRandom((pseudoRandom(x) + pseudoRandom(pseudoRandom(y))) / 2)
end

function pseudoRandom3d(x, y, z)
    return pseudoRandom(
        (
            pseudoRandom(x) + pseudoRandom(pseudoRandom(y)) + pseudoRandom(pseudoRandom(pseudoRandom(z)))
        ) / 3
    )
end

function valueNoise2d(x, y)
    local i = vec:new(math.floor(x), math.floor(y))
    local f = vec:new(fract(x), fract(y))
    -- local u = f:mult(f):mult(f:mult(-2):add(vec:new(3, 3))) --! this might be better, but it's broken
    local u = f

    return mix(
        mix(pseudoRandom2d(i.x + 0, i.y + 0), pseudoRandom2d(i.x + 1, i.y + 0), u.x),
        mix(pseudoRandom2d(i.x + 0, i.y + 1), pseudoRandom2d(i.x + 1, i.y + 1), u.x),
        u.y
    )
end

function valueNoise3d(x, y, z)
    local i = vec:new(math.floor(x), math.floor(y), math.floor(z))
    local f = vec:new(fract(x), fract(y), fract(z))
    local u = f

    return mix(
        mix(
            mix(pseudoRandom3d(i.x + 0, i.y + 0, i.z), pseudoRandom3d(i.x + 1, i.y + 0, i.z), u.x),
            mix(pseudoRandom3d(i.x + 0, i.y + 1, i.z), pseudoRandom3d(i.x + 1, i.y + 1, i.z), u.x),
            u.y
        ),
        mix(
            mix(pseudoRandom3d(i.x + 0, i.y + 0, i.z + 1), pseudoRandom3d(i.x + 1, i.y + 0, i.z + 1), u.x),
            mix(pseudoRandom3d(i.x + 0, i.y + 1, i.z + 1), pseudoRandom3d(i.x + 1, i.y + 1, i.z + 1), u.x),
            u.y
        ),
        u.z
    )
end

function fbmNoise2d(x, y)
    return (0.5 * valueNoise2d(x / 8, y / 8) + 0.25 * valueNoise2d(x / 4, y / 4) + 0.125 * valueNoise2d(x / 2, y / 2) + 0.0625 * valueNoise2d(x, y))
end

function fbmNoise3d(x, y, z)
    return (
        0.5 * valueNoise3d(x / 8, y / 8, z / 8) +
        0.25 * valueNoise3d(x / 4, y / 4, z / 4) +
        0.125 * valueNoise3d(x / 2, y / 2, z / 2) +
        0.0625 * valueNoise3d(x, y, z)
    )
end

-- might not need
function fbmNoiseNormal2d(x, y)
    local dx = (fbmNoise2d(x + 0.1, y) - fbmNoise2d(x - 0.1, y)) / 2
    local dy = (fbmNoise2d(x, y + 0.1) - fbmNoise2d(x, y - 0.1)) / 2

    return vec:new(-dx, -dy, 1):normalize()
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
