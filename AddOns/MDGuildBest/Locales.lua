local _, ns = ...

local locale = GetLocale()
local locales = {}

if locale == "zhCN" then
	locales["Account Keystones"] = "账号角色钥石信息"
	locales["Reset Info"] = "重置数据"
	locales["Hold Shift"] = "按住<Shift>展开"
elseif locale == "zhTW" then
	locales["Account Keystones"] = "帳號角色鑰石資訊"
	locales["Reset Info"] = "重置數據"
	locales["Hold Shift"] = "按住<Shift>展開"
else
	locales["Account Keystones"] = "Account Keystone"
	locales["Reset Info"] = "Reset Data"
	locales["Hold Shift"] = "Hold SHIFT for Details"
end

ns.Locales = locales