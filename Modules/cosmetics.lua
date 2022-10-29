name = "Cosmetics"
description = "Crown and halo cosmetics for Onix Client"

--[[
    Made by O2Flash20
    Sunglasses cosmetic made by rosie
]]

-- Some more controls
animationSpeed = 1
haloHeightAbovePlayer = 0.6
haloBobAmount = 0.025
--

cosmeticNum = 1
client.settings.addInt("Cosmetic:", "cosmeticNum", 1, 4)

client.settings.addAir(10)

haloCol = { 255, 215, 0 }
client.settings.addColor("Halo Color", "haloCol")

client.settings.addAir(10)

crownCol = { 255, 215, 0 }
client.settings.addColor("Crown Color", "crownCol")

gemCol1 = { 0, 255, 0 }
client.settings.addColor("Gem Color 1", "gemCol1")

gemCol2 = { 0, 0, 255 }
client.settings.addColor("Gem Color 2", "gemCol2")

gemCol3 = { 255, 0, 0 }
client.settings.addColor("Gem Color 3", "gemCol3")

gemCol4 = { 255, 0, 255 }
client.settings.addColor("Gem Color 4", "gemCol4")

client.settings.addAir(10)

sunglassesHeight = 1
client.settings.addFloat("Sunglasses Height", "sunglassesHeight", 0.998, 1.004)
sunglassesColor = { 3, 3, 3 }
client.settings.addColor("Sunglasses Color", "sunglassesColor")

-- like gfx.triangle but takes in the points as tables {x, y, z}
function triangle3d(p1, p2, p3)
    gfx.triangle(p1[1], p1[2], p1[3], p2[1], p2[2], p2[3], p3[1], p3[2], p3[3])
end

-- turns dimension of a prism into points
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

-- rotates a prism, given all it's points
function rotatePrism(prism, originX, originY, originZ, pitch, yaw)
    local output = {}
    for i = 1, #prism, 1 do
        local newPoint = rotatePoint(prism[i][1], prism[i][2], prism[i][3], originX, originY, originZ, pitch, yaw)
        table.insert(output, newPoint)
    end

    return output
end

-- rotates a point in 3d space
function rotatePoint(x, y, z, originX, originY, originZ, pitch, yaw)
    local newX, newY, newZ

    -- rotate along z axis
    x = x - originX
    y = y - originY

    newX = x * math.cos(pitch) - y * math.sin(pitch)
    newY = x * math.sin(pitch) + y * math.cos(pitch)

    x = newX + originX
    y = newY + originY

    -- rotate along y axis
    x = x - originX
    z = z - originZ

    newX = z * math.sin(yaw) + x * math.cos(yaw)
    newZ = z * math.cos(yaw) - x * math.sin(yaw)

    x = newX + originX
    z = newZ + originZ

    return { x, y, z }
end

-- renders the prism array using triangles
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

