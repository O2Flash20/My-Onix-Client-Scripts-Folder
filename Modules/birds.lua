---@diagnostic disable: redundant-parameter
name = "Birds"
description = "Funny little bird guys :3 (what's wrong with me)"

importLib("logger")
importLib("vectors")
importLib("renderThreeD")

--[[
pick a spot near the player, out of view, and on the ground, then spawn a bird and pick 2 points for it to fly to
    when it's flying to it's last point, pick another point
        if it's a certain distance away from the player, it lands and then disapears when it is next not visible

visibility could just be checking direction and not occlusion

to find a new spot to fly to:
    pick a random 2d coordinate, height is some offset from map height
    raycast from pos right before to that pos, if there's a collision, pick a new point to go to

maybe have some birds that fly high in the sky in flocks and never take off or land
]]

MAXBIRDS = 20
TIMEPERKEYFRAME = 5
CLOSESTSPAWNDIST = 20
FURTHESTSPAWNDIST = 100
KEYFRAMESPACING = 40
FLYHEIGHT = 30
LANDDIST = 120

birds = {}

function update(dt)
    if #birds < MAXBIRDS then --pick a spot for a bird to spawn
        -- log("hi")
        local offset = vec:fromAngle(1, math.random() * math.pi * 2)
        offset:setMag(math.random(CLOSESTSPAWNDIST, FURTHESTSPAWNDIST))
        local spawnPos = vec:new(
            offset.x + px,
            dimension.getMapHeight(math.floor(offset.x + px), math.floor(offset.y + pz))+1.2,
            offset.y + pz
        )

        if not posIsVisible(spawnPos, pPos, 1) then
            table.insert(birds, { t, { spawnPos } })
        end
    end

    updateBirdsKeyframes()
end

function posIsVisible(pos, camPos, radius)
    local sx, sy = gfx.worldToScreen(pos.x, pos.y, pos.z)
    if not sx or not sy then return false end

    -- local pYaw, pPitch = player.rotation()
    local posTranslated = pos:copy():sub(camPos):rotateYaw(math.rad(pYaw)):rotatePitch(math.rad(-pPitch))

    local fovH, fovV = gfx.fov()
    local r = radius * gui.height() / (posTranslated.z * math.tan(math.rad(fovV / 2))) * 1

    return sx and sy and sx + r >= 0 and sx - r < gui.width() and sy + r >= 0 and sy - r < gui.height()
end

