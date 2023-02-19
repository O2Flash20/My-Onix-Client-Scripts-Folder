name = "Onix SMP"
description = "Some stuff for Onix SMP"

importLib("logger")

sizeX = 100
sizeY = 100
positionX = 100
positionY = 100

points = {
    { 545,   -120, "O2Flash20" },
    { 0,     60,   "Chickens" },
    { 440,   20,   "StaticWarrior77" },
    { -740,  75,   "HazardTheAD" },
    { 500,   1300, "MADKANE1" },
    { 890,   -134, "Joe (the tree)" },
    { -291,  770,  "Villager breeder" },
    { 1880,  180,  "wTBone" },
    { -500,  990,  "Riceexe" },
    { -3300, -800, "Xk4nx" },
    { -1100, -310, "namooTH" },
    { -580,  540,  "Rosie" }
}

mapLocation = { 545, 66, -120 }
origin = { -60, -60 }

-- {pos}, {facing}
maps = {
    { { 545, 63, -116 }, { 0, 1, 0 } },
    { { 537, 68, -137 }, { 1, 0, 0 } },
    { { -578, 70, 554 }, { 0, 0, -1 } }
}

function render3d()
    for _, map in pairs(maps) do
        for _, point in pairs(points) do
            local x = point[1] - origin[1]
            local z = point[2] - origin[2]

            x = x / 2048
            z = z / 2048

            if math.abs(map[2][1]) == 1 then
                z = -z
                if map[2][1] == 1 then x = -x end
                pointerLine(map[1][1], map[1][2] + z, map[1][3] + x, map[2])
            end
            if math.abs(map[2][2]) == 1 then
                if map[2][2] == -1 then z = -z end
                pointerLine(map[1][1] + x, map[1][2], map[1][3] + z, map[2])
            end
            if math.abs(map[2][3]) == 1 then
                z = -z
                if map[2][3] == -1 then x = -x end
                pointerLine(map[1][1] + x, map[1][2] + z, map[1][3], map[2])
            end
        end
    end
end

function render2()
    lx, ly, lz = player.lookingPos()

    local closestDist = 1000
    local closestName = ""

    for _, map in pairs(maps) do
        for _, point in pairs(points) do
            local x = point[1] - origin[1]
            local z = point[2] - origin[2]

            local p = {}

            x = x / 2048
            z = z / 2048

            if math.abs(map[2][1]) == 1 then
                z = -z
                if map[2][1] == 1 then x = -x end
                p = { map[1][1], map[1][2] + z, map[1][3] + x }
            end
            if math.abs(map[2][2]) == 1 then
                if map[2][2] == -1 then z = -z end
                p = { map[1][1] + x, map[1][2], map[1][3] + z }
            end
            if math.abs(map[2][3]) == 1 then
                z = -z
                if map[2][3] == -1 then x = -x end
                p = { map[1][1] + x, map[1][2] + z, map[1][3] }
            end

            local dist = math.sqrt(
                (lx - p[1]) ^ 2 +
                (ly - p[2]) ^ 2 +
                (lz - p[3]) ^ 2
            )

            if dist < 0.1 and dist < closestDist then
                closestDist = dist
                closestName = point[3]
            end
        end
    end

    if closestName then
        gfx2.text(0, 0, closestName)
    end
end

-- direction ex: {0, 0, -1}
function pointerLine(x, y, z, direction)
    gfx.line(x, y, z, x + direction[1] / 2, y + direction[2] / 2, z + direction[3] / 2)
end
