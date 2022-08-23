command = "scan"
help_message = "scans the world to load later: .scan x1 y1 z1 x2 y2 z2"

function execute(args)
    write("")
    input = {}
    local sX, sY, sZ, eX, eY, eZ
    for s in args:gmatch("[^ ]+") do
        table.insert(input, s)
    end
    -- get values in the right format/order
    for i = 1, 4, 1 do
        if input[1] - input[4] < 0 then
            sX = input[1]
            eX = input[4]
        else
            sX = input[4]
            eX = input[1]
        end
        if input[2] - input[5] < 0 then
            sY = input[2]
            eY = input[5]
        else
            sY = input[5]
            eY = input[2]
        end
        if input[3] - input[6] < 0 then
            sZ = input[3]
            eZ = input[6]
        else
            sZ = input[6]
            eZ = input[3]
        end
    end
    print("Scanned from " .. sX .. " " .. sY .. " " .. sZ .. " to " .. eX .. " " .. eY .. " " .. eZ)
    -- CHECK FOR BORDERS
    px, py, pz = player.position()
    for z = sZ, eZ, 1 do
        for x = sX, eX, 1 do
            for y = sY, eY, 1 do
                if dimension.getBlock(x, y, z).name ~= "air" then
                    if isTransparent(dimension.getBlock(x + 1, y, z).name) or
                        isTransparent(dimension.getBlock(x, y + 1, z).name) or
                        isTransparent(dimension.getBlock(x, y, z + 1).name) or
                        isTransparent(dimension.getBlock(x - 1, y, z).name) or
                        isTransparent(dimension.getBlock(x, y - 1, z).name) or
                        isTransparent(dimension.getBlock(x, y, z - 1).name) then
                        add(x - px ..
                            " " ..
                            y - py ..
                            " " .. z - pz ..
                            " " .. dimension.getBlock(x, y, z).name .. " " .. dimension.getBlock(x, y, z).data, true)
                    end
                end
            end
        end
    end
end

filename = "worldScan.txt"

function write(text)
    local file = io.open(filename, 'w')
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
    return io.open(filename, 'r'):read("a")
end

function isTransparent(name)
    -- stairs, trapdoors, doors, signs (standing, wall)
    transparentBlocks = { "air", "barrier", "beacon", "ice", "glass", "stained_glass", "leaves", "leaves2",
        "azalea_leaves", "azalea_leaves_flowered", "amethyst_cluster", "large_amethyst_bud", "medium_amethyst_bud",
        "small_amethyst_bud", "anvil", "bamboo", "bed", "bell", "brewing_stand", "big_dripleaf", "cactus", "cake",
        "campfire", "candle", "carpet", "cauldron", "chain", "chest", "chorus_flower", "chorus_plant", "cobweb", "cocoa",
        "conduit", "grass_path", "dragon_egg", "enchanting_table", "end_portal_frame", "end_rod", "ender_chest",
        "farmland", "fence", "fence_gate", "acacia_fence_gate", "birch_fence_gate", "crimson_fence", "crimson_fence_gate",
        "dark_oak_fence_gate", "jungle_fence_gate", "nether_brick_fence", "spruce_fence_gate", "warped_fence",
        "warped_fence_gate", "flower_pot", "glass_pane", "stained_glass_pane", "gridstone", "honey_block", "iron_bars",
        "ladder", "lantern", "soul_lantern", "lectern", "lightning_rod", "waterlily", "skull", "moss_carpet",
        "pointed_dripstone", "scaffolding", "sea_pickle", "blackstone_slab", "cobbled_deepslate_slab", "crimson_slab",
        "cut_copper_slab", "deepslate_brick_slab", "deepslate_tile_slab", "exposed_cut_copper_slab",
        "oxidized_cut_copper_slab", "polished_blackstone_brick_slab", "polished_blackstone_slab",
        "polished_deepslate_slab", "stone_slab", "stone_slab2", "stone_slab3", "stone_slab4", "warped_slab",
        "waxed_cut_copper_slab", "waxed_exposed_cut_copper_slab", "waxed_oxidized_cut_copper_slab",
        "waxed_weathered_cut_copper_slab", "weathered_cut_copper_slab", "wooden_slab", "snow_layer", "stonecutter",
        "sweet_berry_bush", "turtle_egg", "blackstone_wall", "cobblestone_wall", "cobbled_deepslate_wall",
        "deepslate_brick_wall", "deepslate_tile_wall", "polished_blackstone_brick_wall", "polished_blackstone_wall",
        "polished_deepslate_wall", "daylight_detector", "hopper", "comparator", "repeater", "trapped_chest", "banner",
        "cave_vines", "coral", "coral_fan", "coral_fan_dead", "deadbush", "wheat", "beetroot", "potatoes", "carrots",
        "melon_stem", "pumpkin_stem", "fern", "double_plant", "tallgrass", "red_flower", "yellow_flower", "fire",
        "glow_lichen", "hanging_roots", "portal", "brown_mushroom", "red_mushroom", "invisibleBedrock", "concretepowder",
        "sand", "gravel", "nether_wart", "redstone_wire", "redstone_torch", "lever", "piston", "sticky_piston" }
    for i = 1, #transparentBlocks, 1 do
        if name == transparentBlocks[i] then
            return true
        end
    end
    return false
end
