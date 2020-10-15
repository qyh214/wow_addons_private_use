local W, F, L, _, O = unpack(select(2, ...))
local QK = W:GetModule("QuickKeystone")

O.quickKeystone = {
    order = 5,
    name = L["Quick Keystone"],
    type = "group",
    get = function(info)
        return W.db[info[#info - 1]][info[#info]]
    end,
    set = function(info, value)
        W.db[info[#info - 1]][info[#info]] = value
        QK:ProfileUpdate()
    end,
    args = {
        enable = {
            order = 1,
            type = "toggle",
            name = L["Enable"],
            desc = L["Put the keystone from bag automatically."],
            width = "full"
        }
    }
}