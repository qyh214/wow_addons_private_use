---@class AbstractFramework
local AF = _G.AbstractFramework

function AF.ShowDemo()
    if _G.AF_DEMO then
        _G.AF_DEMO:Show()
        return
    end

    -----------------------------------------------------------------------------
    --                              headered frame                             --
    -----------------------------------------------------------------------------
    local demo = AF.CreateHeaderedFrame(AF.UIParent, "AF_DEMO",
        AF.GetIconString("AF", 16) .. AF.GetGradientText("AbstractFramework", "blazing_tangerine", "vivid_raspberry")
        .. " " .. AF.WrapTextInColor(AF.GetAddOnVersion(AF.name) .. " Demo", "white"), 710, 500)
    -- AF.SetPoint(demo, "LEFT", 100, 0)
    demo:SetPoint("CENTER")
    demo:SetFrameLevel(500)
    demo:SetTitleJustify("LEFT")

    local moverTestFrames = {}

    -- background
    demo:SetScript("OnShow", function()
        if not DEV_BACKGROUND then
            DEV_BACKGROUND = CreateFrame("Frame", "DEV_BACKGROUND", nil, "BackdropTemplate")
            AF.ApplyDefaultBackdrop_NoBorder(DEV_BACKGROUND)
            DEV_BACKGROUND:SetBackdropColor(0.3, 0.3, 0.3, 1)
            DEV_BACKGROUND:SetAllPoints(UIParent)
            DEV_BACKGROUND:SetFrameStrata("BACKGROUND")
            DEV_BACKGROUND:SetFrameLevel(0)
            DEV_BACKGROUND:Hide()
        end
        DEV_BACKGROUND:Show()

        for _, f in pairs(moverTestFrames) do
            f:Show()
        end
    end)

    demo:SetScript("OnHide", function()
        DEV_BACKGROUND:Hide()
        for _, f in pairs(moverTestFrames) do
            f:Hide()
        end
    end)

    demo:Show()

    -- netstats
    local ns = AF.CreateNetStatsPane(demo.header, "RIGHT", true, true)
    AF.SetPoint(ns, "RIGHT", demo.header.closeBtn, "LEFT", -5, 0)

    -- fps
    local fps = AF.CreateFPSPane(demo.header, "RIGHT")
    AF.SetPoint(fps, "RIGHT", ns, "LEFT", -230, 0)

    -----------------------------------------------------------------------------
    --                                 github                                  --
    -----------------------------------------------------------------------------
    local github = AF.CreateEditBox(demo, nil, 350, 20)
    AF.SetPoint(github, "TOPRIGHT", demo, "BOTTOMRIGHT")
    github:SetBackdropBorderColor(AF.GetColorRGB("accent"))
    github:SetText("https://github.com/enderneko/AbstractFramework")
    github:SetNotUserChangable(true)
    github:SetCursorPosition(0)


    -----------------------------------------------------------------------------
    --                         apply combat protection                         --
    -----------------------------------------------------------------------------
    AF.ApplyCombatProtectionToFrame(demo)


    -----------------------------------------------------------------------------
    --                                  button                                 --
    -----------------------------------------------------------------------------
    local b1 = AF.CreateButton(demo, "Button A", "accent", 100, 20)
    AF.SetPoint(b1, "TOPLEFT", 10, -10)
    AF.SetTooltips(b1, "ANCHOR_TOPLEFT", 0, 2, "Tooltip Title", "This is a tooltip")

    local b2 = AF.CreateButton(demo, "Button B", "green", 100, 20)
    AF.SetPoint(b2, "TOPLEFT", b1, "TOPRIGHT", 10, 0)
    b2:SetEnabled(false)

    local b3 = AF.CreateButton(demo, "Button C", "static", 100, 20)
    AF.SetPoint(b3, "TOPLEFT", b2, "TOPRIGHT", 10, 0)
    AF.SetTooltips(b3, "ANCHOR_TOPLEFT", 0, 2, "Another Style", "SetTextHighlightColor", "SetBorderHighlightColor")
    b3:SetTextHighlightColor("accent")
    b3:SetBorderHighlightColor("accent")

    local b4 = AF.CreateButton(demo, "Button D", "red", 100, 20)
    b4:SetTexture("classicon-" .. strlower(PlayerUtil.GetClassFile()), {16, 16}, {"LEFT", 2, 0}, true)
    AF.SetPoint(b4, "TOPLEFT", b3, "TOPRIGHT", 10, 0)

    local b5 = AF.CreateButton(demo, nil, "accent", 20, 20)
    b5:SetTexture("classicon-" .. strlower(PlayerUtil.GetClassFile()), {16, 16}, {"CENTER", 0, 0}, true)
    AF.SetPoint(b5, "TOPLEFT", b4, "TOPRIGHT", 10, 0)

    local b6 = AF.CreateButton(demo, nil, "accent", 20, 20)
    b6:SetTexture("classicon-" .. strlower(PlayerUtil.GetClassFile()), {16, 16}, {"CENTER", 0, 0}, true)
    AF.SetPoint(b6, "TOPLEFT", b5, "TOPRIGHT", 10, 0)
    b6:SetEnabled(false)

    local iconBtn = AF.CreateIconButton(demo, AF.GetIcon("Info_Square"), 20, 20, 2, "gray")
    AF.SetPoint(iconBtn, "TOPLEFT", b6, "TOPRIGHT", 10, 0)


    -----------------------------------------------------------------------------
    --                               check button                              --
    -----------------------------------------------------------------------------
    local cb1 = AF.CreateCheckButton(demo, "Check boxes")
    AF.SetPoint(cb1, "TOPLEFT", b1, "BOTTOMLEFT", 0, -10)
    AF.SetTooltips(cb1, "ANCHOR_TOPLEFT", 0, 3, "Check Button", "The hit rectangle of these check buttons are different")

    local cb2 = AF.CreateCheckButton(demo, "With")
    AF.SetPoint(cb2, "TOPLEFT", cb1, "BOTTOMLEFT", 0, -7)
    cb2:SetEnabled(false)

    local cb3 = AF.CreateCheckButton(demo, "Different label lengths", function(checked)
        cb2:SetChecked(checked)
    end)
    AF.SetPoint(cb3, "TOPLEFT", cb2, "BOTTOMLEFT", 0, -7)


    -----------------------------------------------------------------------------
    --                                 edit box                                --
    -----------------------------------------------------------------------------
    local eb1 = AF.CreateEditBox(demo, "Edit Box", 200, 20)
    AF.SetPoint(eb1, "TOPLEFT", cb3, "BOTTOMLEFT", 0, -10)
    eb1:SetOnTextChanged(function(text)
        AF.Print("TextChanged:", text)
    end)
    eb1:SetText("Hello!")

    local eb2 = AF.CreateEditBox(demo, "Number Only", 200, 20, "number")
    AF.SetPoint(eb2, "TOPLEFT", eb1, "BOTTOMLEFT", 0, -10)
    eb2:SetConfirmButton(function(text)
        AF.Print("ConfirmButtonClicked:", text)
    end)

    local eb3 = AF.CreateEditBox(demo, "Edit Box", 200, 20)
    AF.SetPoint(eb3, "TOPLEFT", eb2, "BOTTOMLEFT", 0, -10)
    eb3:SetText("Disabled Edit Box")
    eb3:SetEnabled(false)

    local eb4 = AF.CreateScrollEditBox(demo, nil, "Scroll Edit Box", 100, 110)
    AF.SetPoint(eb4, "TOPLEFT", eb3, "BOTTOMLEFT", 0, -10)
    eb4:SetText("1 First\n2 Second\n3 Third\n4 Fourth\n5 Fifth\n6 Sixth\n7 Seventh\n8 Eighth\n9 Ninth\n10 Tenth")

    local cb4 = AF.CreateCheckButton(demo, nil, function(checked, self)
        eb4:SetEnabled(checked)
    end)
    AF.SetPoint(cb4, "BOTTOMLEFT", eb4, "BOTTOMRIGHT", 2, 0)
    cb4:SetChecked(true)


    -----------------------------------------------------------------------------
    --                              bordered frame                             --
    -----------------------------------------------------------------------------
    local bf1 = AF.CreateBorderedFrame(demo, nil, 150, 150, nil, "accent")
    AF.SetPoint(bf1, "TOPLEFT", b3, "BOTTOMLEFT", 0, -10)


    -----------------------------------------------------------------------------
    --                               font string                               --
    -----------------------------------------------------------------------------
    local fs1 = AF.CreateFontString(bf1, "Bordered Frame", "gray")
    AF.SetPoint(fs1, "TOPLEFT", 5, -5)


    -----------------------------------------------------------------------------
    --                               titled pane                               --
    -----------------------------------------------------------------------------
    local tp1 = AF.CreateTitledPane(demo, "Titled Pane", 140, 100)
    AF.SetPoint(tp1, "TOPLEFT", bf1, 5, -30)


    -----------------------------------------------------------------------------
    --                               button group                              --
    -----------------------------------------------------------------------------
    local bf2 = AF.CreateBorderedFrame(demo, nil, 100)
    bf2:SetLabel("Button Group")
    AF.SetPoint(bf2, "TOPLEFT", eb4, "BOTTOMLEFT", 0, -27)
    AF.SetListHeight(bf2, 3, 20, -1)

    local gb1 = AF.CreateButton(bf2, "Item A", "accent_transparent", 100, 20, nil, "none", "")
    gb1.id = "gb1"
    gb1:SetTextJustifyH("LEFT")
    AF.SetPoint(gb1, "TOPLEFT")
    AF.SetPoint(gb1, "RIGHT")
    AF.SetTooltips(gb1, "LEFT", -2, 0, "Item A")

    local gb2 = AF.CreateButton(bf2, "Item B", "red_transparent", 100, 20, nil, "none", "")
    gb2.id = "gb2"
    gb2:SetTextJustifyH("LEFT")
    AF.SetPoint(gb2, "TOPLEFT", gb1, "BOTTOMLEFT", 0, 1)
    AF.SetPoint(gb2, "RIGHT")
    AF.SetTooltips(gb2, "LEFT", -2, 0, "Item B")

    local gb3 = AF.CreateButton(bf2, "Item C", "lime_transparent", 100, 20, nil, "none", "")
    gb3.id = "gb3"
    gb3:SetTextJustifyH("LEFT")
    AF.SetPoint(gb3, "TOPLEFT", gb2, "BOTTOMLEFT", 0, 1)
    AF.SetPoint(gb3, "RIGHT")
    AF.SetTooltips(gb3, "LEFT", -2, 0, "Item C")

    AF.CreateButtonGroup({gb1, gb2, gb3}, function(id)
        AF.Print("selected", id)
    end)


    -----------------------------------------------------------------------------
    --                               scroll frame                              --
    -----------------------------------------------------------------------------
    local sf1 = AF.CreateScrollFrame(demo, nil, 150, 150)
    AF.SetPoint(sf1, "TOPLEFT", bf1, "BOTTOMLEFT", 0, -10)
    -- AF.SetPoint(sf1, "TOPRIGHT", bf1, "BOTTOMRIGHT", 0, -10)

    sf1.tex = AF.CreateGradientTexture(sf1.scrollContent, "VERTICAL", {0.96, 0.26, 0.41, 1}, {0.24, 0.23, 0.57, 1})
    AF.SetPoint(sf1.tex, "TOPLEFT", sf1.scrollContent, 1, -1)
    AF.SetPoint(sf1.tex, "BOTTOMRIGHT", sf1.scrollContent, -1, 1)

    sf1.b1 = AF.CreateButton(sf1.scrollContent, "Entry", "blue", 20, 20)
    AF.SetPoint(sf1.b1, "TOPLEFT")
    AF.SetPoint(sf1.b1, "RIGHT")

    sf1:SetContentHeight(20)


    -----------------------------------------------------------------------------
    --                                  switch                                 --
    -----------------------------------------------------------------------------
    local sw1 = AF.CreateSwitch(demo, 150, 20, {
        {
            ["text"] = "20",
            ["value"] = 20,
            ["onClick"] = function()
                sf1:SetContentHeight(20)
            end,
        },
        {
            ["text"] = "100",
            ["value"] = 100,
            ["onClick"] = function()
                sf1:SetContentHeight(100)
            end,
        },
        {
            ["text"] = "200",
            ["value"] = 200,
            ["onClick"] = function()
                sf1:SetContentHeight(200)
            end,
        },
        {
            ["text"] = "400",
            ["value"] = 400,
            ["onClick"] = function()
                sf1:SetContentHeight(400)
            end,
        }
    })
    AF.SetPoint(sw1, "TOPLEFT", sf1, "BOTTOMLEFT", 0, -10)
    sw1:SetSelectedValue(20)


    -----------------------------------------------------------------------------
    --                                  slider                                 --
    -----------------------------------------------------------------------------
    local sl1 = AF.CreateSlider(tp1, "Scale", 130, 0.5, 2, 0.01)
    AF.SetPoint(sl1, "TOPLEFT", 5, -40)
    AF.SetTooltips(sl1, "TOPLEFT", 0, 20, "Set scale of AF.UIParent", "If scale is too small, there can be some display issues", "It's highly recommended to do a UI reload after changing scale")
    sl1:SetValue(AF.GetScale())
    sl1:SetAfterValueChanged(function(value)
        AF.SetScale(value)
    end)

    local sl2 = AF.CreateSlider(demo, "Enabled", 100, 0.5, 5, 0.1, true)
    AF.SetPoint(sl2, "TOPLEFT", eb4, "TOPRIGHT", 10, -25)
    sl2:SetValue(1)
    sl2:SetOnValueChanged(function(value)
        AF.Print("OnSliderValueChanged:", value)
    end)
    sl2:SetAfterValueChanged(function(value)
        AF.Print("AfterSliderValueChanged:", value)
    end)

    local cb5 = AF.CreateCheckButton(demo, nil, function(checked, self)
        sl2:SetEnabled(checked)
        sl2:SetLabel(checked and "Enabled" or "Disabled")
        AF.ShowNotificationText(checked and "Enabled" or "Disabled", "red", nil, nil, "BOTTOMLEFT", self, "TOPLEFT", 0, 3)
    end)
    AF.SetPoint(cb5, "BOTTOMLEFT", sl2, "TOPLEFT", 0, 1)
    cb5:SetChecked(true)

    local sl3 = AF.CreateVerticalSlider(demo, "Vertical Slider", 100, -50, 50, 1)
    AF.SetPoint(sl3, "TOPLEFT", sl2, "BOTTOMLEFT", 45, -30)
    sl3:UpdateWordWrap()
    sl3:SetValue(0) -- for percentage, set value * 100
    sl3:SetOnValueChanged(function(value)
        AF.Print("VERTICAL_OnSliderValueChanged:", value) -- for percentage, get value / 100
    end)
    sl3:SetAfterValueChanged(function(value)
        AF.Print("VERTICAL_AfterSliderValueChanged:", value) -- for percentage, get value / 100
    end)

    local sl4 = AF.CreateSlider(tp1, "Font Size", 130, -5, 5, 1)
    AF.SetPoint(sl4, "TOPLEFT", sl1, 0, -50)
    sl4:SetValue(0)
    sl4:SetAfterValueChanged(function(value)
        AF.UpdateFontSize(value)
    end)


    -----------------------------------------------------------------------------
    --                               scroll list                               --
    -----------------------------------------------------------------------------
    local slist1 = AF.CreateScrollList(demo, nil, 5, 5, 7, 20, 5)
    AF.SetWidth(slist1, 150)
    AF.SetPoint(slist1, "TOPLEFT", bf1, "TOPRIGHT", 10, 0)
    local widgets = {}
    for i = 1, 20 do
        tinsert(widgets, AF.CreateButton(slist1.slotFrame, "Item " .. i, "accent_hover", 20, 20))
    end
    slist1:SetWidgets(widgets)



    -----------------------------------------------------------------------------
    --                             cascading menu                              --
    -----------------------------------------------------------------------------
    local cm = AF.CreateCascadingMenuButton(demo, 150)
    AF.SetPoint(cm, "TOP", b6, 0, -15)
    AF.SetPoint(cm, "LEFT", slist1, "RIGHT", 10, 0)
    cm:SetLabel("Cascading Menu")

    do
        local data = {
            druid = {774, 8936, 190984},
            monk = {119611, 124682, 450805},
            priest = {139, 41635, 17},
        }

        local items = {}
        for class, spells in pairs(data) do
            local t = {
                ["text"] = class,
                ["icon"] = "classicon-" .. class,
                ["isIconAtlas"] = true,
                ["notClickable"] = true,
                ["children"] = {}
            }
            for _, spellID in ipairs(spells) do
                local name, icon = AF.GetSpellInfo(spellID)
                tinsert(t.children, {
                    ["text"] = name,
                    ["icon"] = icon,
                    ["iconBorderColor"] = "black",
                    ["onClick"] = function()
                        AF.Print(string.format("Class: %s, SpellID: %d, SpellName: %s", class, spellID, name))
                    end
                })
            end
            tinsert(items, t)
        end

        local fireballName, fireballIcon = AF.GetSpellInfo(133)
        tinsert(items, {
            ["text"] = fireballName,
            ["icon"] = fireballIcon,
            ["iconBorderColor"] = "black",
            ["onClick"] = function()
                AF.Print(string.format("SpellID: %d, SpellName: %s", 133, fireballName))
            end,
            ["children"] = {
                {
                    ["text"] = "Rank 1",
                    ["onClick"] = function()
                        AF.Print("Fireball Rank 1")
                    end
                },
                {
                    ["text"] = "Rank 2",
                    ["onClick"] = function()
                        AF.Print("Fireball Rank 2")
                    end
                },
                {
                    ["text"] = "Rank 3",
                    ["onClick"] = function()
                        AF.Print("Fireball Rank 3")
                    end
                }
            }
        })

        tinsert(items, {["text"] = "Item 1"})
        tinsert(items, {
            ["text"] = "Item 2",
            ["children"] = {
                {
                    ["text"] = "Item 2-1",
                },
                {
                    ["text"] = "Item 2-2",
                    ["children"] = {
                        {
                            ["text"] = "Item 2-2-1",
                        },
                        {
                            ["text"] = "Item 2-2-2",
                        }
                    }
                }
            }
        })

        cm:SetItems(items)

        hooksecurefunc(cm, "OnMenuSelection", function(self, item, path)
            local paths = {}
            for _, v in ipairs(path) do
                tinsert(paths, v.text)
            end
            AF.Print("OnMenuSelection:", table.concat(paths, AF.WrapTextInColor(" > ", "gray")))
        end)
    end

    -----------------------------------------------------------------------------
    --                                 dropdown                                --
    -----------------------------------------------------------------------------
    -- normal dropdown (items <= 10)
    local dd1 = AF.CreateDropdown(demo, 150)
    AF.SetPoint(dd1, "TOPLEFT", cm, "BOTTOMLEFT", 0, -30)
    AF.SetTooltips(dd1, "TOPLEFT", 0, 2, "Normal Dropdown 1")
    dd1:SetLabel("Normal Dropdown 1")
    dd1:SetOnClick(function(value)
        AF.Print("NormalDropdown1 Selected:", value)
    end)
    local items = {}
    for i = 1, 7 do
        tinsert(items, {["text"] = "Item " .. i})
    end
    dd1:SetItems(items)

    -- normal dropdown (items > 10)
    local dd2 = AF.CreateDropdown(demo, 150)
    AF.SetPoint(dd2, "TOPLEFT", dd1, "BOTTOMLEFT", 0, -30)
    AF.SetTooltips(dd2, "TOPLEFT", 0, 2, "Normal Dropdown 2")
    dd2:SetLabel("Normal Dropdown 2")
    dd2:SetOnClick(function(value)
        AF.Print("NormalDropdown2 Selected:", value)
    end)
    local items = {}
    for i = 1, 20 do
        tinsert(items, {["text"] = "Item " .. i})
    end
    dd2:SetItems(items)

    -- empty dropdown
    local dd3 = AF.CreateDropdown(demo, 150)
    AF.SetPoint(dd3, "TOPLEFT", dd2, "BOTTOMLEFT", 0, -30)
    dd3:SetLabel("Empty Dropdown")

    -- disabled dropdown
    local dd4 = AF.CreateDropdown(demo, 150)
    AF.SetPoint(dd4, "TOPLEFT", dd3, "BOTTOMLEFT", 0, -30)
    dd4:SetLabel("Disabled Dropdown")
    dd4:SetEnabled(false)
    dd4:SetItems({
        {
            ["text"] = "Item 0",
            -- ["value"] = "item0" -- if value not set, value = text
        }
    })
    dd4:SetSelectedValue("Item 0")
    -- dd4:SetSelectedValue("item0")

    -- font dropdown
    local dd5 = AF.CreateDropdown(demo, 150, 10, "font")
    AF.SetPoint(dd5, "TOPLEFT", dd4, "BOTTOMLEFT", 0, -30)
    dd5:SetLabel("Font Dropdown")
    AF.SetTooltips(dd5, "TOPLEFT", 0, 2, "Font Dropdown", "Using LibSharedMedia")

    local LSM = LibStub("LibSharedMedia-3.0", true)
    if LSM then
        local items = {}
        local fonts, fontNames = LSM:HashTable("font"), LSM:List("font")
        for _, name in ipairs(fontNames) do
            tinsert(items, {
                ["text"] = name,
                ["font"] = fonts[name],
            })
        end
        dd5:SetItems(items)
    end

    -- texture dropdown
    local dd6 = AF.CreateDropdown(demo, 150, 10, "texture")
    AF.SetPoint(dd6, "TOPLEFT", dd5, "BOTTOMLEFT", 0, -30)
    dd6:SetLabel("Texture Dropdown")
    AF.SetTooltips(dd6, "TOPLEFT", 0, 2, "Texture Dropdown", "Using LibSharedMedia")

    if LSM then
        local items = {}
        local textures, textureNames = LSM:HashTable("statusbar"), LSM:List("statusbar")
        for _, name in ipairs(textureNames) do
            tinsert(items, {
                ["text"] = name,
                ["texture"] = textures[name],
            })
        end
        dd6:SetItems(items)
    end

    -- vertical mini dropdown
    local dd7 = AF.CreateDropdown(demo, 100, 10, nil, true)
    AF.SetPoint(dd7, "TOPLEFT", dd6, "BOTTOMLEFT", 0, -30)
    dd7:SetLabel("Mini Dropdown (V)")
    local items = {}
    for i = 1, 5 do
        tinsert(items, {
            ["text"] = "VMini " .. i
        })
    end
    dd7:SetItems(items)

    -- horizontal mini dropdown
    local dd8 = AF.CreateDropdown(demo, 100, 10, nil, true, true)
    AF.SetPoint(dd8, "TOPLEFT", dd7, "BOTTOMLEFT", 0, -30)
    dd8:SetLabel("Mini Dropdown (H)")
    local items = {}
    for i = 1, 3 do
        tinsert(items, {
            ["text"] = "HMini " .. i
        })
    end
    dd8:SetItems(items)


    -----------------------------------------------------------------------------
    --                              color picker                               --
    -----------------------------------------------------------------------------
    local cp1 = AF.CreateColorPicker(demo, "Color Picker", true, function(r, g, b, a)
        AF.Print("ColorPicker1_OnChange:", r, g, b, a)
    end, function(r, g, b, a)
        AF.Print("ColorPicker1_OnConfirm:", r, g, b, a)
    end)
    AF.SetPoint(cp1, "TOPLEFT", slist1, "BOTTOMLEFT", 0, -10)
    cp1:SetColor(AF.GetColorRGB("pink", 0.7))

    local cp2 = AF.CreateColorPicker(demo, "CP No Alpha")
    AF.SetPoint(cp2, "TOPLEFT", cp1, "BOTTOMLEFT", 0, -7)
    cp2:SetColor(AF.GetColorRGB("skyblue"))

    local cp3 = AF.CreateColorPicker(demo, "CP Disabled")
    AF.SetPoint(cp3, "TOPLEFT", cp2, "BOTTOMLEFT", 0, -7)
    cp3:SetColor(AF.GetColorTable("purple"))
    cp3:SetEnabled(false)


    -----------------------------------------------------------------------------
    --                                 dialog1                                 --
    -----------------------------------------------------------------------------
    local b7 = AF.CreateButton(demo, "Dialog1", "accent_hover", 150, 20)
    AF.SetPoint(b7, "TOPLEFT", cp3, "BOTTOMLEFT", 0, -10)
    b7:SetScript("OnClick", function()
        local text = AF.WrapTextInColor("Test Message", "firebrick") .. "\nReload UI now?\n" .. AF.WrapTextInColor("The quick brown fox jumps over the lazy dog", "gray")
        AF.ShowDialog(demo, text, 200, nil, nil, true)
        AF.SetDialogPoint("TOPLEFT", 255, -170)
        AF.SetDialogOnConfirm(function()
            C_UI.Reload()
        end)
    end)


    -----------------------------------------------------------------------------
    --                                 dialog2                                 --
    -----------------------------------------------------------------------------
    local b8 = AF.CreateButton(demo, "Dialog2", "accent_hover", 150, 20)
    AF.SetPoint(b8, "TOPLEFT", b7, "BOTTOMLEFT", 0, -7)

    -- content
    local form = AF.CreateDialogContent(50)

    -- NOTE: use WIDTH for pixel perfect

    local eb5 = AF.CreateEditBox(form, "type somthing", 172, 20)
    AF.SetPoint(eb5, "TOPLEFT")
    -- AF.SetPoint(eb5, "TOPRIGHT")

    local dd9 = AF.CreateDropdown(form, 172)
    AF.SetPoint(dd9, "TOPLEFT", eb5, "BOTTOMLEFT", 0, -7)
    -- AF.SetPoint(dd9, "TOPRIGHT", eb5, "BOTTOMRIGHT", 0, -7)
    local items = {}
    for i = 1, 7 do
        tinsert(items, {["text"] = "Item " .. i})
    end
    dd9:SetItems(items)

    eb5:SetOnTextChanged(function(text)
        form.dialog.yes:SetEnabled(text ~= "" and dd9:GetSelected())
        form.value1 = text
    end)

    dd9:SetOnClick(function(value)
        form.dialog.yes:SetEnabled(strtrim(eb5:GetText()) ~= "" and dd9:GetSelected())
        form.value2 = value
    end)

    form:SetScript("OnShow", function()
        eb5:Clear()
        dd9:ClearSelected()
    end)

    b8:SetScript("OnClick", function()
        AF.ShowDialog(demo, AF.WrapTextInColor("Test Form", "yellow"), 200, _G.OKAY, _G.CANCEL, true, form, true)
        AF.SetDialogPoint("TOPLEFT", 255, -170)
        AF.ResizeDialogButtonToFitText(70)
        AF.SetDialogOnConfirm(function()
            AF.Print("Dialog Confirmed:", form.value1, form.value2)
        end)
    end)


    -----------------------------------------------------------------------------
    --                            notificator dialog                           --
    -----------------------------------------------------------------------------
    local b9 = AF.CreateButton(demo, "NotificationDialog", "accent_hover", 150, 20)
    AF.SetPoint(b9, "TOPLEFT", b8, "BOTTOMLEFT", 0, -7)
    b9:SetScript("OnClick", function()
        local text = AF.WrapTextInColor("NOTICE", "orange") .. "\n" .. "One day, when what has happened behind the scene could be told, developers and gamers will have a whole new level understanding of how much damage a jerk can make."
        local dialog = AF.ShowNotificationDialog(demo, text, 200, true, 3)
        AF.ShowNormalGlow(dialog, "accent", 3)
        AF.SetNotificationDialogPoint("TOPLEFT", 255, -120)
    end)


    -----------------------------------------------------------------------------
    --                               scroll text                               --
    -----------------------------------------------------------------------------
    local bf3 = AF.CreateBorderedFrame(demo, nil, 530, 20)
    AF.SetPoint(bf3, "TOPLEFT", bf2, "BOTTOMLEFT", 0, -10)

    local st = AF.CreateScrollingText(bf3, 0.01)
    AF.SetPoint(st, "TOPLEFT", 4, 0)
    AF.SetPoint(st, "TOPRIGHT", -4, 0)
    st:SetText("World of Warcraft, often abbreviated as WoW, is a massively multiplayer online roleplaying game (MMORPG) developed by Blizzard Entertainment and released on November 23, 2004, on the 10th anniversary of the Warcraft franchise, three years after its announcement on September 2, 2001. It is the fourth released game set in the Warcraft universe, and takes place four years after the events of Warcraft III: The Frozen Throne.", "gold")


    -----------------------------------------------------------------------------
    --                             animated resize                             --
    -----------------------------------------------------------------------------
    local b10 = AF.CreateButton(demo, "Animated Resize", "accent_hover", 150, 20)
    AF.SetPoint(b10, "TOPLEFT", bf3, "BOTTOMLEFT", 0, -10)

    local bf4 = AF.CreateBorderedFrame(demo, nil, 120, 78, nil, "hotpink")
    AF.SetFrameLevel(bf4, 50)
    bf4:Hide()
    AF.SetPoint(bf4, "BOTTOMLEFT", b10, "TOPLEFT", 0, 10)

    bf4.widthText = AF.CreateFontString(bf4, "120", "hotpink")
    AF.SetPoint(bf4.widthText, "BOTTOMLEFT", bf4, "TOPLEFT", 0, 2)

    bf4.heightText = AF.CreateFontString(bf4, "78", "hotpink")
    AF.SetPoint(bf4.heightText, "BOTTOMLEFT", bf4, "BOTTOMRIGHT", 2, 0)

    local function UpdateSizeText(width, height)
        bf4.widthText:SetText(Round(width))
        bf4.heightText:SetText(Round(height))
    end

    b10:SetScript("OnClick", function()
        if bf4:IsShown() then
            AF.HideMask(demo)
            AF.SetFrameLevel(b10, 1)
            bf4:Hide()
        else
            AF.ShowMask(demo)
            AF.SetFrameLevel(b10, 50)
            bf4:Show()
        end
    end)

    -- both
    local b11 = AF.CreateButton(bf4, "Both+", "hotpink", 100, 20)
    AF.SetPoint(b11, "BOTTOMLEFT", 10, 10)

    -- height
    local b12 = AF.CreateButton(bf4, "Height+", "hotpink", 100, 20)
    AF.SetPoint(b12, "BOTTOMLEFT", b11, "TOPLEFT", 0, -1)

    -- width
    local b13 = AF.CreateButton(bf4, "Width+", "hotpink", 100, 20)
    AF.SetPoint(b13, "BOTTOMLEFT", b12, "TOPLEFT", 0, -1)

    local maxWidth, maxHeight

    b11:SetScript("OnClick", function()
        if not maxWidth or not maxHeight then
            AF.AnimatedResize(bf4, 300, 200, nil, nil, function()
                AF.Disable(b11, b12, b13)
            end, function()
                maxWidth, maxHeight = true, true
                AF.Enable(b11, b12, b13)
                b11:SetText("Both-")
                b12:SetText("Height-")
                b13:SetText("Width-")
            end, UpdateSizeText)
        else
            AF.AnimatedResize(bf4, 120, 78, nil, nil, function()
                AF.Disable(b11, b12, b13)
            end, function()
                maxWidth, maxHeight = false, false
                AF.Enable(b11, b12, b13)
                b11:SetText("Both+")
                b12:SetText("Height+")
                b13:SetText("Width+")
            end, UpdateSizeText)
        end
    end)

    b12:SetScript("OnClick", function()
        if not maxHeight then
            AF.AnimatedResize(bf4, nil, 200, nil, nil, function()
                AF.Disable(b11, b12, b13)
            end, function()
                maxHeight = true
                AF.Enable(b11, b12, b13)
                b12:SetText("Height-")
                if maxWidth then b11:SetText("Both-") end
            end, UpdateSizeText)
        else
            AF.AnimatedResize(bf4, nil, 78, nil, nil, function()
                AF.Disable(b11, b12, b13)
            end, function()
                maxHeight = false
                AF.Enable(b11, b12, b13)
                b12:SetText("Height+")
                b11:SetText("Both+")
            end, UpdateSizeText)
        end
    end)

    b13:SetScript("OnClick", function()
        if not maxWidth then
            AF.AnimatedResize(bf4, 300, nil, nil, nil, function()
                AF.Disable(b11, b12, b13)
            end, function()
                maxWidth = true
                AF.Enable(b11, b12, b13)
                b13:SetText("Width-")
                if maxHeight then b11:SetText("Both-") end
            end, UpdateSizeText)
        else
            AF.AnimatedResize(bf4, 120, nil, nil, nil, function()
                AF.Disable(b11, b12, b13)
            end, function()
                maxWidth = false
                AF.Enable(b11, b12, b13)
                b13:SetText("Width+")
                b11:SetText("Both+")
            end, UpdateSizeText)
        end
    end)


    -----------------------------------------------------------------------------
    --                                status bar                               --
    -----------------------------------------------------------------------------
    local function OnUpdate(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed >= 0.02 then
            self.elapsed = 0
            if self.isReverse then
                self.value = (self.value or 0) - 1
            else
                self.value = (self.value or 0) + 1
            end
            if self.value == 100 then
                self.isReverse = true
                self.elapsed = -1
            elseif self.value == 0 then
                self.isReverse = false
                self.elapsed = -1
            end
            self:SetBarValue(self.value)
        end
    end

    local bar1 = AF.CreateBlizzardStatusBar(demo, 0, 100, 100, 20, "skyblue", nil, "percentage")
    AF.SetPoint(bar1, "TOPLEFT", b10, "BOTTOMLEFT", 0, -10)

    local bar2 = AF.CreateBlizzardStatusBar(demo, 0, 100, 100, 20, "hotpink", nil, "current_value")
    AF.SetPoint(bar2, "TOPLEFT", bar1, "TOPRIGHT", 10, 0)
    bar2:SetScript("OnUpdate", OnUpdate)

    local bar3 = AF.CreateBlizzardStatusBar(demo, 0, 100, 100, 20, "lime", nil, "current_max")
    AF.SetPoint(bar3, "TOPLEFT", bar2, "TOPRIGHT", 10, 0)
    bar3:SetScript("OnUpdate", OnUpdate)

    local bar4 = AF.CreateBlizzardStatusBar(demo, 0, 100, 320, 7, "accent")
    AF.SetPoint(bar4, "TOPLEFT", bar1, "BOTTOMLEFT", 0, -5)

    bar1:SetScript("OnUpdate", function(self, elapsed)
        OnUpdate(self, elapsed)
        if self.value == 100 then
            bar4:SetSmoothedValue(100)
        elseif self.value == 50 then
            bar4:SetSmoothedValue(50)
        elseif self.value == 0 then
            bar4:SetSmoothedValue(0)
        end
    end)


    -----------------------------------------------------------------------------
    --                                  popups                                 --
    -----------------------------------------------------------------------------
    local bf5 = AF.CreateBorderedFrame(demo, nil, 370, 20)
    AF.SetPoint(bf5, "BOTTOMLEFT", b10, "BOTTOMRIGHT", 10, 0)

    local fs2 = AF.CreateFontString(bf5, "Popups", "accent")
    AF.SetPoint(fs2, "LEFT", bf5, 10, 0)

    local b14 = AF.CreateButton(bf5, "PPopup+", "accent", 95, 20)
    AF.SetPoint(b14, "BOTTOMRIGHT")
    AF.SetTooltips(b14, "ANCHOR_TOPLEFT", 0, 2, "Progress Popup", "With progress bar", "Hide in 5 sec after completion")
    b14:SetScript("OnClick", function()
        local callback = AF.ShowProgressPopup("In Progress...", 100)
        local v = 0
        C_Timer.NewTicker(2, function()
            v = v + 25
            callback(v)
        end, 4)
    end)

    local b15 = AF.CreateButton(bf5, "CPopup+", "accent", 95, 20)
    AF.SetPoint(b15, "BOTTOMRIGHT", b14, "BOTTOMLEFT", 1, 0)
    AF.SetTooltips(b15, "ANCHOR_TOPLEFT", 0, 2, "Confirm Popup", "With \"Yes\" & \"No\" buttons", "Won't hide automatically")
    b15:SetScript("OnClick", function()
        for i = 1, 3 do
            AF.ShowConfirmPopup("Confirm " .. i, function()
                AF.Print("Confirm " .. i, "yes")
            end, function()
                AF.Print("Confirm " .. i, "no")
            end)
        end
    end)

    local b16 = AF.CreateButton(bf5, "NPopup+", "accent", 95, 20)
    AF.SetPoint(b16, "BOTTOMRIGHT", b15, "BOTTOMLEFT", 1, 0)
    AF.SetTooltips(b16, "ANCHOR_TOPLEFT", 0, 2, "Notification Popup", "With timeout", "Right-Click to hide")
    b16:SetScript("OnClick", function()
        for i = 1, 3 do
            local timeout = random(2, 7)
            AF.ShowNotificationPopup("Notification " .. AF.WrapTextInColor(timeout .. "sec", "gray"), timeout)
        end
    end)

    -----------------------------------------------------------------------------
    --                                 calendar                                --
    -----------------------------------------------------------------------------
    local dw = AF.CreateCalendarButton(demo, 150, "TOPLEFT")
    AF.SetPoint(dw, "TOPLEFT", b9, "BOTTOMLEFT", 0, -7)
    local niceDays = {}
    local colors = {"firebrick", "hotpink", "chartreuse", "vividblue"}
    local today = date("*t")
    for i = 1, 7 do
        local str = string.format("%04d%02d%02d", today.year, today.month, random(1, 27))
        if not niceDays[str] then
            niceDays[str] = {color = colors[random(1, 4)], tooltips = {"Nice Day", str}}
        end
    end
    dw:SetMarks(niceDays)
    dw:SetOnDateChanged(function(dt)
        AF.Print(dt.year, dt.month, dt.day, dt.timestamp)
    end)

    -----------------------------------------------------------------------------
    --                                  mover                                  --
    -----------------------------------------------------------------------------
    local mbf = AF.CreateBorderedFrame(demo, nil, 290, 20)
    AF.SetPoint(mbf, "TOPLEFT", bar3, "TOPRIGHT", 10, 0)

    local fs3 = AF.CreateFontString(mbf, "Movers", "accent")
    AF.SetPoint(fs3, "LEFT", mbf, 10, 0)

    local mDropdown

    local undoBtn = AF.CreateButton(mbf, "Undo", "accent", 60, 20)
    AF.SetPoint(undoBtn, "TOPRIGHT")
    undoBtn:SetScript("OnClick", function()
        AF.UndoMovers()
    end)

    local hmBtn = AF.CreateButton(mbf, "Hide", "accent", 60, 20)
    AF.SetPoint(hmBtn, "TOPRIGHT", undoBtn, "TOPLEFT", 1, 0)
    hmBtn:SetScript("OnClick", function()
        AF.HideMovers()
        mDropdown:ClearSelected()
    end)

    mDropdown = AF.CreateDropdown(mbf, 85, 10, nil, true)
    AF.SetPoint(mDropdown, "TOPRIGHT", hmBtn, "TOPLEFT", 1, 0)
    AF.SetTooltips(mDropdown, "TOPLEFT", 0, 2, "Mover Tips", "- Drag to move", "- Use (shift) mouse wheel to move frame by 1 pixel", "- Right-Click to open fine-tuning frame", "- Shift+Right-Click to hide a mover")
    mDropdown:SetItems({
        {
            ["text"] = "All",
            ["onClick"] = function()
                AF.ShowMovers()
            end,
        },
        {
            ["text"] = "Popups",
            ["onClick"] = function()
                AF.ShowMovers("Popups")
            end,
        },
        {
            ["text"] = "Test 1",
            ["onClick"] = function()
                AF.ShowMovers("Test 1")
            end,
        },
        {
            ["text"] = "Test 2",
            ["onClick"] = function()
                AF.ShowMovers("Test 2")
            end,
        },
    })

    local function CreateMoverTestFrame(id, group, point)
        local f = AF.CreateBorderedFrame(AF.UIParent, nil, 170, 70)
        tinsert(moverTestFrames, f)
        AF.SetPoint(f, point)
        f:SetLabel("Mover Test Frame " .. id .. "\n" .. point, "hotpink", nil, true)
        AF.CreateMover(f, group, "Test Mover " .. id, function(p, x, y) AF.Print("MTF" .. id .. ":", p, x, y) end)
    end

    -- group1
    CreateMoverTestFrame(1, "Test 1", "TOPLEFT")
    CreateMoverTestFrame(2, "Test 1", "LEFT")
    CreateMoverTestFrame(3, "Test 1", "BOTTOMLEFT")
    CreateMoverTestFrame(4, "Test 1", "TOP")
    CreateMoverTestFrame(5, "Test 1", "CENTER")

    -- group2
    CreateMoverTestFrame(6, "Test 2", "TOPRIGHT")
    CreateMoverTestFrame(7, "Test 2", "RIGHT")
    CreateMoverTestFrame(8, "Test 2", "BOTTOM")
    CreateMoverTestFrame(9, "Test 2", "BOTTOMRIGHT")


    -----------------------------------------------------------------------------
    --                                 helptip                                 --
    -----------------------------------------------------------------------------
    local htBtn = AF.CreateButton(demo, "HelpTip", "gold", nil, 20)
    AF.SetPoint(htBtn, "TOPLEFT", undoBtn, "TOPRIGHT", 5, 0)
    AF.SetPoint(htBtn, "RIGHT", cm)

    local tips = {
        {
            widget = sw1,
            position = "TOP",
            text = "Switch\n(Group HelpTip 1/3)",
            glow = true,
            callback = function()
                AF.Print("Switch!")
            end
        },
        {
            widget = b7,
            position = "LEFT",
            text = "Dialog\n(Group HelpTip 2/3)",
            glow = true,
            callback = function()
                AF.Print("Dialog!")
            end
        },
        {
            widget = dd6,
            position = "RIGHT",
            text = "Dropdown\n(Group HelpTip 3/3)",
            glow = true,
            callback = function()
                AF.Print("Dropdown!")
            end
        },
    }

    htBtn:SetOnClick(function()
        AF.HideAllHelpTips()
        AF.ShowHelpTip({
            widget = cm,
            position = "RIGHT",
            text = "Cascading Menu\n(Single HelpTip)",
            -- glow = true,
            callback = function()
                AF.Print("HelpTip viewed and closed")
            end
        })
        AF.ShowHelpTipGroup(tips)
    end)
end