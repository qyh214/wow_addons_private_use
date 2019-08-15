local pi = math.pi;
local sin = math.sin;
local FadeFrame = NarciAPI_FadeFrame;
local LanguageDetector = Narci_LanguageDetector;
local Screenshot = Screenshot;
local updateThreshold = 2;
local _G = _G;
local NARCI_GROUP_PHOTO_NOTIFICATION = NARCI_GROUP_PHOTO_NOTIFICATION;
-----------------------------------
local defaultZ = -0.275;
local defaultY = 0.4;
local startY = 2;
local endFacing = -pi/8;
local animationID_Max = 1471;
local IndexButtonPosition = {
	1, 2, 3, 4, 5,
}

local function HighlightButton(button, bool)
	if bool then
		button:LockHighlight();
		button.Label:SetTextColor(1, 1, 1)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		button:UnlockHighlight();
		button.Label:SetTextColor(0.6, 0.6, 0.6);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
end

local ActorNameFont = {
	["CN"] = {"Interface\\AddOns\\Narcissus\\Font\\NotoSansCJKsc-Medium.otf", 8},
	["RM"] = {"Interface\\AddOns\\Narcissus\\Font\\OpenSans-Semibold.ttf", 9},
	["RU"] = {"Interface\\AddOns\\Narcissus\\Font\\NotoSans-Medium.ttf", 8},
	["KR"] = {"Interface\\AddOns\\Narcissus\\Font\\NotoSansCJKsc-Medium.otf", 8},
	["JP"] = {"Interface\\AddOns\\Narcissus\\Font\\NotoSansCJKsc-Medium.otf", 8},
}

local function SmartFontType(fontstring, text)
	--Automatically apply different font based on given text languange. Change text color after this step.
	if not fontstring then return; end;
	fontstring:SetText(text);
	local Language = LanguageDetector(text);
	if Language and ActorNameFont[Language] then
		fontstring:SetFont(ActorNameFont[Language][1] , ActorNameFont[Language][2]);
	end
end

local function SetAlertFrame(anchor, msg, offsetY)
	local frame = Narci_AlertFrame_Autohide;
	local offsetY = offsetY or -12;
	frame:Hide();
	frame:SetParent(anchor);
	frame:ClearAllPoints();
	frame.Text:SetText(msg);
    frame:SetScale(Narci_Character:GetEffectiveScale())
	frame:SetPoint("BOTTOM", anchor, "TOP", 0, offsetY)
	frame:SetFrameLevel(50);
	FadeFrame(frame, 0.2, "IN");
end

local function SetTutorialFrame(self, msg)
	local frame = Narci_AlertFrame_Static;
	frame:SetScale(Narci_Character:GetScale())
	frame.Text:SetText(msg);
	frame:SetParent(self)
	frame:SetPoint("BOTTOM", self, "TOP", 0, -4)
	frame:SetHeight(frame.Background:GetHeight());
	frame:SetFrameStrata("TOOLTIP");
	frame:Hide();
	FadeFrame(frame, 0.25, "IN");

	if NarcissusDB and NarcissusDB.Tutorials and NarcissusDB.Tutorials[self.keyValue] then
		NarcissusDB.Tutorials[self.keyValue] = false;
	end
end

local IsScaleLinked = false;
local IsLightLinked = true;

local ModelSettings = {
	["Generic"] = { panMaxLeft = -4, panMaxRight = 3, panMaxTop = 1.2, panMaxBottom = -1.6, panValue = 40 },
}

local TranslateValue_Male = {
	--[raceID] = {ZoomValue, defaultY, defaultZ},
	[0] = {[1] = {0.05, 0.4, -0.275},		--Default Value
				[2] = {0.05, 0.4, -0.275}},

	[1] = {[1] = {0, 0.43, -0.32},
				[2] = {-0.3, 0.7, -0.26}},		--1 Human √

	[2] = {[1] = {-0.2, 0.6, -0.44},
				[2] = {-0.5, 0.88, -0.386}},		--2 Orc √

	[3] = {[1] = {0.05, 0.2, -0.12},
				[2] = {-0.3, 0.4, -0.03}},		--3 Dwarf √

	[4] = {[1] = {0.1, 0.52, -0.31},
				[2] = {-0.2, 0.8, -0.18}},		--4 NE √

	[5] = {[1] = {0.1, 0.19, -0.2},
				[2] = {-0.3, 0.55, -0.2}},		--5 UD √

	[6] = {[1] = {0, 0.54, -0.1},
				[2] = {-0.3, 0.8, 0}},		--6 Tauren Male √

	[7] = {[1] = {0.05, 0, -0.09},
				[2] = {-0.6, 0.19, -0.175}},		--7 Gnome √

	[8] = {[1] = {-0.2, 0.5, -0.4},
				[2] = {-0.6, 0.76, -0.48}},		--8 Troll √

	[9] = {[1] = {0, 0.13, -0.06},
				[2] = {-0.5, 0.4, -0.123}},		--9 Goblin √

	[10] = {[1] = {0.2, 0.27, -0.25},
				[2] = {-0.3, 0.65, -0.29}},		--10 BloodElf Male √

	[11] = {[1] = {-0.1, 0.84, -0.417},
				[2] = {-0.5, 1.2, -0.48}},		--11 Goat Male √
			
	[24] = {[1] = {0, 0.78, -0.16},
				[2] = {-0.2, 1, -0.15}},		--24 Pandaren Male √

	[27] = {[1] = {0.1, 0.46, -0.35},
				[2] = {-0.3, 0.85, -0.334}},		--27 Nightborne √

	[28] = {[1] = {0.05, 0, -0.09},
				[2] = {-0.6, 0.3, -0.175}},		--28 Tauren Male √

	[31] = {[1] = {0.1, 0.61, -0.4},
				[2] = {-0.3, 1.15, -0.32}},		--31 Zandalari √

	[32] = {[1] = {0.1, 0.55, -0.36},
				[2] = {-0.4, 0.98, -0.46}},	--32 Kul'Tiran √

	[36] = {[1] = {0, 0.87, -0.35},
				[2] = {-0.3, 1.1, -0.38}},		--36 Mag'har √
}

local TranslateValue_Female = {
	--[raceID] = {ZoomValue, defaultY, defaultZ},
	[0] = {[1] = {0.05, 0.4, -0.275},		--Default Value
				[2] = {0.05, 0.4, -0.275}},

	[1] = {[1] = {0.1, 0.27, -0.34},
				[2] = {-0.3, 0.7, -0.26}},		--1 Human √

	[2] = {[1] = {0.1, 0.42, -0.33},
				[2] = {-0.3, 0.7, -0.25}},		--2 Orc √

	[3] = {[1] = {0.0, 0.19, -0.2},
				[2] = {-0.3, 0.4, -0.13}},		--3 Dwarf √

	[4] = {[1] = {0.2, 0.28, -0.28},
				[2] = {-0.3, 0.7, -0.317}},		--4 NE √

	[5] = {[1] = {0.2, 0.3, -0.15},
				[2] = {-0.2, 0.55, -0.09}},		--5 UD √

	[6] = {[1] = {0.1, 0.53, -0.30},
				[2] = {-0.3, 0.85, -0.26}},		--6 Tauren Female √

	[7] = {[1] = {0.05, 0, -0.09},
				[2] = {-0.4, 0.2, -0.1}},		--7 Gnome √

	[8] = {[1] = {0.1, 0.43, -0.3},
				[2] = {-0.4, 0.8, -0.26}},		--8 Troll √

	[9] = {[1] = {0, 0.13, -0.06},
				[2] = {-0.5, 0.35, -0.1653}},		--9 Goblin √

	[10] = {[1] = {0.2, 0.20, -0.25},
				[2] = {-0.3, 0.75, -0.23}},		--10 BloodElf Female √

	[11] = {[1] = {0.2, 0.35, -0.28},
				[2] = {-0.3, 0.85, -0.33}},		--11 Goat Female √
			
	[24] = {[1] = {-0.1, 0.64, -0.34},
				[2] = {-0.4, 1, -0.27}},		--24 Pandaren Female √

	[27] = {[1] = {0.1, 0.45, -0.35},
				[2] = {-0.4, 0.9, -0.378}},		--27 Nightborne √

	[31] = {[1] = {0.2, 0.5, -0.454},
				[2] = {-0.3, 0.95, -0.46}},		--31 Zandalari √

	[32] = {[1] = {0.1, 0.45, -0.36},
				[2] = {-0.5, 0.85, -0.48}},	--32 Kul'Tiran √

	[36] = {[1] = {0.1, 0.42, -0.33},
				[2] = {-0.3, 0.7, -0.25}},		--36 Mag'har √
}

local _, _, raceID = UnitRace("player")
if raceID == 28 then		--Hightmountain
	raceID = 6;
elseif raceID == 30 then	--Lightforged
	raceID = 11;
elseif raceID == 36 then	--Mag'har Orc
	--raceID = 2;
elseif raceID == 34 then	--DarkIron
	raceID = 3;
elseif raceID == 22 then	--Worgen
	raceID = 1;
elseif raceID == 25 or raceID == 26 then --Pandaren A|H
	raceID = 24;
elseif raceID == 28 then
	raceID = 6;
elseif raceID == 29 then
	raceID = 10;
end

local genderID = UnitSex("player"); --2 Male	3 Female
local TranslateValue
if genderID == 2 then
	TranslateValue = TranslateValue_Male[raceID];
else
	TranslateValue = TranslateValue_Female[raceID];
end
-----------------------------------

local function outSine(t, b, c, d)
	return c * sin(t / d * (pi / 2)) + b
end
local function outQuad(t, b, c, d)
	t = t / d
	return -c * t * (t - 2) + b
end
-----------------------------------
local activeModelIndex = 1;
local Narci_ModelFrames = {
	[1] = NarciModelFrame1,
};

local playerInfo = {};

--Derivative of Blizzard DressUpFrames.lua--
local function DressUpSources(appearanceSources, mainHandEnchant, offHandEnchant)
    if ( not appearanceSources ) then
		return true;
	end
	local model = Narci_ModelFrames[activeModelIndex];
	local mainHandSlotID = 16   --GetInventorySlotInfo("MAINHANDSLOT");
	local secondaryHandSlotID = 17  --GetInventorySlotInfo("SECONDARYHANDSLOT");
	--[[
	for i = 1, #appearanceSources do
		if ( i ~= mainHandSlotID and i ~= secondaryHandSlotID ) then
			if ( appearanceSources[i] and appearanceSources[i] ~= NO_TRANSMOG_SOURCE_ID ) then
                model:TryOn(appearanceSources[i]);
			end
        end
	end
	--]]
	model:TryOn(appearanceSources[mainHandSlotID], "MAINHANDSLOT", mainHandEnchant);
    model:TryOn(appearanceSources[secondaryHandSlotID], "SECONDARYHANDSLOT", offHandEnchant);
end

local function UpdateModel(unit)
	--If target player is holding the same weapon in main&off-hand, only the offhand weapon will be shown--
	--This method can solve this issue--
	if not CanInspect(unit, false) then return; end;
	NotifyInspect(unit);
	C_Timer.After(0.1,function()
		DressUpSources(C_TransmogCollection.GetInspectSources())
		ClearInspectPlayer();
	end);
end

local function SetGenderIcon(genderID)
	local button = Narci_GenderButton;
	if genderID == 3 then
		--female
		button.Icon:SetTexCoord(0.5, 1, 0, 0.5);
		button.Icon2:SetTexCoord(0.5, 1, 0, 0.5);
		button.Highlight:SetTexCoord(0.5, 1, 0.5, 1);
	elseif genderID == 2 then
		button.Icon:SetTexCoord(0, 0.5, 0, 0.5);
		button.Icon2:SetTexCoord(0, 0.5, 0, 0.5);
		button.Highlight:SetTexCoord(0, 0.5, 0.5, 1);
	end
end

local function GetUnitRaceIDAndSex(unit)
	unit = unit or "player";
	local raceID, gender
	_, _, raceID = UnitRace(unit);
	gender = UnitSex(unit);	
	return raceID, gender
end

local function InitializePlayerInfo(index, unit)
	local unit = unit or "player";
	local name = UnitName(unit);
	local _, className = UnitClass(unit);
	playerInfo[index] = playerInfo[index] or {};
	playerInfo[index].raceID_Original, playerInfo[index].gender_Original = GetUnitRaceIDAndSex(unit);
	playerInfo[index].raceID = playerInfo[index].raceID_Original;
	playerInfo[index].gender = playerInfo[index].gender_Original;
	playerInfo[index].name = name;
	playerInfo[index].class = className;
	SetGenderIcon(playerInfo[index].gender_Original);
	local r, g, b = GetClassColor(className);
	local fontstring = Narci_ActorPanel.ExtraPanel.buttons[index].Label;
	SmartFontType(fontstring, name);
	fontstring:SetTextColor(r, g, b);
