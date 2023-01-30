-- Made by O2Flash20 🙂

name = "Optimal Hit Position"
description = "Shows you where the best place to hit the player that you're looking at is"

importLib("renderthreeD")

function render3d()
    px, py, pz = player.pposition()

    if player.getFlag(1) then py = py - 0.125 end

    entity = player.selectedEntity()
    if entity and entity.type == "player" then

        gfx.renderBehind(true)
        -- current cross
        pointX, pointY, pointZ = getClosestPointToPlayer(px, py, pz, entity.ppx, entity.ppy, entity.ppz)
        gfx.color(targetColor.r, targetColor.g, targetColor.b)
        xyzCross(pointX, pointY, pointZ, crossSize)

        -- hitbox
        gfx.color(hitboxColor.r, hitboxColor.g, hitboxColor.b, hitboxColor.a)
        cubexyz(entity.ppx - 0.3, entity.ppy - 1.62, entity.ppz - 0.3, 0.6, 1.8, 0.6)

    end
end

function update()
    client.settings.reload()
end

function getClosestPointToPlayer(playerX, playerY, playerZ, otherPlayerX, otherPlayerY, otherPlayerZ)
    -- move the other player to the origin
    local dx = playerX - otherPlayerX
    local dy = playerY - (otherPlayerY - 0.72)
    local dz = playerZ - otherPlayerZ

    -- turn the hitbox form a prism to a cube to make it easy
    dx = dx / 0.3
    dy = dy / 0.9
    dz = dz / 0.3

    -- logic stuff
    local flipX, flipY, flipZ = false, false, false
    if dx < 0 then
        dx = dx * -1
        flipX = true
    end
    if dy < 0 then
        dy = dy * -1
        flipY = true
    end
    if dz < 0 then
        dz = dz * -1
        flipZ = true
    end

    -- more logic stuff
    local ox, oy, oz
    if dx > dy and dx > dz then
        ox = 1
        oy = math.min(1, dy)
        oz = math.min(1, dz)
    end
    if dy > dx and dy > dz then
        ox = math.min(1, dx)
        oy = 1
        oz = math.min(1, dz)
    end
    if dz > dx and dz > dy then
        ox = math.min(1, dx)
        oy = math.min(1, dy)
        oz = 1
    end

    -- put everything back and render
    if flipX then ox = -ox end
    if flipY then oy = -oy end
    if flipZ then oz = -oz end

    ox = ox * 0.3
    oy = oy * 0.9
    oz = oz * 0.3

    ox = ox + otherPlayerX
    oy = oy + (otherPlayerY - 0.72)
    oz = oz + otherPlayerZ

    return ox, oy, oz
end

function xyzCross(x, y, z, size)
    local scale = size / 0.6
    cubexyz(x - 0.3 * scale, y - 0.01 * scale, z - 0.01 * scale, 0.6 * scale, 0.02 * scale, 0.02 * scale)
    cubexyz(x - 0.01 * scale, y - 0.3 * scale, z - 0.01 * scale, 0.02 * scale, 0.6 * scale, 0.02 * scale)
    cubexyz(x - 0.01 * scale, y - 0.01 * scale, z - 0.3 * scale, 0.02 * scale, 0.02 * scale, 0.6 * scale)
end

targetColor = { 255, 0, 0 }
client.settings.addColor("Target Color", "targetColor")

hitboxColor = { 0, 255, 255, 100 }
client.settings.addColor("Hitbox Color", "hitboxColor")

crossSize = 0.6
client.settings.addFloat("Cross Size", "crossSize", 0.1, 2)
