-- Made By O2Flash20 :)

shadingEnabled = false
function enableShading()
    shadingEnabled = true
end

function disableShading()
    shadingEnabled = false
end

-- sets the direction that light is coming from
lightDirection = { 0.195, 0.097, -0.975 }
function setLightDirection(x, y, z)
    local newLightDirection = normalizeVector({ x, y, z })
    lightDirection = newLightDirection
end

function setLightDirectionSun()
    local time = -dimension.time() * 2 * math.pi
    lightDirection = { math.sin(time), math.cos(time), 0 }
end

-- sets how dark the shadow is (0 is black, 1 is no shadow at all)
shadowDarkess = 0.3
function setShadowDarkness(level)
    shadowDarkess = level
end

-- maps a value from one range to another
function map(val, min1, max1, min2, max2)
    return (val - min1) * (max2 - min2) / (max1 - min1) + min2
end

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
    pYaw, pPitch = player.rotation()
    bodyYaw = player.bodyRotation()
    bodyPitch = 0
    headYaw = player.headRotation()
    t = os.clock()

    if player.getFlag(1) then
        py = py - 0.25

        bodyPitch = 30
    end

    local pxint, pyint, pzint = player.position()
    local block, sky = dimension.getBrightness(pxint, pyint, pzint)

    dimensionBrightness = (sky * (2 * math.abs(dimension.time() - 0.5))) / 15
end

-- generates the surface normal of a triangle
function calculateSurfaceNormalTriangle(p1, p2, p3)
    local vectorA = { p2[1] - p1[1], p2[2] - p1[2], p2[3] - p1[3] }
    local vectorB = { p3[1] - p1[1], p3[2] - p1[2], p3[3] - p1[3] }

    local normal = {}

    table.insert(normal, vectorA[2] * vectorB[3] - vectorA[3] * vectorB[2])
    table.insert(normal, vectorA[3] * vectorB[1] - vectorA[1] * vectorB[3])
    table.insert(normal, vectorA[1] * vectorB[2] - vectorA[2] * vectorB[1])

    local length = math.sqrt(normal[1] * normal[1] + normal[2] * normal[2] + normal[3] * normal[3])

    normal[1] = normal[1] / length
    normal[2] = normal[2] / length
    normal[3] = normal[3] / length

    return normal
end

-- gets the dot product of two vectors
function dotProduct3D(vec1, vec2)
    local val = (vec1[1] * vec2[1]) + (vec1[2] * vec2[2]) + (vec1[3] * vec2[3])
    if val > 0 then return val else return 0 end
end

-- makes a given vector's length 1
function normalizeVector(vector)
    local vectorLength = math.sqrt(vector[1] * vector[1] + vector[2] * vector[2] + vector[3] * vector[3])

    return { vector[1] / vectorLength, vector[2] / vectorLength, vector[3] / vectorLength }
end

AnimatedTexture = {}
-- create a new animated texture object
function AnimatedTexture:new(texturesArray, delay)
    local newTexture = {}

    setmetatable(newTexture, self)
    self.__index = self

    newTexture.texNum = 1
    newTexture.delay = delay
    newTexture.texturesArray = texturesArray
    newTexture.texturesArrayLength = #texturesArray
    newTexture.i = 1
    newTexture.texture = texturesArray[1]

    return newTexture
end

-- update the animated texture, goes in update()
function AnimatedTexture:update()
    self.i = (self.i + 1) % self.delay
    if self.i == 0 then
        self.texNum = (self.texNum % self.texturesArrayLength) + 1
        self.texture = self.texturesArray[self.texNum]
    end
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
function Object:attachToHead()
    self.attachPosition = { px, py - 0.2, pz }

    self.attachRotation = { math.rad(pPitch), math.rad(-headYaw), 0 }

    return self
end

function Object:attachToBody()
    self.attachPosition = { px, py - 0.55, pz }
    self.attachRotation = { math.rad(bodyPitch), math.rad(-bodyYaw), 0 }

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