end

local function RestorePlayerInfo(index)
	if not playerInfo[index] then return; end;
	playerInfo[index].raceID = playerInfo[index].raceID_Original;
	playerInfo[index].gender = playerInfo[index].gender_Original;
	SetGenderIcon(playerInfo[index].gender_Original);
end

local function UpdateActorName(index)
	Narci_ActorPanel.ActorIndex:SetText(index);
	local className = playerInfo[index].class;
	local r, g, b = GetClassColor(className);
	if className == "DEATHKNIGHT" or "DEMONHUNTER" or "SHAMAN" then
		r, g, b = r + 0.05, g + 0.05, b + 0.05;
	end
	
	SmartFontType(Narci_ActorPanel.ActorName, playerInfo[index].name);
	Narci_ActorPanel.ActorName:SetTextColor(r, g, b);
end

local function ResetRaceAndSex(model)
	local modelIndex = model:GetID() or 1;
	model:SetCustomRace(playerInfo[modelIndex].raceID_Original, playerInfo[modelIndex].gender_Original);
end

local function ResetCameraPosition(model)
	model:SetCameraPosition(3.62, 0, 0.65);
	model:SetCameraTarget(-0.42, -0.08, 0.60);
end

local function AddNewModelFrame(model)
	for i = 2, 5 do								--Maximum model number is 5, retain #1 for player's model
		if not Narci_ModelFrames[i] then
			Narci_ModelFrames[i] = model;
			return true;
		end
	end
	return false;
end

function UpdateGroundShadowOption()
	local button = Narci_GroundShadowOption;
	local shadowFrame = Narci_ModelFrames[activeModelIndex].GroundShadow;
	local state = shadowFrame:IsShown();
	HighlightButton(button, state);
end

local function SetActiveModel(index)
	activeModelIndex = index or 1;
	for i = 1, #Narci_ModelFrames do
		if Narci_ModelFrames[i] then
			Narci_ModelFrames[i]:EnableMouse(false);
			Narci_ModelFrames[i]:EnableMouseWheel(false);
			Narci_ModelFrames[i].GroundShadow:EnableMouse(false);
			Narci_ModelFrames[i].GroundShadow.Border:Hide();
		end
	end
	local model = Narci_ModelFrames[activeModelIndex];
	if not model then return; end;
	model:EnableMouse(true);
	model:EnableMouseWheel(true);
	model:MakeCurrentCameraCustom();
	local shadowFrame = model.GroundShadow;
	shadowFrame:EnableMouse(true);
	shadowFrame.Border:SetAlpha(1);
	shadowFrame.Border:Show();
	NarciModelControl_AnimationIDEditBox:SetText(model.animationID or 0);
	local sheathState = model:GetSheathed();
	Narci_AnimationOptionFrame_Sheath.button.Highlight:SetShown(sheathState);
	Narci_AnimationOptionFrame_Sheath.button.IsOn = sheathState;

	if not shadowFrame.ManuallyHidden then
		FadeFrame(shadowFrame, 0.25, "IN");
	end
end

local function Narci_CharacterModelFrame_OnShow(self)
	if self.xmogMode == 2 then
		NarciModel_RightGradient:Show();
	else
		NarciModel_RightGradient:Hide();
	end
	FadeFrame(Narci_CharacterModelSettings, 0.5, "IN")
end

function Narci_CharcaterModelFrame_OnHide(self)
	if ( self.panning ) then
		self.panning = false;
	end
	self.mouseDown = false;
	Narci_CharacterModelSettings:Hide();
	Narci_ChromaKey:Hide();
	Narci_ChromaKey:SetAlpha(0);
end

local function rotateTexture(frame, Degree)
    local ag = frame:CreateAnimationGroup()    
    local a1 = ag:CreateAnimation("Rotation")
	a1:SetDegrees(Degree)
	a1:SetOrigin("CENTER",0 ,0) 
	a1:SetOrder(1)
	a1:SetDuration(0)
	local a2 = ag:CreateAnimation("Rotation")
	a2:SetDegrees(0)
	a2:SetOrigin("CENTER",0 ,0) 
	a2:SetOrder(2)
    a2:SetDuration(1)       
	ag:Play()
	ag:Pause()  
end

function LightButton_UpdateFrame_OnLoad(self)
	self.r = self:GetParent():GetWidth()/2 - 4
	local button = self:GetParent().Thumb
	--button:SetPoint("CENTER", 0, -self.r)
	local radian = self.radian
	local x, y = self.r*math.cos(radian), self.r*math.sin(radian)
	button:SetPoint("CENTER", x, y)
	button.Tex:SetRotation(radian)
	button.Highlight:SetRotation(radian)
	self:GetParent().BeamMask:SetRotation(radian)

	self.lastDegree = math.deg(radian)
end

function LightButton_UpdateFrame_OnUpdate(self)
	local rad, cos, sin, sqrt, max, min = math.rad, math.cos, math.sin, math.sqrt, math.max, math.min
	local button = self:GetParent().Thumb
	local radian
	local r = self.r

	local mx, my = self:GetParent():GetCenter()
	local px, py = GetCursorPosition()
	local scale = self:GetParent():GetEffectiveScale()
	px, py = px / scale, py / scale
	radian = math.atan2(py - my, px - mx);
	
	if self.limit then
		if radian >= pi/2 then
			radian = pi/2;
		elseif radian <= -pi/2 then
			radian = -pi/2
		end
		LightInfoSharedFrame.AngleZ = radian;
	else
		LightInfoSharedFrame.AngleXY = radian;
		local FaceLeft = self:GetParent():GetParent().LeftView.FaceLeft;
		local FaceRight = self:GetParent():GetParent().LeftView.FaceRight;
		if FaceLeft and FaceRight then
			local degree2 = math.deg(radian)
			if degree2 > 0 then
				FaceLeft:SetAlpha(1)
				FaceRight:SetAlpha(0)
			elseif degree2 <= 0 and radian >= -180 then
				FaceLeft:SetAlpha(0)
				FaceRight:SetAlpha(1)
			end
		end
	end

	local degree = math.deg(radian)
	rotateTexture(self:GetParent().BeamMask, degree - self.lastDegree)
	self.lastDegree = degree
	local x, y = r*cos(radian), r*sin(radian)
	button:SetPoint("CENTER", x, y)
	button.Tex:SetRotation(radian)
	button.Highlight:SetRotation(radian)
	local phi = pi/2-(LightInfoSharedFrame.AngleZ)
	local rX = sin(phi)*sin(LightInfoSharedFrame.AngleXY)
	local rY = -sin(phi)*cos(LightInfoSharedFrame.AngleXY)
	local rZ = -cos(phi)

	local _, _, _, _, _, ambIntensity, ambR, ambG, ambB, dirIntensity, dirR, dirG, dirB = Narci_ModelFrames[activeModelIndex]:GetLight();
	if IsLightLinked then
		for i = 1, #Narci_ModelFrames do
			Narci_ModelFrames[i]:SetLight(true, false, rX, rY, rZ, ambIntensity, ambR, ambG, ambB, dirIntensity, dirR, dirG, dirB);
		end
	else
		Narci_ModelFrames[activeModelIndex]:SetLight(true, false, rX, rY, rZ, ambIntensity, ambR, ambG, ambB, dirIntensity, dirR, dirG, dirB);
	end
end

local PMAI = CreateFrame("Frame","PlayerModelAnimIn");
PMAI.TimeSinceLastUpdate = 0
PMAI.FaceTime = 0;
PMAI.Trigger = true
local function PlayerModelAnimIn_Update(self, elapsed)
	local ModelFrame = NarciModelFrame1
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
	local turnTime = 0.36
	local t = 1;
	local offset = outQuad(self.TimeSinceLastUpdate, startY, defaultY - startY, t)

	if self.TimeSinceLastUpdate > turnTime then
		self.FaceTime= self.FaceTime + elapsed;
		local radian = outSine(self.FaceTime, -pi/2, endFacing + pi/2, 0.8) --0.11 NE
		ModelFrame:SetFacing(radian)
		ModelFrame.rotation = radian
	end

	ModelFrame:SetPosition(0, offset, defaultZ)
	ModelFrame.cameraY, ModelFrame.cameraZ = offset, defaultZ
	if self.TimeSinceLastUpdate >= t then
		ModelFrame.cameraX = 0;
		self.TimeSinceLastUpdate = 0;
		self:Hide();
	end
	
	if self.TimeSinceLastUpdate <=0.8 then
		return;
	elseif self.Trigger then
		self.Trigger = false;
		ModelFrame:SetAnimation(804, 1)
		ModelFrame:MakeCurrentCameraCustom();
	end
end

local function InitializeModel(model)
	model:SetLight(true, false, - 0.44699833180028 ,  0.72403680806459 , -0.52532198881773, 0.8, 172/255, 172/255, 172/255, 1, 0.8, 0.8, 0.8);
	if NarcissusDB.ShowFullBody then
		ZoomMode = 2;
	else
		ZoomMode = 1;
	end
	local zoomLevel = TranslateValue[ZoomMode][1] or 0.05;
	defaultY = TranslateValue[ZoomMode][2] or 0.4;
	defaultZ = TranslateValue[ZoomMode][3] or -0.275;
	model:SetPortraitZoom(zoomLevel)
	model.zoomLevel = zoomLevel
	model:SetPosition(0, defaultY, defaultZ);
	model:SetAnimation(804, 1)
	model:MakeCurrentCameraCustom();
end

function Narci_OtherCharacterModelFrame_OnShow(self)
	InitializeModel(self);
end

function Narci_OtherCharacterModelFrame_OnHide(self)
	if ( self.panning ) then
		self.panning = false;
	end
	self.mouseDown = false;
end

local hasSetLight = false;

PMAI:Hide();									--PlayerModelAnimIn
PMAI:SetScript("OnShow", function()
	local ModelFrame = NarciModelFrame1;
	local ZoomMode;
	if NarcissusDB.ShowFullBody then
		ZoomMode = 2;	--Full body
	else
		ZoomMode = 1;
	end
	local zoomLevel = TranslateValue[ZoomMode][1] or 0.05;
	defaultY = TranslateValue[ZoomMode][2] or 0.4;
	defaultZ = TranslateValue[ZoomMode][3] or -0.275;
	ModelFrame:SetPortraitZoom(zoomLevel)
	ModelFrame.zoomLevel = zoomLevel
	ModelFrame:SetPosition(0, startY, defaultZ);
	ModelFrame:SetFacing(-pi/2)
	ModelFrame:FreezeAnimation(4,1)
	ModelFrame:SetAnimation(4)
	FadeFrame(ModelFrame, 0.5, "Forced_IN")

	if not hasSetLight then		--IDK why but you cannot set light color/intensity unless the model is visible
		Narci_CharacterModelSettings.ColorPresets.Color1:Click();
		ModelFrame:SetSheathed(true);
		hasSetLight = true;
	end
end);
PMAI:SetScript("OnUpdate", PlayerModelAnimIn_Update);
PMAI:SetScript("OnHide", function(self)
	--Narci_CharacterListener:RegisterEvent("UNIT_MODEL_CHANGED");
	self.TimeSinceLastUpdate = 0
	self.FaceTime = 0
	self.Trigger = true
	NarciModelFrame1.cameraDistance = NarciModelFrame1:GetCameraDistance()
end);

local PMAO = CreateFrame("Frame","PlayerModelAnimOut");
PMAO:Hide();
PMAO.TimeSinceLastUpdate = 0
PMAO.FaceTime = 0;
PMAO.Trigger = true;
PMAO.Facing = 0;
PMAO.PosX = 0;
PMAO.PosY = 0;

local function PlayerModelAnimOut_Update(self, elapsed)
	local ModelFrame = NarciModelFrame1;
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
	local turnTime = 0.3;
	local t = 1;

	local radian = outSine(self.TimeSinceLastUpdate, self.Facing, pi/2 - self.Facing, turnTime); --0.11 NE
	if self.TimeSinceLastUpdate < turnTime then
		ModelFrame:SetFacing(radian);
		ModelFrame.rotation = radian;
	end

	if self.TimeSinceLastUpdate > 0.2 then
		self.FaceTime= self.FaceTime + elapsed;
		local offset = PMAO.PosX + 1.15*self.FaceTime/t;
		ModelFrame:SetPosition(0, offset, self.PosY);
		ModelFrame.cameraY, ModelFrame.cameraZ = offset, PMAO.PosY;
	end

	if self.TimeSinceLastUpdate >= t then
		ModelFrame:SetUnit("player");
		self.TimeSinceLastUpdate = 0;
		self:Hide();
	end
	
	if self.TimeSinceLastUpdate <=0.1 then
		return;
	elseif self.Trigger then
		self.Trigger = false;
		ModelFrame:SetAnimation(4);
	end
