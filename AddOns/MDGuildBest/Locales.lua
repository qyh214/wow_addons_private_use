local _, ns = ...

local locale = GetLocale()
local locales = {}

if locale == "zhCN" then
	locales["Account Keystones"] = "账号角色钥石信息"
	locales["Reset Info"] = "重置数据"
elseif locale == "zhTW" then
	locales["Account Keystones"] = "帳號角色鑰石資訊"
	locales["Reset Info"] = "重置數據"
else
	locales["Account Keystones"] = "Account Keystone"
	locales["Reset Info"] = "Reset Data"
end

ns.Locales = locales