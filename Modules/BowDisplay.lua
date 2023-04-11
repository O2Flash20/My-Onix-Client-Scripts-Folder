name = "Bow Display"
description = "Displays the bow."

importLib("logger")

chargingBow = false
bowStartChargeTime = os.clock()

function holdingBow() return ((player.inventory().at(player.inventory().selected) or {}).name or "") == "bow" end

event.listen("MouseInput", function(button, down)
    if holdingBow() then
        bowStartChargeTime = os.clock()
        chargingBow = down
    elseif button == 2 then
        chargingBow = false
    end
end)

function getBowPath()
    if not chargingBow then
        return "textures/items/bow_standby.png"
    end
    local bowNorm = math.clamp((os.clock() - bowStartChargeTime) / 0.75, 0, 1)
    if bowNorm == 1 then
        return "textures/items/bow_pulling_2"
    elseif bowNorm >= 0.5 then
        return "textures/items/bow_pulling_1"
    else
        return "textures/items/bow_pulling_0"
    end
end

-- function render()
--     if player.perspective() == 0 and holdingBow() then
--         gfx.tquad(
--             0.66 * gui.width(), 0.54 * gui.height(), 0, 0,
--             0.78 * gui.width() - 25, 1.15 * gui.height() - 25, 0, 1,
--             1.23 * gui.width() - 25, 1.28 * gui.height() - 25, 1, 1,
--             1.03 * gui.width() - 25, 0.22 * gui.height() - 25, 1, 0, getBowPath())
--     end
--     -- print("hi")
-- end

function render3d()
    gfx.renderBehind(true)

    px, py, pz = player.pposition()
    pyaw, ppitch = player.rotation()

    local s = 50
    local vertices = {
        { -s, -s, 0 },
        { s,  -s, 0 },
        { s,  s,  0 },
        { -s, s,  0 }
    }

    -- log({ math.rad( -ppitch), math.rad( -pyaw - 180) })

    local v = {}
    for key, vertex in pairs(vertices) do
        table.insert(v,
            rotatePoint(vertex[1], vertex[2], vertex[3], 0, 0, 0, math.rad( -ppitch), math.rad( -pyaw - 180), 0))
    end

    local p = raycastFromPlayer(px, py, pz, ppitch, pyaw, 50)

    local v2 = {}
    for key, vertex in pairs(v) do
        vertex[1] = vertex[1] + p[1]
        vertex[2] = vertex[2] + p[2]
        vertex[3] = vertex[3] + p[3]

        -- vertex = rotatePoint(vertex[1], vertex[2], vertex[3], px, py, pz, 6.89, 3.14, 0)
        -- table.insert(v2, rotatePoint(vertex[1], vertex[2], vertex[3], px, py, pz, math.rad(45), -3.14, 0))
    end

    gfx.tquad(
        v[1][1], v[1][2], v[1][3], 0, 0,
        v[2][1], v[2][2], v[2][3], 1, 0,
        v[3][1], v[3][2], v[3][3], 1, 1,
        v[4][1], v[4][2], v[4][3], 0, 1,
        getBowPath()
    )
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

function raycastFromPlayer(playerX, playerY, playerZ, playerPitch, playerYaw, maxDistance)
    playerPitch = math.rad(playerPitch)
    playerYaw = math.rad( -playerYaw)

    y = -maxDistance * math.sin(playerPitch)
    z = maxDistance * math.cos(playerPitch)
    x = z * math.sin(playerYaw)
    z = z * math.cos(playerYaw)

    return { x + playerX, y + playerY, z + playerZ }
end
