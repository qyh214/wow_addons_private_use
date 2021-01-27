local W, F, L, _, O = unpack(select(2, ...))
local MH = W:GetModule("MDTHelper")

O.mdtHelper = {
    order = 6,
    name = L["MDT Helper"],
    type = "group",
    get = function(info)
        return W.db[info[#info - 1]][info[#info]]
    end,
    set = function(info, value)
        W.db[info[#info - 1]][info[#info]] = value
        MH:ProfileUpdate()
        ReloadUI()
    end,
    args = {
        enable = {
            order = 1,
            type = "toggle",
            name = L["Enable"],
            desc = L["Put the keystone from bag automatically."],
            width = "full"
        },
        translate = {
            order = 2,
            type = "toggle",
            name = L["Translate Existing Data"],
            desc = L["Translate NPC names and types with your language."] .. "\n|cffff0000" .. L["Need reload"] .. "|r",
            width = "full"
        }
    }
}
