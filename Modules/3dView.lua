name = "ThreeD View"
description = "Shows a 3D view of the blocks around you."

positionX = 50
positionY = 100
sizeX = 200
sizeY = 200

importLib("logger")
importLib("MinimapBlockTools")

-- puts the points of a quad in correct order to render
function smartQuad(x1, y1, x2, y2, x3, y3, x4, y4)
    -- top left, bottom left, bottom right, top right

    local coord1 = {}
    local coord2 = {}
    local coord3 = {}
    local coord4 = {}

    local xCoords = { x1, x2, x3, x4 }
    local yCoords = { y1, y2, y3, y4 }

    local mostTop = 10000
    local mostTopI = -1

    local secondMostTop = 10000
    local secondMostTopI = -1

    for i = 1, 4, 1 do
        if yCoords[i] < mostTop then
            secondMostTop = mostTop
            secondMostTopI = mostTopI

            mostTop = yCoords[i]
            mostTopI = i
        else
            if yCoords[i] < secondMostTop then
                secondMostTop = yCoords[i]
                secondMostTopI = i
            end
        end
    end

    if xCoords[mostTopI] < xCoords[secondMostTopI] then
        -- it's top, but is it left? If so it's 1, else it's 4
        coord1 = { xCoords[mostTopI], yCoords[mostTopI] }
        coord4 = { xCoords[secondMostTopI], yCoords[secondMostTopI] }
    else
        coord1 = { xCoords[secondMostTopI], yCoords[secondMostTopI] }
        coord4 = { xCoords[mostTopI], yCoords[mostTopI] }
    end

    local firstBottomPointFound
    local firstBottomPointFoundI
    for i = 1, 4, 1 do
        if i ~= mostTopI and i ~= secondMostTopI then
            if firstBottomPointFound == nil then
                firstBottomPointFound = xCoords[i]
                firstBottomPointFoundI = i
            else
                if xCoords[i] < firstBottomPointFound then
                    coord2 = { xCoords[i], yCoords[i] }
                    coord3 = { xCoords[firstBottomPointFoundI], yCoords[firstBottomPointFoundI] }
                else
                    coord2 = { xCoords[firstBottomPointFoundI], yCoords[firstBottomPointFoundI] }
                    coord3 = { xCoords[i], yCoords[i] }
                end
            end
        end
    end

    gfx.quad(coord1[1], coord1[2], coord2[1], coord2[2], coord3[1], coord3[2], coord4[1], coord4[2])
end

-- projects a 3d point to 2d
function projectPoint(x, y, z)
    local newX = x * (-1 / z)
    local newY = y * (-1 / z)

    -- go from normalized to space of the module
    newX = newX * sizeX + sizeX / 2
    newY = newY * sizeY + sizeY / 2

    return { newX, newY }
end

