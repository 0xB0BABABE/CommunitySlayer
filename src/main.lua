local API = require("api")
local Tasks = require("CommunitySlayer.src.tasks")

local Slayer = {
    slayerTaskId = nil,
    slayerTaskAmount = nil,
}

function Slayer:init()
    self.slayerTaskId = self:getCurrentTaskId()
    self.slayerTaskAmount = self:getCurrentTaskAmount()
end

function Slayer:getCurrentTaskId()
    return API.VB_FindPSettinOrder(185).state
end

function Slayer:getCurrentTaskAmount()
    return API.VB_FindPSettinOrder(183).state
end

---@param task Task
---@return boolean
function Slayer:hasRequiredItems(task)
    return Inventory:ContainsAll(task.itemsNeeded.inventoryItems) and
        Equipment:ContainsAll(task.itemsNeeded.equippedItems)
end

---@param task Task
---@return boolean
function Slayer:isAtTaskLocation(task)
    return API.PInAreaW(task.location, task.range)
end

---@param task Task
function Slayer:slayTask(task)
    error("Not implemented")
end

function Slayer:manageResources()
    error("Not implemented")
end

Slayer:init()

while API.Read_LoopyLoop() do
    -- check if has task
    if Slayer:getCurrentTaskAmount() == 0 or Slayer:getCurrentTaskId() < 1 then
        -- need to find a task
        return
    end

    -- manage hp/prayer/resources
    Slayer:manageResources()

    local task = Tasks[Slayer:getCurrentTaskId()]

    -- check if we are at the location of the task
    if Slayer:isAtTaskLocation(task) then
        -- we are at the location of the task
        -- check if we have the required items
        if Slayer:hasRequiredItems(task) then
            -- start the task
            Slayer:slayTask(task)
        end
    else
        -- we are not at the location of the task
        -- walk to it
    end

    API.RandomSleep2(100, 150, 200)
end

return Slayer
