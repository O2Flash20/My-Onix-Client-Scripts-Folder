name = "World Save"
description = "Saves the world 😂"

positionX = 10
positionY = 10
sizeX = 100
sizeY = 100

r = 15

client.settings.addInt("Save Radius", "r", 5, 100)

function scan()
    write("")
    px, py, pz = player.position()
    for i = 1, r, 1 do
        for j = 1, r, 1 do
            for k = 1, r, 1 do
                x = px + (i - r / 2)
                y = py + (j - r / 2)
                z = pz + (k - r / 2)
                add(dimension.getBlock(x, y, z).name, true)
            end
        end
    end
end

client.settings.addFunction("Scan World", "scan", "Scan")

-- function load()
--     px, py, pz = player.position()
--     for i = 1, r, 1 do
--         for j = 1, r, 1 do
--             for k = 1, r, 1 do
--                 x = px+(i-r/2)
--                 y = py+(j-r/2)
--                 z = pz+(k-r/2)
--                 -- client.execute("execute /setblock "..x.." "..y.." "..z.." ".." "..getLines()[k+r*j+i*r*r])
--                 client.execute("execute /setblock "..x.." "..y.." "..z.." ".." stone")
--             end
--         end
--     end
-- end
function load()
    loading = true
end

client.settings.addFunction("Load World", "load", "Load")

function write(text)
    local file = io.open("worldSave.txt", 'w')
    file:write(text)
    io.close(file)
end

function add(text, newline)
    if newline then
        write(get() .. text .. "\n")
    else
        write(get() .. text)
    end
end

function get()
    return io.open("worldSave.txt", 'r'):read("a")
end

function getLines()
    string = get()
    array = {}
    for s in string:gmatch("[^\r\n]+") do
        table.insert(array, s)
    end
    return array
end

d = 0
loading = false
function update()
    d = d + 0.5
    px, py, pz = player.position()
    if d % 1 == 0 and loading and d < #getLines() then
        z = math.floor((d % r) + 200)
        y = math.floor(((d / r) % r) + 100)
        x = math.floor((d / (r * r)) + 0)
        print(x, y, z)
        if getLines()[d] ~= "air" then
            client.execute("execute /setblock " .. x .. " " .. y .. " " .. z .. " " .. getLines()[d])
        else
            -- client.execute("execute /setblock "..x.." "..y.." "..z.." ".."glass")
        end
    end
end
