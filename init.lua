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
end)

minetest.register_on_joinplayer(function(player, last_login)
    XEnchanting.form_context[player:get_player_name()] = nil
end)

minetest.register_on_leaveplayer(function(player, timed_out)
    XEnchanting.form_context[player:get_player_name()] = nil
end)

-- Silk Touch
local old_handle_node_drops = minetest.handle_node_drops

function minetest.handle_node_drops(pos, drops, digger)
    if not digger
        or not digger:is_player()
    then
        return old_handle_node_drops(pos, drops, digger)
    end

    local wield_stack = digger:get_wielded_item()
    local wield_stack_meta = wield_stack:get_meta()
    if wield_stack_meta:get_int('is_silk_touch') == 0 then
        return old_handle_node_drops(pos, drops, digger)
    end

    local wield_stack_name = wield_stack:get_name()
    local node = minetest.get_node(pos)
    local silk_touch_group

    if minetest.get_item_group(wield_stack_name, 'pickaxe') > 0 then
        silk_touch_group = 'cracky'
    elseif minetest.get_item_group(wield_stack_name, 'shovel') > 0 then
        silk_touch_group = 'crumbly'
    elseif minetest.get_item_group(wield_stack_name, 'axe') > 0 then
        silk_touch_group = 'choppy'
    elseif minetest.get_item_group(wield_stack_name, 'sword') > 0 then
        silk_touch_group = 'snappy'
    end

    if not silk_touch_group
        or minetest.get_item_group(node.name, silk_touch_group) == 0
        or minetest.get_item_group(node.name, 'no_silktouch') == 1
    then
        return old_handle_node_drops(pos, drops, digger)
    end

    -- drop raw item/node
    return old_handle_node_drops(pos, { ItemStack(node.name) }, digger)
end

local mod_end_time = (minetest.get_us_time() - mod_start_time) / 1000000

print('[Mod] x_enchanting loaded.. [' .. mod_end_time .. 's]')
