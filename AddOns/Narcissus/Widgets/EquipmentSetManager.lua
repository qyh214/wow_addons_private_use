Narci_EquipmentSetManager = {};
local ESM = Narci_EquipmentSetManager;
local L = Narci.L;
local EquipmentSetDB;   --NarcissusDB_PC.EquipmentSetDB
local EquipmentSetManagerFrame;
local Switch = Narci_IlvlInfoFrame.IlvlButtonCenter;
local maxTalentTiers = 7;
local MaximumEquipmentSet = MAX_EQUIPMENT_SETS_PER_PLAYER;  --10
local Format_Digit = "%.2f";
local PREFIX_RED = "|cffff5050";
local PREFIX_YELLOW = "|cFFFFD100";
local PREFIX_GREY = "|cffa6a6a6";   --65% White
local ICON_NEW_SET = "Interface\\AddOns\\Narcissus\\Art\\Widgets\\EquipmentSetManager\\NewSet";
local SETBUTTON_HEIGHT = 48;

local FadeFrame = NarciAPI_FadeFrame;
local UIFrameFadeIn = UIFrameFadeIn;
local UIFrameFadeOut = UIFrameFadeOut;
local GetItemStats = NarciAPI_GetItemStats;
local SmartFontType = NarciAPI_SmartFontType;
local DoesItemExist = C_Item.DoesItemExist;
local GetNumEquipmentSets = C_EquipmentSet.GetNumEquipmentSets;     --Returns the number of saved equipment sets.
local GetItemLocations = C_EquipmentSet.GetItemLocations;
local PickupEquipmentSet = C_EquipmentSet.PickupEquipmentSet;
local GetEquipmentSetInfo = C_EquipmentSet.GetEquipmentSetInfo;
local UnpackLocation = EquipmentManager_UnpackLocation;
local GetItemInventoryType = C_Item.GetItemInventoryType;

local sin = math.sin;
local cos = math.cos;
local pi = math.pi;

local _;
-----------------------------------------------------------------------------------
--[[ LibEasing
--
-- Original Lua implementations
-- from 'EmmanuelOga'
-- https://github.com/EmmanuelOga/easing/
--
-- Adapted from
-- Tweener's easing functions (Penner's Easing Equations)
-- and http://code.google.com/p/tweener/ (jstweener javascript version)
--]]
local function outSine(t, b, c, d)
	return c * sin(t / d * (pi / 2)) + b
end
local function inOutSine(t, b, c, d)
	return -c / 2 * (cos(pi * t / d) - 1) + b
end
-----------------------------------------------------------------------------------


local function GetMaxAndKey(table)
    --Get the biggest and 2nd biggest number in a table and their keys --/dump GetMaxAndKey({1,128,129,126})

    if not table and type(table) ~="table" and #table < 2 then return; end;
    local max1,key1, max2, key2;
    
    for k, v in pairs(table) do
        if not max1 then
            max1 = v;
            key1 = k;
        elseif table[k] > max1 then
            max2 = max1;
            key2 = key1;
            max1 = v;
            key1 = k;
        end
    end

    return max1,key1, max2, key2;
end

local RepositionFrame = CreateFrame("Frame", nil, nil, "NarciUpdateFrameTemplate");
RepositionFrame.IsOpen = false;
RepositionFrame:Hide();
RepositionFrame.duration = 0.5;
local function RepositionFrame_OnShow(self)
    self.point, self.relativeTo, self.relativePoint, _, self.StartPoint = ADPrimary:GetPoint();
end

local function UpdateEquipmentSetButtonPosition(parentOffset)
    --offset: -24 ~ -96 → 48 ~ 0    y = 2/3 * x + 64
    local buttons = ESM.buttons;
    local button = buttons[1];
    local offset = parentOffset * 2 / 3 + 64;
    button:SetPoint("TOP", button:GetParent(), "TOP", 0, offset);
    for i = 2, #buttons do
        buttons[i]:SetPoint("TOP", buttons[i -1], "BOTTOM", 0, offset);
    end
end

