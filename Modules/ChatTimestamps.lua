name = "Chat Timestamps"
description = "Adds timestamps to chat"

function onChat(message,username,type)
    timestamped = "§o§8" .. os.date("%X") .. "§r " .. message
    print(timestamped)
    return true
end

event.listen("ChatMessageAdded", onChat)