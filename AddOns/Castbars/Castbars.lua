local Castbars = LibStub("AceAddon-3.0"):NewAddon("Castbars", "AceConsole-3.0");

Castbars.SharedMedia = LibStub("LibSharedMedia-3.0");
Castbars.DoNothing = function() end;

Castbars.BaseTickDuration =
{
    -- Warlock
    [GetSpellInfo(689) or ""] = 1, -- Drain Life
    [GetSpellInfo(103103) or ""] = 1, -- Drain Soul
    [GetSpellInfo(755) or ""] = 1, -- Health Funnel
    [GetSpellInfo(1949) or ""] = 1, -- Hellfire
    -- Druid
    [GetSpellInfo(740) or ""] = 2, -- Tranquility
    [GetSpellInfo(16914) or ""] = 1, -- Hurricane
    -- Priest
    [GetSpellInfo(47540) or ""] = 1, -- Penance
    [GetSpellInfo(15407) or ""] = 1, -- Mind Flay
    [GetSpellInfo(129197) or ""] = 1, -- Mind Flay (Insanity)
    [GetSpellInfo(48045) or ""] = 1, -- Mind Sear
    [GetSpellInfo(64843) or ""] = 2, -- Divine Hymn
    [GetSpellInfo(179338) or ""] = 1, -- Searing Insanity
    -- Mage
    [GetSpellInfo(10) or ""] = 1, -- Blizzard
    [GetSpellInfo(5143) or ""] = 0.4, -- Arcane Missiles
    [GetSpellInfo(12051) or ""] = 2, -- Evocation
    -- Monk
    [GetSpellInfo(117952) or ""] = 1, -- Crackling Jade Lightning
    [GetSpellInfo(115175) or ""] = 1, -- Soothing Mist
    [GetSpellInfo(113656) or ""] = 1, -- Fists of Fury
    [GetSpellInfo(115294) or ""] = -1, -- Mana Tea (not modified by haste)
}

Castbars.Barticks = setmetatable({},
{
    __index = function(tick, i)
        local spark = CastingBarFrame:CreateTexture(nil, 'ARTWORK');
        tick[i] = spark;
        spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark");
        spark:SetVertexColor(1, 1, 1, 0.75);
        spark:SetBlendMode('ADD');
        spark:SetWidth(10);
        return spark;
    end
})

function Castbars:CastingBarFrameTicksSet(frame)
    for _, tick in ipairs(self.Barticks) do
        tick:Hide();
    end
    if (frame) then
        local baseTickDuration = self.BaseTickDuration[frame.spellName];
        local tickDuration;
        if (baseTickDuration) then
            if (baseTickDuration > 0) then
                local castTime = select(4, GetSpellInfo(2060)); -- Heal - works for all classes
                if (not castTime or (castTime == 0)) then
                    castTime = 2500 / (1 + (GetCombatRatingBonus(CR_HASTE_SPELL) or 0) / 100);
                end
                tickDuration = (castTime / 2500) * baseTickDuration;
            else
                tickDuration = -baseTickDuration;
            end                
        end
        if (tickDuration) then
            local width = self.db.profile["CastingBarFrame"]["Width"];
            local delta = (tickDuration * width / frame.maxValue);
            local tickIndex = 1;
            while (delta * tickIndex) < width do
                local tick = self.Barticks[tickIndex];
                tick:SetHeight(self.db.profile["CastingBarFrame"]["Height"] * 1.5);
                tick:SetPoint("CENTER", CastingBarFrame, "LEFT", delta * tickIndex, 0);
                tick:Show();
                tickIndex = tickIndex + 1;
            end
        end
    end
end

function Castbars:IsDualWielding()
    local _, _, ohLow, ohHigh = UnitDamage("player");
    if (self.playerClass ~= "DRUID" and ohLow ~= ohHigh) then
        return true;
    end
end

-- Preloaded with spells that don't work with FindSpellBookSlotBySpellID
local spellbook =
{
    [77767] = true, -- Cobra Shot
    [15407] = true, -- Mind Flay
};
function Castbars:IsSpellBookSpell(spellId)
    if (spellbook[spellId]) then return true end
    local spellBookSlot = FindSpellBookSlotBySpellID(spellId);
    if (spellBookSlot) then
        spellbook[spellId] = true;
        return true;
    end
end

function Castbars:FrameMediaRestore(frame)
    local barTexture = self.SharedMedia:Fetch("statusbar", self.db.profile[frame.configName]["Texture"]);
    local borderTexture = self.SharedMedia:Fetch("border", self.db.profile[frame.configName]["Border"]);
    local font = self.SharedMedia:Fetch("font", self.db.profile[frame.configName]["Font"]);
    if (barTexture) then
        frame.statusBar:setStatusBarTexture(barTexture);
        if (frame.latency) then
            frame.latency:SetTexture(barTexture);
            frame.queuezone:SetTexture(barTexture);
        end
    end
    if (borderTexture) then
        local edgeSize = (self.db.profile[frame.configName]["Height"] - 2) / 1.5;
        if (edgeSize > 16) then edgeSize = 16 end
        edgeSize = edgeSize + self.db.profile[frame.configName]["BorderWidthAdjustment"];
        if (edgeSize < 0.1) then edgeSize = 0.1 end
        frame.borderWidth = (edgeSize + 2 / 1.5) / 2 + self.db.profile[frame.configName]["BorderOffsetAdjustment"];
        frame.backdrop:SetBackdrop({edgeFile = borderTexture, edgeSize = edgeSize});
        frame.backdrop:SetBackdropBorderColor(unpack(self.db.profile[frame.configName]["BorderColor"]));
    else
        frame.backdrop:SetBackdropBorderColor(unpack({0, 0, 0, 0}));
    end
    if (font) then
        local textSize = self.db.profile[frame.configName]["FontSize"];
        local outline = self.db.profile[frame.configName]["FontOutline"] and "OUTLINE" or nil;
        frame.text:SetFont(font, textSize, outline);
        frame.tmr:SetFont(font, textSize, outline);
    end
end

function Castbars:FrameMediaRestoreAll()
    for i, frame in pairs(self.frames) do
        self:FrameMediaRestore(frame)
    end
end

function Castbars:FrameTimerRestore(frame, adjustTextWidth)
    if (frame.mergingTradeSkill) then
        if (frame.casting and frame.maxValue == frame.maxValueMerge) then
            local secLeft = max(frame.maxValue - frame.value, 0);
            local minLeft = floor(secLeft / 60);
            frame.tmr:SetFormattedText("%d/%d - %d:%02d", frame.countCurrent, frame.countTotal, minLeft, secLeft - minLeft * 60);
        end
    elseif (frame.casting) then
        if (frame.delayTime and self.db.profile[frame.configName]["ShowPushback"]) then
            frame.tmr:SetFormattedText("|cFFFF0000+%.1f |cFFFFFFFF" .. frame.castTimeFormat, frame.delayTime, max(frame.maxValue - frame.value, 0), frame.maxValue);
        else
            frame.tmr:SetFormattedText(frame.castTimeFormat, max(frame.maxValue - frame.value, 0), frame.maxValue + (frame.delayTime or 0));
        end
    elseif (frame.channeling) then
        frame.tmr:SetFormattedText(frame.castTimeFormat, max(frame.value, 0), frame.maxValue);
    elseif (self.ConfigMode) then
        if (self.db.profile[frame.configName]["ShowPushback"]) then
            frame.tmr:SetFormattedText("|cFFFF0000+%.1f |cFFFFFFFF" .. frame.castTimeFormat, 0, 0, 0);
        else
            frame.tmr:SetFormattedText(frame.castTimeFormat, 0, 0);
        end
    elseif (frame.value and frame.timer) then -- MirrorTimer
        if (not frame.expirationTime) then
            local duration, expirationTime = select(6, UnitAura("player", frame.text:GetText(), nil, "HELPFUL|PLAYER|CANCELABLE"));
            if (duration and expirationTime) then
                frame.duration, frame.expirationTime = duration, expirationTime;
            end
        end
        frame.value = frame.expirationTime and frame.expirationTime - GetTime() or frame.value;
        frame.value = frame.duration and frame.value > frame.duration and frame.duration or frame.value;
        frame.value = frame.value < 0 and 0 or frame.value;
        local minLeft = floor(frame.value / 60);
        frame.tmr:SetFormattedText("%d:%02d", minLeft, floor(frame.value - minLeft * 60));
    else
        frame.tmr:SetText();
    end
    if (frame.text and adjustTextWidth) then
        frame.text:SetWidthReal(frame:GetWidth() - 10 - frame.tmr:GetWidth());
    end