function render3d()
    if player.perspective() == 0 then return end

    px, py, pz = player.pposition()
    pPitch, pYaw = player.rotation()

    -- Corrects py if the player is crouching
    if player.getFlag(1) then
        py = py - 0.25
    end

    local x, y, z, oX, oY, oZ, rPitch, rYaw, prism

    local t = os.clock() * animationSpeed

    -- HALO --
    if cosmeticNum == 1 then
        -- The starting point for the prisms' positions. Allows you to easily move the whole thing around without changing the values for every prism. Notice how all getPrism3ds use x, y, z as a base, then make small additions or subtractions.
        x = px
        y = py + haloHeightAbovePlayer + math.sin(t) * haloBobAmount
        z = pz

        -- Used as the rotation origin point. This "attaches" all your prisms to the head. For all cosmetics attached to the head, it should be px, py-0.2, pz or else when you look up or down it won't match up with your head.
        oX = px
        oY = py - 0.2
        oZ = pz

        -- Getting the player's rotation so that the cosmetic can match
        rPitch = math.rad(-pYaw)
        rYaw = math.rad(-pPitch - 90)

        gfx.color(haloCol.r, haloCol.g, haloCol.b)

        --[[
            Four steps here:
            1. getPrism3d creates the actual prism at the position and size you want it. NOTE THAT THE POSITION IS THE CENTER OF THE PRISM, NOT AT AN EDGE.
            2. For this mod, I wanted the halo to spin on itself, so I set the rotation origin as the center of the halo (not oX, oY, oZ because I don't want it to spin around the head) and used t as a yaw value
            3. I then used rotatePrism again with oX, oY, oZ, rPitch, rYaw to make the cosmetic match the head rotation. This step should theorectially be done on every cosmetic.
            4. renderPrism, finally renders the prism after being rotated twice
        ]]
        prism = getPrism3d(x + 0.15, y, z, 0.05, 0.05, 0.25)
        prism = rotatePrism(prism, x, y, z, 0, t)
        prism = rotatePrism(prism, oX, oY, oZ, rPitch, rYaw)
        renderPrism(prism)

        prism = getPrism3d(x - 0.15, y, z, 0.05, 0.05, 0.25)
        prism = rotatePrism(prism, x, y, z, 0, t)
        prism = rotatePrism(prism, oX, oY, oZ, rPitch, rYaw)
        renderPrism(prism)

        prism = getPrism3d(x, y, z + 0.15, 0.25, 0.05, 0.05)
        prism = rotatePrism(prism, x, y, z, 0, t)
        prism = rotatePrism(prism, oX, oY, oZ, rPitch, rYaw)
        renderPrism(prism)

        prism = getPrism3d(x, y, z - 0.15, 0.25, 0.05, 0.05)
        prism = rotatePrism(prism, x, y, z, 0, t)
        prism = rotatePrism(prism, oX, oY, oZ, rPitch, rYaw)
        renderPrism(prism)
    end
    -- Crown --
    if cosmeticNum == 2 then
        x = px
        y = py + 0.15
        z = pz

        oX = px
        oY = py - 0.2
        oZ = pz

        rPitch = math.rad(-pYaw)
        rYaw = math.rad(-pPitch - 90)

        gfx.color(crownCol.r, crownCol.g, crownCol.b)
        prism = getPrism3d(x, y, z, 0.55, 0.17, 0.55)
        prism = rotatePrism(prism, oX, oY, oZ, rPitch, rYaw)
        renderPrism(prism)

        -- I use a for loop here because I know that the crown is going to be symmetrical. I'm essentially just saving lines. If you're not comfortable with doing it, just make each prism its own block and don't use a loop.
        -- i flips from 1 to -1, which allows he to get that symmetry on both sides of (0, 0)
        for i = -1, 1, 2 do
            gfx.color(crownCol.r, crownCol.g, crownCol.b)
            prism = getPrism3d(x + (0.27 * i), y + 0.08, z - 0.12, 0.05, 0.2, 0.15)
            prism = rotatePrism(prism, oX, oY, oZ, rPitch, rYaw)
            renderPrism(prism)

            prism = getPrism3d(x + (0.27 * i), y + 0.08, z + 0.12, 0.05, 0.2, 0.15)
            prism = rotatePrism(prism, oX, oY, oZ, rPitch, rYaw)
            renderPrism(prism)

            prism = getPrism3d(x - 0.12, y + 0.08, z + (0.27 * i), 0.15, 0.2, 0.05)
            prism = rotatePrism(prism, oX, oY, oZ, rPitch, rYaw)
            renderPrism(prism)

            prism = getPrism3d(x + 0.12, y + 0.08, z + (0.27 * i), 0.15, 0.2, 0.05)
            prism = rotatePrism(prism, oX, oY, oZ, rPitch, rYaw)
            renderPrism(prism)


            gfx.color(0, 255, 0)
            prism = getPrism3d(x + (0.27 * i), y + 0.08, z - 0.12, 0.07, 0.07, 0.07)
            prism = rotatePrism(prism, oX, oY, oZ, rPitch, rYaw)
            renderPrism(prism)

            gfx.color(0, 0, 255)
            prism = getPrism3d(x + (0.27 * i), y + 0.08, z + 0.12, 0.07, 0.07, 0.07)
            prism = rotatePrism(prism, oX, oY, oZ, rPitch, rYaw)
            renderPrism(prism)

            gfx.color(255, 0, 0)
            prism = getPrism3d(x + 0.12, y + 0.08, z + (0.27 * i), 0.07, 0.07, 0.07)
            prism = rotatePrism(prism, oX, oY, oZ, rPitch, rYaw)
            renderPrism(prism)

            gfx.color(255, 0, 255)
            prism = getPrism3d(x - 0.12, y + 0.08, z + (0.27 * i), 0.07, 0.07, 0.07)
            prism = rotatePrism(prism, oX, oY, oZ, rPitch, rYaw)
            renderPrism(prism)
        end
    end
    -- Sunglasses --
    if cosmeticNum == 3 then
        x = px
        y = py + 0.15
        z = pz

        oX = px
        oY = py - 0.2
        oZ = pz

        rPitch = math.rad(-pYaw)
        rYaw = math.rad(-pPitch - 90)

        gfx.color(sunglassesColor.r, sunglassesColor.g, sunglassesColor.b)

        prism = getPrism3d(x + 0.08, (y - 0.19) * sunglassesHeight, z, 0.4, 0.05, 0.55)
        prism = rotatePrism(prism, oX, oY, oZ, rPitch, rYaw)
        renderPrism(prism)

        gfx.color(0, 0, 255, 10)

        prism = getPrism3d(x + 0.265, (y - 0.24) * sunglassesHeight, z - 0.1, 0.03, 0.06, 0.13)
        prism = rotatePrism(prism, oX, oY, oZ, rPitch, rYaw)
        renderPrism(prism)

        prism = getPrism3d(x + 0.265, (y - 0.24) * sunglassesHeight, z + 0.1, 0.03, 0.06, 0.13)
        prism = rotatePrism(prism, oX, oY, oZ, rPitch, rYaw)
        renderPrism(prism)
    end
    -- Test --
    if cosmeticNum == 4 then
        x = px
        y = py + 0.15
        z = pz

        oX = px
        oY = py - 0.2
        oZ = pz

        rPitch = math.rad(-pYaw)
        rYaw = math.rad(-pPitch - 90)

        prism = getPrism3d(x, y + 2, z, 1, 1, 1)
        prism = rotatePrism(prism, oX, oY, oZ, rPitch, rYaw)
        renderPrism(prism)
    end

    isTest = cosmeticNum == 3
end

-- use delta time instead of os.clock
-- use DependentBoolean library
