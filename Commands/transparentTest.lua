command="test"
help_message="the"


function execute(name)
    if isTransparent(name) then
        print("true")

    else
        print("false")
    end
end

function isTransparent(name)
    transparentBlocks = {"air", "barrier", "beacon", "ice", "glass", "leaves", "leaves2", "azalea_leaves", "azalea_leaves_flowered", "amethyst_cluster", "large_amethyst_bud", "medium_amethyst_bud", "small_amethyst_bud", "anvil", "bamboo", "bed", "bell", "brewing_stand", "big_dripleaf", "cactus", "cake", "campfire", "candle", "carpet", "cauldron", "chain", "chest", "chorus_flower", "chorus_plant", "cobweb", "cocoa", "conduit"}
    for i = 1, #transparentBlocks, 1 do
        if name == transparentBlocks[i] then
            return true
        end
    end
    return false
end