local W, F, L, P, O = unpack(select(2, ...))
local LDBI = LibStub("LibDBIcon-1.0")

local _G = _G

local format = format
local StaticPopup_Show = StaticPopup_Show

local wowVersion, wowPatch = GetBuildInfo()
local locale = GetLocale()

local discordURL = "https://discord.gg/nA44TeZ"
if locale == "zhCN" or locale == "zhTW" then
    discordURL = "https://discord.gg/wvV5rQy"
end

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
        minimapIcon = {
            order = 0,
            name = L["Minimap icon"],
            desc = format(L["Enables / disables %s minimap icon"], L["Wind Dungeon Helper"]),
            type = "toggle",
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
            order = 1,
            type = "description",
            fontSize = "medium",
            name = format(
                "%s\n\n%s\n\n%s\n\n",
                format(L["Thank you for using %s!"], L["Wind Dungeon Helper"]),
                format(L["%s is a plugin designed for dungeon combats."], L["Wind Dungeon Helper"]),
                format(
                    L["You can send your suggestions or bugs via %s, %s, %s, and the thread in %s."],
                    L["QQ Group"],
                    L["Discord"],
                    L["Github"],
                    L["NGA.cn"]
                )
            )
        },
        contributors = {
            order = 2,
            name = L["Contributors (Github.com)"],
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
                }
            }
        },
        version = {
            order = 3,
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
            order = 4,
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
                    width = 0.7
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
                            discordURL
                        )
                    end,
                    width = 0.7
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
                            "336069019"
                        )
                    end,
                    width = 0.7
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
                            "https://github.com/fang2hou/WindDungeonHelper/issues"
                        )
                    end,
                    width = 0.7
                }
            }
        }
    }
}
