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

-- ! takes in the 8 points of a cube in correct render order and renders its quads
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

        projectQuad(face[1], face[2], face[3], face[4], face[5], face[6], face[7], face[8], face[9], face[10], face[11],
            face[12])
    end
end

-- ! uses x, y, z and width, height, depth and converts them to the 8 points (in corect render order)
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

-- ! inputs the an array of all the points of all the cubes and outputs the order at which to render them
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
function rotatePoint(posX, posZ, originX, originZ, angle)
    local pX = posX - originX
    local pY = posZ - originZ
    local hypotenuse = math.sqrt(pX * pX + pY * pY)

    local a = math.atan(pY, pX)

    a = a + angle
    pX = math.sin(a) * hypotenuse
    pY = math.cos(a) * hypotenuse

    pX = pX + originX
    pY = pY + originZ

    return pX, pY
end

-- ! rotates all the points of a cube
function rotateCube(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4, x5, y5, z5, x6, y6, z6, x7, y7, z7, x8, y8, z8,
                    originX, originZ, yaw)
    local rX1, rZ1 = rotatePoint(x1, z1, originX, originZ, yaw)
    local rX2, rZ2 = rotatePoint(x2, z2, originX, originZ, yaw)
    local rX3, rZ3 = rotatePoint(x3, z3, originX, originZ, yaw)
    local rX4, rZ4 = rotatePoint(x4, z4, originX, originZ, yaw)
    local rX5, rZ5 = rotatePoint(x5, z5, originX, originZ, yaw)
    local rX6, rZ6 = rotatePoint(x6, z6, originX, originZ, yaw)
    local rX7, rZ7 = rotatePoint(x7, z7, originX, originZ, yaw)
    local rX8, rZ8 = rotatePoint(x8, z8, originX, originZ, yaw)

    return { rX1, y1, rZ1, rX2, y2, rZ2, rX3, y3, rZ3, rX4, y4, rZ4, rX5, y5, rZ5, rX6, y6, rZ6, rX7, y7, rZ7, rX8,
        y8, rZ8 }
end

-- returns a color given a block
function getColor(block)
    return getMapColorId(block.id, block.data)
end

-- returns true if the block is transparent
function blockIsTransparent(block)
    local transparentBlocks = { "air", "yellow_flower", "red_flower", "barrier", "glass", "stained_glass",
        "amethyst_cluster", "large_amethyst_bud", "medium_amethyst_bud", "small_amethyst_bud", "bamboo", "candle",
        "carpet", "glass_pane",
        "stained_glass_pane", "ladder", "reeds", "waterlily", "moss_carpet", "snow_layer", "banner", "cave_vines", "vine",
        "tallgrass", "double_plant", "brown_mushroom", "red_mushroom", "torch", "chest", "melon_stem", "wheat",
        "brewing_stand", "wall_banner", "standing_banner", "bed", "rail", "chain", "pointed_dripstone" }

    for i = 1, #transparentBlocks, 1 do
        if block.name == transparentBlocks[i] then
            return true
        end
    end
    return false
end

-- ! takes in a radius and outputs the cubes and colors arrays for rendering
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

-- scans the entire area in minecraft and returns 1 if there's a solid block there, to get a coord out of it, do ([x+radius+1][y+radius+1][z+radius+1]) because the array starts at (0, 0, 0) and not -radius
function getBlocksGrid(radius)
    local arr = {}
    local px, py, pz = player.position()

    for x = -radius, radius, 1 do
        table.insert(arr, {})
        for y = -radius, radius, 1 do
            table.insert(arr[x + radius + 1], {})
            for z = -radius, radius, 1 do
                table.insert(arr[x + radius + 1][y + radius + 1], {})

                local block = dimension.getBlock(px + x, py + y, pz + z)
                if blockIsTransparent(block) then
                    arr[x + radius + 1][y + radius + 1][z + radius + 1] = 0
                else
                    arr[x + radius + 1][y + radius + 1][z + radius + 1] = 1
                end
            end
        end
    end

    return arr
