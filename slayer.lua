local API = require("api")
local Tasks = require("CommunitySlayer.slayerTasks")
local SlayerMasters = require("CommunitySlayer.slayerMasters")
local PlayerManager = require("core.player_manager")

local DEBUG = true

---@class SlayerConfig
---@field SELECTED_SLAYER_MASTER string
---@field USE_NPC_CONTACT boolean
---@field SKIP_LIST table<string, boolean>
---@field MINIMUM_POINTS_TO_SKIP_TASK number
local SlayerConfig = {
    SELECTED_SLAYER_MASTER = "Laniakea",
    USE_NPC_CONTACT = false,
    SKIP_LIST = {
        ["TASK_NAME_HERE"] = true,
    },
    MINIMUM_POINTS_TO_SKIP_TASK = 100,
}

---@class Slayer
---@field config SlayerConfig
---@field slayerTaskId number
---@field slayerTaskAmount number
---@field playerManager PlayerManager
local Slayer = {
    config = SlayerConfig,
    slayerTaskId = 0,
    slayerTaskAmount = 0,
    ---@type SlayerTask
    currentTask = nil,
    ---@type SlayerMaster
    currentSlayerMaster = nil,
    ---@diagnostic disable-next-line: assign-type-mismatch
    playerManager = nil,
    rewardsInterfaceIds = { { 1308, 0, -1, 0 } },
    debugGui = {
        ---@type IG_answer
        ---@diagnostic disable-next-line: missing-fields
        background = {},
        ---@type IG_answer
        ---@diagnostic disable-next-line: missing-fields
        startButton = {},
    }
}

---@type PlayerManagerConfig
local playerManagerConfig = {
    health = {
        normal = {
            type = "percent",
            value = 50,
        },
        critical = {
            type = "percent",
            value = 30,
        },
        special = {
            type = "percent",
            value = 75,
        },
    },
    prayer = {
        normal = {
            type = "percent",
            value = 35,
        },
        critical = {
            type = "percent",
            value = 10,
        },
        special = {
            type = "percent",
            value = 75,
        },
    },
    locations = {}
}

function Slayer:init()
    self.slayerTaskId = self:getCurrentTaskId()
    self.slayerTaskAmount = self:getCurrentTaskAmount()
    self.playerManager = PlayerManager.new(playerManagerConfig)

    self.debugGui.background = API.CreateIG_answer()
    self.debugGui.background.box_name = "GuiBackground"
    self.debugGui.background.box_start = FFPOINT.new(100, 100, 0)
    self.debugGui.background.box_size = FFPOINT.new(250, 150, 0)
    self.debugGui.background.colour = ImColor.new(50, 48, 47)

    self.debugGui.startButton = API.CreateIG_answer()
    self.debugGui.startButton.box_name = "Debug Slayer Task"
    self.debugGui.startButton.box_start = FFPOINT.new(100, 100, 0)
    self.debugGui.startButton.box_size = FFPOINT.new(150, 50, 0)
    self.debugGui.startButton.colour = ImColor.new(0, 255, 0)

    API.SetDrawLogs(true)
    API.SetDrawTrackedSkills(true)
    API.Write_LoopyLoop(true)
end

function Slayer:debug()
    API.DrawSquareFilled(Background)
    API.DrawBox(Slayer.debugGui.startButton)
    if Slayer.debugGui.startButton.return_click then
        Slayer.debugGui.startButton.return_click = false
        local taskId = Slayer:getCurrentTaskId()
        local task = Tasks[taskId]
        local taskAmount = Slayer:getCurrentTaskAmount()
        local taskStreak = Slayer:getTaskStreak()
        local slayerPoints = Slayer:getSlayerPoints()
        local spellbook = Slayer:getSpellbook()
        API.logDebug("==========================")
        API.logDebug("Current task id: " .. tostring(taskId))
        API.logDebug("Current task name: " .. tostring(task and task.name or "UNKNOWN TASK - PLEASE CONTRIBUTE"))
        API.logDebug("Current task amount: " .. tostring(taskAmount))
        API.logDebug("Current task streak: " .. tostring(taskStreak))
        API.logDebug("Current slayer points: " .. tostring(slayerPoints))
        API.logDebug("Current spellbook: " .. tostring(spellbook))
        API.logDebug("==========================")
    end
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

function Slayer:getSlayerLevel()
    return API.GetSkillByName("Slayer").level
end

function Slayer:getCombatLevel()
    return 152
end

---@param task SlayerTask
---@return boolean
function Slayer:hasRequiredItems(task)
    local itemsNeeded = task.itemsNeeded or {}
    local inventoryItemsNeeded = itemsNeeded.inventoryItems or {}
    local equippedItemsNeeded = itemsNeeded.equippedItems or {}
    -- just assume that tool belt is full
    -- but check inventory and equipment
    return Inventory:ContainsAll(inventoryItemsNeeded) and
        Equipment:ContainsAll(equippedItemsNeeded)
