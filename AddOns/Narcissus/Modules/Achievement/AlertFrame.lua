local pow = math.pow;
local max = math.max;
local ceil = math.ceil;
local After = C_Timer.After;
local CreateAnimationFrame = NarciAPI_CreateAnimationFrame;

local function outQuart(t, b, e, d)
    t = t / d - 1;
    return (b - e) * (pow(t, 4) - 1) + b
end

local function SetSmallFont(object)
    local path, height = GameFontBlackTiny:GetFont();
    object:SetFont(path, 9);
end

------------------------------------------------------
local function AchievementAlertFrame_SetUp(frame, achievementID, alreadyEarned)
    local _, name, points, completed, month, day, year, description, flags, icon, rewardText, isGuildAch, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementID);
    frame.id = achievementID;

    if ( points < 100 ) then
        frame.points:SetFontObject(GameFontNormal);
    else
        frame.points:SetFontObject(GameFontNormalSmall);
    end
    frame.points:SetText(points);

    if ( points == 0 ) then
        frame.points:Hide();
        frame.shield:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields-NoPoints]]);
    else
        frame.points:Show();
        frame.shield:SetTexture([[Interface\AchievementFrame\UI-Achievement-Shields]]);
    end

    frame.name:SetText(name);
    frame.nameLong:SetText(name);
    local isLongName = frame.name:IsTruncated();
    frame.name:SetShown(not isLongName);
    frame.nameLong:SetShown(isLongName);

    frame.icon:SetTexture(icon);

    local offsetY;
    
    if isGuildAch then
        if not frame.guildDisplay then
            frame.guildDisplay = true;
            frame:SetHeight(98);
            frame.background:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\Classic\\AlertFrameGuildBackground");
            frame.background:SetTexCoord(0, 1, 0.1875, 0.8125);
            frame.mask:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\Classic\\AlertFrameGuildMask");
            frame.mask:SetHeight(156);
            frame.unlockedText:SetText( string.upper(GUILD_ACHIEVEMENT_UNLOCKED) );
            frame.points:SetVertexColor(0, 1, 0);
            frame.shield:SetTexCoord(0, 0.5, 0.5, 1);
            frame.shield:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -16, 14);
            frame.guildName:Show();
            frame.GuildBorder:Show();
            frame.GuildBanner:Show();
            frame.icon:SetSize(45, 45);
            frame.glow:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\Classic\\AlertFrameGuildGlow");
            frame.shine:SetSize(98, 98);
            frame.shine:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\Classic\\AlertFrameGuildShine");
            frame.shineMask:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\Classic\\AlertFrameGuildShineMask");
            offsetY = 3;
        end
        frame.guildName:SetText( GetGuildInfo("player") );
        SetSmallGuildTabardTextures("player", nil, frame.GuildBanner, frame.GuildBorder);
        frame.points:SetPoint("CENTER", frame.shield, "CENTER", -1, 3);
    else
        if frame.guildDisplay then
            frame.guildDisplay = nil;
            frame:SetHeight(78);
            frame.background:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\Classic\\AlertFrameBackground");
            frame.mask:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\Classic\\AlertFrameMask");
            frame.mask:SetHeight(78);
            --frame.unlockedText:SetText( string.upper(ACHIEVEMENT_UNLOCKED) );
            frame.points:SetVertexColor(1, 0.82, 0);
            frame.shield:SetTexCoord(0, 0.5, 0, 0.45);
            frame.shield:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -14, 14);
            frame.guildName:Hide();
            frame.GuildBorder:Hide();
            frame.GuildBanner:Hide();
            frame.icon:SetSize(52, 52);
            frame.glow:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\Classic\\AlertFrameGlow");
            frame.shine:SetSize(78, 78);
            frame.shine:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\Classic\\AlertFrameShine");
            frame.shineMask:SetTexture("Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\Classic\\AlertFrameShineMask");
            offsetY = 0;
        end
        if flags == 131072 then
            frame.background:SetTexCoord(0, 1, 0.5, 1);
        else
            frame.background:SetTexCoord(0, 1, 0, 0.5);
        end
        frame.unlockedText:SetText( string.upper(ACHIEVEMENT_UNLOCKED) );
        frame.points:SetPoint("CENTER", frame.shield, "CENTER", -1, 0);
    end

    SetSmallFont(frame.unlockedText);

    return true
end

