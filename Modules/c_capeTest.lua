name = "Cape Cosmetics Test"
description = "Proof of Concept for Capes"

importLib("cosmeticTools")
importLib("logger")

x = 0
y = 0
z = 0

velocity = { 0, 0, 0 }

oldVelocity = { 0, 0, 0 }
timeOfOldVelocity = 0

function update()
    oldVelocity = velocity
    timeOfOldVelocity = os.clock()

    local displacementX = px - x
    local displacementY = py - y
    local displacementZ = pz - z

    velX = displacementX
    velY = displacementY
    velZ = displacementZ

    x = px
    y = py
    z = pz

    velocity = rotatePoint(velX, velY, velZ, 0, 0, 0, 0, math.rad(bodyYaw), 0)
end

function render3d()
    if player.perspective() == 0 then return end
    updateCosmeticTools()

    -- velocity interpolated
    local vI = {}
    local percentageOfNewVelocity = (os.clock() - timeOfOldVelocity) / 0.1
    vI[1] = ((1 - percentageOfNewVelocity) * oldVelocity[1]) + (percentageOfNewVelocity * velocity[1])
    vI[2] = ((1 - percentageOfNewVelocity) * oldVelocity[2]) + (percentageOfNewVelocity * velocity[2])
    vI[3] = ((1 - percentageOfNewVelocity) * oldVelocity[3]) + (percentageOfNewVelocity * velocity[3])

    Cape = Object:new(0, 0.3, -0.15)
        :attachToBody()
        :rotateSelf(math.sin(os.clock()) / 10 + math.rad(15), 0, 0)

        :rotateSelf(
            math.clamp(math.clamp(vI[3] * 2, 0, math.rad(75)) - vI[2], 0, math.rad(180)),
            math.clamp(vI[1] * 2, math.rad(-90), math.rad(90)),
            0
        )

    Cube:new(Cape, 0, -0.5, 0, 0.6, 1, 0.15)
        :renderTexture(
            "textures/blocks/wool_colored_white",
            "textures/blocks/wool_colored_white",
            "textures/blocks/wool_colored_gray",
            "textures/blocks/wool_colored_gray",
            "textures/blocks/wool_colored_gray",
            "textures/blocks/wool_colored_gray",
            1, 1
        )
    for i = -1, 1, 2 do
        Cube:new(Cape, 0.2 * i, -1.1, 0, 0.12, 0.2, 0.07)
            :rotateObject(math.sin(os.clock() - 1) / 10, 0, 0)
            :renderTexture(
                "textures/blocks/wool_colored_white",
                "textures/blocks/wool_colored_white",
                "textures/blocks/wool_colored_gray",
                "textures/blocks/wool_colored_gray",
                "textures/blocks/wool_colored_gray",
                "textures/blocks/wool_colored_gray",
                0.2, 0.2
            )
        Cube:new(Cape, 0.07 * i, -1.14, 0, 0.12, 0.38 + (0.1 * i), 0.1)
            :rotateObject(math.sin(os.clock() - 1.2) / 40, 0, 0)
            :renderTexture(
                "textures/blocks/wool_colored_white",
                "textures/blocks/wool_colored_white",
                "textures/blocks/wool_colored_gray",
                "textures/blocks/wool_colored_gray",
                "textures/blocks/wool_colored_gray",
                "textures/blocks/wool_colored_gray",
                0.2, 0.38
            )

        Cube:new(Cape, 0.36 * i, -0.3, 0, 0.12, 0.5, 0.1)
            :rotateObject(math.sin(os.clock() - 1) / 7, 0, 0)
            :renderTexture(
                "textures/blocks/wool_colored_white",
                "textures/blocks/wool_colored_white",
                "textures/blocks/wool_colored_gray",
                "textures/blocks/wool_colored_gray",
                "textures/blocks/wool_colored_gray",
                "textures/blocks/wool_colored_gray",
                0.2, 0.5
            )
    end
end

function max(x, y)
    if x < y then
        return y
    else
        return x
    end
end

function min(x, y)
    if x > y then
        return y
    else
        return x
    end
end
