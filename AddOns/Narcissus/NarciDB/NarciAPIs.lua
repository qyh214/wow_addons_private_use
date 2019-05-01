--------------------
----API Datebase----
--------------------
local _, CommanderOfArgus = GetAchievementInfo(12078)                                   --Argus Weapon Transmogs: Arsenal: Weapons of the Lightforged
CommanderOfArgus = CommanderOfArgus or "Commander of Argus"
CommanderOfArgus = BATTLE_PET_SOURCE_6 .." |cFFFFD100"..CommanderOfArgus.."|r"
--print("Name: "..CommanderOfArgus)

local HeritageArmorItemIDs = {
    165931, 165932, 165933, 165934, 165935, 165936, 165937, 16598,                      --Dwarf
    161008, 161009, 161010, 161011, 161012, 161013, 161014, 161015,                     --Dark Iron
    156668, 156669, 156670, 156671, 156672, 156673, 156674, 156684,                     --Highmountain
    156699, 156700, 156701, 156702, 156703, 156704, 156705, 156706,                     --Lightforged
    161050, 161051, 161052, 161054, 161055, 161056, 161057, 161058,                     --Mag'har Orc (Blackrock Recolor)
    161059, 161060, 161061, 161062, 161063, 161064, 161065, 161066,                     --Mag'har Orc (Frostwolf Recolor)
    160992, 160993, 160994, 160999, 161000, 161001, 161002, 161003,                     --Mag'har Orc (Warsong Recolor)
    156690, 156691, 156692, 156693, 156694, 156695, 156696, 156697, 157758, 158917,     --Void Elf
    156675, 156676, 156677, 156678, 156679, 156680, 156681, 156685,                     --Nightborne
    166348, 166349, 166351, 166352, 166353, 166354, 166355, 166356, 166357,             --Blood Elf
    
    --Reserved for test↓
    
}

local SecretlItemIDs = {
    [157636]  = true,     --Waist of Time
}

local SpecialItemList = {
    [152332] = CommanderOfArgus,            --Brilliant Daybreak Aegis
    [152333] = CommanderOfArgus,            --Lustrous Daybreak Aegis
    [152334] = CommanderOfArgus,            --Brilliant Eventide Aegis
    [152335] = CommanderOfArgus,            --Lustrous Eventide Aegis
    [152336] = CommanderOfArgus,            --Lustrous Daybreak Blade
    [152336] = CommanderOfArgus,            --Lustrous Daybreak Blade
    [152336] = CommanderOfArgus,            --Lustrous Daybreak Blade
    [152337] = CommanderOfArgus,            --Brilliant Daybreak Blade
    [152338] = CommanderOfArgus,            --Lustrous Eventide Blade
    [152339] = CommanderOfArgus,            --Brilliant Daybreak Blade
    [152340] = CommanderOfArgus,            --Lustrous Daybreak Greatsword
    [152341] = CommanderOfArgus,            --Lustrous Eventide Greatsword
    [152342] = CommanderOfArgus,            --Lustrous Daybreak Staff
    [152343] = CommanderOfArgus,            --Lustrous Eventide Staff
    [157636] = CommanderOfArgus,            --Test
}


local function BuildSearchTable(table)
    if type(table) ~="table" then
        return;
    end

    local newTable = {};

    for k, v in pairs(table) do
        newTable[v] = true;
    end

    wipe(HeritageArmorItemIDs)
    return newTable;
end

local HeritageArmorList = BuildSearchTable(HeritageArmorItemIDs);

-----Color API------
Narci_GlobalColorIndex = 0;
Narci_ColorTable = {
	[0] = { 35,  96, 147},	--default Blue  0.1372, 0.3765, 0.5765
	[1] = {121,  31,  35},	--Orgrimmar
	[2] = { 49, 176, 107},	--Zuldazar
	[3] = {187, 161, 134},	--Vol'dun
	[4] = { 89, 140, 123},	--Tiragarde Sound
	[5] = {127, 164, 114},	--Stormsong
	[6] = {156, 165, 153},	--Drustvar
	[7] = { 42,  63,  79},	--Halls of Shadow


	--Main City--
	[84]  = { 35,  96, 147},	--Stormwind City
	[85]  = {121,  52,  55},	--Orgrimmar
	[86]  = {121,  31,  35},	--Orgrimmar - Cleft of Shadow
	[87]  = {102,  64,  58},	--Ironforge
	[88]  = {115, 140, 113},	--Thunder Bluff
	[89]  = {121,  31,  35},	--Darnassus	R.I.P.
	[90]  = { 42,  63,  79},	--Undercity

	[625] = { 42,  63,  79},	--Dalaran  	Broken Isles
	[626] = { 42,  63,  79},	--Hall of Shadow
	[627] = {102,  58,  64},	--Dalaran  	Broken Isles

	-- BFA --
	[1163]= { 89, 140, 123},	--Dazar'alor - The Great Seal
	[1164]= { 89, 140, 123},	--Dazar'alor - Hall of Chroniclers
	[1165]= { 89, 140, 123},	--Dazar'alor
	[862] = { 89, 140, 123},	--Zuldazar
	[864] = {187, 161, 134},	--Vol'dun
	[863] = { 48,  94, 131},	--Nazmir
	[895] = { 89, 140, 123},	--Tiragarde Sound
	[1161]= { 89, 140, 123},	--Boralus
	[942] = {127, 164, 114},	--Stormsong
	[896] = {156, 165, 153},	--Drustvar
}


