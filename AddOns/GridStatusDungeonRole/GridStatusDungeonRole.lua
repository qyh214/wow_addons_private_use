-- Libraries
local L = LibStub("AceLocale-3.0"):GetLocale("GridStatusDungeonRole", true)

-- Grid Initialization
local GridRoster = Grid:GetModule("GridRoster")

local GridStatusDungeonRole = Grid:GetModule("GridStatus"):NewModule("DungeonRole")
GridStatusDungeonRole.menuName = L["Dungeon Role"]

local rolestatus = {
    HEALER = {
                text = L["Healer"],
                icon = [[Interface\AddOns\GridStatusDungeonRole\icons\healer.tga]],
        },
    DAMAGER = {
                text = L["DPS"],
                icon = [[Interface\AddOns\GridStatusDungeonRole\icons\damager.tga]],
        },
    TANK = {
                text = L["Tank"],
                icon = [[Interface\AddOns\GridStatusDungeonRole\icons\tank.tga]],
        },
}



-- Grid config defaults
GridStatusDungeonRole.defaultDB = {
    debug = false,
    dungeonRole = {
        text = L["Dungeon Role"],
        enable = true,
        color = { r = 1, g = 1, b = 1, a = 1 },
        priority = 10,
        range = false,
        hideInCombat = false,
        colors = {
            DAMAGER = { r = 0.75, g = 0, b = 0, a = 1 },
            HEALER = { r = 0, g = 0.75, b = 0, a = 1 },
            TANK = { r = 0, g = 0, b = 0.75, a = 1 },
        },
        filter = {
            DAMAGER = true,
            HEALER = true,
            TANK = true,
        },
    },
}

GridStatusDungeonRole.options = false

local function GetRoleColor(role)
    local color = GridStatusDungeonRole.db.profile.dungeonRole.colors[role]
    return color.r, color.g, color.b, color.a
end

local function SetRoleColor(role, r, g, b, a)
    local color = GridStatusDungeonRole.db.profile.dungeonRole.colors[role]
    color.r = r
    color.g = g
    color.b = b
    color.a = a or 1
    GridStatusDungeonRole:SendMessage("Grid_ColorsChanged")
end

local function GetRoleFilter(role)
    return GridStatusDungeonRole.db.profile.dungeonRole.filter[role]
end

local function SetRoleFilter(role, v)
    GridStatusDungeonRole.db.profile.dungeonRole.filter[role] = v
    GridStatusDungeonRole:RoleCheckAll()
end

local function GetHideInCombat()
    return GridStatusDungeonRole.db.profile.dungeonRole.hideInCombat
end

local function SetHideInCombat(v)
    local settings = GridStatusDungeonRole.db.profile.dungeonRole
    settings.hideInCombat = v
    if settings.enable then
        if settings.hideInCombat then
            GridStatusDungeonRole:RegisterMessage("Grid_EnteringCombat")
            GridStatusDungeonRole:RegisterMessage("Grid_LeavingCombat")
        else
            GridStatusDungeonRole:UnregisterMessage("Grid_EnteringCombat")
            GridStatusDungeonRole:UnregisterMessage("Grid_LeavingCombat")
        end
        GridStatusDungeonRole:RoleCheckAll()
    end
end

-- Grid configration options
local roleOptions = {
    ["HEALER"] = {
        type = "color",
        name = L["Healer color"],
        desc = L["Color for Healers."],
        order = 87,
        hasAlpha = true,
        get = function () return GetRoleColor("HEALER") end,
        set = function (_, r, g, b, a) SetRoleColor("HEALER", r, g, b, a) end,
    },
    ["DAMAGER"] = {
        type = "color",
        name = L["DPS color"],
        desc = L["Color for DPS."],
        order = 88,
        hasAlpha = true,
        get = function () return GetRoleColor("DAMAGER") end,
        set = function (_, r, g, b, a) SetRoleColor("DAMAGER", r, g, b, a) end,
    },
    ["TANK"] = {
        type = "color",
        name = L["Tank color"],
        desc = L["Color for Tanks."],
        order = 89,
        hasAlpha = true,
        get = function () return GetRoleColor("TANK") end,
        set = function (_, r, g, b, a) SetRoleColor("TANK", r, g, b, a) end,
    },
    ["filter"] = {
        type = "group",
        name = L["Role filter"],
        desc = L["Show status for the selected roles."],
        order = 90,
        args = {
            ["HEALER"] = {
                type = "toggle",
                name = L["Healer"],
                desc = L["Show on Healer."],
                get = function () return GetRoleFilter("HEALER") end,
                set = function (_, v) SetRoleFilter("HEALER", v) end,
            },
            ["DAMAGER"] = {
                type = "toggle",
                name = L["DPS"],
                desc = L["Show on DPS."],
                get = function () return GetRoleFilter("DAMAGER") end,
                set = function (_, v) SetRoleFilter("DAMAGER", v) end,
            },
            ["TANK"] = {
                type = "toggle",
                name = L["Tank"],
                desc = L["Show on Tank."],
                get = function () return GetRoleFilter("TANK") end,
                set = function (_, v) SetRoleFilter("TANK", v) end,
            },
        },
    },
    ["hideInCombat"] = {
        type = "toggle",
        name = L["Hide in combat"],
        desc = L["Hide roles while in combat."],
        order = 91,
        get = function() return GetHideInCombat() end,
        set = function(_, v) SetHideInCombat(v) end,
    },

    ["color"] = false,
}