-- renders a cube with a texture on each side. if you want each face to be the same, you may only input one argument
-- scales can be from 0 to 1
function Cube:renderTexture(frontTex, backTex, leftTex, rightTex, topTex, bottomTex, scaleHorizontal, scaleVertical)
    local tF = frontTex
    local tBa = backTex or frontTex
    local tL = leftTex or frontTex
    local tR = rightTex or frontTex
    local tT = topTex or frontTex
    local tBo = bottomTex or frontTex
    local sH = scaleHorizontal or 1
    local sV = scaleVertical or 1

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
        vertices = Cube.rotate3d(vertices,
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
        vertices = Cube.rotate3d(vertices,
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
    vertices = Cube.rotate3d(vertices,
        self.object.attachPosition[1], self.object.attachPosition[2], self.object.attachPosition[3],
        self.object.attachRotation[1], self.object.attachRotation[2], self.object.attachRotation[3]
    )

    gfx.tquad(
        vertices[2][1], vertices[2][2], vertices[2][3], 0, sV,
        vertices[1][1], vertices[1][2], vertices[1][3], sH, sV,
        vertices[3][1], vertices[3][2], vertices[3][3], sH, 0,
        vertices[4][1], vertices[4][2], vertices[4][3], 0, 0,
        tBa
    )
    gfx.tquad(
        vertices[8][1], vertices[8][2], vertices[8][3], sH, 0,
        vertices[7][1], vertices[7][2], vertices[7][3], 0, 0,
        vertices[5][1], vertices[5][2], vertices[5][3], 0, sV,
        vertices[6][1], vertices[6][2], vertices[6][3], sH, sV,
        tF
    )
    gfx.tquad(
        vertices[2][1], vertices[2][2], vertices[2][3], 0, sV,
        vertices[6][1], vertices[6][2], vertices[6][3], sH, sV,
        vertices[5][1], vertices[5][2], vertices[5][3], sH, 0,
        vertices[1][1], vertices[1][2], vertices[1][3], 0, 0,
        tBo
    )
    gfx.tquad(
        vertices[5][1], vertices[5][2], vertices[5][3], sH, sV,
        vertices[7][1], vertices[7][2], vertices[7][3], sH, 0,
        vertices[3][1], vertices[3][2], vertices[3][3], 0, 0,
        vertices[1][1], vertices[1][2], vertices[1][3], 0, sV,
        tR
    )
    gfx.tquad(
        vertices[2][1], vertices[2][2], vertices[2][3], sH, sV,
        vertices[4][1], vertices[4][2], vertices[4][3], sH, 0,
        vertices[8][1], vertices[8][2], vertices[8][3], 0, 0,
        vertices[6][1], vertices[6][2], vertices[6][3], 0, sV,
        tL
    )
    gfx.tquad(
        vertices[7][1], vertices[7][2], vertices[7][3], sH, sV,
        vertices[8][1], vertices[8][2], vertices[8][3], sH, 0,
        vertices[4][1], vertices[4][2], vertices[4][3], 0, 0,
        vertices[3][1], vertices[3][2], vertices[3][3], 0, sV,
        tT
    )
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
        vertices = Cube.rotate3d(vertices,
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
        vertices = Cube.rotate3d(vertices,
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
    vertices = Cube.rotate3d(vertices,
        self.object.attachPosition[1], self.object.attachPosition[2], self.object.attachPosition[3],
        self.object.attachRotation[1], self.object.attachRotation[2], self.object.attachRotation[3]
    )

    -- render all the vertices
    if shadingEnabled then
        gfx.color(color[1], color[2], color[3])

        Cube.renderTriangle(color, vertices[3], vertices[2], vertices[1], lightDirection)
        Cube.renderTriangle(color, vertices[6], vertices[7], vertices[5], lightDirection)

        Cube.renderTriangle(color, vertices[2], vertices[3], vertices[4], lightDirection)
        Cube.renderTriangle(color, vertices[8], vertices[7], vertices[6], lightDirection)

        Cube.renderTriangle(color, vertices[5], vertices[3], vertices[1], lightDirection)
        Cube.renderTriangle(color, vertices[2], vertices[4], vertices[6], lightDirection)

        Cube.renderTriangle(color, vertices[3], vertices[5], vertices[7], lightDirection)
        Cube.renderTriangle(color, vertices[8], vertices[6], vertices[4], lightDirection)

        Cube.renderTriangle(color, vertices[1], vertices[2], vertices[5], lightDirection)
        Cube.renderTriangle(color, vertices[7], vertices[4], vertices[3], lightDirection)

        Cube.renderTriangle(color, vertices[6], vertices[5], vertices[2], lightDirection)
        Cube.renderTriangle(color, vertices[4], vertices[7], vertices[8], lightDirection)
    else
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
end

-- a behind the scenes function used to make rendering a cube's triangle easier
function Cube.renderTriangle(color, vertex1, vertex2, vertex3, lightDirection)
    local normal = calculateSurfaceNormalTriangle(vertex1, vertex2, vertex3)
    local dotProduct = dotProduct3D(normal, lightDirection)

    local darkening = map((dotProduct * dimensionBrightness), 0, 1, shadowDarkess, 1)

    gfx.color(color[1] * darkening, color[2] * darkening, color[3] * darkening)
    triangle3d(vertex1, vertex2, vertex3)
end

-- given the origin and angles, rotates all vertices
function Cube.rotate3d(vertices, originX, originY, originZ, pitch, yaw, roll)
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

Sphere = {}

-- a behind the scenes function used to make rendering a sphere's triangle easier
function Sphere.renderTriangle(triangle, color)
    if not shadingEnabled then
        gfx.color(color[1], color[2], color[3])
    else
        local normal = calculateSurfaceNormalTriangle(triangle[1], triangle[2], triangle[3])
        local dot = dotProduct3D(normal, lightDirection)
        local darkening = map((dot * dimensionBrightness), 0, 1, shadowDarkess, 1)
        gfx.color(
            color[1] * darkening,
            color[2] * darkening,
            color[3] * darkening
        )
    end

    triangle3d(triangle[1], triangle[2], triangle[3])
end

-- a behind the scenes function used to calculate the vertices of a sphere
function Sphere.calculateVertices(detail)
    local vertices = { {}, {}, {}, {}, {}, {} }

    -- face 1 (Z+)
    for y = -detail, detail, 1 do
        table.insert(vertices[1], {})
        for x = detail, -detail, -1 do
            local thisVertexPos = { x / detail, y / detail, 1 }
            thisVertexPos = normalizeVector(thisVertexPos)

            table.insert(vertices[1][y + detail + 1], thisVertexPos)
        end
    end

    -- face 2 (Z-)
    for y = -detail, detail, 1 do
        table.insert(vertices[2], {})
        for x = -detail, detail, 1 do
            local thisVertexPos = { x / detail, y / detail, -1 }
            thisVertexPos = normalizeVector(thisVertexPos)

            table.insert(vertices[2][y + detail + 1], thisVertexPos)
        end
    end

    -- face 3 (Y+)
    for y = -detail, detail, 1 do
        table.insert(vertices[3], {})
        for x = -detail, detail, 1 do
            local thisVertexPos = { x / detail, 1, y / detail }
            thisVertexPos = normalizeVector(thisVertexPos)

            table.insert(vertices[3][y + detail + 1], thisVertexPos)
        end
    end

    -- face 4 (Y-)
    for y = -detail, detail, 1 do
        table.insert(vertices[4], {})
        for x = detail, -detail, -1 do
            local thisVertexPos = { x / detail, -1, y / detail }
            thisVertexPos = normalizeVector(thisVertexPos)

            table.insert(vertices[4][y + detail + 1], thisVertexPos)
        end
    end

    -- face 5 (X+)
    for y = -detail, detail, 1 do
        table.insert(vertices[5], {})
        for x = detail, -detail, -1 do
            local thisVertexPos = { 1, x / detail, y / detail }
            thisVertexPos = normalizeVector(thisVertexPos)

            table.insert(vertices[5][y + detail + 1], thisVertexPos)
        end
    end

    -- face 6 (X-)
    for y = -detail, detail, 1 do
        table.insert(vertices[6], {})
        for x = -detail, detail, 1 do
            local thisVertexPos = { -1, x / detail, y / detail }
            thisVertexPos = normalizeVector(thisVertexPos)

            table.insert(vertices[6][y + detail + 1], thisVertexPos)
        end
    end

    return vertices
end

function Sphere:new(Object, x, y, z, radius)
    local newSphere = {}

    setmetatable(newSphere, self)
    self.__index = self

    newSphere.object = Object

    newSphere.pos = { x, y, z }
    newSphere.radius = radius
    newSphere.detail = 2
    newSphere.stretch = { 1, 1, 1 }
    newSphere.rotationQueue = {}

    return newSphere
end

-- detail levels: "Low", "Normal", "Insane"
function Sphere:setDetail(detail)
    if detail == "Low" then
        self.detail = 1
    end
    if detail == "Normal" then
        self.detail = 2
    end
    if detail == "Insane" then
        self.detail = 5
    end

    return self
end

-- sets the "strech" value of  a sphere to make it an ellipsoid
function Sphere:setStretch(x, y, z)
    self.stretch = { x, y, z }
    return self
end

-- adds a rotation with a custom origin to the queue
function Sphere:rotateCustom(originX, originY, originZ, pitch, yaw, roll)
    local rotationQueue = self.rotationQueue or {}

    table.insert(rotationQueue, { { originX, originY, originZ }, { pitch, yaw, roll } })

    self.rotationQueue = rotationQueue
    return self
end

-- rotates around self
function Sphere:rotateSelf(pitch, yaw, roll)
    self:rotateCustom(self.pos[1], self.pos[2], self.pos[3], pitch, yaw, roll)
    return self
end

-- rotates around its object
function Sphere:rotateObject(pitch, yaw, roll)
    self:rotateCustom(0, 0, 0, pitch, yaw, roll)
    return self
end

-- renders the sphere
function Sphere:render(color)
    local sphereFaces = Sphere.calculateVertices(self.detail)

    -- Doing stuff to each point
    for i = 1, #sphereFaces, 1 do
        for x = 1, #sphereFaces[1][1], 1 do
            for y = 1, #sphereFaces[1], 1 do
                local thisPoint = sphereFaces[i][y][x]

                -- stretch and scale the sphere
                thisPoint[1] = thisPoint[1] * self.stretch[1] * self.radius
                thisPoint[2] = thisPoint[2] * self.stretch[2] * self.radius
                thisPoint[3] = thisPoint[3] * self.stretch[3] * self.radius

                -- move it over to its correct position
                thisPoint[1] = thisPoint[1] + self.pos[1]
                thisPoint[2] = thisPoint[2] + self.pos[2]
                thisPoint[3] = thisPoint[3] + self.pos[3]

                -- go through the sphere's rotation queue to rotates this point
                for j = 1, #self.rotationQueue, 1 do
                    thisPoint = rotatePoint(
                        thisPoint[1], thisPoint[2], thisPoint[3],
                        self.rotationQueue[j][1][1], self.rotationQueue[j][1][2], self.rotationQueue[j][1][3],
                        self.rotationQueue[j][2][1], self.rotationQueue[j][2][2], self.rotationQueue[j][2][3]
                    )
                end

                -- move all the points over to attach to its object
                thisPoint[1] = thisPoint[1] + self.object.pos[1]
                thisPoint[2] = thisPoint[2] + self.object.pos[2]
                thisPoint[3] = thisPoint[3] + self.object.pos[3]

                -- go through it's object's rotation queue
                for j = 1, #self.object.rotationQueue, 1 do
                    thisPoint = rotatePoint(
                        thisPoint[1], thisPoint[2], thisPoint[3],
                        self.object.rotationQueue[j][1][1], self.object.rotationQueue[j][1][2],
                        self.object.rotationQueue[j][1][3],
                        self.object.rotationQueue[j][2][1], self.object.rotationQueue[j][2][2],
                        self.object.rotationQueue[j][2][3]
                    )
                end

                -- move all the points over to attach to its attach point
                thisPoint[1] = thisPoint[1] + self.object.attachPosition[1]
                thisPoint[2] = thisPoint[2] + self.object.attachPosition[2]
                thisPoint[3] = thisPoint[3] + self.object.attachPosition[3]

                -- rotate to meet attachment point
                thisPoint = rotatePoint(
                    thisPoint[1], thisPoint[2], thisPoint[3],
                    self.object.attachPosition[1], self.object.attachPosition[2], self.object.attachPosition[3],
                    self.object.attachRotation[1], self.object.attachRotation[2], self.object.attachRotation[3]
                )

                sphereFaces[i][y][x] = thisPoint
            end
        end
    end

    -- rendering each point
    for i = 1, #sphereFaces, 1 do
        local thisFace = sphereFaces[i]

        for x = 1, #thisFace[1], 1 do
            for y = 1, #thisFace - 1, 1 do
                if x > 1 then
                    local triangle = {
                        { thisFace[y][x][1], thisFace[y][x][2], thisFace[y][x][3] },
                        { thisFace[y + 1][x - 1][1], thisFace[y + 1][x - 1][2], thisFace[y + 1][x - 1][3] },
                        { thisFace[y + 1][x][1], thisFace[y + 1][x][2], thisFace[y + 1][x][3] }
                    }
                    Sphere.renderTriangle(triangle, color)
                end
                if x ~= #thisFace[1] then
                    local triangle = {
                        { thisFace[y + 1][x][1], thisFace[y + 1][x][2], thisFace[y + 1][x][3] },
                        { thisFace[y][x + 1][1], thisFace[y][x + 1][2], thisFace[y][x + 1][3] },
                        { thisFace[y][x][1], thisFace[y][x][2], thisFace[y][x][3] }
                    }
                    Sphere.renderTriangle(triangle, color)
                end
            end
        end

    end
end

-- renders the sphere with a texture
function Sphere:renderTexture(texture)
    local sphereFaces = Sphere.calculateVertices(self.detail)

    -- Doing stuff to each point
    for i = 1, #sphereFaces, 1 do
        for x = 1, #sphereFaces[1][1], 1 do
            for y = 1, #sphereFaces[1], 1 do
                local thisPoint = sphereFaces[i][y][x]

                -- stretch and scale the sphere
                thisPoint[1] = thisPoint[1] * self.stretch[1] * self.radius
                thisPoint[2] = thisPoint[2] * self.stretch[2] * self.radius
                thisPoint[3] = thisPoint[3] * self.stretch[3] * self.radius

                -- move it over to its correct position
                thisPoint[1] = thisPoint[1] + self.pos[1]
                thisPoint[2] = thisPoint[2] + self.pos[2]
                thisPoint[3] = thisPoint[3] + self.pos[3]

                -- go through the sphere's rotation queue to rotates this point
                for j = 1, #self.rotationQueue, 1 do
                    thisPoint = rotatePoint(
                        thisPoint[1], thisPoint[2], thisPoint[3],
                        self.rotationQueue[j][1][1], self.rotationQueue[j][1][2], self.rotationQueue[j][1][3],
                        self.rotationQueue[j][2][1], self.rotationQueue[j][2][2], self.rotationQueue[j][2][3]
                    )
                end

                -- move all the points over to attach to its object
                thisPoint[1] = thisPoint[1] + self.object.pos[1]
                thisPoint[2] = thisPoint[2] + self.object.pos[2]
                thisPoint[3] = thisPoint[3] + self.object.pos[3]

                -- go through it's object's rotation queue
                for j = 1, #self.object.rotationQueue, 1 do
                    thisPoint = rotatePoint(
                        thisPoint[1], thisPoint[2], thisPoint[3],
                        self.object.rotationQueue[j][1][1], self.object.rotationQueue[j][1][2],
                        self.object.rotationQueue[j][1][3],
                        self.object.rotationQueue[j][2][1], self.object.rotationQueue[j][2][2],
                        self.object.rotationQueue[j][2][3]
                    )
                end

                -- move all the points over to attach to its attach point
                thisPoint[1] = thisPoint[1] + self.object.attachPosition[1]
                thisPoint[2] = thisPoint[2] + self.object.attachPosition[2]
                thisPoint[3] = thisPoint[3] + self.object.attachPosition[3]

                -- rotate to meet attachment point
                thisPoint = rotatePoint(
                    thisPoint[1], thisPoint[2], thisPoint[3],
                    self.object.attachPosition[1], self.object.attachPosition[2], self.object.attachPosition[3],
                    self.object.attachRotation[1], self.object.attachRotation[2], self.object.attachRotation[3]
                )

                sphereFaces[i][y][x] = thisPoint
            end
        end
    end

    -- a rational function that tries to correct the uvs on the sphere
    function fixUV(x)
        return (-1.4999 / (x - 1.823)) - 0.823
    end

    -- rendering each point
    for i = 1, #sphereFaces, 1 do
        local thisFace = sphereFaces[i]

        for x = 1, #thisFace[1], 1 do
            for y = 1, #thisFace - 1, 1 do
                if x > 1 then
                    local triangle = {
                        { thisFace[y][x][1], thisFace[y][x][2], thisFace[y][x][3] },
                        { thisFace[y + 1][x - 1][1], thisFace[y + 1][x - 1][2], thisFace[y + 1][x - 1][3] },
                        { thisFace[y + 1][x][1], thisFace[y + 1][x][2], thisFace[y + 1][x][3] }
                    }
                    -- Sphere.renderTriangle(triangle, color)
                    gfx.ttriangle(
                        triangle[1][1], triangle[1][2], triangle[1][3],
                        fixUV(x / #thisFace[1]),
                        fixUV(y / (#thisFace - 1)),

                        triangle[2][1], triangle[2][2], triangle[2][3],
                        fixUV((x - 1) / #thisFace[1]),
                        fixUV((y + 1) / (#thisFace - 1)),

                        triangle[3][1], triangle[3][2], triangle[3][3],
                        fixUV(x / #thisFace[1]),
                        fixUV((y + 1) / (#thisFace - 1)),

                        texture
                    )
                end
                if x ~= #thisFace[1] then
                    local triangle = {
                        { thisFace[y + 1][x][1], thisFace[y + 1][x][2], thisFace[y + 1][x][3] },
                        { thisFace[y][x + 1][1], thisFace[y][x + 1][2], thisFace[y][x + 1][3] },
                        { thisFace[y][x][1], thisFace[y][x][2], thisFace[y][x][3] }
                    }
                    -- Sphere.renderTriangle(triangle, color)
                    gfx.ttriangle(
                        triangle[1][1], triangle[1][2], triangle[1][3],
                        fixUV(x / #thisFace[1]),
                        fixUV((y + 1) / (#thisFace - 1)),

                        triangle[2][1], triangle[2][2], triangle[2][3],
                        fixUV((x + 1) / #thisFace[1]),
                        fixUV(y / (#thisFace - 1)),

                        triangle[3][1], triangle[3][2], triangle[3][3],
                        fixUV(x / #thisFace[1]),
                        fixUV(y / (#thisFace - 1)),

                        texture
                    )
                end
            end
        end

    end
end

--[[
    DOCUMENTATION:

    updateCosmeticTools()
        Updates the player's positions and rotations to be used by other functions. For the best result, run this function at the start of render3d()
        This makes a few variables global:
            px, py, pz: Player position.
            pPitch, pYaw: Player/head pitch and yaw.
            bodyYaw: The player's torso's yaw.
            bodyPitch: The player's torso's pitch.
            headYaw: The yaw of the player's head.
            dimensionBrightness: The sky's brighness (taking into account the time of day) at the player's position.

            t: The time in seconds that the mod has been running. Usually used in animations.

    enableShading()
        Enables shading mode, hits fps hard but looks amazing.
    disableShading()
        Disables shading mode.

    setLightDirection(x, y, z)
        Sets the direction that the light is coming from (used only when shading is enabled).
        This direction becomes a normalized vector, which might be counter-intuitive if you're not used to working with them:
            setLightDirection(1, 2, 0) means that the light is coming 1/3 from the +x direction and 2/3 from the +y direction
            The light does not have a position, you can never get closer or further from it, hence why **setLightDirection(1, 0, 0) is the same thing as setLightDirection(9999, 0, 0)**

    setLightDirectionSun()
        Sets the direction that the light is coming from to the direction of the sun, making it look more realistic.

    setShadowDarkness(level)
        Sets how dark the shadow is (0 is black, 1 is no shadow at all)

    map(val, min1, max1, min2, max2)
        A math function that brings a value "val" from the range of min1->max1 into the range of min2->max2

    rotatePoint(x, y, z, originX, originY, originZ, pitch, yaw, roll)
        Rotates a point in 3d space.


    Animated Textures:
        Textures on objects can be animated using Animated Textures. Essentially, different images are cycled through on the object with a given delay.

            local Your_Texture = AnimatedTexture:new(texturesArray, delay)
                Sets up a new animated texture, stored in a variable of your choice.
                texturesArray is a table with the textures that you want to use in the order you want.
                delay is how often the texture changes
            Your_Texture:update()
                Updates the animated texture. The animation won't work without this. *Put it in the update() function.*

            Your_Texture.texture
                How you get the current texture out of the AnimatedTexture. For example, :renderTexture(Your_Texture.texture)


    Object:
        An object is a collection of 3d shapes which attaches to a specified body part. Anything done to an Object is also done to all the shapes it includes.

            local Your_Object = Object:new(x, y, z)
                Returns a new Object with position {x, y, z}

            :attachToHead()
                Attaches this object to the player's head
            :attachToBody()
                Attaches this object to the player's body
            :attachToPlayer()
                Attaches this object to the player's position. It does not rotate with the player.
            :attachNone()
                Does not attach the object to the player, the object's position becomes world coordinates

            :rotateCustom(originX, originY, originZ, pitch, yaw, roll)
                Rotates the object around a custom origin point with a specified pitch, yaw, and roll. Note that the origin is relative to the player and is not world coordinates.
            :rotateSelf(pitch, yaw, roll)
                Rotates the object around itself with a specified pitch, yaw, and roll.
            :rotateAttachment(pitch, yaw, roll)
                Rotates the object around the body part that it's attached to with a specified pitch, yaw, and roll.


    Cube:
        A 3d object with a position, width, height, and depth that gets attached to an Object.

            local Your_Cube = Cube:new(Object, x, y, z, width, height, depth)
                Creates a new Cube that is attached to the specified object. It has a position {x, y, z} (relative to the object it's attached to) and has a specified width, height, and depth.

            :rotateCustom(originX, originY, originZ, pitch, yaw, roll)
                Rotates the cube around a custom origin point with a specified pitch, yaw, and roll. Note that the origin is relative to the object it's attached to.
            :rotateSelf(pitch, yaw, roll)
                Rotates the cube around itself with a specified pitch, yaw, and roll.
            :rotateObject(pitch, yaw, roll)
                Rotates the cube around the object that it's attached to with a specified pitch, yaw, and roll.


            RENDER OPTIONS *one of these should be the last thing you do to a given Cube*

            :render(color)
                Renders the cube into the world with a specified color. The color parameter should be {Red(0-255), Green(0-255), Blue(0-255)}.

            :renderTexture(frontTex, backTex, leftTex, rightTex, topTex, bottomTex, scaleHorizontal, scaleVertical)
                Renders the cube into the world with specified textures on each side.
                frontTex, backTex, leftTex, rightTex, topTex, bottomTex can be strings to a texture file or an AnimatedTexture. If one is not defined, it will default to whatever frontTex is
                scaleHorizontal and scaleVertical are controls to scale the textures on the cube. These values can be in the range (0-1) with 0 making the texture stretched and 1 being the default value.
                :renderTexture("textures/blocks/planks_oak") is valid. It will make all sides the oak planks texture and both the horizontal and verticle scales will be 1. 


    Sphere:
        A 3d object with a position and radius that gets attached to an Object.

            local Your_Sphere = Sphere:new(Object, x, y, z, radius)
                Creates a new Sphere that is attached to the specified object. It has a position {x, y, z} (relative to the object it's attached to) and has a specified radius.
            :setDetail("Low" | "Normal" | "Insane")
                Sets the detail level of the Sphere. If detail is not specified, it will default to Normal.
                Low detail looks bad but is great for performance, Normal detail is a mix of performance and smoothness, and Insane is terrible for performance but looks very smooth.
            :setStretch(x, y, z)
                Stretches the Sphere to make it an ellipsoid. 
                For example:
                    setStretch(1, 1, 1) is a perfect sphere
                    setStretch(1, 2, 1) is a sphere stretched vertically
                    setStretch(0.5, 1, 1) is a sphere that is compressed on the x-axis

            :rotateCustom(originX, originY, originZ, pitch, yaw, roll)
                Rotates the sphere around a custom origin point with a specified pitch, yaw, and roll. Note that the origin is relative to the object it's attached to.
            :rotateSelf(pitch, yaw, roll)
                Rotates the sphere around itself with a specified pitch, yaw, and roll.
            :rotateObject(pitch, yaw, roll)
                Rotates the sphere around the object that it's attached to with a specified pitch, yaw, and roll.


            RENDER OPTIONS *one of these should be the last thing you do to a given Sphere*

            :render(color)
                Renders the sphere into the world with a specified color. The color parameter should be {Red(0-255), Green(0-255), Blue(0-255)}.

            :renderTexture(texture)
                Renders the sphere into the world with a specified texture. This texture can be a string to a texture file or an AnimatedTexture.
]]
