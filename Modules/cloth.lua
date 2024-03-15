name = "Cloth Capes"
description = "cloth????"

importLib("vectors")
importLib("logger")

client.settings.addInfo(
    "To get to the capes folder, type [.lua path] into chat and in the opened folder, navigate to Data/clothCapes."
)

saveCapeName = client.settings.addNamelessTextbox("Save name:", "worn cape")
function saveWornCape()
    player.skin().saveCape("clothCapes/" .. saveCapeName.value .. ".png")
end

client.settings.addFunction("Save in-game cape to folder", "saveWornCape", "Save")

enums = { { 1, "None" } }
filesInFolder = fs.files("clothCapes")
for i = 1, #filesInFolder, 1 do
    table.insert(enums, { i + 1, filesInFolder[i]:sub(12) })
end
selectedCape = client.settings.addNamelessEnum("Selected Cape:", 1, enums)

-- Physics Controls
POINTSMASS = 0.1
DAMPING = 8
SPRINGSTRENGTH = 350

Point = {}
function Point:new(pos, isLocked)
    local newPoint = {}

    setmetatable(newPoint, self)
    self.__index = self

    newPoint.pos = pos
    newPoint.vel = vec:new(0, 0, 0)
    newPoint.acc = vec:new(0, 0, 0)
    newPoint.isLocked = (isLocked == true)

    return newPoint
end

function Point:update(dt)
    if not self.isLocked then
        self.acc:add(self.vel:copy():mult(-DAMPING))
        self.vel:add(self.acc:copy():mult(dt))

        local dp = self.vel:copy():mult(dt)

        -- check collision with each collider
        for i = 1, #colliders, 1 do
            local c = colliders[i]

            local posRelative = self.pos:copy():sub(c.pos):rotate(-c.yaw, 0)
            local dpRelative = dp:copy():sub(c.dp):rotate(-c.yaw, 0) --make it relative to the collider (making the collider at the origin with no rotation and no velocity)

            if c.isVertical then
                if posRelative.z > 0 and posRelative.z + dpRelative.z < 0 then
                    local t = -posRelative.z / dpRelative.z
                    local xHit = posRelative.x + t * dpRelative.x
                    local yHit = posRelative.y + t * dpRelative.y

                    if math.abs(xHit) < c.width / 2 and math.abs(yHit) < c.height / 2 then --the point will cross the collider and will hit it (not pass by)
                        dpRelative:setComponent(3, -2 * c.dp:copy():rotate(c.yaw, 0).z)
                        self.vel = self.vel:sub(c.dp):rotate(-c.yaw, 0):setComponent(3, 0):rotate(c.yaw, 0):add(c.dp)
                        dp = dpRelative:rotate(c.yaw, 0):add(c.dp)
                    end
                end
            else
                if posRelative.y > 0 and posRelative.y + dpRelative.y < 0 then
                    local t = -posRelative.y / dpRelative.y
                    local xHit = posRelative.x + t * dpRelative.x
                    local zHit = posRelative.z + t * dpRelative.z

                    if math.abs(xHit) < c.width / 2 and math.abs(zHit) < c.height / 2 then --the point will cross the collider and will hit it (not pass by)
                        dpRelative:setComponent(2, -2 * c.dp.y)
                        self.vel = self.vel:sub(c.dp):rotate(-c.yaw, 0):setComponent(2, 0):rotate(c.yaw, 0):add(c.dp)
                        dp = dpRelative:rotate(c.yaw, 0):add(c.dp)
                    end
                end
            end
        end

        self.pos:add(dp)
        self.acc = vec:new(0, 0, 0)
    end
end

Spring = {}
function Spring:new(a, b, restLength, k) -- a and b are Points
    local newSpring = {}

    setmetatable(newSpring, self)
    self.__index = self

    newSpring.a = a
    newSpring.b = b
    newSpring.restLength = restLength
    newSpring.k = k

    return newSpring
end

