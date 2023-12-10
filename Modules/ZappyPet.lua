name = "Zappy Pet"
description = "A pet that follows you around and does nothing."

olimode = client.settings.addNamelessBool("Oli Mode", false)
importLib("logger.lua")
importLib("vectors.lua")
function cube(x, y, z, s)
    gfx.quad(x, y, z, x + s, y, z, x + s, y + s, z, x, y + s, z, true)
    gfx.quad(x, y, z + s, x + s, y, z + s, x + s, y + s, z + s, x, y + s, z + s, true)
    gfx.quad(x, y, z, x, y, z + s, x, y + s, z + s, x, y + s, z, true)
    gfx.quad(x + s, y, z, x + s, y, z + s, x + s, y + s, z + s, x + s, y + s, z, true)
    gfx.quad(x, y, z, x + s, y, z, x + s, y, z + s, x, y, z + s, true)
    gfx.quad(x, y + s, z, x + s, y + s, z, x + s, y + s, z + s, x, y + s, z + s, true)
end

function postInit()
    targetPosition = {}
    targetPosition.x, targetPosition.y, targetPosition.z = player.pposition()
    lastPosition = {}
    lastPosition.x, lastPosition.y, lastPosition.z = player.pposition()
    positionSpeed = 1
    zappyObj = gfx.objLoad("Zappy/zappy.obj")
    targetRotation = 0
    -- lastRotation = 0
    lastYaw = 0
    lastPitch = 0
    rotationSpeed = 100
    easingFactor = 0.98
end

local reachedTarget = false
local movedMoreThan4Blocks = false
local reachedTargetRotation = false

function render3d(dt)
    local x, y, z = player.pposition()

    local deltaX = (x - lastPosition.x)
    local deltaY = (y - lastPosition.y)
    local deltaZ = (z - lastPosition.z)

    local distanceMoved = math.sqrt(deltaX ^ 2 + deltaY ^ 2 + deltaZ ^ 2)

    if distanceMoved > 4 then
        movedMoreThan4Blocks = true
    else
        movedMoreThan4Blocks = false
    end

    if reachedTarget and movedMoreThan4Blocks then
        local offsetX = math.random(-5, 5)
        local offsetY = 0 --math.random(-1, 1)
        local offsetZ = math.random(-5, 5)

        targetPosition.x = x + offsetX
        targetPosition.y = y + offsetY
        targetPosition.z = z + offsetZ

        reachedTarget = false
    end

    lastPosition.x = lastPosition.x + (targetPosition.x - lastPosition.x) * positionSpeed * dt
    lastPosition.y = lastPosition.y + (targetPosition.y - lastPosition.y) * positionSpeed * dt
    lastPosition.z = lastPosition.z + (targetPosition.z - lastPosition.z) * positionSpeed * dt

    local distX = math.abs(targetPosition.x - lastPosition.x)
    local distY = math.abs(targetPosition.y - lastPosition.y)
    local distZ = math.abs(targetPosition.z - lastPosition.z)

    if distX < 0.1 and distY < 0.1 and distZ < 0.1 then
        reachedTarget = true
    end
    local targetPositionVec = vec:new(targetPosition.x, targetPosition.y, targetPosition.z)
    local lastPositionVec = vec:new(lastPosition.x, lastPosition.y, lastPosition.z)
    -- targetRotation = math.atan(targetPosition.x - lastPosition.x, targetPosition.z - lastPosition.z)
    local targetRotation = targetPositionVec:angleBetween(lastPositionVec)
    local targetYaw = math.deg(targetRotation[1])
    local targetPitch = math.deg(targetRotation[2])
    -- local angleDifference = targetRotation - lastRotation
    local yawDifference = targetYaw - lastYaw
    local pitchDifference = targetPitch - lastPitch
    -- local deltaAngle = math.atan(math.sin(math.rad(angleDifference)), math.cos(math.rad(angleDifference)))
    -- local rotationFactor = 1 + math.abs(deltaY)
    local rotationFactor = 1
    local easing = 1 - (1 - easingFactor) ^ dt
    -- lastRotation = lastRotation + angleDifference * easing * rotationFactor
    lastYaw = lastYaw + yawDifference * easing * rotationFactor
    lastPitch = lastPitch + pitchDifference * easing * rotationFactor
    -- if math.abs(targetRotation - lastRotation) < 0.1 then
    --     reachedTargetRotation = true
    -- else
    --     reachedTargetRotation = false
    -- endX

    local testRot = math.atan(x - lastPosition.x, z - lastPositionVec.z)

    log(testRot)
    gfx.pushTransformation({ 4, 0.5, 0.5, 0.5 }, { 3, math.rad(testRot), 0, 0, 1 },
        { 2, lastPosition.x, lastPosition.y, lastPosition.z })
    gfx.objRender(zappyObj, olimode.value and "Zappy/oli.png" or "Zappy/zappy.png")
    gfx.popTransformation()
end
