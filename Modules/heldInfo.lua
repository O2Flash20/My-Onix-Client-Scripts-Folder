name = "Item Held Info"
description = "Information on the item you're holding"

sizeX = 100
sizeY = 10
positionX = 500
positionY = 25

function render()
    gfx.color(51, 51, 51, 200)
    gfx.rect(0, 0, sizeX, sizeY)

    inv = player.inventory()
    heldThing = inv.at(inv.selected)
    if heldThing ~= nil then
        held = heldThing.name
    else
        held = "air"
    end

    txt = ""

    -- ITEM COUNT
    if held == "bow" or held == "crossbow" then
        arrowCount = 0
        for i = 1, inv.size, 1 do
            if inv.at(i) ~= nil then
                if inv.at(i).name == "arrow" then
                    arrowCount = arrowCount + inv.at(i).count
                end
            end
        end
        if inv.offhand() ~= nil then
            if inv.offhand().name == "arrow" then
                arrowCount = arrowCount + inv.offhand().count
            end
        end
        txt = "|"..txt..arrowCount.."| "

    else
        if held ~= "air" then
            otherCount = 0
            for i = 1, inv.size, 1 do
                if inv.at(i) ~= nil then
                    if inv.at(i).name == held then
                        otherCount = otherCount + inv.at(i).count
                    end
                end
            end
            if inv.offhand() ~= nil then
                if inv.offhand().name == held then
                    otherCount = otherCount + inv.offhand().count
                end
            end
            txt = "|"..txt..otherCount.."| "
        end
    end

    -- ENCHANTMENTS
    if held ~= "air" then
        ench = {}
        for key,value in pairs(inv.at(inv.selected).enchant) do
            table.insert(ench, {value.name, value.level})
        end

        for i = 1, #ench, 1 do
            for j = 1, #ids, 1 do
                if ids[j] == ench[i][1] then
                    if i == #ench then
                        txt = txt..names[j]..": "..ench[i][2]
                    else
                        txt = txt..names[j]..": "..ench[i][2]..", "
                    end
                end 
            end
        end

        gfx.color(255, 255, 255)
        gfx.text(sizeX/2-(#txt*5)/2+1, 0, txt)

        holdingDamage = getDamage(inv.selected)
        holdingWeapon = (holdingDamage > 0)

        -- list of "same" or "worse" or "better"
        weaponStatus = {}
        -- total count of each
        weaponStatus2 = {0, 0, 0}
        if holdingWeapon then
            for i = 1, inv.size, 1 do

                if holdingDamage > getDamage(i)then
                    table.insert(weaponStatus, "Better")
                end
                if holdingDamage < getDamage(i)then
                    table.insert(weaponStatus, "Worse")
                end
                if holdingDamage == getDamage(i)then
                    table.insert(weaponStatus, "Same")
                end

            end

            for i = 1, #weaponStatus, 1 do
                if weaponStatus[i] == "Worse" then
                    weaponStatus2[1] = weaponStatus2[1]+1
                end
                if weaponStatus[i] == "Same" then
                    weaponStatus2[2] = weaponStatus2[2]+1
                end
                if weaponStatus[i] == "Better" then
                    weaponStatus2[3] = weaponStatus2[3]+1
                end
            end

            if weaponStatus2[1] > 0 then
                gfx.color(255, 0, 0)
            -- one and not 0 because it includes itself as "same"
            elseif weaponStatus2[2] > 1 then
                gfx.color(255, 255, 0)
            else
                gfx.color(0, 255, 0)
            end

            gfx.rect(sizeX/2+(#txt*5)/2+1, 0, 10, 10)
        end
    end

    -- gfx.text(0, 0, getDamage(inv.selected))
end

weapons =        {"wooden_axe", "golden_axe", "stone_axe", "wooden_sword", "golden_sword", "stone_sword", "iron_axe", "iron_sword", "diamond_axe", "diamond_sword", "netherite_axe", "netherite_sword"}
weaponsDamages = {3           , 3           , 4          , 4             , 4             , 5            , 5         , 6           , 6            , 7              , 7              ,  8               }

ids =   {"aqua_affinity", "bane_of_arthropods", "blast_protection", "channeling", "depth_strider", "efficiency", "feather_falling", "fire_aspect", "fire_protection", "flame", "fortune", "frost_walker", "impaling", "infinity", "knockback", "looting", "loyalty", "luck_of_the_sea", "lure", "mending", "multishot", "piercing", "power", "projectile_protection", "protection", "punch", "quick_charge", "respiration", "riptide", "sharpness", "silk_touch", "smite", "soul_speed", "sweeping", "thorns", "unbreaking"}
names = {"AQ"           , "BN"                , "BP"              , "CH"        , "DP"           , "EF"        , "FF"             , "FA"         , "FP"             , "FL"   , "FT"     , "FW"          , "IM"      , "IN"      , "KN"       , "LT"     , "LO"     , "LU"             , "LR"  , "ME"     , "MT"       , "PC"      , "PW"   , "PJ"                   , "PR"        , "PU"   , "QC"          , "RE"         , "RI"     , "SH"       , "SI"        , "SM"   , "SO"        , "SW"      , "TH"    , "UN"        }

function getDamage(slotNum)
    item = inv.at(slotNum)

    if item == nil then return 0 end

    -- get enchantments
    ench = {}
    for key,value in pairs(item.enchant) do
        table.insert(ench, {value.name, value.level})
    end

    -- get material damage
    damage = 0
    for i = 1, #weapons, 1 do
        if item.name == weapons[i] then
            damage = weaponsDamages[i]
        end
    end

    for i = 1, #ench, 1 do
        if ench[i][1] == "sharpness" then
            -- damage = damage + (0.5*ench[i][2]+0.5) JAVA / CUBECRAFT
            damage = damage + (1.25*ench[i][2])
        end
        if ench[i][1] == "fire_aspect" then
            damage = damage + (0.4*ench[i][2])
        end
    end

    return damage
end