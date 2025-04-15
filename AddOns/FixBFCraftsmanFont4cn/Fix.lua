local function setDefaultCVars()
-- 关闭插件CPU性能分析
C_CVar.RegisterCVar("addonProfilerEnabled", "1")
C_CVar.SetCVar("addonProfilerEnabled", "0")
end

local frame = CreateFrame("FRAME", "DefaultCVarSetter")
frame:RegisterEvent("PLAYER_LOGIN")

local function eventHandler(self, event, ...)
    if event == "PLAYER_LOGIN" then
        setDefaultCVars()
    end
end

frame:SetScript("OnEvent", eventHandler)

--反注册LibSharedMedia字体
local LSM = LibStub("LibSharedMedia-3.0", true)
if LSM then
   LSM.MediaTable.font.Emblem = nil
   LSM.MediaTable.font.Expressway = nil
   LSM.MediaTable.font.visitor = nil
   LSM.MediaTable.font.Visitor = nil
end
