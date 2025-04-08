---@class ItemsNeeded
---@field inventoryItems number[]
---@field equippedItems number[]

---@class Task
---@field id number
---@field name string
---@field location WPOINT
---@field range number
---@field npcIds number[]
---@field itemsNeeded? ItemsNeeded
---@field otherConditions? function

---@type table<number, Task>
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
    }
}

return Tasks
