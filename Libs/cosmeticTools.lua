-- Made By O2Flash20

-- like gfx.triangle but takes in the points as tables {x, y, z}
function triangle3d(p1, p2, p3)
    gfx.triangle(p1[1], p1[2], p1[3], p2[1], p2[2], p2[3], p3[1], p3[2], p3[3])
end

--! turns dimension of a prism into points
function getPrism3d(x, y, z, width, height, depth)
    local prismPoints = {}

    local hW = width / 2
    local hH = height / 2
    local hD = depth / 2

    table.insert(prismPoints, { x - hW, y - hH, z - hD })
    table.insert(prismPoints, { x + hW, y - hH, z - hD })
    table.insert(prismPoints, { x - hW, y + hH, z - hD })
    table.insert(prismPoints, { x + hW, y + hH, z - hD })
    table.insert(prismPoints, { x - hW, y - hH, z + hD })
    table.insert(prismPoints, { x + hW, y - hH, z + hD })
    table.insert(prismPoints, { x - hW, y + hH, z + hD })
    table.insert(prismPoints, { x + hW, y + hH, z + hD })

    return prismPoints
end

-- !rotates a prism, given all it's points
function rotatePrism(prism, originX, originY, originZ, pitch, yaw)
    local output = {}
    for i = 1, #prism, 1 do
        local newPoint = rotatePoint(prism[i][1], prism[i][2], prism[i][3], originX, originY, originZ, pitch, yaw)
        table.insert(output, newPoint)
    end

    return output
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

--! renders the prism array using triangles
function renderPrism(prism)
    triangle3d(prism[3], prism[2], prism[1])
    triangle3d(prism[6], prism[7], prism[5])

    triangle3d(prism[2], prism[3], prism[4])
    triangle3d(prism[8], prism[7], prism[6])

    triangle3d(prism[5], prism[3], prism[1])
    triangle3d(prism[2], prism[4], prism[6])

    triangle3d(prism[3], prism[5], prism[7])
    triangle3d(prism[8], prism[6], prism[4])

    triangle3d(prism[1], prism[2], prism[5])
    triangle3d(prism[7], prism[4], prism[3])

    triangle3d(prism[6], prism[5], prism[2])
    triangle3d(prism[4], prism[7], prism[8])
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

    -- CALCULATE ALL IT'S VERTEX POSITIONS
    local cubeVertices = {}

    local hW = width / 2
    local hH = height / 2
    local hD = depth / 2

    table.insert(cubeVertices, { x - hW, y - hH, z - hD })
    table.insert(cubeVertices, { x + hW, y - hH, z - hD })
    table.insert(cubeVertices, { x - hW, y + hH, z - hD })
    table.insert(cubeVertices, { x + hW, y + hH, z - hD })
    table.insert(cubeVertices, { x - hW, y - hH, z + hD })
    table.insert(cubeVertices, { x + hW, y - hH, z + hD })
    table.insert(cubeVertices, { x - hW, y + hH, z + hD })
    table.insert(cubeVertices, { x + hW, y + hH, z + hD })

    newCube.vertices = cubeVertices
    newCube.pos = { x, y, z }
    --

    setmetatable(newCube, self)
    self.__index = self

    return newCube
end

function Cube:render()
    local vertices = self.vertices

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
    a = new Object()

    3d object class
        vertices (all of its points)
        position

        attachToHead()

    A GENERAL SHAPE CLASS THAT ALL SHAPES INHERIT FROM
        INCLUDE ROTATION AND OTHER COMMON OPERATIONS
]]
