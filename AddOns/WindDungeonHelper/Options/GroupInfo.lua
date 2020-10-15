local W, F, L, _, O = unpack(select(2, ...))
local GI = W:GetModule("GroupInfo")

O.groupInfo = {
    order = 5,
    name = L["Group Info"],
    type = "group",
    get = function(info)
        return W.db[info[#info - 1]][info[#info]]
    end,
    set = function(info, value)
        W.db[info[#info - 1]][info[#info]] = value
        GI:ProfileUpdate()
    end,
    args = {
        enable = {
            order = 1,
            type = "toggle",
            name = L["Enable"],
            desc = L["Add LFG group info to tooltip."],
            width = "full"
        },
        title = {
            order = 2,
            type = "toggle",
            name = L["Add Title"],
            desc = L["Display an additional title."]
        },
        mode = {
            order = 3,
            name = L["Mode"],
            type = "select",
            values = {
                NORMAL = L["Normal"],
                COMPACT = L["Compact"]
            }
        }
    }
}
