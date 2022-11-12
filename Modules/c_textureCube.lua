name = "Cosmetic Texture Test"
description = "hello"

importLib("cosmeticTools")
importLib("logger")

CubeTexture = AnimatedTexture:new(
    {
        "textures/blocks/stonebrick",
        "textures/blocks/stonebrick_mossy",
        "textures/blocks/stonebrick",
        "textures/blocks/stonebrick",
        "textures/blocks/planks_oak",
        "textures/blocks/planks_oak"
    },
    5
)

function update()
    CubeTexture:update()
    log(t)
end

function render3d()
    updateCosmeticTools()

    Obj = Object:new(0, 2, 0)
        :attachToHead()
    Cube:new(Obj, 0, 0, 0, 1, 1, 1)
        :rotateSelf(math.sin(t), t, 0)
        :renderTexture(
            CubeTexture.texture,
            nil, nil, nil, nil, nil,
            1, 1
        )

    Sphere:new(Obj, 1, 0, 0, 0.2)
        :renderTexture(CubeTexture.texture)
end
