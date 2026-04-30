local env = select(2, ...)
local SupportedAddons = env.modules:Import("@\\SupportedAddons")

local function OnAddonLoad()
    if not SuperTrackedFrame.Time then return end
    SuperTrackedFrame.Time:SetParent(nil)
    SuperTrackedFrame.Time:ClearAllPoints()
end

SupportedAddons.Add("UnlimitedMapPinDistance", OnAddonLoad)