end

-- returns the visible faces of a block and their color
-- adds 40 to each z value returned so that the scene can be away from the camera
local distAway = 40
function getBlockVisibleFaces(x, y, z, grid)
    local gridRadius = (#grid - 1) / 2

    local faces = {}
    local facesColors = {}
    local normals = {}

    -- no block there, return nothing
    if grid[x + gridRadius + 1][y + gridRadius + 1][z + gridRadius + 1] == 0 then
        return {}, {}, {}
    end

    local px, py, pz = player.position()
    local thisColor = getColor(dimension.getBlock(px + x, py + y, pz + z))

    -- if the block is on the border, return the face on the border, if not but the face is exposed to air, still return that face
    if x == -gridRadius then
        table.insert(faces,
            {
                { x, y, z + distAway },
                { x, y + 1, z + distAway },
                { x, y, z + 1 + distAway },
                { x, y + 1, z + 1 + distAway }
            })
        table.insert(facesColors, thisColor)
        table.insert(normals, { -1, 0, 0 })

    elseif grid[x + gridRadius + 1 - 1][y + gridRadius + 1][z + gridRadius + 1] == 0 then
        table.insert(faces,
            {
                { x, y, z + distAway },
                { x, y + 1, z + distAway },
                { x, y, z + 1 + distAway },
                { x, y + 1, z + 1 + distAway }
            })
        table.insert(facesColors, thisColor)
        table.insert(normals, { -1, 0, 0 })
    end


    if x == gridRadius then
        table.insert(faces,
            {
                { x + 1, y, z + distAway },
                { x + 1, y + 1, z + distAway },
                { x + 1, y, z + 1 + distAway },
                { x + 1, y + 1, z + 1 + distAway }
            })
        table.insert(facesColors, thisColor)
        table.insert(normals, { 1, 0, 0 })

    elseif grid[x + gridRadius + 1 + 1][y + gridRadius + 1][z + gridRadius + 1] == 0 then
        table.insert(faces,
            {
                { x + 1, y, z + distAway },
                { x + 1, y + 1, z + distAway },
                { x + 1, y, z + 1 + distAway },
                { x + 1, y + 1, z + 1 + distAway }
            })
        table.insert(facesColors, thisColor)
        table.insert(normals, { 1, 0, 0 })
    end


    if y == -gridRadius then
        table.insert(faces,
            {
                { x, y, z + distAway },
                { x + 1, y, z + distAway },
                { x, y, z + 1 + distAway },
                { x + 1, y, z + 1 + distAway }
            })
        table.insert(facesColors, thisColor)
        table.insert(normals, { 0, -1, 0 })

    elseif grid[x + gridRadius + 1][y + gridRadius + 1 - 1][z + gridRadius + 1] == 0 then
        table.insert(faces,
            {
                { x, y, z + distAway },
                { x + 1, y, z + distAway },
                { x, y, z + 1 + distAway },
                { x + 1, y, z + 1 + distAway }
            })
        table.insert(facesColors, thisColor)
        table.insert(normals, { 0, -1, 0 })
    end


    if y == gridRadius then
        table.insert(faces,
            {
                { x, y + 1, z + distAway },
                { x + 1, y + 1, z + distAway },
                { x, y + 1, z + 1 + distAway },
                { x + 1, y + 1, z + 1 + distAway }
            })
        table.insert(facesColors, thisColor)
        table.insert(normals, { 0, 1, 0 })

    elseif grid[x + gridRadius + 1][y + gridRadius + 1 + 1][z + gridRadius + 1] == 0 then
        table.insert(faces,
            {
                { x, y + 1, z + distAway },
                { x + 1, y + 1, z + distAway },
                { x, y + 1, z + 1 + distAway },
                { x + 1, y + 1, z + 1 + distAway }
            })
        table.insert(facesColors, thisColor)
        table.insert(normals, { 0, 1, 0 })
    end


    if z == -gridRadius then
        table.insert(faces,
            {
                { x, y, z + distAway },
                { x + 1, y, z + distAway },
                { x + 1, y + 1, z + distAway },
                { x, y + 1, z + distAway }
            })
        table.insert(facesColors, thisColor)
        table.insert(normals, { 0, 0, -1 })

    elseif grid[x + gridRadius + 1][y + gridRadius + 1][z + gridRadius + 1 - 1] == 0 then
        table.insert(faces,
            {
                { x, y, z + distAway },
                { x + 1, y, z + distAway },
                { x + 1, y + 1, z + distAway },
                { x, y + 1, z + distAway }
            })
        table.insert(facesColors, thisColor)
        table.insert(normals, { 0, 0, -1 })
    end


    if z == gridRadius then
        table.insert(faces,
            {
                { x, y, z + 1 + distAway },
                { x + 1, y, z + 1 + distAway },
                { x + 1, y + 1, z + 1 + distAway },
                { x, y + 1, z + 1 + distAway }
            })
        table.insert(facesColors, thisColor)
        table.insert(normals, { 0, 0, 1 })

    elseif grid[x + gridRadius + 1][y + gridRadius + 1][z + gridRadius + 1 - 1] == 0 then
        table.insert(faces,
            {
                { x, y, z + 1 + distAway },
                { x + 1, y, z + 1 + distAway },
                { x + 1, y + 1, z + 1 + distAway },
                { x, y + 1, z + 1 + distAway }
            })
        table.insert(facesColors, thisColor)
        table.insert(normals, { 0, 0, 1 })
    end

    return faces, facesColors, normals
end

-- rotates every face face in the array
function rotateAllFaces(facesArray, originX, originZ, angle)
    local output = {}
    for i = 1, #facesArray, 1 do
        table.insert(output, {})
        for pointNum = 1, 4, 1 do
            local p = facesArray[i][pointNum]

            local newX, newY = rotatePoint(p[1], p[3], originX, originZ, angle)
            table.insert(output[i], { newX, p[2], newY })
        end
    end
    return output
end

-- rotates all the normals in an array
function rotateAllNormals(normalsArray, angle)
    local output = {}
    for i = 1, #normalsArray, 1 do
        local newX, newZ = rotatePoint(normalsArray[i][1], normalsArray[i][3], 0, 0, angle)
        table.insert(output, { newX, normalsArray[i][2], newZ })
    end

    return output
end

-- gets the point at the center of a face
function getFaceCenter(face)
    local avgX = 0
    local avgY = 0
    local avgZ = 0

    -- for each point
    for i = 1, 4, 1 do
        avgX = avgX + face[i][1]
        avgY = avgY + face[i][2]
        avgZ = avgZ + face[i][3]
    end

    avgX = avgX / 4
    avgY = avgY / 4
    avgZ = avgZ / 4

    return { avgX, avgY, avgZ }
end

-- casts a ray towards the camera to see if the quad is visible, returns true if it is
-- CHECK ALL 4 POINTS, NOT JUST MIDDLE
function isFaceVisible(face, grid, rotOriginX, rotOriginZ, rotAngle)
    local gridRadius = (#grid - 1) / 2

    -- get the coords of the starting position (the face's center)
    local origin = getFaceCenter(face)
    local oX = origin[1]
    local oY = origin[2]
    local oZ = origin[3]

    -- the distance from the camera to the center of the face
    local vectToCameraLength = math.sqrt(oX * oX + oY * oY + oZ * oZ)

    -- x, y, z are the components of a normalized vector towards the camera
    local x = -oX / vectToCameraLength
    local y = -oY / vectToCameraLength
    local z = -oZ / vectToCameraLength

    -- un-rotate the origin so that it is aligned with the grid
    oX, oZ = rotatePoint(oX, oZ, rotOriginX, rotOriginZ, rotAngle)
    -- un-rotate the vector so that it is aligned with the grid
    x, z = rotatePoint(x, z, 0, 0, rotAngle)

    -- transform the origin so that it can become an index of the grid
    oX = oX + gridRadius + 1
    oY = oY + gridRadius + 1
    oZ = oZ + gridRadius + 1 - distAway

    -- one block at a time, step the ray forward and see if it hits anything
    local raySteps = 2
    while raySteps <= 5 do
        -- start at the origin and move along the vector raySteps amount of times
        -- then do math.floor so that the variables can be indices to the grid
        local thisX = math.floor(oX + (raySteps * x))
        local thisY = math.floor(oY + (raySteps * y))
        local thisZ = math.floor(oZ + (raySteps * z))

        -- check if the point is in range of the grid, if it is and it lands on a block, return false (not visible)
        if grid[thisX] ~= nil then
            if grid[thisX][thisY] ~= nil then
                if grid[thisX][thisY][thisZ] ~= nil then
                    if grid[thisX][thisY][thisZ] == 1 then
                        return false
                    end
                end
            end
        end

        raySteps = raySteps + 1
    end

    -- hasnt hit anything, return true
    return true
end

-- gets the surface normal for a face (use for lighting?)
function getFaceNormal(face)
    local p1 = face[1]
    local p2 = face[2]
    local p3 = face[3]

    local dirX = (p2[1] - p1[1]) * (p3[1] - p1[1])
    local dirY = (p2[2] - p1[2]) * (p3[2] - p1[2])
    local dirZ = (p2[3] - p1[3]) * (p3[3] - p1[3])

    local length = math.sqrt(dirX * dirX + dirY * dirY + dirZ * dirZ)

    local normX = dirX / length
    local normY = dirY / length
    local normZ = dirZ / length

    return { normX, normY, normZ }
end

-- inputs the faces array, sorts all the faces from furthest to closest and then returns the faces and facesColors arrays in that order (to be ready to render)
function sortFaces(faces, facesColors, normals)
    local distsTable = {}
    for i = 1, #faces, 1 do
        local center = getFaceCenter(faces[i])
        local dist = center[1] * center[1] + center[2] * center[2] + center[3] * center[3]

        table.insert(distsTable, dist)
    end

    local indicesOrder = insertionSort(distsTable)
    local outFaces = {}
    local outColors = {}
    local outNormals = {}

    for i = #indicesOrder, 1, -1 do
        table.insert(outFaces, faces[indicesOrder[i]])
        table.insert(outColors, facesColors[indicesOrder[i]])
        table.insert(outNormals, normals[indicesOrder[i]])
    end

    return outFaces, outColors, outNormals
end

-- gets the dot product of 2 vectors, if the vectors are parrallel, returns one, if perperdicular or worse, returns 0
function dotProduct3D(vec1, vec2, minVal)
    local val = (vec1[1] * vec2[1]) + (vec1[2] * vec2[2]) + (vec1[3] * vec2[3])
    if val <= minVal then
        return minVal
    else
        return val
    end
end

-- maps a value from one range to another
function map(val, min1, max1, min2, max2)
    return (val - min1) * (max2 - min2) / (max1 - min1) + max2
end

-- {..., ..., {{x, y, z}, {x, y, z}, {x, y, z}, {x, y, z}}, ..., ...}

local radius = 8
local iterations = 0
function render(dt)
    -- UpdateMapTools()

    -- gfx.color(51, 51, 51, 120)
    -- gfx.rect(0, 0, sizeX, sizeY)

    -- local px, py, pz = player.pposition()

    -- -- adding in all the cubes
    -- local cubes, colors = getCubesFromWorld(10)

    -- local originX = 0
    -- local originZ = 40
    -- local yaw = iterations / 20

    -- for i = 1, #cubes, 1 do
    --     local c = cubes[i]
    --     cubes[i] = rotateCube(c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9], c[10], c[11], c[12], c[13], c[14],
    --         c[15],
    --         c[16], c[17], c[18], c[19], c[20], c[21], c[22], c[23], c[24], originX, originZ, yaw)
    -- end

    -- -- rendering the cubes the right way around
    -- local renderOrder = sortCubes(cubes)
    -- for i = #renderOrder, 1, -1 do
    --     local c = cubes[renderOrder[i]]
    --     local color = colors[renderOrder[i]]
    --     projectCube(c[1], c[2], c[3], c[4], c[5], c[6], c[7], c[8], c[9], c[10], c[11], c[12], c[13], c[14], c[15],
    --         c[16], c[17], c[18], c[19], c[20], c[21], c[22], c[23], c[24], color)
    -- end


    for i = 1, #faces, 1 do
        local thisQuad = faces[i]
        local thisCol = faceColors[i]
        local thisNorm = normals[i]

        -- gfx.color(thisCol[1], thisCol[2], thisCol[3])
        local dot = dotProduct3D(thisNorm, { -1, 1, -1 }, 0.5)
        gfx.color(
            thisCol[1] * dot * map((i / #faces), 0, 1, 0.2, 0.8),
            thisCol[2] * dot * map((i / #faces), 0, 1, 0.2, 0.8),
            thisCol[3] * dot * map((i / #faces), 0, 1, 0.2, 0.8))
        -- gfx.color(thisNorm[1] * 255, thisNorm[2] * 255, thisNorm[3] * -255)
        -- gfx.color(i, i, i)

        projectQuad(thisQuad[1][1], thisQuad[1][2], thisQuad[1][3], thisQuad[2][1], thisQuad[2][2], thisQuad[2][3],
            thisQuad[3][1], thisQuad[3][2], thisQuad[3][3], thisQuad[4][1], thisQuad[4][2], thisQuad[4][3])
    end

    iterations = iterations + 1
end

faces = {}
faceColors = {}
normals = {}
function update()
    UpdateMapTools()

    faces = {}
    faceColors = {}
    normals = {}

    local originX = 0
    local originZ = distAway
    local angle = math.rad(iterations)

    local blocksGrid = getBlocksGrid(radius)
    for x = -radius, radius, 1 do
        for y = -radius, radius, 1 do
            for z = -radius, radius, 1 do

                local thisBlock, thisColors, thisNormals = getBlockVisibleFaces(x, y, z, blocksGrid)
                -- add all of the block's faces to the overall array
                for i = 1, #thisBlock, 1 do
                    table.insert(faces, thisBlock[i])
                end
                for i = 1, #thisColors, 1 do
                    table.insert(faceColors, thisColors[i])
                end
                for i = 1, #thisNormals, 1 do
                    table.insert(normals, thisNormals[i])
                end

            end
        end
    end

    faces = rotateAllFaces(faces, originX, originZ, angle)
    normals = rotateAllNormals(normals, angle)

    local i = 1
    while i <= #faces do
        if isFaceVisible(faces[i], blocksGrid, originX, originZ, angle) == false then
            -- delete
            table.remove(faces, i)
            table.remove(faceColors, i)
            table.remove(normals, i)
        else
            -- move on to the next one
            i = i + 1
        end
    end

    faces, faceColors, normals = sortFaces(faces, faceColors, normals)
end

--[[
    ---function that:
        scans the entire area in minecraft and returns 1 if there's a solid block there
        returns it an a big 3d (?) array]

    --- function that:
        inputs a minecraft world coordinate
        check the previous function's (^) array to see on what sides there is something in front of it
        if it is not hidden, table.insert that side's face (4 points)

    ---scan every block add all the visible faces into one array

    ---function to rotate every face in an array

    -- (still have to make it check all the 4 corners, not just the center) for every face, cast a ray towards the camera (0, 0, 0)
        move the ray 1 block each time, if it ends up at a position that is marked as 1 in the grid, save that,  and if all the faces hit a 1, delete that face

    --- every face is ordered from furthest to closest and then rendered in that order
]]

-- make a global player position
-- move all the faces coordinates down 5