end

function Castbars:FrameColorRestore(frame)
    local r, g, b;
    if (frame.shield and frame.shield:IsShown()) then
        r, g, b = unpack(self.db.profile[frame.configName]["BarColorShielded"]);
    elseif (frame.outOfRange) then
        r, g, b = unpack(self.db.profile[frame.configName]["BarColorOutOfRange"]);
    elseif (frame.channeling) then
        r, g, b = unpack(self.db.profile[frame.configName]["BarColorChanneling"]);
    else
        r, g, b = unpack(self.db.profile[frame.configName]["BarColor"]);
    end
    frame.statusBar:SetStatusBarColor(r, g, b);
    frame.shade:SetTexture(r * 0.1, g * 0.1, b * 0.1, 0.5);
end

function Castbars:FrameIconRestore(frame)
    if (frame.icon) then
        local height = frame:GetHeight();
        if (frame.shield and frame.shield:IsShown() and self.db.profile[frame.configName]["ShowShield"]) then
            frame.icon:ClearAllPoints();
            frame.icon:SetPoint("RIGHT", frame, "LEFT", -0.5 * height, -0.16667 * height);
            frame.icon:SetHeight(1.8 * height);
            frame.icon:SetWidth(1.8 * height);
            frame.icon:show();
        elseif (self.db.profile[frame.configName]["ShowIcon"]) then
            frame.icon:ClearAllPoints();
            if (self.db.profile[frame.configName]["IconAlignment"] == "LEFT") then
                if (self.db.profile[frame.configName]["Border"] == "None") then
                    frame.icon:SetPoint("RIGHT", frame, "LEFT", 0, 0);
                else
                    frame.icon:SetPoint("RIGHT", frame, "LEFT", -3, 0);
                end
            else
                if (self.db.profile[frame.configName]["Border"] == "None") then
                    frame.icon:SetPoint("LEFT", frame, "RIGHT", 0, 0);
                else
                    frame.icon:SetPoint("LEFT", frame, "RIGHT", 3, 0);
                end
            end
            frame.icon:SetHeight(height);
            frame.icon:SetWidth(height);
            frame.icon:show();
        else
            frame.icon:hide();
        end
    end
end

function Castbars:FrameLatencyQueueRestore(frame)
    if (frame.latency and self.db.profile[frame.configName]["ShowLatency"] and not frame.mergingTradeSkill and frame.spellInSpellBook) then
        local start, stop = frame:GetMinMaxValues();
        local scale = (stop - start);
        local castTime = select(4, GetSpellInfo(2060)); -- Heal - works for all classes
        local lockout = (1.5 * (castTime or 2500) / 2500 - GetMaxSpellStartRecoveryOffset() / 1000) / scale;
        local latency;
        if (frame.spellInitialDelay) then
            latency = (frame.spellInitialDelay) / scale;
        else
            local _, _, _, roundtrip = GetNetStats();
            latency = (roundtrip / 1000) / scale;
        end
        if (latency > 1) then latency = 1 end
        frame.latency:SetWidth(frame:GetWidth() * latency);
        frame.latency:ClearAllPoints();
        if (frame.channeling) then
            frame.latency:SetTexCoord(0, latency, 0, 1);
            frame.latency:SetPoint("LEFT", frame, "LEFT", 0, 0);
            frame.queuezone:Hide();
        else
            local queue = 0.4 / scale;
            if ((latency + queue + lockout) > 1) then queue = math.max(1 - (latency + lockout), 0) end
            frame.latency:SetTexCoord(1 - latency, 1, 0, 1);
            frame.latency:SetPoint("RIGHT", frame, "RIGHT", 0, 0);
            if (queue > 0) then
                frame.queuezone:SetTexCoord(1 - (latency + queue), 1 - latency, 0, 1);
                frame.queuezone:SetWidth(frame:GetWidth() * queue);
                frame.queuezone:Show();
            else
                frame.queuezone:Hide();
            end
        end
        if (latency > 0) then frame.latency:Show() else frame.latency:Hide() end
    end
end

function Castbars:FrameTextRestore(frame)
    local barText = frame.text:GetText();
    if (frame.channeling and frame.spellName) then
        -- When channeling use the spellName (replaces "Channeling")
        barText = frame.spellName
    end
    if (self.db.profile[frame.configName]["ShowSpellName"]) then
        if (self.db.profile[frame.configName]["ShowSpellTarget"] and
            barText and
            frame.spellTargetName and
            frame.spellTargetName ~= "" and
            frame.spellTargetName ~= barText) then
            frame.text:SetFormattedText("%s (%s)", barText, frame.spellTargetName);
        else
            frame.text:SetText(barText);
        end
    elseif (self.db.profile[frame.configName]["ShowSpellTarget"] and
            frame.spellTargetName and
            frame.spellTargetName ~= "") then
        frame.text:SetText(frame.spellTargetName);
    else
        frame.text:SetText();
    end
end

function Castbars:FrameDynamicRestore(frame, unit, adjustTextWidth)
    self:FrameColorRestore(frame);
    self:FrameIconRestore(frame);
    self:FrameTimerRestore(frame, adjustTextWidth);
    self:FrameTextRestore(frame);
    if ((unit == "player") and (frame.unit == "player")) then
        self:FrameLatencyQueueRestore(frame);
    end
end

function Castbars:FrameLayoutRestore(frame)
    -- Position
    local position = self.db.profile[frame.configName]["Position"];
    if (frame.dragable and position) then
        frame:clearAllPoints();
        frame:setPoint(position.point, position.parent, position.relpoint, position.x, position.y);
    end

    -- Texture
    self:FrameMediaRestore(frame);

    -- Visibility
    if (self.db.profile[frame.configName]["Show"]) then
        if (frame == PetCastingBarFrame) then
            frame.showCastbar = self.db.profile[frame.configName]["Show"] or UnitIsPossessed("pet");
        else
            frame.showCastbar = true;
        end
    else
        frame.showCastbar = false;
    end

    -- Shield visibility
    if (frame.shield) then
        if (self.db.profile[frame.configName]["ShowShield"]) then
            frame.shield:SetTexture("Interface\\CastingBar\\UI-CastingBar-Arena-Shield");
            frame.shield:SetVertexColor(1, 1, 1, 0.65);
            frame.shieldborder:SetTexture("Interface\\CastingBar\\UI-CastingBar-Small-Shield");
            frame.shieldborder:SetTexCoord(0.15, 0.92, 0, 1);
            frame.shieldborder:SetVertexColor(1, 1, 1, 0.65);
        else
            frame.shield:SetTexture();
            frame.shieldborder:SetTexture();
        end
    end

    -- Total cast time
    frame.castTimeFormat = "%.1f";
    if (self.db.profile[frame.configName]["ShowTotalCastTime"]) then
        frame.castTimeFormat = frame.castTimeFormat .. "/%." .. (self.db.profile[frame.configName]["TotalCastTimeDecimals"] or "1") .. "f";
    end
    if (self.db.profile[frame.configName]["ShowPushback"]) then
        frame.tmr:SetFormattedText("|cFFFF0000+%.1f |cFFFFFFFF" .. frame.castTimeFormat, 0, 0, 0);
    else
        frame.tmr:SetFormattedText(frame.castTimeFormat, 0, 0);
    end

    -- Swing timer
    if (frame.swing) then
        frame.swing:UnregisterAllEvents();
        if (self.db.profile[frame.configName]["ShowSwingTimer"]) then
            frame.swing:RegisterEvent("PLAYER_LEAVE_COMBAT");
            frame.swing:RegisterEvent("STOP_AUTOREPEAT_SPELL");
            frame.swing:RegisterEvent("UNIT_ATTACK_SPEED");
            frame.swing:RegisterEvent("UNIT_RANGEDDAMAGE");
            frame.swing:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
            frame.swing:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
            local r, g, b = unpack(self.db.profile[frame.configName]["BarColor"]);
            frame.swing.texture:SetTexture(r, g, b);
        end
    end

    -- Text Alignment
    frame.text:SetJustifyH(self.db.profile[frame.configName]["TextAlignment"]);

    -- Dimensions
    frame:setWidth(self.db.profile[frame.configName]["Width"]);
    frame:setHeight(self.db.profile[frame.configName]["Height"]);

    -- Alpha
    frame:SetAlpha(self.db.profile[frame.configName]["Alpha"]);

    -- Restore dynamic settings
    self:FrameDynamicRestore(frame);
