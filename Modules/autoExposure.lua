name = "Auto Exposure"
description = "Lightens your screen when you're looking at something dark."

importLib("renderThreeD")
importLib("vectors")
importLib("logger")

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
end

nextBrightness = nil
nextContrast = nil
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
    timeSinceUpdate = timeSinceUpdate + dt
    brightnessSetting.value = map(timeSinceUpdate, 0, 0.11 * changeSlowness, thisBrightness, nextBrightness)
    contrastSetting.value = map(timeSinceUpdate, 0, 0.11 * changeSlowness, thisContrast, nextContrast)

    local sunDir = getSunDir()
    local midX, midY = gfx.worldToScreen(sunDir[1] * 1000000000, sunDir[2] * 1000000000, 0)
    -- local bottomLeftX, bottomLeftY = gfx.worldToScreen((sunDir[1] + 0.15) * 1000000000, sunDir[2] * 1000000000,
    --     0.08 * 1000000000)
    local sunCoords = getSunCoords()
    local trX, trY = gfx.worldToScreen(
        sunCoords.topRight[1] * 1000000000,
        sunCoords.topRight[2] * 1000000000,
        sunCoords.topRight[3] * 1000000000
    )
    local tlX, tlY = gfx.worldToScreen(
        sunCoords.topLeft[1] * 1000000000,
        sunCoords.topLeft[2] * 1000000000,
        sunCoords.topLeft[3] * 1000000000
    )
    local brX, brY = gfx.worldToScreen(
        sunCoords.bottomRight[1] * 1000000000,
        sunCoords.bottomRight[2] * 1000000000,
        sunCoords.bottomRight[3] * 1000000000
    )
    local blX, blY = gfx.worldToScreen(
        sunCoords.bottomLeft[1] * 1000000000,
        sunCoords.bottomLeft[2] * 1000000000,
        sunCoords.bottomLeft[3] * 1000000000
    )

    local w = gui.width()
    local h = gui.height()
    if midX and midY then
        gfx.color(255, 255, 255, 100)

        gfx.quad(
            -tlX + w, -tlY + h,
            -trX + w, -trY + h,
            -brX + w, -brY + h,
            -blX + w, -blY + h
        )

        gfx.quad(
            (tlX - w / 2) / 2 + w / 2, (tlY - h / 2) / 2 + h / 2,
            (trX - w / 2) / 2 + w / 2, (trY - h / 2) / 2 + h / 2,
            (brX - w / 2) / 2 + w / 2, (brY - h / 2) / 2 + h / 2,
            (blX - w / 2) / 2 + w / 2, (blY - h / 2) / 2 + h / 2
        )

        gfx.quad(
            -(tlX - w / 2) * 3 + w / 2, -(tlY - h / 2) * 3 + h / 2,
            -(trX - w / 2) * 3 + w / 2, -(trY - h / 2) * 3 + h / 2,
            -(brX - w / 2) * 3 + w / 2, -(brY - h / 2) * 3 + h / 2,
            -(blX - w / 2) * 3 + w / 2, -(blY - h / 2) * 3 + h / 2
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