local function RepositionFrame_OnUpdate(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
	local EndPoint = self.EndPoint;
	local StartPoint = self.StartPoint;
	local offset = outSine(self.TimeSinceLastUpdate, StartPoint, EndPoint - StartPoint, self.duration);

	if self.TimeSinceLastUpdate >= self.duration then
		offset = EndPoint;
		self:Hide();
    end

    ADPrimary:SetPoint(self.point, self.relativeTo, self.relativePoint, 0, offset);
    UpdateEquipmentSetButtonPosition(offset);
end

RepositionFrame:SetScript("OnShow", RepositionFrame_OnShow);
RepositionFrame:SetScript("OnUpdate", RepositionFrame_OnUpdate);

----------------------------------------------------------------------------------
--[[
local SlotIDtoName = Narci.SlotIDtoName;    --[SlotID] = {InventorySlotName, Localized Name, SlotID}    
local itemSlotButtons = {};                 --PaperDoll Frame: Slot buttons
for k, v in pairs(SlotIDtoName) do
    itemSlotButtons[k] = _G["Character" .. v[1] ];
end
--]]
----------------------------------------------------------------------------------
local function GetAllSelectedTalentIDsAndIcons()
    local talentInfo = {}
    local MaxTiers = GetMaxTalentTier();    --based on the character's level
    local talentGroup = GetActiveSpecGroup();
    local _, _, classID = UnitClass("player");
    talentInfo.classID = classID;

    if not talentGroup then
        talentInfo.talentGroup = false;
        return;
    else
        talentInfo.talentGroup = talentGroup;
    end

    local column, talentID, iconTexture, selected;
    for tier = 1, MaxTiers do
        _, column = GetTalentTierInfo(tier, talentGroup);
        if column then
            talentID, _, iconTexture, selected = GetTalentInfo(tier, column, talentGroup);
            talentInfo[tier] = {talentID, iconTexture};
        else
            talentInfo[tier] = {false, 134400};     --Question Mark Icon
        end
    end

    return talentInfo
end

local function LoadSetInfo(SetButton, SetName)
    local equipmentSetID = SetButton.setID;
    if not EquipmentSetDB or not equipmentSetID then return end

    local texs = SetButton.texs;
    local icon;
    local SetInfo = EquipmentSetDB[equipmentSetID];
    if SetInfo and SetName == SetInfo[1] then
        local SavedTalents = SetInfo[2];
        for i = #SavedTalents, 1, -1 do
            icon = SavedTalents[i][2];
            texs[i]:SetTexture(icon);
            texs[i]:Show();
        end
    end
end

local function SaveSetInfo(setID)
    --Save current set name and talents in the database
    if not EquipmentSetDB then return; end;
    local talentInfo = GetAllSelectedTalentIDsAndIcons(); 
    local name = GetEquipmentSetInfo(setID);
    if name then
        EquipmentSetDB[setID] = {name, talentInfo};
    end
end

local function WipeSetInfo(setID)
    if not EquipmentSetDB then return; end;
    EquipmentSetDB[setID] = nil;
end



ESM.GetAllSelectedTalentIDsAndIcons = GetAllSelectedTalentIDsAndIcons;

local function AsignTalentIcons(button)    --/run Narci_EquipmentSetManager:AsignTalentIcons(TV)
    local texs = button.texs;
    local talentInfo = GetAllSelectedTalentIDsAndIcons();
    local tiers = #talentInfo;
    if not tiers or tiers < 1 then return; end;

    local index = 1;
    for i = tiers, 1, -1 do
        texs[index]:SetTexture(talentInfo[i][2]);
        texs[index]:Show();
        index = index + 1;
    end
end

local function FadeInTalentIcons(button, action)
    local texFrame = button.texFrame;
    if action then
        UIFrameFadeIn(texFrame, 0.15, texFrame:GetAlpha(), 1);
    else
        UIFrameFadeOut(texFrame, 0.2, texFrame:GetAlpha(), 0.4);
    end
end

local function SetBackgroundColor(self)
    local colors = Narci_ColorTable[Narci_GlobalColorIndex];
    local R, G, B = colors[1], colors[2], colors[3];
    local r, g, b = R/255, G/255, B/255;
    self.Bar2:SetColorTexture(r, g, b, 0.75);
    self.Color:SetColorTexture(r, g, b, 0.75);
end

local function AnimateBackgroundColor(self)
    local colors = Narci_ColorTable[Narci_GlobalColorIndex];
    local R, G, B = colors[1], colors[2], colors[3];
    local r, g, b = R/255, G/255, B/255;
    local Black = 0.4;

    self.Color:SetColorTexture(r, g, b, 0.75);
    self.BarColors = {r, g, b};

    self.Bar2.animBling:Play();
end

local function ResetBackgroundColor(button)
    button.Bar1:SetColorTexture(0.1, 0.1, 0.1, 0.75);
    button.Bar2:SetColorTexture(0.25, 0.25, 0.25, 0.75);
    button.Color:SetColorTexture(0.2, 0.2, 0.2, 0.75);
end

local function ResetAllBackgroundColor()
    local buttons = ESM.buttons;
    for i = 1, #buttons do
        ResetBackgroundColor(buttons[i]);
    end
end

local KeyStats = {"prim", "stamina", "crit", "haste", "mastery", "versatility", "ilvl", "gems"};
local StatsName = {["crit"] = NARCI_CRITICAL_STRIKE, ["haste"] = STAT_HASTE, ["mastery"] = STAT_MASTERY, ["versatility"] = STAT_VERSATILITY,};

local function InventoryTypeToInventorySlotID(Types)
    if not Types then return {}; end;

    local SlotIDs = {};
    local slotID;

    for _, v in pairs(Types) do
        slotID = nil;

        if v > 0 and v < 11 then        --this is the range where SlotID matches the TypeID
            slotID = v;
        elseif v == 11 then             --finger
            if not SlotIDs[11] then
                slotID = 11;
            else
                slotID = 12;
            end
        elseif v == 12 then             --trinket
            if not SlotIDs[13] then
                slotID = 13;
            else
                slotID = 14;
            end
        elseif v == 13 or v == 21 then  --One-Hand/Main hand
            slotID = 16;
        elseif v == 14 or v == 22 then  --Off-hand
            slotID = 17;
        elseif v == 15 or v == 17 then  --Ranged/Two-Hand
            slotID = 16;
        elseif v == 16 then             --Back
            slotID = 15;
        elseif v == 19 then             --Tabard
            slotID = 19;
        elseif v == 20 then             --Shirt
            slotID = 5;
        end
        
        if slotID then
            SlotIDs[slotID] = true;
        end
    end

    return SlotIDs;
end

local function GetTotalStats(equipmentSetID)
    --print("|cFFFFD100"..equipmentSetID.."|r");
    local locations = GetItemLocations(equipmentSetID)
    if not locations then return; end;
    local player, bank, bags, voidStorage, slot, bag;
    local itemlocation;
    local TotalStats, Stats = {}, {};
    local toltalItems = 0;      --Ignore 4/19 Tabard & shirt
    local inventoryType;
    local IncludedTypes = {};
    local KeyStats = KeyStats;

    local function add(key)
        TotalStats[key] = TotalStats[key] + Stats[key];
    end

    for i = 1, #KeyStats do
        TotalStats[KeyStats[i]] = 0;
    end

    for k, v in pairs(locations) do
        itemlocation = nil;
        if k ~= 4 and k ~= 19 and v then     --ignore shirt and tabard during calculation
            toltalItems = toltalItems + 1;
            player, bank, bags, voidStorage, slot, bag = UnpackLocation(v);
            if bag and slot then
                --print("bag: "..bag.."  slot: "..slot);
                itemlocation = ItemLocation:CreateFromBagAndSlot(bag, slot);
                if itemlocation then
                    inventoryType = GetItemInventoryType(itemlocation);
                    tinsert(IncludedTypes, inventoryType);
                end
            elseif slot then
                --print("slot: "..slot);
                itemlocation = ItemLocation:CreateFromEquipmentSlot(slot);
            end
            
            if itemlocation then
                Stats = GetItemStats(itemlocation);
                local itemName = C_Item.GetItemName(itemlocation);
                --print(string.format("|cff959595%s:|r %s, %s, %s, %s, %s",  itemName, Stats.crit, Stats.haste, Stats.mastery, Stats.versatility, Stats.stamina));
                for j = 1, #KeyStats do
                    add(KeyStats[j])
                end
            end
        end
    end
    
    TotalStats.AverageIlvl = math.floor(100*TotalStats.ilvl/toltalItems + 0.5)/100;
    TotalStats.IncludedSlots = InventoryTypeToInventorySlotID(IncludedTypes);
    return TotalStats;
end

local RelevantSlots = {1, 2, 3, 5, 6, 7, 8, 9 ,10 ,11, 12, 13, 14 ,15, 16, 17};   --Irrelevant: 4 Shirt, 19 Tabard
local HealthFactor = 1;

local function GetHPFactor()
    --Calculate stamina → Health conversion rate
    local ConversionRate; 
    local stamina, _, posBuff, negBuff = UnitStat("player", LE_UNIT_STAT_STAMINA);
    local BasicStamima = stamina - posBuff - negBuff;
    local Health = UnitHealth("player");
    if stamina == 0 then
        ConversionRate = 20;
    else
        ConversionRate = Health / stamina;
    end

    --Calculate stamina gain from current equipment
    local Stats;
    local StaminaFromItems = 0;
    local itemlocation;
    for i = 1, #RelevantSlots do
        itemlocation = ItemLocation:CreateFromEquipmentSlot(RelevantSlots[i]);
        if DoesItemExist(itemlocation) then
            Stats = GetItemStats(itemlocation);
            StaminaFromItems = StaminaFromItems + Stats.stamina;
        end
    end

    HealthFactor = ConversionRate * stamina / (StaminaFromItems + BasicStamima) ;
end

--[[    --Deprecated Method
local function GetHealthFactor()
    --Calculate stamina → Health conversion rate
    local ConversionRate; 
    local stamina = UnitStat("player", LE_UNIT_STAT_STAMINA);
    local Health = UnitHealth("player");
    if stamina == 0 then
        ConversionRate = 20;
    else
        ConversionRate = Health / stamina;
    end

    --Calculate Stamina bonus from spec (tank) and Heart
    --Gained from Azerite Heart Essence
    local EXP = 0;          --exponential
    local slotId = 2;       --Neck
    local itemLocation = ItemLocation:CreateFromEquipmentSlot(slotId);
    if DoesItemExist(itemLocation) and C_AzeriteItem.IsAzeriteItem(itemLocation) then
        local GetMilestoneInfo = C_AzeriteEssence.GetMilestoneInfo;
        local info;
        for i = 110, 113 do
            info = GetMilestoneInfo(i);
            if info and info.unlocked then
                EXP = EXP + 1;
            else
                break;
            end
        end
    end
    local HeartBonus = 1.03^EXP;    --3%

    --Gained from Armor Skill
	local spec = GetSpecialization() or 1;
    local role = GetSpecializationRole(spec);
    local ArmorBonus = 1;
    if role == "TANK" and UnitLevel("player") >= 50 then    --Prim stat bonus starts at level 50    **9.0 Level Squash
        ArmorBonus = 1.05;
    end

    --Gained from other spell
    local SpellBonus = 1;
    if IsSpellKnown(203513) then        --Demonic Wards DH
        SpellBonus = 1.65;
    elseif IsSpellKnown(48263) then     --Veteran of the Third War DK
        if role == "TANK" then
            SpellBonus = 1.65;
        else
            SpellBonus = 1.10;
        end
    end

    print(string.format("%s | %s, %s, %s", ConversionRate, HeartBonus, ArmorBonus, SpellBonus));
    HealthFactor = ConversionRate * HeartBonus * ArmorBonus * SpellBonus;
end
--]]

local function GetEquipmentSetStatsAndHealth(equipmentSetID)
    local Stats, tempTable = {}, {};
    tempTable = GetTotalStats(equipmentSetID);
    if not tempTable then return; end;
    Stats.crit, Stats.haste, Stats.mastery, Stats.versatility = tempTable.crit, tempTable.haste, tempTable.mastery, tempTable.versatility;
    local max1, key1, max2, key2 = GetMaxAndKey(Stats)
    local stat, effectiveStat, posBuff, negBuff = UnitStat("player", LE_UNIT_STAT_STAMINA);
    local base = stat - posBuff - negBuff;
    local health = (base + tempTable.stamina) * HealthFactor;     --HP20/Stamina
    --print("HP: "..health)
    health = math.floor(health / 1000);
    return max1,key1, max2, key2, health, tempTable;
end

local isDuplicatedSet = false;

local function InitializeOptionalSetButton(frame, equipmentSetID, avgItemLevel)      --/run Narci_EquipmentSetManager:InitializeOptionalSetButton(TV)
    equipmentSetID = equipmentSetID or 1;
    --AsignTalentIcons(frame);
    local name, iconFileID, setID, isEquipped, numItems, _, _, numLost, _ = GetEquipmentSetInfo(equipmentSetID);
    frame.numLost = numLost;
    local max1,key1, max2, key2, health, statsTable = GetEquipmentSetStatsAndHealth(equipmentSetID);
    local statString = StatsName[key1];
    if key2 then
        --statString = statString.." |cff959595".."||".."|r "..StatsName[key2];
        statString = statString.." || "..StatsName[key2];
    end
    frame.SetIcon.Icon:SetTexture(iconFileID);
    frame.iconID = iconFileID;
    frame.SetName:SetText(name);
    frame.SetName:Disable();
    C_Timer.After(0, function()
        SmartFontType(frame.SetName);   
    end)

    frame.Health:SetText(health.." K")
    frame.statsTable = statsTable;
    frame.setID = equipmentSetID;
    
    local ilvl = math.floor(statsTable.AverageIlvl);

    if avgItemLevel and ilvl < avgItemLevel - 15 then
        frame.IlvlBackground:SetColorTexture(1, 0.3137, 0.3137, 1);    --Mark it red
        statString = PREFIX_RED .. L["Low Item Level"];
    else
        frame.IlvlBackground:SetColorTexture(1, 1, 1, 0.6);
        statString = PREFIX_GREY .. statString;
    end

    if numItems < 11 then--Naked set
        ilvl = "N/A";
        frame.IlvlBackground:SetColorTexture(1, 1, 1, 0.25);
    end

    frame.Ilvl:SetText(ilvl);

    if numLost > 0 then
        if numLost == 1 then
            statString = L["1 Missing Item"];
        else
            statString = string.format(L["n Missing Items"], numLost);
        end
        if numLost < 3 then
            statString = PREFIX_YELLOW .. statString;
        else
            statString = PREFIX_RED .. statString;
        end
    end

    if isDuplicatedSet and isEquipped then
        statString = PREFIX_YELLOW .. L["Duplicated Set"];
    end
    isDuplicatedSet = (isDuplicatedSet or isEquipped);
    
    frame.Enhancement:SetText(statString);

    if isEquipped then
        SetBackgroundColor(frame);
    end

    LoadSetInfo(frame, name);
    frame.Bar1:SetHeight(SETBUTTON_HEIGHT / 2);
    frame.TalentAnchor:SetPoint("RIGHT", frame.Bar1, "TOPRIGHT", 0, -12);
    frame:Show();
    --print("setID: "..setID)
end

local UpdateEquipmentNum;
local ShouldUpdateEquipment = false;
local ShouldUpdateTalent = false;

local function ShowOrHideSettings(self, visibility, useAnimation)
    if useAnimation then
        if visibility then
            FadeFrame(self.ConfirmButton, 0.15, "IN");
            FadeFrame(self.CancelButton, 0.15, "IN");
            FadeFrame(self.DeleteButton, 0.15, "IN");        
        else
            FadeFrame(self.DeleteButton, 0.15, "OUT");
            FadeFrame(self.ConfirmButton, 0.15, "OUT");
            FadeFrame(self.CancelButton, 0.15, "OUT");
        end
    else
        self.DeleteButton:SetShown(visibility);
        self.ConfirmButton:SetShown(visibility);
        self.CancelButton:SetShown(visibility);
    end
end

local function UpdateScrollRange()
    local frame = EquipmentSetManagerFrame;
    local savedSets = GetNumEquipmentSets() or 0;
    local TotalButton = math.min(savedSets + 1, MaximumEquipmentSet);
    local buttonHeight = SETBUTTON_HEIGHT;
    local TotalTab = math.max(TotalButton - 4, 1);
    local MaxScroll = floor((TotalTab - 0.5) * buttonHeight + 0.5);
    frame.ListScrollFrame.range = MaxScroll;
    frame.ListScrollFrame.scrollBar:SetMinMaxValues(0, MaxScroll)
    Switch.PlayerItemLvl:SetText(savedSets.."/"..MaximumEquipmentSet);
    Switch.Header:SetText("SETS");
end

local function InitializeEquipmentSetManager()
    --Refresh stamina factor
    GetHPFactor();
    isDuplicatedSet = false;
    ------------------------
    local button;
    local buttons = ESM.buttons;
    local SetIDs = C_EquipmentSet.GetEquipmentSetIDs() or {};
    local setID;
    local totalSets = GetNumEquipmentSets();
    local avgItemLevel = GetAverageItemLevel();
    for i = 1, MaximumEquipmentSet do
        setID = SetIDs[i];
        button = buttons[i];
        if setID then
            InitializeOptionalSetButton(button, setID, avgItemLevel);
            ShowOrHideSettings(button, false, true);
        else
            button.setID = nil;
            button.SetIcon.Icon:SetTexture(ICON_NEW_SET);
            button.SetName:SetText(PAPERDOLL_NEWEQUIPMENTSET);
            button.SetName:Enable();
            button.SetName:ClearFocus();
            if i == totalSets + 1 then
                button:Show();      --to create new set: if there are 3 saved sets, this button will be #4 
            else
                button:Hide();
            end
            button:Reset();
        end
        button:SetID(i);
        button:SetHeight(SETBUTTON_HEIGHT);
    end
end

local function SetEnhancements(c, h, m, v)
    --crit, haste, mastery, versatility
    --In order to preview the stats on each set, the radar chart and four enchancement stats stop auto updating once equipment set manager is activated
    --So enchancement stats need to be set manually
    local Radar = Narci_RadarChartFrame;
    local ConvertRatio = Narci.ConvertRatio;
    local table = {{c, "crit"}, {h, "haste"}, {m, "mastery"}, {v, "versatility"}};
    local stat = 0;
    local statBase = 0;
    local ratio = 0;
	local ratingText;
	local PercentageText;
	local key;
	for i = 1, #table do
        key = table[i][2];
        stat = table[i][1];	                                                --rating
        statBase = ConvertRatio[key.."Base"];
        ratio = ConvertRatio[key] or ratio;
        Radar[key].ValueRating:SetText(stat);
        stat = max(0, stat * ratio + statBase);	                    --Convert a rating to percentage / + basic percent (example: 10% basic critical chance)
		PercentageText = string.format(Format_Digit, stat).."%";
		Radar[key].Value:SetText(PercentageText);
	end   
end

local function HighlightRelevantSlots(table)
    local slotTable = Narci.slotTable;
    for i = 1, #slotTable do
        slotTable[i].Highlight:Hide();
        slotTable[i].Highlight:SetAlpha(0);
    end
    if not table then return; end;
    for k, v in pairs(table) do
        if v then
            slotTable[k].Highlight:Show();
            slotTable[k].Highlight:SetAlpha(1);
        end
    end
end

----------------------------------------------------------
--Event listener

local function InitializeScripts()
    local Overlay1 = EquipmentSetManagerFrame.ListScrollFrame.OverlayFrame1;
    local SaveItemButton =  Overlay1.SaveItem;
    local SaveTalentButton =  Overlay1.SaveTalent;
    
    local function ChangeColorAndText(self)
        if self.IsOn then
            self.Background:SetColorTexture(self.r, self.g, self.b);
            self:SetText(self.EnabledText);
        else
            self.Background:SetColorTexture(0.2, 0.2, 0.2);
            self:SetText(PREFIX_GREY .. self.DisabledText);
        end
    end

    local function SaveButton_OnShow(self)
        ChangeColorAndText(self);
    end

    local function SaveItemButton_OnClick(self)
        self.IsOn = not self.IsOn;
        ShouldUpdateEquipment = self.IsOn;
        ChangeColorAndText(self);
    end

    local function SaveTalentButton_OnClick(self)
        self.IsOn = not self.IsOn;
        ShouldUpdateTalent = self.IsOn;
        ChangeColorAndText(self);
    end

    SaveItemButton:SetScript("OnShow", SaveButton_OnShow);
    SaveTalentButton:SetScript("OnShow", SaveButton_OnShow);
    SaveItemButton:SetScript("OnClick", SaveItemButton_OnClick);
    SaveTalentButton:SetScript("OnClick", SaveTalentButton_OnClick);

    SaveItemButton.EnabledText = L["Update Items"];
    SaveItemButton.DisabledText = L["Don't Update Items"];
    SaveTalentButton.EnabledText = L["Update Talents"];
    SaveTalentButton.DisabledText = L["Don't Update Talents"];
end

----------------------------------------------------------

NarciEquipmentSetButtonMixin = {};

local function NarciEquipmentSetButton_AnimFrame_OnShow(self)
    local SetButton = self:GetParent();
    self.StartHeight = SetButton.Bar1:GetHeight();
    _, _ , _, self.StartX = SetButton.TalentAnchor:GetPoint();
    --self.fontName = SetButton.SetName:GetFont()  --fontName, fontHeight, fontFlags
end

local function NarciEquipmentSetButton_AnimFrame_OnUpdate(self, elapsed)
    local t = self.TimeSinceLastUpdate;
    local delay = self.Delay;
    local height = inOutSine(t, self.StartHeight, self.EndHeight - self.StartHeight , 0.25);
    local offset;
	if t >= 0.25 then
        height = self.EndHeight;
    else
        offset = self.StartX;
    end

    if t <= 0.25 + delay and t >= delay then
        offset = outSine(t - delay, self.StartX, self.EndX - self.StartX , 0.25);
    elseif t > 0.25 + delay then
        offset = self.EndX;
        self:Hide();
    end

    local parent = self:GetParent();
    parent.Bar1:SetHeight(height);
    parent.TalentAnchor:SetPoint("RIGHT", parent.Bar1, "TOPRIGHT", offset, -12);

    --parent.SetName:SetHeight(10 + height/12)
    --parent.SetName:SetFont(self.fontName, 10 + height/12);

	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
end

local function ShowFlyoutBlack(bool)
    if Narci_EquipmentFlyoutFrame:IsShown() then return; end
	Narci_FlyoutBlack.AnimFrame:Hide();
	Narci_FlyoutBlack.AnimFrame.OppoDirection = not bool;
	Narci_FlyoutBlack.AnimFrame:Show();
end

local function HideIconSelector()
    local ListScrollFrame = Narci_EquipmentSetManagerFrame.ListScrollFrame;
    local Overlay1 = ListScrollFrame.OverlayFrame1;
    local Overlay2 = ListScrollFrame.OverlayFrame2;
    ESM.IconSelector:Hide();
    Overlay1:Hide();
    Overlay2:Hide();
    ShowFlyoutBlack(false);
end

local function ShowIconSelector(SetButton)
    local Selector = ESM.IconSelector;
    local specName, specIcon, roleIcon, dungeonIcon, pvpIcon, spellIcons, roleName, spellNames = ESM:GetCurrentSpecializationNameAndIcons();

    --Icon Selector
    local Selector = ESM.IconSelector;
    Selector:ClearAllPoints();
    Selector:SetFrameLevel(40);
    Selector.SetButton = SetButton;
    
    local icons = Selector.icons;
    local buttons = Selector.buttons;

    icons[1]:SetTexture(roleIcon);
    buttons[1].iconID = roleIcon;
    buttons[1].name = roleName;
    icons[2]:SetTexture(dungeonIcon);
    buttons[2].iconID = dungeonIcon;
    buttons[2].name = CHALLENGES;
    icons[3]:SetTexture(pvpIcon);
    buttons[3].iconID = pvpIcon;
    buttons[3].name = PVP;
    local icon, button;
    --print(#spellIcons)
    for i = 4, #icons do
        icon = spellIcons[i - 3];
        button = buttons[i];
        icons[i]:SetTexture(icon);
        if icon then
            button.iconID = icon;
            button.name = spellNames[i - 3];
            button:Enable();
        else
            button.iconID = nil;
            button.name = "";
            button:Disable();
        end
    end
    Selector:SetPoint("BOTTOMRIGHT", Narci_EquipmentSetManagerFrame, "BOTTOMLEFT", -4, 0);
    FadeFrame(Selector, 0.15, "IN");
    ShowFlyoutBlack(true);
    return specName, specIcon;
end

local function CollapseButton(self)
    local AnimFrame = self.AnimFrame;
    AnimFrame:Hide();
    AnimFrame.EndHeight = SETBUTTON_HEIGHT / 2;
    AnimFrame.EndX = 0;
    AnimFrame.Delay = 0.225;
    self.SetName:Disable();
    ShowOrHideSettings(self, false, true);
    AnimFrame:Show();
end

local function ExpandButton(self)
    local AnimFrame = self.AnimFrame;
    AnimFrame:Hide();
    UIFrameFadeOut(self.Highlight, 0.15, self.Highlight:GetAlpha(), 0);
    AnimFrame.EndHeight = SETBUTTON_HEIGHT;
    AnimFrame.EndX = 140;
    AnimFrame.Delay = 0;
    self.SetName:Enable();
    self.SetName:SetFocus();
    ShowOrHideSettings(self, true, true);

    local ListScrollFrame = Narci_EquipmentSetManagerFrame.ListScrollFrame;
    local Overlay1 = ListScrollFrame.OverlayFrame1;
    local Overlay2 = ListScrollFrame.OverlayFrame2;

    FadeFrame(ESM.IconSelector, 0.15, "IN");
    FadeFrame(Overlay1, 0.15, "IN");
    FadeFrame(Overlay2, 0.15, "IN");
    AnimFrame:Show();
end

local function SetToEditMode(self, bool, showExtraButton)
    --self = SetButton
    --Collapsing animation
    if bool then
        ExpandButton(self);
    else
        CollapseButton(self);
        return;
    end

    local ListScrollFrame = Narci_EquipmentSetManagerFrame.ListScrollFrame;
    local Overlay1 = ListScrollFrame.OverlayFrame1;
    local Overlay2 = ListScrollFrame.OverlayFrame2;
    Overlay1:ClearAllPoints();
    Overlay2:ClearAllPoints();

    Overlay1:SetPoint("TOPLEFT", ListScrollFrame, "TOPLEFT", 4, 0);
    Overlay1:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 0);
    Overlay2:SetPoint("BOTTOMRIGHT", ListScrollFrame, "BOTTOMRIGHT", -4, 0);
    Overlay2:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, 0);

    local SaveItem = Overlay1.SaveItem;
    local SaveTalent = Overlay1.SaveTalent;
    Overlay1.TargetButton = self;
    if showExtraButton then
        SaveItem:ClearAllPoints();
        SaveTalent:ClearAllPoints();
        if self:GetID() == 1 then
            SaveItem:SetPoint("TOPLEFT", Overlay2, "TOPLEFT", 0, 0);
            SaveItem:SetPoint("TOPRIGHT", Overlay2, "TOP", 0, 0);
        else
            SaveItem:SetPoint("BOTTOMLEFT", Overlay1, "BOTTOMLEFT", 0, 0);
            SaveItem:SetPoint("BOTTOMRIGHT", Overlay1, "BOTTOM", 0, 0);
        end
        SaveTalent:SetPoint("LEFT", SaveItem, "RIGHT", 0, 0);
        SaveTalent:SetPoint("RIGHT", Overlay1, "RIGHT", 0, 0);
        if self.numLost ~= 0 and ShouldUpdateEquipment and UpdateEquipmentNum == self:GetID() then
            SaveItem.IsOn = true;
        end
        SaveItem:Show();
        SaveTalent:Show();
    else
        SaveItem:Hide();
        SaveTalent:Hide();
    end

    Narci_EquipmentSetManagerFrame.ArtFrame.Shadow:SetAlpha(0);