-- Status handling
function GridStatusDungeonRole:OnInitialize()
    self.super.OnInitialize(self)
    self:RegisterStatus("dungeonRole", L["Dungeon Role"], roleOptions, true)
end

function GridStatusDungeonRole:OnStatusEnable(status)
    if status == "dungeonRole" then
        if self.db.profile.dungeonRole.hideInCombat then
            self:RegisterMessage("Grid_EnteringCombat")
            self:RegisterMessage("Grid_LeavingCombat")
        end
        self:RegisterMessage("Grid_RosterUpdated", "RoleCheckAll")
        self:RegisterEvent("PLAYER_ROLES_ASSIGNED", "RoleCheckAll")
        self:RegisterEvent("PARTY_MEMBERS_CHANGED", "RoleCheckAll")
        self:RoleCheckAll()
    end
end

function GridStatusDungeonRole:OnStatusDisable(status)
    if status == "dungeonRole" then
        if self.db.profile.dungeonRole.hideInCombat then
            self:UnregisterMessage("Grid_EnteringCombat")
            self:UnregisterMessage("Grid_LeavingCombat")
        end
        self:UnregisterMessage("Grid_RosterUpdated")
        self:UnregisterEvent("PLAYER_ROLES_ASSIGNED")
        self:UnregisterEvent("PARTY_MEMBERS_CHANGED")
        self.core:SendStatusLostAllUnits("dungeonRole")
    end
end

function GridStatusDungeonRole:Reset()
    self.super.Reset(self)
    self:RoleCheckAll()
    if self.db.profile.dungeonRole.hideInCombat then
        GridStatusDungeonRole:RegisterMessage("Grid_EnteringCombat")
        GridStatusDungeonRole:RegisterMessage("Grid_LeavingCombat")
    else
        GridStatusDungeonRole:UnregisterMessage("Grid_EnteringCombat")
        GridStatusDungeonRole:UnregisterMessage("Grid_LeavingCombat")
    end
end

function GridStatusDungeonRole:Grid_EnteringCombat()
    local settings = self.db.profile.dungeonRole
    if settings.enable and settings.hideInCombat then
        self.core:SendStatusLostAllUnits("dungeonRole")
    end
end

function GridStatusDungeonRole:Grid_LeavingCombat()
    local settings = self.db.profile.dungeonRole
    if settings.enable and settings.hideInCombat then
        self:RoleCheckAll()
    end
end



-- Role check functions
function GridStatusDungeonRole:RoleCheckAll()
    local settings = self.db.profile.dungeonRole
    if settings.enable and ( not settings.hideInCombat or not Grid.inCombat ) then
        for guid in GridRoster:IterateRoster() do
            self:RoleCheck(guid)
        end
    else
        self.core:SendStatusLostAllUnits("dungeonRole")
    end
end

function GridStatusDungeonRole:RoleCheck(guid)
    local gained
    local settings = self.db.profile.dungeonRole

    if settings.enable and ( not settings.hideInCombat or not Grid.inCombat ) then
        local unitId = GridRoster:GetUnitidByGUID(guid)
        local role = UnitGroupRolesAssigned(unitId)

        if role == "NONE" then
            role = false
            gained = false
        end

        if role and settings.filter[role] then
            local status = rolestatus[role]
            self.core:SendStatusGained(
                guid,
                "dungeonRole",
                settings.priority,
                (settings.range and 40),
                settings.colors[role],
                status.text,
                nil,
                nil,
                status.icon
            )
            gained = true
        end
    end

    if not gained then
        self.core:SendStatusLost(guid, "dungeonRole")
    end
end
