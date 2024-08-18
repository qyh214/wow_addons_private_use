local W, F, L, P, O = unpack(select(2, ...))
local LDBI = LibStub("LibDBIcon-1.0")

local _G = _G

local format = format
local StaticPopup_Show = StaticPopup_Show

local wowVersion, wowPatch = GetBuildInfo()

_G.StaticPopupDialogs["WIND_DUNGEON_HELPER_EDITBOX"] = {
    text = "",
    button1 = _G.OKAY,
    hasEditBox = true,
    OnShow = function(self, data)
        self.editBox:SetAutoFocus(false)
        self.editBox.width = self.editBox:GetWidth()
        self.editBox:SetWidth(250)
        self.editBox:AddHistoryLine("text")
        self.editBox.temptxt = data
        self.editBox:SetText(data)
        self.editBox:HighlightText()
        self.editBox:SetJustifyH("CENTER")

        self.text:SetText(self.text.text_arg1)
    end,
    OnHide = function(self)
        self.editBox:SetWidth(self.editBox.width or 50)
        self.editBox.width = nil
        self.temptxt = nil
    end,
    EditBoxOnEnterPressed = function(self)
        self:GetParent():Hide()
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    EditBoxOnTextChanged = function(self)
        if self:GetText() ~= self.temptxt then
            self:SetText(self.temptxt)
        end
        self:HighlightText()
        self:ClearFocus()
    end,
    OnAccept = function()
        return
    end,
    whileDead = true,
    preferredIndex = 3,
    hideOnEscape = true
}

O.information = {
    order = 1,
    type = "group",
    name = L["Information"],
    args = {
        kofi = {
            order = 1,
            type = "execute",
            name = format("%s %s (%s)", F.GetIconString(W.Media.Icons.donateKofi, 14), L["Donate"], L["Ko-fi"]),
            func = function()
                StaticPopup_Show(
                    "WIND_DUNGEON_HELPER_EDITBOX",
                    L["Wind Dungeon Helper"] ..
                        " - " ..
                            format("%s %s (%s)", F.GetIconString(W.Media.Icons.donateKofi, 14), L["Donate"], L["Ko-fi"]),
                    nil,
                    "https://ko-fi.com/fang2hou"
                )
            end,
            width = 1.2
        },
        aiFaDian = {
            order = 2,
            type = "execute",
            name = format("%s %s (%s)", F.GetIconString(W.Media.Icons.donateAiFaDian, 14), L["Donate"], L["AiFaDian"]),
            func = function()
                StaticPopup_Show(
                    "WIND_DUNGEON_HELPER_EDITBOX",
                    L["Wind Dungeon Helper"] ..
                        " - " ..
                            format(
                                "%s %s (%s)",
                                F.GetIconString(W.Media.Icons.donateAiFaDian, 14),
                                L["Donate"],
                                L["AiFaDian"]
                            ),
                    nil,
                    "https://afdian.com/a/fang2hou"
                )
            end,
            width = 1.2
        },
        betterAlign = {
            order = 3,
            type = "description",
            fontSize = "medium",
            name = " ",
            width = "full"
        },
        minimapIcon = {
            order = 4,
            name = L["Minimap icon"],
            desc = format(L["Enables / disables %s minimap icon"], L["Wind Dungeon Helper"]),
            type = "toggle",
            width = "full",
            set = function(info, value)
                W.db.minimapIcon.hide = not value
                if value then
                    LDBI:Show(L["Wind Dungeon Helper"])
                else
                    LDBI:Hide(L["Wind Dungeon Helper"])
                end
            end,
            get = function()
                return not W.db.minimapIcon.hide
            end
        },
        description = {
            order = 5,
            type = "description",
            fontSize = "medium",
            name = format(
                "%s\n\n%s\n\n%s\n\n",
                format(L["Thank you for using %s!"], L["Wind Dungeon Helper"]),
                format(L["%s is a plugin designed for dungeon combats."], L["Wind Dungeon Helper"]),
                format(
                    L["You can send your suggestions or bugs via %s, %s, %s, %s and the thread in %s."],
                    L["QQ Group"],
                    L["Discord"],
                    L["KOOK"],
                    L["Github"],
                    L["NGA.cn"]
                )
            )
        },
        contributors = {
            order = 6,
            name = L["Contributors (GitHub.com)"],
            type = "group",
            inline = true,
            args = {
                ["1"] = {
                    order = 1,
                    type = "description",
                    name = format(
                        "%s: %s",
                        "fang2hou",
                        F.CreateClassColorString("Tabimonk @ " .. L["Shadowmoon"] .. "(TW)", "MONK")
                    )
                },
                ["2"] = {
                    order = 2,
                    type = "description",
                    name = format(
                        "%s: %s",
                        "tro-janek",
                        F.CreateClassColorString("Mhalvir @ " .. L["Burning Legion"] .. "(EU)", "SHAMAN")
                    )
                }
            }
        },
        version = {
            order = 7,
            name = L["Version"],
            type = "group",
            inline = true,
            args = {
                windtools = {
                    order = 1,
                    type = "description",
                    name = L["Wind Dungeon Helper"] .. ": " .. F.CreateColorString(W.Version)
                },
                build = {
                    order = 2,
                    type = "description",
                    name = L["WoW Build"] .. ": " .. F.CreateColorString(format("%s (%s)", wowVersion, wowPatch))
                }
            }
        },
        contact = {
            order = 8,
            type = "group",
            inline = true,
            name = " ",
            args = {
                nga = {
                    order = 1,
                    type = "execute",
                    name = L["NGA.cn"],
                    image = W.Media.Icons.nga,
                    func = function()
                        StaticPopup_Show(
                            "WIND_DUNGEON_HELPER_EDITBOX",
                            L["Wind Dungeon Helper"] .. " - " .. L["NGA.cn"],
                            nil,
                            "https://nga.178.com/read.php?tid=15265896"
                        )
                    end,
                    width = 0.6
                },
                discord = {
                    order = 2,
                    type = "execute",
                    name = L["Discord"],
                    image = W.Media.Icons.discord,
                    func = function()
                        StaticPopup_Show(
                            "WIND_DUNGEON_HELPER_EDITBOX",
                            L["Wind Dungeon Helper"] .. " - " .. L["Discord"],
                            nil,
                            "https://discord.gg/CMDsBmhvyW"
                        )
                    end,
                    width = 0.6
                },
                qq = {
                    order = 3,
                    type = "execute",
                    name = L["QQ Group"],
                    image = W.Media.Icons.qq,
                    func = function()
                        StaticPopup_Show(
                            "WIND_DUNGEON_HELPER_EDITBOX",
                            L["Wind Dungeon Helper"] .. " - " .. L["QQ Group"],
                            nil,
                            "948518444"
                        )
                    end,
                    width = 0.6
                },
                github = {
                    order = 4,
                    type = "execute",
                    name = L["Github"],
                    image = W.Media.Icons.github,
                    func = function()
                        StaticPopup_Show(
                            "WIND_DUNGEON_HELPER_EDITBOX",
                            L["Wind Dungeon Helper"] .. " - " .. L["Github"],
                            nil,
                            "https://github.com/wind-addons/WindDungeonHelper/issues"
                        )
                    end,
                    width = 0.6
                }
            }
        }
    }
}
