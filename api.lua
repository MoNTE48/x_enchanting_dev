XEnchanting = {
    -- add enchantability to default tools
    tools_enchantability = {
        -- picks
        ['default:pick_wood'] = 15,
        ['default:pick_stone'] = 5,
        ['default:pick_bronze'] = 22,
        ['default:pick_steel'] = 14,
        ['default:pick_mese'] = 15,
        ['default:pick_diamond'] = 10,
        -- shovels
        ['default:shovel_wood'] = 15,
        ['default:shovel_stone'] = 5,
        ['default:shovel_bronze'] = 22,
        ['default:shovel_steel'] = 14,
        ['default:shovel_mese'] = 15,
        ['default:shovel_diamond'] = 10,
        -- axes
        ['default:axe_wood'] = 15,
        ['default:axe_stone'] = 5,
        ['default:axe_bronze'] = 22,
        ['default:axe_steel'] = 14,
        ['default:axe_mese'] = 15,
        ['default:axe_diamond'] = 10,
        -- swords
        ['default:sword_wood'] = 15,
        ['default:sword_stone'] = 5,
        ['default:sword_bronze'] = 22,
        ['default:sword_steel'] = 14,
        ['default:sword_mese'] = 15,
        ['default:sword_diamond'] = 10,
        -- hoes
        ['farming:hoe_wood'] = 15,
        ['farming:hoe_stone'] = 5,
        ['farming:hoe_steel'] = 14,
        ['farming:hoe_bronze'] = 22,
        ['farming:hoe_mese'] = 15,
        ['farming:hoe_diamond'] = 10,
    },
    roman_numbers = {
        [1] = 'I',
        [2] = 'II',
        [3] = 'III',
        [4] = 'IV',
        [5] = 'V',
    },
    enchantment_defs = {
        -- Living things like animals and the player. This could imply
        -- some blood effects when hitting
        sharpness = {
            name = 'Sharpness',
            -- what level should be taken, `level = min/max values`
            final_level_range = {
                [1] = { 1, 21 },
                [2] = { 12, 32 },
                [3] = { 23, 43 },
                [4] = { 34, 54 },
                [5] = { 45, 65 },
            },
            -- level definition, `level = added value`
            level_def = {
                [1] = 1.25,
                [2] = 2.5,
                [3] = 3.75,
                [4] = 5,
                [5] = 6.25,
            },
            weight = 10
        },
        fortune = {
            name = 'Fortune',
            -- what level should be taken, `level = min/max values`
            final_level_range = {
                [1] = { 15, 65 },
                [2] = { 24, 74 },
                [3] = { 33, 83 }
            },
            -- level definition, `level = number to add`
            level_def = {
                [1] = 1,
                [2] = 2,
                [3] = 3
            },
            weight = 2
        },
        unbreaking = {
            name = 'Unbreaking',
            -- what level should be taken, `level = min/max values`
            final_level_range = {
                [1] = { 5, 55 },
                [2] = { 13, 63 },
                [3] = { 21, 71 }
            },
            -- level definition, `level = percentage increase`
            level_def = {
                [1] = 100,
                [2] = 200,
                [3] = 300
            },
            weight = 5
        },
        efficiency = {
            name = 'Efficiency',
            -- what level should be taken, `level = min/max values`
            final_level_range = {
                [1] = { 1, 51 },
                [2] = { 11, 61 },
                [3] = { 21, 71 },
                [4] = { 31, 81 },
                [5] = { 41, 91 },
            },
            -- level definition, `level = percentage increase`
            level_def = {
                [1] = 25,
                [2] = 30,
                [3] = 35,
                [4] = 40,
                [5] = 45,
            },
            weight = 10
        }
    }
}

---Merge two tables with key/value pair
---@param t1 table
---@param t2 table
---@return table
local function mergeTables(t1, t2)
    for k, v in pairs(t2) do t1[k] = v end
    return t1
end

function XEnchanting.has_tool_group(self, name)
    if minetest.get_item_group(name, 'pickaxe') > 0 then
        return 'pickaxe'
    elseif minetest.get_item_group(name, 'shovel') > 0 then
        return 'shovel'
    elseif minetest.get_item_group(name, 'axe') > 0 then
        return 'axe'
    elseif minetest.get_item_group(name, 'sword') > 0 then
        return 'sword'
    end

    return false
end

