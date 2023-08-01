name = "Ray Tracing Test"
description = "how bad can it possibly be"

importLib("vectors")
importLib("blockToTexture")

_depth = false
_normal = false
_sunShadows = false
_waterReflections = false
_dof = false
_clouds = false
_waterShine = false
_waterShadows = false
_textures = false
_realWater = false

ResolutionW = 500
ResolutionH = math.ceil(ResolutionW * (9 / 16))

gameFov = 100.40

traceBtn = client.settings.addNamelessKeybind("Raytrace Scene Button", 0x22)

client.settings.addInt("Horizontal Resolution", "ResolutionW", 0, 2160)

client.settings.addFloat("Game FOV", "gameFov", 30, 110)

client.settings.addBool("Real Water Optics", "_realWater")
client.settings.addBool("Sun Shadows", "_sunShadows")
client.settings.addBool("Volumetric Clouds", "_clouds")
client.settings.addBool("Depth of Field", "_dof")
client.settings.addBool("Depth Fog", "_depth")
client.settings.addBool("Normal Direction Demo", "_normal")
client.settings.addBool("Textures Demo", "_textures")
client.settings.addBool("Water Reflections (old)", "_waterReflections")
client.settings.addBool("Water Shine (old)", "_waterShine")
client.settings.addBool("Water Shadows (old)", "_waterShadows")

client.settings.addTitle(
    "NOTES:\nMake sure to set Game FOV to your current fov.\nMade to be used in fullscreen mode, however it's more convenient to have it do the raytrace while in windowed.\nIt will freeze your game, but it (almost) always comes back after the raytrace is done.\nVolumetric Clouds takes a LONG time."
)

verticalFov = math.rad(gameFov)
fov = 2 * math.atan((16 / 9) * (math.tan(verticalFov / 2)))

squareSpacing = 640 / ResolutionW

