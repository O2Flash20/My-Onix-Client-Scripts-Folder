name = "Fill Better"
description = "actual fill"

function test()
    -- print("e")
    -- 10 80 -150

    for i = 1, 20, 1 do
        for j = 1, 20, 1 do
            for k = 1, 20, 1 do
                client.execute("execute /summon armor_stand " .. (10 + j) .. " " .. 80 + k .. " " .. (-210 + i))
            end
        end
    end

    sleep(0.3)

    client.execute("execute /execute @e[type=armor_stand] ~ ~ ~ setblock ~ ~ ~ planks")

    sleep(0.3)

    client.execute("execute /kill @e[type=armor_stand]")
end

client.settings.addFunction("Fill test", "test", "Enter")


function sleep(a)
    local sec = tonumber(os.clock() + a);
    while (os.clock() < sec) do
    end
end
