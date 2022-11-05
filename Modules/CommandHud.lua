name="Command Block Hud"
description="Shows you contents of a command block"

positionX = 50
positionY = 50
sizeX = 80
sizeY = 40

textColor = client.settings.addNamelessColor("Text Color", {255,255,255})

function getCommandBlockTexture(name)
    if name == "command_block" then
        return "textures/blocks/command_block"
    elseif name == "repeating_command_block" then
        return "textures/blocks/repeating_command_block_back_mipmap"
    elseif name == "chain_command_block" then
        return "textures/blocks/chain_command_block_back_mipmap"
    end
    return nil
end


lastServerBlockEntity = os.clock()
event.listen("LocalServerUpdate", function()
    if player.facingBlock() == false then return end
    local texture = getCommandBlockTexture(dimension.getBlock(player.selectedPos()).name)
    if texture == nil then return end --not looking at command block
    local x,y,z = player.selectedPos()
    nbt = dimension.getBlockEntity(x, y, z, true)
    lastServerBlockEntity = os.clock()
    --print(nbt.strf)
end)

function render()
    if player.facingBlock() == false then return end
    local texture = getCommandBlockTexture(dimension.getBlock(player.selectedPos()).name)
    if texture == nil then return end --not looking at command block

    if (os.clock() - lastServerBlockEntity) > 4 or nbt == nil then
        nbt = dimension.getBlockEntity(player.selectedPos())
    end

    local font = gui.font()
    local fontSize = 0.8
    if font.isMinecrafttia == true then
        font.height = font.height - 0.15
    else
        fontSize = 1
        font.height = font.height + 1.2
    end
    local textsizeX = 0
    gfx.texture(0, 0, 40, 40, texture)
    
    gfx.color(textColor)
    textsizeX = math.max(font.width("cmd: " .. nbt.Command, fontSize), textsizeX)
    if nbt.CustomName == "" then
        gfx.text(44, 0, "Hello i'm " .. "Nameless", fontSize)
    else
        gfx.text(44, 0, "Hello i'm " .. nbt.CustomName, fontSize)
    end

    textsizeX = math.max(font.width("cmd: " .. nbt.Command, fontSize), textsizeX)
    gfx.text(44, font.height, "cmd: " .. nbt.Command, fontSize)

    local paramTxt = "    "
    for _, val in Nbt(nbt.LastOutputParams) do
        paramTxt = paramTxt .. val .. " "
    end

    --textsizeX = math.max(font.width("last out: " .. nbt.LastOutput .. paramTxt, fontSize), textsizeX)
    if nbt.TrackOutput ~= 0 then
        gfx.text(44, font.height*2, "last out: " .. nbt.LastOutput .. paramTxt, fontSize)
    else
        gfx.text(44, font.height*2, "last out: " .. "Off", fontSize)
    end

    textsizeX = math.max(font.width("need reds: " .. nbt.LPRedstoneMode .. " auto: " .. nbt.auto, fontSize), textsizeX)
    gfx.text(44, font.height*3, "need reds: " .. nbt.LPRedstoneMode .. " auto: " .. nbt.auto, fontSize)

    textsizeX = math.max(font.width("Tick Delay: " .. nbt.TickDelay, fontSize), textsizeX)
    gfx.text(44, font.height*4, "Tick Delay: " .. nbt.TickDelay, fontSize)

    sizeX = textsizeX + 44
    sizeY = 40
end
