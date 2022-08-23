name        = "Direct Message"
description = "Direct messages within Onix Client"

function test()
    -- x, y, z = player.position()

    -- local fileR = io.open("_index.html", 'r')
    -- oldText = fileR:read("a")
    -- io.close(fileR)

    -- local fileW = io.open("_index.html", 'w')
    -- if fileW then fileW:write(oldText .. x .. " " .. y .. " " .. z) end

    -- io.close(fileW)

    -- NEEDS TO BE LOCAL SERVER!!!!!!!!
    network.get("https://biscord.glitch.me", "test")
end

function onNetworkData(code, id, data)
    if id == "test" then
        print(data)
    end
end

client.settings.addFunction("Test send to website", "test", "Enter")
