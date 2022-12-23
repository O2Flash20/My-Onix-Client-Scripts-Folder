name = "Raycast Test"
description = "Testing the raycastFromPlayer function"

importLib("renderthreeD")

function render3d()
    local px, py, pz = player.pposition()
    local rx, ry = player.rotation()


    local ray = raycastFromPlayer(px, py, pz, ry, rx, 5)
    cube(ray[1], ray[2], ray[3], 0.1)
end

function raycastFromPlayer(playerX, playerY, playerZ, playerPitch, playerYaw, maxDistance)
    playerPitch = math.rad(playerPitch)
    playerYaw = math.rad(-playerYaw)

    y = -maxDistance * math.sin(playerPitch)
    z = maxDistance * math.cos(playerPitch)
    x = z * math.sin(playerYaw)
    z = z * math.cos(playerYaw)

    return { x + playerX, y + playerY, z + playerZ }
end