end

local function PlayBling(self)
    local Bling = EquipmentSetManagerFrame.BlingFrame;
    Bling:StopAnimating();
    Bling:ClearAllPoints();
    Bling:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
    Bling:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0);
    Bling.Bling.animIn:Play();

    PlaySound(117310);
end

local function PlayHighlight(self)
    local Highlight = EquipmentSetManagerFrame.HighlightFrame;
    Highlight:StopAnimating();
    Highlight:ClearAllPoints();
    Highlight:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
    Highlight:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0);

    local colors = Narci_ColorTable[Narci_GlobalColorIndex];
    local R, G, B = colors[1], colors[2], colors[3];
    local white = 0.4;
    local r, g, b = R/255 + white, G/255 + white, B/255 + white;
    Highlight.Color:SetColorTexture(r, g, b);

    Highlight.Color.animIn:Play();
end

local function ShowNewSetButton()
    local savedSets = GetNumEquipmentSets();
    local buttons = ESM.buttons;
    if savedSets < MaximumEquipmentSet then
        FadeFrame(buttons[savedSets + 1], 0.35, "Forced_IN");
    end
    UpdateScrollRange();
end

local IgnoreSlotsForSave = C_EquipmentSet.IgnoreSlotForSave;
local GetEquipmentSetIDByName = C_EquipmentSet.GetEquipmentSetID;

