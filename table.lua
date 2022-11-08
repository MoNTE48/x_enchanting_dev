screwdriver = minetest.global_exists('screwdriver') and screwdriver --[[@as MtgScrewdriver]]

local scroll_animations = {
    scroll_open = { { x = 1, y = 40 }, 80, 0, false },
    scroll_close = { { x = 45, y = 84 }, 80, 0, false },
    scroll_open_idle = { { x = 41, y = 42 }, 0, 0, false },
    scroll_closed_idle = { { x = 43, y = 43 }, 0, 0, false }
}

local function get_formspec(pos)
    local spos = pos.x .. ',' .. pos.y .. ',' .. pos.z
    local formspec =
        'size[8,9]' ..
        'label[0, 0;Enchant]' ..
        ---@diagnostic disable-next-line: codestyle-check
        'model[0,0;2,3;x_enchanting_table;x_enchanting_scroll.b3d;x_enchanting_scroll_mesh.png,x_enchanting_scroll_handles_mesh.png,x_enchanting_scroll_mesh.png;89,0;false;false;' .. scroll_animations.scroll_open_idle[1].x .. ',' .. scroll_animations.scroll_open_idle[1].y .. ';0]' ..
        'list[nodemeta:' .. spos .. ';item;0, 2.5;1, 1;]' ..
        'image[1,2.5;1,1;x_enchanting_trade_slot.png;]' ..
        'list[nodemeta:' .. spos .. ';trade;1, 2.5;1, 1;]' ..
        'list[current_player;main;0, 4.85;8, 1;]' ..
        'list[current_player;main;0, 6.08;8, 3;8]' ..
        'listring[nodemeta:' .. spos .. ';item]' ..
        'listring[nodemeta:' .. spos .. ';trade]' ..
        'listring[current_player;main]' ..
        default.get_hotbar_bg(0, 4.85)

    return formspec
end

