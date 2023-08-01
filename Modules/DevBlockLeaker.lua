name = "Dev Block Leaker"
description = "See the unseen! May be laggy but this time it's because of the amount of cubes being rendered."

importLib("cosmeticTools")
importLib("vectors")

barriers = client.settings.addNamelessBool("Barriers", true)
lightBlocks = client.settings.addNamelessBool("Light Blocks", true)
voidBlocks = client.settings.addNamelessBool("Void Blocks", true)
radius = client.settings.addNamelessInt("Radius", 1, 1024, 32)

BarrierList = {}
LightList = {}
VoidList = {}

function update()
    BarrierList = dimension.findBlock("barrier", 0, radius.value)
    LightList = dimension.findBlock("light_block", -1, radius.value)
    VoidList = dimension.findBlock("structure_void", 0, radius.value)
end

local function renderBlockList(blockList, texturePath, getBrightness)
    for i = 1, #blockList do
        local pos = blockList[i]
        local posVec = vec:new(pos[1], pos[2], pos[3])

        if playerRot:dot(posVec:sub(playerPos)) > 0 then
            if texturePath ~= "textures/blocks/structure_void" then
                local texture
                if getBrightness then
                    local brightness = dimension.getBrightness(pos[1], pos[2], pos[3])
                    texture = texturePath .. brightness .. ".png"
                else
                    texture = texturePath .. ".png"
                end
                renderFacingPlayerQuad(pos[1], pos[2], pos[3], texture)
            else
                local block = Object:new(pos[1], pos[2], pos[3]):attachNone()

                local texture = texturePath .. ".png"

                Cube:new(block, 0.5, 0.5, 0.5, 1, 1, 1):renderTexture(gfx.loadTexture(texture))
            end
        end
    end
end

function render3d()
    px, py, pz = player.pposition()
    pyaw, ppitch = player.rotation()
    playerPos = vec:new(px, py, pz)
    playerRot = vec:fromAngle(1, math.rad(pyaw + 90), math.rad(-ppitch))

    local selectSlot = player.inventory().selected
    local selectedItem = player.inventory().at(selectSlot)
    if barriers.value and (not selectedItem or selectedItem.blockname ~= "barrier") then
        renderBlockList(BarrierList, "textures/blocks/barrier", false)
    end
    if lightBlocks.value and (not selectedItem or selectedItem.blockname ~= "light_block") then
        renderBlockList(LightList, "textures/items/light_block_", true)
    end
    if voidBlocks.value and (not selectedItem or selectedItem.blockname ~= "structure_void") then
        renderBlockList(VoidList, "textures/blocks/structure_void", false)
    end
end

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

function renderFacingPlayerQuad(x, y, z, texture)
    local blockPos = vec:new(x + 0.5, y + 0.5, z + 0.5)

    local topLeft = vec:new(-0.5, 0.5, 0)
    local topRight = vec:new(0.5, 0.5, 0)
    local bottomRight = vec:new(0.5, -0.5, 0)
    local bottomLeft = vec:new(-0.5, -0.5, 0)

    local toRotate = vec:new(px, py, pz):sub(blockPos):dir()

    local topLeftRot = rotatePoint(
        topLeft.x, topLeft.y, topLeft.z,
        0, 0, 0, -toRotate[2], -toRotate[1] + math.rad(90), 0
    )
    local topRightRot = rotatePoint(
        topRight.x, topRight.y, topRight.z,
        0, 0, 0, -toRotate[2], -toRotate[1] + math.rad(90), 0
    )
    local bottomRightRot = rotatePoint(
        bottomRight.x, bottomRight.y, bottomRight.z,
        0, 0, 0, -toRotate[2], -toRotate[1] + math.rad(90), 0
    )
    local bottomLeftRot = rotatePoint(
        bottomLeft.x, bottomLeft.y, bottomLeft.z,
        0, 0, 0, -toRotate[2], -toRotate[1] + math.rad(90), 0
    )

    gfx.tquad(
        bottomLeftRot[1] + blockPos.x, bottomLeftRot[2] + blockPos.y, bottomLeftRot[3] + blockPos.z, 0, 1,
        bottomRightRot[1] + blockPos.x, bottomRightRot[2] + blockPos.y, bottomRightRot[3] + blockPos.z, 1, 1,
        topRightRot[1] + blockPos.x, topRightRot[2] + blockPos.y, topRightRot[3] + blockPos.z, 1, 0,
        topLeftRot[1] + blockPos.x, topLeftRot[2] + blockPos.y, topLeftRot[3] + blockPos.z, 0, 0,
        texture
    )
end