end

PMAO:SetScript("OnShow", function(self)
	self.Facing = NarciModelFrame1:GetFacing();
	_, self.PosX, self.PosY = NarciModelFrame1:GetPosition();
	FadeFrame(Narci_CharacterModelSettings, 0.4, "OUT")
	
	for i = 2, #Narci_ModelFrames do
		FadeFrame(Narci_ModelFrames[i], 0.25, "OUT");
	end
end)

PMAO:SetScript("OnUpdate", PlayerModelAnimOut_Update);
PMAO:SetScript("OnHide", function(self)
	self.TimeSinceLastUpdate = 0;
	self.FaceTime = 0;
	self.Trigger = true;
	
end);

function Narci_SetLightButton(self, button)
	local model = Narci_ModelFrames[activeModelIndex];
	local _, _, dirX, dirY, dirZ, ambIntensity, ambR, ambG, ambB, dirIntensity, dirR, dirG, dirB = model:GetLight();
	local offset = 0
	local change = 0;
	local id = self:GetID()
	if button ~= "MiddleButton" then
		if button == "LeftButton" then
			offset = 0.1
		elseif button == "RightButton" then
			offset = -0.1
		end

		if id == 1 then
			dirX = dirX + offset;
			change = dirX;
		elseif id == 2 then
			dirY = dirY + offset;
			change = dirY;
		elseif id == 3 then
			dirZ = dirZ + offset;
			change = dirZ;
		end

	elseif button == "MiddleButton" then
		if id == 1 then
			dirX = -0.5
			change = dirX;
		elseif id == 2 then
			dirY = 0.5
			change = dirY;
		elseif id == 3 then
			dirZ = -0.5
			change = dirZ;
		end		
	end
		
	self.Readings:SetText(string.format(Format_Digit, change))
	model:SetLight(true, false, dirX, dirY, dirZ, ambIntensity, ambR, ambG, ambB, dirIntensity, dirR, dirG, dirB)
end

--------------------------------
--------------------------------
function Narci_Xmog_UseCompactMode(state)
	local frame = NarciModelFrame1;
	if state then
		FadeFrame(frame.GuideFrame, 0.5, "IN");
		ModelVignetteRightSmall:Show();
		UIFrameFadeOut(NarciModel_RightGradient, 0.5, NarciModel_RightGradient:GetAlpha(), 0)
	else
		FadeFrame(frame.GuideFrame, 0.5, "OUT");
		if NarciModelFrame1.xmogMode == 2 and Narci_Character:IsShown() then
			UIFrameFadeIn(NarciModel_RightGradient, 0.5, NarciModel_RightGradient:GetAlpha(), 1)
		end
	end
end
--/run Narci_Xmog_UseCompactMode
----------- Derivated from Blizzard ModelFrames.lua	Model_OnUpdate() -----------
local Smooth_Zoom = CreateFrame("Frame");
local SetCameraDistance = SetCameraDistance;
Smooth_Zoom.TimeSinceLastUpdate = 0;
Smooth_Zoom.duration = 0.2;
Smooth_Zoom:Hide();

