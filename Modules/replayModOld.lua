name = "Replay Mod OLD"
description = "It is what it is"

positionX = 10
positionY = 10
sizeX = 100
sizeY = 100

function write(fileN, text)
    local file = io.open(fileN, 'w')
    file:write(text)
    io.close(file)
end

function add(file, text, newline)
    if newline then
        write(file, get(file) .. text .. "\n")
    else
        write(file, get(file) .. text)
    end
end

function get(file)
    return io.open(file, 'r'):read("a")
end

function getLines(file)
    string = get(file)
    array = {}
    for s in string:gmatch("[^\r\n]+") do
        table.insert(array, s)
    end
    return array
end

recording = false
client.settings.addBool("Recording?", "recording")

playing = false
playI = 0
function playRecording()
    playing = true
    playI = 0
end

client.settings.addFunction("Play Recording", "playRecording", "Play")

lastRecordingState = false
output = {}
interpolateAmount = 20
function interpolate()
    input = getLines("replay.txt")
    positions = {}
    for i = 1, #getLines("replay.txt"), interpolateAmount do
        coords = {}
        for s in input[i]:gmatch("[^ ]+") do
            table.insert(coords, s)
        end
        table.insert(positions, coords)
    end

    output = {}
    for i = 1, #positions - 1, 1 do
        thisPos = positions[i]
        nextPos = positions[i + 1]
        xDiff = thisPos[1] - nextPos[1]
        yDiff = thisPos[2] - nextPos[2]
        zDiff = thisPos[3] - nextPos[3]

        xIncrement = xDiff / interpolateAmount
        yIncrement = yDiff / interpolateAmount
        zIncrement = zDiff / interpolateAmount

        -- converting to float
        table.insert(output, { thisPos[1] + 0.5, thisPos[2], thisPos[3] + 0.5 })
        for j = 1, interpolateAmount, 1 do
            table.insert(output,
                { thisPos[1] - j * (xIncrement) + 0.5, thisPos[2] - j * (yIncrement), thisPos[3] - j * (zIncrement) + 0.5 })
        end
    end
end

function writeInterpolated()
    -- remove?
    write("")
    for i = 1, #output, 1 do
        add("replay.txt", output[i][1] .. " " .. output[i][2] .. " " .. output[i][3], true)
    end
end

function render()
    if recording ~= lastRecordingState then
        if recording then
            write("")
        else
            interpolate()
            writeInterpolated()
        end
    end

    if recording then
        x, y, z = player.position()
        lx, ly = player.rotation()
        add("replay.txt", x .. " " .. y .. " " .. z .. " " .. lx .. " " .. ly, true)
    end

    if playing and not recording then
        positions = getLines("replay.txt")
        if playI > #getLines("replay.txt") - 1 then
            playI = 0
            playing = false
        end
        playI = playI + 1
        -- client.execute("execute /tp @e[name=test] "..positions[playI])
        client.execute("execute /tp @s " .. positions[playI])
    end

    lastRecordingState = recording
end

loadingWorld = false
px, py, pz = 0, 0, 0
function startLoad()
    px, py, pz = player.position()
    loadingWorld = true
    i = 0
end

client.settings.addAir(10)
client.settings.addFunction("Start World Load", "startLoad", "Load")
i = 0
function update()
    if i > #getLines("worldScan.txt") then
        i = 0
        loadingWorld = false
    end
    if loadingWorld then
        i = i + 0.5
        if i % 1 == 0 then
            dataIn = getLines("worldScan.txt")[i]
            dataOut = {}
            for s in dataIn:gmatch("[^ ]+") do
                table.insert(dataOut, s)
            end
            table.insert(dataOut, coords)
            -- if invisibleBedrock, barrier instead
            if dataOut[4] == "invisibleBedrock" then
                dataOut[4] = "barrier"
            end
            client.execute("execute /setblock " ..
                dataOut[1] + px .. " " .. dataOut[2] + py .. " " .. dataOut[3] + pz .. " " .. dataOut[4] ..
                " " .. dataOut[5])
        end
    end
end