function Spring:applySpringForce()
    local d = self.a.pos:dist(self.b.pos)
    local deltaX = d - self.restLength

    self.a.acc:add(self.b.pos:copy():sub(self.a.pos):setMag(self.k * deltaX):div(POINTSMASS))
    self.b.acc:add(self.a.pos:copy():sub(self.b.pos):setMag(self.k * deltaX):div(POINTSMASS))
end

function Spring:draw()
    gfx.line(self.a.pos.x, self.a.pos.y, self.a.pos.z, self.b.pos.x, self.b.pos.y, self.b.pos.z)
end

colliders = {}
Collider = {}
function Collider:new(pos, yaw, isVertical, width, height, dp) --it would be nice if it worked for any pitch and yaw, but vector rotations 😭
    local newCollider = {}

    setmetatable(newCollider, self)
    self.__index = self

    newCollider.pos = pos
    newCollider.yaw = yaw
    newCollider.isVertical = isVertical
    newCollider.width = width
    newCollider.height = height
    newCollider.dp = dp

    return newCollider
end

function Collider:draw()
    if self.isVertical then
        local topRight = vec:new(self.width / 2, self.height / 2, 0):rotate(self.yaw, 0):add(self.pos)
        local topLeft = vec:new(-self.width / 2, self.height / 2, 0):rotate(self.yaw, 0):add(self.pos)
        local bottomRight = vec:new(self.width / 2, -self.height / 2, 0):rotate(self.yaw, 0):add(self.pos)
        local bottomLeft = vec:new(-self.width / 2, -self.height / 2, 0):rotate(self.yaw, 0):add(self.pos)

        gfx.quad(
            bottomLeft.x, bottomLeft.y, bottomLeft.z,
            bottomRight.x, bottomRight.y, bottomRight.z,
            topRight.x, topRight.y, topRight.z,
            topLeft.x, topLeft.y, topLeft.z,
            false
        )
    else
        local topRight = vec:new(self.width / 2, 0, self.height / 2):rotate(self.yaw, 0):add(self.pos)
        local topLeft = vec:new(-self.width / 2, 0, self.height / 2):rotate(self.yaw, 0):add(self.pos)
        local bottomRight = vec:new(self.width / 2, 0, -self.height / 2):rotate(self.yaw, 0):add(self.pos)
        local bottomLeft = vec:new(-self.width / 2, 0, -self.height / 2):rotate(self.yaw, 0):add(self.pos)

        gfx.quad(
            topLeft.x, topLeft.y, topLeft.z,
            topRight.x, topRight.y, topRight.z,
            bottomRight.x, bottomRight.y, bottomRight.z,
            bottomLeft.x, bottomLeft.y, bottomLeft.z,
            false
        )
    end
end

-- Cape Dimensions Controls
CWIDTH = 3
CHEIGHT = 6
CSPACINGW = .6 / (CWIDTH - 1)
CSPACINGH = .95 / (CHEIGHT - 1)
CTHICKNESS = 0.06
DISTTOPLAYER = 0.15

points = {} --setting up the cape for the first time
for i = 1, CWIDTH, 1 do
    points[i] = {}
    for j = 1, CHEIGHT, 1 do
        points[i][j] = Point:new(vec:new(CSPACINGW * i, CSPACINGH * j, 0), j == CHEIGHT) --only locks top row
    end
end