end

function Castbars:FrameLayoutRestoreAll()
    for i, frame in pairs(self.frames) do
        self:FrameLayoutRestore(frame)
    end
end

function Castbars:FrameCustomize(frame)
    local frameName = frame:GetName();
    local frameType;

    if (frameName:sub(1, 11) == "MirrorTimer") then
        local index = tonumber(frameName:sub(12,12));
        frameType = "Mirror";
        frame.statusBar = _G[frameName .. "StatusBar"];
        frame.configName = "MirrorTimer";
        frame.friendlyName = "Mirror Timer " .. index;
        if (index == 1) then
            frame.dragable = true;
        end
    elseif (frameName == "CastingBarFrame") then
        frameType = "Castbar";
        frame.statusBar = frame;
        frame.configName = frameName;
        frame.friendlyName = "Player/Vehicle Castbar";
        frame.dragable = true;
        frame.icon = _G[frameName .. "Icon"];
    elseif (frameName == "PetCastingBarFrame") then
        frameType = "Castbar";
        frame.statusBar = frame;
        frame.configName = UnitIsPossessed("pet") and "CastingBarFrame" or "PetCastingBarFrame";
        frame.friendlyName = "Pet Castbar";
        frame.dragable = true;
        frame.icon = _G[frameName .. "Icon"];
    elseif (frameName == "TargetCastingBarFrame") then
        frameType = "Castbar";
        frame.statusBar = frame;
        frame.configName = frameName;
        frame.friendlyName = "Target Castbar";
        frame.dragable = true;
        frame.icon = _G[frameName .. "Icon"];
        frame.shield = _G[frameName .. "BorderShield"];
    elseif (frameName == "FocusCastingBarFrame") then
        frameType = "Castbar";
        frame.statusBar = frame;
        frame.configName = frameName;
        frame.friendlyName = "Focus Castbar";
        frame.dragable = true;
        frame.icon = _G[frameName .. "Icon"];
        frame.shield = _G[frameName .. "BorderShield"];
    end

    -- Find the shade
    for i, region in pairs({frame:GetRegions()}) do
        if (region.GetDrawLayer and region:GetDrawLayer() == "BACKGROUND") then
            frame.shade = region;
        end
    end

    -- Make dragable
    if (frame.dragable) then
        frame:SetMovable(true);
        frame:RegisterForDrag("LeftButton");
        self.OnDragStart = self.OnDragStart or function(frame)
            if (self.ConfigMode) then
                GameTooltip:Hide();
                frame:EnableKeyboard(true);
                frame:StartMoving();
            end
        end
        frame:SetScript("OnDragStart", self.OnDragStart);
        self.OnDragStop = self.OnDragStop or function(frame)
            frame:EnableKeyboard(false);
            frame:StopMovingOrSizing();
            if (not self.db.profile[frame.configName]["Position"]) then
                self.db.profile[frame.configName]["Position"] = {};
            end
            local position = self.db.profile[frame.configName]["Position"];
            position.point, position.parent, position.relpoint, position.x, position.y = frame:GetPoint();
        end
        frame:SetScript("OnDragStop", self.OnDragStop);
        self.OnKeyUp = self.OnKeyUp or function(frame, key)
            local point, parent, relpoint, x, y = frame:GetPoint();
            if (key == "UP") then y = y + 1;
            elseif (key == "DOWN") then y = y - 1;
            elseif (key == "RIGHT") then x = x + 1;
            elseif (key == "LEFT") then x = x - 1; end
            frame:setPoint(point, parent, relpoint, x, y);
        end
        frame:SetScript("OnKeyUp", self.OnKeyUp);
        self.OnEnter = self.OnEnter or function(frame)
            if (self.ConfigMode and not frame:IsDragging()) then
                GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT");
                GameTooltip:SetText("|cFFFFFFFFDrag with mouse.\n|cFFCCCCCCUse arrow keys while dragging to fine tune position.");
            end
        end
        frame:SetScript("OnEnter", self.OnEnter);
        self.OnLeave = self.OnLeave or function(frame)
            GameTooltip:Hide();
        end
        frame:SetScript("OnLeave", self.OnLeave);
        frame:EnableKeyboard(false);
    end
    frame:EnableMouse(false);

    -- Adjust spark position
    frame.spark = _G[frameName .. "Spark"];
    if (frame.spark) then
        local setPoint = frame.spark.SetPoint;
        frame.spark.SetPoint = function(self, point, relativeFrame, relativePoint, x, y)
            setPoint(self, point, relativeFrame, relativePoint, x, 0);
        end
        frame.spark:SetWidth(10);
    end

    -- Adjust text position
    frame.text = _G[frameName .. "Text"];
    frame.text:ClearAllPoints();
    if (frameType == "Castbar") then
        frame.text:SetPoint("LEFT", frame.statusBar, "LEFT", 5, 0.25);
    elseif (frameType == "Mirror") then
        frame.text:SetPoint("CENTER", frame.statusBar, "CENTER", 0, 0.25);
    end

    -- Adjust Icon Texture
    if (frame.icon) then
        frame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93);
        frame.icon.show = frame.icon.Show;
        frame.icon.Show = self.DoNothing;
        frame.icon.hide = frame.icon.Hide;
        frame.icon.Hide = self.DoNothing;
    end

    -- Prevent other addons moving the text (and setting the width)
    frame.text.SetWidthReal = frame.text.SetWidth;
    frame.text.SetWidth = self.DoNothing;
    frame.text.ClearAllPoints = self.DoNothing;
    frame.text.SetAllPoints = self.DoNothing;
    frame.text.SetPoint = self.DoNothing;

    -- Prevent other addons moving/parenting/sizing/texturing the frame
    frame.clearAllPoints = frame.ClearAllPoints;
    frame.ClearAllPoints = self.DoNothing;
    frame.SetParent = self.DoNothing;
    frame.setPoint = frame.SetPoint;
    frame.SetPoint = self.DoNothing;
    frame.SetSize = self.DoNothing;
    frame.statusBar.setStatusBarTexture = frame.statusBar.SetStatusBarTexture;
    frame.statusBar.SetStatusBarTexture = self.DoNothing;

    -- Prevent other addons from modifying event registrations
    frame.UnregisterEvent = self.DoNothing;
    frame.UnregisterAllEvents = self.DoNothing;
    frame.RegisterEvent = self.DoNothing;

    -- Reuse the border texture as a shield border
    if (frame.shield) then
        frame.shieldborder = _G[frameName .. "Border"];
        local hide = frame.shieldborder.Hide;
        frame.shieldborder.Hide = frame.shieldborder.Show;
        frame.shieldborder.Show = hide;
    else
        local frameBorder = _G[frameName .. "Border"];
        frameBorder:SetTexture();
        frameBorder.SetTexture = self.DoNothing;
    end

    -- Remove the flash
    local frameFlash = _G[frameName .. "Flash"];
    if (frameFlash) then
        frameFlash:SetTexture();
        frameFlash.SetTexture = self.DoNothing;
    end

    -- Create backdrop
    frame.backdrop = CreateFrame("Frame", nil, frame);
    frame.backdrop:SetPoint("CENTER", frame.statusBar, "CENTER", 0, 0);

    if (frameName == "CastingBarFrame") then
        frame.gcd = CreateFrame("Frame", nil, UIParent);
        frame.gcd:SetPoint("BOTTOM", frame.statusBar, "TOP", 0, 0);
        frame.gcd:SetHeight(3);
        frame.gcd:Hide();
        frame.gcd.border = frame.gcd:CreateTexture(nil, "BACKGROUND");
        frame.gcd.border:SetAllPoints(frame.gcd);
        local texture = frame.gcd:CreateTexture(nil, "OVERLAY");
        texture:SetTexture("Spells\\AURA_01");
        texture:SetVertexColor(1, 1, 1, 1)
        texture:SetBlendMode('ADD');
        texture:SetWidth(35);
        texture:SetHeight(35);
        frame.gcd:SetScript("OnUpdate", function(frameGcd, elapsed)
            frameGcd.elapsed = (frameGcd.elapsed or 0) + elapsed;
            if (frameGcd.elapsed > 0.1) then
                frameGcd.elapsed = 0;
                if (frame:IsVisible()) then frame.gcd.border:SetTexture(0, 0, 0, 0) else frame.gcd.border:SetTexture(0, 0, 0, 0.5) end
            end
            local x = GetTime() * frameGcd.a - frameGcd.b;
            if (x > frameGcd:GetWidth()) then
                frameGcd:Hide();
            else
                texture:SetPoint("CENTER", frameGcd, "LEFT", x, 0);
            end
        end);
    end

    if (frameName == "CastingBarFrame") then
        frame.swing = CreateFrame("Frame", nil, UIParent);
        frame.swing:Hide();
        frame.swing:SetPoint("TOP", frame.statusBar, "BOTTOM", 0, 0);
        frame.swing:SetHeight(3);
        local border = frame.swing:CreateTexture(nil, "BACKGROUND");
        border:SetAllPoints(frame.swing);
        border:SetTexture(0, 0, 0, 0.5);
        frame.swing.texture = frame.swing:CreateTexture(nil, "ARTWORK");
        frame.swing.texture:SetHeight(frame.swing:GetHeight());
        frame.swing.texture:SetWidth(5);
        frame.swing.texture:SetPoint("LEFT", frame.swing, "LEFT", 0, 0);
        frame.swing:SetScript("OnUpdate", function(frameSwing, elapsed)
            if frameSwing.startTime then
                local spent = GetTime() - frameSwing.startTime;
                local perc = spent / frameSwing.duration;
                if (perc > 1) then
                    return frameSwing:Hide();
                else
                    frameSwing.texture:SetWidth(frameSwing:GetWidth() * perc);
                end
            end
        end);
        frame.swing:SetScript("OnEvent", function(frameSwing, event, ...)
            if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
                local _, combatevent, _, srcGUID, _, _, _, dstGUID = ...;
                local playerGuid = UnitGUID("player");
                if (srcGUID == playerGuid) then
                    if (combatevent == "SPELL_EXTRA_ATTACKS") then
                        frameSwing.extraAttacks = select(15 , ...);
                        frameSwing.extraInhibit = true;
                    elseif (combatevent == "SWING_DAMAGE" or combatevent == "SWING_MISSED") then
                        if ((frameSwing.extraAttacks or 0) > 0 and not frameSwing.extraInhibit) then
                            frameSwing.extraAttacks = (frameSwing.extraAttacks or 0) - 1;
                        elseif (not self:IsDualWielding()) then
                            frameSwing.extraInhibit = false;
                            frameSwing.duration = UnitAttackSpeed("player");
                            frameSwing.startTime = GetTime();
                            frameSwing:Show();
                        end
                    end
                elseif (dstGuid == playerGuid and combatevent == "SWING_MISSED") then
                    local missType = select(12, ...);
                    if (missType == "PARRY" and frameSwing.duration) then
                        frameSwing.duration = frameSwing.duration * 0.6;
                    end
                end
            elseif (event == "UNIT_ATTACK_SPEED" and ... == "player") then
                frameSwing.duration = UnitAttackSpeed("player");
            elseif (event == "UNIT_RANGEDDAMAGE" and ... == "player") then
                frameSwing.duration = UnitRangedDamage("player");
            elseif (event == "PLAYER_LEAVE_COMBAT" or event == "STOP_AUTOREPEAT_SPELL") then
                frameSwing:Hide();
            elseif (event == "UNIT_SPELLCAST_SUCCEEDED" and ... == "player") then
                local _, _, _, _, spellId = ...;
                if (spellId == 75 or spellId == 5019) then
                    frameSwing.duration = UnitRangedDamage("player");
                    frameSwing.startTime = GetTime();
                    frameSwing:Show();
                end
            end
        end);
    end

    -- Add timer text
    frame.tmr = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight");
    frame.tmr:SetPoint("RIGHT", frame.statusBar, "RIGHT", -5, 0.25);
    frame.nextupdate = 0.1;

    -- Prevent other addons from creating useful font strings from this frame
    local createFontString = frame.CreateFontString;
    frame.CreateFontString = function(...)
        local fontString = createFontString(...);
        fontString.SetFormattedText = self.DoNothing;
        fontString.SetText = self.DoNothing;
        return fontString;
    end

    if (frameType == "Castbar") then
        -- Add latency indication texture
        if (frameName == 'CastingBarFrame') then
            frame.latency = frame:CreateTexture(nil, "ARTWORK");
            frame.latency:SetVertexColor(1, 0, 0, 0.65);
            frame.queuezone = frame:CreateTexture(nil, "ARTWORK");
            frame.queuezone:SetVertexColor(0.5, 0, 0, 0.65);
            frame.queuezone:SetPoint("RIGHT", frame.latency, "LEFT", 0, 0);
            frame.queuezone:Hide();
        end

        -- Adjust shield layer
        if (frame.shield) then
            frame.shield:SetDrawLayer("OVERLAY");
        end
    end

    -- Automatically adjust the height of sub elements
    local setHeight = frame.SetHeight;
    if (frameType == "Castbar") then
        frame.setHeight = function(self, height)
            frame.backdrop:SetHeight(height + (frame.borderWidth or 0) - 2);
            frame.spark:SetHeight(1.8 * height);
            if (frame.latency) then
                frame.latency:SetHeight(height);
                frame.queuezone:SetHeight(height);
            end
            if (frame.shield) then
                frame.shield:SetHeight(5.4 * height);
                frame.shield:SetWidth(5.4 * height);
                frame.shield:ClearAllPoints();
                frame.shield:SetPoint("LEFT", frame.icon, "LEFT", -0.77143 * height, 0);
                frame.shieldborder:SetHeight(5 * height);
            end
            setHeight(self, height);
        end
    elseif (frameType == "Mirror") then
        frame.setHeight = function(self, height)
            frame.backdrop:SetHeight(height + (frame.borderWidth or 0) - 2);
            frame.statusBar:SetHeight(height);
            frame.shade:SetHeight(height);
            setHeight(self, height + 10); -- Spacing between mirror timer bars
        end
    end
    frame.SetHeight = self.DoNothing;

    -- Automatically adjust the width of sub elements
    local setWidth = frame.SetWidth
    if (frameType == "Castbar") then
        frame.setWidth = function(self, width)
            frame.backdrop:SetWidth(width + (frame.borderWidth or 0) - 2);
            frame.text:SetWidthReal(width - 10 - frame.tmr:GetWidth());
            if (frame.gcd) then
                frame.gcd:SetWidth(width);
            end
            if (frame.swing) then
                frame.swing:SetWidth(width);
            end
            if (frame.shield) then
                frame.shieldborder:SetWidth(1.05 * width);
                frame.shieldborder:ClearAllPoints();
                frame.shieldborder:SetPoint("CENTER", frame.statusBar, "CENTER", 0.015 * width, 0);
            end
            setWidth(self, width);
        end
    elseif (frameType == "Mirror") then
        frame.setWidth = function(self, width)
            frame.backdrop:SetWidth(width + (frame.borderWidth or 0) - 2);
            frame.statusBar:SetWidth(width);
            frame.shade:SetWidth(width);
            setWidth(self, width);
        end
    end
    frame.SetWidth = self.DoNothing;

    frame:Hide();
