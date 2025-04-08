local API = require("api")
local Tasks = require("CommunitySlayer.tasks")

local DEBUG = true

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

function Slayer:getTaskStreak()
    return API.VB_FindPSettinOrder(10077).state
end

function Slayer:getSlayerPoints()
    return API.VB_FindPSettinOrder(2092).state % 65536
end

function Slayer:getSpellbook()
    local bitPattern = API.VB_FindPSettinOrder(4).state & 0x3
    local spellbooks = {
        [0] = "Normal",
        [1] = "Ancient",
        [2] = "Lunar",
    }
    return spellbooks[bitPattern]
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

API.SetDrawLogs(false)
API.SetDrawTrackedSkills(true)
-- API.Write_LoopyLoop(true)

print("Loading gui...")
local Background = API.CreateIG_answer()
Background.box_name = "GuiBackground"
Background.box_start = FFPOINT.new(100, 100, 0)
Background.box_size = FFPOINT.new(250, 150, 0)
Background.colour = ImColor.new(50, 48, 47)

local StartButton = API.CreateIG_answer()
StartButton.box_name = "Debug Slayer Task"
StartButton.box_start = FFPOINT.new(100, 100, 0)
StartButton.box_size = FFPOINT.new(150, 50, 0)
StartButton.colour = ImColor.new(0, 255, 0)

print("Gui loaded")

while API.Read_LoopyLoop() do
    if DEBUG then
        API.DrawSquareFilled(Background)
        API.DrawBox(StartButton)
        if StartButton.return_click then
            StartButton.return_click = false
            local taskId = Slayer:getCurrentTaskId()
            local task = Tasks[taskId]
            local taskAmount = Slayer:getCurrentTaskAmount()
            local taskStreak = Slayer:getTaskStreak()
            local slayerPoints = Slayer:getSlayerPoints()
            local spellbook = Slayer:getSpellbook()
            print("==========================")
            print("Current task id: " .. tostring(taskId))
            print("Current task name: " .. tostring(task and task.name or "UNKNOWN TASK - PLEASE CONTRIBUTE"))
            print("Current task amount: " .. tostring(taskAmount))
            print("Current task streak: " .. tostring(taskStreak))
            print("Current slayer points: " .. tostring(slayerPoints))
            print("Current spellbook: " .. tostring(spellbook))
            print("==========================")
        end
    end

    local task = Tasks[Slayer:getCurrentTaskId()]

    -- check if has task
    if Slayer:getCurrentTaskAmount() == 0 or Slayer:getCurrentTaskId() < 1 then
        -- need to find a task
        goto continue
    end

    -- manage hp/prayer/resources
    -- Slayer:manageResources()

    -- check if we are at the location of the task
    if Slayer:isAtTaskLocation(task) then
        -- we are at the location of the task
        -- check if we have the required items
        if Slayer:hasRequiredItems(task) then
            -- start the task
            -- Slayer:slayTask(task)
        end
    else
        -- we are not at the location of the task
        -- walk to it
    end

    ::continue::
    API.RandomSleep2(100, 150, 200)
end

return Slayer
