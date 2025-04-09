---@class ItemsNeeded
---@field inventoryItems number[]
---@field equippedItems number[]

---@class SlayerTask
---@field id number
---@field name string
---@field location WPOINT
---@field range number
---@field npcIds number[]
---@field itemsNeeded? ItemsNeeded
---@field otherConditions? function
---@field specialActions? function

---@type table<number, SlayerTask>
local Tasks = {
    [91] = {
        id = 91,
        name = "Spiritual Mages",
        location = WPOINT.new(0, 0, 0),
        range = 50,
        npcIds = { 6221, 16962, 6257, 6278, 6231 },
    },
    [112] = {
        id = 112,
        name = "Grotworms",
        location = WPOINT.new(0, 0, 0),
        range = 50,
        npcIds = { 15462, 15463 },
    },
    [152] = {
        id = 152,
        name = "Corrupted creatures",
        location = WPOINT.new(0, 0, 0),
        range = 50,
        npcIds = {},
    },
    [172] = {
        id = 172,
        name = "Vile blooms",
        location = WPOINT.new(0, 0, 0),
        range = 50,
        npcIds = { 26565, 26566, 26563, 26567 },
    },
    [173] = {
        id = 173,
        name = "Dragons",
        location = WPOINT.new(0, 0, 0),
        range = 50,
        npcIds = {},
    },
    [179] = {
        id = 179,
        name = "Nodon dragonkin",
        location = WPOINT.new(0, 0, 0),
        range = 50,
        npcIds = {},
    },
}

return Tasks
