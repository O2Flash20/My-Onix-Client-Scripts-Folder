name = "Cubecraft Auto GG"
description = "Auto GG for Cubecraft"

event.listen("ChatMessageAdded", function(message)
    if message == "§7§7-------------------------------§r" then
        client.execute("say gg")
    end
end)
