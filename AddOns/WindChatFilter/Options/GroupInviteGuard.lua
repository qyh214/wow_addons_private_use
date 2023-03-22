local W, F, L, P, G, O = unpack(select(2, ...))

local modes = {
    "onlyFriendsOrGuildMembers",
    "smartMode",
    "chatFilterMode"
}

local function changeMode(mode)
    if F.In(mode, modes) then
        for _, _mode in pairs(modes) do
            W.db.groupInviteGuard[_mode] = _mode == mode
        end
    end
end

O.groupInviteGuard = {
    order = 20,
    name = L["Group Invite Guard"],
    type = "group",
    args = {
        description = {
            order = 1,
            type = "group",
            inline = true,
            name = L["Description"],
            args = {
                description = {
                    order = 1,
                    type = "description",
                    fontSize = "medium",
                    name = L["This module will help you to automatically decline group invitations."] ..
                        "\n" .. L["This feature does not block invitations from premade groups."],
                    width = "full"
                }
            }
        },
        general = {
            order = 2,
            type = "group",
            inline = true,
            name = L["General"],
            get = function(info)
                return W.db.groupInviteGuard[info[#info]]
            end,
            set = function(info, value)
                W.db.groupInviteGuard[info[#info]] = value
            end,
            args = {
                enabled = {
                    order = 1,
                    type = "toggle",
                    name = L["Enabled"],
                    width = "full",
                    desc = L["Enable this module."]
                },
                displayMessageAfterRejecting = {
                    order = 2,
                    type = "toggle",
                    name = L["Reject Message"],
                    desc = L["Display a message after rejecting a group invitation."]
                },
                allowWhisperedTarget = {
                    order = 3,
                    type = "toggle",
                    name = L["Allow Whispered Target"],
                    desc = L["Allow group invites from players who you sent whispers recently."]
                },
                modes = {
                    order = 4,
                    type = "group",
                    inline = true,
                    name = L["Modes"],
                    get = function(info)
                        return W.db.groupInviteGuard[info[#info]]
                    end,
                    set = function(info, value)
                        if value then
                            changeMode(info[#info])
                        end
                    end,
                    args = {
                        smartMode = {
                            order = 1,
                            type = "toggle",
                            name = L["Smart Mode"],
                            desc = L["It should be worked in most cases, but not always."],
                            width = 1.5
                        },
                        onlyFriendsOrGuildMembers = {
                            order = 2,
                            type = "toggle",
                            name = L["Strict Mode"],
                            desc = L["Decline all group invites NOT from friends or guild members."],
                            width = 1.5
                        },
                        chatFilterMode = {
                            order = 3,
                            type = "toggle",
                            name = L["Chat Filter Mode"],
                            desc = L["Enable this mode to filter group invites with existing chat filters."] ..
                                "\n" .. L["The filtering will ignore channel limitation of rules."],
                            width = 1.5
                        }
                    }
                }
            }
        }
    }
}
