-- Made By O2Flash20

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

-- updates player position and such
function updateCosmeticTools()
    px, py, pz = player.pposition()
    pPitch, pYaw = player.rotation()
    bodyRotation = player.bodyRotation()
end

Object = {}
-- create a new Object
function Object:new(x, y, z)
    local newObject = {}

    setmetatable(newObject, self)
    self.__index = self

    newObject.pos = { x, y, z }
    newObject.rotationQueue = {}

    return newObject
end

-- set the position and rotation of the Object's attachment
-- make one function for every attachment?
function Object:attachToHead()
    self.attachPosition = { px, py - 0.2, pz }

    self.attachRotation = { math.rad(pYaw), math.rad(-pPitch), 0 }

    return self
end

function Object:attachToBody()
    self.attachPosition = { px, py - 0.55, pz }
    self.attachRotation = { 0, math.rad(-bodyRotation), 0 }

    return self
end

function Object:attachNone()
    self.attachPosition = { 0, 0, 0 }
    self.attachRotation = { 0, 0, 0 }

    return self
end

function Object:attachToPlayer()
    self.attachPosition = { px, py, pz }
    self.attachRotation = { 0, 0, 0 }

    return self
end

-- tells all the Shapes of the Object to rotate around a given point, gets added to a queue
function Object:rotateCustom(originX, originY, originZ, pitch, yaw, roll)
    local rotationQueue = self.rotationQueue or {}

    table.insert(rotationQueue, { { originX, originY, originZ }, { pitch, yaw, roll } })

    self.rotationQueue = rotationQueue
    return self
end

-- tells all the Shapes of the Object to rotate around the center of the object, gets added to a queue
function Object:rotateSelf(pitch, yaw, roll)
    self:rotateCustom(self.pos[1], self.pos[2], self.pos[3], pitch, yaw, roll)
    return self
end

-- tells all the Shapes of the Object to rotate around the attachment point, gets added to a queue
-- is {0, 0, 0} right?
function Object:rotateAttachment(pitch, yaw, roll)
    self:rotateCustom(0, 0, 0, pitch, yaw, roll)
    return self
end

Cube = {}
function Cube:new(Object, x, y, z, width, height, depth)
    local newCube = {}

    setmetatable(newCube, self)
    self.__index = self

    newCube.object = Object

    newCube.pos = { x, y, z }
    newCube.size = { width, height, depth }
    newCube.rotationQueue = {}

    return newCube
end

-- adds a rotation with a custom origin to the queue
function Cube:rotateCustom(originX, originY, originZ, pitch, yaw, roll)
    local rotationQueue = self.rotationQueue or {}

    table.insert(rotationQueue, { { originX, originY, originZ }, { pitch, yaw, roll } })

    self.rotationQueue = rotationQueue
    return self
end

-- rotates around self
function Cube:rotateSelf(pitch, yaw, roll)
    self:rotateCustom(self.pos[1], self.pos[2], self.pos[3], pitch, yaw, roll)
    return self
end

-- rotates around its object
function Cube:rotateObject(pitch, yaw, roll)
    self:rotateCustom(0, 0, 0, pitch, yaw, roll)
    return self
end

-- renders the cube
-- color is an array {red, green, blue}
function Cube:render(color)
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

    -- go through it's own rotation queue
    for i = 1, #self.rotationQueue, 1 do
        vertices = rotate3d(vertices,
            self.rotationQueue[i][1][1], self.rotationQueue[i][1][2], self.rotationQueue[i][1][3],
            self.rotationQueue[i][2][1], self.rotationQueue[i][2][2], self.rotationQueue[i][2][3]
        )
    end

    -- move all the points over to attach to its object
    for i = 1, #vertices, 1 do
        vertices[i][1] = vertices[i][1] + self.object.pos[1]
        vertices[i][2] = vertices[i][2] + self.object.pos[2]
        vertices[i][3] = vertices[i][3] + self.object.pos[3]
    end

    -- go through it's object's rotation queue
    for i = 1, #self.object.rotationQueue, 1 do
        vertices = rotate3d(vertices,
            self.object.rotationQueue[i][1][1], self.object.rotationQueue[i][1][2], self.object.rotationQueue[i][1][3],
            self.object.rotationQueue[i][2][1], self.object.rotationQueue[i][2][2], self.object.rotationQueue[i][2][3]
        )
    end

    -- move all the points over to attach to its attach point
    for i = 1, #vertices, 1 do
        vertices[i][1] = vertices[i][1] + self.object.attachPosition[1]
        vertices[i][2] = vertices[i][2] + self.object.attachPosition[2]
        vertices[i][3] = vertices[i][3] + self.object.attachPosition[3]
    end

    -- rotate to meet attachment point
    vertices = rotate3d(vertices,
        self.object.attachPosition[1], self.object.attachPosition[2], self.object.attachPosition[3],
        self.object.attachRotation[1], self.object.attachRotation[2], self.object.attachRotation[3]
    )

    -- render all the vertices
    gfx.color(color[1], color[2], color[3])

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

-- given the origin and angles, rotates all vertices
function rotate3d(vertices, originX, originY, originZ, pitch, yaw, roll)
    local output = {}

    for i = 1, #vertices, 1 do
        local newPoint = rotatePoint(
            vertices[i][1], vertices[i][2], vertices[i][3],
            originX, originY, originZ,
            pitch, yaw, roll
        )
        table.insert(output, newPoint)
    end
    return output
end

--[[
    DOCUMENTATION:

    updateCosmeticTools()
        Updates the player's positions and rotations to be used by other functions. For the best result, run this function at the start of render3d()

    Object:
        An object is a collection of 3d shapes which attaches to a specified body part. Anything done to an Object is also done to all the shapes it includes.
        FUNCTIONS
            new(x, y, z)
                Returns a new Object with position {x, y, z}

            attachToHead()
                Attaches this object to the player's head
            attachToBody()
                Attaches this object to the player's body
            attachToPlayer()
                Attaches this object to the player's position. It does not rotate with the player.
            attachNone()
                Does not attach the object to the player, the object's position becomes world coordinates

            rotateCustom(originX, originY, originZ, pitch, yaw, roll)
                Rotates the object around a custom origin point with a specified pitch, yaw, and roll. Note that the origin is relative to the player and is not world coordinates.
            rotateSelf(pitch, yaw, roll)
                Rotates the object around itself with a specified pitch, yaw, and roll.
            rotateAttachment(pitch, yaw, roll)
                Rotates the object around the body part that it's attached to with a specified pitch, yaw, and roll.

    Cube:
        A 3d object with a position, width, height, and depth that gets attached to an Object.
        FUNCTIONS
            new(Object, x, y, z, width, height, depth)
                Creates a new Cube that is attached to the specified object. It has a position {x, y, z} (relative to the object it's attached to) and has a specified width, height, and depth.

            rotateCustom(originX, originY, originZ, pitch, yaw, roll)
                Rotates the cube around a custom origin point with a specified pitch, yaw, and roll. Note that the origin is relative to the object it's attached to.
            rotateSelf(pitch, yaw, roll)
                Rotates the cube around itself with a specified pitch, yaw, and roll.
            rotateObject(pitch, yaw, roll)
                Rotates the object around the object that it's attached to with a specified pitch, yaw, and roll.

            render(color)
                Renders the cube into the world with a specified color. The color parameter should be {Red(0-255), Green(0-255), Blue(0-255)}.
                This is always the last thing to be done on a given cube.
]]