--------------------
------Item API------
--------------------

function NarciAPI_GetItemEnchant(itemLink)
    local EnchantID = 0;
    local _, a = string.find(itemLink, ":%d+:.-:")
    local _, b = string.find(itemLink, ":%d+:")

    if a and b and ((b + 1) < (a -1)) then
        EnchantID = string.sub(itemLink, b+1, a-1)
    end

    return tonumber(EnchantID)
end

function NarciAPI_IsHeritageArmor(itemID)
    if not itemID then
        return false;
    end
    
    if HeritageArmorList[itemID] then
        return true;
    else
        return false;
    end
end

function NarciAPI_IsSpecialItem(itemID)
    if not itemID then
        return false;
    end
    
    local itemSource = SpecialItemList[itemID]
    if itemSource ~= nil then
        --print("Is Special")
        return true, itemSource;
    end

    if SecretlItemIDs[itemID] then
        return true, ITEMSOURCE_SECRETFINDING;
    else
        return false;
    end
end

--------------------
---Formating API----
--------------------

function NarciAPI_FormatLargeNumbers(value)
    value = tonumber(value) or 0;
    local formatedNumber = ""
    if value >= 1000 and value < 1000000 then
        formatedNumber = strsub(value, 1, -4) .. "," .. strsub(value, -3);
    elseif value >= 1000000 and value < 1000000000 then
        formatedNumber = strsub(value, 1, -7) .. "," .. strsub(value, -6, -4) .. "," .. strsub(value, -3);
    else
        formatedNumber  = tostring(value)
    end
    return formatedNumber
end


--------------------
---Fade Frame API---
--------------------

local function SetFade_finishedFunc(frame)
	if frame.fadeInfo.mode == "OUT" then
		frame:Hide();
	elseif	frame.fadeInfo.mode == "IN" then
		frame:Show();
	end
end

function NarciAPI_FadeFrame(frame, time, mode)
	if mode == "IN" then
		UIFrameFadeIn(frame, time, frame:GetAlpha(), 1)
	elseif mode == "OUT" then
		if not frame:IsShown() then
			return;
		end
		UIFrameFadeOut(frame, time, frame:GetAlpha(), 0)
	elseif mode == "Forced_IN" then
		UIFrameFadeIn(frame, time, 0, 1)
	elseif mode == "Forced_OUT" then
	UIFrameFadeOut(frame, time, 1, 0)
	end

	if not frame.fadeInfo then
		return;
	end

	frame.fadeInfo.finishedArg1 = frame;
	frame.fadeInfo.finishedFunc = SetFade_finishedFunc
end
------------------------------------------------------------------

function NarciAPI_OptimizeBorderThickness(self)
    local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
    self:SetPoint(point, relativeTo, relativePoint, math.floor(xOfs + 0.5), math.floor(yOfs + 0.5))

    local scale = string.match(GetCVar( "gxWindowedResolution" ), "%d+x(%d+)" );
    local uiScale = self:GetEffectiveScale();
    local rate = 768/scale/uiScale;
    local borderWeight = 2;
    local weight = borderWeight * rate;
    local weight2 = weight * math.sqrt(2);
    self.Border:SetPoint("TOPLEFT", weight, -weight)
    self.Border:SetPoint("BOTTOMRIGHT", -weight, weight)

    if self.ThumbBorder then
        self.ThumbBorder:SetPoint("TOPLEFT", self.VirtualThumb, -weight2, weight2)
        self.ThumbBorder:SetPoint("BOTTOMRIGHT", self.VirtualThumb,weight2, -weight2)
    end

    if self.Marks then
        for i=1, #self.Marks do
            self.Marks[i]:SetWidth(weight);
        end
    end
end

function NarciAPI_SliderWithSteps_OnLoad(self)
    self.oldValue = 0;
    self.Marks = {};
    local width = self:GetWidth();
    local step = self:GetValueStep();
    local sliderMin, sliderMax = self:GetMinMaxValues()
    local range = sliderMax - sliderMin;
    local num_Gap = math.floor((range / step) + 0.5);
    local tex;
    local markOffset = 5;
    width = width - 2*markOffset
    --print(self:GetName().." "..(num_Gap + 1))
    for i=1, (num_Gap + 1) do
        tex = self:CreateTexture(nil, "BACKGROUND", nil, 1);
        --tex:SetAllPoints()
        tex:SetSize(2, 10)
        tex:SetColorTexture(0.3, 0.3, 0.3, 1)
        --print((i-1)*width/num_Gap)
        tex:SetPoint("LEFT", self, "LEFT", markOffset + (i-1)*width/num_Gap, 0)
        tinsert(self.Marks, tex);
    end
end