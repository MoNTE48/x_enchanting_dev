-- X Enchanting
-- by SaKeL

local path = minetest.get_modpath('x_enchanting')
local mod_start_time = minetest.get_us_time()

dofile(path .. '/api.lua')
dofile(path .. '/table.lua')

minetest.register_on_mods_loaded(function()
    for name, tool_def in pairs(minetest.registered_tools) do
        if XEnchanting:has_tool_group(name) then
            XEnchanting:set_tool_enchantability(tool_def)
        end
    end

    for _, def in pairs(minetest.registered_ores) do
        if not XEnchanting.registered_ores[def.ore] then
            XEnchanting.registered_ores[def.ore] = true
        end
    end
end)

minetest.register_on_joinplayer(function(player, last_login)
    XEnchanting.form_context[player:get_player_name()] = nil

    if not XEnchanting.player_seeds[player:get_player_name()] then
        XEnchanting.player_seeds[player:get_player_name()] = XEnchanting.get_randomseed()
    end
end)

minetest.register_on_leaveplayer(function(player, timed_out)
    XEnchanting.form_context[player:get_player_name()] = nil
end)

local old_handle_node_drops = minetest.handle_node_drops

function minetest.handle_node_drops(pos, drops, digger)
    if not digger
        or not digger:is_player()
    then
        return old_handle_node_drops(pos, drops, digger)
    end

    local node = minetest.get_node(pos)
    local wield_stack = digger:get_wielded_item()
    local wield_stack_meta = wield_stack:get_meta()

    -- Fortune
    local fortune = wield_stack_meta:get_float('is_fortune')

    if fortune > 0 then
        local new_drops = {}

        for _, itemstring in ipairs(drops) do
            if XEnchanting.registered_ores[node.name]
                or minetest.get_item_group(node.name, 'stone') > 0
                or minetest.get_item_group(node.name, 'soil') > 0
                or minetest.get_item_group(node.name, 'sand') > 0
                or minetest.get_item_group(node.name, 'snowy') > 0
                or minetest.get_item_group(node.name, 'slippery') > 0
                or minetest.get_item_group(node.name, 'tree') > 0
                or minetest.get_item_group(node.name, 'leaves') > 0
            then
                local tool_capabilities = wield_stack:get_tool_capabilities()
                local stack = ItemStack(itemstring)
                local chance = math.random(1, tool_capabilities.max_drop_level)

                stack:set_count(stack:get_count() * chance)

                if stack:get_count() > 0 then
                    table.insert(new_drops, stack)
                end
            end
        end

        if #new_drops > 0 then
            return old_handle_node_drops(pos, new_drops, digger)
        end

        return old_handle_node_drops(pos, drops, digger)
    end

    -- Silk Touch
    local silk_touch = wield_stack_meta:get_float('is_silk_touch')

    if silk_touch > 0
        and minetest.get_item_group(node.name, 'no_silktouch') == 0
    then
        -- drop raw item/node
        return old_handle_node_drops(pos, { ItemStack(node.name) }, digger)
    end

    return old_handle_node_drops(pos, drops, digger)
end

minetest.register_on_player_hpchange(function(player, hp_change, reason)
    -- Curse of Vanishing
    if (player:get_hp() + hp_change) <= 0 then
        -- Going to die
        local player_inv = player:get_inventory() --[[@as InvRef]]

        local player_inventory_lists = { 'main', 'craft' }

        for _, list_name in ipairs(player_inventory_lists) do
            if not player_inv:is_empty(list_name) then
                for i = 1, player_inv:get_size(list_name) do
                    local stack = player_inv:get_stack(list_name, i)
                    local stack_meta = stack:get_meta()

                    if stack_meta:get_float('is_curse_of_vanishing') > 0 then
                        player_inv:set_stack(list_name, i, ItemStack(''))
                    end
                end
            end
        end
    end

    return hp_change
end, true)

-- Knockback (only for players)
local old_calculate_knockback = minetest.calculate_knockback

function minetest.calculate_knockback(player, hitter, time_from_last_punch,
    tool_capabilities, dir, distance, damage)
    if hitter and hitter:is_player() then
        local hitter_wield_stack = hitter:get_wielded_item()
        local hitter_wield_stack_meta = hitter_wield_stack:get_meta()
        local ench_knockback = hitter_wield_stack_meta:get_float('is_knockback')

        if ench_knockback > 0 then
            local orig_knockback = old_calculate_knockback(
                player,
                hitter,
                time_from_last_punch,
                tool_capabilities,
                dir,
                distance,
                damage
            )

            orig_knockback = orig_knockback + 1

            local new_knockback = orig_knockback + (orig_knockback * (ench_knockback / 100))

            player:add_velocity(vector.new(0, new_knockback, 0))

            return new_knockback
        end
    end

    return old_calculate_knockback(player, hitter, time_from_last_punch,
    tool_capabilities, dir, distance, damage)
end

local mod_end_time = (minetest.get_us_time() - mod_start_time) / 1000000

print('[Mod] x_enchanting loaded.. [' .. mod_end_time .. 's]')