local function Smooth_Zoom_Update(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
	local EndPoint = self.EndPoint;
	local StartPoint = self.StartPoint;
	local Value = outSine(self.TimeSinceLastUpdate, StartPoint, EndPoint - StartPoint, self.duration) --0.11 NE
	if IsScaleLinked then
		for i = 1, #Narci_ModelFrames do
			Narci_ModelFrames[i]:SetCameraDistance(Value);
			Narci_ModelFrames[i].cameraDistance = Value;
		end
	else
		Narci_ModelFrames[activeModelIndex]:SetCameraDistance(Value);
	end

	if self.TimeSinceLastUpdate >= self.duration then
		--SetCVar("test_cameraOverShoulder", EndPoint)
		self:Hide();
	end
end


Smooth_Zoom:SetScript("OnShow", function(self)
	self.StartPoint = Narci_ModelFrames[activeModelIndex]:GetCameraDistance()
	--print(self.EndPoint);
end);
Smooth_Zoom:SetScript("OnUpdate", Smooth_Zoom_Update);
Smooth_Zoom:SetScript("OnHide", function(self)
	self.TimeSinceLastUpdate = 0
end);

local function SmoothZoomModel(EndPoint)
	Smooth_Zoom:Hide();
	Smooth_Zoom.EndPoint = EndPoint;
	Smooth_Zoom:Show();
end

function NarciModel_OnWheel(self, delta)
	--[[
	maxZoom = self.maxZoom;
	minZoom = self.minZoom;
	local zoomLevel = self.zoomLevel;
	zoomLevel = zoomLevel + delta * 0.1;
	zoomLevel = min(zoomLevel, maxZoom);
	zoomLevel = max(zoomLevel, minZoom);
	self:SetPortraitZoom(zoomLevel);
	self.zoomLevel = zoomLevel;
	--]]
	if not self:HasCustomCamera() then return; end
	self.cameraDistance = self:GetCameraDistance() - delta * 0.25
	SmoothZoomModel(self.cameraDistance)
end
function NarciModel_StartPanning(self)
	self.panning = true;
	local cameraX, cameraY, cameraZ = self:GetPosition();
	self.cameraX = cameraX;
	self.cameraY = cameraY;
	self.cameraZ = cameraZ;
	local cursorX, cursorY = GetCursorPosition();
	self.cursorX = cursorX;
	self.cursorY = cursorY;
end

function NarciModel_OnMouseDown(model, button)
	if ( not button or button == "LeftButton" ) then
		model.mouseDown = true;
		model.rotationCursorStart = GetCursorPosition();
	end
end

function Narci_Model_OnUpdate(self, elapsedTime)

	-- Mouse drag rotation
	if (self.mouseDown) then
		if ( self.rotationCursorStart ) then
			local x = GetCursorPosition();
			local diff = (x - self.rotationCursorStart) * MODELFRAME_DRAG_ROTATION_CONSTANT;
			self.rotationCursorStart = GetCursorPosition();
			self.rotation = self.rotation + diff;
			if ( self.rotation < 0 ) then
				self.rotation = self.rotation + (2 * PI);
			end
			if ( self.rotation > (2 * PI) ) then
				self.rotation = self.rotation - (2 * PI);
			end
			self:SetRotation(self.rotation, false);
		end
	elseif ( self.panning ) then
		local modelScale = self:GetModelScale();
		local cursorX, cursorY = GetCursorPosition();
		local scale = UIParent:GetEffectiveScale();
		-- settings
		local settings;
		settings = ModelSettings["Generic"]
		--[[
		local hasAlternateForm, inAlternateForm = HasAlternateForm();
		if ( hasAlternateForm and inAlternateForm ) then
			settings = ModelSettings[playerRaceSex.."Alt"];
		else
			settings = ModelSettings[playerRaceSex];
		end
		--]]
		local zoom = self.zoomLevel or self.minZoom;
		zoom = 1 + zoom - self.minZoom;	-- want 1 at minimum zoom

		-- Panning should require roughly the same mouse movement regardless of zoom level so the model moves at the same rate as the cursor
		-- This formula more or less works for all zoom levels, found via trial and error
		local transformationRatio = settings.panValue * 2 ^ (zoom * 2) * scale / modelScale;

		local dx = (cursorX - self.cursorX) / transformationRatio;
		local dy = (cursorY - self.cursorY) / transformationRatio;
		local cameraY = self.cameraY + dx;
		local cameraZ = self.cameraZ + dy;
		-- bounds
		scale = scale * modelScale;
		local maxCameraY = settings.panMaxRight * scale;
		cameraY = min(cameraY, maxCameraY);
		local minCameraY = settings.panMaxLeft * scale;
		cameraY = max(cameraY, minCameraY);
		local maxCameraZ = settings.panMaxTop * scale;
		cameraZ = min(cameraZ, maxCameraZ);
		local minCameraZ = settings.panMaxBottom * scale;
		cameraZ = max(cameraZ, minCameraZ);

		self:SetPosition(self.cameraX, cameraY, cameraZ);
		self:SetCameraDistance(self.cameraDistance)
		--print(self.cameraX .." "..cameraY.." "..cameraZ)
		--print(self.cameraDistance)
	end
end

function Narci_Model_SetSheath(self)
	local model = Narci_ModelFrames[activeModelIndex];
	self.IsOn = not self.IsOn;
	model:SetSheathed(self.IsOn);
	if self.IsOn then
		self.Highlight:Show();
	else
		self.Highlight:Hide();
	end
end

function Narci_ShowEquipmentSlots(alpha)
	Narci_Character:SetShown(not Narci_Character:IsShown());
end

function Narci_ShowPlayerModel(alpha)
	local frame = NarciModelFrame1;
	if state ~= nil then
		frame:SetAlpha(alpha);
	else
		if frame:GetAlpha() == 1 then
			frame:SetAlpha(0);
			Narci_VignetteLeft:Hide();
			VignetteRightLarge:Hide();
		else
			frame:SetAlpha(1);
			Narci_VignetteLeft:Show();
			VignetteRightLarge:Show();
		end
	end
end

function Narci_ShowChromaKey(state)
	local frame = Narci_ChromaKey;

	if state then
		FadeFrame(frame, 0.25, "IN");
		Narci_Character:SetShown(false);
	else
		FadeFrame(frame, 0.5, "OUT");
		if Narci_SlotLayerButton.IsOn then
			Narci_Character:SetShown(true);
		end
	end
end

--[[
Chroma Key Blue :
0, 71, 187
#0047bb

Chroma Key Green :
0, 177, 64
#00b140
--]]

--- Show Alpha Channel ---

local function ShowTextAlphaChannel(state)
    local slotTable = Narci_Character.slotTable;
    if not (slotTable) then
        return;
    end
	
	local theme = NarcissusDB.BorderTheme;
	local borderMask;
	local shadowAlpha = false;
	local runeAlpha = 1;
	if theme == "Bright" then
		borderMask = "Interface/AddOns/Narcissus/Art/Masks/HexagonThin-Mask";
	elseif theme == "Dark" then
		borderMask = "Interface/AddOns/Narcissus/Art/Masks/HexagonThick-Mask";
		shadowAlpha = true;
		runeAlpha = 0;
	end
	if state then
		for i=1, #slotTable do
			if slotTable[i] then
				--slotTable[i].Name:SetFont(font, Height);
				if slotTable[i].RuneSlot then
					slotTable[i].RuneSlot.AlphaChannelRune:Show();
					slotTable[i].RuneSlot.Background:SetAlpha(runeAlpha);
				end
				slotTable[i].AlphaChannelBorder:SetTexture(borderMask);
				slotTable[i].AlphaChannelBorder:Show();
				slotTable[i].AlphaChannelShadow:SetShown(shadowAlpha);
				slotTable[i].GradientBackground:SetColorTexture(1, 1, 1);
				slotTable[i].Name:SetTextColor(1, 1, 1);
				slotTable[i].Name:SetShadowColor(1, 1, 1);
				local sourcePlainText = slotTable[i].sourcePlainText;
				if sourcePlainText then
					slotTable[i].ItemLevel:SetText(sourcePlainText);
				end
				slotTable[i].ItemLevel:SetTextColor(1, 1, 1);
				slotTable[i].ItemLevel:SetShadowColor(1, 1, 1);
			end
		end
		NarciModelFrame1:SetAlpha(0);
		Narci_XmogNameFrame:Hide();
		Narci_Character:Show();
	else
		for i=1, #slotTable do
			if slotTable[i] then
				--slotTable[i].Name:SetFont(font, Height);
				if slotTable[i].RuneSlot then
					slotTable[i].RuneSlot.AlphaChannelRune:Hide();
					slotTable[i].RuneSlot.Background:SetAlpha(runeAlpha);
				end
				slotTable[i].AlphaChannelBorder:Hide();
				slotTable[i].AlphaChannelShadow:Hide();
				slotTable[i].GradientBackground:SetColorTexture(0, 0, 0);
				slotTable[i].Name:SetShadowColor(0, 0, 0);
				slotTable[i].ItemLevel:SetShadowColor(0, 0, 0);	
				Narci_ItemSlotButton_OnLoad(slotTable[i]);
			end
		end
		NarciModelFrame1:SetAlpha(1);
		Narci_XmogNameFrame:Show();
	end
end

function ShowTextAlphaChannel_OnClick(state)
	ShowTextAlphaChannel(state)
	if state then
		FadeFrame(FullScreenAlphaChannel, 0.5, "IN")
	else
		FadeFrame(FullScreenAlphaChannel, 0.5, "OUT")
	end
end

local hasBackup = false;
local LayerButtonStates = {};
local function UnhighlightAllLayerButtons()
	local buttons = Narci_CharacterModelSettings.LayerButtons;
	if not hasBackup then
		wipe(LayerButtonStates);
	end

	for i=1, #buttons do
		if not hasBackup then
			tinsert(LayerButtonStates, buttons[i].IsOn);
		end
		buttons[i].IsOn = false;
		buttons[i]:UnlockHighlight();
		buttons[i].Label:SetTextColor(0.6, 0.6, 0.6)
		buttons[i].AlphaButton.IsOn = false;
		buttons[i].AlphaButton:UnlockHighlight();
	end
	hasBackup = true;
end

local function RestoreAllLayerButtons()
	local buttons = Narci_CharacterModelSettings.LayerButtons;
	for i=1, #buttons do
		local state = LayerButtonStates[i];
		buttons[i].IsOn = state
		buttons[i].AlphaButton.IsOn = false;
		buttons[i].AlphaButton:UnlockHighlight();
		--print(i..": "..tostring(state))
		HighlightButton(buttons[i], state);
	end
	hasBackup = false;
end

local function ExitAlphaMode()
	local buttons = Narci_CharacterModelSettings.AlphaButtons;
	for i=1, #buttons do
		if buttons[i].IsOn then
			buttons[i]:Click()
			return true;
		end
	end
	return false;
end

local function LayerButton_OnClick(self)
	if ExitAlphaMode() then
		return;
	end

	self.IsOn = not self.IsOn;
	HighlightButton(self, self.IsOn);
end

local function HideVignette()
	local state = Narci_VignetteLeft:IsShown()
	Narci_VignetteLeft:SetShown(not state);
	VignetteRightSmall:SetShown(not state);
	if NarciModelFrame1.xmogMode == 2 and not state then
		VignetteRightLarge:SetShown(true);
	end
end

local function SlotLayerButton_OnClick(self)
	LayerButton_OnClick(self);
	--Narci_Character:SetShown(self.IsOn);
	if self.IsOn then
		if NarciModelFrame1.xmogMode == 2 then
			FadeFrame(NarciModel_RightGradient, 0.25, "IN");
		end
		FadeFrame(Narci_Character, 0.25, "IN");
	else
		FadeFrame(NarciModel_RightGradient, 0.25, "OUT");
		FadeFrame(Narci_Character, 0.25, "OUT");
	end
end

local function PlayerModelLayerButton_OnClick(self)
	LayerButton_OnClick(self);
	local model = Narci_CharacterModelContainer;
	if self.IsOn then
		if model:IsShown() then
			UIFrameFadeIn(model, 0.25, model:GetAlpha(), 1);
		end
	else
		UIFrameFadeOut(model, 0.25, model:GetAlpha(), 0);
	end	
end

local function PlayerModelLayerButton_Newbee(self)
	SetTutorialFrame(self, NARCI_TUTORIAL_GREEN_SCREEN);
	self:SetScript("OnClick", PlayerModelLayerButton_OnClick);
end

function Narci_LayerButton_OnLoad(self)
	self.IsOn = true;
	self:LockHighlight();
	local ID = self:GetID();
	if ID == 1 then
		self.Label:SetText(NARCI_EQUIPMENTSLOTS);
		self.Icon:SetTexCoord(0.5, 0.703125, 0.703125, 0.890625);
		self:SetScript("OnClick", SlotLayerButton_OnClick);
	elseif ID == 2 then
		self.Label:SetText(NARCI_3DMODEL);
		self:SetScript("OnClick", PlayerModelLayerButton_OnClick);
	end
	
	if not self:GetParent().LayerButtons then
		self:GetParent().LayerButtons = {};
	end
	tinsert(self:GetParent().LayerButtons, self);
end

local function AlphaLayerButton_OnClick(self)
	self.IsOn = not self.IsOn;
	if self.IsOn then
		UnhighlightAllLayerButtons();
		self.IsOn = true;
		self:LockHighlight();
		self:GetParent().Label:SetTextColor(1, 1, 1)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		RestoreAllLayerButtons();
		self:UnlockHighlight();
		self.IsOn = false;
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end	
end

function Narci_AlphaLayerButton_OnLoad(self)
	self.IsOn = false;
	local ID = self:GetParent():GetID();
	if ID == 1 then
		self:SetScript("OnClick", function(self)
			if Narci_PlayerModelLayerButton.AlphaButton.IsOn then
				Narci_PlayerModelLayerButton.AlphaButton:Click();
			end
			AlphaLayerButton_OnClick(self);
			ShowTextAlphaChannel_OnClick(self.IsOn);
		end)
		self:SetScript("OnHide", function()
			if self.IsOn then
				self.IsOn = false;
				self:UnlockHighlight();
				self:GetParent().Label:SetTextColor(0.6, 0.6, 0.6);
				ShowTextAlphaChannel_OnClick(false);
			end
		end)
	elseif ID == 2 then
		self:SetScript("OnClick", function(self)
			if Narci_SlotLayerButton.AlphaButton.IsOn then
				Narci_SlotLayerButton.AlphaButton:Click();
			end
			AlphaLayerButton_OnClick(self);
			Narci_ShowChromaKey(self.IsOn);
			if self.IsOn then
				self:GetParent().ColorButtons:Show();
			else
				self:GetParent().ColorButtons:Hide();
			end
		end)
		self:SetScript("OnHide", function()
			if self.IsOn then
				self.IsOn = false;
				self:UnlockHighlight();
				self:GetParent().Label:SetTextColor(0.6, 0.6, 0.6);
			end
		end)
	end

	if not self:GetParent():GetParent().AlphaButtons then
		self:GetParent():GetParent().AlphaButtons = {};
	end
	tinsert(self:GetParent():GetParent().AlphaButtons, self);
end


local AutoCloseTimer = C_Timer.NewTimer(0, function()	end)

function Narci_AnimationOption_MainTabButton_OnClick(self)
	AutoCloseTimer:Cancel()
	self.IsOn = not self.IsOn;
	if self.IsOn then
		self.Background:SetTexCoord(0, 0.376953125, 0.52734375, 0.6328125);
		self.Arrow:SetTexCoord(0, 1, 1, 0);
		self:GetParent().OtherTab:Show();
	else
		self.Background:SetTexCoord(0, 0.376953125, 0.2109375, 0.31640625);
		self.Arrow:SetTexCoord(0, 1, 0, 1);
		self:GetParent().OtherTab:Hide();
	end
	AutoCloseTimer = C_Timer.NewTimer(5, function()
		if Narci_AnimationOptionFrame_Tab1.IsOn then
			Narci_AnimationOptionFrame_Tab1:Click();
		end
	end)
end

local maxTab = 3;
local animationIDs = {
	[1] = {110, 48, 109, 29, ["name"] = NARCI_RANGED_WEAPON,},
	[2] = {968, 1242, 1240, 1076, ["name"] = NARCI_MELEE_WEAPON,},
	[3] = {124, 51, 874, 940, ["name"] = NARCI_SPELLCASTING,},
}

function Narci_AnimationOptionFrame_OnLoad(self)
	local _, _, classID = UnitClass("player");
	local ID;
	if classID == 5 or classID == 8 or classID == 9 or classID == 11 then	--spellcasting
		ID = 3;
	elseif classID == 3 then												--hunter
		ID = 1;
	else
		ID = 2;
	end
	self.tab1:SetID(ID);
	self.tab1.Label:SetText(animationIDs[ID]["name"]);

	local otherIDs = {}
	for i=1, maxTab do
		if i ~= ID then
			tinsert(otherIDs, i)
		end
	end

	self.OtherTab.tab2:SetID(otherIDs[1]);
	self.OtherTab.tab2.Label:SetText(animationIDs[otherIDs[1]]["name"]);	
	self.OtherTab.tab3:SetID(otherIDs[2]);
	self.OtherTab.tab3.Label:SetText(animationIDs[otherIDs[2]]["name"]);

	local buttons = self.buttons;
	for i=1, #buttons do
		buttons[i]:SetID(animationIDs[ID][i]);
	end
end

function Narci_AnimationOption_OtherTabButton_OnClick(self)
	local ID = self:GetID();
	local tab1 = self:GetParent():GetParent().tab1;
	local activeID = tab1:GetID();
	local buttons = self:GetParent():GetParent().buttons;

	for i=1, #buttons do
		buttons[i]:SetID(animationIDs[ID][i]);
		buttons[i].animOut:Play();
	end

	self:SetID(activeID);
	self.Label:SetText(animationIDs[activeID]["name"]);
	tab1:SetID(ID);
	tab1.Label:SetText(animationIDs[ID]["name"]);
	tab1:Click();
end

function Narci_Model_Idle(self)
	local model = Narci_ModelFrames[activeModelIndex];
	model:SetAnimation(804, 1);

	self.IsOn = true;
	if not self.IsOn then
		self.Highlight:Hide();
	end

	local buttons = Narci_AnimationOptionFrame.buttons;
	for i=1, #buttons do
		buttons[i].IsOn = false;
		buttons[i].Highlight:Hide();
	end
end

function Narci_AnimationPresetButton_OnClick(self)
	Narci_ModelFrames[activeModelIndex]:SetAnimation(self:GetID(), 1)
	local buttons = self:GetParent().buttons;
	for i=1, #buttons do
		buttons[i].Highlight:Hide();
		buttons[i].IsOn = false;
	end
	Narci_Model_IdleButton.IsOn = false;
	Narci_Model_IdleButton.Highlight:Hide();
	self.IsOn = true;
	self.Highlight:Show();
end

function Narci_Model_DarknessSlider_OnValueChanged(self, value, userInput)
    self.VirtualThumb:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0)
    if value ~= self.oldValue then
		self.oldValue = value
		Narci_BackgroundBrightnessTexture:SetAlpha(value);
    end
end

function Narci_Model_VignetteSlider_OnValueChanged(self, value, userInput)
    self.VirtualThumb:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0)
    if value ~= self.oldValue then
		self.oldValue = value
		Narci_VignetteLeft:SetAlpha(value);
		VignetteRightLarge:SetAlpha(value);
		VignetteRightSmall:SetAlpha(value);
		ModelVignetteRightSmall:SetAlpha(value);
    end
end

function Narci_Model_UseCompactMode_OnClick(self)
	self.IsOn = not self.IsOn;
	if self.IsOn then
		self:LockHighlight();
		self.Label:SetTextColor(1, 1, 1)
		if not Narci_HidePlayerButton.IsOn then
			Narci_HidePlayerButton:Click();
		end
	else
		self:UnlockHighlight();
		self.Label:SetTextColor(0.6, 0.6, 0.6)
		if Narci_HidePlayerButton.IsOn then
			Narci_HidePlayerButton:Click();
		end
	end
	Narci_Xmog_UseCompactMode(self.IsOn);
end

function Narci_Model_HidePlayer_OnClick(self)
	self.IsOn = not self.IsOn;
	ConsoleExec( "showPlayer");
	HighlightButton(self, self.IsOn);
end

function NarciModelControl_AnimationSlider_OnValueChanged(self, value, userInput)
    self.VirtualThumb:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0)
	if value ~= self.oldValue then
		if not self:IsShown() then return; end
		self.oldValue = value
		local id = NarciModelControl_AnimationIDEditBox:GetNumber();
		local model = Narci_ModelFrames[activeModelIndex];
		model:FreezeAnimation(id, 0, value)
    end
end

function NextAnimationButton_Newbee(self, button)
	SetTutorialFrame(self, NARCI_TUTORIAL_ANIMATION_ID);
	NarciModelControl_NextAnimationButton_OnClick(self, button);
	self:SetScript("OnClick", NarciModelControl_NextAnimationButton_OnClick);
end

function Narci_ModelShadow_SizeSlider_OnValueChanged(self, value, userInput)
    self.VirtualThumb:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0)
    if value ~= self.oldValue then
		self.oldValue = value
		self:GetParent():GetParent().Shadow:SetScale(value)
    end
end

function Narci_ModelShadow_AlphaSlider_OnValueChanged(self, value, userInput)
    self.VirtualThumb:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0)
    if value ~= self.oldValue then
		self.oldValue = value
		self:GetParent():GetParent().Shadow:SetAlpha(value)
    end
end




-------------------------
---- Custom Lighting ----
-------------------------
local SetAmbient = true;
local Xenabled, Xomni, XdirX, XdirY, XdirZ, XambIntensity, XambR, XambG, XambB, XdirIntensity, XdirR, XdirG, XdirB