function XEnchanting.set_tool_enchantability(self, tool_def)
    local _enchantability = 1

    if minetest.get_item_group(tool_def.name, 'enchantability') > 0 then
        _enchantability = minetest.get_item_group(tool_def.name, 'enchantability')
    elseif self.tools_enchantability[tool_def.name] then
        _enchantability = self.tools_enchantability[tool_def.name]
    end

    minetest.override_item(tool_def.name, {
        groups = mergeTables(tool_def.groups, { enchantability = _enchantability })
    })
end

function XEnchanting.get_enchanted_tool_capabilities(self, tool_def, enchantments)
    local tool_stack = ItemStack({ name = tool_def.name })
    local tool_capabilities = tool_stack:get_tool_capabilities()
    local enchantments_desc = {}

    -- print('tool_capabilities #1', dump(tool_capabilities))

    for i, enchantment in ipairs(enchantments) do
        -- Efficiency
        if enchantment.id == 'efficiency' then
            if tool_capabilities.groupcaps then
                -- groupcaps
                for group_name, def in pairs(tool_capabilities.groupcaps) do
                    -- times
                    if def.times then
                        local old_times = def.times
                        local new_times = {}

                        for lvl, old_time in ipairs(old_times) do
                            local new_time = old_time - (old_time * (enchantment.value / 100))

                            if new_time < 0.15 then
                                new_time = 0.15
                            end

                            table.insert(new_times, lvl, new_time)
                        end

                        tool_capabilities.groupcaps[group_name].times = new_times
                    end

                    -- maxlevel
                    if def.maxlevel and def.maxlevel < enchantment.level then
                        tool_capabilities.groupcaps[group_name].maxlevel = enchantment.level
                    end
                end
            end

            if tool_capabilities.full_punch_interval then
                -- full_punch_interval
                local old_fpi = tool_capabilities.full_punch_interval
                local new_fpi = old_fpi - (old_fpi * (enchantment.value / 100))

                if new_fpi < 0.15 then
                    new_fpi = 0.15
                end

                tool_capabilities.full_punch_interval = new_fpi
            end

            if tool_capabilities.groupcaps or tool_capabilities.full_punch_interval then
                enchantments_desc[#enchantments_desc + 1] = self.enchantment_defs[enchantment.id].name
                    .. ' '
                    .. self.roman_numbers[enchantment.level]
            end
        end

        -- Unbreaking
        if enchantment.id == 'unbreaking' then
            if tool_capabilities.groupcaps then
                -- groupcaps
                for group_name, def in pairs(tool_capabilities.groupcaps) do
                    -- uses
                    if def.uses then
                        local old_uses = def.uses
                        local new_uses = old_uses + (old_uses * (enchantment.value / 100))

                        tool_capabilities.groupcaps[group_name].uses = new_uses
                    end
                end
            end

            if tool_capabilities.punch_attack_uses then
                -- punch_attack_uses
                local old_uses = tool_capabilities.punch_attack_uses
                local new_uses = old_uses + (old_uses * (enchantment.value / 100))

                tool_capabilities.punch_attack_uses = new_uses
            end

            if tool_capabilities.groupcaps or tool_capabilities.punch_attack_uses then
                enchantments_desc[#enchantments_desc + 1] = self.enchantment_defs[enchantment.id].name
                    .. ' '
                    .. self.roman_numbers[enchantment.level]
            end
        end

        -- Sharpness
        if enchantment.id == 'sharpness' and tool_capabilities.damage_groups then
            for group_name, val in pairs(tool_capabilities.damage_groups) do
                local old_damage = val
                local new_damage = old_damage + enchantment.value

                tool_capabilities.damage_groups[group_name] = new_damage
            end

            enchantments_desc[#enchantments_desc + 1] = self.enchantment_defs[enchantment.id].name
                .. ' '
                .. self.roman_numbers[enchantment.level]
        end

        -- Fortune
        if enchantment.id == 'fortune' and tool_capabilities.max_drop_level then
            local old_max_drop_level = tool_capabilities.max_drop_level
            local new_max_drop_level = old_max_drop_level + enchantment.value

            tool_capabilities.max_drop_level = new_max_drop_level

            enchantments_desc[#enchantments_desc + 1] = self.enchantment_defs[enchantment.id].name
                .. ' '
                .. self.roman_numbers[enchantment.level]
        end
    end

    enchantments_desc = minetest.colorize('#C70039', '\nEnchanted\n') .. table.concat(enchantments_desc, '\n')

    -- print('tool_capabilities #2', dump(tool_capabilities))
    -- print('enchantments_desc', enchantments_desc)
    -- return {
    --     tool_capabilities = tool_capabilities,
    --     enchantments_desc = enchantments_desc
    -- }
end

function XEnchanting.set_enchanted_tool_capabilities(self, itemstack, capabilities, description)
    -- local tool_def = minetest.registered_tools[itemstack:get_name()]
    -- minetest.override_item(tool_def.name, {
    --     groups = mergeTables(tool_def.groups, { enchantability = 0 }),
    --         tool_capabilities = tool_capabilities
    -- })
end

function XEnchanting.get_base_enchantment_level(self, nr_of_bookshelfs, tool_def)
    local _nr_of_bookshelfs = nr_of_bookshelfs

    if _nr_of_bookshelfs > 15 then
        _nr_of_bookshelfs = 15
    end

    ----
    -- 0 Show slots in formspec
    ----

    -- Base enchantment
    local base = math.random(1, 8) + math.floor(_nr_of_bookshelfs / 2) + math.random(0, _nr_of_bookshelfs)
    local top_slot_base_level = math.floor(math.max(base / 3, 1))
    local middle_slot_base_level = math.floor((base * 2) / 3 + 1)
    local bottom_slot_base_level = math.floor(math.max(base, _nr_of_bookshelfs * 2))

    -- print('top_slot_base_level', top_slot_base_level)
    -- print('middle_slot_base_level', middle_slot_base_level)
    -- print('bottom_slot_base_level', bottom_slot_base_level)

    ----
    -- 1 Applying modifiers to the enchantment level
    ----

    -- Just for testing, this has to come from formspec
    local chosen_enchantment_level = 30
    -- Applying modifiers to the enchantment level
    local enchantability = minetest.get_item_group(tool_def.name, 'enchantability')
    -- Generate a random number between 1 and 1+(enchantability/2), with a triangular distribution
    -- print('-------------------')
    -- print('enchantability', enchantability)
    local rand_enchantability = 1 + math.random(enchantability / 4 + 1) + math.random(enchantability / 4 + 1)
    -- print('rand_enchantability', rand_enchantability)
    -- Choose the enchantment level
    local k = chosen_enchantment_level + rand_enchantability
    -- print('k', k)
    -- A random bonus, between .85 and 1.15
    local rand_bonus_percent = 1 + ((math.random(0, 99) / 100) + (math.random(0, 99) / 100) - 1) * 0.15
    -- print('rand_bonus_percent', rand_bonus_percent)
    -- Finally, we calculate the level
    local final_level = math.round(k * rand_bonus_percent)

    if final_level < 1 then
        final_level = 1
    end

    -- print('final_level', final_level)

    ----
    -- 2 Find possible enchantments
    ----
    local possible_enchantments = {}

    -- Get level
    -- If the modified level is within two overlapping ranges for the same
    -- enchantment type, the higher power value is used.
    for enchantment_name, enchantment_def in pairs(self.enchantment_defs) do
        local levels = {}

        for level, final_level_range in ipairs(enchantment_def.final_level_range) do
            local min = final_level_range[1]
            local max = final_level_range[2]

            if final_level >= min and final_level <= max then
                table.insert(levels, level)
            end
        end

        local level = levels[#levels]

        -- print('levels', enchantment_name, dump(levels))
        -- print('level', enchantment_name, level)

        table.insert(possible_enchantments, {
            id = enchantment_name,
            value = enchantment_def.level_def[level],
            level = level
        })
    end

    -- print('possible_enchantments', dump(possible_enchantments))

    ----
    -- 3 Select a set of enchantments from the list
    ----
    local final_enchantments = {}
    local total_weight = 0

    -- calculate total weight
    for i, enchantment in ipairs(possible_enchantments) do
        total_weight = total_weight + self.enchantment_defs[enchantment.id].weight
    end

    local rand_weight = math.random(0, total_weight / 2)

    -- print('total_weight', total_weight)
    -- print('rand_weight', rand_weight)

    -- select final enchantments
    for i = 1, #possible_enchantments, 1 do
        local rand_ench_idx = math.random(1, #possible_enchantments)
        local rand_ench = possible_enchantments[rand_ench_idx]

        table.remove(possible_enchantments, rand_ench_idx)
        rand_weight = rand_weight - self.enchantment_defs[rand_ench.id].weight
        table.insert(final_enchantments, rand_ench)

        if rand_weight < 0 then
            break
        end
    end

    -- print('final_enchantments', dump(final_enchantments))

    self:get_enchanted_tool_capabilities(tool_def, final_enchantments)
end
