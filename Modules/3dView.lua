name = "ThreeD View"
description = "Shows a 3D view of the blocks around you."

importLib("renderthreeD")
importLib("logger")

cubeSize = 10

function placeCube(x, y, z, r, g, b)
    gfx.color(r, g, b)
    cube(px + offX + x * cubeSize, py + offY + y * cubeSize, pz + offZ + z * cubeSize, cubeSize)
end

function render3d()
    local pYaw, pPitch = player.rotation()
    px, py, pz = player.pposition()

    px = px - cubeSize / 2
    py = py - cubeSize / 2
    pz = pz - cubeSize / 2

    local yaw = math.rad(-pYaw - 90)
    local pitch = math.rad(-pPitch)

    local xzLen = math.cos(pitch)
    offX = xzLen * math.cos(yaw) * 100
    offY = math.sin(pitch) * 100
    offZ = xzLen * math.sin(-yaw) * 100

    gfx.renderBehind(true)
    gfx.color(0, 255, 255)

    -- cube(px + offX, py + offY, pz + offZ, cubeSize)

    placeCube(0, 0, 0, 255, 0, 0)
    placeCube(0, -1, 0, 0, 255, 0)
    placeCube(1, 0, 0, 0, 0, 255)

    -- gfx.color(255, 0, 0)
    -- cube(px + offX, py + offY + cubeSize, pz + offZ, cubeSize)

    -- log({ math.rad(pYaw), math.rad(pPitch) })
    log({ math.rad(-pYaw - 90), math.rad(-pPitch) })
end

function update()

end
