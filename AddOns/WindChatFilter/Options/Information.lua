local W, F, L, P, G, O = unpack(select(2, ...))
local LDBI = LibStub("LibDBIcon-1.0")

local _G = _G
local format = format
local StaticPopup_Show = StaticPopup_Show

local wowVersion, wowPatch = GetBuildInfo()

local discordURL = "https://discord.gg/WHDER5SATV"
if W.Locale == "zhCN" or W.Locale == "zhTW" then
    discordURL = "https://discord.gg/SPqB72z7TK"
end

_G.StaticPopupDialogs["WIND_CHAT_FILTER_EDITBOX"] = {
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
    order = 10,
    type = "group",
    name = L["Information"],
    args = {
        minimapIcon = {
            order = 1,
            name = L["Minimap icon"],
            desc = format(L["Enables / disables %s minimap icon"], L["Wind Chat Filter"]),
            type = "toggle",
            set = function(info, value)
                W.db.minimapIcon.hide = not value
                if value then
                    LDBI:Show(L["Wind Chat Filter"])
                else
                    LDBI:Hide(L["Wind Chat Filter"])
                end
            end,
            get = function()
                return not W.db.minimapIcon.hide
            end
        },
        kofi = {
            order = 2,
            type = "execute",
            name = format("%s %s (%s)", F.GetIconString(W.Media.Icons.donateKofi, 14), L["Donate"], L["Ko-fi"]),
            func = function()
                StaticPopup_Show(
                    "WIND_CHAT_FILTER_EDITBOX",
                    L["Wind Chat Filter"] ..
                        " - " ..
                            format("%s %s (%s)", F.GetIconString(W.Media.Icons.donateKofi, 14), L["Donate"], L["Ko-fi"]),
                    nil,
                    "https://ko-fi.com/fang2hou"
                )
            end,
            width = 1.2
        },
        aiFaDian = {
            order = 3,
            type = "execute",
            name = format("%s %s (%s)", F.GetIconString(W.Media.Icons.donateAiFaDian, 14), L["Donate"], L["AiFaDian"]),
            func = function()
                StaticPopup_Show(
                    "WIND_CHAT_FILTER_EDITBOX",
                    L["Wind Chat Filter"] ..
                        " - " ..
                            format(
                                "%s %s (%s)",
                                F.GetIconString(W.Media.Icons.donateAiFaDian, 14),
                                L["Donate"],
                                L["AiFaDian"]
                            ),
                    nil,
                    "https://afdian.net/@fang2hou"
                )
            end,
            width = 1.2
        },
        betterAlign = {
            order = 4,
            type = "description",
            fontSize = "medium",
            name = " ",
            width = "full"
        },
        description = {
            order = 5,
            type = "description",
            fontSize = "medium",
            name = format(
                "%s\n\n%s\n\n%s\n\n",
                format(L["Thank you for using %s!"], L["Wind Chat Filter"]),
                format(L["%s is an addon aimed to filter some chat messages in game."], L["Wind Chat Filter"]),
                format(
                    L["You can send your suggestions or bugs via %s, %s, %s and the thread in %s."],
                    L["QQ Group"],
                    L["Discord"],
                    L["GitHub"],
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
                        F.CreateClassColorString("Tabideath @ " .. L["Shadowmoon"] .. "(TW)", "DEATHKNIGHT")
                    )
                },
                ["2"] = {
                    order = 2,
                    type = "description",
                    name = format("%s", "kpkhxlgy0")
                },
                ["3"] = {
                    order = 3,
                    type = "description",
                    name = format(
                        "%s: %s",
                        "BlueNightSky",
                        F.CreateClassColorString("三皈依 @ " .. L["Shadowmoon"] .. "(TW)", "SHAMAN")
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
                    name = L["Wind Chat Filter"] .. ": " .. F.CreateColorString(W.Version)
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
                            "WIND_CHAT_FILTER_EDITBOX",
                            L["Wind Chat Filter"] .. " - " .. L["NGA.cn"],
                            nil,
                            "https://nga.178.com/read.php?tid=35272239"
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
                            "WIND_CHAT_FILTER_EDITBOX",
                            L["Wind Chat Filter"] .. " - " .. L["Discord"],
                            nil,
                            discordURL
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
                            "WIND_CHAT_FILTER_EDITBOX",
                            L["Wind Chat Filter"] .. " - " .. L["QQ Group"],
                            nil,
                            "336069019"
                        )
                    end,
                    width = 0.6
                },
                github = {
                    order = 4,
                    type = "execute",
                    name = L["GitHub"],
                    image = W.Media.Icons.github,
                    func = function()
                        StaticPopup_Show(
                            "WIND_CHAT_FILTER_EDITBOX",
                            L["Wind Chat Filter"] .. " - " .. L["GitHub"],
                            nil,
                            "https://github.com/fang2hou/" .. W.AddonNamePlain .. "/issues"
                        )
                    end,
                    width = 0.6
                }
            }
        }
    }
}
