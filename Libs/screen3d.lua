---Starts screen3d, everything after this will be relative to the player's screen. It must be used in render3d and it must be ended before the render3d function ends.
function startScreen3d()
    local ___px, ___py, ___pz = player.forwardPosition(0)
    local ___pyaw, ___ppitch = player.rotation()

    gfx.pushTransformation(
        { 4, 1 / 40, 1 / 40, 1 / 40 },
        { 3, math.rad(___ppitch), 0, 1, 0 },
        { 3, math.rad(-___pyaw), 1, 0, 1 },
        { 2, ___px, ___py, ___pz }
    )
end

---Everything between this and startScreen3d will be relative to the player's screen.
function endScreen3d()
    gfx.color(0, 0, 0)
    gfx.popTransformation()
end

--[[
    What about 3rd person?
        make it not show at all or try to transform it to work
]]
