-- Made By O2Flash20

-- -- like gfx.triangle but takes in the points as tables {x, y, z}
-- function triangle3d(p1, p2, p3)
--     gfx.triangle(p1[1], p1[2], p1[3], p2[1], p2[2], p2[3], p3[1], p3[2], p3[3])
-- end

-- -- rotates a point in 3d space
-- function rotatePoint(x, y, z, originX, originY, originZ, pitch, yaw, roll)
--     local newX, newY, newZ

--     -- rotate along z axis
--     x = x - originX
--     y = y - originY

--     newX = x * math.cos(roll) - y * math.sin(roll)
--     newY = x * math.sin(roll) + y * math.cos(roll)

--     x = newX + originX
--     y = newY + originY

--     -- rotate along x axis
--     y = y - originY
--     z = z - originZ

--     newY = y * math.cos(pitch) - z * math.sin(pitch)
--     newZ = y * math.sin(pitch) + z * math.cos(pitch)

--     y = newY + originY
--     z = newZ + originZ

--     -- rotate along y axis
--     x = x - originX
--     z = z - originZ

--     newX = z * math.sin(yaw) + x * math.cos(yaw)
--     newZ = z * math.cos(yaw) - x * math.sin(yaw)

--     x = newX + originX
--     z = newZ + originZ

--     return { x, y, z }
-- end

-- Shape = {}
-- function Shape:rotate(originX, originY, originZ, pitch, yaw, roll)
--     local vertices = self.vertices
--     local output = {}

--     for i = 1, #vertices, 1 do
--         local newPoint = rotatePoint(
--             vertices[i][1], vertices[i][2], vertices[i][3],
--             originX, originY, originZ,
--             pitch, yaw, roll
--         )
--         table.insert(output, newPoint)
--     end

--     self.vertices = output
--     return self
-- end

-- Cube = {}
-- setmetatable(Cube, Shape)
-- Shape.__index = Shape

-- function Cube:new(x, y, z, width, height, depth)
--     local newCube = {}

--     -- CALCULATE ALL IT'S VERTEX POSITIONS
--     local cubeVertices = {}

--     local hW = width / 2
--     local hH = height / 2
--     local hD = depth / 2

--     table.insert(cubeVertices, { x - hW, y - hH, z - hD })
--     table.insert(cubeVertices, { x + hW, y - hH, z - hD })
--     table.insert(cubeVertices, { x - hW, y + hH, z - hD })
--     table.insert(cubeVertices, { x + hW, y + hH, z - hD })
--     table.insert(cubeVertices, { x - hW, y - hH, z + hD })
--     table.insert(cubeVertices, { x + hW, y - hH, z + hD })
--     table.insert(cubeVertices, { x - hW, y + hH, z + hD })
--     table.insert(cubeVertices, { x + hW, y + hH, z + hD })

--     newCube.vertices = cubeVertices
--     newCube.pos = { x, y, z }
--     --

--     setmetatable(newCube, self)
--     self.__index = self

--     return newCube
-- end

-- function Cube:attachToHead()
--     local pPitch, pYaw = player.rotation()
--     local px, py, pz = player.pposition()

--     pPitch = math.rad(-pPitch)
--     pYaw = math.rad(-pYaw - 90)

--     self.pos = { self.pos[1] + px, self.pos[2] + py + 0.3, self.pos[3] + pz }

--     self:rotate(px, py - 0.2, pz, pYaw, pPitch, 0)

--     return self
-- end

-- function Cube:render()
--     local vertices = self.vertices

--     triangle3d(vertices[3], vertices[2], vertices[1])
--     triangle3d(vertices[6], vertices[7], vertices[5])

--     triangle3d(vertices[2], vertices[3], vertices[4])
--     triangle3d(vertices[8], vertices[7], vertices[6])

--     triangle3d(vertices[5], vertices[3], vertices[1])
--     triangle3d(vertices[2], vertices[4], vertices[6])

--     triangle3d(vertices[3], vertices[5], vertices[7])
--     triangle3d(vertices[8], vertices[6], vertices[4])

--     triangle3d(vertices[1], vertices[2], vertices[5])
--     triangle3d(vertices[7], vertices[4], vertices[3])

--     triangle3d(vertices[6], vertices[5], vertices[2])
--     triangle3d(vertices[4], vertices[7], vertices[8])
-- end

-- function Cube:log()
--     log(self.pos)
-- end


-- like gfx.triangle but takes in the points as tables {x, y, z}
function triangle3d(p1, p2, p3)
    gfx.triangle(p1[1], p1[2], p1[3], p2[1], p2[2], p2[3], p3[1], p3[2], p3[3])
end

-- rotates a point in 3d space
function rotatePoint(x, y, z, originX, originY, originZ, pitch, yaw, roll)
    local newX, newY, newZ

    -- rotate along z axis
    x = x - originX
    y = y - originY

    newX = x * math.cos(roll) - y * math.sin(roll)
    newY = x * math.sin(roll) + y * math.cos(roll)

    x = newX + originX
    y = newY + originY

    -- rotate along x axis
    y = y - originY
    z = z - originZ

    newY = y * math.cos(pitch) - z * math.sin(pitch)
    newZ = y * math.sin(pitch) + z * math.cos(pitch)

    y = newY + originY
    z = newZ + originZ

    -- rotate along y axis
    x = x - originX
    z = z - originZ

    newX = z * math.sin(yaw) + x * math.cos(yaw)
    newZ = z * math.cos(yaw) - x * math.sin(yaw)

    x = newX + originX
    z = newZ + originZ

    return { x, y, z }
