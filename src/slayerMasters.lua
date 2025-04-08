---@class SlayerMaster
---@field id number
---@field name string
---@field levelRequirement number
---@field location WPOINT
---@field otherConditions function

---@type table<number, SlayerMaster>
local SlayerMasters = {
    [1] = {
        id = 1,
        name = "",
        levelRequirement = 1,
        location = WPOINT.new(0, 0, 0),
        otherConditions = function() return true end
    },
}

return SlayerMasters