local function IsNameDuplicated(name, setID)
    --Check if the new name has been taken
    local oldID = GetEquipmentSetIDByName(name);
    if oldID and oldID ~= setID then
        return true;
    else
        return false;
    end
end

local function CreateNewSet(self)
    --self = SetButton
    local specName, specIcon = ShowIconSelector(self);
    self.SetName:Enable();
    self.SetName:SetFocus();
    self.SetName:SetText(specName);
    self.SetName:HighlightText();

    UIFrameFadeOut(self.Highlight, 0.15, self.Highlight:GetAlpha(), 0);
    SetToEditMode(self, true, false);

    self:SetIconWithTransition(specIcon, specName);
end

local function ConfirmButton_OnClick(self)
    local SetButton = self:GetParent();
    local setID = SetButton.setID;
    local name = SetButton.SetName:GetText() or SetButton.TextBackup or "";
    local icon = SetButton.iconID;
    Narci_AlertFrame_Autohide:SetAnchor(SetButton);

    if IsNameDuplicated(name, setID) then
        --A set with that name already exists
        Narci_AlertFrame_Autohide:AddMessage(EQUIPMENT_SETS_CANT_RENAME, true);
        return;
    end
    SetToEditMode(SetButton, false);
    HideIconSelector();
    if setID then
        if type(icon) == "number" then
            C_EquipmentSet.ModifyEquipmentSet(setID, name, icon);
        else
            C_EquipmentSet.ModifyEquipmentSet(setID, name);
        end
        local name, _, _, isEquipped = GetEquipmentSetInfo(setID);
        
        if ShouldUpdateTalent then
            SaveSetInfo(setID);
            --print("Talent Saved")
        end

        if ShouldUpdateEquipment then
            C_EquipmentSet.SaveEquipmentSet(setID);
        end

        LoadSetInfo(SetButton, name);

        C_Timer.After(0.25, function()
            isDuplicatedSet = false;
            InitializeOptionalSetButton(SetButton, setID);
        end)
    else
        if type(icon) == "number" then
            C_EquipmentSet.CreateEquipmentSet(name, icon);
        else
            C_EquipmentSet.CreateEquipmentSet(name);
        end

        C_Timer.After(0.25, function()
            IgnoreSlotsForSave(4);
            IgnoreSlotsForSave(19);
            local NewSetID = GetEquipmentSetIDByName(name);
            if NewSetID then
                C_EquipmentSet.SaveEquipmentSet(NewSetID);
                SaveSetInfo(NewSetID);
                InitializeOptionalSetButton(SetButton, NewSetID);
                ShowNewSetButton();
            end
        end)
    end

    SetButton.SetName:ClearFocus();
    PlayBling(SetButton);
