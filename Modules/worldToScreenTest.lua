name = "world to screen"
description = "a test module for world to screen calculations. useless since it's an onix function"

-- just a random point, can be anything
x = 0
y = 0
z = 10

--game's fov: the vertical fov
fovV = math.rad(90)
--the horizontal fov, 16/9 should be replaced by the actual aspect ratio
fovH = 2 * math.atan((16 / 9) * (math.tan(fovV / 2)))

function render()
    local px, py, pz = gfx.origin()
    local pyaw, ppitch = player.rotation()
    pyaw = math.rad(pyaw)
    ppitch = math.rad(ppitch)

    -- fix angle if player is in third person front
    if player.perspective() == 2 then
        pyaw = math.pi + pyaw
        ppitch = -ppitch
    end

    -- translate to be relative to camera
    local ox = x - px
    local oy = y - py
    local oz = z - pz

    -- rotate to be relative to camera
    local angleXZ = math.atan(ox, oz)
    local distXZ = math.sqrt(ox * ox + oz * oz)
    ox = distXZ * math.sin(angleXZ + pyaw)
    oz = distXZ * math.cos(angleXZ + pyaw)
    local angleZY = math.atan(oy, oz)
    local distZY = math.sqrt(oy * oy + oz * oz)
    oz = distZY * math.cos(angleZY + ppitch)
    oy = distZY * math.sin(angleZY + ppitch)

    --behind the player, so reject
    if (oz < 0) then return end

    -- project to z=1
    ox = ox / oz
    oy = oy / oz

    -- map to screen
    ox = 640 * (ox - math.tan(fovH / 2)) / (-2 * math.tan(fovH / 2))
    oy = 360 * (oy - math.tan(fovV / 2)) / (-2 * math.tan(fovV / 2))

    -- draw the point to the screen
    gfx.color(0, 255, 255)
    gfx.rect(ox - 5, oy - 5, 10, 10)
end
