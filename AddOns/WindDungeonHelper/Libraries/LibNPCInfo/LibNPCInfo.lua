local _G = _G
local major = "LibNPCInfo"
local minor = 1

local lib = _G.LibStub:NewLibrary(major, minor)
if not lib then
    return
end

local format = format
local ipairs = ipairs
local print = print
local tinsert = tinsert
local type = type

local CreateFrame = CreateFrame
local GetTime = GetTime

local C_Timer_After = C_Timer.After

local SCAN_TIMEOUT = 0.34
local cache = {}
local scanQueue = {}
local scanTooltipsPool = {}

local function FetchDataOnTooltipSetUnit(self)
    local tooltipName = self:GetName()
    local topLeftText = _G[tooltipName .. "TextLeft1"]:GetText()

    if topLeftText then
        cache[self.npcID] = {
            id = self.npcID,
            name = topLeftText,
            desc = _G[tooltipName .. "TextLeft2"]:GetText()
        }

        if self.callback then
            self.callback(cache[self.npcID])
        end
    end

    scanQueue[self.npcID] = nil
    self:SetScript("OnTooltipSetUnit", nil)
    self.callback = nil
    self.npcID = nil
end

local function FindTimeoutTooltip()
    local now = GetTime()
    for i, tt in ipairs(scanTooltipsPool) do
        if not tt.npcID or not tt.lastUpdate or now - tt.lastUpdate > SCAN_TIMEOUT + 1 then
            return tt
        end
    end
end

local function GetNewTooltip()
    local tt =
        CreateFrame(
        "GameTooltip",
        "LibNPCInfoScanTooltip" .. (#scanTooltipsPool + 1),
        _G.UIParent,
        "GameTooltipTemplate"
    )

    tt:Show()
    tt:SetHyperlink("unit:")

    tinsert(scanTooltipsPool, tt)
    return tt
end

-- -----------------------------------------------------
-- LibNPCInfo:GetNPCInfoByID(npcID, [callback, [failedCallback]])
-- @param npcID number - NPC ID
-- @param callback function - optional callback function
-- @param failedCallback function - optional failed callback function
-- @return nil - if NPC not found
-- @return "scanning" - if NPC has been added to scan queue
-- @return "start" - if NPC is being scanned
-- @return table{id:number, name:string, desc:string} - NPC info, if there is not callback function
-- -----------------------------------------------------
function lib.GetNPCInfoByID(npcID, callback, failedCallback)
    if not npcID then
        print("LibNPCInfo.GetNPCInfoByID: npcID is nil.")
        return
    end

    if type(npcID) ~= "number" or callback and type(callback) ~= "function" then
        print('LibNPCInfo.GetNPCInfoByID: "npcID" must be a number and "callback" must be a function or nil.')
        return
    end

    if cache[npcID] then
        return callback and callback(cache[npcID]) or cache[npcID]
    end

    if scanQueue[npcID] then
        return "scanning"
    end

    local tt = FindTimeoutTooltip() or GetNewTooltip()
    tt.lastUpdate = GetTime()
    tt.callback = callback
    tt.npcID = npcID
    scanQueue[npcID] = tt

    tt:SetOwner(_G.UIParent, "ANCHOR_NONE")
    tt:SetScript("OnTooltipSetUnit", FetchDataOnTooltipSetUnit)

    -- once
    tt:SetHyperlink(format("unit:Creature-0-0-0-0-%d-0", npcID))

    -- twice
    C_Timer_After(
        SCAN_TIMEOUT,
        function()
            if tt.npcID == npcID then
                tt:SetHyperlink(format("unit:Creature-0-0-0-0-%d-0", npcID))
                tt.lastUpdate = GetTime()
            end
        end
    )

    -- failed
    C_Timer_After(
        SCAN_TIMEOUT * 2,
        function()
            if tt.npcID == npcID then
                scanQueue[npcID] = nil
                tt:SetScript("OnTooltipSetUnit", nil)

                if failedCallback then
                    failedCallback(npcID)
                else
                    print("LibNPCInfo.GetNPCInfoByID: failed to fetch data for npcID " .. npcID)
                end

                tt.callback = nil
                tt.npcID = nil
                tt.lastUpdate = nil
            end
        end
    )

    return "start"
end

-- -----------------------------------------------------
-- LibNPCInfo:GetNPCInfoWithIDTable(npcID, [callback])
-- @param npcID number - NPC ID
-- @param callback function - optional callback function for each NPC info
-- -----------------------------------------------------
function lib.GetNPCInfoWithIDTable(npcIDs, callback)
    if not npcIDs then
        print("LibNPCInfo.GetNPCInfoWithIDTable: npcIDs is nil.")
        return
    end

    if type(npcIDs) ~= "table" or callback and type(callback) ~= "function" then
        print('LibNPCInfo.GetNPCInfoWithIDTable: "npcIDs" must be a table and "callback" must be a function or nil.')
        return
    end

    local numDone = 0
    local numTotal = #npcIDs

    local function findNextAndStartScan()
        numDone = numDone + 1
        if numDone > numTotal then
            return
        end

        lib.GetNPCInfoByID(
            npcIDs[numDone],
            function(...)
                callback(...)
                findNextAndStartScan()
            end,
            function()
                findNextAndStartScan()
            end
        )
    end

    findNextAndStartScan()
end