end

function Castbars:FrameCustomizeAll()
    for i, frame in pairs(self.frames) do
        self:FrameCustomize(frame)
    end
end

function Castbars:GetOptionsTableForBar(frameConfigName, friendlyName, order)
    local options =
    {
        type = "group",
        name = friendlyName,
        order = order,
        args =
        {
            width =
            {
                name = "Width",
                type = "range",
                order = 100,
                desc = "Set the width of the " .. friendlyName .. " bar",
                min = 50,
                max = 600,
                step = 1,
                get = function() return self.db.profile[frameConfigName]["Width"] end,
                set = function(info, value)
                    self.db.profile[frameConfigName]["Width"] = value;
                    self:FrameLayoutRestoreAll();
                end,
            },
            height =
            {
                name = "Height",
                type = "range",
                order = 101,
                desc = "Set the height of the " .. friendlyName .. " bar",
                min = 10,
                max = 100,
                step = 1,
                get = function() return self.db.profile[frameConfigName]["Height"] end,
                set = function(info, value)
                    self.db.profile[frameConfigName]["Height"] = value;
                    self:FrameLayoutRestoreAll();
                end,
            },
            texture =
            {
                name = "Texture",
                type = "select",
                order = 102,
                desc = "Select texture to use for the " .. friendlyName .. " bar",
                dialogControl = "LSM30_Statusbar",
                values = AceGUIWidgetLSMlists.statusbar,
                get = function() return self.db.profile[frameConfigName]["Texture"] end,
                set = function(info, value)
                    self.db.profile[frameConfigName]["Texture"] = value;
                    self:FrameLayoutRestoreAll();
                end,
            },
            color =
            {
                name = "Bar Color",
                type = "color",
                order = 103,
                desc = "Set color of the " .. friendlyName .. " bar",
                get = function(info)
                    return unpack(self.db.profile[frameConfigName]["BarColor"]);
                end,
                set = function(info, r, g, b)
                    self.db.profile[frameConfigName]["BarColor"] = {r, g, b};
                    self:FrameLayoutRestoreAll();
                end,
            },
            border =
            {
                name = "Border",
                type = "select",
                order = 105,
                desc = "Select border to use for the " .. friendlyName .. " bar",
                dialogControl = "LSM30_Border",
                values = AceGUIWidgetLSMlists.border,
                get = function() return self.db.profile[frameConfigName]["Border"] end,
                set = function(info, value)
                    self.db.profile[frameConfigName]["Border"] = value;
                    self:FrameLayoutRestoreAll();
                end,
            },
            bordercolor =
            {
                name = "Border Color",
                type = "color",
                hasAlpha = true,
                order = 106,
                desc = "Set color of the border of the " .. friendlyName .. " bar",
                get = function(info)
                    return unpack(self.db.profile[frameConfigName]["BorderColor"]);
                end,
                set = function(info, r, g, b, a)
                    self.db.profile[frameConfigName]["BorderColor"] = {r, g, b, a};
                    self:FrameLayoutRestoreAll();
                end,
            },
            borderwidthadjustment =
            {
                name = "Border Width Adjustment",
                type = "range",
                order = 107,
                desc = "Adjust the width of the border of the " .. friendlyName .. " bar",
                min = -16,
                max = 16,
                step = 0.1,
                get = function() return self.db.profile[frameConfigName]["BorderWidthAdjustment"] end,
                set = function(info, value)
                    self.db.profile[frameConfigName]["BorderWidthAdjustment"] = value;
                    self:FrameLayoutRestoreAll();
                end,
            },
            borderoffsetadjustment =
            {
                name = "Border Offset Adjustment",
                type = "range",
                order = 108,
                desc = "Adjust the offset of the border of the " .. friendlyName .. " bar",
                min = -16,
                max = 16,
                step = 0.1,
                get = function() return self.db.profile[frameConfigName]["BorderOffsetAdjustment"] end,
                set = function(info, value)
                    self.db.profile[frameConfigName]["BorderOffsetAdjustment"] = value;
                    self:FrameLayoutRestoreAll();
                end,
            },
            alpha =
            {
                name = "Opacity",
                type = "range",
                order = 109,
                desc = "Set the opacity of the " .. friendlyName .. " bar",
                min = 0,
                max = 1,
                step = 0.01,
                get = function() return self.db.profile[frameConfigName]["Alpha"] end,
                set = function(info, value)
                    self.db.profile[frameConfigName]["Alpha"] = value;
                    self:FrameLayoutRestoreAll();
                end,
            },
            font =
            {
                name = "Font",
                type = "select",
                order = 200,
                desc = "Select font to use for the " .. friendlyName .. " bar",
                dialogControl = "LSM30_Font",
                values = AceGUIWidgetLSMlists.font,
                get = function() return self.db.profile[frameConfigName]["Font"] end,
                set = function(info, value)
                    self.db.profile[frameConfigName]["Font"] = value;
                    self:FrameLayoutRestoreAll();
                end,
            },
            fontsize =
            {
                name = "Font Size",
                type = "range",
                order = 201,
                desc = "Set the font size of the " .. friendlyName .. " bar",
                min = 6,
                max = 30,
                step = 1,
                get = function() return self.db.profile[frameConfigName]["FontSize"] end,
                set = function(info, value)
                    self.db.profile[frameConfigName]["FontSize"] = value;
                    self:FrameLayoutRestoreAll();
                end,
            },
            fontoutline =
            {
                name = "Font Outline",
                type = "toggle",
                order = 202,
                desc = "Toggles outline on the font of the " .. friendlyName .. " bar",
                get = function() return self.db.profile[frameConfigName]["FontOutline"] end,
                set = function()
                    self.db.profile[frameConfigName]["FontOutline"] = not self.db.profile[frameConfigName]["FontOutline"];
                    self:FrameLayoutRestoreAll();
                end,
            },
        },
    };
    if (frameConfigName ~= "MirrorTimer") then
        options.args.enable =
        {
            name = "Enable",
            type = "toggle",
            order = 1,
            desc = "Toggles display of the " .. friendlyName .. " bar",
            get = function() return self.db.profile[frameConfigName]["Show"] end,
            set = function()
                self.db.profile[frameConfigName]["Show"] = not self.db.profile[frameConfigName]["Show"];
                self:FrameLayoutRestoreAll();
            end,
        }
    end
    if (frameConfigName ~= "MirrorTimer") then
        options.args.showicon =
        {
            name = "Show Icon",
            type = "toggle",
            order = 2,
            desc = "Toggles display of the icon at the left side of the bar",
            get = function() return self.db.profile[frameConfigName]["ShowIcon"] end,
            set = function()
                self.db.profile[frameConfigName]["ShowIcon"] = not self.db.profile[frameConfigName]["ShowIcon"];
                self:FrameLayoutRestoreAll();
            end,
        }
    end
    if (frameConfigName ~= "MirrorTimer") then
        options.args.iconalign =
        {
            name = "Icon Alignment",
            type = "select",
            order = 3,
            desc = "Set the alignment of the icon",
            values = {LEFT = "Left", RIGHT = "Right"},
            get = function() return self.db.profile[frameConfigName]["IconAlignment"] end,
            set = function(info, value)
                self.db.profile[frameConfigName]["IconAlignment"] = value;
                self:FrameLayoutRestoreAll();
            end,
        }
    end
    if (frameConfigName == "TargetCastingBarFrame" or frameConfigName == "FocusCastingBarFrame") then
        options.args.showshield =
        {
            name = "Show Shield",
            type = "toggle",
            order = 4,
            desc = "Toggles display of the shield around the bar when the spell cannot be interrupted.",
            get = function() return self.db.profile[frameConfigName]["ShowShield"] end,
            set = function()
                self.db.profile[frameConfigName]["ShowShield"] = not self.db.profile[frameConfigName]["ShowShield"];
                self:FrameLayoutRestoreAll();
            end,
        }
    end
    if (frameConfigName == "CastingBarFrame") then
        options.args.showlatency =
        {
            name = "Show Latency",
            type = "toggle",
            order = 5,
            desc = "Toggles display of the combined queue zone and latency indicator, which shows the queue zone and latency as a bar at the end of the Castbar, making it easier to time chain casting of spells.",
            get = function() return self.db.profile[frameConfigName]["ShowLatency"] end,
            set = function()
                self.db.profile[frameConfigName]["ShowLatency"] = not self.db.profile[frameConfigName]["ShowLatency"];
                self:FrameLayoutRestoreAll();
            end,
        }
    end
    if (frameConfigName ~= "MirrorTimer") then
        options.args.showspellname =
        {
            name = "Show Spell Name",
            type = "toggle",
            order = 6,
            desc = "Toggles display of the name of the spell being cast.",
            get = function() return self.db.profile[frameConfigName]["ShowSpellName"] end,
            set = function()
                self.db.profile[frameConfigName]["ShowSpellName"] = not self.db.profile[frameConfigName]["ShowSpellName"];
                self:FrameLayoutRestoreAll();
            end,
        }
    end
    if (frameConfigName == "CastingBarFrame") then
        options.args.showspelltarget =
        {
            name = "Show Spell Target",
            type = "toggle",
            order = 7,
            desc = "Toggles display of the target of the spell being cast.",
            get = function() return self.db.profile[frameConfigName]["ShowSpellTarget"] end,
            set = function()
                self.db.profile[frameConfigName]["ShowSpellTarget"] = not self.db.profile[frameConfigName]["ShowSpellTarget"];
                self:FrameLayoutRestoreAll();
            end,
        }
    end
    if (frameConfigName ~= "MirrorTimer") then
        options.args.showtotalcasttime =
        {
            name = "Show Total Cast Time",
            type = "toggle",
            order = 8,
            desc = "Toggles display of the total cast time.",
            get = function() return self.db.profile[frameConfigName]["ShowTotalCastTime"] end,
            set = function()
                self.db.profile[frameConfigName]["ShowTotalCastTime"] = not self.db.profile[frameConfigName]["ShowTotalCastTime"];
                self:FrameLayoutRestoreAll();
            end,
        }
    end
    if (frameConfigName ~= "MirrorTimer") then
        options.args.totalcasttimedecimals =
        {
            name = "Total Cast Time Decimals",
            type = "range",
            order = 9,
            desc = "Set the number of decimal places for the total cast time.",
            min = 0,
            max = 3,
            step = 1,
            get = function() return self.db.profile[frameConfigName]["TotalCastTimeDecimals"] end,
            set = function(info, value)
                self.db.profile[frameConfigName]["TotalCastTimeDecimals"] = value;
                self:FrameLayoutRestoreAll();
            end,
        }
    end
    if (frameConfigName == "CastingBarFrame") then
        options.args.showpushback =
        {
            name = "Show Pushback",
            type = "toggle",
            order = 10,
            desc = "Toggles display of the pushback time when spell casting is delayed.",
            get = function() return self.db.profile[frameConfigName]["ShowPushback"] end,
            set = function()
                self.db.profile[frameConfigName]["ShowPushback"] = not self.db.profile[frameConfigName]["ShowPushback"];
                self:FrameLayoutRestoreAll();
            end,
        }
    end
    if (frameConfigName == "CastingBarFrame") then
        options.args.showspark =
        {
            name = "Show Global Cooldown Spark",
            type = "toggle",
            order = 11,
            desc = "Toggles display of the global cooldown spark.",
            get = function() return self.db.profile[frameConfigName]["ShowCooldownSpark"] end,
            set = function()
                self.db.profile[frameConfigName]["ShowCooldownSpark"] = not self.db.profile[frameConfigName]["ShowCooldownSpark"];
            end,
        }
    end
    if (frameConfigName == "CastingBarFrame") then
        options.args.showswingtimer =
        {
            name = "Show Swing Timer",
            type = "toggle",
            order = 12,
            desc = "Toggles display of the swing timer.",
            get = function() return self.db.profile[frameConfigName]["ShowSwingTimer"] end,
            set = function()
                self.db.profile[frameConfigName]["ShowSwingTimer"] = not self.db.profile[frameConfigName]["ShowSwingTimer"];
                self:FrameLayoutRestoreAll();
            end,
        }
    end
    if (frameConfigName ~= "MirrorTimer") then
        options.args.colorchanneling =
        {
            name = "Channeling Bar Color",
            type = "color",
            order = 104,
            desc = "Set color of the " .. friendlyName .. " bar when channeling",
            get = function(info)
                return unpack(self.db.profile[frameConfigName]["BarColorChanneling"]);
            end,
            set = function(info, r, g, b)
                self.db.profile[frameConfigName]["BarColorChanneling"] = {r, g, b};
            end,
        }
    end
    if (frameConfigName == "TargetCastingBarFrame" or frameConfigName == "FocusCastingBarFrame") then
        options.args.colorshielded =
        {
            name = "Shielded Bar Color",
            type = "color",
            order = 105,
            desc = "Set color of the " .. friendlyName .. " bar when cast cannot be interrupted",
            get = function(info)
                return unpack(self.db.profile[frameConfigName]["BarColorShielded"]);
            end,
            set = function(info, r, g, b)
                self.db.profile[frameConfigName]["BarColorShielded"] = {r, g, b};
            end,
        }
    end
    if (frameConfigName == "CastingBarFrame") then
        options.args.coloroutofrange =
        {
            name = "Out-of-range Bar Color",
            type = "color",
            order = 106,
            desc = "Set color of the " .. friendlyName .. " bar when target is out of range",
            get = function(info)
                return unpack(self.db.profile[frameConfigName]["BarColorOutOfRange"]);
            end,
            set = function(info, r, g, b)
                self.db.profile[frameConfigName]["BarColorOutOfRange"] = {r, g, b};
            end,
        }
    end
    if (frameConfigName ~= "MirrorTimer") then
        options.args.textalign =
        {
            name = "Text Alignment",
            type = "select",
            order = 203,
            desc = "Set the alignment of the Castbar text",
            values = {LEFT = "Left", CENTER = "Center"},
            get = function() return self.db.profile[frameConfigName]["TextAlignment"] end,
            set = function(info, value)
                self.db.profile[frameConfigName]["TextAlignment"] = value;
                self:FrameLayoutRestoreAll();
            end,
        }
    end
    return options;