local function SetViewerLightColor(r, g, b)
	if not SetAmbient then
		Narci_CharacterModelSettings.TopView.LightColor:SetColorTexture(r, g, b, 0.6);
		Narci_CharacterModelSettings.LeftView.LightColor:SetColorTexture(r, g, b, 0.6);
	else
		Narci_CharacterModelSettings.TopView.AmbientColor:SetColorTexture(r, g, b, 0.5);
		Narci_CharacterModelSettings.LeftView.AmbientColor:SetColorTexture(r, g, b, 0.5);
	end
end

local function RGB2HSV(r, g, b)
	local Cmax = max(r, g, b);
	local Cmin = min(r, g, b);
	local dif = Cmax - Cmin;
	local Hue = 0;
	local Brightness = math.floor(100*(Cmax / 255)+0.5)/100;
	local Stauration = 0;
	if Cmax ~= 0 then Stauration = math.floor(100*(dif / Cmax)+0.5)/100; end;

	if dif ~= 0 then
		if r == Cmax and g >= b then
			Hue = (g - b) / dif + 0;
		elseif r == Cmax and g < b then
			Hue = (g - b) / dif + 6;
		elseif g == Cmax then
			Hue = (b - r) / dif + 2;
		elseif b == Cmax then
			Hue = (r - g) / dif + 4;
		end
	end
	--print(60*Hue.."° "..Stauration.."% "..Brightness.."%")
	return math.floor(60*Hue + 0.5), Stauration, Brightness
end

local function HSV2RGB(h, s, v)
	local floor = math.floor;
	local Cmax = 255 * v;
	local Cmin = Cmax * (1 - s);
	local i = floor(h / 60);
	local dif = h % 60;
	local Cmid = (Cmax - Cmin) * dif / 60
	local r, g, b
	if i == 0 then
		r, g, b = Cmax, Cmin + Cmid, Cmin;
	elseif i == 1 then
		r, g, b = Cmax - Cmid, Cmax, Cmin;
	elseif i == 2 then
		r, g, b = Cmin, Cmax, Cmin + Cmid;
	elseif i == 3 then
		r, g, b = Cmin, Cmax - Cmid, Cmax;
	elseif i == 4 then
		r, g, b = Cmin + Cmid, Cmin, Cmax;
	else
		r, g, b = Cmax, Cmin, Cmax - Cmid;
	end

	--print(floor(r + 0.5).." "..floor(g + 0.5).." "..floor(b + 0.5))
	r, g, b = floor(r + 0.5)/255, floor(g + 0.5)/255, floor(b + 0.5)/255
	return r, g, b
end

function Narci_ColorButton_OnClick(self)
	--Change Light Color--
	--[[]]
	--[[
	local model = Narci_ModelFrames[activeModelIndex]
	_, _, XdirX, XdirY, XdirZ, XambIntensity, _, _, _, XdirIntensity, XdirR, XdirG, XdirB = model:GetLight();
	model:SetLight(true, false, XdirX, XdirY, XdirZ, XambIntensity, self.r, self.g, self.b, XdirIntensity, XdirR, XdirG, XdirB)
	--]]
	local H, S, V = RGB2HSV(self.r, self.g, self.b)
	local ColorSliders = Narci_CharacterModelSettings.ColorSliders;
	if H then ColorSliders.HueSlider:SetValue(H); end
	if S then ColorSliders.SaturationSlider:SetValue(S); end
	if V then ColorSliders.BrightnessSlider:SetValue(V); end

	SetViewerLightColor(self.r/255, self.g/255, self.b/255)

	local ColorButtons = self:GetParent().Colors
	for i=1, #ColorButtons do
		ColorButtons[i].Border:SetTexCoord(0.75, 0.8359375, 0, 0.171875)
	end
	self.Border:SetTexCoord(0.8359375, 0.921875, 0, 0.171875)
end

function ColorButton_OnLoad(self)
	local r, g, b = 0, 0, 0;
	local id = self:GetID();

	if id == 1 then
		r, g, b = 204, 204, 204;
	elseif id == 2 then
		r, g, b = 0.65*255, 0.45*255, 0.7*255; --
	elseif id == 3 then
		r, g, b = 140, 70, 70
	elseif id == 4 then
		r, g, b = 220, 173, 83; --
	elseif id == 5 then
		r, g, b = 80, 186, 141;
	elseif id == 6 then
		r, g, b = 0, 174, 239;
	elseif id == 7 then
		r, g, b = 40, 124, 186; --
 	elseif id == 8 then
		r, g, b = 70, 61, 220;
	end

	self.r = r;
	self.g = g;
	self.b = b;

	self.Color:SetColorTexture(r / 255, g / 255, b / 255, 1);

	if not self:GetParent().Colors then
		self:GetParent().Colors = {};
	end
	tinsert(self:GetParent().Colors, self)
end




---------------------------
---------------------------
---------------------------
local LayersToBeCaptured = -1;
local Alpha_Temp1 = 1;
local Alpha_Temp2 = 1;
local Vignette_Temp = 0;
local Brightness_Temp = 0;
local HidePlayer_Temp = false;
local FullSceenChromaKey;
local r1, g1, b1 = 0, 177/255, 64/255;
local r2, g2, b2 = 0, 71/255, 187/255;

local function NarciModel_OnMouseUp(model, button)
	if ( not button or button == "LeftButton" ) then
		model.mouseDown = false;
	end
end

function NarciTargetModel_OnLoad(self, maxZoom, minZoom, defaultRotation, onMouseUp)
	self:SetKeepModelOnHide(true);
	if UnitExists("target") and UnitIsPlayer("target") then
		self:SetUnit("target");
	else
		self:SetUnit("player");
	end
	
	self.maxZoom = maxZoom or MODELFRAME_MAX_ZOOM;
	self.minZoom = minZoom or MODELFRAME_MIN_ZOOM;
	self.defaultRotation = defaultRotation or MODELFRAME_DEFAULT_ROTATION;
	self.onMouseUpFunc = onMouseUp or NarciModel_OnMouseUp;
	self.rotation = self.defaultRotation;
	self:SetRotation(self.rotation);
	self.TimeSinceLastUpdate = 0;
	self.cameraDistance = self:GetCameraDistance()

	local W = self:GetWidth()
	self:SetHitRectInsets(2*W/3, 0, 0, 0);

	AddNewModelFrame(self);
end

function NarciMainModel_OnLoad(self, maxZoom, minZoom, defaultRotation, onMouseUp)
	self:SetUnit("player");
	self.mouseDown = false;
	self.panning = false;
	self.maxZoom = maxZoom or MODELFRAME_MAX_ZOOM;
	self.minZoom = minZoom or MODELFRAME_MIN_ZOOM;
	self.defaultRotation = defaultRotation or MODELFRAME_DEFAULT_ROTATION;
	self.onMouseUpFunc = onMouseUp or NarciModel_OnMouseUp;
	self.rotation = self.defaultRotation;
	self:SetRotation(self.rotation);
	self:SetLight(true, false, - 0.44699833180028 ,  0.72403680806459 , -0.52532198881773, 1, 138/255, 138/255, 138/255, 1, 0.8, 0.8, 0.8)
	self.TimeSinceLastUpdate = 0;
	local r, g, b = 0, 177/255, 64/255;
	--local r, g, b =	0, 71/255, 187/255;
	Narci_ChromaKey:SetColorTexture(r, g, b);
	FullSceenChromaKey = Narci_ChromaKey;

	local W = self:GetWidth()
	self:SetHitRectInsets(2*W/3, 0, 0, 0);
	
	Narci_ModelFrames[1] = self;
end

local function PauseAllModel(bool)
	for i = 1, #Narci_ModelFrames do
		Narci_ModelFrames[i]:SetPaused(bool);
	end
end

local function BeginLayerCapture()
	local model = Narci_CharacterModelContainer;
	if LayersToBeCaptured == 5 then
		PauseAllModel(true);
		HidePlayer_Temp = Narci_HidePlayerButton.IsOn;
		if not HidePlayer_Temp then
			Narci_HidePlayerButton:Click();
		end
		Vignette_Temp = Narci_Model_VignetteSlider:GetValue();
		Brightness_Temp = Narci_Model_DarknessSlider:GetValue();
		Narci_Model_VignetteSlider:SetValue(0);
		Narci_Model_DarknessSlider:SetValue(0);
		Narci_Character:Hide();
		model:SetAlpha(0);
	elseif LayersToBeCaptured == 4 then
		model:SetAlpha(1);
		FullSceenChromaKey:SetColorTexture(r1, g1, b1);
		FullSceenChromaKey:Show();
		FullSceenChromaKey:SetAlpha(1);
	elseif LayersToBeCaptured == 3 then
		model:SetAlpha(1);
		FullSceenChromaKey:SetColorTexture(r2, g2, b2);
		FullSceenChromaKey:Show();
		FullSceenChromaKey:SetAlpha(1);
	elseif LayersToBeCaptured == 2 then
		model:SetAlpha(0);
		FullSceenChromaKey:Hide();
		FullSceenChromaKey:SetAlpha(0);
		ShowTextAlphaChannel(true);
		FullScreenAlphaChannel:SetAlpha(1);
		FullScreenAlphaChannel:Show();
	elseif LayersToBeCaptured == 1 then
		ShowTextAlphaChannel(false);
		FullScreenAlphaChannel:SetAlpha(1);
		FullScreenAlphaChannel:Show();
		model:SetAlpha(0);
	elseif LayersToBeCaptured == 0 then
		Narci_Model_VignetteSlider:SetValue(Vignette_Temp);
		Narci_Model_DarknessSlider:SetValue(Brightness_Temp);
		model:SetAlpha(1);
		FullScreenAlphaChannel:SetAlpha(0);
		FullScreenAlphaChannel:Hide();
		if not HidePlayer_Temp then
			Narci_HidePlayerButton:Click();
		end
		LayersToBeCaptured = -1;
		Narci_Model_CaptureButton.Value:SetText(0);
		Narci_Model_CaptureButton:Enable();
		local button = Narci_SlotLayerButton;
		button:LockHighlight();
		button.Label:SetTextColor(1, 1, 1);
		button.IsOn = true;
		PauseAllModel(false);
		return;
	else
		LayersToBeCaptured = -1;
		Narci_Model_CaptureButton.Value:SetText(0);
		Narci_Model_CaptureButton:Enable();
		PauseAllModel(false);
		return;
	end
	C_Timer.After(1, function()
	Screenshot();
	end)
	Narci_Model_CaptureButton.Value:SetText(LayersToBeCaptured);
	LayersToBeCaptured = LayersToBeCaptured - 1;
end



local function CaptureButton_Seasoned(self)
	Narci_AlertFrame_Static:Hide();
	self:Disable()
	Narci_VignetteLeft:SetAlpha(0);
	VignetteRightSmall:SetAlpha(0);
	LayersToBeCaptured = 5;
	Screenshot();
end

local function CaptureButton_Newbee(self)
	SetTutorialFrame(self, NARCI_TUTORIAL_CAPTUREBUTTON)
	self:Disable()
	C_Timer.After(2, function()
		Narci_Model_CaptureButton:Enable();
		Narci_Model_CaptureButton:SetScript("OnClick", CaptureButton_Seasoned)
	end)
end

function Narci_Model_CaptureButton_OnClick(self)
	CaptureButton_Seasoned(self)
end

function Narci_Model_CaptureButton_OnEnter(self)
	if LayersToBeCaptured == -1 then
		Narci_Model_CaptureButton.Value:SetText(5);
	end
end

function Narci_Model_CaptureButton_OnLeave(self)
	if LayersToBeCaptured == -1 then
		Narci_Model_CaptureButton.Value:SetText(0);
	end
end

local function EnableButtonTutorial(button, key, func)
	if NarcissusDB and NarcissusDB.Tutorials and NarcissusDB.Tutorials[key] then
		button:SetScript("OnClick", func);
		button.keyValue = key;
	end
end