end

local function CancelButton_OnClick(self)
    local SetButton = self:GetParent();
    local setID  = SetButton.setID;

    if setID and type(setID) == "number" then
        local name, iconFileID = GetEquipmentSetInfo(setID);
        SetButton.SetName:SetText(name);
        SetButton:SetIconWithTransition(iconFileID);
        SetToEditMode(SetButton, false);
    else
        SetButton.SetName:Disable();
        SetButton.SetName:SetText(PAPERDOLL_NEWEQUIPMENTSET);
        SetButton:SetIconWithTransition(ICON_NEW_SET);
        ShowOrHideSettings(SetButton, false, true);
    end

    HideIconSelector();
end

local function DeleteTimer_OnPlay(self)
    local SetButton = self:GetParent():GetParent():GetParent();
    local setID = SetButton.setID;
    if not (setID and type(setID) == "number") then
        SetButton.CancelButton:Click();
    end
    
    ShouldUpdateEquipment = false;
end

local function DeleteTimer_OnFinished(self)
    local SetButton = self:GetParent():GetParent():GetParent();
    Narci_EquipmentSetManagerFrame.ArtFrame.Shadow:SetAlpha(0);
    local setID = SetButton.setID;
    if setID and type(setID) == "number" then
        self:GetParent().FadeOut:Play();
        SetButton.EraseFrame:Show();
        C_EquipmentSet.DeleteEquipmentSet(setID);
        WipeSetInfo(setID);
        local savedSets = GetNumEquipmentSets() or 0;
        Switch.PlayerItemLvl:SetText(savedSets.."/"..MaximumEquipmentSet);
        Switch.Header:SetText("SETS");
        HideIconSelector();
    end
