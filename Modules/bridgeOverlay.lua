name = "Bridge Overlay"
description = "Overlay for bridge"

importLib("renderthreeD")

color = { 0, 0, 255, 75 }
client.settings.addColor("Overlay Color", "color")

height = 86
client.settings.addInt("Overlay Y level", "height", 0, 200)

radius = 5
client.settings.addInt("Radius", "radius", 2, 20)

function render3d()
    if radius % 2 ~= 0 then
        r = radius + 1
    else
        r = radius
    end

    px, py, pz = player.position()
    for x = px - r / 2, px + r / 2, 1 do
        for z = pz - r / 2, pz + r / 2, 1 do
            if dimension.getBlock(x, height, z).name ~= "air" then
                gfx.color(color.r, color.g, color.b, color.a)
                cube(x - 0.0025, height - 0.0025, z - 0.0025, 1.005)
            end
        end
    end
end