local function CriteriaAlertFrame_SetUp(frame, achievementID, criteriaString)
    frame.id = achievementID;
    frame.name:SetText(criteriaString);
    frame.unlockedText:SetText( string.upper(ACHIEVEMENT_PROGRESSED) );
    SetSmallFont(frame.unlockedText);
end

local EventListener = CreateFrame("Frame");
EventListener:RegisterEvent("PLAYER_ENTERING_WORLD");
EventListener:RegisterEvent("ACHIEVEMENT_EARNED");
EventListener:RegisterEvent("CRITERIA_EARNED");
--EventListener:RegisterEvent("ADDON_LOADED");
EventListener:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
        NarciAchievementAlertSystem:Enable();
    elseif event == "ACHIEVEMENT_EARNED" then
        NarciAchievementAlertSystem:AddAlert(...);
    elseif event == "CRITERIA_EARNED" then
        NarciCriteriaAlertSystem:AddAlert(...);
    end
end)
------------------------------------------------------------------------------------------------------
--Public:

NarciCriteriaAlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("NarciCriteriaAlertFrameTemplate", CriteriaAlertFrame_SetUp, 2, 0);
NarciAchievementAlertSystem = AlertFrame:AddQueuedAlertFrameSubSystem("NarciAchievementAlertFrameTemplate", AchievementAlertFrame_SetUp, 2, 6);

function NarciAchievementAlertSystem:Enable()
    EventListener:RegisterEvent("ACHIEVEMENT_EARNED");
    EventListener:RegisterEvent("CRITERIA_EARNED");
    if AlertFrame then
        AlertFrame:UnregisterEvent("ACHIEVEMENT_EARNED");
        AlertFrame:UnregisterEvent("CRITERIA_EARNED");
    end
end

function NarciAchievementAlertSystem:Disable()
    EventListener:UnregisterEvent("ACHIEVEMENT_EARNED");
    EventListener:UnregisterEvent("CRITERIA_EARNED");
    if AlertFrame then
        AlertFrame:RegisterEvent("ACHIEVEMENT_EARNED");
        AlertFrame:RegisterEvent("CRITERIA_EARNED");
    end
end


function NarciAchievementAlertFrame_OnClick(self, button, down)
    if( AlertFrame_OnClick(self, button, down) ) then
        return;
    end
    local id = self.id;
    if ( not id ) then
        return;
    end
    
    Narci_AchievementFrame:LocateAchievement(id);
end


------------------------------------------------------------------------------------------------------
--/run NarciAchievementAlertSystem:AddAlert(13699)
--/run NarciAchievementAlertSystem:AddAlert(5159)

