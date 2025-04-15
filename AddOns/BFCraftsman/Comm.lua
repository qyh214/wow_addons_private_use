---@class BFC
local BFC = select(2, ...)
local L = BFC.L
---@type AbstractFramework
local AF = _G.AbstractFramework

local SYNC_INTERVAL = 5 * 60 -- 5 minutes
-- local MIN_SYNC_INTERVAL = 5 * 60
-- local MAX_SYNC_INTERVAL = 10 * 60
local BFC_PUBLISH_DELAY = 30
local BFC_PUBLISH_PREFIX = "BFC_PUB"
local BFC_UNPUBLISH_PREFIX = "BFC_UNPUB"
local BFC_CHK_CRAFT_PREFIX = "BFC_CHK_CRAFT"
local BFC_CAN_CRAFT_PREFIX = "BFC_CAN_CRAFT"
local BFC_INSTANCE_PREFIX = "BFC_INSTANCE"
local BFC_VER = "BFC_VER"

local IsInInstance = IsInInstance

---------------------------------------------------------------------
-- version check
---------------------------------------------------------------------
local function VersionCheckReceived(version)
    if type(version) == "number" and version > BFC.versionNum and (not BFC_DB.lastVersionCheck or time() - BFC_DB.lastVersionCheck >= 3600) then
        BFC_DB.lastVersionCheck = time()
        AF.Print(L["New version (%s) available! Please consider updating."]:format("r" .. version))
    end
end
AF.RegisterComm(BFC_VER, VersionCheckReceived)

function BFC.BroadcastVersion()
    if BFC.channelID == 0 then return end
    AF.SendCommMessage_Channel(BFC_VER, BFC.versionNum, BFC.channelName)
end

---------------------------------------------------------------------
-- publish timer
---------------------------------------------------------------------
local timer
function BFC.ScheduleNextSync(useDelay)
    if useDelay then
        timer = C_Timer.NewTimer(BFC_PUBLISH_DELAY, function()
            if BFC_DB.publish.mode == "always" then
                BFC.Publish()
                BFC.ScheduleNextSync()
            elseif BFC_DB.publish.mode == "outdoors" then
                if IsInInstance() then
                    BFC.Unpublish()
                else
                    BFC.Publish()
                    BFC.ScheduleNextSync()
                end
            else
                BFC.Unpublish()
            end
        end)
    else
        timer = C_Timer.NewTimer(SYNC_INTERVAL, function()
            BFC.Publish()
            BFC.ScheduleNextSync()
        end)
    end
end

function BFC.CancelNextSync()
    if timer then
        timer:Cancel()
        timer = nil
    end
end

---------------------------------------------------------------------
-- receiving publish
---------------------------------------------------------------------
local function ProfessionProcessor(_, id)
    if id:find("!$") then
        return tonumber(id:sub(1, -2)), true
    else
        return tonumber(id), false
    end
end

local function PublishReceived(data, _, channel)
    local version, id, name, class, tagline, craftingFee, professions = AF.Unpack7(data)
    if type(version) ~= "number" or version < BFC.minVersion then return end
    if BFC_DB.blacklist[id] then return end

    if not BFC_DB.list[id] then
        BFC_DB.list[id] = {
            recipes = {},
        }
    end

    BFC_DB.list[id].name = name
    BFC_DB.list[id].class = class
    BFC_DB.list[id].tagline = tagline
    BFC_DB.list[id].craftingFee = craftingFee
    BFC_DB.list[id].professions = professions
    BFC_DB.list[id].lastUpdate = time()
    BFC_DB.list[id].unpublished = nil

    BFC.UpdateList()
end
AF.RegisterComm(BFC_PUBLISH_PREFIX, PublishReceived)

local function UnpublishReceived(id, _, channel)
    if type(id) ~= "string" or BFC_DB.blacklist[id] then return end
    if BFC_DB.list[id] then
        BFC_DB.list[id].unpublished = true
        BFC.UpdateList()
    end
end
AF.RegisterComm(BFC_UNPUBLISH_PREFIX, UnpublishReceived)

---------------------------------------------------------------------
-- sending publish
---------------------------------------------------------------------
local data = {}
function BFC.UpdateSendingData()
    data = {
        BFC.versionNum,
        BFC.battleTag,
        AF.player.fullName,
        AF.player.class,
        BFC_DB.publish.tagline,
        BFC_DB.publish.craftingFee,
        BFC.learnedProfessions,
    }
end

function BFC.Publish()
    if BFC.channelID == 0 then return end
    if AF.IsBlank(data[2]) then return end -- battleTag
    AF.SendCommMessage_Channel(BFC_PUBLISH_PREFIX, data, BFC.channelName)
end

function BFC.Unpublish()
    if BFC.channelID == 0 then return end
    if AF.IsBlank(BFC.battleTag) then return end
    AF.SendCommMessage_Channel(BFC_UNPUBLISH_PREFIX, BFC.battleTag, BFC.channelName)
end

---------------------------------------------------------------------
-- can craft
---------------------------------------------------------------------
function BFC.CheckCanCraft(id, recipeID)
    if BFC.channelID == 0 then return end
    AF.SendCommMessage_Channel(BFC_CHK_CRAFT_PREFIX, {BFC.versionNum, id, recipeID}, BFC.channelName)
end

local function CheckCanCraftReceived(data)
    local version, id, recipeID = AF.Unpack3(data)
    if type(version) ~= "number" or version < BFC.minVersion then return end

    if id == BFC.battleTag then
        AF.SendCommMessage_Channel(BFC_CAN_CRAFT_PREFIX, {BFC.versionNum, BFC.battleTag, recipeID, BFC.learnedRecipes[recipeID]}, BFC.channelName)
    end
end
AF.RegisterComm(BFC_CHK_CRAFT_PREFIX, CheckCanCraftReceived)

local function CanCraftReceived(data)
    local version, id, recipeID, chars = AF.Unpack4(data)
    if type(version) ~= "number" or version < BFC.minVersion then return end

    if not BFC_DB.blacklist[id] and BFC_DB.list[id] then
        BFC_DB.list[id].recipes[recipeID] = chars
        BFC.NotifyCanCraft(id, recipeID, chars)
    end
end
AF.RegisterComm(BFC_CAN_CRAFT_PREFIX, CanCraftReceived)

---------------------------------------------------------------------
-- in instance
---------------------------------------------------------------------
local wasInInstance = false
function BFC.UpdateInstanceStatus()
    if BFC.channelID == 0 or BFC_DB.publish.mode == "disabled" then return end
    local inInstance = IsInInstance()
    if inInstance ~= wasInInstance then
        wasInInstance = inInstance
        AF.SendCommMessage_Channel(BFC_INSTANCE_PREFIX, {BFC.versionNum, BFC.battleTag, inInstance}, BFC.channelName)
        if BFC_DB.publish.mode == "outdoors" then
            BFC.ScheduleNextSync(true)
        end
    end
end

local function InstanceStatusReceived(data)
    local version, id, inInstance = AF.Unpack3(data)
    if type(version) ~= "number" or version < BFC.minVersion then return end

    if not BFC_DB.blacklist[id] and BFC_DB.list[id] then
        BFC_DB.list[id].inInstance = inInstance
        BFC.UpdateList()
    end
end
AF.RegisterComm(BFC_INSTANCE_PREFIX, InstanceStatusReceived)