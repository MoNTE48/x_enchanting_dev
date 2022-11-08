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
            -- print(name, dump(minetest.registered_tools[name]._x_enchanting))
            -- print(name, dump(minetest.registered_tools[name].groups))
        end
    end
end)

local mod_end_time = (minetest.get_us_time() - mod_start_time) / 1000000

print('[Mod] x_enchanting loaded.. [' .. mod_end_time .. 's]')