end

function Castbars:GetOptionsTable()
    local options =
    {
        type = "group",
        args =
        {
            general =
            {
                type = "group",
                name = "General Settings",
                childGroups = "tab",
                args =
                {
                    toggleconfigmode =
                    {
                        name = "Configuration Mode",
                        type = "toggle",
                        order = 1,
                        desc = "Toggle configuration mode to allow moving bars and setting appearance options",
                        get = function() return self.ConfigMode end,
                        set = function() self:Toggle() end,
                    },
                    player = self:GetOptionsTableForBar("CastingBarFrame", "Player/Vehicle", 2),
                    pet = self:GetOptionsTableForBar("PetCastingBarFrame", "Pet", 3),
                    target = self:GetOptionsTableForBar("TargetCastingBarFrame", "Target", 4),
                    focus = self:GetOptionsTableForBar("FocusCastingBarFrame", "Focus", 5),
                    mirror = self:GetOptionsTableForBar("MirrorTimer", "Mirror Timers", 6),
                },
            },
            profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db),
        },
    };
    return options;
end

function Castbars:UnitFullName(unit)
    local name, realm = UnitName(unit);
    if (realm and realm ~= "") then
        return name .. "-" .. realm;
    else
        return name;
    end
end

function Castbars:NameToUnitID(targetName)
    return UnitExists(targetName) and targetName or (targetName == self:UnitFullName("target") and "target") or (targetName == self:UnitFullName("focus") and "focus") or (targetName == self:UnitFullName("targettarget") and "targettarget") or (targetName == self:UnitFullName("focustarget") and "focustarget") or nil;