---Table Node
minetest.register_node('x_enchanting:table', {
    description = 'Enchating Table',
    short_description = 'Enchating Table',
    drawtype = 'mesh',
    mesh = 'x_enchanting_table.obj',
    tiles = { 'x_enchanting_table.png' },
    paramtype = 'light',
    paramtype2 = 'facedir',
    walkable = true,
    wield_scale = { x = 2, y = 2, z = 2 },
    selection_box = {
        type = 'fixed',
        fixed = { -1 / 2, -1 / 2, -1 / 2, 1 / 2, 1 / 2 - 4 / 16, 1 / 2 }
    },
    collision_box = {
        type = 'fixed',
        fixed = { -1 / 2, -1 / 2, -1 / 2, 1 / 2, 1 / 2 - 4 / 16, 1 / 2 }
    },
    sounds = {
        footstep = {
            name = 'x_enchanting_table_hard_footstep',
            gain = 0.2
        },
        dug = {
            name = 'x_enchanting_table_hard_footstep',
            gain = 1.0
        },
        place = {
            name = 'x_enchanting_table_place_node_hard',
            gain = 1.0
        }
    },
    is_ground_content = false,
    groups = { cracky = 1, level = 2 },
    stack_max = 1,
    mod_origin = 'x_enchanting',
    light_source = 6,
    ---@param pos Vector
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        local inv = meta:get_inventory()

        meta:set_string('infotext', 'Enchating Table')
        meta:set_string('owner', '')
        inv:set_size('item', 1)
        inv:set_size('trade', 1)
        minetest.add_entity({ x = pos.x, y = pos.y + 0.7, z = pos.z }, 'x_enchanting:table_scroll')
        minetest.get_node_timer(pos):start(5)
    end,
    ---@param pos Vector
    ---@param placer ObjectRef | nil
    ---@param itemstack ItemStack
    ---@param pointed_thing PointedThingDef
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        local meta = minetest.get_meta(pos)

        if not placer then
            return
        end

        local player_name = placer:get_player_name()

        meta:set_string('owner', player_name)
        meta:set_string('infotext', 'Enchating Table (owned by ' .. player_name .. ')')
    end,
    ---@param pos Vector
    ---@param node NodeDef
    ---@param clicker ObjectRef
    ---@param itemstack ItemStack
    ---@param pointed_thing? PointedThingDef
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local p_name = clicker:get_player_name()

        if minetest.is_protected(pos, p_name) then
            return itemstack
        end

        minetest.sound_play('default_dig_choppy', {
            gain = 0.3,
            pos = pos,
            max_hear_distance = 10
        }, true)

        local formspec = get_formspec(pos)

        minetest.show_formspec(clicker:get_player_name(), 'x_enchanting:table', formspec)
    end,
    ---@param pos Vector
    ---@param intensity? number
    ---@return table | nil
    on_blast = function(pos, intensity)
        if minetest.is_protected(pos, '') then
            return
        end

        local drops = {}
        local inv = minetest.get_meta(pos):get_inventory()
        local stack_item = inv:get_stack('item', 1)
        local stack_trade = inv:get_stack('trade', 1)

        if not stack_item:is_empty() then
            drops[#drops + 1] = stack_item:to_table()
        end

        if not stack_trade:is_empty() then
            drops[#drops + 1] = stack_trade:to_table()
        end

        drops[#drops + 1] = 'x_enchanting:table'
        minetest.remove_node(pos)

        return drops
    end,
    ---@param pos Vector
    ---@param player? ObjectRef
    can_dig = function(pos, player)
        if not player then
            return false
        end

        local inv = minetest.get_meta(pos):get_inventory()

        return inv:is_empty('item')
            and inv:is_empty('trade')
            and not minetest.is_protected(pos, player:get_player_name())
    end,
    on_rotate = function(pos, node, user, mode, new_param2)
        return false
    end,
    ---@param pos Vector
    ---@param elapsed number
    on_timer = function(pos, elapsed)
        -- entity
        local table_scroll = minetest.get_objects_inside_radius(pos, 0.9)

        if #table_scroll == 0 then
            minetest.add_entity({ x = pos.x, y = pos.y + 0.7, z = pos.z }, 'x_enchanting:table_scroll')
        end

        local particlespawner_def = {
            amount = 30,
            time = 5,
            minpos = { x = pos.x - 0.1, y = pos.y + 0.2, z = pos.z - 0.1 },
            maxpos = { x = pos.x + 0.1, y = pos.y + 0.3, z = pos.z + 0.1 },
            minvel = { x = -0.1, y = 0.1, z = -0.1 },
            maxvel = { x = 0.1, y = 0.2, z = 0.1 },
            minacc = { x = -0.1, y = 0.1, z = -0.1 },
            maxacc = { x = 0.1, y = 0.2, z = 0.1 },
            minexptime = 1.5,
            maxexptime = 2.5,
            minsize = 0.1,
            maxsize = 0.3,
            texture = 'x_enchanting_scroll_particle.png',
            glow = 1
        }

        if minetest.has_feature({ dynamic_add_media_table = true, particlespawner_tweenable = true }) then
            -- new syntax, after v5.6.0
            particlespawner_def = {
                amount = 30,
                time = 5,
                size = {
                    min = 0.1,
                    max = 0.3,
                },
                exptime = 2,
                pos = {
                    min = vector.new({ x = pos.x - 0.5, y = pos.y, z = pos.z - 0.5 }),
                    max = vector.new({ x = pos.x + 0.5, y = pos.y, z = pos.z + 0.5 }),
                },
                attract = {
                    kind = 'point',
                    strength = 0.5,
                    origin = vector.new({ x = pos.x, y = pos.y + 0.65, z = pos.z })
                },
                texture = {
                    name = 'x_enchanting_scroll_particle.png',
                    alpha_tween = {
                        0, 1,
                        style = 'fwd',
                        reps = 1
                    }
                },
                glow = 1
            }
        end

        minetest.add_particlespawner(particlespawner_def)

        ---bookshelfs
        local bookshelfs = minetest.find_nodes_in_area(
            { x = pos.x - 2, y = pos.y, z = pos.z - 2 },
            { x = pos.x + 2, y = pos.y + 2, z = pos.z + 2 },
            { 'default:bookshelf' }
        )

        if #bookshelfs == 0 then
            return true
        end

        -- just for testing
        XEnchanting:get_base_enchantment_level(#bookshelfs, minetest.registered_tools['default:pick_mese'])

        -- symbol particles
        for i = 1, 10, 1 do
            local pos_random = bookshelfs[math.random(1, #bookshelfs)]
            local x = pos.x - pos_random.x
            local y = pos_random.y - pos.y
            local z = pos.z - pos_random.z
            local rand1 = (math.random(150, 250) / 100) * -1
            local rand2 = math.random(10, 500) / 100
            local rand3 = math.random(50, 200) / 100

            minetest.after(rand2, function()
                minetest.add_particle({
                    pos = pos_random,
                    velocity = { x = x, y = 2 - y, z = z },
                    acceleration = { x = 0, y = rand1, z = 0 },
                    expirationtime = 1,
                    size = rand3,
                    texture = 'x_enchanting_symbol_' .. math.random(1, 26) .. '.png',
                    glow = 6
                })
            end)
        end

        return true
    end,
    ---@param pos Vector
    on_destruct = function(pos)
        for _, obj in ipairs(minetest.get_objects_inside_radius(pos, 0.9)) do
            if obj
                and obj:get_luaentity()
                and obj:get_luaentity().name == 'x_enchanting:table_scroll'
            then
                obj:remove()
                break
            end
        end
    end,

    -- on_receive_fields = enchanting.fields,
    -- on_metadata_inventory_put = enchanting.on_put,
    -- on_metadata_inventory_take = enchanting.on_take,
    -- allow_metadata_inventory_put = enchanting.put,
    -- allow_metadata_inventory_take = enchanting.take,
    -- allow_metadata_inventory_move = function() return 0 end,
})

---Scroll Entity
minetest.register_entity('x_enchanting:table_scroll', {
    initial_properties = {
        visual = 'mesh',
        mesh = 'x_enchanting_scroll.b3d',
        textures = {
            --- back
            'x_enchanting_scroll_mesh.png',
            -- handles
            'x_enchanting_scroll_handles_mesh.png',
            --- front
            'x_enchanting_scroll_mesh.png',
        },
        collisionbox = { 0, 0, 0, 0, 0, 0 },
        selectionbox = { 0, 0, 0, 0, 0, 0 },
        physical = false,
        hp_max = 1,
        visual_size = { x = 1, y = 1, z = 1 },
        glow = 1,
        pointable = false,
        infotext = 'Scroll of Enchantments',
    },
    ---@param self table
    ---@param killer ObjectRef
    on_death = function(self, killer)
        self.object:remove()
    end,
    ---@param self table
    ---@param staticdata StringAbstract
    ---@param dtime_s number
    on_activate = function(self, staticdata, dtime_s)
        self._scroll_closed = true
        self._tablechecktimer = 5
        self._playerchecktimer = 1
        self._bouncetimer = 3
        self._player = nil
        self._last_rotation = nil
        self._bounce_up = false
        self._bounce_init = false

        self.object:set_armor_groups({ immortal = 1 })
        self.object:set_animation({ x = 0, y = 0 }, 0, 0, false)
    end,
    ---@param self table
    ---@param dtime number
    ---@param moveresult? table
    on_step = function(self, dtime, moveresult)
        local pos = self.object:get_pos()

        self._last_rotation = self.object:get_rotation()
        self._tablechecktimer = self._tablechecktimer - dtime
        self._playerchecktimer = self._playerchecktimer - dtime
        self._bouncetimer = self._bouncetimer - dtime

        -- table
        if self._tablechecktimer <= 0 then
            self._tablechecktimer = 5
            local node = minetest.get_node({ x = pos.x, y = pos.y - 0.7, z = pos.z })

            if node.name ~= 'x_enchanting:table' then
                -- remove entity when no table under it
                self.object:remove()
            end
        end

        -- player
        if self._playerchecktimer <= 0 then
            self._playerchecktimer = 1
            local objects = minetest.get_objects_inside_radius(pos, 5)

            -- inital value
            local shortest_distance = 10
            local found_player = false

            if #objects > 0 then
                for i, obj in ipairs(objects) do
                    if obj:is_player() and obj:get_pos() then
                        -- player
                        found_player = true
                        local distance = vector.distance(pos, obj:get_pos())

                        if distance < shortest_distance then
                            self._player = obj
                        end
                    end
                end
            else
                self._player = nil
            end

            if not found_player then
                self._player = nil
            end

            -- scroll open/close animation
            if self._player and self._scroll_closed then
                self._scroll_closed = false
                self.object:set_animation(unpack(scroll_animations.scroll_open))
            elseif not self._player and not self._scroll_closed then
                self._scroll_closed = true
                self.object:set_animation(unpack(scroll_animations.scroll_close))
            end
        end

        -- rotation
        if self._player and self._player:get_pos() then
            local direction = vector.direction(pos, self._player:get_pos())
            self.object:set_yaw(minetest.dir_to_yaw(direction))
        else
            self.object:set_rotation({
                x = self._last_rotation.x,
                y = self._last_rotation.y + (math.pi / -50),
                z = self._last_rotation.z
            })
        end
    end,
    ---@param self table
    ---@param puncher ObjectRef
    ---@param time_from_last_punch number | nil
    ---@param tool_capabilities ToolCapabilitiesDef | nil
    ---@param dir Vector
    ---@param damage number
    ---@return boolean | nil
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
        return true
    end
})