--connect up the springs
springs = {}
for i = 1, CWIDTH, 1 do
    for j = 1, CHEIGHT, 1 do
        -- structural
        if i ~= CWIDTH then
            table.insert(springs, Spring:new(points[i][j], points[i + 1][j], CSPACINGW, SPRINGSTRENGTH))
        end
        if j ~= CHEIGHT then
            table.insert(springs, Spring:new(points[i][j], points[i][j + 1], CSPACINGH, SPRINGSTRENGTH))
        end

        -- shear
        if i ~= CWIDTH and j ~= CHEIGHT then
            table.insert(springs,
                Spring:new(
                    points[i][j], points[i + 1][j + 1],
                    math.sqrt(CSPACINGW * CSPACINGW + CSPACINGH * CSPACINGH),
                    SPRINGSTRENGTH
                )
            )
        end
        if i ~= 1 and j ~= CHEIGHT then
            table.insert(springs,
                Spring:new(
                    points[i][j], points[i - 1][j + 1],
                    math.sqrt(CSPACINGW * CSPACINGW + CSPACINGH * CSPACINGH),
                    SPRINGSTRENGTH
                )
            )
        end

        -- flexion
        if i < CWIDTH - 1 then
            table.insert(springs, Spring:new(points[i][j], points[i + 2][j], CSPACINGW * 2, SPRINGSTRENGTH))
        end
        if j < CHEIGHT - 1 then
            table.insert(springs, Spring:new(points[i][j], points[i][j + 2], CSPACINGH * 2, SPRINGSTRENGTH))
        end
    end
end

-- player's body collider
table.insert(colliders, Collider:new(vec:new(0, 0, 0), 0, true, 2, 2, vec:new(0, 0, 0)))

iteration = 0
madeDir = false
function update()
    -- if not madeDir then
    --     log(fs.isdir("clothCapes"))
    --     if not fs.isdir("clothCapes") then -- makes the folder for the capes to go in if they dont already exist
    --         fs.mkdir("clothCapes")
    --         madeDir = true
    --     end
    -- end

    iteration = (iteration + 1) % 10
    if iteration ~= 0 then return end
    -- update colliders for the blocks around the player
    local px, py, pz = player.position()

    -- remove the old block colliders
    for i = 2, #colliders, 1 do
        table.remove(colliders, 2)
    end

    for i = -1, 1 do
        for k = -1, 1 do
            for j = -1, 1 do
                if dimension.getBlock(px + i, py + k, pz + j).isSolid and not dimension.getBlock(px + i, py + k + 1, pz + j).isSolid then
                    table.insert( -- +y only, i dont want to have collisions for the other faces for frame rate reasons
                        colliders,
                        Collider:new(
                            vec:new(0.5 + i + px, 1 + k + py, 0.5 + j + pz),
                            0,
                            false,
                            1, 1,
                            vec:new(0, 0, 0))
                    )
                end
            end
        end
    end
end