end

function Castbars:ChatCommand(cmd)
    if (cmd ~= "") then
        if (string.match(cmd, "^blacklist$", 1)) then
            for i,v in pairs(self.db.profile.CastingBarFrame.Blacklist) do
                print(i);
            end
        end
        local spell = string.match(cmd, "blacklist (.+)", 1);
        if (spell) then
            if (self.db.profile.CastingBarFrame.Blacklist[spell]) then
                self.db.profile.CastingBarFrame.Blacklist[spell] = nil;
                print("Removed " .. spell .. " from blacklist");
            else
                self.db.profile.CastingBarFrame.Blacklist[spell] = true;
                print("Added " .. spell .. " to blacklist");
            end
        end
    else
        InterfaceOptionsFrame_OpenToCategory("Castbars");
    end
end

function Castbars:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("CastbarsDB",
    {
        profile =
        {
            ["**"] =
            {
                Width = 205,
                Height = 13,
                Alpha = 1.0,
                Texture = "Castbars",
                BarColor = {0.3, 0.3, 0.8},
                BarColorChanneling = {0.4, 0.2, 0.8},
                BarColorShielded = {0.6, 0.6, 0.6},
                BarColorOutOfRange = {0.6, 0.6, 0.6},
                Border = "Blizzard Tooltip",
                BorderColor = {0.0, 0.0, 0.0, 0.8},
                BorderWidthAdjustment = 0,
                BorderOffsetAdjustment = 0,
                Font = "Friz Quadrata TT",
                FontSize = 10,
                FontOutline = true,
                TextAlignment = "CENTER",
                Position = nil,
                ShowSpellName = true,
            },
            CastingBarFrame =
            {
                Show = true,
                ShowLatency = true,
                ShowIcon = true,
                IconAlignment = "LEFT",
                ShowSpellTarget = true,
                ShowTotalCastTime = true,
                TotalCastTimeDecimals = 1,
                ShowPushback = true,
                ShowCooldownSpark = true,
                Width = 250,
                Height = 24,
                Position = {point = "CENTER", relpoint = "CENTER", x = 0, y = -245},
                Blacklist = {},
            },
            PetCastingBarFrame =
            {
                Show = true,
                ShowIcon = true,
                IconAlignment = "LEFT",
                ShowTotalCastTime = false,
                TotalCastTimeDecimals = 1,
                Width = 150,
                Height = 12,
                FontSize = 9,
                Border = "None",
                Position = {point = "CENTER", relpoint = "CENTER", x = 0, y = -275},
            },
            TargetCastingBarFrame =
            {
                Show = true,
                ShowIcon = true,
                IconAlignment = "LEFT",
                ShowTotalCastTime = false,
                TotalCastTimeDecimals = 1,
                ShowShield = true,
                Height = 12,
                Border = "None",
                Position = {point = "CENTER", relpoint = "CENTER", x = 0, y = 180},
            },
            FocusCastingBarFrame =
            {
                Show = false,
                ShowIcon = true,
                IconAlignment = "LEFT",
                ShowTotalCastTime = false,
                TotalCastTimeDecimals = 1,
                ShowShield = true,
                Height = 12,
                Border = "None",
                Position = {point = "CENTER", relpoint = "CENTER", x = 0, y = 220},
            },
            MirrorTimer =
            {
                Position = {point = "TOP", relpoint = "TOP", x = 0, y = -130},
            },
        }
    });
    self.db.RegisterCallback(self, "OnProfileChanged", "FrameLayoutRestoreAll");
    self.db.RegisterCallback(self, "OnProfileCopied", "FrameLayoutRestoreAll");
    self.db.RegisterCallback(self, "OnProfileReset", "FrameLayoutRestoreAll");

    self.options = self:GetOptionsTable();
    LibStub('LibDualSpec-1.0'):EnhanceDatabase(self.db, "Castbars")
    LibStub('LibDualSpec-1.0'):EnhanceOptions(self.options.args.profile, self.db)
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Castbars", self.options);
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Castbars", nil, nil, "general");
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Castbars", "Profiles", "Castbars", "profile");
    self:RegisterChatCommand("cb", "ChatCommand");
    self:RegisterChatCommand("castbars", "ChatCommand");

    self.playerClass = select(2, UnitClass("player"));

    -- Prevent the UIParent from moving the CastingBarFrame around
    UIPARENT_MANAGED_FRAME_POSITIONS["CastingBarFrame"] = nil;

    -- Reset player and pet casting bars in case another addon have 
    -- messed with them before this addons loads
    CastingBarFrame_OnLoad(CastingBarFrame, "player", true, false);
    PetCastingBarFrame_OnLoad(PetCastingBarFrame);

    -- Create target casting bar
    CreateFrame("StatusBar", "TargetCastingBarFrame", UIParent, "CastingBarFrameTemplate");
    TargetCastingBarFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
    CastingBarFrame_OnLoad(TargetCastingBarFrame, "target", false, true);

    -- Create focus casting bar
    CreateFrame("StatusBar", "FocusCastingBarFrame", UIParent, "CastingBarFrameTemplate");
    FocusCastingBarFrame:RegisterEvent("PLAYER_FOCUS_CHANGED");
    CastingBarFrame_OnLoad(FocusCastingBarFrame, "focus", false, true);

    -- Register additional events on CastingBarFrame
    CastingBarFrame:RegisterEvent("UNIT_SPELLCAST_SENT");
    CastingBarFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");

    -- Setup table with all frames
    self.frames = {CastingBarFrame, PetCastingBarFrame, TargetCastingBarFrame, FocusCastingBarFrame, MirrorTimer1, MirrorTimer2, MirrorTimer3};

    -- Customize the bars
    self:FrameCustomizeAll();

    -- Restore layout of all frames
    local loginRestoreOnce;
    if (IsLoggedIn()) then
        self:FrameLayoutRestoreAll();
        loginRestoreOnce = true;
    end

    -- Register Texture and Listen to LibSharedMedia-3.0 callbacks
    self.SharedMedia:Register("statusbar", "Castbars", [[Interface\AddOns\Castbars\Castbars]])
    self.SharedMedia.RegisterCallback(self, "LibSharedMedia_Registered", "FrameMediaRestoreAll")
    self.SharedMedia.RegisterCallback(self, "LibSharedMedia_SetGlobal", "FrameMediaRestoreAll")

    self.CastingBarFrame_OnUpdate = function(frame, elapsed, ...)
        CastingBarFrame_OnUpdate(frame, elapsed, ...);
        if (frame:IsVisible()) then
            if (frame.outOfRange ~= nil) then
                local outOfRange = frame.outOfRange;
                frame.outOfRange = frame.spellName and frame.spellTarget and (IsSpellInRange(frame.spellName, frame.spellTarget) == 0) and true or false;
                if (outOfRange ~= frame.outOfRange) then
                    self:FrameColorRestore(frame);
                end
            end
            if (frame.nextupdate < elapsed) then
                self:FrameTimerRestore(frame);
                frame.nextupdate = 0.1;
            else
                frame.nextupdate = frame.nextupdate - elapsed;
            end
        end
    end

    -- Hook MirrorTimer_Show
    local orgMirrorTimer_Show = MirrorTimer_Show;
    MirrorTimer_Show = function(timer, value, maxvalue, ...)
        local frame = orgMirrorTimer_Show(timer, value, maxvalue, ...);
        if (frame) then
            frame.expirationTime = nil;
            frame.duration = maxvalue / 1000;
        end
        return frame;
    end

    self.MirrorTimerFrame_OnUpdate = function(frame, elapsed, ...)
        MirrorTimerFrame_OnUpdate(frame, elapsed, ...);
        if (frame:IsVisible()) then
            if (frame.nextupdate < elapsed) then
                self:FrameTimerRestore(frame);
                frame.nextupdate = 0.1;
            else
                frame.nextupdate = frame.nextupdate - elapsed;
            end
        end
    end

    self.CastingBarFrame_OnEvent = function(frame, event, ...)
        if (self.ConfigMode) then return end
        frame.Show = nil; -- Protect against addons that override the Show method
        if (event == "UNIT_SPELLCAST_SENT") then
            local unit, spellName, _, targetName, id = ...;
            if (unit == "player") then
                frame.sentTime = GetTime();
                frame.sentTargetName = targetName;
                frame.sentId = id;
                frame.sentSpellName = spellName;
            end
            return;
        elseif (event == "ACTIONBAR_UPDATE_COOLDOWN") then
            local startTime, duration = GetSpellCooldown(52127); -- Water Shield - works for all classes
            if (self.db.profile[frame.configName]["ShowCooldownSpark"]) then
                frame.gcd:SetFrameLevel(frame.backdrop:GetFrameLevel() + 1);
                if (duration and (duration > 0)) then
                    frame.gcd.a = frame.gcd:GetWidth() / duration;
                    frame.gcd.b = (startTime * frame.gcd:GetWidth()) / duration;
                    frame.gcd:Show();
                else
                    frame.gcd:Hide();
                end
            end
            return;
        elseif (event == "PLAYER_ENTERING_WORLD") then
            if (not loginRestoreOnce) then
                self:FrameLayoutRestoreAll();
                loginRestoreOnce = true;
            end
        elseif (event == "PLAYER_TARGET_CHANGED") then
            CastingBarFrame_OnEvent(frame, "PLAYER_ENTERING_WORLD", ...);
            if (frame.unit == "target") then
                self:FrameDynamicRestore(frame, unit);
            end
            return;
        elseif (event == "PLAYER_FOCUS_CHANGED") then
            CastingBarFrame_OnEvent(frame, "PLAYER_ENTERING_WORLD", ...);
            if (frame.unit == "focus") then
                self:FrameDynamicRestore(frame, unit);
            end
            return;
        elseif ((event == "UNIT_PET") and (... == "player")) then
            frame.configName = UnitIsPossessed("pet") and "CastingBarFrame" or "PetCastingBarFrame";
            self:FrameLayoutRestore(frame);
            return;
        end
        CastingBarFrame_OnEvent(frame, event, ...);
        if ((event == "UNIT_SPELLCAST_START") or (event == "UNIT_SPELLCAST_CHANNEL_START")) then
            local unit, spellName, _, id, spellId = ...;
            if (unit == frame.unit) then
                if (self.db.profile.CastingBarFrame.Blacklist[spellName] or self.db.profile.CastingBarFrame.Blacklist[spellId]) then frame:Hide() end
                if (frame.configName) then frame:SetAlpha(self.db.profile[frame.configName]["Alpha"]) end
                if (unit == "player") then
                    frame.spellInSpellBook = self:IsSpellBookSpell(spellId);
                    if (id == frame.sentId or (event == "UNIT_SPELLCAST_CHANNEL_START") and (spellName == frame.sentSpellName)) then
                        frame.spellTargetName = frame.sentTargetName;
                    else
                        frame.spellTargetName = nil;
                    end
                    frame.spellTarget = self:NameToUnitID(frame.spellTargetName);
                    frame.spellName = spellName;
                    frame.spellInitialDelay = frame.sentTime and GetTime() - frame.sentTime;
                    frame.outOfRange = false;
                    frame.gcd.border:SetTexture(0, 0, 0, 0);
                    if (frame.channeling) then
                        self:CastingBarFrameTicksSet(frame);
                    end
                    if (frame.casting) then
                        frame.startTime = GetTime() - (frame.value or 0);
                        frame.delayTime = nil;
                        local repeatCount = GetTradeskillRepeatCount();
                        if (not frame.mergingTradeSkill and repeatCount > 1) then
                            frame.mergingTradeSkill = true;
                            frame.countCurrent = 0;
                            frame.countTotal = repeatCount;
                        end
                        if (frame.mergingTradeSkill) then
                            frame.value = frame.value + frame.maxValue * frame.countCurrent;
                            frame.maxValue = frame.maxValue * frame.countTotal;
                            frame.maxValueMerge = frame.maxValue;
                            frame:SetMinMaxValues(0, frame.maxValue);
                            frame:SetValue(frame.value);
                            frame.countCurrent = frame.countCurrent + 1;
                        end
                    end
                end
                self:FrameDynamicRestore(frame, unit, true);
            end
        elseif ((event == "UNIT_SPELLCAST_STOP") or (event == "UNIT_SPELLCAST_CHANNEL_STOP")) then
            if ((... == "player") and (frame.unit == "player")) then
                frame.sentTime = nil;
                if (not frame.casting and not frame.channeling) then
                    frame.outOfRange = nil;
                    frame.latency:Hide();
                    frame.queuezone:Hide();
                    self:CastingBarFrameTicksSet();
                end
                if (frame.mergingTradeSkill) then
                    if (frame.countCurrent == frame.countTotal) then
                        frame.mergingTradeSkill = nil;
                    else
                        frame.value = frame.maxValue * frame.countCurrent / frame.countTotal;
                        frame:SetValue(frame.value);
                        frame:SetStatusBarColor(unpack(self.db.profile[frame.configName]["BarColor"]))
                        frame.holdTime = GetTime() + 1;
                        local sparkPosition = (frame.value / frame.maxValue) * frame:GetWidth();
                        frame.spark:SetPoint("CENTER", frame, "LEFT", sparkPosition, 2);
                        frame.spark:Show();
                    end
                end
            end
        elseif (event == "UNIT_SPELLCAST_CHANNEL_UPDATE") then
            if ((... == "player") and (frame.unit == "player")) then
                self:FrameTimerRestore(frame, true);
                self:CastingBarFrameTicksSet(frame)
            end
        elseif (event == "UNIT_SPELLCAST_DELAYED") then
            if ((... == "player") and (frame.unit == "player") and frame.casting) then
                frame.delayTime = (GetTime() - (frame.value or 0)) - (frame.startTime or 0);
                self:FrameTimerRestore(frame, true);
            end
        elseif ((event == "UNIT_SPELLCAST_FAILED") or (event == "UNIT_SPELLCAST_INTERRUPTED")) then
            if ((... == "player") and (frame.unit == "player")) then
                frame.mergingTradeSkill = nil;
            end
        elseif ((event == "UNIT_SPELLCAST_INTERRUPTIBLE") or (event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE")) then
            if (... == frame.unit) then
                self:FrameIconRestore(frame);
            end
        end
    end

    -- Replace the OnEvent handler
    CastingBarFrame:SetScript("OnEvent", self.CastingBarFrame_OnEvent);
    PetCastingBarFrame:SetScript("OnEvent", self.CastingBarFrame_OnEvent);
    TargetCastingBarFrame:SetScript("OnEvent", self.CastingBarFrame_OnEvent);
    FocusCastingBarFrame:SetScript("OnEvent", self.CastingBarFrame_OnEvent);

    -- Replace the OnUpdate handler
    CastingBarFrame:SetScript("OnUpdate", self.CastingBarFrame_OnUpdate);
    PetCastingBarFrame:SetScript("OnUpdate", self.CastingBarFrame_OnUpdate);
    TargetCastingBarFrame:SetScript("OnUpdate", self.CastingBarFrame_OnUpdate);
    FocusCastingBarFrame:SetScript("OnUpdate", self.CastingBarFrame_OnUpdate);
    MirrorTimer1:SetScript("OnUpdate", self.MirrorTimerFrame_OnUpdate);
    MirrorTimer2:SetScript("OnUpdate", self.MirrorTimerFrame_OnUpdate);
    MirrorTimer3:SetScript("OnUpdate", self.MirrorTimerFrame_OnUpdate);

    self.GetOptionsTableForBar = nil;
    self.GetOptionsTable = nil;
    self.FrameCustomize = nil;
    self.FrameCustomizeAll = nil;
    self.OnInitialize = nil;
end

--[[ ConfigMode Support ]]--

Castbars.MirrorTimerFrame_OnEvent = MirrorTimerFrame_OnEvent;
Castbars.MirrorTimer_Show = MirrorTimer_Show;

function Castbars:Show()
    if (not self.ConfigMode) then
        self.ConfigMode = true;

        -- Prevent event handling
        MirrorTimerFrame_OnEvent = self.DoNothing
        MirrorTimer_Show = self.DoNothing;

        -- Make the Pet Castbar appear as a Pet Castbar even if in a vehicle while configuring.
        PetCastingBarFrame.configName = "PetCastingBarFrame";
        self:FrameLayoutRestore(PetCastingBarFrame);

        -- Condition and show all bars
        for i, frame in pairs(self.frames) do
            frame:EnableMouse(true);
            frame.text:SetText(frame.friendlyName);
            frame.statusBar:SetStatusBarColor(unpack(self.db.profile[frame.configName]["BarColor"]));
            frame.statusBar:SetAlpha(self.db.profile[frame.configName]["Alpha"]);
            frame.statusBar:SetValue(select(2, frame.statusBar:GetMinMaxValues()));
            if (frame.spark) then
                frame.spark:Hide();
            end
            if (frame.shield) then
                frame.shield:Hide();
                frame.shieldborder:Show(); -- Show means Hide (the functions are swapped)
            end
            frame.fadeOut = nil;
            frame.paused = 1;
            if (frame.icon) then frame.icon:SetTexture("Interface\\Icons\\Spell_Arcane_MassDispel") end
            self:FrameTimerRestore(frame, true);
            self:FrameIconRestore(frame);
            frame:Show();
        end
    end
end

function Castbars:Hide()
    if (self.ConfigMode) then
        for i, frame in pairs(self.frames) do
            frame:EnableMouse(false);
            frame:Hide();
        end

        -- Restore the config name of the Pet Castbar
        PetCastingBarFrame.configName = UnitIsPossessed("pet") and "CastingBarFrame" or "PetCastingBarFrame";
        self:FrameLayoutRestore(PetCastingBarFrame);

        -- Restore event handling
        MirrorTimerFrame_OnEvent = self.MirrorTimerFrame_OnEvent;
        MirrorTimer_Show = self.MirrorTimer_Show;
        self.ConfigMode = false;
    end
end

function Castbars:Toggle()
    if (self.ConfigMode) then
        self:Hide();
    else
        self:Show();
    end
end

CONFIGMODE_CALLBACKS = CONFIGMODE_CALLBACKS or {};
CONFIGMODE_CALLBACKS["Castbars"] = function(action)
    if (action == "ON") then Castbars:Show()
    elseif (action == "OFF") then Castbars:Hide() end
end
