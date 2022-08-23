name="Dev Block Leaker"
description="See the unseen!!"

importLib("renderthreeD")

--[[
    Forked by Helix, big ty to onix for getting me started
    Pls dont look at my messy unotimized code pls
]]


B = false
Lb = false
Sv = false
--ntk ="Avoid turning everything on! The script is vary resource heavy!"

--client.settings.addInfo(ntk)
client.settings.addAir(5)
client.settings.addBool("Barriers", "B")
client.settings.addBool("Light Blocks", "Lb")
client.settings.addBool("Void Blocks", "Sv")
--I feel like if I add invis bedrock and border blocks the game would drop to 1 fps while trying and render everything
client.settings.addAir(5)
HighlightRadius = 10
client.settings.addInt("Radius", "HighlightRadius", 3, 50)

BarrierList = {}
LightList = {}
VoidList = {}

function update(dt)
    local player_x, player_y, player_z = player.position()
    BarrierList = {}
    if (B == true) then
        for x=player_x - HighlightRadius,player_x + HighlightRadius do
            for y=player_y - HighlightRadius,player_y + HighlightRadius do
                for z=player_z - HighlightRadius,player_z + HighlightRadius do
                  local block = dimension.getBlock(x, y, z)
                  if (block.id == 416) then
                    table.insert(BarrierList, {x=x,y=y,z=z})
                  end
                end
            end
        end
    end
    local player_x, player_y, player_z = player.position()
    LightList = {}
    if (Lb == true) then
        for x=player_x - HighlightRadius,player_x + HighlightRadius do
            for y=player_y - HighlightRadius,player_y + HighlightRadius do
                for z=player_z - HighlightRadius,player_z + HighlightRadius do
                  local block = dimension.getBlock(x, y, z)
                  if (block.id == 470) then
                    table.insert(LightList, {x=x,y=y,z=z})
                  end
                end
            end
        end
    end
    local player_x, player_y, player_z = player.position()
    VoidList = {}
    if (Sv == true) then
        for x=player_x - HighlightRadius,player_x + HighlightRadius do
            for y=player_y - HighlightRadius,player_y + HighlightRadius do
                for z=player_z - HighlightRadius,player_z + HighlightRadius do
                  local block = dimension.getBlock(x, y, z)
                  if (block.id == 217) then
                    table.insert(VoidList, {x=x,y=y,z=z})
                  end
                end
            end
        end
    end
end

function render3d()
    gfx.color(225,0,0,70)
    for _, pos in pairs(BarrierList) do
        cube(pos.x, pos.y, pos.z, 1)
    end
    gfx.color(255,255,77,70)
    for _, pos in pairs(LightList) do
        cube(pos.x, pos.y, pos.z, 1)
    end
    gfx.color(255,128,128,70)
    for _, pos in pairs(VoidList) do
        cube(pos.x, pos.y, pos.z, 1)
    end
end

--[[                                   *@@.
                                  O@@#
                                 *@@#.O
                                 @@@ °@@@°
                                 @@@    O@@o   **
                       .*oO#@@@@ @@@ *Ooo#@@@@@@@*
                   .O@@@@@@@@#@@ O@@°o@@@@@#Oo.
                 *@@@@*  .#@@*   o@@o
               .@@@#@@O     o@@@ *@@o
              °@@@   °@@@o    °# @@@.
              @@@ O.    O@@#.   #@@O
             .@@@ @@@o    .#@@O@@@*
             °@@@   o@@O.  *@@@@o
   .*oO@@@@@# @@@ @@@@@@@@@@@o.
*@@@@@@@OoOOo @@@ #@@#Oo*°
 oo. .#@@*    @@@
        o@@@. @@@
          .#°O@@*
            #@@#        Helix (omg bloat)
           .@@o
]]