--反注册LibSharedMedia字体
local LSM = LibStub("LibSharedMedia-3.0", true)
if LSM then
   LSM.MediaTable.font.Emblem = nil
   LSM.MediaTable.font.Expressway = nil
   LSM.MediaTable.font.visitor = nil
   LSM.MediaTable.font.Visitor = nil
   LSM.MediaTable.font.Unifont = nil
   LSM.MediaTable.font.Dolphin = nil
   LSM.MediaTable.font["Accidental Presidency"] = nil
   LSM.MediaTable.font["Cal Sans"] = nil
end
