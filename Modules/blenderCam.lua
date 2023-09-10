name = "Blender Camera Recorder"
description = "Records your player camera to import in Blender."

importLib("logger")

positionX = 320
positionY = 0
sizeX = 60
sizeY = 20

recordKey = client.settings.addNamelessKeybind("Record Toggle", 77)
saveFileName = client.settings.addNamelessTextbox("Save file name:", "recording")

saveFile = nil
isRecording = false
event.listen("KeyboardInput", function(key, down)
    if key == recordKey.value and down then
        isRecording = not isRecording
        if isRecording then
            t = 0
            local px, py, pz = player.position()
            origin = { px, py, pz }
            saveFile = io.open("BlenderCam/" .. saveFileName.value .. ".py", "w")
        else
            local keyframesText = ""
            for i = 1, #keyframes do
                keyframesText = keyframesText .. "\n\t[" .. math.floor(keyframes[i][1] * 60) .. ", "

                keyframesText = keyframesText ..
                    "(" .. keyframes[i][2][1] .. ", " .. keyframes[i][2][2] .. ", " .. keyframes[i][2][3] .. "), "

                keyframesText = keyframesText ..
                    "(" .. keyframes[i][3][1] .. ", " .. keyframes[i][3][2] .. ", " .. keyframes[i][3][3] .. ")],"
            end
            local fov = getFOV() --in degrees and vertical
            fov = 2 * math.atan((16 / 9) * (math.tan(math.rad(fov) / 2)))
            saveFile:write(
                "import bpy\n",
                "animationLength = ", math.floor(keyframes[#keyframes][1] * 60), "\n",
                "keyframes = [", keyframesText, "\n]\n",
                "bpy.ops.object.camera_add(location = keyframes[0][1])\n",
                "camera = bpy.context.object\n",
                "camera.data.lens_unit = 'FOV'\n",
                "camera.data.angle = ", fov, "\n",
                "bpy.context.scene.frame_end = animationLength\n\n",
                "for keyframe in keyframes:\n",
                "\tcamera.location = keyframe[1]\n",
                "\tcamera.keyframe_insert(data_path = 'location', frame = keyframe[0])\n\n",
                "\tcamera.rotation_euler = keyframe[2]\n",
                "\tcamera.keyframe_insert(data_path = 'rotation_euler', frame = keyframe[0])\n"
            )
            saveFile:close()
            keyframes = {}
        end
    else
        if key == 78 and down then
            getFOV()
        end
    end
end)

function postInit()
    if not fs.exist("BlenderCam") then
        fs.mkdir("BlenderCam")
    end
end

keyframes = {}
t = 0
origin = { 0, 0, 0 }
function render2(dt)
    local px, py, pz = player.pposition()
    local pyaw, ppitch = player.rotation()
    t = t + dt
    gfx2.color(51, 51, 51, 100)
    gfx2.fillRoundRect(0, 0, 60, 20, 5)
    if isRecording then
        gfx2.color(255, 0, 0)
        gfx2.fillElipse(10, 10, 5)

        -- in blender, z is "up"
        if (#keyframes == 0 or keyframes[#keyframes][1] ~= t) and (ppitch ~= 0 and pyaw ~= 0) then --if there isnt already a keyframe at the same time
            table.insert(keyframes,
                { t,
                    { (px - origin[1]),       -(pz - origin[3]), py - origin[2] },
                    { math.rad(-ppitch + 90), 0,                 math.rad(-pyaw + 180) }
                })
        end
    end
end

-- function update()
--     log(#keyframes)
-- end

function getFOV()
    workingDir = "LocalState/games/com.mojang/minecraftpe"

    -- thanks chatgpt buddy 🙂
    local function extractX(line)
        local _, _, xValue = line:find("gfx_field_of_view:(%S+)")
        return xValue
    end

    -- Open the file and search for the line containing "gfx_field_of_view:"
    local file = io.open("options.txt", "r")
    local out = nil
    if file then
        for line in file:lines() do
            local xValue = extractX(line)
            if xValue then
                -- print("Found X:", xValue)
                out = xValue
                break
            end
        end
        file:close()
    end

    workingDir = "RoamingState/OnixClient/Scripts/Data"
    return out
end

--[[
import bpy

animationLength = 100

keyframes = []
for i in range(animationLength):
    keyframes.append([i, (i, 0, 0.01*i*i), (i/20*3.14, 0, 0)])

bpy.ops.object.camera_add(location = keyframes[0][1])
camera = bpy.context.object
bpy.context.scene.frame_end = animationLength

for keyframe in keyframes:
    camera.location = keyframe[1]
    camera.keyframe_insert(data_path = "location", frame = keyframe[0])

    camera.rotation_euler = keyframe[2]
    camera.keyframe_insert(data_path = "rotation_euler", frame = keyframe[0])
]]

--[[
    put camera down a bit when crouching
]]
