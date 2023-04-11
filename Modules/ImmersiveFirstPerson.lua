-- Made By O2Flash20 🙂

name = "Immersive First Person"
description = "Look at yourself and see... yourself"

importLib("cosmeticTools")
importLib("vectors")
importLib("logger")

t = 0

offset = -0.2

lastPos = { 0, 0, 0 }

function render3d(dt)
    -- if player.perspective() ~= 0 then return end
    enableShading()
    updateCosmeticTools()
    updateCapes()

    t = t + dt
    -- log({ player.getFlag(3), player.getFlag(1), player.getFlag(38) })
    -- log({ lastPos[1] - px, lastPos[2] - py, lastPos[3] - pz })

    local moveThreshold = 0.05

    local a = 1
    if player.getFlag(3) then
        a = 2
    elseif player.getFlag(1) then
        a = 0.5
    elseif lastPos[1] == px and lastPos[2] == py and lastPos[3] == pz then
        a = 0
    end

    -- log(a)

    Body = Object:new(0, 0, offset)
        :attachToBody()

    Legs = Object:new(0, -0.38, offset)
        :attachToBody()

    Sphere:new(
        Legs,
        0, 0, 0,
        0.02
    )
        :render({ 255, 0, 0 })

    -- body
    Cube:new(
        Body,
        0, 0, 0,
        0.5, 0.75, 0.25
    )
        :render({ 255, 0, 0 })

    -- right leg
    Cube:new(
        Legs,
        0.12, -0.35, 0,
        0.25, 0.71, 0.25
    )
        :rotateObject(a * 0.5 * math.sin(10 * t), 0, 0)
        :render({ 255, 255, 0 })

    -- left leg
    Cube:new(
        Legs,
        -0.12, -0.35, 0,
        0.25, 0.71, 0.25
    )
        :rotateObject(a * -0.5 * math.sin(10 * t), 0, 0)
        :render({ 0, 255, 255 })

    lastPos = { px, py, pz }
end