function updateBirdsKeyframes() --finds the birds new positions to go to if they need
    local birdsToRemove = {}
    for i = 1, #birds, 1 do
        local thisBird = birds[i]
        local thisBirdSpawnTime = thisBird[1]
        local thisBirdKeyframes = thisBird[2] --the spawn position counts as a keyframe

        local nextKeyframe = thisBirdKeyframes[#thisBirdKeyframes-2]

        if nextKeyframe and (nextKeyframe.x-px)^2 + (nextKeyframe.z-pz)^2 >= LANDDIST^2 and not posIsVisible(nextKeyframe, pPos, 1) then --far and not visible, remove it
            table.insert(birdsToRemove, i)

        else
            local timeSinceSpawn = t - thisBirdSpawnTime
            local currentKeyframe = math.ceil(timeSinceSpawn / TIMEPERKEYFRAME) --the first keyframe is 1, and "current" is the one that was just passed

            local j = 0
            while #thisBirdKeyframes < currentKeyframe + 3 do --needs more keyframes
                if j > 10 then --it has tried too many times to find a spot, give up because this bird is stuck
                    table.insert(birdsToRemove, i)
                    break
                end

                local newPos = findNewPosition(thisBirdKeyframes[#thisBirdKeyframes])
                if not newPos==false then
                    table.insert(thisBirdKeyframes, newPos)
                end

                j=j+1
            end
        end
    end

    for i = #birdsToRemove, 1, -1 do
        table.remove(birds, birdsToRemove[i])
    end
end

-- !make the new position be restricted to a certain angle in front of where it already is (vector from previous to current keyframe)
function findNewPosition(lastPos)
    local offset = vec:fromAngle(1, math.random() * math.pi * 2)
    offset:setMag(KEYFRAMESPACING)
    local newPos = vec:new(
        offset.x + lastPos.x,
        dimension.getMapHeight(math.floor(offset.x + lastPos.x), math.floor(offset.y + lastPos.z))+FLYHEIGHT,
        offset.y + lastPos.z
    )

    if dimension.raycast(lastPos.x, lastPos.y, lastPos.z, newPos.x, newPos.y, newPos.z).isBlock then --the bird would hit something on its way to the next position, so call the function again until it doesnt
        return false --this new position is invalid :(
    else
        return newPos
    end
end

t = 0

function postInit()
    birdBodyMesh = gfx.objLoad("Birds/body.obj")
    birdWingLMesh = gfx.objLoad("Birds/wingL.obj")
    birdWingRMesh = gfx.objLoad("Birds/wingR.obj")
end

-- lastVelocity = vec:new(0, 0, 0)
function render3d(dt)
    t = t + dt

    px, py, pz = player.pposition()
    pYaw, pPitch = player.rotation()
    pPos = vec:new(px, py, pz)

    for i = 1, #birds, 1 do
        local thisBird = birds[i]
        local thisBirdSpawnTime = thisBird[1]
        local thisBirdKeyframes = thisBird[2]

        -- for j = 1, #thisBirdKeyframes-1, 1 do
        --     gfx.line(
        --         thisBirdKeyframes[j].x, thisBirdKeyframes[j].y, thisBirdKeyframes[j].z,
        --         thisBirdKeyframes[j+1].x, thisBirdKeyframes[j+1].y, thisBirdKeyframes[j+1].z
        --     )
        -- end

        local timeSinceSpawn = t - thisBirdSpawnTime
        local keyframeMix = (timeSinceSpawn/TIMEPERKEYFRAME)-math.floor(timeSinceSpawn/TIMEPERKEYFRAME)
        local currentKeyframe = thisBirdKeyframes[math.ceil(timeSinceSpawn / TIMEPERKEYFRAME)]
        local nextKeyframe = thisBirdKeyframes[math.ceil(timeSinceSpawn / TIMEPERKEYFRAME)+1]

        local currentPos = catmullRomSpline3D(thisBirdKeyframes, timeSinceSpawn/TIMEPERKEYFRAME, 0, 0)
        local nextPos = catmullRomSpline3D(thisBirdKeyframes, timeSinceSpawn/TIMEPERKEYFRAME+0.01, 0, 0)
        local velocity = nextPos:copy():sub(currentPos):div(0.01)
        local facingDir = velocity:dir()
        
        local nextNextPos = catmullRomSpline3D(thisBirdKeyframes, timeSinceSpawn/TIMEPERKEYFRAME+0.02, 0, 0)
        local nextVelocity = nextNextPos:copy():sub(nextPos):div(0.01)
        local acceleration = nextVelocity:copy():sub(velocity):div(0.01)

        lastVelocity = velocity:copy()
        local turnDir = acceleration:copy():set(-acceleration.x, acceleration.y, acceleration.z):rotateYaw(-facingDir[1]):rotatePitch(-facingDir[2])
        -- log(turnDir.components)

        renderBird(currentPos, facingDir[1], facingDir[2], math.clamp(velocity.y+0.2, 0, 1), turnDir.z/200, t)

        -- gfx.color(255, 0, 0)
        -- gfx.line(currentPos.x, currentPos.y, currentPos.z, currentPos.x+acceleration.x, currentPos.y+acceleration.y, currentPos.z+acceleration.z)
    end
end

function catmullRomSpline1D(points, t, alpha, tension)
    local i = math.floor(t) + 1

    if #points < i + 3 then
        return points[#points - 1]
    end

    local p1 = points[i]
    local p2 = points[i + 1]
    local p3 = points[i + 2]
    local p4 = points[i + 3]

    -- stop it from giving errors of two points are the same (there's probably a better way of doing this)
    if p1 == p2 then p2 = p2 + 0.001 end
    if p2 == p3 then p3 = p3 + 0.001 end
    if p3 == p4 then p4 = p4 + 0.001 end

    t = t - math.floor(t)

    local t12 = math.abs(p1 - p2) ^ alpha
    local t23 = math.abs(p2 - p3) ^ alpha
    local t34 = math.abs(p3 - p4) ^ alpha

    local m1 = (1 - tension) *
        (p3 - p2 + t23 * ((p2 - p1) / t12 - (p3 - p1) / (t12 + t23)))

    local m2 = (1 - tension) *
        (p3 - p2 + t23 * ((p4 - p3) / t34 - (p4 - p2) / (t23 + t34)))

    local a = 2 * (p2 - p3) + m1 + m2
    local b = -3 * (p2 - p3) - m1 - m1 - m2
    local c = m1
    local d = p2

    return a * t ^ 3 +
        b * t ^ 2 +
        c * t +
        d
end

function catmullRomSpline3D(points, t, alpha, tension)
    -- the point at the first index will be in there twice to say that it's not moving at the start
    local xPoints = {points[1].x}
    local yPoints = {points[1].y}
    local zPoints = {points[1].z}

    for i = 1, #points, 1 do
        table.insert(xPoints, points[i].x)
        table.insert(yPoints, points[i].y)
        table.insert(zPoints, points[i].z)
    end

    local xPos = catmullRomSpline1D(xPoints, t, alpha, tension)
    local yPos = catmullRomSpline1D(yPoints, t, alpha, tension)
    local zPos = catmullRomSpline1D(zPoints, t, alpha, tension)

    return vec:new(xPos, yPos, zPos)
end

function renderBird(position, yaw, pitch, flapStrength, roll, t)
    gfx.pushTransformation(
        { 3, math.rad(90), 0, 0, 1 },
        { 3, roll, 0, 1, 0 }, --apply turning roll
        { 3, math.rad(-90), 0, 0, 1 },
        { 2, 0, 0.03*(flapStrength+0.5)*math.cos(t*10+math.cos(t)), 0}, --add random shake to the body ?not perfect?
        { 4, 2, 2, 2 },
        { 3, -pitch, 0, 1, 0 },
        { 3, math.pi/2-yaw, 0, 0, 1 },
        { 2, position.x, position.y, position.z }
    )
    gfx.objRender(birdBodyMesh, "Birds/texture.png")
    gfx.popTransformation()

    gfx.pushTransformation(
        { 3, math.rad(90), 0, 0, 1 },
        { 3, roll, 0, 1, 0 }, --apply turing roll !the pivot should be the body pivot, not the origin
        { 3, math.rad(-90), 0, 0, 1 },
        { 2, 0, 0.03*(flapStrength+0.5)*math.cos(t*10+math.cos(t)), 0 }, --add random shake to the body ?not perfect?
        { 3, -flapStrength*0.5*math.cos(10*t), 0, 1, 0 }, --two directions of flap animation
        { 3, math.rad(90), 0, 0, 1 },
        { 3, flapStrength*math.sin(10*t), 0, 1, 0 }, --two directions of flap animation
        { 3, math.rad(-90), 0, 0, 1 },
        { 2, 0.06, 0, 0 },

        -- align with body
        { 4, 2, 2, 2 },
        { 3, -pitch, 0, 1, 0 },
        { 3, math.pi/2-yaw, 0, 0, 1 },
        { 2, position.x, position.y, position.z }
    )
    gfx.objRender(birdWingLMesh, "Birds/texture.png")
    gfx.popTransformation()

    gfx.pushTransformation(
        { 3, math.rad(90), 0, 0, 1 },
        { 3, roll, 0, 1, 0 }, --apply turing roll !the pivot should be the body pivot, not the origin
        { 3, math.rad(-90), 0, 0, 1 },
        { 2, 0, 0.03*(flapStrength+0.5)*math.cos(t*10+math.cos(t)), 0 }, --add random shake to the body ?not perfect?
        { 3, -flapStrength*0.5*math.cos(10*t), 0, 1, 0 }, --two directions of flap animation
        { 3, math.rad(90), 0, 0, 1 },
        { 3, -flapStrength*math.sin(10*t), 0, 1, 0 }, --two directions of flap animation
        { 3, math.rad(-90), 0, 0, 1 },
        { 2, -0.06, 0, 0 },

        -- align with body
        { 4, 2, 2, 2 },
        { 3, -pitch, 0, 1, 0 },
        { 3, math.pi/2-yaw, 0, 0, 1 },
        { 2, position.x, position.y, position.z }
    )
    gfx.objRender(birdWingRMesh, "Birds/texture.png")
    gfx.popTransformation()
end