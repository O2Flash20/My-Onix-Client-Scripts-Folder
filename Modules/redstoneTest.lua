name = "Redstone Utility Power Level"
description = "the"

positionX = 500
positionY = 25
sizeX = 100
sizeY = 100

function update()

end

function render()
    gfx.color(40, 40, 40, 150)
    gfx.rect(-2, -1, 16, 10)
    gfx.color(255, 255, 255)
    if dimension.getBlock(player.selectedPos()).name == "redstone_wire" then
        gfx.text(0, 0, dimension.getBlock(player.selectedPos()).data)
    end
end
