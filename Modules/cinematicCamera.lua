-- Made by O2Flash20 🙂

name = "Camera Animations"
description = "A camera animation system"

sizeX = 300
sizeY = 50
positionX = 0
positionY = 0

importLib("logger")

playing = false
timeInReplay = 0
lastKeyframe = 1
function render2(dt)
    -- background
    gfx2.color(38, 38, 38, 230)
    gfx2.fillRoundRect(0, 0, 300, 50, 2)
    gfx2.color(255, 255, 255, 115)
    gfx2.drawRoundRect(0, 0, 300, 50, 1, 1)

    -- time slider
    gfx2.color(26, 26, 16)
    gfx2.fillRoundRect(30, 25, 240, 15, 5)

    -- keyframes
    for _, keyframe in pairs(keyframes) do
        if keyframe.time == math.floor(currentTime * 10) / 10 then
            gfx2.color(255, 120, 0)
        else
            gfx2.color(255, 0, 0)
        end
        gfx2.fillQuad(
            30 + keyframe.time * (240 / totalTime) - 2.5,
            25,
            30 + keyframe.time * (240 / totalTime),
            27.5,
            30 + keyframe.time * (240 / totalTime) + 2.5,
            25,
            30 + keyframe.time * (240 / totalTime),
            22.5
        )
    end

    -- selected keyframe arrow
    local selectedK = keyframes[selectedKeyframe]
    if selectedK then
        gfx2.color(255, 255, 255)
        gfx2.fillTriangle(
            30 + selectedK.time * (240 / totalTime) - 2.5, 22,
            30 + selectedK.time * (240 / totalTime), 25,
            30 + selectedK.time * (240 / totalTime) + 2.5, 22
        )
    end

    -- pointer
    gfx2.color(255, 255, 255)
    gfx2.drawRoundRect(
        (currentTime / totalTime) * (sizeX - 60) + 30 - 1, 25,
        2, 15,
        1, 1
    )

    -- time reading
    gfx2.text(
        (currentTime / totalTime) * (sizeX - 60) + 20, 40,
        stylizedTime(currentTime)
    )

    if playing then
        --[[
            timeInReplay = timeInReplay + dt
            currentTime = timeInReplay
    
            local lastK = keyframes[lastKeyframe]
            local nextK = keyframes[lastKeyframe + 1]
    
            local currentX = map(timeInReplay, lastK.time, nextK.time, lastK.position[1], nextK.position[1])
            local currentY = map(timeInReplay, lastK.time, nextK.time, lastK.position[2], nextK.position[2])
            local currentZ = map(timeInReplay, lastK.time, nextK.time, lastK.position[3], nextK.position[3])
            local currentYaw = map(timeInReplay, lastK.time, nextK.time, lastK.rotation[1], nextK.rotation[1])
            local currentPitch = map(timeInReplay, lastK.time, nextK.time, lastK.rotation[2], nextK.rotation[2])
    
            client.execute(
                "execute /tp @s "
                .. currentX .. " "
                .. currentY - 1.6 .. " "
                .. currentZ .. " "
                .. currentYaw .. " "
                .. currentPitch
            )
    
            if timeInReplay >= nextK.time then
                lastKeyframe = lastKeyframe + 1
                log("Next")
            end
            -- log(lastK.time)
    
            if timeInReplay > keyframes[#keyframes].time then
                print("No more keyframes")
                playing = false
                timeInReplay = 0
                currentTime = 0.0
                lastKeyframe = 1
            end
        ]]

        timeInReplay = timeInReplay + dt
        currentTime = timeInReplay

        if currentTime > keyframes[#keyframes].time then
            log("done")
            print("No more keyframes")
            playing = false
            timeInReplay = 0
            currentTime = 0.0
            lastKeyframe = 1
        end

        local lastPathPoint
        local nextPathPoint
        for i = 1, #PATHPOINTS, 1 do
            if currentTime >= PATHPOINTS[i] and currentTime < PATHPOINTS[i + 1] then
                lastPathPoint = i
                nextPathPoint = i + 1
                break
            end
        end

        local smoothedTime = map(
            currentTime, PATHPOINTS[lastPathPoint], PATHPOINTS[nextPathPoint], lastPathPoint, nextPathPoint
        ) / 10

        local lastK = keyframes[math.floor(smoothedTime) + 1]
        local nextK = keyframes[math.floor(smoothedTime) + 2]

        local currentX = map(
            smoothedTime, math.floor(smoothedTime), math.floor(smoothedTime) + 1,
            lastK.position[1],
            nextK.position[1]
        )
        local currentY = map(
            smoothedTime, math.floor(smoothedTime), math.floor(smoothedTime) + 1,
            lastK.position[2], nextK.position[2]
        )
        local currentZ = map(
            smoothedTime, math.floor(smoothedTime), math.floor(smoothedTime) + 1,
            lastK.position[3], nextK.position[3]
        )
        local currentYaw = map(
            smoothedTime, math.floor(smoothedTime), math.floor(smoothedTime) + 1,
            lastK.rotation[1], nextK.rotation[1]
        )
        local currentPitch = map(
            smoothedTime, math.floor(smoothedTime), math.floor(smoothedTime) + 1,
            lastK.rotation[2], nextK.rotation[2]
        )

        client.execute(
            "execute /tp @s "
            .. currentX .. " "
            .. currentY - 1.6 .. " "
            .. currentZ .. " "
            .. currentYaw .. " "
            .. currentPitch
        )

        -- client.execute(
        --     "execute /tp @s "
        --     ..
        --     smoothedTime ..
        --     " "
        --     .. 70 - 1.6 .. " "
        --     .. 0 .. " "
        --     .. 0 .. " "
        --     .. 0
        -- )
    end

    -- -- SPLINE DEMO
    -- -- generate points for the catmull-rom
    -- local points = {}
    -- for i = 1, #keyframes do
    --     if #keyframes < 2 then return end
    --     table.insert(points, keyframes[i].time)
    --     if i == 1 then table.insert(points, keyframes[i].time - 1) end
    --     if i == #keyframes then table.insert(points, keyframes[i].time + 1) end
    -- end

    -- -- generate points that follow the curve of the catmull-rom
    -- local approximatedPoints = approximateCurve(
    --     function(x)
    --         return catmullRomSpline1D(points, x, 0.5, 0)
    --     end
    --     , #points - 3, 0.1
    -- )

    -- -- draw lines between those points
    -- for i = 1, #approximatedPoints - 1, 1 do
    --     gfx2.color(i * 10, 0, 0)
    --     gfx2.drawLine(approximatedPoints[i], -i, approximatedPoints[i + 1], -(i + 1), 2)
    -- end
end

currentTime = 0.0
totalTime = 30 -- start time end time instead?

function createKeyFrame()

    -- delete the old one there
    for i = 1, #keyframes do
        if keyframes[i].time == math.floor(currentTime * 10) / 10 then
            table.remove(keyframes, i)
            break
        end
    end

    table.insert(keyframes, {
        position = { px, py, pz },
        rotation = { yaw, pitch },
        time = currentTime
    })

    sortKeyframes()
end

selectedKeyframe = 0
function selectKeyframe()
    local closestTime = 1000000000
    local closestIndex = -1
    for i = 1, #keyframes do
        if math.abs(keyframes[i].time - currentTime) < closestTime then
            closestTime = math.abs(keyframes[i].time - currentTime)
            closestIndex = i
        end
    end

    selectedKeyframe = closestIndex
end

function moveSelectedKeyframe()
    if keyframes[selectedKeyframe] then
        keyframes[selectedKeyframe].time = currentTime
        sortKeyframes()
    end
end

-- sorts the keyframes from earliest to latest
function sortKeyframes()
    local keyframeTimes = {}
    for i = 1, #keyframes do
        table.insert(keyframeTimes, keyframes[i].time)
    end

    orderedIndices = insertionSort(keyframeTimes)

    local output = {}
    for i = 1, #orderedIndices do
        table.insert(output, keyframes[orderedIndices[i]])
    end

    selectedKeyframe = orderedIndices[selectedKeyframe] or 0

    keyframes = output
end

-- takes in an array of values and returns the indices corresponding to the values smallest -> largest
function insertionSort(arr)
    local len = #arr

    local indices = {}
    for i = 1, len, 1 do
        table.insert(indices, i)
    end

    local index = 2
    while index <= len do
        local curr = arr[index]
        local currI = indices[index]
        local prev = index - 1

        while prev >= 1 and arr[prev] > curr do
            arr[prev + 1] = arr[prev]
            indices[prev + 1] = indices[prev] --
            prev = prev - 1
        end

        arr[prev + 1] = curr
        indices[prev + 1] = currI --

        index = index + 1
    end

    return indices
end

keyframes = {}
togglePlayKey = 0x39
client.settings.addKeybind("Start/Stop playing: ", "togglePlayKey")

setKeyframeKey = 0x2D
client.settings.addKeybind("Set Keyframe: ", "setKeyframeKey")

event.listen("KeyboardInput", function(key, down)
    -- create keyframe
    if key == setKeyframeKey and down then
        if selectedKeyframe ~= 0 then
            -- delete keyframe
            table.remove(keyframes, selectedKeyframe)
            selectedKeyframe = 0
        else
            -- add keyframe
            createKeyFrame()
        end
    end

    -- select keyframe
    if key == 0x38 and down then
        if selectedKeyframe ~= 0 then
            selectedKeyframe = 0
        else
            selectKeyframe()
        end
    end

    -- start/stop playing
    if key == togglePlayKey and down then
        if not playing then
            timeInReplay = currentTime
        end
        playing = not playing
        currentTime = math.floor(currentTime * 10) / 10
    end

    -- move the cursor
    local RIGHTARROW = 0x27
    local LEFTARROW = 0x25
    local UPARROW = 0x26
    local DOWNARROW = 0x28
    if key == RIGHTARROW and down then
        currentTime = currentTime + 1
        moveSelectedKeyframe()
    end
    if key == LEFTARROW and down then
        currentTime = currentTime - 1
        moveSelectedKeyframe()
    end
    if key == UPARROW and down then
        currentTime = currentTime + 0.1
        moveSelectedKeyframe()
    end
    if key == DOWNARROW and down then
        currentTime = currentTime - 0.1
        moveSelectedKeyframe()
    end
    currentTime = math.clamp(currentTime, 0, totalTime)
end)

PATHPOINTS = {}
lastKeyframes = {}
function update(dt)
    px, py, pz = player.pposition()
    yaw, pitch = player.rotation()

    -- time time to update the path?
    if lastKeyframes ~= keyframes and #keyframes >= 2 then
        local points = {}

        for i = 1, #keyframes do
            table.insert(points, keyframes[i].time)
            if i == 1 then table.insert(points, keyframes[i].time - 1) end
            if i == #keyframes then table.insert(points, keyframes[i].time + 1) end
        end

        PATHPOINTS = approximateCurve(
            function(x)
                return catmullRomSpline1D(points, x, 0.5, 0)
            end
            , #points - 3, 0.1
        )
    end
    lastKeyframes = keyframes
end

-- maps a value from one range to another
function map(value, min1, max1, min2, max2)
    return (value - min1) * ((max2 - min2) / (max1 - min1)) + min2
end

function stylizedTime(seconds)
    seconds = math.floor(seconds * 10) / 10
    minutes = math.floor(seconds / 60)
    seconds = seconds % 60

    if seconds < 10 then seconds = "0" .. seconds end
    if minutes < 10 then minutes = "0" .. minutes end

    return minutes .. ":" .. seconds
end

--[[
have a table of all keyframes with their pos, rot and time
    a curve (catmull-rom?) will interpolate between them
    keyframes need to be sorted by time?
    the time can be set and reset
        if you "select" a keyframe and move "currentTime" it will change the time of the keyframe
have a visual representation of the motion of the camera with render3

*catmull-rom curve interpolating between points
    visualized with 3d lines
    creates a list of straight-line interpolations?
*save keyframes to a file

https://dev.to/ndesmic/splines-from-scratch-catmull-rom-3m66
https://qroph.github.io/2018/07/30/smooth-paths-using-catmull-rom-splines.html

catmull rom splines will always be each spline is t=[0, 1]
so if a curve is 1s long, you can use the raw
but if it's two seconds long, make t go two times faster
but that will create lurches in velocity
so make another catmull-rom that is [0, 1]time vs desired time
then if you plug if a y value of desired time, if will give you the [0, 1]time
and it will be smooth
]]

function catmullRomSpline1D(points, t, alpha, tension)
    local i = math.floor(t) + 1

    if #points < i + 3 then
        return points[#points - 1]
    end

    local p1 = points[i]
    local p2 = points[i + 1]
    local p3 = points[i + 2]
    local p4 = points[i + 3]

    t = t - math.floor(t)

    local t12 = math.abs(p1 - p2) ^ alpha
    local t23 = math.abs(p2 - p3) ^ alpha
    local t34 = math.abs(p3 - p4) ^ alpha

    local m1 = (1 - tension) *
        (p3 - p2 + t23 * ((p2 - p1) / t12 - (p3 - p1) / (t12 + t23)))

    local m2 = (1 - tension) *
        (p3 - p2 + t23 * ((p4 - p3) / t34 - (p4 - p2) / (t23 + t34)))

    local a = 2 * (p2 - p3) + m1 + m2
    local b = -3 * (p2 - p3) - m1 - m1 - m2
    local c = m1
    local d = p2

    return a * t ^ 3 +
        b * t ^ 2 +
        c * t +
        d
end

function approximateCurve(curveFunction, max, delta)
    local points = {}
    for i = 0, max, delta do
        table.insert(points, curveFunction(i))
    end
    return points
end