end

Shape = {}
function Shape:rotate(originX, originY, originZ, pitch, yaw, roll)
    local vertices = self.vertices
    local output = {}

    for i = 1, #vertices, 1 do
        local newPoint = rotatePoint(
            vertices[i][1], vertices[i][2], vertices[i][3],
            originX, originY, originZ,
            pitch, yaw, roll
        )
        table.insert(output, newPoint)
    end

    self.vertices = output
    return self
end

Cube = {}
setmetatable(Cube, Shape)
Shape.__index = Shape

function Cube:new(x, y, z, width, height, depth)
    local newCube = {}

    newCube.pos = { x, y, z }
    newCube.size = { width, height, depth }
    newCube.rotation = { 0, 0, 0 }

    setmetatable(newCube, self)
    self.__index = self

    return newCube
end

function Cube:render()
    local vertices = {}

    local x = self.pos[1]
    local y = self.pos[2]
    local z = self.pos[3]

    local width = self.size[1]
    local height = self.size[2]
    local depth = self.size[3]

    local hW = width / 2
    local hH = height / 2
    local hD = depth / 2

    -- get all the vertices
    table.insert(vertices, { x - hW, y - hH, z - hD })
    table.insert(vertices, { x + hW, y - hH, z - hD })
    table.insert(vertices, { x - hW, y + hH, z - hD })
    table.insert(vertices, { x + hW, y + hH, z - hD })
    table.insert(vertices, { x - hW, y - hH, z + hD })
    table.insert(vertices, { x + hW, y - hH, z + hD })
    table.insert(vertices, { x - hW, y + hH, z + hD })
    table.insert(vertices, { x + hW, y + hH, z + hD })

    -- rotate all the vertices
    -- local output = {}

    -- for i = 1, #vertices, 1 do
    --     local newPoint = rotatePoint(
    --         vertices[i][1], vertices[i][2], vertices[i][3],
    --         , originY, originZ,
    --         pitch, yaw, roll
    --     )
    --     table.insert(output, newPoint)
    -- end
    -- vertices = output

    -- render all the vertices
    triangle3d(vertices[3], vertices[2], vertices[1])
    triangle3d(vertices[6], vertices[7], vertices[5])

    triangle3d(vertices[2], vertices[3], vertices[4])
    triangle3d(vertices[8], vertices[7], vertices[6])

    triangle3d(vertices[5], vertices[3], vertices[1])
    triangle3d(vertices[2], vertices[4], vertices[6])

    triangle3d(vertices[3], vertices[5], vertices[7])
    triangle3d(vertices[8], vertices[6], vertices[4])

    triangle3d(vertices[1], vertices[2], vertices[5])
    triangle3d(vertices[7], vertices[4], vertices[3])

    triangle3d(vertices[6], vertices[5], vertices[2])
    triangle3d(vertices[4], vertices[7], vertices[8])
end

function Cube:log()
    log(self.pos)
end

--[[
    Object:
        position
        rotationQueue
        attachPosition
        attachRotation (origin, angle)
        attachTo()
            sets the attachPosition and attachRotation
        rotateSelf()
            adds values to the rotation queue
        rotateCustom()
            adds values to the rotation queue
    
    Shape:
        rotateSelf()
            adds values to the rotation queue
        rotateCustom()
            adds values to the rotation queue
        3dRotation(originX, originY, originZ, pitch, yaw, roll)
        rotationQueue
        vertices
        position
        parent:
            can get all of the parent's information seen above

    Cube:
        new()
        size
        render()

    //
    Hat = Object:new(0, 1, 0)
        :attachToHead()
        :rotateSelf(0, 45, 0)
        :rotateCustom( -- rotate custom has the player position at (0, 0, 0)
            0, 2, 0,
            t, 0, 0
        )

    Cube:new(Hat, 0.2, 0, 0, 0.1, 0.1, 0.5)
        :rotateSelf(0, 0, 25)
        :render()

    Create a new object at (0, 1, 0)
    attachToHead: notes the position offset to attach to the head (PERFORMS THIS AT THE END) and AT THE END of the object's rotation queue the rotation to match the head
    rotateSelf: adds to the rotation queue a rotation with origin at the object's position
    rotateCustom: adds to the rotation queue a rotation with the origin inputted

    Create a new Cube at position (0.2, 0, 0) with size (0.1, 0.1, 0.5) that stores the rotations and offsets of the Object stated in the first parameter
    rotateSelf: adds to the rotation queue a rotation with origin at the cube's position
    render: 
        1. The cube calculates all of its vertices using size and position
        2. Loops over all its vertices and performs all the rotations IN THE CUBE'S QUEUE

        3. Loops over all its vertices and offsets their positions according to it's parent Object
        4. Loops over all its vertices and performs all the rotations IN THE PARENT'S QUEUE

        5. Loops over all its vertices and offsets their positions according to it's attach point
        6. Loops over all its vertices and performs the rotation needed to ATTACH TO A BODY PART
    //
]]
