
Minesweeperr = LibStub("AceAddon-3.0"):NewAddon("Minesweeperr", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0")
local L = LibStub ("AceLocale-3.0"):GetLocale("Minesweeperr", true)
_G.Minesweeperr = Minesweeperr
local MS = Minesweeperr

-- -------------
-- Legacy
-- -------------
MSDB = {}
function MS:LegacyInitialize()
    if not self.db.global.ratings then
        self.db.global.ratings = MSDB
        MSDB = nil
    end
    self.db.global.legacyTransfered = true
    MS:Print("Legacy DB loaded.")
end



-- -------------
-- Chat Command
-- -------------
function MS:SlashProcessorFunc(input)
    if input == "" then
        MS:SendMessage("MSCustomEvent", "TOGGLE_MAIN_FRAME")
    elseif input == "minimap" then
        self:Print(L["Toggle Minimap Icon"])
        self.db.profile.minimap.hide = not self.db.profile.minimap.hide
    end
end

-- -------------
-- Initialize
-- -------------
function MS:Initialize()
    self.db = LibStub("AceDB-3.0"):New("msACEDB", {
        profile = {
            minimap = {
                hide = false,
            },
            mainAchiID = 14145,
            childAchi1ID = 13781,
            childAchi2ID = 13449,
            childAchi3ID = 14043,
            autoShow = true,
        },
        global = {
            ratings = nil,
            history = nil,
            legacyTransfered = false
        }
    })

end

function MS:createMinimapIcon()
    local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("MS", {
        type = "data source",
        text = "Minesweeperr",
        icon = "Interface\\Icons\\INV_Chest_Cloth_17",
        OnClick = function()
            MS:SendMessage("MSCustomEvent", "TOGGLE_MAIN_FRAME")
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("Minesweeperr")
            tooltip:Show()
        end
    })
    local icon = LibStub("LibDBIcon-1.0")
    icon:Register("Minesweeperr", LDB, self.db.profile.minimap)
end

function MS:createOptions()
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Minesweeperr", self.optionsTable)
	self.optionsTable.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Minesweeperr", "Minesweeperr")
end

function MS:OnInitialize()
    self:Initialize()
    if not self.db.global.legacyTransfered then
        self:LegacyInitialize()
    end
    self:createMinimapIcon()
    self:createOptions()
    self:RegisterChatCommand("ms", "SlashProcessorFunc")
    self:RegisterComm("MS")
    self:RegisterComm("AngryKeystones")

    MS:SendMessage("MSCustomEvent", "INIT_FRAME")
    MS:wait(5, MS.Frame.CloseInitializeFrame, MS.Frame)
    MS:SendMessage("MSCustomEvent", "INIT_DATA_ENGINE")
    MS:SendMessage("MSCustomEvent", "INIT_ANIMATION")

end

-- ---------------------
-- Utils

function MS:toString(tbl)
    local result = "{"
    for k, v in pairs(tbl) do
       -- Check the key type (ignore any numerical keys - assume its an array)
       if type(k) == "string" then
          result = result.."[\""..k.."\"]".."="
       end
       
       -- Check the value type
       if type(v) == "table" then
          result = result..self:toString(v)
       elseif type(v) == "boolean" then
          result = result..tostring(v)
       else
          result = result.."\""..v.."\""
       end
       result = result..","
    end
    -- Remove leading commas from the result
    if result ~= "{" then
       result = result:sub(1, result:len()-1)
    end
    return result.."}"
 end

function MS:createMessage(type, body)
    local message = {}
    message["prefix"] = "MS"
    message["type"] = type
    message["body"] = body
    return MS:toString(message)
end



MS.waitTable = {}
MS.waitFrame = nil

function MS:wait(delay, func, ...)
    if(type(delay)~="number" or type(func)~="function") then
        return false;
    end
    if(MS.waitFrame == nil) then
        MS.waitFrame = CreateFrame("Frame","WaitFrame", UIParent);
        MS.waitFrame:SetScript("onUpdate", function (self, elapse)
            local count = #MS.waitTable;
            local i = 1;
            while(i <= count) do
                local waitRecord = tremove(MS.waitTable,i);
                local d = tremove(waitRecord,1);
                local f = tremove(waitRecord,1);
                local p = tremove(waitRecord,1);
                if(d>elapse) then
                    tinsert(MS.waitTable,i,{d-elapse,f,p});
                    i = i + 1;
                else
                    count = count - 1;
                    f(unpack(p));
                end
            end
        end);
    end
    tinsert(MS.waitTable,{delay,func,{...}});
    return true;
end


function MS:getN(map)
    local count = 0
    for k,v in pairs(map) do count = count + 1 end
    return count
end