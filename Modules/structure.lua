name = "Structurer"
description = "Save and load a structure"

positionX = 100
positionY = 100
sizeX = 50
sizeY = 50

recording = false

client.settings.addBool("Record", "recording")

importLib('renderthreeD.lua')

function write(text)
    local file = io.open("replay.txt", 'w')
    file:write(text)
    io.close(file)
end

function add(text, newline)
    if newline then
        write(get()..text.."\n")
    else
        write(get()..text)
    end
end

function get()
    return io.open("replay.txt", 'r'):read("a")
end

function getLines()
    string = get()
    array = {}
    for s in string:gmatch("[^\r\n]+") do
        table.insert(array, s)
    end
    return array
end

i = 0
function update()
    if recording then
        x, y, z = player.position()
        lx, ly = player.rotation()
        add(x.." "..y.." "..z.." "..lx.." "..ly, true)
    else
        positions = getLines()
        i = (i + 1) % #positions

        client.execute("execute /tp @s "..positions[i])
    end
end

function render3d()
    gfx.color(255,255,255,64)
    for i = 1, 10, 1 do
        cube(i, 101, 0, 1)
    end
end