----------------------------
--[[
/run NarciModelFrame1:SetUseTransmogSkin(false)
/run NarciModelFrame1:PlayAnimKit(false)
/run NarciModelFrame1:ApplySpellVisualKit(92719, true)82193 73393 61975 82148 Ghost
82192	Fire in Hand
82148	Ghost
73396	Light Orb in hand
/run NarciModelFrame1:MakeCurrentCameraCustom()
/dump NarciModelFrame1:GetCameraPosition()
/dump NarciModelFrame1:GetModelFileID()
/run NarciModelFrame1:SetCameraPosition(3.62,0,0)
/dump NarciModelFrame1:GetCameraTarget()
/run NarciModelFrame1:SetPortraitZoom(4)
/run NarciModelFrame1:SetBarberShopAlternateForm()
/run NarciModelFrame1:SetCustomRace(1, 1);NarciModelFrame1:MakeCurrentCameraCustom()
/run NarciModelFrame1:SetDisplayInfo(89631)
/run NarciModelFrame1:SetParticlesEnabled(bool)
/run NarciModelFrame1:Undress()
/run NarciModelFrame1:SetItem(155880)
/run NarciModelFrame1:SetItemAppearance()
/run NarciModelFrame1:SetModel("spells\\errorcube.mdx")
/run NarciModelFrame1:SetRoll(math.pi/2)
/run NarciModelFrame1:SetPitch(math.pi/4)
/dump NarciModelFrame1:GetCameraPosition()
My wow programming in a nut shell: Spending 90% of time on finding the right API
/run NarciModelFrame1:EquipItem(159653)
/run xxid=NarciModelFrame1:GetSlotTransmogSources(5);dump C_TransmogCollection.GetSourceInfo(xxid)
C_TransmogCollection.GetSourceInfo(NarciModelFrame1:GetSlotTransmogSources(5))
/run NarciModelFrame1:SetUnit("target");
104197 lighting
104488 Red Ghost
104534  Heart of Azeroth!!! 1330
/run NarciModelFrame1:SetAnimation(1330);NarciModelFrame1:ApplySpellVisualKit(104534, false)

-----------------
-------API-------
-----------------

SetShadowEffect(0~1)	--Transparent



function SM(path)
	path = tostring(path)
	path = gsub(path, "%/", "\\".."\\")
	print(path)
	NarciModelFrame1:SetModel(path)
end

function EQ(id)
	local _, itemLink = GetItemInfo(id)
	NarciModelFrame1:TryOn(itemLink)
end

function SV(id)
	NarciModelFrame1:ApplySpellVisualKit(id, true)
end
--]]

-------------------------
--Model Control Buttons--
-------------------------

local function DisablePlayButton()
	local playButton = NarciModelControl_PlayAnimationButton;
	local animationSlider = NarciModelControl_AnimationSlider;
	playButton.IsOn = false;
	playButton.Highlight:Hide();
	animationSlider:Show();
end

local function DisableIdleButton()
	Narci_Model_IdleButton.IsOn = false;
	Narci_Model_IdleButton.Highlight:Hide();
end

local function DisablePauseButton()
	local pauseButton = NarciModelControl_PauseAnimationButton;
	local animationSlider = NarciModelControl_AnimationSlider;
	pauseButton.IsOn = false;
	pauseButton.Highlight:Hide();
	animationSlider:Hide();
end

function NarciModelControl_NextAnimationButton_OnClick(self, button)
	NarciModelControl_AnimationIDEditBox:ClearFocus();
	local id = NarciModelControl_AnimationIDEditBox:GetNumber();
	local model = Narci_ModelFrames[activeModelIndex];

	if button == "LeftButton" and id < animationID_Max then
		id = id + 1;
		while (not model:HasAnimation(id) and id <animationID_Max) do
			id = id + 1
		end
	elseif button == "RightButton" and id > 0 then
		id = id - 1;
		while (not model:HasAnimation(id) and id > 0) do
			id = id - 1
		end
	end

	if self:GetParent().Pause.IsOn then
		NarciModelControl_AnimationSlider:SetValue(1);
		model:FreezeAnimation(id, 0, 1)
	else
		model:SetAnimation(id, 1)
	end

	model.animationID = id;
	DisableIdleButton()

	NarciModelControl_AnimationIDEditBox:SetNumber(id)
	Narci_AlertFrame_Static:Hide();
	--NarciModelFrame1:ApplySpellVisualKit(id, true)
end

function NarciModelControl_PlayAnimationButton_OnClick(self)
	self.IsOn = true;
	NarciModelControl_AnimationIDEditBox:ClearFocus();
	local model = Narci_ModelFrames[activeModelIndex]
	local id = NarciModelControl_AnimationIDEditBox:GetNumber();
	model:SetAnimation(id, 1)
	model:SetPaused(false)
	DisableIdleButton();
	DisablePauseButton();
end

function NarciModelControl_PauseAnimationButton_OnClick(self)
	self.IsOn = true;
	NarciModelControl_AnimationIDEditBox:ClearFocus();
	local model = Narci_ModelFrames[activeModelIndex]
	local id = NarciModelControl_AnimationIDEditBox:GetNumber();
	model:FreezeAnimation(id, 0, 1)
	DisablePlayButton();
end

function NarciModelControl_AnimationIDEditBox_OnEditFocusLost(self)
	local model = Narci_ModelFrames[activeModelIndex]
	self.Highlight:Hide();
	local animationID = math.min(self:GetNumber(), animationID_Max);
	model.animationID = animationID;
	if self:GetParent().Pause.IsOn then
		model:FreezeAnimation(animationID, 0, 1);
		NarciModelControl_AnimationSlider:SetValue(1);
	else
		model:SetAnimation(animationID, 1)
	end
	DisableIdleButton();
end

local xR, xG, xB = 1, 0, 0;		--Spot Light: red, green, blue, stauration
local xHUE = 0;
local xSAT = 0;					--Spot Light: stauration
local xBRT = 1;					--Spot Light: brightness 100%

local aHue, aSAT, aBRT = 0, 0, 0.8;
local sHue, sSAT, sBRT = 0, 0, 0.8;

local function PlayLightBling(index)
	if index == 1 then
		Narci_CharacterModelSettings.LeftView.LightColor.Bling:Play();
		Narci_CharacterModelSettings.TopView.LightColor.Bling:Play();
	else
		Narci_CharacterModelSettings.LeftView.AmbientColor.Bling:Play();
		Narci_CharacterModelSettings.TopView.AmbientColor.Bling:Play();
	end
end

function NarciModelControl_LightSwitch_OnClick(self)
	SetAmbient = not SetAmbient;
	local frame = Narci_CharacterModelSettings;
	local ColorSliders = frame.ColorSliders;
	local BAK1 = ColorSliders.HueSlider:GetValue();
	local BAK2 = ColorSliders.SaturationSlider:GetValue();
	local BAK3 = ColorSliders.BrightnessSlider:GetValue();

	if SetAmbient then
		sHue = BAK1;
		sSAT = BAK2;
		sBRT = BAK3;
		ColorSliders.HueSlider:SetValue(aHue)
		ColorSliders.SaturationSlider:SetValue(aSAT);
		ColorSliders.BrightnessSlider:SetValue(aBRT);
		PlayLightBling(2)
		self.Icon:SetTexCoord(0.25, 0.5, 0, 1);
	else
		aHue = BAK1;
		aSAT = BAK2;
		aBRT = BAK3;
		ColorSliders.HueSlider:SetValue(sHue)
		ColorSliders.SaturationSlider:SetValue(sSAT);
		ColorSliders.BrightnessSlider:SetValue(sBRT);
		PlayLightBling(1)
		self.Icon:SetTexCoord(0, 0.25, 0, 1);
	end
end

--[[
function NarciModelControl_LightSwitch_OnEnter(self)
	self.Highlight:Show();
	if SetAmbient then
		PlayLightBling(2)
	else
		PlayLightBling(1)
	end
end
--]]

function NarciModelControl_ColorPaneSwitch_OnClick(self)
	local state = self:GetParent().ColorPresets:IsShown();
	self:GetParent().ColorPresets:SetShown(not state);
	self:GetParent().ColorSliders:SetShown(state);
	if not state then
		self.Icon:SetTexCoord(0.1875, 0.25, 0.9375, 1);
		self:GetParent().ColorSliders.BrightnessSlider:SetHeight(0.001);
	else
		self.Icon:SetTexCoord(0.25, 0.3125, 0.9375, 1);
		self:GetParent().ColorSliders.BrightnessSlider:SetHeight(12);
	end
end

local function InitializeModelLight(NewModel)
	local model = Narci_ModelFrames[activeModelIndex];
	local NewModel = NewModel;
	local r, g, b = HSV2RGB(xHUE, xSAT, xBRT);
	if IsLightLinked then
		if SetAmbient then
			_, _, XdirX, XdirY, XdirZ, XambIntensity, _, _, _, XdirIntensity, XdirR, XdirG, XdirB = model:GetLight();
			NewModel:SetLight(true, false, XdirX, XdirY, XdirZ, XambIntensity, r, g, b, XdirIntensity, XdirR, XdirG, XdirB);
		else
			local r0, g0, b0;
			_, _, XdirX, XdirY, XdirZ, XambIntensity, r0, g0, b0, XdirIntensity, XdirR, XdirG, XdirB = model:GetLight();
			NewModel:SetLight(true, false, XdirX, XdirY, XdirZ, XambIntensity, r0, g0, b0, XdirIntensity, r, g, b);
		end
	end
end

local function SetModelLight()
	local model = Narci_ModelFrames[activeModelIndex];
	local r, g, b = HSV2RGB(xHUE, xSAT, xBRT);
	if IsLightLinked then
		if SetAmbient then
			_, _, XdirX, XdirY, XdirZ, XambIntensity, _, _, _, XdirIntensity, XdirR, XdirG, XdirB = model:GetLight();
			for i = 1, #Narci_ModelFrames do
				Narci_ModelFrames[i]:SetLight(true, false, XdirX, XdirY, XdirZ, XambIntensity, r, g, b, XdirIntensity, XdirR, XdirG, XdirB);
			end
		else
			local r0, g0, b0;
			_, _, XdirX, XdirY, XdirZ, XambIntensity, r0, g0, b0, XdirIntensity, XdirR, XdirG, XdirB = model:GetLight();
			for i = 1, #Narci_ModelFrames do
				Narci_ModelFrames[i]:SetLight(true, false, XdirX, XdirY, XdirZ, XambIntensity, r0, g0, b0, XdirIntensity, r, g, b);
			end
		end
	else
		if SetAmbient then
			_, _, XdirX, XdirY, XdirZ, XambIntensity, _, _, _, XdirIntensity, XdirR, XdirG, XdirB = model:GetLight();
			model:SetLight(true, false, XdirX, XdirY, XdirZ, XambIntensity, r, g, b, XdirIntensity, XdirR, XdirG, XdirB);
		else
			local r0, g0, b0;
			_, _, XdirX, XdirY, XdirZ, XambIntensity, r0, g0, b0, XdirIntensity, XdirR, XdirG, XdirB = model:GetLight();
			model:SetLight(true, false, XdirX, XdirY, XdirZ, XambIntensity, r0, g0, b0, XdirIntensity, r, g, b);
		end
	end
	SetViewerLightColor(r, g, b);
end

function NarciModelControl_HueSlider_OnValueChanged(self, value)
	if value ~= self.oldValue then
		if self:GetParent():IsShown() then
			self.Thumb:SetTexCoord(0.96875, 1, 0, 0.0625);
		end;
		self.oldValue = value;
		xHUE = value;
		
		value = value/60;
		if value <= 1 then
			xR, xG, xB = 1, value, 0;
		elseif value > 1 and value <= 2 then
			xR, xG, xB = 2 - value, 1, 0;
		elseif value > 2 and value <= 3 then
			xR, xG, xB = 0, 1, value - 2;
		elseif value > 3 and value <= 4 then
			xR, xG, xB = 0, 4 - value, 1;
		elseif value > 4 and value <= 5 then
			xR, xG, xB = value - 4, 0, 1;
		else
			xR, xG, xB = 1, 0, 6 - value;
		end
		

		NarciModelControl_SaturationSlider.Color:SetGradient("HORIZONTAL", 1, 1, 1, xR, xG, xB);
		NarciModelControl_BrightnessSlider.Color:SetGradient("HORIZONTAL", 0, 0, 0, xR + (1-xSAT), xG + (1-xSAT), xB + (1-xSAT));

		SetModelLight();
    end
end

function NarciModelControl_SaturationSlider_OnValueChanged(self, value)
	if value ~= self.oldValue then
		if self:GetParent():IsShown() then
			self.Thumb:SetTexCoord(0.96875, 1, 0.0625, 0);
		end
		self.oldValue = value;
		xSAT = value;

		NarciModelControl_BrightnessSlider.Color:SetGradient("HORIZONTAL", 0, 0, 0, xR + (1-xSAT), xG + (1-xSAT), xB + (1-xSAT));

		SetModelLight();
	end
end

function NarciModelControl_BrightnessSlider_OnValueChanged(self, value)
	if value ~= self.oldValue then
		if self:GetParent():IsShown() then
			self.Thumb:SetTexCoord(0.96875, 1, 0.0625, 0.125);
		end
		self.oldValue = value;
		xBRT = value;

		SetModelLight();
	end
end

------------------------------------------------------------
------------------------Actor Panel-------------------------
--Race/gender change, Active Model, Synchronize light/size--
------------------------------------------------------------
local RaceList = {
	1, 3, 4, 7, 11, 22,
	29, 30, 34, 32, -1, 24,
	2, 5, 6, 8, 10, 9,
	27, 28, 36, 31, -1, 24,
};