------------------------------------------------------------------------------------------------------
--[[
    NarciAchievementAlertMixin = {};

    function NarciAchievementAlertMixin:OnHide()
        self:StopAnimating();
        self.highlightTop:SetAlpha(0);
        self.highlightCenter:SetAlpha(0);
        self.highlightBottom:SetAlpha(0);
        self:StopFading();
        self:SetAlpha(0);
        self:Hide();
        AchivementContainer:SetHeight( max(8, AchivementContainer:GetHeight() - self:GetHeight() - 12) );
        AlertSystem:ReleaseSlot(self);
        AlertSystem:ShowNextCard(self);
    end

    function NarciAchievementAlertMixin:OnEnter()
        self:StartFadeIn();
    end

    function NarciAchievementAlertMixin:OnLeave()
        self:StartFadeOut(true);
    end

    function NarciAchievementAlertMixin:ShowBing()
        self.highlightTop:SetAlpha(1);
        self.highlightCenter:SetAlpha(1);
        self.highlightBottom:SetAlpha(1);
        self.star1.move:Play();
        self.star1.blink:Play();
        self.star2.move:Play();
        self.star2.blink:Play();
    end

    function NarciAchievementAlertMixin:PlayBling()
        self.highlightTop.fade:Play();
        self.highlightCenter.fade:Play();
        self.highlightBottom.fade:Play();
    end

    function NarciAchievementAlertMixin:OnLoad()
        local reference = CreateFrame("Frame", nil, UIParent);
        reference:SetSize(8, 8);
        self.reference = reference;

        --
        local scaleIn = CreateAnimationFrame(0.7);    
        scaleIn:SetScript("OnUpdate", function(frame, elapsed)
            frame.total = frame.total + elapsed;
            local alpha = outQuart(frame.total, 0, 1, 0.25);
            local scale = outQuart(frame.total, 0.2, 1, 0.25);

            if frame.total >= 0.25 then
                if not frame.hasPlayed then
                    frame.hasPlayed = true;
                    self:PlayBling();
                end

                local textAlpha = outQuart(frame.total - 0.25, 0, 1, 0.5);
                if frame.total >= frame.duration then
                    textAlpha = 1;
                    frame:Hide();
                    self.isPlaying = nil;
                end
                alpha = 1;
                scale = 1;
                self.points:SetAlpha(textAlpha);
                self.lion:SetAlpha(textAlpha);
                self.header:SetAlpha(textAlpha);
                self.description:SetAlpha(textAlpha);
                self.date:SetAlpha(textAlpha);
                self.RewardFrame:SetAlpha(textAlpha);
            end
            
            self.background:SetAlpha(alpha);
            self:SetScale(scale);
            self:SetAlpha(alpha);
        end)
        
        function self:PlayScale()
            scaleIn:Hide();

            self:StopAnimating();
            self.points:SetAlpha(0);
            self.lion:SetAlpha(0);
            self.header:SetAlpha(0);
            self.description:SetAlpha(0);
            self.date:SetAlpha(0);
            self.RewardFrame:SetAlpha(0);
            self:ShowBing();
            scaleIn.fromAlpha = 0;
            scaleIn.hasPlayed = false;
            scaleIn:Show();
        end

        --
        local animFadeIn = CreateAnimationFrame(0.2);
        animFadeIn.fromAlpha = 0;
        animFadeIn:SetScript("OnUpdate", function(frame, elapsed)
            frame.total = frame.total + elapsed;
            local alpha = frame.fromAlpha + frame.total / 0.2;
            if alpha >= 1 then
                alpha = 1;
                frame:Hide();
                if not self:IsMouseOver() then
                    self:StartFadeOut(true);
                end
            end
            self:SetAlpha(alpha);
        end)

        local animFadeOut = CreateAnimationFrame(4.5);
        animFadeOut.startDelay = 4;
        animFadeOut:SetScript("OnUpdate", function(frame, elapsed)
            frame.total = frame.total + elapsed;
            if frame.total >= frame.startDelay then
                local alpha = 1 - (frame.total - frame.startDelay)/1.5;
                if alpha <= 0 or frame.total >= (frame.startDelay + 1.5) then
                    alpha = 0;
                    frame:Hide();
                    self:Hide();
                end
                self:SetAlpha(alpha);
            end
        end)

        function self:StartFadeOut(isOnLeave)
            if self.isPlaying or (self.highlightBottom.fade:IsPlaying()) or animFadeIn:IsShown() then
                return
            end

            animFadeOut:Hide();
            if isOnLeave then
                animFadeOut.startDelay = 0.5;
            else
                local descriptionHeight = self.description:GetHeight();
                local numLines = ceil( descriptionHeight / 14 - 0.1 );
                if self.RewardFrame:IsShown() then
                    numLines = numLines + 1;
                end
                animFadeOut.startDelay = 3.5 + 1.2*numLines;
            end
            animFadeOut:Show();
        end

        function self:StartFadeIn()
            if (self.highlightBottom.fade:IsPlaying()) or (self:GetAlpha() == 0) then
                return
            end
            animFadeIn:Hide();
            animFadeOut:Hide();
            animFadeIn.fromAlpha = self:GetAlpha();
            animFadeIn:Show();
        end

        function self:StopFading()
            animFadeIn:Hide();
            animFadeOut:Hide();
        end
    end

    function NarciAchievementAlertMixin:OnClick(button)
        if button == "RightButton" then
            self:Hide();
            return
        end

        Narci_AchievementFrame:LocateAchievement(self.id);
    end

    function NarciAchievementAlertMixin:ConvertAnchor()
        local x, y = self:GetCenter();
        local y0;
        if ALERT_ANCHOR == "TOP" then
        y0 = AchivementContainer:GetTop();
        else
        y0 = AchivementContainer:GetBottom();
        end
        local uiScale = UIParent:GetEffectiveScale();
        local cardScale = self:GetEffectiveScale();
        local ratio = cardScale/uiScale;
        local reference = self.reference;

        reference:SetPoint("CENTER", AchivementContainer, ALERT_ANCHOR, 0, y - y0);
        self:ClearAllPoints();
        self:SetPoint("CENTER", reference, "CENTER", 0, 0);
    end

    function NarciAchievementAlertMixin:PlayEntranceVisual(playVFX)
        self:SetAlpha(0);
        self:Show();

        if playVFX then
            local actor = self.VFX.narciEffectActor;
            actor:Hide();

            if self.accountWide then
                actor.finalSequence = 0;
                actor:SetAnimation(0, 0, 0.95, 20);
            else
                actor.finalSequence = 5;
                actor:SetAnimation(0, 0, 0.15, 0);
            end

            actor:Show();

            After(0.7, function()
                self:PlayScale();
            end)
        else
            After(0.0, function()
                self:PlayScale();
            end)
        end

        self:StartFadeOut();
        self.isPlaying = true;
    end

    local CRITERIA_WIDTH_MIN = 136;

    NarciAchievementCriteriaNoteMixin = {};

    function NarciAchievementCriteriaNoteMixin:OnLoad()
        self:RegisterForDrag("LeftButton");

        --self.header:SetText( "|cff5fbd6b".. string.upper(ACHIEVEMENT_PROGRESSED) .."|r");
        self.header:SetText(string.upper(ACHIEVEMENT_PROGRESSED));

        local animCheck = CreateAnimationFrame(0.8);
        animCheck:SetScript("OnUpdate", function(frame, elapsed)
            frame.total = frame.total + elapsed;
            local total = frame.total;
            local scale = 1.25;
            local offset1 = outQuart(total, -16, -4, 0.5);

            if total >= 0.3 then
                scale = outQuart(total - 0.3, 1.25, 1, 0.5);
                if scale <= 1.02 then
                    scale = 1;
                end
                offset1 = -4;
                local offset2 = outQuart(total - 0.3, -22, 4, 0.5);
                if total >= frame.duration then
                    offset2 = 4;
                    frame:Hide();
                end
                self.checkRightMask:SetPoint("CENTER", self.left, "CENTER", offset2, offset2);
            end
            self.checkLeftMask:SetPoint("CENTER", self.left, "CENTER", offset1, -offset1);
            self.checkLeft:SetScale(scale);
            self.checkRight:SetScale(scale);
        end)

        function self:PlayCheckAnimation()
            animCheck:Hide();
            animCheck:Show();
        end

        function self:ResetCheck()
            animCheck:Hide();
            self.checkLeftMask:SetPoint("CENTER", self.left, "CENTER", -16, 16);
            self.checkRightMask:SetPoint("CENTER", self.left, "CENTER", -22, -22);
        end


        local animFadeIn = CreateAnimationFrame(0.2);
        animFadeIn.fromAlpha = 0;
        animFadeIn:SetScript("OnUpdate", function(frame, elapsed)
            frame.total = frame.total + elapsed;
            local alpha = frame.fromAlpha + frame.total / 0.2;
            if alpha >= 1 then
                alpha = 1;
                frame:Hide();

                if not self.hasPlayed then
                    self.hasPlayed = true;
                    self:PlayCheckAnimation();
                    self:StartFadeOut();
                else
                    if not self:IsMouseOver() then
                        self:StartFadeOut(true);
                    end
                end
            end
            self:SetAlpha(alpha);
        end)

        local animFadeOut = CreateAnimationFrame(4.5);
        animFadeOut.startDelay = 4;
        animFadeOut:SetScript("OnUpdate", function(frame, elapsed)
            frame.total = frame.total + elapsed;
            if frame.total >= frame.startDelay then
                local alpha = 1 - (frame.total - frame.startDelay)/1.5;
                if alpha <= 0 or frame.total >= (frame.startDelay + 1.5) then
                    alpha = 0;
                    frame:Hide();
                    self:Hide();
                end
                self:SetAlpha(alpha);
            end
        end)

        function self:StartFadeOut(isOnLeave)
            if animFadeIn:IsShown() then
                return
            end

            animFadeOut:Hide();
            if isOnLeave then
                animFadeOut.startDelay = 0.5;
            else
                animFadeOut.startDelay = 4.5
            end
            animFadeOut:Show();
        end

        function self:StartFadeIn()
            if animFadeIn:IsShown() then
                return
            end
            animFadeOut:Hide();
            animFadeIn.fromAlpha = self:GetAlpha();
            animFadeIn:Show();
        end

        self:UpdateTheme();
    end

    function NarciAchievementCriteriaNoteMixin:OnClick(button)
        if button == "RightButton" then
            self:Hide();
            return
        end

        Narci_AchievementFrame:LocateAchievement(self.id);
        self:ResetCheck();
        self:PlayCheckAnimation();
    end

    function NarciAchievementCriteriaNoteMixin:SetDescription(text)
        self.description:SetText(text);
        local textWidth = max(CRITERIA_WIDTH_MIN, self.description:GetWidth()) + 8;
        self.reference:SetWidth(textWidth);
        self:SetWidth(textWidth + 66);
    end

    function NarciAchievementCriteriaNoteMixin:OnMouseDown()

    end

    function NarciAchievementCriteriaNoteMixin:OnMouseUp()
        --self.animPushed.hold:SetDuration(0);
    end

    function NarciAchievementCriteriaNoteMixin:OnHide()
        self:StopAnimating();
        self:SetAlpha(0);
        self:Hide();
        AlertSystem:ReleaseSlot(self);
        CriteriaContainer:SetHeight( max(8, CriteriaContainer:GetHeight() - self:GetHeight() - 6) );
    end

    function NarciAchievementCriteriaNoteMixin:OnEnter()
        self:StartFadeIn();
    end

    function NarciAchievementCriteriaNoteMixin:OnLeave()
        self:StartFadeOut(true);
    end

    function NarciAchievementCriteriaNoteMixin:AutoDock()
        self:ClearAllPoints();
        local note;
        local hasDocked;

        local offsetY = AlertSystem:GetEmptySlot(self);
        if ALERT_ANCHOR == "TOP" then
            offsetY = -offsetY;
        end
        self:SetPoint(ALERT_ANCHOR, CriteriaContainer, ALERT_ANCHOR, 0, offsetY);

        CriteriaContainer:SetHeight(CriteriaContainer:GetHeight() + self:GetHeight() + 6);
    end

    function NarciAchievementCriteriaNoteMixin:PlayEntranceVisual()
        self:SetAlpha(0);
        self:Show();
        self:AutoDock();
        self:ResetCheck();
        self:StartFadeIn();
        self.hasPlayed = nil;
        PlaySound(38326, "SFX", true);    --SOUNDKIT.UI_DIG_SITE_COMPLETION_TOAST
    end

    function NarciAchievementCriteriaNoteMixin:UpdateTheme()
        local texturePrefix;
        local isBlackFont;
        local themeID = themeID;
        if themeID == 3 then
            isBlackFont = false;
            texturePrefix = "Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\Flat\\";
        elseif themeID == 2 then
            isBlackFont = true;
            texturePrefix = "Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\Classic\\";
        else
            isBlackFont = false;
            texturePrefix = "Interface\\AddOns\\Narcissus\\Art\\Modules\\Achievement\\DarkWood\\";
        end

        self.left:SetTexture(texturePrefix.."CriteriaBackground");
        self.center:SetTexture(texturePrefix.."CriteriaBackground");
        self.right:SetTexture(texturePrefix.."CriteriaBackground");
        self.checkLeft:SetTexture(texturePrefix.."CriteriaCheck");
        self.checkRight:SetTexture(texturePrefix.."CriteriaCheck");

        if isBlackFont then
            self.description:SetTextColor(0, 0, 0);
            self.description:SetShadowColor(1, 0.82, 0.408, 1);
            self.header:SetTextColor(0, 0, 0);
            self.header:SetShadowColor(1, 0.82, 0.408, 1);
        else
            self.description:SetTextColor(0.88, 0.88, 0.88);
            self.description:SetShadowColor(0, 0, 0);
            self.header:SetShadowColor(0, 0, 0);
            if themeID == 3 then
                self.header:SetTextColor(0.37, 0.74, 0.42);
            else
                self.header:SetTextColor(0.8, 0.7, 0.4);
            end
        end
    end

    function ShowCriteriaNote(achievementID, description)
        local note = AlertSystem:AcquireNote();
        note:SetDescription(description);
        note:ClearAllPoints();
        note:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 140);
        note:PlayEntranceVisual();
        note.id = achievementID;
    end

    function ShowAchievementAlert(achievementID)
        AlertSystem:AddAlert(achievementID);
    end
--]]
--/run ShowCriteriaNote(12509, "At the Bottom of the Sea");ShowAchievementAlert(12509)
--/run ShowAchievementAlert(8721);ShowAchievementAlert(12509);ShowAchievementAlert(12905);ShowAchievementAlert(14060)