end

local function SetIcon_OnPostClick(self)
    self:GetParent():Click("RightButton");
end

local function RepositionButton(deletedButton)
    --After deleting a set, replace it with the button beneath it then move it to the bottom of the list

    local buttons = ESM.buttons;
    local ID = deletedButton:GetID();
    
    --Re-index
    for i = ID, (MaximumEquipmentSet - 1) do
        buttons[i] = buttons[i + 1];
    end
    buttons[MaximumEquipmentSet] = deletedButton;

    --Reposition
    local button = buttons[ID];
    deletedButton:ClearAllPoints();
    button:ClearAllPoints();
    deletedButton:SetPoint("TOP", buttons[MaximumEquipmentSet - 1], "BOTTOM", 0, 0);

    if ID == 1 then
        button:SetPoint("TOP", deletedButton:GetParent(), "TOP", 0, 0);
    else
        button:SetPoint("TOP", buttons[ID - 1], "BOTTOM", 0, 0);
    end
end

local function NarciEquipmentSetButton_EraseFrame_OnUpdate(self, elapsed)
    local t = self.TimeSinceLastUpdate;
    local height = inOutSine(t, SETBUTTON_HEIGHT, 0.001 - SETBUTTON_HEIGHT , 0.4);
    if t >= 0.4 then
        height = 0.001;
        self:Hide();
        local SetButton = self:GetParent();
        ShowOrHideSettings(SetButton, false, true);
        RepositionButton(SetButton);
        C_Timer.After(0.2, InitializeEquipmentSetManager);
    end
    self:GetParent():SetHeight(height);
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
end