local function InitializeRaceName()
	local GetRaceInfo = C_CreatureInfo.GetRaceInfo;
	local name;
	local length, max, index = 0, 0, 1;
	for i = 1, #RaceList do
		name = GetRaceInfo(RaceList[i]).raceName
		RaceList[i] = name;
		length = (name and strlen(name)) or 0
		if length >= max then
			max = length
			index = i;
		end
		print(RaceList[i].." "..length)
	end
	print("\""..RaceList[index].."\" is the longest.")
end

local function AjustCamera(model)
	model.cameraDistance = model:GetCameraDistance();
	model:MakeCurrentCameraCustom();
	if not IsScaleLinked then
		model.cameraDistance = model:GetCameraDistance();
	end
	if not model:HasCustomCamera() then return; end;
	SmoothZoomModel(model.cameraDistance);
end

local function SwitchPortrait(index, update)
	local Portraits = Narci_ActorPanel.PortraitFrame;
	local portrait = Portraits["Portrait"..index];
	for i = 1, 5 do
		Portraits["Portrait"..i]:Hide();
	end
	if update then
		SetPortraitTexture(portrait, "target");
	end
	portrait:Show();
end

local function ModelIndexButton_ResetReposition()
	--Reset Model Index Buttons' position--
	IndexButtonPosition = {
		1, 2, 3, 4, 5,
	}
	local buttons = Narci_ActorPanel.ExtraPanel.buttons;
	local relativeTo = Narci_ActorPanel.ExtraPanel.ReferenceFrame;
	local offset;
	for i = 1, #buttons do
		local button = buttons[i];
		button.order = i;
		offset = (button.order - 1) * 24;	--button width = 24
		buttons[i]:ClearAllPoints();
		buttons[i]:SetPoint("LEFT", relativeTo, "LEFT", offset, 0);
	end
end

local function ResetIndexButton()
	local buttons = Narci_ActorPanel.ExtraPanel.buttons;
	local button = buttons[1];
	button.HasModel = true;
	button.HiddenModel = false;
	button.order = 1;
	button.Highlight:Show();
	button.IsOn = true;
	button.ID:SetShadowColor(1, 1, 1);
	button.ID:SetTextColor(0, 0, 0);
	button.ID:Show();
	button.Icon:Hide();
	button.Icon:SetTexCoord(0, 0.25, 0, 1);
	for i=2, #buttons do
		button = buttons[i];
		button.ID:Hide();
		button.Icon:SetTexCoord(0, 0.25, 0, 1);
		button.Icon:Show();
		button:Hide();
		button.HasModel = false;
		button.HiddenModel = false;
		button.IsOn = false;
		button.Highlight:Hide();
		button.order = i;
	end

	buttons[2]:Show();
	SwitchPortrait(1);
	UpdateActorName(1);
	ModelIndexButton_ResetReposition();
end

local function ExitGroupPhoto()
	local model = NarciModelFrame1;
	model:EnableMouse(true);
	model:EnableMouseWheel(true);
	model.GroundShadow:EnableMouse(true);
	
	local panel = Narci_ActorPanel;
	panel.ExpandButton:Show();
	panel.ExpandButton:SetAlpha(1);
	panel.ExtraPanel:Hide();
	panel.Background:SetTexCoord(0, 0.8125, 0.4375, 0.65625);

	for i = 1, #Narci_ModelFrames do
		Narci_ModelFrames[i].GroundShadow.ManuallyHidden = false;
	end
end

function Narci_CharacterModelSettings_OnHide(self)
	self:SetAlpha(0);
	ResetIndexButton();
	ExitGroupPhoto();
	RestorePlayerInfo(1);
	self:ClearAllPoints();
	self:SetPoint("BOTTOM", VirtualLineRightCenter, "BOTTOM", -10 , 40);
	self:SetUserPlaced(false);
end

local function ShowIndexButtonLabel(self, bool)
	self.Label:SetShown(bool);
	self.Status:SetShown(bool);
	self.LabelColor:SetShown(bool);
end

function Narci_ModelIndexButton_OnClick(self)
	--Functionality
	local unit = "target";
	local ID = self:GetID();
	local playBling = true;
	local model = _G["NarciModelFrame"..ID];
	local buttons = self:GetParent().buttons

	if not self.HasModel then
		if UnitExists(unit) and UnitIsPlayer(unit) then
			if not model then
				model = CreateFrame("DressUpModel", "NarciModelFrame"..ID, Narci_CharacterModelContainer, "Narci_CharacterModelFrame_Template");
				model:SetFrameLevel(10 - ID);
			end
			SwitchPortrait(ID, true);
			model:SetUnit(unit);
			UpdateModel(unit);
			AjustCamera(model);
			InitializeModelLight(model);
			InitializePlayerInfo(ID, unit);
			self.HasModel = true;
			playBling = false;

			if buttons[ID + 1] then
				buttons[ID + 1]:Show();
			end
		else
			SetAlertFrame(self, NARCI_GROUP_PHOTO_NOTIFICATION, -24);
			return;
		end
	end

	--Visual
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	for i=1, #buttons do
		if i ~= ID then
			buttons[i].Highlight:Hide();
			buttons[i].IsOn = false;
			buttons[i].ID:SetShadowColor(0, 0, 0);
			buttons[i].ID:SetTextColor(0.25, 0.78, 0.92);
		end
	end
	self.Highlight:Show();
	self.ID:SetShadowColor(1, 1, 1);
	self.ID:SetTextColor(0, 0, 0);
	self.ID:Show();
	self.Icon:Hide();

	SwitchPortrait(ID);
	UpdateActorName(ID);
	SetGenderIcon(playerInfo[ID].gender);
	
	if self.IsOn then
		--Clicking a index button which has been selected earlier will hide the model temporarily--
		local state = not (model and model:IsMouseEnabled());
		model:EnableMouse(state);
		model:EnableMouseWheel(state);
		if state and (not model.GroundShadow.ManuallyHidden) then
			model.GroundShadow:SetShown(true);
		end

		if state then
			model:SetAlpha(1);
			self.ID:Show();
			self.Icon:Hide();
			self.Icon:SetTexCoord(0, 0.25, 0, 1);
			self.HiddenModel = false;
		else
			model:SetAlpha(0);
			self.ID:Hide();
			self.Icon:SetTexCoord(0.5, 0.75, 0, 1);
			self.Icon:Show();
			self.HiddenModel = true;

		end
		if self.HiddenModel then
			self.Status:SetText(NARCI_GROUP_PHOTO_STATUS_HIDDEN)
		else
			self.Status:SetText(nil);
		end
		return;
	else
		if model then
			if playBling then
				UIFrameFadeOut(model, 0.25, model:GetAlpha(), 0);
				C_Timer.After(0.25, function()
					UIFrameFadeIn(model, 0.25, 0, 1);
				end)
			else
				UIFrameFadeIn(model, 0.25, 0, 1);
			end
		end
	end

	SetActiveModel(ID);
	UpdateGroundShadowOption();
	self.IsOn = true;
	self.Status:SetText(nil);
end

function Narci_ModelIndexButton_OnEnter(self)
	self.Highlight:Show();
	if self.HasModel and not self:GetParent().UpdateFrame:IsShown() then
		if self.HiddenModel then
			self.Status:SetText(NARCI_GROUP_PHOTO_STATUS_HIDDEN);
		else
			self.Status:SetText(nil);
		end
		ShowIndexButtonLabel(self, true);
	end
end

local function Narci_ModelIndexButton_ShowSelfLabelAndHideOthers(self)
	local buttons = self:GetParent().buttons;
	local button;
	for i = 1, #buttons do
		button = buttons[i];
		ShowIndexButtonLabel(button, false);
	end
	ShowIndexButtonLabel(self, true);
end

function Narci_ModelIndexButton_OnDragStart(self)
	if not self.HasModel then return; end;
	self:SetFrameLevel(22);
	self:GetParent().ReferenceFrame.Label:SetText(NARCI_GROUP_PHOTO_FRONT);
	self.LockHighlight = true;
	local UpdateFrame = self:GetParent().UpdateFrame;
	UpdateFrame.ActiveButton = self:GetID();
	UpdateFrame:Show();
	Narci_ModelIndexButton_ShowSelfLabelAndHideOthers(self);
end

function Narci_ModelIndexButton_OnDragStop(self)
	self:SetFrameLevel(21);
	self:GetParent().ReferenceFrame.Label:SetText(NARCI_GROUP_PHOTO_INDEX);
	self:GetParent().UpdateFrame:Hide();
	if not self.HasModel then return; end;
	local _, _, _, offset = self:GetPoint();
	offset = tonumber(offset) - 12;
	local AnimFrame = self.AnimFrame;
	AnimFrame.StartX = offset;
	AnimFrame.duration = math.max(0.05, math.abs(offset - AnimFrame.EndX) / 65);
	--print("Anim Duration(s) = "..AnimFrame.duration)
	self.ID:SetPoint("CENTER", 0, 0);
	self.LockHighlight = false;
	if not self.IsOn then
		self.Highlight:Hide();
	end

	if not self:IsMouseOver() then
		ShowIndexButtonLabel(self, false);
	end
end

local function CopyTable(table)
	if not table then return; end;
	local newTable = {};
	for i = 1, #table do
		newTable[i] = table[i];
	end
	return newTable;
end

local function UpdateButtonOrder(button, newOrder)
	local buttons = Narci_ActorPanel.ExtraPanel.buttons;
	local buttonID = button:GetID();
	local orderTable = {};
	for i = 1, #IndexButtonPosition do
		if IndexButtonPosition[i] == buttonID then
			IndexButtonPosition[i] = false;
		end
	end
	local a = 1;
	for i = 1, #IndexButtonPosition do
		if IndexButtonPosition[i] then
			if a == newOrder then
				a = a + 1;
			end
			orderTable[a] = IndexButtonPosition[i];
			a = a + 1;
		end
	end
	orderTable[newOrder] = buttonID;

	--[[
	local str = "";
	for i = 1, 5 do
		if orderTable[i] then
			str = str..orderTable[i].." ";
		else
			return;
		end
	end
	print(str);
	--]]
	
	return orderTable;
end

