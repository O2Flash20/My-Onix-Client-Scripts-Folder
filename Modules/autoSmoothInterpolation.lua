name = "Auto Smooth Interpolation"
description = "test"

importLib("logger")

sizeX = 100
sizeY = 100
positionX = 0
positionY = 0


APPROXIMATIONRESOLUTION = 10
client.settings.addFloat("Resolution", "APPROXIMATIONRESOLUTION", 1, 100)
ALPHA = 0.5
client.settings.addFloat("Alpha", "ALPHA", 0, 1)
TENSION = 0
client.settings.addFloat("Tension", "TENSION", 0, 1)

function preparePointsForSpline(points)
    local output = {}
    table.insert(output, points[1])
    for i = 1, #points do
        table.insert(output, points[i])
    end
    table.insert(output, points[#points])

    return output
end

points = preparePointsForSpline({ 5, 100, 2, 60, 20 })
points2D = preparePointsForSpline({ { 0, 10 }, { 2, 5 }, { 6, 100 }, { 6.5, 10 }, { 8, 10 }, { 10, 50 } })
Time = 0
function render2(dt)
    Time = Time + dt
    local t = Time % points2D[#points2D][1]

    local times = {}
    for i = 1, #points2D do
        table.insert(times, points2D[i][1])
    end

    local x = timeToSplineInput(t, times)

    local ys = {}
    for i = 1, #points2D do
        table.insert(ys, points2D[i][2])
    end
    local y = catmullRomSpline1D(ys, x, ALPHA, TENSION)
    gfx2.fillRect(t * 10, -y, 10, 10)
end

function catmullRomSpline1D(points, t, alpha, tension)
    local i = math.floor(t) + 1

    if #points < i + 3 then
        return points[#points - 1]
    end

    local p1 = points[i]
    local p2 = points[i + 1]
    local p3 = points[i + 2]
    local p4 = points[i + 3]

    -- stop it from giving errors of two points are the same (there's probably a better way of doing this)
    if p1 == p2 then p2 = p2 + 0.001 end
    if p2 == p3 then p3 = p3 + 0.001 end
    if p3 == p4 then p4 = p4 + 0.001 end

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

function timeToSplineInput(t, times)
    local ar = 1 / APPROXIMATIONRESOLUTION
    local timesAppr = approximateCurve(
        function(x)
            return catmullRomSpline1D(times, x, 0.5, 0)
        end,
        #times, ar
    )

    local x = 0
    for i = 1, #timesAppr do
        if t >= timesAppr[i] and t < timesAppr[i + 1] then
            x = map(t, timesAppr[i], timesAppr[i + 1], 0, 1)
            x = x + i
        end
    end

    return x / APPROXIMATIONRESOLUTION
end

-- maps a value from one range to another
function map(value, min1, max1, min2, max2)
    return (value - min1) * ((max2 - min2) / (max1 - min1)) + min2
end
