name = "Cosmetics Spheres Test"
description = "Spheres???"

importLib("cosmeticTools")
importLib("logger")

vertices = {}

function calculateVertices(radius)
    local vertices = {}

    for y = -radius, radius, 1 do
        table.insert(vertices, {})
        for x = radius, -radius, -1 do
            table.insert(vertices[y + radius + 1], { x / radius, y / radius, 1 })
        end
    end

    return vertices
end

function update()
    vertices = calculateVertices(2)
end

function render3d()
    -- if player.perspective() == 0 then return end
    updateCosmeticTools()

    -- normalizes all vertices
    for x = 1, #vertices[1], 1 do
        for y = 1, #vertices, 1 do
            vertices[y][x] = normalizeVector(vertices[y][x])
        end
    end

    -- renders vertices list
    drawSphere()
end

function drawSphere()
    -- z+
    for x = 1, #vertices[1], 1 do
        for y = 1, #vertices - 1, 1 do
            if x > 1 then
                local triangle = {
                    { vertices[y][x][1], vertices[y][x][2], vertices[y][x][3] },
                    { vertices[y + 1][x - 1][1], vertices[y + 1][x - 1][2], vertices[y + 1][x - 1][3] },
                    { vertices[y + 1][x][1], vertices[y + 1][x][2], vertices[y + 1][x][3] }
                }
                renderSphereTriangle(triangle)
            end
            if x ~= #vertices[1] then
                local triangle = {
                    { vertices[y + 1][x][1], vertices[y + 1][x][2], vertices[y + 1][x][3] },
                    { vertices[y][x + 1][1], vertices[y][x + 1][2], vertices[y][x + 1][3] },
                    { vertices[y][x][1], vertices[y][x][2], vertices[y][x][3] }
                }
                renderSphereTriangle(triangle)
            end
        end
    end

    -- z-
    for x = 1, #vertices[1], 1 do
        for y = 1, #vertices - 1, 1 do
            if x > 1 then
                local triangle = {
                    { vertices[y + 1][x - 1][1], vertices[y + 1][x - 1][2], -vertices[y + 1][x - 1][3] },
                    { vertices[y][x][1], vertices[y][x][2], -vertices[y][x][3] },
                    { vertices[y + 1][x][1], vertices[y + 1][x][2], -vertices[y + 1][x][3] }
                }
                renderSphereTriangle(triangle)
            end
            if x ~= #vertices[1] then
                local triangle = {
                    { vertices[y][x + 1][1], vertices[y][x + 1][2], -vertices[y][x + 1][3] },
                    { vertices[y + 1][x][1], vertices[y + 1][x][2], -vertices[y + 1][x][3] },
                    { vertices[y][x][1], vertices[y][x][2], -vertices[y][x][3] }
                }
                renderSphereTriangle(triangle)
            end
        end
    end

    -- y+
    for x = 1, #vertices[1], 1 do
        for y = 1, #vertices - 1, 1 do
            if x > 1 then
                local triangle = {
                    { vertices[y + 1][x - 1][1], vertices[y + 1][x - 1][3], vertices[y + 1][x - 1][2] },
                    { vertices[y][x][1], vertices[y][x][3], vertices[y][x][2] },
                    { vertices[y + 1][x][1], vertices[y + 1][x][3], vertices[y + 1][x][2] }
                }
                renderSphereTriangle(triangle)
            end
            if x ~= #vertices[1] then
                local triangle = {
                    { vertices[y][x + 1][1], vertices[y][x + 1][3], vertices[y][x + 1][2] },
                    { vertices[y + 1][x][1], vertices[y + 1][x][3], vertices[y + 1][x][2] },
                    { vertices[y][x][1], vertices[y][x][3], vertices[y][x][2] }
                }
                renderSphereTriangle(triangle)
            end
        end
    end

    -- y-
    for x = 1, #vertices[1], 1 do
        for y = 1, #vertices - 1, 1 do
            if x > 1 then
                local triangle = {
                    { vertices[y][x][1], -vertices[y][x][3], vertices[y][x][2] },
                    { vertices[y + 1][x - 1][1], -vertices[y + 1][x - 1][3], vertices[y + 1][x - 1][2] },
                    { vertices[y + 1][x][1], -vertices[y + 1][x][3], vertices[y + 1][x][2] }
                }
                renderSphereTriangle(triangle)
            end
            if x ~= #vertices[1] then
                local triangle = {
                    { vertices[y + 1][x][1], -vertices[y + 1][x][3], vertices[y + 1][x][2] },
                    { vertices[y][x + 1][1], -vertices[y][x + 1][3], vertices[y][x + 1][2] },
                    { vertices[y][x][1], -vertices[y][x][3], vertices[y][x][2] }
                }
                renderSphereTriangle(triangle)
            end
        end
    end

    -- x+
    for x = 1, #vertices[1], 1 do
        for y = 1, #vertices - 1, 1 do
            if x > 1 then
                local triangle = {
                    { vertices[y + 1][x - 1][3], vertices[y + 1][x - 1][2], vertices[y + 1][x - 1][1] },
                    { vertices[y][x][3], vertices[y][x][2], vertices[y][x][1] },
                    { vertices[y + 1][x][3], vertices[y + 1][x][2], vertices[y + 1][x][1] }
                }
                renderSphereTriangle(triangle)
            end
            if x ~= #vertices[1] then
                local triangle = {
                    { vertices[y][x + 1][3], vertices[y][x + 1][2], vertices[y][x + 1][1] },
                    { vertices[y + 1][x][3], vertices[y + 1][x][2], vertices[y + 1][x][1] },
                    { vertices[y][x][3], vertices[y][x][2], vertices[y][x][1] }
                }
                renderSphereTriangle(triangle)
            end
        end
    end

    -- x-
    for x = 1, #vertices[1], 1 do
        for y = 1, #vertices - 1, 1 do
            if x > 1 then
                local triangle = {
                    { -vertices[y][x][3], vertices[y][x][2], vertices[y][x][1] },
                    { -vertices[y + 1][x - 1][3], vertices[y + 1][x - 1][2], vertices[y + 1][x - 1][1] },
                    { -vertices[y + 1][x][3], vertices[y + 1][x][2], vertices[y + 1][x][1] }
                }
                renderSphereTriangle(triangle)
            end
            if x ~= #vertices[1] then
                local triangle = {
                    { -vertices[y + 1][x][3], vertices[y + 1][x][2], vertices[y + 1][x][1] },
                    { -vertices[y][x + 1][3], vertices[y][x + 1][2], vertices[y][x + 1][1] },
                    { -vertices[y][x][3], vertices[y][x][2], vertices[y][x][1] }
                }
                renderSphereTriangle(triangle)
            end
        end
    end
end

function renderSphereTriangle(triangle)
    local normal = calculateSurfaceNormalTriangle(triangle[1], triangle[2], triangle[3])
    -- local dot = dotProduct3D(normal, { -1, 1, 1 }, 0.1)
    -- gfx.color(dot * 255, dot * 255, dot * 255)
    gfx.color(normal[1] * 255, normal[2] * 255, normal[3] * 255)
    tri(triangle[1], triangle[2], triangle[3])
end

function dotProduct3D(vec1, vec2, minVal)
    local val = (vec1[1] * vec2[1]) + (vec1[2] * vec2[2]) + (vec1[3] * vec2[3])
    if val <= minVal then
        return minVal
    else
        return val
    end
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

function normalizeVector(vector)
    local vectorLength = math.sqrt(vector[1] * vector[1] + vector[2] * vector[2] + vector[3] * vector[3])

    return { vector[1] / vectorLength, vector[2] / vectorLength, vector[3] / vectorLength }
end

function tri(p1, p2, p3)
    gfx.triangle(p1[1], p1[2], p1[3], p2[1], p2[2], p2[3], p3[1], p3[2], p3[3])
end
