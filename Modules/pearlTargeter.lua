name = "Ender Pearl Targeter"
description = "Shows you where you have to look to hit a target with an ender pearl."

importLib("logger")
importLib("renderThreeD")

INITIALVEL = 45
GRAVACC = 22

tx = 1022.5
ty = 63
tz = 13.5

function render()
    local px, py, pz = player.pposition()

    local Dx = -(tx - px)
    local Dy = -(ty - py)
    local Dz = -(tz - pz)
    local Dd = math.sqrt(Dx ^ 2 + Dy ^ 2 + Dz ^ 2)

    local s1 = GRAVACC * Dy + INITIALVEL ^ 2
    local s2 = math.sqrt((-GRAVACC * Dy - INITIALVEL ^ 2) ^ 2 - (Dd * GRAVACC) ^ 2)
    local denominator = math.sqrt(2) * Dd / Dx

    local vx1 = -math.sqrt(s1 + s2) / denominator
    local vx2 = -math.sqrt(s1 - s2) / denominator

    local vy1 = (Dy / Dx) * vx1 - 0.5 * GRAVACC * Dx / vx1
    local vy2 = (Dy / Dx) * vx2 - 0.5 * GRAVACC * Dx / vx2

    local vz1 = vx1 * Dz / Dx
    local vz2 = vx2 * Dz / Dx

    local x1, y1 = gfx.worldToScreen(
        vx1 / INITIALVEL + px,
        vy1 / INITIALVEL + py,
        vz1 / INITIALVEL + pz
    )
    if x1 and y1 then
        gfx.color(0, 255, 255)
        gfx.rect(x1 - 2, y1 - 2, 4, 4)
    end

    local x2, y2 = gfx.worldToScreen(
        vx2 / INITIALVEL + px,
        vy2 / INITIALVEL + py,
        vz2 / INITIALVEL + pz
    )
    if x2 and y2 then
        gfx.color(255, 0, 255)
        gfx.rect(x2 - 2, y2 - 2, 4, 4)
    end

    log(vx1, vy1, vz1)
end