t = 0
lastPPosVec = nil
function render3d(dt)
    t = t + dt

    px, py, pz = player.pposition()
    pyaw = player.bodyRotation()

    -- get player position and velocity as a vector
    local pPosVec = vec:new(px, py, pz)
    local pdp
    if lastPPosVec then pdp = pPosVec:copy():sub(lastPPosVec) end
    lastPPosVec = pPosVec

    -- update the player's collider
    local yawRad = math.rad(pyaw)
    colliders[1].pos = vec:new(0, -0.55, 0.1):rotate(yawRad + math.rad(180), 0):add(pPosVec)
    colliders[1].yaw = yawRad + math.rad(180)
    colliders[1].dp = pdp or vec:new(0, 0, 0)

    -- move the top layer of points to the neck of the player
    for i = 1, CWIDTH, 1 do
        local newPos = vec:new((i - 0.5 - CWIDTH / 2) * CSPACINGW, -0.2, -DISTTOPLAYER):rotate(math.rad(pyaw), 0)
        points[i][CHEIGHT].pos:set(
            newPos.x + px,
            newPos.y + py,
            newPos.z + pz
        )
    end

    -- update the forces, accelerations, velocities, and positions three times per frame to avoid jitters
    local subframes = 3
    for timeStep = 1, subframes, 1 do
        for i = 1, #springs, 1 do
            springs[i]:applySpringForce()
        end

        for i = 1, CWIDTH, 1 do
            for j = 1, CHEIGHT, 1 do
                points[i][j].acc:add(vec:new(0, -9.81, 0))
                points[i][j].acc:add(
                    sinNoise3d(
                        points[i][j].pos:copy():mult(20):add(vec:new(t, t, t):mult(20))
                    ):mult(20)
                )
                points[i][j]:update(dt / subframes)

                -- if a point is going too fast, reset the entire cape
                if points[i][j].vel:magSq() > 20000 then
                    resetCape(); goto skipPhysics
                end
            end
        end
    end

    ::skipPhysics::

    quadsToRender = {} --add all the quads to render to a table and batch render them later

    -- rendering the simulated version of the cape (the one that's usually hidden by the player's body)
    for i = 1, CWIDTH - 1, 1 do
        for j = 1, CHEIGHT - 1, 1 do
            table.insert(quadsToRender, {
                points[i + 1][j].pos.x, points[i + 1][j].pos.y, points[i + 1][j].pos.z,
                map(i + 1, 1, CWIDTH, 12 / 64, 22 / 64), map(j, CHEIGHT, 1, 1 / 32, 17 / 32),
                points[i + 1][j + 1].pos.x, points[i + 1][j + 1].pos.y, points[i + 1][j + 1].pos.z,
                map(i + 1, 1, CWIDTH, 12 / 64, 22 / 64), map(j + 1, CHEIGHT, 1, 1 / 32, 17 / 32),
                points[i][j + 1].pos.x, points[i][j + 1].pos.y, points[i][j + 1].pos.z,
                map(i, 1, CWIDTH, 12 / 64, 22 / 64), map(j + 1, CHEIGHT, 1, 1 / 32, 17 / 32),
                points[i][j].pos.x, points[i][j].pos.y, points[i][j].pos.z,
                map(i, 1, CWIDTH, 12 / 64, 22 / 64), map(j, CHEIGHT, 1, 1 / 32, 17 / 32)
            })
        end
    end

    -- create a copy of "points" but now the solifidied set
    local solidifyOffsets = {}
    for i = 1, CWIDTH, 1 do
        table.insert(solidifyOffsets, {})
        for j = 1, CHEIGHT, 1 do
            solidifyOffsets[i][j] = vec:new(0, 0, 0, 0)
        end
    end

    -- calculate the offset that the thickened layer of points has
    for i = 1, CWIDTH - 1, 1 do
        for j = 1, CHEIGHT - 1, 1 do
            local BA = points[i + 1][j].pos:copy():sub(points[i][j].pos)
            local CA = points[i][j + 1].pos:copy():sub(points[i][j].pos)
            local faceNormal = CA:cross(BA):normalize()
            local solidifyOffset = faceNormal:copy():setMag(CTHICKNESS)

            solidifyOffset:setComponent("w", 1) --add a fourth dimension of "how many times has an offset been added", for averaging later

            solidifyOffsets[i][j]:add(solidifyOffset)
            solidifyOffsets[i + 1][j]:add(solidifyOffset)
            solidifyOffsets[i][j + 1]:add(solidifyOffset)
            solidifyOffsets[i + 1][j + 1]:add(solidifyOffset)
        end
    end

    -- average the points that are shared between faces
    for i = 1, CWIDTH, 1 do
        for j = 1, CHEIGHT, 1 do
            solidifyOffsets[i][j]:div(solidifyOffsets[i][j].w)
        end
    end

    -- render the thickened part of the cape
    for i = 1, CWIDTH - 1, 1 do
        for j = 1, CHEIGHT - 1, 1 do
            table.insert(quadsToRender, {
                points[i][j].pos.x + solidifyOffsets[i][j].x,
                points[i][j].pos.y + solidifyOffsets[i][j].y,
                points[i][j].pos.z + solidifyOffsets[i][j].z,
                map(i, CWIDTH, 1, 1 / 64, 11 / 64), map(j, CHEIGHT, 1, 1 / 32, 17 / 32),
                points[i][j + 1].pos.x + solidifyOffsets[i][j + 1].x,
                points[i][j + 1].pos.y + solidifyOffsets[i][j + 1].y,
                points[i][j + 1].pos.z + solidifyOffsets[i][j + 1].z,
                map(i, CWIDTH, 1, 1 / 64, 11 / 64), map(j + 1, CHEIGHT, 1, 1 / 32, 17 / 32),
                points[i + 1][j + 1].pos.x + solidifyOffsets[i + 1][j + 1].x,
                points[i + 1][j + 1].pos.y + solidifyOffsets[i + 1][j + 1].y,
                points[i + 1][j + 1].pos.z + solidifyOffsets[i + 1][j + 1].z,
                map(i + 1, CWIDTH, 1, 1 / 64, 11 / 64), map(j + 1, CHEIGHT, 1, 1 / 32, 17 / 32),
                points[i + 1][j].pos.x + solidifyOffsets[i + 1][j].x,
                points[i + 1][j].pos.y + solidifyOffsets[i + 1][j].y,
                points[i + 1][j].pos.z + solidifyOffsets[i + 1][j].z,
                map(i + 1, CWIDTH, 1, 1 / 64, 11 / 64), map(j, CHEIGHT, 1, 1 / 32, 17 / 32)
            })
        end
    end

    -- finish the shape by rendering the edges of the cape
    for i = 1, CWIDTH - 1, 1 do --bottom edge
        table.insert(quadsToRender, {
            points[i + 1][1].pos.x + solidifyOffsets[i + 1][1].x,
            points[i + 1][1].pos.y + solidifyOffsets[i + 1][1].y,
            points[i + 1][1].pos.z + solidifyOffsets[i + 1][1].z,
            map(i + 1, 1, CWIDTH, 12 / 64, 21 / 64), 0,
            points[i + 1][1].pos.x,
            points[i + 1][1].pos.y,
            points[i + 1][1].pos.z,
            map(i + 1, 1, CWIDTH, 12 / 64, 21 / 64), 0,
            points[i][1].pos.x,
            points[i][1].pos.y,
            points[i][1].pos.z,
            map(i, 1, CWIDTH, 12 / 64, 21 / 64), 0,
            points[i][1].pos.x + solidifyOffsets[i][1].x,
            points[i][1].pos.y + solidifyOffsets[i][1].y,
            points[i][1].pos.z + solidifyOffsets[i][1].z,
            map(i, 1, CWIDTH, 12 / 64, 21 / 64), 0
        })
    end
    for i = 1, CWIDTH - 1, 1 do --top edge
        table.insert(quadsToRender, {
            points[i][CHEIGHT].pos.x + solidifyOffsets[i][CHEIGHT].x,
            points[i][CHEIGHT].pos.y + solidifyOffsets[i][CHEIGHT].y,
            points[i][CHEIGHT].pos.z + solidifyOffsets[i][CHEIGHT].z,
            map(i, 1, CWIDTH, 1 / 64, 11 / 64), 0,
            points[i][CHEIGHT].pos.x,
            points[i][CHEIGHT].pos.y,
            points[i][CHEIGHT].pos.z,
            map(i, 1, CWIDTH, 1 / 64, 11 / 64), 0,
            points[i + 1][CHEIGHT].pos.x,
            points[i + 1][CHEIGHT].pos.y,
            points[i + 1][CHEIGHT].pos.z,
            map(i + 1, 1, CWIDTH, 1 / 64, 11 / 64), 0,
            points[i + 1][CHEIGHT].pos.x + solidifyOffsets[i + 1][CHEIGHT].x,
            points[i + 1][CHEIGHT].pos.y + solidifyOffsets[i + 1][CHEIGHT].y,
            points[i + 1][CHEIGHT].pos.z + solidifyOffsets[i + 1][CHEIGHT].z,
            map(i + 1, 1, CWIDTH, 1 / 64, 11 / 64), 0
        })
    end
    for j = 1, CHEIGHT - 1, 1 do --left edge
        table.insert(quadsToRender, {
            points[CWIDTH][j + 1].pos.x + solidifyOffsets[CWIDTH][j + 1].x,
            points[CWIDTH][j + 1].pos.y + solidifyOffsets[CWIDTH][j + 1].y,
            points[CWIDTH][j + 1].pos.z + solidifyOffsets[CWIDTH][j + 1].z,
            0, map(j + 1, CHEIGHT, 1, 1 / 32, 17 / 32),
            points[CWIDTH][j + 1].pos.x,
            points[CWIDTH][j + 1].pos.y,
            points[CWIDTH][j + 1].pos.z,
            0, map(j + 1, CHEIGHT, 1, 1 / 32, 17 / 32),
            points[CWIDTH][j].pos.x,
            points[CWIDTH][j].pos.y,
            points[CWIDTH][j].pos.z,
            0, map(j, CHEIGHT, 1, 1 / 32, 17 / 32),
            points[CWIDTH][j].pos.x + solidifyOffsets[CWIDTH][j].x,
            points[CWIDTH][j].pos.y + solidifyOffsets[CWIDTH][j].y,
            points[CWIDTH][j].pos.z + solidifyOffsets[CWIDTH][j].z,
            0, map(j, CHEIGHT, 1, 1 / 32, 17 / 32)
        })
    end
    for j = 1, CHEIGHT - 1, 1 do --right edge
        table.insert(quadsToRender, {
            points[1][j].pos.x + solidifyOffsets[1][j].x,
            points[1][j].pos.y + solidifyOffsets[1][j].y,
            points[1][j].pos.z + solidifyOffsets[1][j].z,
            12 / 64, map(j, CHEIGHT, 1, 1 / 32, 17 / 32),
            points[1][j].pos.x,
            points[1][j].pos.y,
            points[1][j].pos.z,
            12 / 64, map(j, CHEIGHT, 1, 1 / 32, 17 / 32),
            points[1][j + 1].pos.x,
            points[1][j + 1].pos.y,
            points[1][j + 1].pos.z,
            12 / 64, map(j + 1, CHEIGHT, 1, 1 / 32, 17 / 32),
            points[1][j + 1].pos.x + solidifyOffsets[1][j + 1].x,
            points[1][j + 1].pos.y + solidifyOffsets[1][j + 1].y,
            points[1][j + 1].pos.z + solidifyOffsets[1][j + 1].z,
            12 / 64, map(j + 1, CHEIGHT, 1, 1 / 32, 17 / 32)
        })
    end

    gfx.tquadbatch(quadsToRender, "clothCapes/" .. selectedCape.enumValues[selectedCape.value][1], true) --render all the quads with the selected texture
end

-- inputs a 3d vector, outputs a 3d vector
function sinNoise3d(seed)
    local output = vec:new(0, 0, 0)
    for i = 0.5, 3, 0.5 do
        output:add(
            vec:new(
                i * math.sin(1 / i * seed.x),
                i * math.sin(1 / i * seed.y + 10),
                i * math.sin(1 / i * seed.z + 20)
            )
        )
    end
    return output
end

function resetCape()
    for i = 1, #points, 1 do
        for j = 1, #points[1], 1 do
            local p = points[i][j]
            p.vel:mult(0)
            p.acc:mult(0)
            p.pos = vec:new((i - 0.5 - CWIDTH / 2) * CSPACINGW, j * CSPACINGH - 1.35, -DISTTOPLAYER)
                :rotate(math.rad(pyaw), 0)
                :add(vec:new(px, py, pz))
        end
    end
end

function map(val, min1, max1, min2, max2)
    return (val - min1) * (max2 - min2) / (max1 - min1) + min2
end

--[[
    if the clothCapes folder doesnt exist, create it (in the update function?)
        if there is no cape or cape is "None", dont do anything at all
    if you save a worn cape, recreate the enum

    disable cape in first person, change the position of it when crouching (swimming?)
]]
