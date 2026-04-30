local env = select(2, ...)

local CreateFrame = CreateFrame
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local ipairs = ipairs
local tinsert = table.insert

local SupportedAddons = env.modules:New("@\\SupportedAddons")
local list = {}

function SupportedAddons.Add(addonName, loadFunc)
    tinsert(list, {
        name     = addonName,
        loadFunc = loadFunc
    })
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    f:UnregisterAllEvents()
    f:SetScript("OnEvent", nil)

    for _, addon in ipairs(list) do
        if IsAddOnLoaded(addon.name) then
            addon.loadFunc()
        end
    end
end)