function NarciEquipmentSetButtonMixin:OnLoad()
    self.texs = {};
    self.statsTable = {};
    self.statsTable.crit = 0;
    self.statsTable.haste = 0;
    self.statsTable.mastery = 0;
    self.statsTable.versatility = 0;
    self.setID = nil;

    --Create Talent Icon
    local texFrame = CreateFrame("Frame", nil, self);
    self.SetName:SetFrameLevel(texFrame:GetFrameLevel() + 1)
    texFrame:SetAlpha(0.4);
    local offset = 4;
    local tex;
    for i = 1, maxTalentTiers do
        tex = texFrame:CreateTexture(nil,"OVERLAY", "NarciEquipmentSetTalentTexture", 1);
        if i == 1 then
            tex:SetPoint("RIGHT", self.TalentAnchor, "RIGHT", -6 - 8, 0);

        else
            tex:SetPoint("RIGHT", self.texs[i-1], "LEFT", -offset, 0);
        end
        tinsert(self.texs, tex);
    end

    self.texFrame = texFrame;
    self.BarColors = {0.25, 0.25, 0.25};

    self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
    self:RegisterForDrag("LeftButton");
    self.AnimFrame:SetScript("OnShow", NarciEquipmentSetButton_AnimFrame_OnShow);
    self.AnimFrame:SetScript("OnUpdate", NarciEquipmentSetButton_AnimFrame_OnUpdate);
    self.EraseFrame:SetScript("OnUpdate", NarciEquipmentSetButton_EraseFrame_OnUpdate);
    self.Color = self.SetName.RightEndColor;    --Lays above talent icons

    self.ConfirmButton:SetScript("OnClick", ConfirmButton_OnClick);
    self.CancelButton:SetScript("OnClick", CancelButton_OnClick);
    self.DeleteButton.Fill.Timer:SetScript("OnPlay", DeleteTimer_OnPlay);
    self.DeleteButton.Fill.Timer:SetScript("OnFinished", DeleteTimer_OnFinished);
    self.SetIcon:SetScript("PostClick", SetIcon_OnPostClick);
end

function NarciEquipmentSetButtonMixin:SetIconWithTransition(iconFileID, iconName)
    self.iconID = iconFileID;
    self.iconName = iconName;
    local SetIcon = self.SetIcon;
    SetIcon:StopAnimating();
    SetIcon.IconTemp:SetTexture(iconFileID);
    SetIcon.IconTemp:SetAlpha(1);
    SetIcon.Icon.Transition:Play();
end

function NarciEquipmentSetButtonMixin:Reset()
    local height, offset;
    
    if self.setID and type(self.setID) == "number" then
        height = SETBUTTON_HEIGHT / 2;
        offset = 0;
    else
        height = SETBUTTON_HEIGHT;
        offset = 140;
        ResetBackgroundColor(self);

        --Remove talent icons
        local texs = self.texs;
        for i = 1, maxTalentTiers do
            texs[i]:SetTexture(nil);
            texs[i]:Hide();
        end    
    end
    self.numLost = 0;
    self.SetName:Disable();
    self.Bar1:SetHeight(height);
    self.TalentAnchor:SetPoint("RIGHT", self.Bar1, "TOPRIGHT", offset, -12);
    ShowOrHideSettings(self, false, false);
end

function NarciEquipmentSetButtonMixin:OnEnter()
    if self.SetName:HasFocus() then return; end;
    UIFrameFadeIn(self.Highlight, 0.15, self.Highlight:GetAlpha(), 0.15);
    FadeInTalentIcons(self, true);

    --Stats Preview
    if self.setID then
        local c, h, m, v = self.statsTable.crit, self.statsTable.haste, self.statsTable.mastery, self.statsTable.versatility;
        Narci:AnimateRadarChart(c, h, m, v);
        SetEnhancements(c, h, m, v);
    end
    HighlightRelevantSlots(self.statsTable.IncludedSlots);

    --All set buttons share the same shadow
    local shadow = EquipmentSetManagerFrame.ArtFrame.Shadow;
    local _, anchorTo = shadow:GetPoint();
    if not anchorTo or anchorTo ~= self then
        shadow:ClearAllPoints();
        shadow:SetPoint("CENTER", self, "CENTER", 0 , 0);
        UIFrameFadeIn(shadow, 0.15, 0, 0.6);
    end

    --Show Tooltip
    --NarciTooltip:NewText("Double-click to activate\nRight-click to modify");
end

function NarciEquipmentSetButtonMixin:OnLeave()
    if self:IsMouseOver() and EquipmentSetManagerFrame:IsMouseOver() then
        return
    end
    UIFrameFadeOut(self.Highlight, 0.3, self.Highlight:GetAlpha(), 0);
    FadeInTalentIcons(self, false);
    HighlightRelevantSlots();
    local shadow = EquipmentSetManagerFrame.ArtFrame.Shadow;
    shadow:SetAlpha(0);
end

function NarciEquipmentSetButtonMixin:OnClick(button)
    if not self.setID or self.setID == nil then
        CreateNewSet(self);
        return
    end
    
    if button == "RightButton" then
        SetToEditMode(self, true, true);
        self.iconName = L["Old Icon"];
        ShowIconSelector(self);
    end
end

function NarciEquipmentSetButtonMixin:OnDoubleClick(button)
    if not self.setID or InCombatLockdown() or type(self.setID) ~= "number" or button ~="LeftButton" then return; end;
    self:RegisterEvent("EQUIPMENT_SWAP_FINISHED");
    Narci_AlertFrame_Autohide:SetAnchor(self);
    C_EquipmentSet.UseEquipmentSet(self.setID);
    ShouldUpdateEquipment = true;
    UpdateEquipmentNum = self:GetID();
end

function NarciEquipmentSetButtonMixin:OnDragStart()
    if not self.setID or type(self.setID) ~= "number" then return; end;
    PickupEquipmentSet(self.setID);
end

function NarciEquipmentSetButtonMixin:OnEvent(event,...)
    if event == "UI_ERROR_MESSAGE" then
        local _, msg = ...
        Narci_AlertFrame_Autohide:AddMessage(msg);
    elseif event == "EQUIPMENT_SWAP_FINISHED" then
        local result, setID = ...;
        self:UnregisterEvent("EQUIPMENT_SWAP_FINISHED");
        if result then
            HighlightRelevantSlots();
            C_Timer.After(0.2, InitializeEquipmentSetManager);
            ResetAllBackgroundColor();
            PlayHighlight(self);
            AnimateBackgroundColor(self);   --Succeed
        else
            FadeFrame(self.RedOverlay, 0.1, "IN");
            C_Timer.After(0.5, function()
                FadeFrame(self.RedOverlay, 0.45, "OUT");
            end)
            self.animError:Play();      --Failed to change set
        end
    end
end

