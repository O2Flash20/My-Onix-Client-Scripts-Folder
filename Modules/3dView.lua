name = "ThreeD View"
description = "Shows a 3D view of the blocks around you."

positionX = 50
positionY = 100
sizeX = 200
sizeY = 200

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
local distDown = 5
function projectQuad(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
    local p1 = projectPoint(x1, y1 - distDown, z1)
    local p2 = projectPoint(x2, y2 - distDown, z2)
    local p3 = projectPoint(x3, y3 - distDown, z3)
    local p4 = projectPoint(x4, y4 - distDown, z4)

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

    elseif grid[x + gridRadius + 1][y + gridRadius + 1][z + gridRadius + 1 + 1] == 0 then
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
-- NOT PERFECT
function isFaceVisible(face, grid, rotOriginX, rotOriginZ, rotAngle)
    local gridRadius = (#grid - 1) / 2

    -- get the coords of the starting position (the face's center)
    local origin = getFaceCenter(face)
    local oX = origin[1]
    local oY = origin[2]
    local oZ = origin[3]

    local p1X = face[1][1]
    local p1Y = face[1][2]
    local p1Z = face[1][3]

    local p2X = face[2][1]
    local p2Y = face[2][2]
    local p2Z = face[2][3]

    local p3X = face[3][1]
    local p3Y = face[3][2]
    local p3Z = face[3][3]

    local p4X = face[4][1]
    local p4Y = face[4][2]
    local p4Z = face[4][3]

    -- the distance from the camera to the center of the face
    local vectToCameraLength = math.sqrt(oX * oX + oY * oY + oZ * oZ)
    -- x, y, z are the components of a normalized vector towards the camera
    local x = -oX / vectToCameraLength
    local y = -oY / vectToCameraLength
    local z = -oZ / vectToCameraLength

    -- un-rotate the origin so that it is aligned with the grid
    oX, oZ = rotatePoint(oX, oZ, rotOriginX, rotOriginZ, rotAngle)
    -- un-rotate all the points too
    p1X, p1Z = rotatePoint(p1X, p1Z, rotOriginX, rotOriginZ, -rotAngle)
    p2X, p2Z = rotatePoint(p2X, p2Z, rotOriginX, rotOriginZ, -rotAngle)
    p3X, p3Z = rotatePoint(p3X, p3Z, rotOriginX, rotOriginZ, -rotAngle)
    p4X, p4Z = rotatePoint(p4X, p4Z, rotOriginX, rotOriginZ, -rotAngle)
    -- un-rotate the vector so that it is aligned with the grid
    x, z = rotatePoint(x, z, 0, 0, rotAngle)

    -- transform the origin so that it can become an index of the grid
    oX = oX + gridRadius + 1
    oY = oY + gridRadius + 1
    oZ = oZ + gridRadius + 1 - distAway

    -- do the same with the 4 points
    p1X = p1X + gridRadius + 1
    p1Y = p1Y + gridRadius + 1
    p1Z = p1Z + gridRadius + 1 - distAway

    p2X = p2X + gridRadius + 1
    p2Y = p2Y + gridRadius + 1
    p2Z = p2Z + gridRadius + 1 - distAway

    p3X = p3X + gridRadius + 1
    p3Y = p3Y + gridRadius + 1
    p3Z = p3Z + gridRadius + 1 - distAway

    p4X = p4X + gridRadius + 1
    p4Y = p4Y + gridRadius + 1
    p4Z = p4Z + gridRadius + 1 - distAway

    -- one block at a time, step the ray forward and see if it hits anything
    local raySteps = 1
    while raySteps <= 15 do
        -- start at the origin and move along the vector raySteps amount of times
        -- then do math.floor so that the variables can be indices to the grid

        -- check if the point is in range of the grid, if it is and it lands on a block, return false (not visible)
        if checkIsBlockInGrid(grid,
            math.floor(oX + (raySteps * x)),
            math.floor(oY + (raySteps * y)),
            math.floor(oZ + (raySteps * z)))
        then
            -- the center has collided with something, if the edges have all done too, the face is not visible
            if checkIsBlockInGrid(grid,
                math.floor(p1X + (raySteps * x)),
                math.floor(p1Y + (raySteps * y)),
                math.floor(p1Z + (raySteps * z)))
                and
                checkIsBlockInGrid(grid,
                    math.floor(p2X + (raySteps * x)),
                    math.floor(p2Y + (raySteps * y)),
                    math.floor(p2Z + (raySteps * z)))
                and
                checkIsBlockInGrid(grid,
                    math.floor(p3X + (raySteps * x)),
                    math.floor(p3Y + (raySteps * y)),
                    math.floor(p3Z + (raySteps * z)))
                and
                checkIsBlockInGrid(grid,
                    math.floor(p4X + (raySteps * x)),
                    math.floor(p4Y + (raySteps * y)),
                    math.floor(p4Z + (raySteps * z)))
            then
                return false
            end
        end

        raySteps = raySteps + 1
    end

    -- hasnt hit anything, return true
    return true
end

-- a helper function for the one above
function checkIsBlockInGrid(grid, x, y, z)
    if grid[x] ~= nil then
        if grid[x][y] ~= nil then
            if grid[x][y][z] ~= nil then
                if grid[x][y][z] == 1 then
                    return true
                end
            end
        end
    end
    return false
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
    for i = 1, #faces, 1 do
        local thisQuad = faces[i]
        local thisCol = faceColors[i]
        local thisNorm = normals[i]

        -- gfx.color(thisCol[1], thisCol[2], thisCol[3])

        -- the epic lighting
        local dot = dotProduct3D(thisNorm, { -1, 1, -1 }, 0.5)
        gfx.color(
            thisCol[1] * dot * map((i / #faces), 0, 1, 0.1, 0.8),
            thisCol[2] * dot * map((i / #faces), 0, 1, 0.1, 0.8),
            thisCol[3] * dot * map((i / #faces), 0, 1, 0.1, 0.8))

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
updates = 0
function update()
    if updates % 1 == 0 then
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

    updates = updates + 1
end