event.listen("KeyboardInput", function(key, down)
    if key == traceBtn.value and down then
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
                local col = outputBuffer[x + 1][y + 1]

                -- *normals
                if _normal then
                    local facingDir = col[2]
                    local dirToCol = {}
                    dirToCol[-1] = { 0, 0, 0, 0 }
                    dirToCol[0] = { 0, 127, 0, 255 }
                    dirToCol[1] = { 0, 255, 0, 255 }
                    dirToCol[2] = { 0, 0, 127, 255 }
                    dirToCol[3] = { 0, 0, 255, 255 }
                    dirToCol[4] = { 127, 0, 0, 255 }
                    dirToCol[5] = { 255, 0, 0, 255 }
                    local thisColor = dirToCol[facingDir]
                    gfx2.color(thisColor[1], thisColor[2], thisColor[3], 100)
                end

                --*TEXTURES
                if _textures then
                    gfx2.color(col[9][1], col[9][2], col[9][3], 255)
                    gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing + 0.1, squareSpacing + 0.1)
                end

                -- *shadows
                if _sunShadows then
                    local shadowAmount = col[3]
                    gfx2.color(0, 0, 0, shadowAmount * 100)
                    gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing, squareSpacing)
                end

                -- *fog
                if _depth then
                    if col[1] == 1 then
                    else
                        gfx2.color(120, 220, 255, (col[1] ^ 2 / 1.2) * 1000)
                        gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing, squareSpacing)
                    end
                end

                -- *clouds
                if _clouds then
                    local a = col[6][1] * (255 / 0.7)
                    local b = 255 - (col[6][2] * (255 / 1.5))
                    gfx2.color(b, b, b, a)
                    gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing + 0.1, squareSpacing + 0.1)
                end

                -- *water reflections
                if _waterReflections then
                    gfx2.color(col[4][1], col[4][2], col[4][3], col[4][4])
                    gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing + 0.1, squareSpacing + 0.1)
                end

                -- *water shine
                if _waterShine then
                    gfx2.color(255, 255, 255, col[7] * 150)
                    gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing + 0.1, squareSpacing + 0.1)
                end

                --*water shadows
                if _waterShadows then
                    gfx2.color(0, 0, 0, col[8] * 80)
                    gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing + 0.1, squareSpacing + 0.1)
                end

                --*REFLECTION + REFRACTION
                if _realWater then
                    gfx2.color(
                        col[4][1] * col[10] + col[11][1] * (1 - col[10]),
                        col[4][2] * col[10] + col[11][2] * (1 - col[10]),
                        col[4][3] * col[10] + col[11][3] * (1 - col[10]),
                        col[4][4]
                    )
                    gfx2.fillRect(x * squareSpacing, y * squareSpacing, squareSpacing + 0.1, squareSpacing + 0.1)
                end

                -- *dof
                if _dof then
                    gfx2.blur(x * squareSpacing, y * squareSpacing, squareSpacing, squareSpacing, col[5] / 250, 0)
                end
            end
        end
    end


    ---- 3d fbm demo
    -- time = time + dt
    -- for i = 1, 20, 1 do
    --     for j = 1, 20, 1 do
    --         local val = fbmNoise3d(i, j, time * 2)
    --         val = (-1 * math.abs(val * 2 - 1) + 0.1) * 10
    --         val = val * 255
    --         gfx2.color(val, val, val)
    --         gfx2.fillRect(i * 10, j * 10, 10, 10)
    --     end
    -- end

    if oldResolutionW ~= ResolutionW then
        ResolutionH = math.ceil(ResolutionW * (9 / 16))
        squareSpacing = 640 / ResolutionW
    end
    if oldGameFOV ~= gameFov then
        verticalFov = math.rad(gameFov)
        fov = 2 * math.atan((16 / 9) * (math.tan(verticalFov / 2)))
    end
    oldResolutionW = ResolutionW
    oldGameFOV = gameFov
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

    local output = {}

    local hit = dimension.raycast(px, py, pz, px + worldDir.x * dist, py + worldDir.y * dist, pz + worldDir.z * dist)
    local hitW = dimension.raycast(px, py, pz, px + worldDir.x * dist, py + worldDir.y * dist, pz + worldDir.z * dist,
        dist, false, false, true)
    local sunDir = getSunDirection()

    --DEPTH-- [1]
    if _depth or _dof then
        local distToCam = vec:new(hit.px, hit.py, hit.pz):dist(vec:new(px, py, pz))
        if hit.isBlock then
            output[1] = distToCam / dist
        else
            output[1] = 1
        end
    end

    --NORMAL (in the form of the block face number)-- [2]
    if _normal then
        if hit.isBlock then
            output[2] = hit.blockFace
        else
            output[2] = -1
        end
    end

    --SUN SHADOWS-- [3]
    if _sunShadows then
        if hit.isBlock then
            local shadowDist = 100
            local toSunRaycast = dimension.raycast(
                hit.px, hit.py, hit.pz,
                hit.px + sunDir.x * shadowDist, hit.py + sunDir.y * shadowDist, hit.pz + sunDir.z * shadowDist
            )
            if toSunRaycast.isBlock then
                output[3] = 1
            else
                output[3] = 0
            end
        else
            output[3] = 0
        end
    end

    --WATER REFLECTIONS-- [4]
    if _waterReflections or _waterShine or _realWater then
        if hitW.isBlock then
            if dimension.getBlock(hitW.x, hitW.y, hitW.z).name == "water" then
                local waterNormal = fbmNoiseNormal2d(hitW.px * 4, hitW.pz * 4, 1)
                local reflected = reflectVector3d(vec:new(worldDir.x, worldDir.y, worldDir.z), waterNormal)
                local reflectedHit = dimension.raycast(
                    hitW.px, hitW.py, hitW.pz,
                    hitW.px + reflected.x * dist,
                    hitW.py + reflected.y * dist,
                    hitW.pz + reflected.z * dist
                )
                if reflectedHit.isBlock then
                    local color = getColorFromCoord(reflectedHit.px, reflectedHit.py, reflectedHit.pz, reflectedHit.x,
                        reflectedHit.y, reflectedHit.z, reflectedHit.blockFace)
                    output[4] = { color[1], color[2], color[3], 255 }
                else
                    output[4] = { 111, 165, 252, 255 }
                end
            else
                output[4] = { 0, 0, 0, 0 }
            end
        else
            output[4] = { 0, 0, 0, 0 }
        end
    end

    --DEPTH OF FIELD BLUR MASK-- [5]
    if _dof then
        local focalDistance = 300
        output[5] = math.abs(output[1] * dist - focalDistance)
    end

    --CLOUD MAP-- [6]
    if _clouds then
        local cloudBottomBound = 200
        local cloudTopBound = 350

        if (py < cloudBottomBound and worldDir.y < 0) or (py > cloudTopBound and worldDir.y > 0) then
            output[6] = { 0, 0 }
        else
            local cloudRay
            if py < cloudTopBound and py > cloudBottomBound then
                cloudRay = vec:new(px, py, pz)
            elseif py < cloudBottomBound then
                local xStart = ((cloudBottomBound - py) / worldDir.y) * worldDir.x + px
                local zStart = ((cloudBottomBound - py) / worldDir.y) * worldDir.z + pz
                cloudRay = vec:new(xStart, cloudBottomBound, zStart)
            elseif py > cloudTopBound then
                local xStart = ((cloudTopBound - py) / worldDir.y) * worldDir.x + px
                local zStart = ((cloudTopBound - py) / worldDir.y) * worldDir.z + pz
                cloudRay = vec:new(xStart, cloudTopBound, zStart)
            end

            local density = 0
            local darkening = 0
            local worldDirMult = vec:new(worldDir.x, worldDir.y, worldDir.z):mult(16)

            local numSteps = 25
            for i = 1, numSteps, 1 do
                if cloudRay.y > cloudTopBound + 1 or cloudRay.y < cloudBottomBound - 1 then break end
                local thisDensity = factorRamp(cloudRay.y,
                        {
                            { cloudBottomBound,   0 }, { cloudBottomBound + 10, 1 },
                            { cloudTopBound - 10, 1 }, { cloudTopBound, 0 }
                        })
                    * contrast(fbmNoise3d(cloudRay.x / 10, cloudRay.y / 10, cloudRay.z / 10), 0.9)
                density = density + thisDensity

                darkening = darkening + thisDensity * mapRange(cloudRay.y, cloudBottomBound, cloudTopBound, 1, 0)

                cloudRay:add(worldDirMult)
            end
            output[6] = { density / numSteps, darkening / numSteps }
        end
    end

    --WATER SHINE-- [7]
    if _waterShine then
        if hitW.isBlock then
            if dimension.getBlock(hitW.x, hitW.y, hitW.z).name == "water" and output[4][4] == 0 then --hit water and reflects into the sky
                local waterNormal = fbmNoiseNormal2d(hitW.px * 4, hitW.pz * 4, 1)
                local reflected = reflectVector3d(worldDir:copy(), waterNormal)
                reflected:setComponent("y", -reflected.y)

                output[7] = factorRamp(reflected:normalize():dot(sunDir), { { 0, 0 }, { 0.994, 0 },
                    { 1, 1 } })
            else
                output[7] = 0
            end
        else
            output[7] = 0
        end
    end

    --WATER SHADOWS-- [8]
    if _waterShadows then
        if hitW.isBlock then
            if dimension.getBlock(hitW.x, hitW.y, hitW.z).name == "water" then
                local waterNormal = fbmNoiseNormal2d(hitW.px * 4, hitW.pz * 4, 0.2)
                local reflected = reflectVector3d(worldDir:copy(), waterNormal)
                reflected:setComponent("y", -reflected.y)

                local dot = worldDir.x * reflected.x + worldDir.y * reflected.y + worldDir.z * reflected.z

                output[8] = math.min((1 - dot) * 5, 1)
            else
                output[8] = 0
            end
        else
            output[8] = 0
        end
    end

    --TEXTURES-- [9]
    if _textures then
        if hit.isBlock then
            output[9] = getColorFromCoord(hit.px, hit.py, hit.pz, hit.x, hit.y, hit.z, hit.blockFace)
        else
            output[9] = { 100, 100, 255 }
        end
    end

    --REFLECTANCE-- [10]
    if _realWater then
        if hitW.isBlock then
            if dimension.getBlock(hitW.x, hitW.y, hitW.z).name == "water" then
                output[10] = reflectance(worldDir, fbmNoiseNormal2d(hitW.px * 4, hitW.pz * 4, 1), 1, 1.33)
            else
                output[10] = 0
            end
        else
            output[10] = 0
        end
    end

    --REFRACTIONS-- [11]
    if _realWater then
        if hitW.isBlock then
            if dimension.getBlock(hitW.x, hitW.y, hitW.z).name == "water" then
                local refractedVec = refractVector(worldDir, fbmNoiseNormal2d(hitW.px * 4, hitW.pz * 4, 1), 1, 1.33)
                if refractedVec == nil then
                    output[11] = { 0, 0, 0 }
                else
                    --actually refracted
                    local refractDist = 300
                    local refractHit = dimension.raycast(
                        hitW.px, hitW.py, hitW.pz,
                        hitW.px + refractedVec.x * refractDist,
                        hitW.py + refractedVec.y * refractDist,
                        hitW.pz + refractedVec.z * refractDist
                    )

                    if refractHit.isBlock then
                        local hitColor = getColorFromCoord(
                            refractHit.px, refractHit.py, refractHit.pz,
                            refractHit.x, refractHit.y, refractHit.z,
                            refractHit.blockFace
                        )

                        local distThroughWater = vec:new(hitW.px, hitW.py, hitW.pz)
                            :dist(vec:new(refractHit.px, refractHit.py, refractHit.pz))
                        local waterColMixAmount = math.clamp(0.0009 * distThroughWater ^ 2, 0, 0.8)
                        local waterColor = dimension.getBiomeColor(hitW.x, hitW.y, hitW.z).water

                        -- *check if under the sky
                        local causticBrightness = fbmNoise2d(refractHit.px * 8, refractHit.pz * 8)
                        causticBrightness = 40 * (-1 * math.abs(2 * causticBrightness - 1) + 0.025)
                        causticBrightness = math.clamp(causticBrightness, 0, 1) * 100

                        local face = refractHit.blockFace
                        local faceShadow
                        if face == 0 or face == 1 then
                            faceShadow = 0.95
                        end
                        if face == 2 or face == 3 then
                            faceShadow = 0.65
                        end
                        if face == 4 or face == 5 then
                            faceShadow = 0.8
                        end

                        hitColor[1] = (1 - waterColMixAmount) * (hitColor[1] * faceShadow + causticBrightness) +
                            waterColMixAmount * waterColor.r * 255
                        hitColor[2] = (1 - waterColMixAmount) * (hitColor[2] * faceShadow + causticBrightness) +
                            waterColMixAmount * waterColor.g * 255
                        hitColor[3] = (1 - waterColMixAmount) * (hitColor[3] * faceShadow + causticBrightness) +
                            waterColMixAmount * waterColor.b * 255
                        output[11] = hitColor
                    else
                        output[11] = { 0, 0, 0 }
                    end
                end
            else
                output[11] = { 0, 0, 0 }
            end
        else
            output[11] = { 0, 0, 0 }
        end
    end

    return output