end

---@param task SlayerTask
---@return boolean
function Slayer:isAtTaskLocation(task)
    return API.PInAreaW(task.location, task.range)
end

---@param slayerMaster SlayerMaster
---@return boolean
function Slayer:isAtSlayerMasterLocation(slayerMaster)
    return API.PInAreaW(slayerMaster.location, 5)
end

---@param slayerMaster SlayerMaster
---@return boolean
function Slayer:walkToSlayerMaster(slayerMaster)
    local randomLocation = WPOINT.new(
        slayerMaster.location.x + math.random(-5, 5),
        slayerMaster.location.y + math.random(-5, 5),
        slayerMaster.location.z
    )
    return API.DoAction_WalkerW(randomLocation)
end

---@param slayerMaster SlayerMaster
function Slayer:getNewTask(slayerMaster)
    if Slayer:isAtSlayerMasterLocation(slayerMaster) then
        -- check if dialog is open
        API.logDebug("Checking if dialog is open")
        if API.VB_FindPSettinOrder(2874).state == 12 then
            -- continue dialog
            API.logDebug("Continuing dialog")
            return API.KeyboardPress2(0x20, 60, 120)
        else
            -- interact with slayer master to get a task
            API.logDebug("Interacting with slayer master to get a task")
            return Interact:NPC(slayerMaster.name, "Get task", 5)
        end
    else
        -- travel to slayer master
        API.logDebug("Traveling to slayer master")
        return Slayer:walkToSlayerMaster(slayerMaster)
    end
end

---@param slayerMaster SlayerMaster
function Slayer:skipTask(slayerMaster)
    if Slayer:isAtSlayerMasterLocation(slayerMaster) then
        local rewardsInterface = API.ScanForInterfaceTest2Get(true, self.rewardsInterfaceIds)
        if #rewardsInterface > 0 then
            API.logDebug("Rewards interface found, skipping task")
            ---@diagnostic disable-next-line: missing-parameter
            return API.DoAction_Interface(0x24, 0xffffffff, 1, 1308, 551, -1, API.OFF_ACT_GeneralInterface_route)
        else
            API.logDebug("Interacting with slayer master to skip task")
            return Interact:NPC(slayerMaster.name, "Rewards", 5)
        end
    else
        API.logDebug("Traveling to slayer master")
        return Slayer:walkToSlayerMaster(slayerMaster)
    end
end

---@param task SlayerTask
function Slayer:slayTask(task)
    API.logError("Not implemented")
end

Slayer:init()

while API.Read_LoopyLoop() do
    if DEBUG then
        Slayer:debug()
    end

    -- update current slayer master and task
    Slayer.currentSlayerMaster = SlayerMasters[Slayer.config.SELECTED_SLAYER_MASTER]
    Slayer.currentTask = Tasks[Slayer:getCurrentTaskId()]

    if not Slayer.currentSlayerMaster then
        API.logError("Slayer master not found")
    end

    if API.ReadPlayerMovin2() then
        goto continue
    end

    -- check if has task
    if Slayer:getCurrentTaskAmount() == 0 or Slayer:getCurrentTaskId() < 1 then
        API.logDebug("No task found, getting new task")
        -- need to find a task
        Slayer:getNewTask(Slayer.currentSlayerMaster)
        goto continue
    end

    -- manage hp/prayer/resources
    -- Slayer.playerManager:manageHealth()
    -- Slayer.playerManager:managePrayer()

    if not Slayer.currentTask then
        API.logError("UNKNOWN TASK - PLEASE CONTRIBUTE")
        -- API.Write_LoopyLoop(false)
        goto continue
    end

    -- check if we should skip the task
    local slayerPoints = Slayer:getSlayerPoints()
    if Slayer.config.SKIP_LIST[Slayer.currentTask.name] and slayerPoints >= Slayer.config.MINIMUM_POINTS_TO_SKIP_TASK then
        API.logDebug("Skipping task: " .. Slayer.currentTask.name)
        Slayer:skipTask(Slayer.currentSlayerMaster)
        goto continue
    end

    if not Slayer:hasRequiredItems(Slayer.currentTask) then
        -- how should we handle this?
        -- check bank for items?
        goto continue
    end

    -- check if we are at the location of the task
    if Slayer:isAtTaskLocation(Slayer.currentTask) then
        -- we are at the location of the task
        -- check if we have the required items
        if Slayer:hasRequiredItems(Slayer.currentTask) then
            -- start the task
            -- Slayer:slayTask(task)
            goto continue
        end
    else
        -- we are not at the location of the task
        -- walk to it
        -- pay $50/day for higgins world-walker
        goto continue
    end

    ::continue::
    API.RandomSleep2(600, 600, 1200)
end

return Slayer
