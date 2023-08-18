-- Made by O2Flash20 🙂

name = "Animated Skin"
description = "yes"

importLib("logger")
importLib("vectors")

time = 0
i = 0
skinImg = nil
skinUVs = nil
inputSkin = nil
function postInit()
    skinImg = gfx2.createImage(64, 64)
    skinUVs = gfx2.loadImage("skinUVs.png")
    inputSkin = gfx2.loadImage("mySkin.png")
end

function update()
    px, py, pz = player.position()
    i = i + 1
    if i % 2 > 0 then return end

    -- if not skinImg then return end

    -- for i = 0, 200 do
    --     coroutine.resume(updateSkin)
    -- end

    for i = 1, 64 do
        for j = 1, 64 do
            local uv = skinUVs:getPixel(i, j)
            local inSkin = inputSkin:getPixel(i, j)
            local noiseAmount = math.sin((1 / 10) * (uv.r - time * 20)) ^ 30
            local r = inSkin.r + pseudoRandom(i * j + 10 + time) * noiseAmount * 100
            local g = inSkin.g + pseudoRandom(i * j + time) * noiseAmount * 100
            local b = inSkin.b + pseudoRandom(i * j + 200 + time) * noiseAmount * 100
            local a = inSkin.a
            skinImg:setPixel(i, j, math.floor(r), math.floor(g), math.floor(b), math.floor(a))
        end
    end
    player.skin().setSkin(skinImg)
end

updateSkin = coroutine.create(function()
    ::start::
    local thisTime = time
    for i = 1, 64 do
        for j = 1, 64 do
            local r = 255 * valueNoise3d(i / 5, j / 5, thisTime)
            local g = 255 * valueNoise3d(i / 5, j / 5, thisTime + 1345)
            local b = 255 * valueNoise3d(i / 5, j / 5, thisTime + 834349)
            local a = 255

            skinImg:setPixel(i, j, math.floor(r), math.floor(g), math.floor(b), math.floor(a))
            coroutine.yield()
        end
    end
    player.skin().setSkin(skinImg)
    goto start
end)

function render(dt)
    time = time + dt
end

function sinFBM(x, detail)
    local output = 0
    for i = 0, detail do
        local thisScale = 1 / (2 * 2 ^ detail)
        local sinFunc = thisScale * math.sin((1 / thisScale) * x)
        output = output + sinFunc
    end
    return output
end

-----------
function mix(val1, val2, factor)
    return val1 * (1 - factor) + val2 * factor
end

function fract(x)
    return x - math.floor(x)
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

-- *alpha < 26: invisible