end

function getColorFromCoord(x, y, z, xint, yint, zint, face)
    local blockFract = vec:new(fract(x), 1 - fract(y), fract(z))
    local uv = vec:new(0, 0)
    if face == 0 or face == 1 then
        uv.u = blockFract.x
        uv.v = blockFract.z
    end
    if face == 2 or face == 3 then
        uv.u = blockFract.x
        uv.v = blockFract.y
    end
    if face == 4 or face == 5 then
        uv.u = blockFract.z
        uv.v = blockFract.y
    end

    local texture = btt.getTexture(xint, yint, zint, face)
    if texture then
        local img
        if fs.exist(texture .. ".png") then
            img = gfx2.loadImage(texture .. ".png")
        elseif fs.exist(texture .. ".tga") then
            img = gfx2.loadImage(texture .. ".tga")
        else
            img = gfx2.loadImage("textures/blocks/dirt.png")
        end
        if img then
            local color = img:getPixel(math.floor(uv.u * 16) + 1, math.floor(uv.v * 16) + 1)
            img:unload()
            return { color.r, color.g, color.b }
        end
    else
        return { 255, 0, 0 }
    end
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

-- {x, y}
function factorRamp(x, points)
    for i = 1, #points do
        if x < points[1][1] then return points[1][2] end
        if x > points[#points][1] then return points[#points][2] end
        if x >= points[i][1] and x < points[i + 1][1] then
            return mapRange(x, points[i][1], points[i + 1][1], points[i][2], points[i + 1][2])
        end
    end
end

-- might not need
function reflectVector3d(incident, normal)
    normal:normalize()
    local dot = incident:dot(normal)

    return incident:copy():sub(normal:mult(2 * dot))
end

-- https://graphics.stanford.edu/courses/cs148-10-summer/docs/2006--degreve--reflection_refraction.pdf
-- n1: the one you're in, n2: the one you're going into
function refractVector(incident, normal, n1, n2)
    local Normal = vec:new(normal.x, normal.y, normal.z)
    local Incident = vec:new(incident.x, incident.y, incident.z)

    local n = n1 / n2
    local cosI = -Normal:dot(Incident)
    local sinT2 = n * n * (1 - cosI * cosI)

    if sinT2 > 1 then return nil end --total internal reflection

    local cosT = math.sqrt(1 - sinT2)
    return Incident:mult(n):add(Normal:mult(n * cosI - cosT))
end

-- 1: all reflection, 0: add refraction
function reflectance(incident, normal, n1, n2)
    local n = n1 / n2
    local cosI = -normal:dot(incident)
    local sinT2 = n * n * (1 - cosI * cosI)
    if sinT2 > 1 then return 1 end --total internal reflection
    local cosT = math.sqrt(1 - sinT2)
    local rOrthogonal = (n1 * cosI - n2 * cosT) / (n1 * cosI + n2 * cosT)
    local rParallel = (n2 * cosI - n1 * cosT) / (n2 * cosI + n1 * cosT)
    return math.clamp((rOrthogonal * rOrthogonal + rParallel * rParallel) / 2, 0, 1)
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
function fbmNoiseNormal2d(x, y, strength)
    local dx = (fbmNoise2d(x + 1, y) - fbmNoise2d(x - 1, y)) / 2
    local dy = (fbmNoise2d(x, y + 1) - fbmNoise2d(x, y - 1)) / 2

    return vec:new(-dx, strength, -dy):normalize()
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
--   five+ differnent sun directions, shadows are added together
-- torch shadows
-- iron mirror reflections
-- sun color with depending on time with water reflection
-- normal maps on all blocks
-- distort fbm by shifting pixels by other fbm
