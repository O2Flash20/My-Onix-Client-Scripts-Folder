name = "Vectors Test"
description = "A mod to test out the vectors lib"

importLib("vectors")
importLib("logger")

function update()
    local a = vec:new(10, 30, 20)
    a:setComponent("w", 6)
    log(a.components)
end