-- draws a quad (turns 3d coords to 2d and renders)
function projectQuad(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
    local p1 = projectPoint(x1, y1, z1)
    local p2 = projectPoint(x2, y2, z2)
    local p3 = projectPoint(x3, y3, z3)
    local p4 = projectPoint(x4, y4, z4)

    smartQuad(p1[1], p1[2], p2[1], p2[2], p3[1], p3[2], p4[1], p4[2])
end

-- inputs the 4 points of a quad and returns the average dist to the camera
function getDistSquaredToQuad(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
    local xAvg = (x1 + x2 + x3 + x4) / 4
    local yAvg = (y1 + y2 + y3 + y4) / 4
    local zAvg = (z1 + z2 + z3 + z4) / 4

    return xAvg * xAvg + yAvg * yAvg + zAvg * zAvg
end

-- takes in an array of values and returns the indices corresponding to the values smallest -> largest
function insertionSort(arr)
    local len = #arr

    local indices = {}
    for i = 1, len, 1 do
        table.insert(indices, i)
    end

    local index = 2
    while index <= len do
        local curr = arr[index]
        local currI = indices[index]
        local prev = index - 1

        while prev >= 1 and arr[prev] > curr do
            arr[prev + 1] = arr[prev]
            indices[prev + 1] = indices[prev] --
            prev = prev - 1
        end

        arr[prev + 1] = curr
        indices[prev + 1] = currI --

        index = index + 1
    end

    return indices
end

-- takes in the 8 points of a cube in correct render order and renders its quads
function projectCube(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, x5, y5, z5, x6, y6, z6, x7, y7, z7, x8, y8, z8,
                     color)
    -- top, front, back, left, right, bottom
    -- parameters 1-4: top face
    -- parameters 5-8: bottom face
    -- parameters 1/2, 5/6: front face
    -- parameters 3/4, 7/8: back face
    -- parameters 1/3, 5/7: left face
    -- parameters 2/4, 6,8: right face

    -- get the 3d middle of a quad and render then furthest ones first

    local faces = {
        -- top
        { x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4 },
        -- front
        { x1, y1, z1, x2, y2, z2, x5, y5, z5, x6, y6, z6 },
        -- back
        { x3, y3, z3, x4, y4, z4, x7, y7, z7, x8, y8, z8 },
        -- left
        { x1, y1, z1, x3, y3, z3, x5, y5, z5, x7, y7, z7 },
        -- right
        { x2, y2, z2, x4, y4, z4, x6, y6, z6, x8, y8, z8 },
        -- bottom
        { x5, y5, z5, x6, y6, z6, x7, y7, z7, x8, y8, z8 }
    }

    local topDist = getDistSquaredToQuad(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
    local frontDist = getDistSquaredToQuad(x1, y1, z1, x2, y2, z2, x5, y5, z5, x6, y6, z6)
    local backDist = getDistSquaredToQuad(x3, y3, z3, x4, y4, z4, x7, y7, z7, x8, y8, z8)
    local leftDist = getDistSquaredToQuad(x1, y1, z1, x3, y3, z3, x5, y5, z5, x7, y7, z7)
    local rightDist = getDistSquaredToQuad(x2, y2, z2, x4, y4, z4, x6, y6, z6, x8, y8, z8)
    local bottomDist = getDistSquaredToQuad(x5, y5, z5, x6, y6, z6, x7, y7, z7, x8, y8, z8)

    local dists = { topDist, frontDist, backDist, leftDist, rightDist, bottomDist }
    dists = insertionSort(dists)

    for i = #dists, 1, -1 do
        local faceNum = dists[i]
        local face = faces[faceNum]

        -- different faces are darkened differently so that the individual faces are easier to see
        local faceColorOffsets = { 1, 0.8, 0.8, 0.7, 0.7, 1 }
        local thisColorOffset = faceColorOffsets[faceNum]

        gfx.color(color[1] * thisColorOffset, color[2] * thisColorOffset, color[3] * thisColorOffset)
        -- gfx.color(thisColorOffset[1], thisColorOffset[2], thisColorOffset[3])

        projectQuad(face[1], face[2], face[3], face[4], face[5], face[6], face[7], face[8], face[9], face[10], face[11],
            face[12])
    end
end

-- uses x, y, z and width, height, depth and converts them to the 8 points (in corect render order)
function getCubePoints(x, y, z, width, height, depth)
    local top = { x, y + height, z, x + width, y + height, z, x, y + height, z + depth, x + width, y + height, z + depth }
    -- local front = { x, y + height, z, x + width, y + height, z, x, y, z, x + width, y, z }
    -- local back = { x, y + height, z + depth, x + width, y + height, z + depth, x, y, z + depth, x + width, y, z + depth }
    -- local left = { x, y + height, z, x, y + height, z + depth, x, y, z, x, y, z + depth }
    -- local right = { x + width, y + height, z, x + width, y + height, z + depth, x + width, y, z, x + width, y, z + depth }
    local bottom = { x, y, z, x + width, y, z, x, y, z + depth, x + width, y, z + depth }

    -- projectCube(top[1], top[2], top[3], top[4], top[5], top[6], top[7], top[8], top[9], top[10], top[11], top[12],
    --     bottom[1], bottom[2], bottom[3], bottom[4], bottom[5], bottom[6], bottom[7], bottom[8], bottom[9], bottom[10],
    --     bottom[11], bottom[12])

    return top[1], top[2], top[3], top[4], top[5], top[6], top[7], top[8], top[9], top[10], top[11], top[12],
        bottom[1], bottom[2], bottom[3], bottom[4], bottom[5], bottom[6], bottom[7], bottom[8], bottom[9], bottom[10],
        bottom[11], bottom[12]
end

-- inputs the an array of all the points of all the cubes and outputs the order at which to render them
function sortCubes(arr)
    -- for each of the 8 entries of arr, average all their points to get the center point
    -- get an array of the 8 distances (one for each vertex)
    -- sort the array to get the indices which correspond to the largest dist -> smallest
    -- return the above array

    -- arr has *the amount of cubes* entries, each of those has 24 entries (8 xyz triplets)
    -- x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, x5, y5, z5, x6, y6, z6, x7, y7, z7, x8, y8, z8

    -- *the amount of cubes* entries, each the dist of that cube (unordered for now)
    local dists = {}

    for i = 1, #arr, 1 do
        local avgX = (arr[i][1] + arr[i][4] + arr[i][7] + arr[i][10] + arr[i][13] + arr[i][16] + arr[i][19] + arr[i][22]
            ) / 8
        local avgY = (arr[i][2] + arr[i][5] + arr[i][8] + arr[i][11] + arr[i][14] + arr[i][17] + arr[i][20] + arr[i][23]
            ) / 8
        local avgZ = (arr[i][3] + arr[i][6] + arr[i][9] + arr[i][12] + arr[i][15] + arr[i][18] + arr[i][21] + arr[i][24]
            ) / 8

        table.insert(dists, avgX * avgX + avgY * avgY + avgZ * avgZ)
    end

    return insertionSort(dists)
end

-- rotates a 2d point around an origin
function rotatePoint(posX, posY, originX, originY, angle)
    local pX = posX - originX
    local pY = posY - originY
    local hypotenuse = math.sqrt(pX * pX + pY * pY)

    local a = math.atan(pY, pX)

    a = a + angle
    pX = math.sin(a) * hypotenuse
    pY = math.cos(a) * hypotenuse

    pX = pX + originX
    pY = pY + originY

    return pX, pY
end

function rotatePoint1(posX, posY, posZ, originX, originY, originZ, yaw, pitch)
    local px = posX - originX
    local py = posY - originY
    local pz = posZ - originZ

    local xzLen = math.cos(pitch)

    local distToOriginXZ = math.sqrt(px * px + pz * pz)

    local aYaw = math.atan(pz, px)
    aYaw = aYaw + yaw

    px = math.sin(aYaw) * distToOriginXZ
    pz = math.cos(aYaw) * distToOriginXZ

    -- local hyp = math.sqrt(distToOriginXZ * distToOriginXZ + py * py)
    -- local aPitch = math.atan(py, distToOriginXZ)
    -- aPitch = aPitch + pitch
    -- py = math.sin(aPitch) * hyp
    -- py = py + (px / 5)

    px = px + originX
    py = py + originY
    pz = pz + originZ

    return px, py, pz
end

-- rotates all the points of a cube
function rotateCube(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, x5, y5, z5, x6, y6, z6, x7, y7, z7, x8, y8, z8,
                    originX, originY, originZ, yaw, pitch)
    local rX1, rY1, rZ1 = rotatePoint1(x1, y1, z1, originX, originY, originZ, yaw, pitch)
    local rX2, rY2, rZ2 = rotatePoint1(x2, y2, z2, originX, originY, originZ, yaw, pitch)
    local rX3, rY3, rZ3 = rotatePoint1(x3, y3, z3, originX, originY, originZ, yaw, pitch)
    local rX4, rY4, rZ4 = rotatePoint1(x4, y4, z4, originX, originY, originZ, yaw, pitch)
    local rX5, rY5, rZ5 = rotatePoint1(x5, y5, z5, originX, originY, originZ, yaw, pitch)
    local rX6, rY6, rZ6 = rotatePoint1(x6, y6, z6, originX, originY, originZ, yaw, pitch)
    local rX7, rY7, rZ7 = rotatePoint1(x7, y7, z7, originX, originY, originZ, yaw, pitch)
    local rX8, rY8, rZ8 = rotatePoint1(x8, y8, z8, originX, originY, originZ, yaw, pitch)

    return { rX1, rY1, rZ1, rX2, rY2, rZ2, rX3, rY3, rZ3, rX4, rY4, rZ4, rX5, rY5, rZ5, rX6, rY6, rZ6, rX7, rY7, rZ7, rX8,
        rY8, rZ8 }
end

-- returns a color given a block
function getColor(block)
    return getMapColorId(block.id, block.data)
end

function blockIsTransparent(block)
    local transparentBlocks = { "air", "yellow_flower", "red_flower", "barrier", "glass", "stained_glass",
        "amethyst_cluster", "large_amethyst_bud", "medium_amethyst_bud", "small_amethyst_bud", "bamboo", "candle",
        "carpet", "glass_pane",
        "stained_glass_pane", "ladder", "reeds", "waterlily", "moss_carpet", "snow_layer", "banner", "cave_vines", "vine",
        "tallgrass", "double_plant", "brown_mushroom", "red_mushroom", "torch", "chest" }

    for i = 1, #transparentBlocks, 1 do
        if block.name == transparentBlocks[i] then
            return true
        end
    end
    return false
end

-- takes in a radius and outputs the cubes and colors arrays for rendering
function getCubesFromWorld(radius)
    local px, py, pz = player.position()
    local cubes = {}
    local colors = {}

    for x = -radius, radius, 1 do
        for y = -radius, radius, 1 do
            for z = -radius, radius, 1 do
                local block = dimension.getBlock(px + x, py + y, pz + z)

                if blockIsTransparent(block) == false then
                    -- is on border
                    if x == -radius or x == radius or y == -radius or y == radius or z == -radius or z == radius then
                        table.insert(cubes, { getCubePoints(x, y - 5, z + 40, 1, 1, 1) })
                        table.insert(colors, getColor(block))

                        -- not on border, check if visible anyways
                    else if blockIsTransparent(dimension.getBlock(px + x + 1, py + y, pz + z)) or
                            blockIsTransparent(dimension.getBlock(px + x - 1, py + y, pz + z)) or
                            blockIsTransparent(dimension.getBlock(px + x, py + y + 1, pz + z)) or
                            blockIsTransparent(dimension.getBlock(px + x, py + y - 1, pz + z)) or
                            blockIsTransparent(dimension.getBlock(px + x, py + y, pz + z + 1)) or
                            blockIsTransparent(dimension.getBlock(px + x, py + y, pz + z - 1))
                        then
                            table.insert(cubes, { getCubePoints(x, y - 5, z + 40, 1, 1, 1) })
                            table.insert(colors, getColor(block))
                        end
                    end
                end
            end
        end
    end

    return cubes, colors
end

local iterations = 0
function render(dt)
    UpdateMapTools()

    -- gfx.color(51, 51, 51, 120)
    -- gfx.rect(0, 0, sizeX, sizeY)

    local px, py, pz = player.pposition()

    -- adding in all the cubes
    local cubes, colors = getCubesFromWorld(4)

    local originX = 0
    local originY = 0
    local originZ = 40
    local yaw = iterations / 20
    local pitch = math.rad(iterations)

    for i = 1, #cubes, 1 do
        local c = cubes[i]
        cubes[i] = rotateCube(c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9], c[10], c[11], c[12], c[13], c[14],
            c[15],
            c[16], c[17], c[18], c[19], c[20], c[21], c[22], c[23], c[24], originX, originY, originZ, yaw, pitch)
    end

    -- rendering the cubes the right way around
    local renderOrder = sortCubes(cubes)
    for i = #renderOrder, 1, -1 do
        local c = cubes[renderOrder[i]]
        local color = colors[renderOrder[i]]
        projectCube(c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9], c[10], c[11], c[12], c[13], c[14], c[15],
            c[16], c[17], c[18], c[19], c[20], c[21], c[22], c[23], c[24], color)
    end

    iterations = iterations + 1
end

function update()

end