function Narci_ModelIndexButton_AnimFrame_OnUpdate(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
	local value = outSine(self.TimeSinceLastUpdate, self.StartX, self.EndX - self.StartX, self.duration) --0.11 NE
	
	self:GetParent():SetPoint("LEFT", self.relativeTo, "LEFT", value, 0);
	if self.TimeSinceLastUpdate >= self.duration then
		self:Hide();
	end
end

local function AssignOrder(orderTable)
	--Replace Index Button (transition animation)--
	if not orderTable then return; end;
	local buttons = Narci_ActorPanel.ExtraPanel.buttons;
	local button, buttonID, model;
	local relativeTo = Narci_ActorPanel.ExtraPanel.ReferenceFrame;
	local offset;
	for i = 1, #orderTable do
		buttonID = orderTable[i];
		button = buttons[buttonID];
		model = Narci_ModelFrames[buttonID];
		if model then
			model:SetFrameLevel(10 - i);
		end
		offset = 24*(i - 1);
		button.AnimFrame:Hide();
		button.AnimFrame.EndX = 24*(i - 1);
		button.AnimFrame:Show();
	end
end

function Narci_ModelIndexButton_RepositionFrame_OnUpdate(self)
	--drag an index button to replace model's framelevel--
	local scale = UIParent:GetEffectiveScale();
	local xpos, _ = GetCursorPosition();
	xpos = xpos;
	local buttons = self:GetParent().buttons;
	local ofsx, order;
	if xpos <= self.xmin then
		ofsx = 0 + 12;
	elseif xpos >= self.xmax then
		ofsx = 4 * 24 + 12;
	else
		ofsx = (xpos - self.x0);
	end

	local button = buttons[self.ActiveButton];
	for i = 1, 5 do
		if ofsx > 24*(i - 1) and ofsx <= 24*i then
			if self.order ~= i then
				self.order = i;
				self.orderTable = UpdateButtonOrder(button, self.order);
				AssignOrder(self.orderTable);
			end
			break;
		end
	end

	--print(ofsx);
	button:ClearAllPoints();
	button:SetPoint("CENTER", self.ref, "LEFT", ofsx, 0);
end

function Narci_ModelIndexButton_RepositionFrame_OnHide(self)
	IndexButtonPosition = CopyTable(self.orderTable) or IndexButtonPosition;
	AssignOrder(IndexButtonPosition);
end

function Narci_DeleteModelButton_OnClick(self)
	local ID = activeModelIndex;
	local buttons = Narci_ActorPanel.ExtraPanel.buttons;
	local button = buttons[ID]; 
	local model = Narci_ModelFrames[ID];
	model:ClearModel();
	if ID ~= 1 then
		model:Hide();
	end
	button.HasModel = false;
	button.IsOn = false;
	button.Icon:SetTexCoord(0, 0.25, 0, 1);
	button.Icon:Show();
	button.ID:Hide();
	button.Highlight:Hide();
	for i = ID - 1, 1, -1 do
		if buttons[i].HasModel then
			buttons[i]:Click();
			return;
		end
	end
	for i = ID + 1, #buttons do
		if buttons[i].HasModel then
			buttons[i]:Click();
			return;
		end
	end
end

function Narci_GenderButton_OnLoad(self)
	local _, genderID = GetUnitRaceIDAndSex("player");
	SetGenderIcon(genderID)
end

function Narci_GenderButton_OnClick(self)
	local index = activeModelIndex;
	local model = Narci_ModelFrames[activeModelIndex];
	local genderID = playerInfo[index].gender or 2;
	
	if genderID == 2 then
		model:SetCustomRace(playerInfo[index].raceID, 1);
		playerInfo[index].gender = 3;
	elseif genderID == 3 then
		model:SetCustomRace(playerInfo[index].raceID, 0);
		playerInfo[index].gender = 2;
	end
	model:MakeCurrentCameraCustom();
	SetGenderIcon(playerInfo[index].gender);
	AjustCamera(model);
end

local AutoCloseTimer2 = C_Timer.NewTimer(0, function()	end)
local function AutoCloseRaceOption(time)
	AutoCloseTimer2:Cancel();
	AutoCloseTimer2 = C_Timer.NewTimer(time, function()
		if NarciModelControl_ActorButton.IsOn then
			NarciModelControl_ActorButton:Click();
		end
	end)
end

function Narci_RaceOptionButton_OnEnter(self)
	self.Highlight:Show();
	AutoCloseTimer2:Cancel();
end

function Narci_RaceOptionButton_OnLeave(self)
	self.Highlight:Hide();
	AutoCloseRaceOption(2);
end

function Narci_RaceOptionButton_OnClick(self)
	AutoCloseTimer2:Cancel();
	local model = Narci_ModelFrames[activeModelIndex];
	local genderID = playerInfo[activeModelIndex].gender;
	local raceID = self:GetID() or 1;
	playerInfo[activeModelIndex].raceID = raceID;
	if genderID == 2 then
		model:SetCustomRace(raceID, 0);
	else
		model:SetCustomRace(raceID, 1);
	end
	AutoCloseRaceOption(4);
	
	C_Timer.After(0.2, function()
		AjustCamera(model);
	end);
end

function Narci_ActorPanelExpandButton_OnClick(self)
	ResetIndexButton();
	FadeFrame(self, 0.25, "OUT");
	FadeFrame(self:GetParent().ExtraPanel, 0.2, "Forced_IN");
	self:GetParent().Background:SetTexCoord(0, 0.8125, 0, 0.21875);
	if Narci_SlotLayerButton.IsOn then
		Narci_SlotLayerButton:Click();
	end
	if not Narci_GroundShadowOption.IsOn then
		Narci_GroundShadowOption:Click();
	end
end

function Narci_LinkLightButton_OnClick(self)
	self.IsOn = not self.IsOn;
	IsLightLinked = self.IsOn;
	HighlightButton(self, self.IsOn);
end

function Narci_LinkScaleButton_OnClick(self)
	self.IsOn = not self.IsOn;
	IsScaleLinked = self.IsOn;
	HighlightButton(self, self.IsOn);
end

function Narci_ActorButton_OnClick(self)
	self.IsOn = not self.IsOn;
	if self.IsOn then
		self:LockHighlight();
		FadeFrame(Narci_RaceOptionFrame, 0.2, "IN");
		AutoCloseRaceOption(4);
	else
		self:UnlockHighlight();
		FadeFrame(Narci_RaceOptionFrame, 0.2, "OUT");
	end
end

local function HideGroundShadowControl()
	local model;
	for i = 1, #Narci_ModelFrames do
		model = Narci_ModelFrames[i];
		if model then
			model.GroundShadow.Border:Hide();
		end
	end
end

function Narci_CharacterModelSettings_OnEnter(self)
	HideGroundShadowControl();
	UIFrameFadeIn(self:GetParent(), 0.2, self:GetParent():GetAlpha(), 1);
end

function Narci_GroundShadowOption_ResetButton_OnClick(self)
	local frame = Narci_ModelFrames[activeModelIndex].GroundShadow;
	frame:ClearAllPoints();
	frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0 ,0);
	frame:SetUserPlaced(false);
	frame.Border.SizeSlider:SetValue(1);
	frame.Border.AlphaSlider:SetValue(1);
end

function Narci_GroundShadowOption_OnHide(self)
	HideGroundShadowControl();
	self.IsOn = false;
	self:UnlockHighlight();
	self.Label:SetTextColor(0.6, 0.6, 0.6);
end

function Narci_GroundShadowOption_OnClick(self)
	local frame = Narci_ModelFrames[activeModelIndex].GroundShadow;
	local state = not frame:IsShown();
	frame:SetShown(state);
	frame.ManuallyHidden = not state;
	self.IsOn = state;
	HighlightButton(self, state);
end

local function CreateRaceButtonList(self, buttonTemplate, buttonNameTable, numRow)
	local button, buttonWidth, buttonHeight;
	local buttons, columnWidth = {}, {};
	local parentName = self:GetName();
	local buttonName = parentName and (parentName .. "Button") or nil;
	local minWidth, maxWidth = 80, 0;
	local GetRaceInfo = C_CreatureInfo.GetRaceInfo;
	local _, _, playerRaceID = UnitRace("player");
	playerRaceID = playerRaceID or -1;
	local column = 1;

	local insetFrame = self.Inset;
	local initialPoint = initialPoint or "TOPLEFT";
    local initialRelative = initialRelative or "TOPLEFT";
    local initialOffsetX = initialOffsetX or 0;
    local initialOffsetY = initialOffsetY or 0;
	local point = point or "TOPLEFT";
	local relativePoint = relativePoint or "BOTTOMLEFT";
	local offsetX = offsetX or 0;
	local offsetY = offsetY or 0;

	local numButtons = #buttonNameTable;
	local totalHeight = 0;
	numRow = numRow or numButtons;
	
	local value;
	for i = 1, numButtons do
		button = CreateFrame("BUTTON", buttonName and (buttonName .. i) or nil, self, buttonTemplate);
		value = buttonNameTable[i]
		
		if value ~= -1 then
			button:SetID(value);
			button.Name:SetText(GetRaceInfo(value).raceName);
			if value == playerRaceID then
				button.Name:SetTextColor(0.25, 0.78, 0.92);
				--highlight the original race
			end
		else
			--Create placeholder
			button.Name:SetText("")
			button:Disable();
		end

		if i == 1 then
			button:SetPoint(initialPoint, insetFrame, initialRelative, initialOffsetX, initialOffsetY);
			buttonHeight = button:GetHeight();
			totalHeight = buttonHeight * numRow;
		else
			if i % numRow == 1 then
				button:SetPoint(point, buttons[i- numRow], "TOPRIGHT", offsetX, offsetY);
				column = column + 1;
				maxWidth = 0;
				--Create divider
				local tex = self:CreateTexture(nil, "OVERLAY", nil, 1);
				tex:SetSize(0.5, 0);
				tex:SetColorTexture(1, 1, 1, 0.15);
				tex:SetPoint("TOP", button, "TOPLEFT", 0, -2);
				tex:SetPoint("BOTTOM", insetFrame, "BOTTOM", 0, 2);

				if (column - 1) % 2 == 1 then
					tex = self:CreateTexture(nil, "ARTWORK", nil, 1);
					tex:SetSize(totalHeight + 22, totalHeight + 22);
					tex:SetPoint("TOPRIGHT", button, "TOPRIGHT", 5, 12);
					--tex:SetWidth(totalHeight - 10);
					tex:SetTexture("Interface/AddOns/Narcissus/Art/Widgets/LightSetup/FactionEmblems.tga")
					tex:SetAlpha(0.15);
					if column == 2 then
						tex:SetTexCoord(0, 0.5, 0, 1);
					elseif column == 4 then
						tex:SetTexCoord(0.5, 1, 0, 1);
					end
				end
			else
				button:SetPoint(point, buttons[i- 1], relativePoint, offsetX, offsetY);
				button:SetPoint("TOPRIGHT", buttons[i- 1], "TOPRIGHT", 0, 0);
			end
		end

		if column < 3 then
			--Alliance blue
			button.Background:SetColorTexture(10/255, 40/255, 120/255, 0.2);
		else
			--Horde red
			button.Background:SetColorTexture(120/255, 27/255, 27/255, 0.2);
		end

		buttonWidth = button.Name:GetWidth();
		if buttonWidth > maxWidth then
			maxWidth = buttonWidth;
		end

		columnWidth[column] = math.max(minWidth, math.floor(maxWidth + 0.5 + 16));

		tinsert(buttons, button);
	end

	local totalWidth = 0;
	for i = 1, column do
		--Resize Button
		buttons[(i-1)*numRow + 1]:SetWidth(columnWidth[i]);
		totalWidth = totalWidth + columnWidth[i];
	end

	self:SetSize(totalWidth + 10, numRow*buttonHeight + 10)
	self.buttons = buttons;
end

local function CacheModel()
	local model = NarciModelFrame1;
	model:SetUnit("player");
	UIFrameFadeIn(model, 0.4, 0.01, 0);
	model:Show();
	model:SetPosition(0, -1000, -2200)
	model:EnableMouse(false)
	model:EnableMouseWheel(false)
	C_Timer.After(0.5, function()
		model:Hide();
		model:EnableMouse(true);
		model:EnableMouseWheel(true);
		model:SetScript("OnShow", Narci_CharacterModelFrame_OnShow);
	end)
end
----------------------------------------------------
local ScreenshotListener = CreateFrame("Frame");
ScreenshotListener:RegisterEvent("SCREENSHOT_STARTED")
ScreenshotListener:RegisterEvent("SCREENSHOT_SUCCEEDED")
ScreenshotListener:RegisterEvent("VARIABLES_LOADED");
ScreenshotListener:SetScript("OnEvent",function(self,event,...)
	if event == "SCREENSHOT_STARTED" then
		Alpha_Temp1 = PhotoModeController:GetAlpha();
		Alpha_Temp2 = Narci_CharacterModelSettings:GetAlpha();
		PhotoModeController:SetAlpha(0);
		Narci_CharacterModelSettings:SetAlpha(0);
	elseif event == "SCREENSHOT_SUCCEEDED" then
		PhotoModeController:SetAlpha(Alpha_Temp1);
		Narci_CharacterModelSettings:SetAlpha(Alpha_Temp2);
		if LayersToBeCaptured >= 0  then
			C_Timer.After(1.5, function()
				BeginLayerCapture();
			end)
		end
	elseif event == "VARIABLES_LOADED" then
		EnableButtonTutorial(Narci_Model_CaptureButton, "CaptureButton", CaptureButton_Newbee);
		EnableButtonTutorial(NarciModelControl_NextAnimationButton, "NextAnimationButton", NextAnimationButton_Newbee);
		EnableButtonTutorial(Narci_PlayerModelLayerButton, "PlayerModelLayerButton", PlayerModelLayerButton_Newbee);
		ModelIndexButton_ResetReposition();
		InitializePlayerInfo(1);
		UpdateActorName(1);
		CreateRaceButtonList(Narci_RaceOptionFrame, "Narci_RaceOptionButton_Template", RaceList, 6);
		self:UnregisterEvent("VARIABLES_LOADED")
		C_Timer.After(1, function()
			CacheModel();
		end)
	end
end)
--[[
hooksecurefunc("ShowUIPanel", function(name)
	if name == "DressUpFrame" then
		StaticPopup_Hide("EXPERIMENTAL_CVAR_WARNING");
	end
end)
 0.65*255, 0.45*255, 0.7*255
/run NarciModelFrame2:SetLight(true, false,  -0.72699833180028 ,  0.056403680806459 , -0.707532198881773, 0.6, 0.65, 0.45, 0.7, 1, 1, 1, 0.8);
/run NarciModelFrame1:EnableMouse(false)
/dump NarciModelFrame1:GetLight();
/run NarciModelFrame2:SetAnimation(1242)
/run NarciModelFrame2:EnableMouse(false)
/run CreateFrame("DressUpModel", "NarciModelFrame2", nil, "Narci_CharacterModelFrame_Template")
/run SetActiveModel(2)
/dump NarciModelFrame2:HasCustomCamera()
/run NarciModelFrame2.GroundShadow:Show()
/dump NarciModelFrame1:GetKeepModelOnHide()


function PrintIcon(id)
	print("|T"..id..":18:18:0:0:64:64:4:60:4:60|t")
end
--]]