name="Skinstealer"
description="Steals peoples skins"

function stealMySkin()
    local localSkin = player.skin()
    local localUsername = player.name()
    if localUsername ~= nil then
        local playerName = string.split(localUsername, "\n")
        if string.find(playerName[1],"§.") then
            localUsername = string.gsub(playerName[1],"§.","")
            if string.find(localUsername,"%[") then
                localUsername = string.gsub(localUsername," %[.*%]","")
            end
        else
            return localUsername
        end
    end
    if localSkin ~= nil then
        fs.mkdir("Skinstealer/" .. localUsername)
        print("§aGrabbed your skin!")
        localSkin.save("Skinstealer/" .. localUsername .. "/" .. localUsername .. "_skin.png")
        if localSkin.hasCape() then
            localSkin.saveCape("Skinstealer/" .. localUsername .. "/" .. localUsername .. "_cape.png")
        end
        local file = io.open("Skinstealer/" .. localUsername .. "/" .. localUsername .. "_geometry.json","w")
        file:write(localSkin.geometry())
        file:close()
    end
end

fs.mkdir("Skinstealer")
grabSkin = false
username = ""
usernameTest = ""

skinstealKey = client.settings.addNamelessKeybind("Skinsteal Key", 0)
client.settings.addAir(5)
client.settings.addInfo("Mouse Settings")
disableMiddleClick = client.settings.addNamelessBool("Disable Mouse Button Skin Stealing", false)
disableMouseButtons = client.settings.addNamelessBool("Prohibit Selected Mouse Button Input", false)
mouseButtonToUse = client.settings.addNamelessInt("Mouse Button to Use",1,3,3)
client.settings.addAir(5)
client.settings.addInfo("Misc Settings")
holdToSteal = client.settings.addNamelessBool("Hold to steal skins", false)
client.settings.addFunction("Steal Your Own Skin", "stealMySkin", "Steal")
client.settings.addAir(5)
client.settings.addInfo("Chat Settings")
disableChatMessage = client.settings.addNamelessBool("Disable Chat Message",false)
warningMessage = client.settings.addNamelessBool("Disable \"Could not steal skin.\" message.",false)


function skinsteal()
    if player.facingEntity() then
        if (player.selectedEntity().type ~= "player" or player.selectedEntity().nametag == "") and warningMessage.value == false and disableChatMessage.value == false then
            print("§cCould not steal skin.\nThis could be because it's not a player, or the player is crouching.")
        else
            local p = player.selectedEntity()
            if p.username ~= nil then
                local playerName = string.split(p.username, "\n")
                if string.find(playerName[1],"§.") then
                    username = string.gsub(playerName[1],"§.","")
                    if string.find(username,"%[") then
                        username = string.gsub(username," %[.*%]","")
                    end
                else
                    username = p.username
                end
            else
                playerName = p.type
            end
            if p.skin == nil then return end
            local skin = p.skin()
            if skin ~= nil then
                fs.mkdir("Skinstealer/" .. username)
                if disableChatMessage.value == false and username ~= usernameTest then
                    print("§aStole " .. username .. "'s skin!")
                    usernameTest = username
                end
                skin.save("Skinstealer/" .. username .. "/" .. username .. "_skin.png")
                if skin.hasCape() then
                    skin.saveCape("Skinstealer/" .. username .. "/" .. username .. "_cape.png")
                end
                local file = io.open("Skinstealer/" .. username .. "/" .. username .. "_geometry.json","w")
                file:write(skin.geometry())
                file:close()
            end
        end
    end
end
function update()
    if holdSteal then
        skinsteal()
    end
end
event.listen("KeyboardInput", function(key,down) 
    if key == skinstealKey.value and down then 
        skinsteal()
    end
    if key == skinstealKey and holdToSteal.value == true then
        holdSteal = down
    end
end)
event.listen("MouseInput", function(button,down)
    if button == mouseButtonToUse.value and down and disableMiddleClick.value == false then
        skinsteal()
    end
    if button == mouseButtonToUse.value and disableMiddleClick.value == false and holdToSteal.value == true then
        holdSteal = down
    end
    if disableMouseButtons.value == true and button == mouseButtonToUse.value then
        return true
    end
end)
registerCommand("skinsteal", function(args)
    if args == "" then
        client.notification("Do Win + R and paste to open the filepath!")
        setClipboard("C:/Users/%USERNAME%/AppData/Local/Packages/Microsoft.MinecraftUWP_8wekyb3d8bbwe/RoamingState/OnixClient/Scripts/Data/Skinstealer")
    elseif args == "--lastStolen" then
    client.notification("Do Win + R and paste to open the filepath!")
    setClipboard("C:/Users/%USERNAME%/AppData/Local/Packages/Microsoft.MinecraftUWP_8wekyb3d8bbwe/RoamingState/OnixClient/Scripts/Data/Skinstealer" .. username)
    elseif args == "help" then
        print("§c§lSkinstealer Help§r\n§aArguments can be added with §r§o§7--[argument]§r.§a\n§lArgs:\n§r§7--lastStolen §a§oOpens the folder of the last stolen skin.")
    else
        print("§aUnknown argument \"§7" .. args .. "§a\".\ndo §o§7.skinsteal help §r§afor help")
    end
    end)