name = "Projectile Trajectory"
description = "Shows you where your projectiles will hit"

importLib("renderThreeD")
importLib("logger")

-- initial velocity: magnitude of 30m/s
-- acceleration due to gravity: -12m/(s^2)

-- SNOWBALL
INITIALVEL = 30
GRAVACC = 11.5
TERMVEL = 54.5

-- ENDER PEARL (PERFECT)
-- INITIALVEL = 45
-- GRAVACC = 22

function calculateDeltaX(initialVelocity, angle, time)
    return initialVelocity * math.cos(angle) * time
end

function calculateDeltaY(initialVelocity, angle, accelerationY, time)
    return initialVelocity * math.sin(angle) * time - 0.5 * accelerationY * time * time
end

function calculateDeltaXDrag(initalVelocity, angle, terminalVelocity, accelerationFromGravity, time)
    return ((initalVelocity * terminalVelocity * math.cos(angle)) / accelerationFromGravity) *
        (1 - math.exp(-(accelerationFromGravity * time) / terminalVelocity))
end

function calculateDeltaYDrag(initalVelocity, angle, terminalVelocity, accelerationFromGravity, time)
    return (terminalVelocity / accelerationFromGravity) *
        (initalVelocity * math.sin(angle) + terminalVelocity) *
        (1 - math.exp(-(accelerationFromGravity * time) / terminalVelocity)) -
        terminalVelocity * time
end

function render3d()
    local px, py, pz = player.pposition()
    local pyaw, ppitch = player.rotation()
    local points = {}
    -- for i = 0, 10, 0.1 do
    --     local deltaX = calculateDeltaX(INITIALVEL, -math.rad(ppitch), i) --BUT, this is split between x and z, depending on pyaw
    --     table.insert(points, {
    --         deltaX * math.sin(math.rad(-pyaw)),
    --         calculateDeltaY(INITIALVEL, -math.rad(ppitch), GRAVACC, i),
    --         deltaX * math.cos(math.rad(-pyaw))
    --     })
    -- end

    for i = 0, 10, 0.1 do
        local deltaX = calculateDeltaXDrag(INITIALVEL, -math.rad(ppitch), TERMVEL, GRAVACC, i) --BUT, this is split between x and z, depending on pyaw
        table.insert(points, {
            deltaX * math.sin(math.rad(-pyaw)),
            calculateDeltaYDrag(INITIALVEL, -math.rad(ppitch), TERMVEL, GRAVACC, i),
            deltaX * math.cos(math.rad(-pyaw))
        })
    end


    gfx.color(255, 0, 0)
    for i = 1, #points - 1, 1 do
        gfx.line(
            points[i][1] + px, points[i][2] + py, points[i][3] + pz,
            points[i + 1][1] + px, points[i + 1][2] + py, points[i + 1][3] + pz
        )
    end
end