--[[
    GetSpecializationRole(specIndex)    "DAMAGER", "TANK", "HEALER"

    Test Commands:
    /run Narci:AnimateRadarChart(0,0,0,0)
/run Narci_EquipmentSetManager:InitializeOptionalSetButton(TV);Narci_EquipmentSetManager:InitializeOptionalSetButton(TV2, 0);Narci_EquipmentSetManager:InitializeOptionalSetButton(TV3, 3);
--]]

function ESM:Open()
    --PlaySound(138542);    --136114
    Narci.EnableAutoUpdate = false;
    ShouldUpdateEquipment = false;
    RepositionFrame.IsOpen = true;
    RepositionFrame:Hide();
    RepositionFrame.EndPoint = -24 - 72;
    RepositionFrame:Show();
    FadeFrame(Narci_DetailedStatFrame, 0.35, "OUT");
    FadeFrame(Narci_ConciseStatFrame, 0.35, "OUT");
    FadeFrame(EquipmentSetManagerFrame, 0.25, "IN");
    FadeFrame(Narci_RadarChartFrame, 0.5, "IN");
    UpdateScrollRange();
end

function ESM:Close()
    Narci.EnableAutoUpdate = true;
    RepositionFrame.IsOpen = false;
    RepositionFrame:Hide();
    RepositionFrame.EndPoint = -24;
    RepositionFrame:Show();
    FadeFrame(EquipmentSetManagerFrame, 0.35, "OUT");
    if NarcissusDB.DetailedIlvlInfo then
        FadeFrame(Narci_DetailedStatFrame, 0.5, "IN");
    else
        FadeFrame(Narci_ConciseStatFrame, 0.5, "IN");
        FadeFrame(Narci_RadarChartFrame, 0.35, "OUT");
    end

    Narci.AnimateRadarChart();
    Narci.RefreshAllStats();

    HideIconSelector();
end

local function CreateEquipmentSetButtons(self)
    local ScrollChild = self.ScrollChild;
    local button;
    local buttons = {};
    
    for i = 1 , MaximumEquipmentSet do
        button = CreateFrame("Button", nil, ScrollChild, "NarciEquipmentSetButtonTemplate");    --"NarciEquipmentSetButton"..i
        if i == 1 then
            button:SetPoint("TOP", ScrollChild, "TOP", 0, 0);
        else
            button:SetPoint("TOP", buttons[i - 1], "BOTTOM", 0, 0);
        end
        tinsert(buttons, button);
    end

    ESM.buttons = buttons;
end

local function UpdateInnerShadowStates(self)
	local currValue = self:GetValue();
    local minVal, maxVal = self:GetMinMaxValues();

	if ( currValue >= maxVal -20) then
		self.BottomShadow:Hide();
    else
        self.BottomShadow:Show();
    end
    
	if ( currValue <= minVal +20) then
		self.TopShadow:Hide();
    else
        self.TopShadow:Show();
	end
end

function Narci_EquipmentSetManager_ScrollFrame_OnLoad(self)
    local buttonHeight = SETBUTTON_HEIGHT;
    local TotalTab = MaximumEquipmentSet - 4;
    local TotalHeight = floor(TotalTab * buttonHeight + 0.5);
    local MaxScroll = floor((TotalTab - 0.5) * buttonHeight + 0.5);
    self.scrollBar:SetMinMaxValues(0, MaxScroll)
    self.scrollBar:SetValueStep(0.001);
    self.buttonHeight = TotalHeight;
    self.range = MaxScroll;
    self.scrollBar:SetScript("OnValueChanged", function(self, value)
        HybridScrollFrame_SetOffset(self:GetParent(), value)
        UpdateInnerShadowStates(self)
    end)
    CreateEquipmentSetButtons(self);
    NarciAPI_SmoothScroll_Initialization(self, nil, nil, 2/(TotalTab), 0.14, 0.4);
end

local function IlvlButtonCenter_OnClick(self)
    --Open/Close Equipment Set Manager
    Narci:HideButtonTooltip();
    if RepositionFrame.IsOpen then
        ESM:Close();
        Narci:SetItemLevel();
        self.isSetManagerOpen = false;
    else
        local colors = Narci_ColorTable[Narci_GlobalColorIndex];
        local R, G, B = colors[1], colors[2], colors[3];
        local Overlay1 = EquipmentSetManagerFrame.ListScrollFrame.OverlayFrame1;
        local SaveItemButton =  Overlay1.SaveItem;
        local SaveTalentButton =  Overlay1.SaveTalent;
        SaveItemButton.r, SaveItemButton.g, SaveItemButton.b = R/255, G/255, B/255;
        SaveTalentButton.r, SaveTalentButton.g, SaveTalentButton.b = R/255, G/255, B/255;
        --[[
        --Shock wave animation : Disabled
        local white = 0.4;
        local r, g, b = R/255 + white, G/255 + white, B/255 + white;
        EquipmentSetManagerFrame.ArtFrame.Tex:SetColorTexture(r, g, b);
        --]]
        InitializeEquipmentSetManager();
        ESM:Open();
        self.isSetManagerOpen = true;
        UIFrameFadeOut(self.Highlight, 0.15, self.Highlight:GetAlpha(), 0);
	end
end

Switch:SetScript("OnClick", IlvlButtonCenter_OnClick);
Switch:SetScript("OnHide", function(self)
    if RepositionFrame.IsOpen then
        self:Click();
    end
end);

-------------------------------------------------------------------
local EL = CreateFrame("Frame");
EL:RegisterEvent("PLAYER_ENTERING_WORLD");
--[[
EL:RegisterEvent("EQUIPMENT_SETS_CHANGED");
EL:RegisterEvent("EQUIPMENT_SWAP_FINISHED");
EL:RegisterEvent("EQUIPMENT_SWAP_PENDING");
EL:RegisterEvent("TRANSMOG_OUTFITS_CHANGED");
EL:RegisterEvent("WEAR_EQUIPMENT_SET");
--]]
EL:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD");
        C_Timer.After(1, function()
            NarcissusDB_PC = NarcissusDB_PC or {};
            EquipmentSetDB = NarcissusDB_PC.EquipmentSetDB;
            EquipmentSetManagerFrame = Narci_EquipmentSetManagerFrame;
            InitializeScripts();
        end);
    end

    --[[
    print(PREFIX_YELLOW .. event .. "|r");
    if event == "EQUIPMENT_SWAP_FINISHED" then
        local result, setID = ...;
        if not setID then return; end;
        print("Set #"..setID.." "..tostring(result));
    elseif event == "WEAR_EQUIPMENT_SET" then
        local setID = ...;
        print("Wearing Set #"..setID);
    elseif event == "EQUIPMENT_SETS_CHANGED" then
        local a = ...;
        print(a);
    end
    --]]
end)