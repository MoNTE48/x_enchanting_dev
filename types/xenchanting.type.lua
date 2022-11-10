---@diagnostic disable: codestyle-check

---Base class XEnchanting
---@class XEnchanting
---@field tools_enchantability table<string, number>  Add enchantability to default tools. key/value = tool_name/enchantibility value
---@field roman_numbers table<number, string>  Convert Arabic numbers to Roman numbers
---@field enchantment_defs table<'sharpness' | 'fortune' | 'unbreaking' | 'efficiency', EnchantmentDef>
---@field has_tool_group fun(self: XEnchanting, name: string): string | boolean Check if tool has one of the known tool groups, returns `false` otherwise.
---@field set_tool_enchantability fun(self: XEnchanting, tool_def: ItemDef): nil Sets `enchantibility` group and values from base table (`XEnchanting.tools_enchantability`) to all registered tools (atching known group names). If tool has already `enchantibility` group defined it will take the defined value insted.
---@field get_enchanted_tool_capabilities fun(self: XEnchanting, tool_def: ItemDef, enchantments: Enchantments[]): GetEnchantedToolCapabilitiesReturn Applies enchantments to item tool capabilities.
---@field set_enchanted_tool fun(self: XEnchanting, itemstack: ItemStack, level: number, player_name: string): nil Set choosen enchantment and its modified tool capabilities to itemstack and `item` inventory. This will also get new `randomseed`.
---@field get_enchantment_data fun(self: XEnchanting, nr_of_bookshelfs: number, tool_def: ItemDef): EnchantmentData Algoritm to get aplicable random enchantments.
---@field get_formspec fun(self: XEnchanting, pos: Vector, player_name: string, data?: EnchantmentData): string Builds and returns `formspec` string


---Enchantment definition
---@class EnchantmentDef
---@field name string Readable name of the enchantment
---@field final_level_range table<number, number[]> Level range
---@field level_def table<number, number> Level bonus
---@field weight number Enchantment weight
---@field randomseed number Math random seed. Will change after item was enchanted.
---@field form_context table<string, FormContextDef> Additional form data for player.
---@field scroll_animations table<string, table> Parameters for `ObjectRef` `set_animation` method


---Form context
---@class FormContextDef
---@field pos Vector Formspec/node form position
---@field data EnchantmentDataSlot Enchantment data


---@class GetEnchantedToolCapabilitiesReturn
---@field tool_capabilities ToolCapabilitiesDef
---@field enchantments_desc string
---@field enchantments_desc_masked string


---@class EnchantmentData
---@field slots EnchantmentDataSlot[]


---@class Enchantments
---@field id string
---@field value number
---@field level number


---@class ToolCapData
---@field enchantments_desc string Masket description before enchanting
---@field enchantments_desc_masked string Description added to item description definition after enchanting
---@field tool_capabilities ToolCapabilitiesDef Modified tool capabilities with applied enchantment


---@class EnchantmentDataSlot
---@field final_enchantments Enchantments[]
---@field tool_cap_data ToolCapData
---@field level number
