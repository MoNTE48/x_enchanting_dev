---@diagnostic disable: codestyle-check

---Base class XEnchanting
---@class XEnchanting
---@field tools_enchantability table<string, number>  Add enchantability to default tools. key/value = tool_name/enchantibility value
---@field roman_numbers table<number, string>  Convert Arabic numbers to Roman numbers
---@field enchantment_defs table<'sharpness' | 'fortune' | 'unbreaking' | 'efficiency' | 'silk_touch' | 'curse_of_vanishing' | 'knockback', EnchantmentDef>
---@field has_tool_group fun(self: XEnchanting, name: string): string | boolean Check if tool has one of the known tool groups, returns `false` otherwise.
---@field set_tool_enchantability fun(self: XEnchanting, tool_def: ItemDef): nil Sets `enchantibility` group and values from base table (`XEnchanting.tools_enchantability`) to all registered tools (atching known group names). If tool has already `enchantibility` group defined it will take the defined value insted.
---@field get_enchanted_tool_capabilities fun(self: XEnchanting, tool_def: ItemDef, enchantments: Enchantment[]): ToolCapabilitiesDef Applies enchantments to item tool capabilities.
---@field set_enchanted_tool fun(self: XEnchanting, pos: Vector, itemstack: ItemStack, level: number, player_name: string): nil Set choosen enchantment and its modified tool capabilities to itemstack and `item` inventory. This will also get new `randomseed`.
---@field get_enchantment_data fun(self: XEnchanting, player: ObjectRef, nr_of_bookshelfs: number, tool_def: ItemDef): EnchantmentData Algoritm to get aplicable random enchantments.
---@field get_formspec fun(self: XEnchanting, pos: Vector, player_name: string, data: EnchantmentData | nil): string Builds and returns `formspec` string
---@field form_context table<string, FormContextDef> Additional form data for player.
---@field scroll_animations table<string, table> Parameters for `ObjectRef` `set_animation` method
---@field player_seeds table<string, number | integer>


---Enchantment definition
---@class EnchantmentDef
---@field name string Readable name of the enchantment
---@field final_level_range table<number, number[]> Level range
---@field level_def table<number, number> Level bonus. Value will be set in item meta as float.
---@field weight number Enchantment weight
---@field secondary boolean Will not appear in masked description and can be applied only as additional enchantment by probability chance.


---Form context
---@class FormContextDef
---@field pos Vector Formspec/node form position
---@field data EnchantmentData | nil Enchantment data


---@class EnchantmentData
---@field slots EnchantmentDataSlot[]


---@class Enchantment
---@field id string
---@field value number
---@field level number
---@field secondary boolean Will not appear in masked description and can be applied only as additional enchantment by probability chance.


---@class EnchantmentDataSlot
---@field level number
---@field final_enchantments Enchantment[]
---@field tool_cap_data ToolCapabilitiesDef
---@field descriptions {["enchantments_desc"]: string, ["enchantments_desc_masked"]: string }
