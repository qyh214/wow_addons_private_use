--[[
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.
--]]

--Settings storaged in NarcissusDB
local Current_Version = 10051;	--last: 50
local Irrelevant_Attribute_Alpha = 0.5;
local slotTable = {};
local statTable = {};
local statTable_Short = {};
local L = Narci.L;
local VignetteAlpha = 0.8;
local GlobalScale = 0.8;
local FrameGap = 1/60;										-- 1 / FrameRate
local OpenViaClick = false;									--Addon was opened by clicking
local TransmogMode = false;
local hasSet = false;										--Save View#4 for switching between Xmog layout mode --useless maybe removed in the future
local Format_Digit = "%.2f";
local xmogMode = 0;											-- 0 off	1 "Texts Only" 	2 "Texts & Model"
local ItemName_DefaultHeight = 10;

local EnchantableSlotID = {9, 10, 11, 12, 16, 17}			--9~Wrist 10~Hands Enchanter only
local GetItemEnchant = NarciAPI_GetItemEnchant;				--Bridge/ItemAPIs.lua
local EnchantInfo = Narci_EnchantInfo;						--Bridge/GearBonus.lua
local FormatLargeNumbers = NarciAPI_FormatLargeNumbers;
local BreakUpLargeNumbers = BreakUpLargeNumbers;
local IsHeritageArmor = NarciAPI_IsHeritageArmor;
local IsSpecialItem = NarciAPI_IsSpecialItem;
local Narci_GetPrimaryStatusName = NarciAPI_GetPrimaryStatusName;
local Narci_LetterboxAnimation = NarciAPI_LetterboxAnimation;
local IsItemSocketable = NarciAPI_IsItemSocketable;
local GetItemExtraEffect = NarciAPI_GetItemExtraEffect;

local sin = math.sin
local cos = math.cos
local pow = math.pow
local pi = math.pi
local max = math.max
local ltrim = string.trim;

local UIFrameFadeIn = UIFrameFadeIn;
local UIFrameFadeOut = UIFrameFadeOut;
local FadeFrame = NarciAPI_FadeFrame;
local UIParent = _G.UIParent

function PlaceHolderFeature_OnLoad(self)
	self.tooltipHeadline = "Button-PH";
	self.tooltipLineOpen = "Placeholder: RP addon support, player statistics";
	self.tooltipSpecial = "ETA: N/A"
end



hooksecurefunc("StaticPopup_Show", function(name)
	if name == "EXPERIMENTAL_CVAR_WARNING" then
		StaticPopup_Hide("EXPERIMENTAL_CVAR_WARNING");
	end
end)

function SetFrameScale_OnLoad(self)
	self:SetScale(GlobalScale);												--Scale Customization
end

function Narci_Pref_SetFrameScale(scale)
	local scale = tonumber(scale) or 1;

	PhotoModeController:SetScale(scale);
	Narci_Character:SetScale(scale);
	Narci_Attribute:SetScale(scale);

	if NarcissusDB then
		NarcissusDB.GlobalScale = scale
	end
end

function Narci_Pref_SetVignetteStrength()
	local alpha = tonumber(NarcissusDB.VignetteStrength) or 0.8;
	VignetteAlpha = alpha;
	Narci_Vignette.VignetteLeft:SetAlpha(VignetteAlpha);
	Narci_Vignette.VignetteRight:SetAlpha(VignetteAlpha);
	Narci_Vignette.VignetteRightSmall:SetAlpha(VignetteAlpha);
	ModelVignetteRightSmall:SetAlpha(VignetteAlpha);
end

local ACL = CreateFrame("Frame", "Narci_CharacterListener");

--[[
local TakenOutFrames = {
	[1] = GameTooltip, 					--TOOLTTIP
	[2] = AzeriteEmpoweredItemUI, 		--
	[3] = ItemSocketingFrame,			--
	[4] = ArtifactFrame,				--
}
--]]

local function TakeOutFromUIParent(frame, FrameStrata, bool) --take out Gametooltip and other frames from UIParent, so they will still be visible when UI is hidden
	local UIScale = UIParent:GetEffectiveScale()

	FrameStrata = FrameStrata or "MEDIUM";

	if frame then
		if bool == true then
			frame:SetParent(nil);
			frame:SetFrameStrata(FrameStrata);
			frame:SetScale(UIScale);
		elseif bool == false or nil then
			frame:SetScale(1);
			frame:SetParent(UIParent);
			frame:SetFrameStrata(FrameStrata);
		end
	end
end

local function ForceTooltipToShow()
	TakeOutFromUIParent(GameTooltip, "TOOLTIP", true);
end

function ShowButtonTooltip(self)
	ForceTooltipToShow()

	GameTooltip:SetOwner(self, "ANCHOR_NONE");

	if not self.tooltipHeadline then
		return
	end

	GameTooltip:SetText(self.tooltipHeadline);
	if self.IsOn then
		GameTooltip:AddLine(self.tooltipLineClose, 1, 1, 1, true);
	else
		GameTooltip:AddLine(self.tooltipLineOpen, 1 ,1 ,1 ,true);
	end

	if self.tooltipSpecial then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(self.tooltipSpecial, 0.25, 0.78, 0.92, true);
	end

	GameTooltip:SetPoint("BOTTOMLEFT",self,"TOP", -2, 4)
	GameTooltip:Show();	
end

function HideButtonTooltip()
	GameTooltip:Hide();	
	GameTooltip:SetParent(UIParent);
	GameTooltip:SetFrameStrata("TOOLTIP");
	GameTooltip:SetScale(1);
end

--[[
Workflow: (RP Addon) TotalRP

	MainMenuBar
	PlayerFrame
	TargetFrame

local sources = WardrobeCollectionFrame_GetSortedAppearanceSources(self.visualInfo.visualID);

/console test_cameraOverShoulder 

--]]
-- For all easing functions:
-- t = elapsed time
-- b = begin
-- c = change == ending - beginning
-- d = duration (total time)

--[[ LibEasing
--
-- Original Lua implementations
-- from 'EmmanuelOga'
-- https://github.com/EmmanuelOga/easing/
--
-- Adapted from
-- Tweener's easing functions (Penner's Easing Equations)
-- and http://code.google.com/p/tweener/ (jstweener javascript version)
--

Disclaimer for Robert Penner's Easing Equations license:

TERMS OF USE - EASING EQUATIONS

Open source under the BSD License.

Copyright © 2001 Robert Penner
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of the author nor the names of contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
local function outSine(t, b, c, d)
	return c * sin(t / d * (pi / 2)) + b
end

local function inOutSine(t, b, c, d)
	return -c / 2 * (cos(pi * t / d) - 1) + b
end

--------------------------------
local UIPA = CreateFrame("Frame", "Narci_UIParentAlphaAnimation");
UIPA:Hide()
UIPA.TimeSinceLastUpdate = 0;
UIPA.TotalTime = 0;
local function UIParent_AnimIn(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
	self.TotalTime = self.TotalTime + elapsed;
	if self.TimeSinceLastUpdate < 0.08 then
		return;
	else
		self.TimeSinceLastUpdate = 0;
	end

	local t = 0.5;
	local EndAlpha = 0;
	local StartAlpha = self.StartAlpha;
	--local alpha = outSine(self.TotalTime, StartAlpha, EndAlpha - StartAlpha, t) --0.11 NE
	local alpha = 1 - 2*(self.TotalTime)
	UIParent:SetAlpha(alpha)

	if self.TotalTime >= t then
		UIParent:SetAlpha(EndAlpha)
		self:Hide();
	end

	--print(self.TimeSinceLastUpdate)
end


UIPA:SetScript("OnShow", function(self)
	self.StartAlpha = UIParent:GetAlpha();
end);
UIPA:SetScript("OnUpdate", UIParent_AnimIn);
UIPA:SetScript("OnHide", function(self)
	self.TimeSinceLastUpdate = 0
	self.TotalTime = 0;
end);


--------------------------------
-------Backup Camera Cvar-------
--------------------------------
ConsoleExec( "pitchlimit 88")
CVar_Temp = {};
--CVar_Temp.YawSpeed = GetCVar("cameraYawMoveSpeed");							--Discarded due to new method
CVar_Temp.OverShoulder = GetCVar("test_cameraOverShoulder");
CVar_Temp.ActioncamState = tonumber(GetCVar("test_cameraDynamicPitch"));		--No CVar directly shows the current state of ActionCam. Check this CVar for the moment. 1~On  2~Off
CVar_Temp.MusicVolume = GetCVar("Sound_MusicVolume");
CVar_Temp.ZoomLevel = 2;

local ZoomFactor = {};
ZoomFactor.Time = 1.5;			--1.5 outSine
--ZoomFactor.Amplifier = 0.65; 	--0.65
ZoomFactor.EndSpeedBasic = 0.004;	--yawmovespeed 180
ZoomFactor.StartSpeedBasic = 1.0;	--yawmovespeed 180
ZoomFactor.EndSpeed = 0.005;	--yawmovespeed 180
ZoomFactor.StartSpeed = 1.0;	--yawmovespeed 180 outSine 1.4 
ZoomFactor.SpeedFactor = 180/GetCVar("cameraYawMoveSpeed");
ZoomFactor.Goal = 2.5; --2.5 with dynamic pitch

local ZoomValuebyRaceID = {
	--[raceID] = {ZoomValue, factor1, factor2, ZoomValue for XmogMode},
	[0] = {[2] = {2.1, 0.361, 0.1654, 4},},		--Default Value

	[1] = {[2] = {2.1, 0.3283, 0.02, 4},		--1 Human √
		   [3] = {2.0, 0.38, -0.0311, 3.6}},

	[2] = {[2] = {2.4, 0.2667, 0.1233, 5.2},	--2 Orc √
		   [3] = {2.1, 0.3045, 0.0483, 5}},

	[3] = {[2] = {2.0, 0.2667, 0.0267, 3.6},	--3 Dwarf √
		   [3] = {1.8, 0.3533, 0.02, 3.6}},

	[4] = {[2] = {2.1, 0.30, 0.0404, 5},		--4 NE √
		   [3] = {2.1, 0.329, -0.025, 4.6}},

	[5] = {[2] = {2.1, 0.3537, 0.15, 4.2},		--5 UD √
		   [3] = {2.0, 0.3447, -0.03, 3.6}},

	[6] = {[2] = {4.5, 0.2027, 0.18, 5.5},		--6 Tauren Male √
		   [3] = {3.0, 0.2427, 0.1867, 5.5}},

	[7] = {[2] = {2.1, 0.329, -0.0517, 4},		--7 Gnome √
		   [3] = {2.1, 0.329, 0.012, 3.6}},

	[8] = {[2] = {2.1, 0.2787, -0.04, 5.2},		--8 Troll √
		   [3] = {2.1, 0.355, 0.1317, 5}},

	[9] = {[2] = {2.1, 0.2787, -0.04, 4.2},		--9 Goblin √
		   [3] = {2.1, 0.3144, 0.054, 4}},

	[10] = {[2] = {2.1, 0.361, 0.1654, 4},		--10 BloodElf Male √
		    [3] = {2.1, 0.3177, -0.0683, 4}},

	[11] = {[2] = {2.4, 0.248, 0.02, 5.5},		--11 Goat Male √
			[3] = {2.1, 0.3177, 0, 5}},
			
	[24] = {[2] = {2.5, 0.2233, 0.04, 5.2},		--24 Pandaren Male √
		    [3] = {2.5, 0.2433, -0.04, 5.2}},

	[27] = {[2] = {2.1, 0.3067, 0.02, 5.2},		--27 Nightborne √
		   [3] = {2.1, 0.3347, 0.0563, 4.7}},

	[28] = {[2] = {3.5, 0.2027, 0.18, 5.5},		--28 Tauren Male √
		   [3] = {2.3, 0.2293, -0.0067, 5.5}},

	[29] = {[2] = {2.1, 0.3556, 0.1038, 4.5},	--24 VE √
			[3] = {2.1, 0.3353, 0.02, 3.8}},

	[31] = {[2] = {2.3, 0.2387, 0.04, 5.5},		--32 Zandalari √
		   [3] = {2.1, 0.2733, 0.1243, 5.5}},

	[32] = {[2] = {2.3, 0.2387, -0.04, 5.2},	--32 Kul'Tiran √
		   [3] = {2.1, 0.312, 0.02, 4.7}},

	["Wolf"] = {[2] = {2.6, 0.2266, 0.02, 5},	--22 Worgen Wolf form √
		   	[3] = {2.1, 0.2613, 0.0133, 4.7}},
	
	["Druid"] = {[1] = {3.71, 0.2027, 0.02, 5},		--Cat
				 [5] = {4.8, 0.1707, 0.04, 5},		--Bear
				 [31] = {4.61, 0.1947, 0.02, 5},	--Moonkin
				 [4] = {4.61, 0.1307, 0.04, 5},		--Swim
				 [27] = {3.61, 0.1067, 0.02, 5},	--Fly Swift
				 [29] = {3.61, 0.1067, 0.02, 5},	--Fly
				 [3] = {4.91, 0.184, 0.02, 5}},		--Travel Form
				 
	["Mounted"] = {[1] = {8, 1.2495, 4, 5.5}},
	
	--1 	Human 32 Kultiran
	--2 	Orc
	--3 	Dwarf
	--4 	Night Elf
	--5 	Undead
	--6 	Tauren
	--7 	Gnome
	--8 	Troll
	--9 	Goblin
	--10 	Blood Elf
	--11 	Draenei
};

local _, _, playerRaceID = UnitRace("player")
local playerGenderID = UnitSex("player")
local _, _, playerClassID = UnitClass("player");	
local ZoomInValue_Default = ZoomValuebyRaceID[0][1];
local Shoulder_Factor1_Defalut = ZoomValuebyRaceID[0][2];
local Shoulder_Factor2_Defalut = ZoomValuebyRaceID[0][3];
local ZoomInValue = ZoomInValue_Default;
local Shoulder_Factor1 = Shoulder_Factor1_Defalut;
local Shoulder_Factor2 = Shoulder_Factor2_Defalut;

local function ReIndexRaceID(raceID)
	if raceID == 25 or raceID == 26 then	--Pandaren A|H
		raceID = 24;
	elseif raceID == 30 then				--Lightforged
		raceID = 11;
	elseif raceID == 36 then				--Mag'har Orc
		raceID = 2;
	elseif raceID == 34 then				--DarkIron
		raceID = 3;
	else
		raceID = raceID;
	end
	return raceID
end

playerRaceID = ReIndexRaceID(playerRaceID)

local function InitializeShoulderFactors()
	local _, _, raceID = UnitRace("player");
	raceID = raceID or 0;
	local GenderID = UnitSex("player")	
	raceID = ReIndexRaceID(raceID)

	if not ZoomValuebyRaceID[raceID] then
		raceID = 0;
	end

	if not ZoomValuebyRaceID[raceID][GenderID] then
		GenderID = 2;	--Male 2 / Female 3
	end

	ZoomInValue = ZoomValuebyRaceID[raceID][GenderID][1];
	Shoulder_Factor1 = ZoomValuebyRaceID[raceID][GenderID][2];
	Shoulder_Factor2 = ZoomValuebyRaceID[raceID][GenderID][3];
	ZoomInValue_XmogMode = ZoomValuebyRaceID[raceID][GenderID][4];
end

InitializeShoulderFactors();

local function ModifyCameraForMounts()
	if IsMounted() then
		local index = "Mounted"
		ZoomInValue = ZoomValuebyRaceID[index][1][1];
		Shoulder_Factor1 = ZoomValuebyRaceID[index][1][2];
		Shoulder_Factor2 = ZoomValuebyRaceID[index][1][3];
	else
		ZoomInValue = ZoomValuebyRaceID[playerRaceID][playerGenderID][1];
		Shoulder_Factor1 = ZoomValuebyRaceID[playerRaceID][playerGenderID][2];
		Shoulder_Factor2 = ZoomValuebyRaceID[playerRaceID][playerGenderID][3];
		ZoomInValue_XmogMode = ZoomValuebyRaceID[playerRaceID][playerGenderID][4];		
	end
end

local function ModifyCameraForShapeshifter()
	if IsMounted() then
		ModifyCameraForMounts();
		return;
	end

	if playerRaceID ~= 22 and playerClassID ~= 11 then	--22 Worgen 11 druid
		ZoomInValue = ZoomValuebyRaceID[playerRaceID][playerGenderID][1];
		Shoulder_Factor1 = ZoomValuebyRaceID[playerRaceID][playerGenderID][2];
		Shoulder_Factor2 = ZoomValuebyRaceID[playerRaceID][playerGenderID][3];
		ZoomInValue_XmogMode = ZoomValuebyRaceID[playerRaceID][playerGenderID][4];
		return;
	end

	local raceID_shouldUse = 1;
	
	if playerClassID ~= 11 then
		local _, inAlternateForm = HasAlternateForm();
		if not inAlternateForm then						--Is curren in wolf form
			raceID_shouldUse = "Wolf";
		else
			raceID_shouldUse = 1;
		end
		ZoomInValue = ZoomValuebyRaceID[raceID_shouldUse][playerGenderID][1];
		Shoulder_Factor1 = ZoomValuebyRaceID[raceID_shouldUse][playerGenderID][2];
		Shoulder_Factor2 = ZoomValuebyRaceID[raceID_shouldUse][playerGenderID][3];
		ZoomInValue_XmogMode = ZoomValuebyRaceID[raceID_shouldUse][playerGenderID][4];
		return;
	else
		ACL:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
		local formID = GetShapeshiftFormID()
		raceID_shouldUse = "Druid";
		if (not formID) or (not ZoomValuebyRaceID[raceID_shouldUse][formID]) then
			raceID_shouldUse = playerRaceID
			if playerRaceID == 22 and (not formID) then
				local _, inAlternateForm = HasAlternateForm();
				if not inAlternateForm then						--Is curren in wolf form
					raceID_shouldUse = "Wolf";
				else
					raceID_shouldUse = 1;
				end
			end
			formID = playerGenderID;
		end
		--print(raceID_shouldUse)
		--print(formID)
		ZoomInValue = ZoomValuebyRaceID[raceID_shouldUse][formID][1];
		Shoulder_Factor1 = ZoomValuebyRaceID[raceID_shouldUse][formID][2];
		Shoulder_Factor2 = ZoomValuebyRaceID[raceID_shouldUse][formID][3];
		ZoomInValue_XmogMode = ZoomValuebyRaceID[raceID_shouldUse][formID][4];
	end
end

--SetCVar("test_cameraOverShoulder", 0.60)
--UnitOnTaxi
--test_cameraDynamicPitchSmartPivotCutoffDist
--test_cameraDynamicPitch
--EndPoint Head = 1.6 

local Smooth_Shoulder = CreateFrame("Frame","SmoothShoulderContainer");
Smooth_Shoulder.TimeSinceLastUpdate = 0;
Smooth_Shoulder.duration = 1;
Smooth_Shoulder:Hide();

local function Smooth_Shoulder_Update(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
	local EndPoint = self.EndPoint;
	local StartPoint = self.StartPoint;
	local Value = outSine(self.TimeSinceLastUpdate, StartPoint, EndPoint - StartPoint, self.duration) --0.11 NE
	SetCVar("test_cameraOverShoulder", Value)

	if self.TimeSinceLastUpdate >= self.duration then
		SetCVar("test_cameraOverShoulder", EndPoint)
		self:Hide();
	end

	--print(self.TimeSinceLastUpdate)
end


Smooth_Shoulder:SetScript("OnShow", function(self)
	self.StartPoint = GetCVar("test_cameraOverShoulder");
	--print(self.EndPoint);
end);
Smooth_Shoulder:SetScript("OnUpdate", Smooth_Shoulder_Update);
Smooth_Shoulder:SetScript("OnHide", function(self)
	self.TimeSinceLastUpdate = 0
end);

local function Smooth_ShoulderCvar(EndPoint)
	Smooth_Shoulder:Hide();
	Smooth_Shoulder.EndPoint = EndPoint;
	Smooth_Shoulder:Show();
end


hooksecurefunc("CameraZoomIn", function(increment)
	local Zoom = GetCameraZoom() - increment
	if OpenViaClick and (xmogMode ~= 1) then
		Smooth_ShoulderCvar(Shoulder_Factor1*Zoom - Shoulder_Factor2)
	end
end)

hooksecurefunc("CameraZoomOut", function(increment)
	local Zoom = GetCameraZoom() + increment
	if OpenViaClick  and (xmogMode ~= 1)then
		Smooth_ShoulderCvar(Shoulder_Factor1*Zoom - Shoulder_Factor2)
	end
end)


function AAACameraZoomIn(EndPoint)
	local goal = EndPoint or ZoomFactor.Goal;
	ZoomFactor.Current = GetCameraZoom();
	if ZoomFactor.Current >= goal then
		CameraZoomIn(ZoomFactor.Current - goal);
	else
		CameraZoomOut(-ZoomFactor.Current + goal);
	end
end

local TimeSinceLastUpdate = 0
local function SmoothYaw(self, elapsed)
	TimeSinceLastUpdate = TimeSinceLastUpdate + elapsed
	local x = TimeSinceLastUpdate;
	local t = ZoomFactor.Time;
	local EndSpeed = ZoomFactor.EndSpeed;
	local StartSpeed = ZoomFactor.StartSpeed;
	local speed = inOutSine(TimeSinceLastUpdate, StartSpeed, EndSpeed - StartSpeed, t)
	MoveViewRightStart(speed);
	
	if TimeSinceLastUpdate >= t then
		MoveViewRightStart(EndSpeed);
		TimeSinceLastUpdate = 0;
		self:Hide();
	end
end

local SY = CreateFrame("Frame","SmoothYawContainer");
SY:Hide();
SY:SetScript("OnUpdate", SmoothYaw); --SmoothYaw
SY:SetScript("OnHide", function()
	TimeSinceLastUpdate = 0
end);

--[[
local function SmoothZoom_Update(self, elapsed)
	self.TimeSinceLastUpdate_Zoom = self.TimeSinceLastUpdate_Zoom + elapsed
	local x = self.TimeSinceLastUpdate_Zoom;
	local t = 3;
	local EndDistance = ZoomFactor.Goal;
	local goal = 5.5;
	ZoomFactor.Current = GetCameraZoom();
	local speed = (ZoomFactor.Current- goal-1)*inOutSine(self.TimeSinceLastUpdate_Zoom, 1,  -1, t) --0.11 NE
	if speed > 0 then
		MoveViewInStart(speed);
	else
		MoveViewOutStart(-speed);
	end
	
	if self.TimeSinceLastUpdate_Zoom >= t then
		MoveViewInStop()
		self.TimeSinceLastUpdate_Zoom = 0;
		self:Hide();
	end
end

local SZ = CreateFrame("Frame","SmoothZoomContainer");
SZ.TimeSinceLastUpdate_Zoom = 0
SZ:Hide();
SZ:SetScript("OnUpdate", SmoothZoom_Update);
SZ:SetScript("OnHide", function(self)
	self.TimeSinceLastUpdate_Zoom = 0
end);
--]]

local function SmoothPitch_Update(self, elapsed)
	self.TimeSinceLastUpdate_Pitch = self.TimeSinceLastUpdate_Pitch + elapsed
	local x = self.TimeSinceLastUpdate_Pitch;
	local t = 1.65;
	local EndDistance = ZoomFactor.Goal;
	--local speed = 0.3*outSine(self.TimeSinceLastUpdate_Pitch, 1,  -1, t)
	local PL = tostring(outSine(self.TimeSinceLastUpdate_Pitch, 88,  -88, t))
	--MoveViewDownStart(0.1)
	ConsoleExec( "pitchlimit "..PL)
	--MoveViewDownStart(speed);
	
	if self.TimeSinceLastUpdate_Pitch >= t then
		ConsoleExec( "pitchlimit 0")
		--MoveViewDownStop()
		ConsoleExec( "pitchlimit 88")
		--MoveViewUpStart(0.02)
		self.TimeSinceLastUpdate_Pitch = 0;
		self:Hide();
	end
end

local SP = CreateFrame("Frame","SmoothPitchContainer");
SP.TimeSinceLastUpdate_Pitch = 0;
SP:Hide();
SP:SetScript("OnShow", function(self)
	self.TimeSinceLastUpdate_Pitch = 0
end);
SP:SetScript("OnUpdate", SmoothPitch_Update);
SP:SetScript("OnHide", function(self)
	self.TimeSinceLastUpdate_Pitch = 0
end);
------------------------------

local function ResetCamera()
	OpenViaClick = false
	xmogMode = 0;
	Narci_CharacterModelFrame.xmogMode = 0;
	ACL:Hide()
	hasSet = false;
	MoveViewRightStop()
	if CVar_Temp.ActioncamState ~= 1 then		--Restore the acioncam state
		SetCVar("test_cameraDynamicPitch", 0)	--Note: "test_cameraDynamicPitch" may cause camera to jitter while reseting the player's view
		Smooth_ShoulderCvar(0)
		C_Timer.After(1, function()
			ConsoleExec( "actioncam off" )
		end)
	end
		
	ConsoleExec( "pitchlimit 88")
	
	FadeFrame(Narci_Vignette, 0.5, "OUT")
	Narci_Attribute.animOut:Play();
	C_Timer.After(0.1, function()
		--UIFrameFadeIn(UIParent, 0.5, 0, 1);	--cause frame rate drop
		Minimap:Show()
		local CameraFollowStyle = GetCVar("cameraSmoothStyle");
		if CameraFollowStyle == "0" then		--workaround for auto-following
			SetView(5);
		else
			ResetView(2);
			ResetView(5);
			AAACameraZoomIn(CVar_Temp.ZoomLevel);
		end
	end)	
	Narci_Attribute:Show();
end

--[[
local function SetDate()
	local CalendarTime = C_Calendar.GetDate();
	local hour = CalendarTime.hour;
	local minute = CalendarTime.minute;
	if minute < 10 then
		minute = "0"..tostring(minute)
	end
	Narci_Vignette.Time:SetText(hour..":"..minute)
	local zoneText = GetMinimapZoneText()
	Narci_Vignette.Location:SetText(zoneText)
end
--]]
--[[
function testAnim()
	UIFrameFadeOut(UIParent, 0.5, 1, 0);
	C_Timer.After(3, function()
		UIFrameFadeIn(UIParent, 0.5, 0, 1);
	end)

end
--]]

local function SetYawTransitionTime()
	local zoomlevel = GetCameraZoom();
	ZoomFactor.Time = 0;
end

local function ZoomTest()
	CVar_Temp.ZoomLevel = GetCameraZoom();
	SetCVar("test_cameraDynamicPitch", 1)
	if NarcissusDB.CameraOrbit and not IsPlayerMoving() and not IsMounted() then
		SY:Show();
		SetView(2);	
	end
	SP:Show();	
	C_Timer.After(0.1, function()
		AAACameraZoomIn(ZoomInValue)
	end)
end

function Narci_MinimapButton_OnClick(self, button, down)
	if button == "MiddleButton" then
		--Emergency Stop --PH
		print("Camera has been reset.")
		UIParent:SetAlpha(1);
		MoveViewRightStop();
		MoveViewLeftStop();
		ResetView(5);
		ConsoleExec( "pitchlimit 88");
		CVar_Temp.OverShoulder = 0;
		SetCVar("test_cameraOverShoulder", 0)
		ConsoleExec( "actioncam off" )
		Narci_CharacterModelFrame:Hide();
		Narci_CharacterModelSettings:Hide();
		return;
	elseif button == "RightButton" then
		if IsShiftKeyDown() then
			NarcissusDB.ShowMinimapButton = false;
			print("Minimap button has been hidden. You may type /Narci minimap to re-enable it.");
			self:Hide();
			Narci_MinimapButtonSwitch.Tick:Hide();
		end
		return;
	end
	GameTooltip:Hide();
	self:Disable();
	C_Timer.After(0.1, function()
		if not UIParent:IsVisible() then SetUIVisibility(true); end
	end)
	Narci_Open();

	C_Timer.After(2, function()
		self:Enable()
	end)
end

function Narci_MinimapButton_OnEnter(self)
	if not NarcissusDB.ShowMinimapButton then return; end

	local function GetCharcterInfoHotKey()
		local command = "TOGGLECHARACTER0";
		local key1, key2 = GetBindingKey(command);
		return key1, key2
	end

	local HotKey1, HotKey2 = GetCharcterInfoHotKey();
	local KeyText;
	local LeftClickText = L["Minimap Tooltip Left Click"];
	if HotKey1 and NarcissusDB.EnableDoubleTap then
		KeyText = "("..HotKey1..")";
		if HotKey2 then
			KeyText = KeyText .. "|cffffffff or |r("..HotKey2..")";
		end
		LeftClickText = LeftClickText.." |cffffffff".."/".." |r"..L["Minimap Tooltip Double Click"].." "..KeyText.."|r";
	end

	local bindAction = "CLICK Narci_MinimapButton:LeftButton";
	local keyBind = GetBindingKey(bindAction)
	if keyBind and keyBind ~= "" then
		LeftClickText = LeftClickText.." |cffffffff".."/|r "..keyBind;
	end

	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPRIGHT", self, "BOTTOM", 0, 0)
	GameTooltip:SetText(NARCI_GRADIENT);
	--GameTooltip:AddDoubleLine(NARCI_GRADIENT, "A.A.K.");
	GameTooltip:AddLine(LeftClickText.." "..L["Minimap Tooltip To Open"], nil, nil, nil, false);
	GameTooltip:AddLine(L["Minimap Tooltip Shift Right Click"].." "..L["Minimap Tooltip Hide Button"], nil, nil, nil, true);
	GameTooltip:AddLine(L["Minimap Tooltip Middle Button"], nil, nil, nil, true);
	GameTooltip:AddLine(" ", nil, nil, nil, true);
	GameTooltip:AddDoubleLine(NARCI_VERSION_INFO, NARCI_DEVELOPER_INFO, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8);
	if NARCI_TRANSLATOR_INFO then	GameTooltip:AddDoubleLine(" ", NARCI_TRANSLATOR_INFO, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8);	end
	GameTooltip:AddLine("https://wow.curseforge.com/projects/narcissus", 0.5, 0.5, 0.5, false);
	GameTooltip:Show()

	self.Color:Show();
	UIFrameFadeIn(self.Color, 0.2, self.Color:GetAlpha(), 1)
	UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
	SetCursor("Interface/CURSOR/Reforge.blp")
end

-- Derivative from [[LibDBIcon-1.0]]

local minimapShapes = {
	["ROUND"] = {true, true, true, true},
	["SQUARE"] = {false, false, false, false},
	["CORNER-TOPLEFT"] = {false, false, false, true},
	["CORNER-TOPRIGHT"] = {false, false, true, false},
	["CORNER-BOTTOMLEFT"] = {false, true, false, false},
	["CORNER-BOTTOMRIGHT"] = {true, false, false, false},
	["SIDE-LEFT"] = {false, true, false, true},
	["SIDE-RIGHT"] = {true, false, true, false},
	["SIDE-TOP"] = {false, false, true, true},
	["SIDE-BOTTOM"] = {true, true, false, false},
	["TRICORNER-TOPLEFT"] = {false, true, true, true},
	["TRICORNER-TOPRIGHT"] = {true, false, true, true},
	["TRICORNER-BOTTOMLEFT"] = {true, true, false, true},
	["TRICORNER-BOTTOMRIGHT"] = {true, true, true, false},
}

local function Narci_MinimapButton_UpdateAngle(radian)
	local x, y, q = cos(radian), sin(radian), 1
	if x < 0 then q = q + 1 end
	if y > 0 then q = q + 2 end
	local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
	local quadTable = minimapShapes[minimapShape]
	local w = (Minimap:GetWidth() / 2) + 10	--10
	local h = (Minimap:GetHeight() / 2) + 10
	if quadTable[q] then
		x, y = x*w, y*h
	else
		local diagRadiusW = sqrt(2*(w)^2) - 10	--  -10
		local diagRadiusH = sqrt(2*(h)^2) - 10
		x = max(-w, min(x*diagRadiusW, w))
		y = max(-h, min(y*diagRadiusH, h))
	end
	Narci_MinimapButton:SetPoint("CENTER", "Minimap", "CENTER", x, y)
end

local function Narci_MinimapButton_OnLoad()
	local radian = NarcissusDB.MinimapButton.Position;
	Narci_MinimapButton_UpdateAngle(radian);
end

function Narci_MinimapButton_DraggingFrame_OnUpdate()
	local rad, cos, sin, sqrt, max, min = math.rad, math.cos, math.sin, math.sqrt, math.max, math.min
	local button = Narci_MinimapButton
	local radian

	local mx, my = Minimap:GetCenter()
	local px, py = GetCursorPosition()
	local scale = Minimap:GetEffectiveScale()
	px, py = px / scale, py / scale
	radian = math.atan2(py - my, px - mx);

	Narci_MinimapButton_UpdateAngle(radian);
	NarcissusDB.MinimapButton.Position = radian;
end

---------------End of derivation---------------

function Narci_ItemSlotButton_OnEnter(self, direction)
	--[[
	if self.itemModID then
		print(self.itemModID)
	end
	--]]
	self.Highlight:StopAnimating();
	self.Highlight.BlingIn:Play();
	ForceTooltipToShow();
	if IsAltKeyDown() and not TransmogMode then
		Narci_EquipmentFlyout_Show(self, self:GetID());
		Narci_EquipmentFlyoutFrame.Arrow:Show();
	end

	if Narci_EquipmentFlyoutFrame:IsShown() then
		NarciTooltip_SetComparison(Narci_EquipmentFlyoutFrame.BaseItem, self);
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	if direction == "left" then
		GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", 10, -20);
	else
		GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", -10, -20);
	end
	if (self.hyperlink) then
		GameTooltip:SetHyperlink(self.hyperlink);
		GameTooltip:Show();
		return;
	end
	local hasItem, hasCooldown, repairCost = GameTooltip:SetInventoryItem("player", self:GetID(), nil, true);

	GameTooltip:Show()
end

local BorderTexture = NarciAPI_GetBorderTexture();

local GemBorderTexture = {
	[1]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Unique",	--Kraken's Eye
	[2]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Green",
	[3]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Unique",	--Prismatic	
	[4]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Unique",	--Meta
	[5]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Orange",	--Orange
	[6]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Purple",
    [7]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Yellow",	--Yellow	
	[8]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Blue",		--Blue
	[9]  = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot",			--Empty
	[10] = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot-Red",	--Artifact
	[11] = "Interface/AddOns/Narcissus/Art/GemBorder/GemSlot",			--Artifact
}

local RunePlateTexture = {
	[0] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-Black",		--Enchantable but unenchanted
	[1] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-Black",
	[2] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-Uncommon",
	[3] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-Rare",
	[4] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-Epic",
	[5] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-Legendary",
	[6] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-Artifact",
	[7] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-Heirloom",
}

local function designateColorID(itemID)
    if itemID == 153714 then
        return 10;
    elseif itemID == 153715 then
        return 2;
    end
end
---Get Transmog Appearance---
--[[
	==sourceInfo==
	sourceType					TRANSMOG_SOURCE_1 = "Boss Drop";
	invType						TRANSMOG_SOURCE_2 = "Quest";
	visualID					TRANSMOG_SOURCE_3 = "Vendor";
	isCollected					TRANSMOG_SOURCE_4 = "World Drop";
	sourceID					TRANSMOG_SOURCE_5 = "Achievement";
	isHideVisual				TRANSMOG_SOURCE_6 = "Profession";
	itemID
	itemModID					Normal 0, Heroic 1, Mythic 3, LFG 4
	categoryID
	name
	quality	
--]]

local xmogTable = {
	{1, INVTYPE_HEAD}, {3, INVTYPE_SHOULDER}, {15, INVTYPE_CLOAK}, {5, INVTYPE_CHEST}, {4, INVTYPE_BODY}, {18, INVTYPE_TABARD}, {9, INVTYPE_WRIST},		--Left 	**slotID for TABARD is 19
	{10, INVTYPE_HAND}, {6, INVTYPE_WAIST}, {7, INVTYPE_LEGS}, {8, INVTYPE_FEET},																		--Right
	{16, INVTYPE_WEAPONMAINHAND}, {17, INVTYPE_WEAPONOFFHAND},																							--Weapon
};

local function ShareHyperLink()																	--Send transmog hyperlink to chat
	local delay = 0;																			--Keep message in order
	print(MYMOG_GRADIENT)
	for i=1, #xmogTable do
		local index =  xmogTable[i][1]
		if slotTable[index] and slotTable[index].hyperlink then			
			C_Timer.After(delay, function()
			SendChatMessage(xmogTable[i][2]..": "..slotTable[index].hyperlink, "GUILD")
			end)
			delay = delay + 0.1;
		end
	end
end

local function AAASetCoolDown(self)
	local frame = self.CooldownFrame.Cooldown;
	if ( frame ) then
		local start, duration, enable = GetInventoryItemCooldown("player", self:GetID());
		if enable and enable ~= 0 and start > 0 and duration > 0 then
			frame:SetCooldown(start, duration);
			frame:SetHideCountdownNumbers(false)
		else
			frame:Clear();
		end
	end
end

local function GetSlotVisualID(slotId)
	if slotId == 2 or (slotId > 10 and slotId < 15) then
		return -1, -1;
	end
	local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID, _, _, _, hideVisual = C_Transmog.GetSlotVisualInfo(slotId, 0);
	if ( hideVisual ) then
		return 0, 0;
	elseif ( appliedSourceID == NO_TRANSMOG_SOURCE_ID ) then
		return baseSourceID, baseVisualID;
	else
		return appliedSourceID, appliedVisualID;
	end
end

local function SetItemSocketingFramePosition(self)		--Let ItemSocketingFrame appear on the side of the slot
	if ItemSocketingFrame then																		
		if self.GemSlot:IsShown() then
			ItemSocketingFrame:Show()
		else
			ItemSocketingFrame:Hide()
			return;
		end
		ItemSocketingFrame:ClearAllPoints();
		if self.IsRight then
			ItemSocketingFrame:SetPoint("TOPRIGHT", self, "TOPLEFT", 4, 0);
		else
			ItemSocketingFrame:SetPoint("TOPLEFT", self, "TOPRIGHT", -4, 0);
		end
		GameTooltip:Hide();
	end
end

local function FadeOutSlotButton(self)
	self:SetAlpha(1);

	local targetID = self:GetID()

	for i=1, #slotTable do
		if slotTable[i] and slotTable[i]:GetID() ~= targetID then
			slotTable[i]:SetAlpha(Irrelevant_Attribute_Alpha);
		end
	end
end

local function AAAPaperDollItemSlotButton_OnClick(self, button)
	MerchantFrame_ResetRefundItem();
	if ( button == "LeftButton" ) then
		local type = GetCursorInfo();
		if ( type == "merchant" and MerchantFrame.extendedCost ) then
			MerchantFrame_ConfirmExtendedItemCost(MerchantFrame.extendedCost);
		else
			if ( CursorHasItem() ) then
				--MerchantFrame_SetRefundItem(self, 1);
			end
		end
	else
		return;
	end
end


function Narci_ItemSlotButton_OnClick(self, button)
	if ( IsModifiedClick() ) then
		if IsAltKeyDown() and button == "LeftButton" then
			local action = EquipmentManager_UnequipItemInSlot(self:GetID())
			if action then
				EquipmentManager_RunAction(action)
			end
			return;
		elseif IsShiftKeyDown() and button == "LeftButton" then
			if self.hyperlink then
				--SendChatMessage(self.hyperlink)
			end
			ShareHyperLink()
		else
			PaperDollItemSlotButton_OnModifiedClick(self, button);
			
			TakeOutFromUIParent(AzeriteEmpoweredItemUI, "MEDIUM", true);
			TakeOutFromUIParent(AzeriteEssenceUI, "MEDIUM", true);
			TakeOutFromUIParent(ItemSocketingFrame, "MEDIUM", true);
			TakeOutFromUIParent(ArtifactFrame, "MEDIUM", true);

			SetItemSocketingFramePosition(self);
		end
	else
		if button == "LeftButton" then
			Narci_EquipmentFlyout_Show(self, self:GetID())
		elseif button == "RightButton" then
		--	UseInventoryItem(self:GetID());
		end
	end	
end

local function IsItemEnchantable(self, slotID)
	if slotID == 11 or slotID == 12 or
		slotID == 16 or slotID == 17 then
		return true;
	elseif (slotID == 9 or slotID == 10) and false then
		return true;
	else
		return false;
	end
end

local RuneLetterTable = {
	["crit"] = "ᚲ\nᚱ\nᛁ",	  --CRI
	["haste"] = "ᚼ\nᛆ\nᛋ",	 --HAS
	["mastery"] = "ᛘ\nᛋ\nᛐ", --MST
	["versa"] = "ᚡ\nᚽ\nᚱ",	 --VER
	["STR"] = "ᛊ\nᛏ\nᚱ",	 --STR
	["AGI"] = "ᛆ\nᚵ\nᛁ",	 --AGI
	["INT"] = "ᛁ\nᚾ\nᛐ",	 --INT
	["speed"] = "ᛋ\nᛕ\nᛑ",	 --SPF
	["armor"] = "ᛆ\nᚱ\nᛘ",	 --ARM
	["heal"] = "ᚺ\nᛁ\nᛚ", 	 --HIL
	["leech"] = "ᛒ\nᛚ\nᛑ",	 --BLD
	["spell"] = "ᛗ\nᚷ\nᚲ",	 --MGC
}

local function DisplayRuneSlot(self, slotID, itemQuality, itemLink)
	if not self.RuneSlot then
		return;
	elseif (itemQuality == 0) or (not itemLink) then
		self.RuneSlot:Hide();
		return;
	end

	if IsItemEnchantable(self, slotID) then
		self.RuneSlot:Show();
		self.RuneSlot.Background:SetTexture(RunePlateTexture[itemQuality])
	else
		self.RuneSlot:Hide();
	end

	local EnchantID = GetItemEnchant(itemLink)
	if EnchantID ~= 0 then
		self.RuneSlot.RuneLetter:Show();
		if EnchantInfo[EnchantID] then
			self.RuneSlot.RuneLetter:SetText(RuneLetterTable[ EnchantInfo[EnchantID][1] ])
			self.RuneSlot.spellID = EnchantInfo[EnchantID][3]
		end
	else
		--self.RuneSlot.Background:SetTexture(RunePlateTexture[0])	--if the item is enchantable but unenchanted, set its texture to black
		self.RuneSlot.spellID = nil;
		self.RuneSlot.RuneLetter:Hide();
	end
end

function Narci_RuneButton_OnEnter(self)
	local spellID = self.spellID;
	if (not spellID) then
		return;
	end
	ForceTooltipToShow()
	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 0)
	GameTooltip:SetSpellByID(spellID);
	GameTooltip:Show()
end

---------------------------------------------------

function Narci_ItemSlotButton_SetUseItem(self)
	local slotName = strsub(self:GetName(), 7);
	local slotId, textureName = GetInventorySlotInfo(slotName)
	self:SetID(slotId);
	self:SetAttribute("type2", "item")
	self:SetAttribute("item", slotId)
end

function Narci_ItemSlotButton_OnLoad(self)
	self:RegisterForDrag("LeftButton");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	AAASetCoolDown(self);
	local slotId = self:GetID()
	local slotName = strsub(self:GetName(), 7);
	local _, textureName = GetInventorySlotInfo(slotName)

	local itemLocation = ItemLocation:CreateFromEquipmentSlot(slotId)
	--print(slotName..slotId)
	--local texture = CharacterHeadSlot.popoutButton.icon:GetTexture()
	local itemLink = "";
	local itemIcon, itemName, itemQuality, itemLevel, effectiveLvl, GemName, GemLink;
	local isAzeriteEmpoweredItem = false;		--3 Pieces	**likely to be changed in patch 8.2
	local isAzeriteItem = false;				--Heart of Azeroth
	local sourceitemIcon, sourceitemName, sourceitemQuality;


	if C_Item.DoesItemExist(itemLocation) and not TransmogMode then
		self.Icon:SetDesaturated(false)
		self.Name:Show();
		self.ItemLevel:Show();

		local current, maximum = GetInventoryItemDurability(slotId);
		if current and maximum then
			self.Durability = (current / maximum);
		end
		itemLink = C_Item.GetItemLink(itemLocation)
		self.hyperlink = nil;
		itemIcon = C_Item.GetItemIcon(itemLocation)
		itemName = C_Item.GetItemName(itemLocation)
		self.GradientBackground:Show()
		itemQuality = C_Item.GetItemQuality(itemLocation)
		_, _, _, itemLevel = GetItemInfo(itemLink)
		effectiveLvl = C_Item.GetCurrentItemLevel(itemLocation)
		GemName, GemLink = IsItemSocketable(itemLink)
		self.GemSlot.ItemLevel = effectiveLvl
		self.GemLink = GemLink;
		isAzeriteEmpoweredItem = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation)
		isAzeriteItem = C_AzeriteItem.IsAzeriteItem(itemLocation)

	elseif C_Item.DoesItemExist(itemLocation) and TransmogMode then
		self.GradientBackground:Show()
		itemName = C_Item.GetItemName(itemLocation)
		itemIcon = C_Item.GetItemIcon(itemLocation)
		itemQuality = C_Item.GetItemQuality(itemLocation)
		local appliedSourceID, appliedVisualID = GetSlotVisualID(slotId);
		if appliedVisualID > 0 then
			local sourceInfo = C_TransmogCollection.GetSourceInfo(appliedSourceID)
			self.itemID = sourceInfo.itemID																							--saved for export
			itemName = sourceInfo.name; 																							--sourceitemName
			local _, sourceID = C_TransmogCollection.GetItemInfo(sourceInfo.itemID, sourceInfo.itemModID)							--appearanceID, sourceID
			itemQuality = sourceInfo.quality or 12;																				--sourceitemQuality
			itemIcon = GetItemIcon(sourceInfo.itemID); 																				--sourceitemIcon
			local _, _, _, hex = GetItemQualityColor(itemQuality)
			_, self.hyperlink = GetItemInfo(sourceInfo.itemID)
			self.itemModID = sourceInfo.itemModID;

			local sourceType = sourceInfo.sourceType
			if sourceType == TRANSMOG_SOURCE_BOSS_DROP then
				local drops = C_TransmogCollection.GetAppearanceSourceDrops(sourceID)
				if drops and drops[1] then
					effectiveLvl = drops[1].encounter.." ".."|cFFFFD100"..drops[1].instance.."|r|CFFf8e694";
					self.sourcePlainText = drops[1].encounter.." "..drops[1].instance;
					
					if sourceInfo.itemModID == 0 then 
						effectiveLvl = effectiveLvl.." "..PLAYER_DIFFICULTY1;
						self.sourcePlainText = self.sourcePlainText.." "..PLAYER_DIFFICULTY1;
						self.hyperlink = "|c"..hex.."|Hitem:"..sourceInfo.itemID.."::::::::120::::2:356".."1"..":1476:|h|r"
					elseif sourceInfo.itemModID == 1 then 
						effectiveLvl = effectiveLvl.." "..PLAYER_DIFFICULTY2;
						self.sourcePlainText = self.sourcePlainText.." "..PLAYER_DIFFICULTY2;
						self.hyperlink = "|c"..hex.."|Hitem:"..sourceInfo.itemID.."::::::::120::::2:356".."2"..":1476:|h|r"
					elseif sourceInfo.itemModID == 3 then 
						effectiveLvl = effectiveLvl.." "..PLAYER_DIFFICULTY6;
						self.sourcePlainText = self.sourcePlainText.." "..PLAYER_DIFFICULTY6;
						self.hyperlink = "|c"..hex.."|Hitem:"..sourceInfo.itemID.."::::::::120::::2:356".."3"..":1476:|h|r"
					elseif sourceInfo.itemModID == 4 then
						effectiveLvl = effectiveLvl.." "..PLAYER_DIFFICULTY3;
						self.sourcePlainText = self.sourcePlainText.." "..PLAYER_DIFFICULTY3;
						self.hyperlink = "|c"..hex.."|Hitem:"..sourceInfo.itemID.."::::::::120::::2:356".."4"..":1476:|h|r"
					end
				end
			else
				if sourceType == 2 then --quest
					effectiveLvl = TRANSMOG_SOURCE_2
					if sourceInfo.itemModID == 3 then 
						self.hyperlink = "|c"..hex.."|Hitem:"..sourceInfo.itemID.."::::::::120::::2:512".."6"..":1562:|h|r"
					elseif sourceInfo.itemModID == 2 then 
						self.hyperlink = "|c"..hex.."|Hitem:"..sourceInfo.itemID.."::::::::120::::2:512".."5"..":1562:|h|r"
					elseif sourceInfo.itemModID == 1 then 
						self.hyperlink = "|c"..hex.."|Hitem:"..sourceInfo.itemID.."::::::::120::::2:512".."4"..":1562:|h|r"
					end
				elseif sourceType == 3 then --vendor
					effectiveLvl = TRANSMOG_SOURCE_3
				elseif sourceType == 4 then --world drop
					effectiveLvl = TRANSMOG_SOURCE_4
				elseif sourceType == 5 then --achievement
					effectiveLvl = TRANSMOG_SOURCE_5
				elseif sourceType == 6 then	--profession
					effectiveLvl = TRANSMOG_SOURCE_6
				else
					if itemQuality == 6 then
						effectiveLvl = ITEM_QUALITY6_DESC;
					elseif itemQuality == 5 then
						effectiveLvl = ITEM_QUALITY5_DESC;
					end
				end
				self.sourcePlainText = nil;
			end
			if self.hyperlink then
				_, self.hyperlink = GetItemInfo(self.hyperlink)																		--original hyperlink cannot be printed (workaround)
				if self.hyperlink then
					_, _, _, _, itemIcon = GetItemInfoInstant(self.hyperlink)
				end
			end
		else	--irrelevant slot
			self.Icon:SetDesaturated(true)
			itemQuality = 0;
			self.Name:Hide();
			self.ItemLevel:Hide();
			self.GradientBackground:Hide();
		end

	else
		self.Icon:SetDesaturated(false)
		itemQuality = 0;
		itemIcon = textureName;
		itemName = "" ;
		self.GradientBackground:Hide();
		itemLevel = "";
		effectiveLvl = "";
	end

		self.itemQuality = itemQuality;
	if GemName ~= nil then
		self.GemSlot:Show()
		if GemLink then
			--local _, _, _, _, _, _, _, _, _, GemIcon, _, _, itemSubClassID = GetItemInfo(GemLink);
			local id, _, _, _, GemIcon, _, itemSubClassID = GetItemInfoInstant(GemLink);
			itemSubClassID = designateColorID(id) or itemSubClassID
			self.GemSlot.GemBorder:SetTexture(GemBorderTexture[itemSubClassID]);
			self.GemSlot.GemIcon:SetTexture(GemIcon);
			self.GemSlot.GemIcon:Show();
			self.GemSlot.ItemID = id;
		else
			self.GemSlot.GemBorder:SetTexture(GemBorderTexture[9]);
			self.GemSlot.GemIcon:SetTexture(nil);
			self.GemSlot.GemIcon:Hide();
		end
		--print(itemSubClassID)
	else
		self.GemSlot:Hide();
	end
	self.Icon:SetTexture(itemIcon);
	self.Name:SetText(itemName);
	self.IlvlCenter.ItemLevelCenter:SetText(effectiveLvl);
	if itemQuality then --itemQuality sometimes return nil. This is a temporary solution
		local r, g, b = GetItemQualityColor(itemQuality);
		self.Name:SetTextColor(r, g, b);
		self.Border:SetTexture(BorderTexture[itemQuality]);
	end

	if isAzeriteEmpoweredItem then
		self.ItemLevel:SetText(effectiveLvl);
		self.Border:SetTexture(BorderTexture[8]);
		return;
	end

	if isAzeriteItem then
		self.isAzeriteItem = true;
		local HeartLevel = C_AzeriteItem.GetPowerLevel(itemLocation);
		local xp_Current, xp_Needed =  C_AzeriteItem.GetAzeriteItemXPInfo(itemLocation);
		HeartLevel = HeartLevel .. "  |CFFf8e694" .. math.floor((xp_Current/xp_Needed)*100 + 0.5) .. "%";
		self.ItemLevel:SetText(effectiveLvl.."  |cFFFFD100"..HeartLevel);
		return;
	else
		self.isAzeriteItem = false;
	end

	if effectiveLvl == nil then
		if IsHeritageArmor(self.itemID) then
			effectiveLvl = L["Heritage Armor"];
		elseif IsSpecialItem(self.itemID) then
			local _, sourceName = IsSpecialItem(self.itemID);
			effectiveLvl = sourceName;
		else
			effectiveLvl = " ";
		end
	end

	self.ItemLevel:SetText(effectiveLvl);
	--Enchant Frame--
	if itemQuality then
		DisplayRuneSlot(self, slotId, itemQuality, itemLink);
	end
	-----------------
end

function Narci_ItemSlotButton_OnEvent(self, event, ...)
	if event == "BAG_UPDATE_COOLDOWN" then
		AAASetCoolDown(self);
	elseif ( event == "MODIFIER_STATE_CHANGED" ) then
		local key, state = ...;
		if ( key == "LALT" and self:IsMouseOver() ) then
			local flyout = Narci_EquipmentFlyoutFrame
			if state == 1 then
				if flyout:IsShown() and flyout.slotID == self:GetID() then
					flyout:Hide();
				else
					Narci_EquipmentFlyout_Show(self, self:GetID())
					flyout.Arrow:Show();
				end
			else
				--Narci_EquipmentFlyout_Show(self, -1)
			end
			
		end
	end

end

function Narci_ItemSlotButton_OnShow(self)
	AAASetCoolDown(self)
	self:RegisterEvent("BAG_UPDATE_COOLDOWN");
end

function Narci_ItemSlotButton_OnLeave(self)
	self:UnregisterEvent("MODIFIER_STATE_CHANGED");
	self.Highlight.BlingOut:Play();
	--GameTooltip:Hide();
	HideButtonTooltip();
end

function Narci_ItemSlotButton_OnHide(self)
	self:UnregisterEvent("BAG_UPDATE_COOLDOWN");
end

------------------------------------------------------------------
----The following codes are derivated from PapaerDollFrame.lua----
------------------------------------------------------------------

local function SetRegen(self)
	local powerType, powerToken = UnitPowerType("player");
	local regenRate = GetPowerRegen()
	local regenRateText = BreakUpLargeNumbers(regenRate);
	local regenRatePerSec = string.format("%.2f", regenRate).."/s";
	if powerToken == "ENERGY" then
		self.Label:SetText(STAT_ENERGY_REGEN);
		self.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_ENERGY_REGEN).." "..regenRateText..FONT_COLOR_CODE_CLOSE;
		self.tooltip2 = STAT_ENERGY_REGEN_TOOLTIP;
	elseif powerToken == "RUNES" then
		self.Label:SetText(STAT_RUNE_REGEN);
		self.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_RUNE_REGEN).." "..regenRateText..FONT_COLOR_CODE_CLOSE;
		self.tooltip2 = STAT_RUNE_REGEN_TOOLTIP;
	elseif powerToken == "FOCUS" then
		self.Label:SetText(STAT_FOCUS_REGEN);
		self.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_FOCUS_REGEN).." "..regenRateText..FONT_COLOR_CODE_CLOSE;
		self.tooltip2 = STAT_FOCUS_REGEN_TOOLTIP;
	elseif UnitHasMana("player") then
		regenRate = GetManaRegen();
		regenRatePerSec = tostring(math.floor(regenRate)).."/s";
		self.Label:SetText(MANA_REGEN);
	else
		local _, class = UnitClass("player");
		if (class ~= "DEATHKNIGHT") then
			self.Label:SetText(MANA_REGEN_COMBAT);		--MANA_REGEN_ABBR
			self.Value:SetText("N/A");
			self.Label:SetAlpha(Irrelevant_Attribute_Alpha);
			self.Value:SetAlpha(Irrelevant_Attribute_Alpha);
			return;
		end
		local _, regenRate = GetRuneCooldown(1);
		local regenRateText = (format(STAT_RUNE_REGEN_FORMAT, regenRate));
		self.Label:SetText(STAT_RUNE_REGEN);
		self.Value:SetText(regenRateText);
		self.Label:SetAlpha(1);
		self.Value:SetAlpha(1);
		return;
	end
	
	self.Value:SetText(regenRatePerSec)
end

local function GetEffectiveCrit()
	local rating;
	local spellCrit, rangedCrit, meleeCrit;
	local critChance;
	
	-- Start at 2 to skip physical damage
	local holySchool = 2;
	local minCrit = GetSpellCritChance(holySchool);
	local spellCritTable = {};
	spellCritTable[holySchool] = minCrit;
	local spellCrit;
	for i=(holySchool+1), MAX_SPELL_SCHOOLS do
		spellCrit = GetSpellCritChance(i);
		minCrit = min(minCrit, spellCrit);
		spellCritTable[i] = spellCrit;
	end
	spellCrit = minCrit
	rangedCrit = GetRangedCritChance();
	meleeCrit = GetCritChance();

	if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
		critChance = spellCrit;
		rating = CR_CRIT_SPELL;
	elseif (rangedCrit >= meleeCrit) then
		critChance = rangedCrit;
		rating = CR_CRIT_RANGED;
	else
		critChance = meleeCrit;
		rating = CR_CRIT_MELEE;
	end

	return critChance, rating
end

local function SetCrit(self)
	local critChance, rating = GetEffectiveCrit();

	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_CRITICAL_STRIKE).." "..format("%.2F%%", critChance)..FONT_COLOR_CODE_CLOSE;
	local extraCritChance = GetCombatRatingBonus(rating);
	local extraCritRating = GetCombatRating(rating);
	if (GetCritChanceProvidesParryEffect()) then
		self.tooltip2 = format(CR_CRIT_PARRY_RATING_TOOLTIP, BreakUpLargeNumbers(extraCritRating), extraCritChance, GetCombatRatingBonusForCombatRatingValue(CR_PARRY, extraCritRating));
	else
		self.tooltip2 = format(CR_CRIT_TOOLTIP, BreakUpLargeNumbers(extraCritRating), extraCritChance);
	end

	local PercentageText = string.format(Format_Digit, critChance).."%"
	self.Label:SetText(NARCI_CRITICAL_STRIKE);		--COMBAT_RATING_NAME10
	self.Value:SetText(PercentageText);
	self.ValueRating:SetText(extraCritRating);
end

local function SetHaste(self)
	local unit = "player"

	local haste = GetHaste();
	local rating = CR_HASTE_MELEE;

	local hasteFormatString;
	if (haste < 0 and not GetPVPGearStatRules()) then
		hasteFormatString = RED_FONT_COLOR_CODE.."%s"..FONT_COLOR_CODE_CLOSE;
	else
		hasteFormatString = "%s";
	end

	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_HASTE) .. " " .. format(hasteFormatString, format("%.2F%%", haste)) .. FONT_COLOR_CODE_CLOSE;

	local _, class = UnitClass(unit);
	self.tooltip2 = _G["STAT_HASTE_"..class.."_TOOLTIP"];
	if (not self.tooltip2) then
		self.tooltip2 = STAT_HASTE_TOOLTIP;
	end
	self.tooltip2 = self.tooltip2 .. format(STAT_HASTE_BASE_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(rating)), GetCombatRatingBonus(rating));

	local PercentageText = string.format(Format_Digit, haste).."%"
	self.Label:SetText(STAT_HASTE);
	self.Value:SetText(PercentageText);
	self.ValueRating:SetText(GetCombatRating(rating));
end

local function MasteryFrame_OnEnter(self)
	SetRadarVertexSize(self, 15);

	GameTooltip:SetOwner(self, "ANCHOR_NONE");

	local _, class = UnitClass("player");
	local mastery, bonusCoeff = GetMasteryEffect();
	local masteryBonus = GetCombatRatingBonus(CR_MASTERY) * bonusCoeff;

	local title = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_MASTERY).." "..format("%.2F%%", mastery)..FONT_COLOR_CODE_CLOSE;
	if (masteryBonus > 0) then
		title = title..HIGHLIGHT_FONT_COLOR_CODE.." ("..format("%.2F%%", mastery-masteryBonus)..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..format("%.2F%%", masteryBonus)..FONT_COLOR_CODE_CLOSE..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
	end
	GameTooltip:SetText(title);

	local primaryTalentTree = GetSpecialization();
	if (primaryTalentTree) then
		local masterySpell, masterySpell2 = GetSpecializationMasterySpells(primaryTalentTree);
		if (masterySpell) then
			GameTooltip:AddSpellByID(masterySpell);
		end
		if (masterySpell2) then
			GameTooltip:AddLine(" ");
			GameTooltip:AddSpellByID(masterySpell2);
		end
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(format(STAT_MASTERY_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_MASTERY)), masteryBonus), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	else
		GameTooltip:AddLine(format(STAT_MASTERY_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_MASTERY)), masteryBonus), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(STAT_MASTERY_TOOLTIP_NO_TALENT_SPEC, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true);
	end
	GameTooltip:SetPoint("TOPRIGHT",self,"TOPLEFT", -4, 0)
	--self.UpdateTooltip = self.onEnterFunc;
	ForceTooltipToShow();
	GameTooltip:Show();
end

local function SetMastery(self)

	local mastery = GetMasteryEffect();

	self:SetScript("OnEnter", MasteryFrame_OnEnter);
	local PercentageText = string.format(Format_Digit, mastery).."%"
	self.Label:SetText(STAT_MASTERY);

	if (UnitLevel("player") < SHOW_MASTERY_LEVEL) then
		self.numericValue = 0;
		self.Value:SetText("N/A");
		self.ValueRating:SetText("0");
		self.Label:SetAlpha(Irrelevant_Attribute_Alpha)
		self.Value:SetAlpha(Irrelevant_Attribute_Alpha)
		self.ValueRating:SetAlpha(Irrelevant_Attribute_Alpha)
		return;
	end

	self.Value:SetText(PercentageText);
	self.ValueRating:SetText(GetCombatRating(CR_MASTERY));

	self.Label:SetAlpha(1)
	self.Value:SetAlpha(1)
	self.ValueRating:SetAlpha(1)
end

local function SetVersatility(self)
	local versatility = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE);
	local versatilityDamageBonus = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE);
	local versatilityDamageTakenReduction = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_TAKEN);
	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(VERSATILITY_TOOLTIP_FORMAT, STAT_VERSATILITY, versatilityDamageBonus, versatilityDamageTakenReduction) .. FONT_COLOR_CODE_CLOSE;

	self.tooltip2 = format(CR_VERSATILITY_TOOLTIP, versatilityDamageBonus, versatilityDamageTakenReduction, BreakUpLargeNumbers(versatility), versatilityDamageBonus, versatilityDamageTakenReduction);
	
	--local PercentageText = string.format(Format_Digit, versatilityDamageBonus).."% / "..string.format(Format_Digit, versatilityDamageTakenReduction).."%"
	local PercentageText = string.format(Format_Digit, versatilityDamageBonus).."%"
	self.Label:SetText(STAT_VERSATILITY);
	self.Value:SetText(PercentageText);
	self.ValueRating:SetText(GetCombatRating(CR_VERSATILITY_DAMAGE_DONE));
end

local function SetLeech(self)
	local lifesteal = GetLifesteal();

	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_LIFESTEAL) .. " " .. format("%.2F%%", lifesteal) .. FONT_COLOR_CODE_CLOSE;

	self.tooltip2 = format(CR_LIFESTEAL_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_LIFESTEAL)), GetCombatRatingBonus(CR_LIFESTEAL));

	--self:Show();

	local PercentageText = string.format(Format_Digit, lifesteal).."%"
	self.Label:SetText(STAT_LIFESTEAL);
	self.Value:SetText(PercentageText);
	if lifesteal == 0 then
		self.Label:SetAlpha(Irrelevant_Attribute_Alpha)
		self.Value:SetAlpha(Irrelevant_Attribute_Alpha)
		self.animIn.A2:SetToAlpha(1);
	else
		self.Label:SetAlpha(1)
		self.Value:SetAlpha(1)
		self.animIn.A2:SetToAlpha(1);
	end
end

local function SetAvoidance(self)
	local avoidance = GetAvoidance();

	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVOIDANCE) .. " " .. format("%.2F%%", avoidance) .. FONT_COLOR_CODE_CLOSE;

	self.tooltip2 = format(CR_AVOIDANCE_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_AVOIDANCE)), GetCombatRatingBonus(CR_AVOIDANCE));

	--self:Show();

	local PercentageText = string.format(Format_Digit, avoidance).."%"
	self.Label:SetText(STAT_AVOIDANCE);
	self.Value:SetText(PercentageText);
	
	if avoidance == 0 then
		self.Label:SetAlpha(Irrelevant_Attribute_Alpha)
		self.Value:SetAlpha(Irrelevant_Attribute_Alpha)
		self.animIn.A2:SetToAlpha(1);
	else
		self.Label:SetAlpha(1)
		self.Value:SetAlpha(1)
		self:SetAlpha(1)
		self.animIn.A2:SetToAlpha(1);
	end
end

local function SetSpeed(self)
	local speed = GetSpeed();

	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_SPEED) .. " " .. format("%.2F%%", speed) .. FONT_COLOR_CODE_CLOSE;

	self.tooltip2 = format(CR_SPEED_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_SPEED)), GetCombatRatingBonus(CR_SPEED));

	--self:Show();

	local PercentageText = string.format(Format_Digit, speed).."%"
	self.Label:SetText(STAT_SPEED);
	self.Value:SetText(PercentageText);

	if speed == 0 then
		self.Label:SetAlpha(Irrelevant_Attribute_Alpha)
		self.Value:SetAlpha(Irrelevant_Attribute_Alpha)
		self.animIn.A2:SetToAlpha(1);
	else
		self.Label:SetAlpha(1)
		self.Value:SetAlpha(1)
		self.animIn.A2:SetToAlpha(1);
	end
end

local function AAAMovementSpeed_OnUpdate(self, elapsedTime)
	local unit = self.unit;
	local _, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed(unit);
	runSpeed = runSpeed/BASE_MOVEMENT_SPEED*100;
	flightSpeed = flightSpeed/BASE_MOVEMENT_SPEED*100;
	swimSpeed = swimSpeed/BASE_MOVEMENT_SPEED*100;

	-- Pets seem to always actually use run speed
	if (unit == "pet") then
		swimSpeed = runSpeed;
	end

	-- Determine whether to display running, flying, or swimming speed
	local speed = runSpeed;
	local swimming = IsSwimming(unit);
	if (swimming) then
		speed = swimSpeed;
	elseif (IsFlying(unit)) then
		speed = flightSpeed;
	end

	-- Hack so that your speed doesn't appear to change when jumping out of the water
	if (IsFalling(unit)) then
		if (self.wasSwimming) then
			speed = swimSpeed;
		end
	else
		self.wasSwimming = swimming;
	end

	local valueText = format("%d%%", speed+0.5);

	self.Label:SetText(L["Movement Speed"]);		--STAT_MOVEMENT_SPEED
	self.Value:SetText(valueText);

	self.speed = speed;
	self.runSpeed = runSpeed;
	self.flightSpeed = flightSpeed;
	self.swimSpeed = swimSpeed;
end

local function AAAMovementSpeed_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_MOVEMENT_SPEED).." "..format("%d%%", self.speed+0.5)..FONT_COLOR_CODE_CLOSE);

	GameTooltip:AddLine(format(STAT_MOVEMENT_GROUND_TOOLTIP, self.runSpeed+0.5));
	if (self.unit ~= "pet") then
		GameTooltip:AddLine(format(STAT_MOVEMENT_FLIGHT_TOOLTIP, self.flightSpeed+0.5));
	end
	GameTooltip:AddLine(format(STAT_MOVEMENT_SWIM_TOOLTIP, self.swimSpeed+0.5));
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine(format(CR_SPEED_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(CR_SPEED)), GetCombatRatingBonus(CR_SPEED)));

	GameTooltip:SetPoint("TOPRIGHT",self,"TOPLEFT", -4, 0)

	ForceTooltipToShow()
	GameTooltip:Show();

	self.UpdateTooltip = AAAMovementSpeed_OnEnter;
end

local function SetMovementSpeed(self)
	local unit = "player"

	self.wasSwimming = nil;
	self.unit = unit;
	--self:Show();
	AAAMovementSpeed_OnUpdate(self);
	self:SetScript("OnEnter", AAAMovementSpeed_OnEnter);
	--self.onEnterFunc = AAAMovementSpeed_OnEnter;

	self:SetScript("OnUpdate", AAAMovementSpeed_OnUpdate);
end

function AAAPaperDollStatTooltip(self, direction)
	if ( not self.tooltip ) then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	GameTooltip:SetText(self.tooltip);
	if ( self.tooltip2 ) then
		GameTooltip:AddLine(self.tooltip2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	end
	if ( self.tooltip3 ) then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(self.tooltip3, RAID_CLASS_COLORS["MAGE"].r, RAID_CLASS_COLORS["MAGE"].g, RAID_CLASS_COLORS["MAGE"].b, true);
	end

	if (not direction) then
		GameTooltip:SetPoint("TOPRIGHT",self,"TOPLEFT", -4, 0)
	elseif direction=="RIGHT" then
		GameTooltip:SetPoint("LEFT",self,"RIGHT", 0, 0)
	elseif direction=="TOP" then
		GameTooltip:SetPoint("BOTTOM",self,"TOP", 0, -4)
	elseif direction=="CURSOR" then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR");
	end

	ForceTooltipToShow();
	GameTooltip:Show();
end



local powerTypeList = {
	--localized Name
	[0] 	= MANA,						--mana
	[1] 	= RAGE,						--rage
	[2] 	= FOCUS,					--focus
	[3] 	= ENERGY,					--energy
	[4] 	= TUTORIAL_TITLE61_ROGUE,	--combo points
	[5] 	= RUNES,					--runes
	[6] 	= RUNIC_POWER,				--runic power
	[7] 	= SOUL_SHARDS_POWER,		--soul shards
	[8] 	= ECLIPSE,					--eclipse
	[9] 	= HOLY_POWER,				--holy power
	[11]	= MAELSTROM,				--Maelstrom
	[12]	= CHI,						--Chi
	[13]	= INSANITY,					--Shadow Priests
	[16]	= ARCANE_CHARGES,			--
	[17]	= FURY,						--Havoc 
	[18]	= PAIN,						--Vengeance 		

};

local RegenList = {
	[2] = STAT_FOCUS_REGEN,
	[3] = STAT_ENERGY_REGEN,
	[5] = STAT_RUNE_REGEN,
}

local function trim(s)
	if s ~= nil then
		return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
	else
		return nil
	end
end


function IlvlButtonCenter_OnClick(self)
	NarcissusDB.DetailedIlvlInfo = not NarcissusDB.DetailedIlvlInfo;
	local DetailedIlvlInfo = NarcissusDB.DetailedIlvlInfo
	
	local frame1, frame2 = self:GetParent().IlvlButtonLeft, self:GetParent().IlvlButtonRight;
	--print("DetailedIlvlInfo: "..tostring(NarcissusDB.DetailedIlvlInfo))
	if DetailedIlvlInfo then
		frame1.AnimFrame:Hide();
		frame2.AnimFrame:Hide();
		frame1.AnimFrame:Show();
		frame2.AnimFrame:Show();
		frame1:Show();
		frame2:Show();
		FadeFrame(AAADetailedStatFrame, 0.5, "IN")
		FadeFrame(AAAConsiceStatFrame, 0.5, "OUT")	
	else
		frame1.AnimFrame:Hide();
		frame2.AnimFrame:Hide();
		frame1.AnimFrame:Show();
		frame2.AnimFrame:Show();
		FadeFrame(AAADetailedStatFrame, 0.5, "OUT")
		FadeFrame(AAAConsiceStatFrame, 0.5, "IN")		
	end
end

function ShowDetailedIlvlInfo()
	local frame = Narci_IlvlInfoFrame;
	local frame1 = Narci_IlvlInfoFrame.IlvlButtonLeft;
	local frame2 = Narci_IlvlInfoFrame.IlvlButtonRight;


	if NarcissusDB.DetailedIlvlInfo and (not frame1:IsShown()) then
		frame1.AnimFrame:Show();
		frame2.AnimFrame:Show();
		frame1:Show();
		frame2:Show();
	end
end

function AAAStatus_OnLoad(self)
	if NarcissusDB.DetailedIlvlInfo then
		FadeFrame(AAADetailedStatFrame, 0.5, "IN")
		FadeFrame(AAAConsiceStatFrame, 0.5, "OUT")	
	else
		FadeFrame(AAADetailedStatFrame, 0.5, "OUT")
		FadeFrame(AAAConsiceStatFrame, 0.5, "IN")	
	end
end

local InventorySlotIdTable = {
	1, 		--Head
	2, 		--Neck
	3, 		--Shoulder
	--,4 	--Shirt
	5,		--Chest
	6, 		--Waist
	7, 		--Legs
	8, 		--Feet
	9, 		--Wrist
	10, 	--Hand
	11, 	--Finger1
	12,		--Finger2
	13,		--Trinket1
	14,		--Trinket2
	15,		--Back
	16,		--MainHand
	17, 	--OffHand
	--18，	--INVSLOT_RANGED
}
--/dump GetItemStats(GetInventoryItemLink("player", 8))
--/script DEFAULT_CHAT_FRAME:AddMessage("\124cff0070dd\124Hitem:152783::::::::120::::1:1672:\124h[Mac'Aree Focusing Amethyst]\124h\124r");
--/script DEFAULT_CHAT_FRAME:AddMessage("\124cff0070dd\124Hitem:152783::::::::120::::1:1657:\124h[Mac'Aree Focusing Amethyst]\124h\124r");
--/script DEFAULT_CHAT_FRAME:AddMessage("\124cff0070dd\124Hitem:158362::::::::120::::2:1557:4778:\124h[Lord Waycrest's Signet]\124h\124r");
--[[				 Stats sum						ilvl							ilvl+ from Gem
	Ring		1.7626*ilvl - 246.88		(sum + 246.88) / 1.7626				40  / 1.7626 = 22.6937
--]]

function CalculateWA()
	local k1, k2, k3, k4, k5 = 1, 1, 1 ,1 ,1 ;
	local Num_Equip = 0;
	local Gears = {};
	local Sum_weight = 0;
	local Sum_WI = 0;

	for i=1, #InventorySlotIdTable do
		local slotID = InventorySlotIdTable[i]
		local itemLocation = ItemLocation:CreateFromEquipmentSlot(slotId)
		local itemLink = GetInventoryItemLink("player", slotID)
		--local itemLink = C_Item.GetItemLink(itemLocation)
		Gears[i] = {};

		if itemLink then
			Num_Equip = Num_Equip + 1;
			local ilvl = GetDetailedItemLevelInfo(itemLink)
			local stats = GetItemStats(itemLink)
			local prim = stats["ITEM_MOD_AGILITY_SHORT"] or stats["ITEM_MOD_STRENGTH_SHORT"] or stats["ITEM_MOD_INTELLECT_SHORT"] or 0;
			local crit = stats["ITEM_MOD_CRIT_RATING_SHORT"] or 0;
			local haste = stats["ITEM_MOD_HASTE_RATING_SHORT"] or 0;
			local mastery = stats["ITEM_MOD_MASTERY_RATING_SHORT"] or 0;
			local versa = stats["ITEM_MOD_VERSATILITY"] or 0;
			--print(ilvl.." "..prim.." "..crit.." "..haste.." "..mastery.." "..versa)

			Gears[i].ilvl = ilvl;
			local weight = k1 * prim + k2 * crit + k3 * haste + k4 * mastery + k5 * versa;
			--Gears[i].weight =
			Gears[i].WI = ilvl * weight

			Sum_WI = Sum_WI + Gears[i].WI
			Sum_weight = Sum_weight + weight
			--Gears[i].prim = prim;
			--Gears[i].crit = crit;
			--Gears[i].haste = haste;
			--Gears[i].mastery = mastery;
			--Gears[i].versa = versa;
		end
	end

	local WAvg = Sum_WI/Sum_weight
	--print("Num_Equip = "..WAvg)
	for i=1, #InventorySlotIdTable do
		if Gears[i] and Gears[i].ilvl then
		--print("Item "..i.." WA: "..(Gears[i].WI/Sum_weight*Num_Equip))
		end
	end

	return WAvg;
end

local function SetIlvlBackground(level)
	level = level or UnitLevel("player")
	local avgItemLevel, avgItemLevelEquipped, _ = GetAverageItemLevel();
	local avgIvl = math.floor(avgItemLevel);
	local avgIvl2 = math.floor(avgItemLevel*100 + 0.5) / 100
	local EAvg = math.floor(avgItemLevelEquipped*100 + 0.5) / 100;
	--local WAvg = math.floor(CalculateWA()*10 + 0.5) / 10;
	--frame3.PlayerItemLvlWeighted:SetText(WAvg);
	local percentage = math.ceil( (avgItemLevel - avgIvl)*100 );		--Set the bar(Fluid) height in the Tube

	local height
	if percentage < 10 then
		height = 0;
	elseif percentage > 90 then
		height = 100;
	else
		height = 84*percentage/100;
	end
	
	local frame = Narci_IlvlInfoFrame.IlvlButtonCenter
	local frame2 = Narci_IlvlInfoFrame.IlvlButtonLeft
	local frame3 = Narci_IlvlInfoFrame.IlvlButtonRight
	
	frame.Fluid:SetHeight(height)
	frame.PlayerItemLvl:SetText(avgIvl);
	frame.tooltip = format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVERAGE_ITEM_LEVEL).." "..avgIvl2;
	frame.tooltip2 = HIGHLIGHT_FONT_COLOR_CODE .. STAT_AVERAGE_ITEM_LEVEL_TOOLTIP .. FONT_COLOR_CODE_CLOSE;
	frame.tooltip3 = L["Advanced Info"]
	frame2.PlayerItemLvlEquipped:SetText(EAvg);

	if level <= 60 then
		frame.IvlBackground:SetTexture("Interface\\AddOns\\Narcissus\\ART\\Solid\\HexagonSolid-Grey")
		frame.Fluid:SetColorTexture(ITEM_QUALITY_COLORS[0].r, ITEM_QUALITY_COLORS[0].g, ITEM_QUALITY_COLORS[0].b);
	elseif level <= 80 then
		frame.IvlBackground:SetTexture("Interface\\AddOns\\Narcissus\\ART\\Solid\\HexagonSolid-Green")
		frame.Fluid:SetColorTexture(ITEM_QUALITY_COLORS[2].r, ITEM_QUALITY_COLORS[2].g, ITEM_QUALITY_COLORS[2].b);
	elseif level <= 100 then
		frame.IvlBackground:SetTexture("Interface\\AddOns\\Narcissus\\ART\\Solid\\HexagonSolid-Blue")
		frame.Fluid:SetColorTexture(ITEM_QUALITY_COLORS[3].r, ITEM_QUALITY_COLORS[3].g, ITEM_QUALITY_COLORS[3].b);
	elseif level > 100 then
		if avgItemLevel < 340 then
			frame.IvlBackground:SetTexture("Interface\\AddOns\\Narcissus\\ART\\Solid\\HexagonSolid-Blue")
			frame.Fluid:SetColorTexture(ITEM_QUALITY_COLORS[3].r, ITEM_QUALITY_COLORS[3].g, ITEM_QUALITY_COLORS[3].b);
		else
			frame.IvlBackground:SetTexture("Interface\\AddOns\\Narcissus\\ART\\Solid\\HexagonSolid-Purple")
			frame.Fluid:SetColorTexture(ITEM_QUALITY_COLORS[4].r, ITEM_QUALITY_COLORS[4].g, ITEM_QUALITY_COLORS[4].b);
		end
	end
end

local function CharacterInfoFrame_OnLoad(NewLevel)
	local TitleID = GetCurrentTitle();
	local TitleName = GetTitleName(TitleID);
	if TitleName ~= nil then
		TitleName = strtrim(TitleName) --delete the space in Title
	end
	local level = NewLevel or UnitLevel("player")

	local currentSpecName;
	local currentSpec = GetSpecialization()
	if currentSpec then
	   _, currentSpecName = GetSpecializationInfo(currentSpec)
	else
		currentSpecName = " "
	end

	local className, englishClass, classID = UnitClass("player");
	local _, _, _, rgbHex = GetClassColor(englishClass)
	local frame = PlayerInfoFrame
	if currentSpecName ~= nil then
		if TitleName ~= nil then
			frame.Miscellaneous:SetText(TitleName.."  |  ".."|cFFFFD100"..level.."|r ".." ".."|c"..rgbHex..currentSpecName.." "..className.."|r")
		else
			frame.Miscellaneous:SetText("Level".." |cFFFFD100"..level.."|r ".."|c"..rgbHex..currentSpecName.." "..className.."|r")
		end
	end

	SetIlvlBackground(level)
end

local function RefreshSlot(SlotId)
	if slotTable[SlotId] then
		Narci_ItemSlotButton_OnLoad(slotTable[SlotId]);
	end
end

local function RefreshAllSlot()
	--print(#slotTable)
	for i=1, #slotTable do
		RefreshSlot(i);
	end
end

local function PlaySlotAnimOut()
	if not InCombatLockdown() then
		for i=1, #slotTable do
			if slotTable[i] then
				slotTable[i].animOut:Play()
			end
		end
	end
	Narci_Character.animOut:Play();
end

local function CacheSourceInfo(slotId)
	local appliedSourceID, appliedVisualID 
	if slotID then
		appliedSourceID, appliedVisualID = GetSlotVisualID(slotId);
		if appliedVisualID > 0 then
			local sourceInfo = C_TransmogCollection.GetSourceInfo(appliedSourceID)
			local sources = C_TransmogCollection.GetAppearanceSources(appliedVisualID);
		end
	else
		for i=1, #slotTable do
			if slotTable[i] then
				local ID = slotTable[i]:GetID();
				appliedSourceID, appliedVisualID = GetSlotVisualID(ID);
				if appliedVisualID > 0 then
					local sourceInfo = C_TransmogCollection.GetSourceInfo(appliedSourceID);
					local sources = C_TransmogCollection.GetAppearanceSources(appliedVisualID);
				end
			end
		end
	end
end

local SlotLabelStyle = true;

function SetSlotLabelStyle(self)

	if SlotLabelStyle then
		for i=1, #slotTable do
			if slotTable[i] then
				slotTable[i].GradientBackground:Hide();
				slotTable[i].GradientBackground:SetAlpha(0);
				slotTable[i].Name:Hide();
				local text = slotTable[i].ItemLevel:GetText();
				slotTable[i].ItemLevel:Hide();
				slotTable[i].IlvlCenter.ItemLevelCenter:SetText(text);
				slotTable[i].IlvlCenter:Show();
			end
		end
	else
		for i=1, #slotTable do
			if slotTable[i] then
				slotTable[i].GradientBackground:Show();
				slotTable[i].GradientBackground:SetAlpha(1);
				slotTable[i].Name:Show();
				slotTable[i].ItemLevel:Show();
				slotTable[i].IlvlCenter:Hide();
			end
		end
	end
	if SlotLabelStyle then
		self.icon:SetTexCoord(0, 0.5, 0, 1)
	else
		self.icon:SetTexCoord(0.5, 1, 0, 1)
	end
	SlotLabelStyle = not SlotLabelStyle;
end

local function GetPrimaryStatusNum()
	local _, Strength, _, _ = UnitStat("player", 1);
	local _, Agility, _, _ = UnitStat("player", 2);
	local _, Intellect, _, _ = UnitStat("player", 4);
	if Strength > Agility and Strength > Intellect then
		return Strength;
	elseif	Agility > Strength and Agility > Intellect then
		return Agility;
	elseif	Intellect > Agility and	Intellect >	Strength then
		return Intellect;
	end
end

local function SetPrimary(self)
	local unit = "player"
	local PrimaryStatusName = Narci_GetPrimaryStatusName();
	local PrimaryStatusNum = GetPrimaryStatusNum();
	self.Label:SetText(PrimaryStatusName)
	self.Value:SetText(PrimaryStatusNum)
	local primaryStat, spec;
	spec = GetSpecialization();
	if not spec then return; end
	local role = GetSpecializationRole(spec);
	_, _, _, _, _, primaryStat = GetSpecializationInfo(spec);

	local stat;
	local effectiveStat;
	local posBuff;
	local negBuff;
	stat, effectiveStat, posBuff, negBuff = UnitStat(unit, primaryStat);
	local effectiveStatDisplay = FormatLargeNumbers(effectiveStat);

	-- Set the tooltip text
	local statName = _G["SPELL_STAT"..primaryStat.."_NAME"];
	local tooltipText = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, statName).." ";

	if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
		self.tooltip = tooltipText..effectiveStatDisplay..FONT_COLOR_CODE_CLOSE;
	else
		tooltipText = tooltipText..effectiveStatDisplay;
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText.." ("..BreakUpLargeNumbers(stat - posBuff - negBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 ) then
			tooltipText = tooltipText..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..BreakUpLargeNumbers(posBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( negBuff < 0 ) then
			tooltipText = tooltipText..RED_FONT_COLOR_CODE.." "..BreakUpLargeNumbers(negBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
		end
		self.tooltip = tooltipText;

		-- If there are any negative buffs then show the main number in red even if there are
		-- positive buffs. Otherwise show in green.
		if ( negBuff < 0 and not GetPVPGearStatRules() ) then
			effectiveStatDisplay = RED_FONT_COLOR_CODE..effectiveStatDisplay..FONT_COLOR_CODE_CLOSE;
		end
	end

	self.tooltip2 = _G["DEFAULT_STAT"..primaryStat.."_TOOLTIP"];

	if ( primaryStat == LE_UNIT_STAT_AGILITY ) then
		local attackPower = GetAttackPowerForStat(primaryStat, effectiveStat);
		local tooltip = STAT_TOOLTIP_BONUS_AP;
		if (HasAPEffectsSpellPower()) then
			tooltip = STAT_TOOLTIP_BONUS_AP_SP;
		end
		if (not primaryStat or primaryStat == LE_UNIT_STAT_AGILITY) then
			self.tooltip2 = format(tooltip, BreakUpLargeNumbers(attackPower));
			if ( role == "TANK" ) then
				local increasedDodgeChance = GetDodgeChanceFromAttribute();
				if ( increasedDodgeChance > 0 ) then
					self.tooltip2 = self.tooltip2.."|n|n"..format(CR_DODGE_BASE_STAT_TOOLTIP, increasedDodgeChance);
				end
			end
		else
			self.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
		end

	elseif ( primaryStat == LE_UNIT_STAT_STRENGTH ) then
		local attackPower = GetAttackPowerForStat(primaryStat,effectiveStat);
		if (HasAPEffectsSpellPower()) then
			self.tooltip2 = STAT_TOOLTIP_BONUS_AP_SP;
		end
		if (not primaryStat or primaryStat == LE_UNIT_STAT_STRENGTH) then
			self.tooltip2 = format(self.tooltip2, BreakUpLargeNumbers(attackPower));
			if ( role == "TANK" ) then
				local increasedParryChance = GetParryChanceFromAttribute();
				if ( increasedParryChance > 0 ) then
					self.tooltip2 = self.tooltip2.."|n|n"..format(CR_PARRY_BASE_STAT_TOOLTIP, increasedParryChance);
				end
			end
		else
			self.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
		end

	elseif ( primaryStat == LE_UNIT_STAT_INTELLECT ) then
		if ( UnitHasMana("player") ) then
			if (HasAPEffectsSpellPower()) then
				self.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
			else
				local result, druid = HasSPEffectsAttackPower();
				if (result and druid) then
					self.tooltip2 = format(STAT_TOOLTIP_SP_AP_DRUID, max(0, effectiveStat), max(0, effectiveStat));
				elseif (result) then
					self.tooltip2 = format(STAT_TOOLTIP_BONUS_AP_SP, max(0, effectiveStat));
				elseif (not primaryStat or primaryStat == LE_UNIT_STAT_INTELLECT) then
					self.tooltip2 = format(self.tooltip2, max(0, effectiveStat));
				else
					self.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
				end
			end
		else
			self.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
		end
	end

end

local function SetStamina(self)
	local statIndex = LE_UNIT_STAT_STAMINA;
	local stat;
	local effectiveStat;
	local posBuff;
	local negBuff;
	stat, effectiveStat, posBuff, negBuff = UnitStat("player", statIndex);

	local effectiveStatDisplay = FormatLargeNumbers(effectiveStat);
	-- Set the tooltip text
	local statName = _G["SPELL_STAT"..statIndex.."_NAME"];
	local tooltipText = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, statName).." ";

	if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
		self.tooltip = tooltipText..effectiveStatDisplay..FONT_COLOR_CODE_CLOSE;
	else
		tooltipText = tooltipText..effectiveStatDisplay;
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText.." ("..BreakUpLargeNumbers(stat - posBuff - negBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 ) then
			tooltipText = tooltipText..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..BreakUpLargeNumbers(posBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( negBuff < 0 ) then
			tooltipText = tooltipText..RED_FONT_COLOR_CODE.." "..BreakUpLargeNumbers(negBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
		end
		self.tooltip = tooltipText;

		-- If there are any negative buffs then show the main number in red even if there are
		-- positive buffs. Otherwise show in green.
		if ( negBuff < 0 and not GetPVPGearStatRules() ) then
			effectiveStatDisplay = RED_FONT_COLOR_CODE..effectiveStatDisplay..FONT_COLOR_CODE_CLOSE;
		end
	end

	self.Label:SetText(statName)
	self.Value:SetText(effectiveStat)
	self.tooltip2 = _G["DEFAULT_STAT"..statIndex.."_TOOLTIP"];
	self.tooltip2 = format(self.tooltip2, BreakUpLargeNumbers(((effectiveStat*UnitHPPerStamina("player")))*GetUnitMaxHealthModifier("player")));

	self:Show();
end

local function GetAppropriateDamage(unit)
	if IsRangedWeapon() then
		local attackTime, minDamage, maxDamage, bonusPos, bonusNeg, percent = UnitRangedDamage(unit);
		return minDamage, maxDamage, nil, nil, 0, 0, percent;
	else
		return UnitDamage(unit);
	end
end

local function AAACharacterDamageFrame_OnEnter(self)
	-- Main hand weapon
	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	if ( self.unit == "pet" ) then
		GameTooltip:SetText(INVTYPE_WEAPONMAINHAND_PET, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	else
		GameTooltip:SetText(INVTYPE_WEAPONMAINHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	end
	GameTooltip:AddDoubleLine(format(STAT_FORMAT, ATTACK_SPEED_SECONDS), format("%.2F", self.attackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	GameTooltip:AddDoubleLine(format(STAT_FORMAT, DAMAGE), self.damage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	-- Check for offhand weapon
	if ( self.offhandAttackSpeed ) then
		GameTooltip:AddLine("\n");
		GameTooltip:AddLine(INVTYPE_WEAPONOFFHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		GameTooltip:AddDoubleLine(format(STAT_FORMAT, ATTACK_SPEED_SECONDS), format("%.2F", self.offhandAttackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		GameTooltip:AddDoubleLine(format(STAT_FORMAT, DAMAGE), self.offhandDamage, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end

	GameTooltip:SetPoint("TOPRIGHT",self,"TOPLEFT", -4, 0)
	ForceTooltipToShow()
	GameTooltip:Show();
end

local function SetDamage(self)
	local unit = "player";

	local speed, offhandSpeed = UnitAttackSpeed(unit);
	local minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percent = GetAppropriateDamage(unit);

	-- remove decimal points for display values
	local displayMin = max(floor(minDamage),1);
	local displayMinLarge = displayMin	--BreakUpLargeNumbers(displayMin);
	local displayMax = max(ceil(maxDamage),1);
	local displayMaxLarge = displayMax	--BreakUpLargeNumbers(displayMax);

	-- calculate base damage
	minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg;
	maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg;

	local baseDamage = (minDamage + maxDamage) * 0.5;
	local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
	local totalBonus = (fullDamage - baseDamage);
	-- set tooltip text with base damage
	local damageTooltip = BreakUpLargeNumbers(max(floor(minDamage),1)).." - "..BreakUpLargeNumbers(max(ceil(maxDamage),1));

	local colorPos = "|cffffffff";
	local colorNeg = "|cffffffff";

	-- epsilon check
	if ( totalBonus < 0.1 and totalBonus > -0.1 ) then
		totalBonus = 0.0;
	end

	local value;
	if ( totalBonus == 0 ) then
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then
			value = displayMinLarge.." - "..displayMaxLarge;
		else
			value = displayMinLarge.." - "..displayMaxLarge;
		end
	else
		-- set bonus color and display
		local color;
		if ( totalBonus > 0 ) then
			color = colorPos;
		else
			color = colorNeg;
		end
		if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then
			value = color..displayMinLarge.." - "..displayMaxLarge.."|r";
		else
			value = color..displayMinLarge.." - "..displayMaxLarge.."|r";
		end
		if ( physicalBonusPos > 0 ) then
			damageTooltip = damageTooltip..colorPos.." +"..physicalBonusPos.."|r";
		end
		if ( physicalBonusNeg < 0 ) then
			damageTooltip = damageTooltip..colorNeg.." "..physicalBonusNeg.."|r";
		end
		if ( percent > 1 ) then
			damageTooltip = damageTooltip..colorPos.." x"..floor(percent*100+0.5).."%|r";
		elseif ( percent < 1 ) then
			damageTooltip = damageTooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r";
		end

	end

	self.Label:SetText(DAMAGE)
	self.Value:SetText(value)
	self.damage = damageTooltip;
	self.attackSpeed = speed;
	self.unit = unit;

	-- If there's an offhand speed then add the offhand info to the tooltip
	if ( offhandSpeed and minOffHandDamage and maxOffHandDamage ) then
		minOffHandDamage = (minOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg;
		maxOffHandDamage = (maxOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg;

		local offhandBaseDamage = (minOffHandDamage + maxOffHandDamage) * 0.5;
		local offhandFullDamage = (offhandBaseDamage + physicalBonusPos + physicalBonusNeg) * percent;
		local offhandDamageTooltip = BreakUpLargeNumbers(max(floor(minOffHandDamage),1)).." - "..BreakUpLargeNumbers(max(ceil(maxOffHandDamage),1));
		if ( physicalBonusPos > 0 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorPos.." +"..physicalBonusPos.."|r";
		end
		if ( physicalBonusNeg < 0 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorNeg.." "..physicalBonusNeg.."|r";
		end
		if ( percent > 1 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorPos.." x"..floor(percent*100+0.5).."%|r";
		elseif ( percent < 1 ) then
			offhandDamageTooltip = offhandDamageTooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r";
		end
		self.offhandDamage = offhandDamageTooltip;
		self.offhandAttackSpeed = offhandSpeed;
	else
		self.offhandAttackSpeed = nil;
	end

	self:SetScript("OnEnter", AAACharacterDamageFrame_OnEnter);
	self:Show();
end

local function SetAttackSpeed(self, unit)
	local unit = "player"

	local meleeHaste = GetMeleeHaste();
	local speed, offhandSpeed = UnitAttackSpeed(unit);

	local displaySpeed = math.floor(100*speed + 0.5)/100;
	if ( offhandSpeed ) then
		offhandSpeed = math.floor(100*offhandSpeed + 0.5)/100;
	end
	if ( offhandSpeed ) then
		if displaySpeed ~= offhandSpeed then
			displaySpeed =  displaySpeed.." / ".. offhandSpeed;
		else
			displaySpeed =  displaySpeed;
		end
	else
		displaySpeed =  displaySpeed;
	end

	local speedText = string.format(Format_Digit, meleeHaste).."%"
	self.Label:SetText(ATTACK_SPEED)
	self.Value:SetText(displaySpeed)

	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ATTACK_SPEED).." "..displaySpeed..FONT_COLOR_CODE_CLOSE;
	self.tooltip2 = format(STAT_ATTACK_SPEED_BASE_TOOLTIP, string.format(Format_Digit, meleeHaste));

	self:Show();
end

local function SetArmor(self, unit)
	local unit = "player"

	local baselineArmor, effectiveArmor, armor, bonusArmor = UnitArmor(unit);
	self.Label:SetText(STAT_ARMOR);
	self.Value:SetText(effectiveArmor);

    local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitEffectiveLevel(unit));
	local armorReductionAgainstTarget = PaperDollFrame_GetArmorReductionAgainstTarget(effectiveArmor);

	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, ARMOR).." "..BreakUpLargeNumbers(effectiveArmor)..FONT_COLOR_CODE_CLOSE;
	self.tooltip2 = format(STAT_ARMOR_TOOLTIP, armorReduction);
	if (armorReductionAgainstTarget) then
		self.tooltip3 = format(STAT_ARMOR_TARGET_TOOLTIP, armorReductionAgainstTarget);
	else
		self.tooltip3 = nil;
	end
	self:Show();
end

local function SetPower(self)
	local unit = "player"
	local powerType, powerToken = UnitPowerType(unit);
	local power = UnitPowerMax(unit) or 0;
	local powerText = FormatLargeNumbers(power);
	local powerName = _G[powerToken];
	if (powerToken and powerName) then
		self.Label:SetText(powerName)
		self.Value:SetText(powerText)
		self.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, powerName).." "..powerText..FONT_COLOR_CODE_CLOSE;
		self.tooltip2 = _G["STAT_"..powerToken.."_TOOLTIP"];
		self:Show();
	else
		self.Label:SetText("Resource")
		self.Value:SetText("N/A")
	end
end

local function SetReduction(self)
	local unit = "player"
	local baselineArmor, effectiveArmor, armor, bonusArmor = UnitArmor(unit);

    local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitEffectiveLevel(unit));
	local armorReductionAgainstTarget = C_PaperDollInfo.GetArmorEffectivenessAgainstTarget(effectiveArmor);
	local armorReductionText = string.format(Format_Digit, armorReduction).."%"
	
	self.Label:SetText(L["Damage Reduction Percentage"]);

	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE..COMBAT_TEXT_SHOW_RESISTANCES_TEXT.." "..armorReductionText..FONT_COLOR_CODE_CLOSE;
	self.tooltip2 = format(STAT_ARMOR_TOOLTIP, armorReduction);
	if (armorReductionAgainstTarget) then
		self.tooltip3 = format(STAT_ARMOR_TARGET_TOOLTIP, 100*armorReductionAgainstTarget);
		armorReduction = 100 * armorReductionAgainstTarget
	else
		self.tooltip3 = nil;
	end

	self.Value:SetText(armorReductionText);
	self:Show();
end

local function SetDodge(self)
	local chance = GetDodgeChance();
	local chanceText = string.format("%.2F", chance).."%"
	self.Label:SetText(STAT_DODGE);
	self.Value:SetText(chanceText);

	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, DODGE_CHANCE).." "..string.format("%.2F", chance).."%"..FONT_COLOR_CODE_CLOSE;
	self.tooltip2 = format(CR_DODGE_TOOLTIP, GetCombatRating(CR_DODGE), GetCombatRatingBonus(CR_DODGE));
	self:Show();
end

local function SetParry(self)
	local chance = GetParryChance();
	local chanceText = string.format("%.2F", chance).."%"
	self.Label:SetText(STAT_PARRY);
	self.Value:SetText(chanceText);		

	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, PARRY_CHANCE).." "..string.format("%.2F", chance).."%"..FONT_COLOR_CODE_CLOSE;
	self.tooltip2 = format(CR_PARRY_TOOLTIP, GetCombatRating(CR_PARRY), GetCombatRatingBonus(CR_PARRY));
	self:Show();
end

local function SetBlock(self, unit)
	local unit = "player"

	local chance = GetBlockChance();
	local chanceText = string.format("%.2F", chance).."%"
	self.Label:SetText(STAT_BLOCK);

	local spec = GetSpecialization();
	if not spec then return; end
	local role = GetSpecializationRole(spec);

	if role == "TANK" and chance ~= 0 then
		self.Value:SetText(chanceText);
		self.Label:SetAlpha(1);
		self.Value:SetAlpha(1);	
	else
		self.Value:SetText("N/A");
		self.Label:SetAlpha(Irrelevant_Attribute_Alpha);
		self.Value:SetAlpha(Irrelevant_Attribute_Alpha);		
	end

	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, BLOCK_CHANCE).." "..string.format("%.2F", chance).."%"..FONT_COLOR_CODE_CLOSE;

	local shieldBlockArmor = GetShieldBlock();
	local blockArmorReduction = PaperDollFrame_GetArmorReduction(shieldBlockArmor, UnitEffectiveLevel(unit));
	local blockArmorReductionAgainstTarget = PaperDollFrame_GetArmorReductionAgainstTarget(shieldBlockArmor);

	self.tooltip2 = CR_BLOCK_TOOLTIP:format(blockArmorReduction);
	if (blockArmorReductionAgainstTarget) then
		self.tooltip3 = format(STAT_BLOCK_TARGET_TOOLTIP, blockArmorReductionAgainstTarget);
	else
		self.tooltip3 = nil;
	end
	self:Show();
end

local function SetHealth(self, unit)
	if (not unit) then
		unit = "player";
	end
	local health = UnitHealthMax(unit);
	local healthText = FormatLargeNumbers(health);
	self.Label:SetText(HEALTH)
	self.Value:SetText(healthText)
	self.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, HEALTH).." "..healthText..FONT_COLOR_CODE_CLOSE;
	if (unit == "player") then
		self.tooltip2 = STAT_HEALTH_TOOLTIP;
	elseif (unit == "pet") then
		self.tooltip2 = STAT_HEALTH_PET_TOOLTIP;
	end
	self:Show();
end

------------------------------------------------------------------
-----Some of the codes are derivated from EquipmentFlyout.lua-----
------------------------------------------------------------------
local itemTable = {}; 					-- Used for items and locations
local itemDisplayTable = {} 			-- Used for ordering items by location
local itemDisplayTable_ilvl = {}		-- *Sorted by item level
local MaxItemLevelinSlot = 0;

local function SortedbyIlvl(a,b)
	return tonumber(a.Level)> tonumber(b.Level)
end

function AAAItemFlyoutButton_OnEnter(self)
	self.Highlight:StopAnimating();
	self.Highlight.BlingIn:Play();
	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	if (self.hyperlink) then
		GameTooltip:SetHyperlink(self.hyperlink);
		GameTooltip:SetPoint("BOTTOMLEFT", Narci_EquipmentFlyoutFrame, "TOPLEFT", 0, 0)
		GameTooltip:Show()
		return;
	end
end

local function SetAlertFrame(anchor)
    anchor:RegisterEvent("UI_ERROR_MESSAGE");
    local frame = Narci_AlertFrame_Autohide;
    frame:ClearAllPoints();
    frame:SetScale(Narci_Character:GetEffectiveScale())
    frame:SetPoint("BOTTOM", anchor, "TOP", 0, -12)
end

function AAAItemFlyoutButton_OnClick(self)
	local action = EquipmentManager_EquipItemByLocation(self.location, self.id)
	if action then
		SetAlertFrame(self)
		EquipmentManager_RunAction(action)
	end
	self:Disable()
	C_Timer.After(0.5, function()
		self:Enable()
		self:UnregisterEvent("UI_ERROR_MESSAGE");
	end)
end

function Narci_FlyoutBlack_OnUpdate(self, elapsed)
	local alpha;
	local t = self.TimeSinceLastUpdate;
	local blackFrame = self:GetParent();
	local AnimDuration = 0.25;

	if self.OppoDirection then
		alpha = outSine(t, self.startAlpha, 0 - self.startAlpha, AnimDuration);
	else
		alpha = outSine(t, self.startAlpha, 1 - self.startAlpha, AnimDuration);
	end

	blackFrame:SetAlpha(alpha);

	if t >= AnimDuration then
		if self.OppoDirection then
			blackFrame:SetAlpha(0);
		else
			blackFrame:SetAlpha(1);
		end

		self:Hide();
		return;
	end

	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
end

local function Narci_EquipmentFlyout_CreateButton()
	local frame = Narci_EquipmentFlyoutFrame
	local perRow = EQUIPMENTFLYOUT_ITEMS_PER_ROW;
	local buttons = frame.buttons;
	local buttonAnchor = frame.buttonFrame;
	local numButtons = #buttons;

	local button = CreateFrame("Button", "Narci_EquipmentFlyoutFrameButton" .. numButtons + 1, buttonAnchor, "AAAEquipmentFlyoutButtonTemplate");
	button:SetFrameStrata("DIALOG")
	local pos = numButtons/perRow;
	if pos == 0 then
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
	elseif ( math.floor(pos) == pos ) then
		-- This is the first button in a row (from 2nd)
		button:SetPoint("TOP", buttons[numButtons + 1 - perRow], "BOTTOM", 0, -2);
	else
		button:SetPoint("TOPLEFT", buttons[numButtons], "TOPRIGHT", 0, 0);
	end

	tinsert(buttons, button);
	return button
end

local function ShowLessInformation(self, bool)
	if bool then
		self.Name:Hide();
		self.ItemLevel:Hide();
		self.IlvlCenter:Show();
	else
		self.Name:Show();
		self.ItemLevel:Show();
		self.IlvlCenter:Hide();
	end
end

function Narci_ShowAllInformation()
	if xmogMode ~=0 then
		return;
	end

	local level = Narci_FlyoutBlack:GetFrameLevel() - 1;

	for i=1, #slotTable do
		if slotTable[i] then
			ShowLessInformation(slotTable[i], false);
			slotTable[i]:SetFrameLevel(level -1)
			slotTable[i].RuneSlot:SetFrameLevel(level)
		end
	end
end

function Narci_EquipmentFlyoutFrame_OnHide(self)
	Narci_ShowAllInformation();
	self.slotID = -1;
	self:UnregisterEvent("MODIFIER_STATE_CHANGED");
	self.Arrow:Hide();

	if Narci_Character.animOut:IsPlaying() then return; end
	Narci_FlyoutBlack.AnimFrame:Hide();
	--Narci_FlyoutBlack.AnimFrame.OppoDirection = true;
	Narci_FlyoutBlack.AnimFrame:Show();
end

function Narci_EquipmentFlyoutFrame_OnEvent(self, event, ...)	--Hide Flyout if Left-Alt is released
	if ( event == "MODIFIER_STATE_CHANGED" ) then
		local key, state = ...;
		if ( key == "LALT" ) then
			local flyout = Narci_EquipmentFlyoutFrame
			if state == 0 and flyout:IsShown() then
				flyout:Hide()
			end
		end
	end
end

function Narci_EquipmentFlyout_Show(self,slotID)
	if TransmogMode then
		return;
	end
	
	local flyout = Narci_EquipmentFlyoutFrame;
	if (flyout.slotID == slotID or slotID == -1) and (not IsAltKeyDown()) then
		flyout:Hide();
		return;
	end
	if slotTable[flyout.slotID] then
		local level = Narci_FlyoutBlack:GetFrameLevel() -1
		slotTable[flyout.slotID]:SetFrameLevel(level - 1);
		slotTable[flyout.slotID].RuneSlot:SetFrameLevel(level)
		ShowLessInformation(slotTable[flyout.slotID], false);
	end
	flyout.slotID = slotID
	Narci_BuildFlyout();
	flyout:SetParent(self);
	flyout:ClearAllPoints();
	if self.IsRight then
		flyout:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, 0);			--EquipmentFlyout's Position
	else
		flyout:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 0);
	end

	flyout.Arrow:ClearAllPoints();
	flyout.Arrow:SetPoint("TOP", self, "TOP", 0, 0);

	Narci_FlyoutBlack.AnimFrame:Hide();
	Narci_FlyoutBlack.AnimFrame.OppoDirection = false;
	Narci_FlyoutBlack.AnimFrame:Show();
	self:SetFrameLevel(Narci_FlyoutBlack:GetFrameLevel() + 1)
	--GameTooltip:Hide();
	HideButtonTooltip();
	ShowLessInformation(self, true)
	
	--Reposition Comparison Tooltip if it reaches the top of the screen--
	local TooltipPos = NarciTooltip:GetBottom() or -1;
	NarciTooltip:ClearAllPoints();
	NarciTooltip:SetPoint("BOTTOMLEFT", "Narci_EquipmentFlyoutFrame", "TOPLEFT", 8, 12);
	if self:GetTop() > NarciTooltip:GetBottom() then
    	NarciTooltip:ClearAllPoints();
    	NarciTooltip:SetPoint("TOPLEFT", "Narci_EquipmentFlyoutFrame", "BOTTOMLEFT", 8, -12);
	end
	NarciTooltip_SetComparison(Narci_EquipmentFlyoutFrame.BaseItem, self);
end

function Narci_BuildFlyout(slotID)
	local flyout = Narci_EquipmentFlyoutFrame;
	local LoadItemData = C_Item.RequestLoadItemData;	--Cache Item Info

	flyout:Show();
	local id = slotID or flyout.slotID;
	
	--print(id)
	flyout.BaseItem = ItemLocation:CreateFromEquipmentSlot(id)
	local buttons = flyout.buttons;
	MaxItemLevelinSlot = 0;
	
	wipe(itemDisplayTable);
	wipe(itemTable);
	wipe(itemDisplayTable_ilvl);
	GetInventoryItemsForSlot(id, itemTable);
	local itemLocation, itemLevel, tableOutput
	for location, itemID in next, itemTable do
		if ( location - id == ITEM_INVENTORY_LOCATION_PLAYER ) then -- Remove the currently equipped item from the list
			itemTable[location] = nil;
		else
			local _, _, bags, _, slot, bag = EquipmentManager_UnpackLocation(location);
			if bags then
				itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot)
				itemLevel = C_Item.GetCurrentItemLevel(itemLocation)
				NarciCacheTooltip:SetHyperlink(C_Item.GetItemLink(itemLocation))
				MaxItemLevelinSlot = math.max(MaxItemLevelinSlot, itemLevel)
				LoadItemData(itemLocation)
				tableOutput = {["Level"] = itemLevel, ["itemLocation"] = itemLocation, ["location"] = location}
				tinsert(itemDisplayTable_ilvl, tableOutput);
			end 
		end
	end

	table.sort(itemDisplayTable); -- Sort by location. This ends up as: inventory, backpack, bags, bank, and bank bags.
	table.sort(itemDisplayTable_ilvl, SortedbyIlvl);
	local numTotalItems = #itemDisplayTable_ilvl;
	local buttonWidth, buttonHeight = Narci_HeadSlot:GetWidth(), Narci_HeadSlot:GetHeight();
	buttonWidth, buttonHeight = math.floor(buttonWidth + 0.5), math.floor(buttonHeight + 0.5);
	flyout:SetWidth(math.max(buttonWidth, math.min(numTotalItems, EQUIPMENTFLYOUT_ITEMS_PER_ROW)*buttonWidth))
	--print(numTotalItems)
	local numPageItems = min(numTotalItems, EQUIPMENTFLYOUT_ITEMS_PER_PAGE);
	flyout:SetHeight(math.max(math.floor((numPageItems-1)/EQUIPMENTFLYOUT_ITEMS_PER_ROW + 1)*buttonHeight, buttonHeight))
	local index = 1;
	while #buttons < numPageItems do -- Create any buttons we need.
		local button = Narci_EquipmentFlyout_CreateButton();
	end
	
	for i=1, #buttons do
		button = buttons[i]
		if i <= numPageItems then
			button.itemLocation = itemDisplayTable_ilvl[i].itemLocation;
			button.location = itemDisplayTable_ilvl[i].location;
			button.id = id;
			Narci_EquipmentFlyout_DisplayButton(button)
			button:Show();
			button:SetSize(buttonWidth, buttonHeight)
		else
			button:Hide();
		end
	end

	--NarciTooltip_SetComparison(flyout.BaseItem)
end

function Narci_EquipmentFlyout_DisplayButton(button)
	local location = button.itemLocation;
	button.hyperlink = C_Item.GetItemLink(location)
	if ( not location ) then
		return;
	end

	local itemQuality = C_Item.GetItemQuality(location);
	local itemLevel = C_Item.GetCurrentItemLevel(location);
	local itemIcon = C_Item.GetItemIcon(location);

	if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(location) then
		itemQuality = 8;	--AzeriteEmpoweredItem
	end

	if itemLevel < MaxItemLevelinSlot - 44 then
		itemQuality = 0;
		button.Icon:SetDesaturated(true);
	else
		button.Icon:SetDesaturated(false);
	end
	
	button.Icon:SetTexture(itemIcon)
	button.Border:SetTexture(BorderTexture[itemQuality])
	button.IlvlCenter.ItemLevelCenter:SetText(itemLevel)
	button.IlvlCenter:Show()

	local itemLink = C_Item.GetItemLink(location)

	if itemLink then
		DisplayRuneSlot(button, button.id, itemQuality, itemLink);
	end
end
-----------------------------------------------------------
------------------------Color Theme------------------------
-----------------------------------------------------------
local ColorTable = Narci_ColorTable;
local ColorIndex = Narci_GlobalColorIndex; --#ColorTable;		--Pick up color according to MapID

function SetColorThemeBasedOnMapID()
	local mapID = C_Map.GetBestMapForUnit("player") or nil;
	if mapID and NarcissusDB.AuotoColorTheme then
		if ColorTable[mapID] then
			ColorIndex = mapID
			Narci_GlobalColorIndex = mapID;
		else
			ColorIndex = 0;
			Narci_GlobalColorIndex = 0;
		end
	end
	Narci_Pref_SetRadarColor();
	--print("mapID: "..mapID.." ColorIndex: "..ColorIndex)
end

function Narci_Pref_ColorTheme(index)
	ColorIndex = index or 0;
	Narci_Attribute:Hide();
	Narci_Attribute:Show();
	Narci_Pref_SetRadarColor();
end

local function SetWidgetColor(frame)
	local R, G, B = ColorTable[ColorIndex][1], ColorTable[ColorIndex][2], ColorTable[ColorIndex][3];
	local r, g, b = R/255, G/255 ,B/255;
	local type = frame:GetObjectType();

	if type == "FontString" then
		local sqrt = math.sqrt;
		r, g, b = sqrt(r), sqrt(g), sqrt(b)
		frame:SetTextColor(r, g, b);
		return;
	end

	frame:SetColorTexture(r, g, b);
end

function SetRadarVertexSize(self, size)
	local name = self:GetName()
	local Frame = Narci_RadarChartFrame;
	if name == "ADCrit" then
		Frame.P1:SetSize(size, size);
	elseif name == "ADHaste" then
		Frame.P2:SetSize(size, size);
	elseif name == "ADMastery" then
		Frame.P3:SetSize(size, size);
	elseif name == "ADVersatility" then
		Frame.P4:SetSize(size, size);
	end
end

function Narci_Pref_SetRadarColor()
	local Frame = Narci_RadarChartFrame
	SetWidgetColor(Frame.MaskedBackground)
	SetWidgetColor(Frame.MaskedBackground2)
	SetWidgetColor(Frame.MaskedLine1)
	SetWidgetColor(Frame.MaskedLine2)
	SetWidgetColor(Frame.MaskedLine3)
	SetWidgetColor(Frame.MaskedLine4)
end

local function SetRadarChart()
	local deg = math.deg;
	local rad = math.rad;
	local Frame = Narci_RadarChartFrame;
	--/run Narci_RadarChartFrame.MaskLine1:SetRotation(math.rad());
	local chartWidth = 96 / 2;											--		|
	local _, rating = GetEffectiveCrit();								--		|	p1(x1,y1)	  Line4		p3(x3,y3)
																		--		|			*				*
	local Crit = GetCombatRating(rating);								--		|			 	*		*
	local Haste = GetCombatRating(CR_HASTE_MELEE);						--		|	Line1		 	*		   Line3
	local Mastery = GetCombatRating(CR_MASTERY);						--		|			 	*		*
	local Versatility = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE);	--		|			*				*
																		--		|	p2(x2,y2)	  Line2		p4(x4,y4)
	local Sum = Crit + Haste + Mastery + Versatility;					--		|
	local d1, d2, d3, d4 = chartWidth * (Crit / Sum), chartWidth * (Haste / Sum) , chartWidth * (Mastery / Sum) ,chartWidth * (Versatility / Sum);
	local a = math.sqrt(0.618/(d1 + d4)/(d2 + d3)/2)* 96
	local max = a * math.max(d1, d2, d3, d4);
	local Amplifier = 0;
	local playerLevel = tonumber(UnitLevel("player"))
	if playerLevel >= 1 then
		Amplifier = 0.1671 * math.log(playerLevel)
	end

	if max >= Amplifier * chartWidth then
		a = a * Amplifier * chartWidth / max;
	end
	--print(a)
	local x1, x2, x3, x4 = -d1*a, -d2*a, d3*a, d4*a;
	local y1, y2, y3, y4 = d1*a, -d2*a, d3*a, -d4*a;
	local mx1, mx2, mx3, mx4 = (x1 + x2)/2, (x2 + x4)/2, (x3 + x4)/2, (x1 + x3)/2;
	local my1, my2, my3, my4 = (y1 + y2)/2, (y2 + y4)/2, (y3 + y4)/2, (y1 + y3)/2;

	local ma1 = math.atan2((y1 - y2), (x1 - x2))
	local ma2 = math.atan2((y2 - y4), (x2 - x4))
	local ma3 = math.atan2((y4 - y3), (x4 - x3))
	local ma4 = math.atan2((y3 - y1), (x3 - x1))

	--[[
	print("ma1: "..deg(ma1))
	print("ma2: "..deg(ma2))
	print("ma3: "..deg(ma3))
	print("ma4: "..deg(ma4))
	print(mx1..","..my1)
	print(mx2..","..my2)
	print(mx3..","..my3)
	print(mx4..","..my4)
	--]]
	if my1 == 0 then
		my1 = 0.01;
	end
	if my3 == 0 then
		my1 = -0.01;
	end
	if deg(ma1) == 90 then
		ma1 = rad(89)
	end
	if deg(ma3) == -90 then
		ma1 = rad(-89)
	end

	Frame.P1:SetPoint("CENTER", x1, y1);
	Frame.P2:SetPoint("CENTER", x2, y2);
	Frame.P3:SetPoint("CENTER", x3, y3);
	Frame.P4:SetPoint("CENTER", x4, y4);

	Frame.Mask1:SetRotation(ma1);
	Frame.Mask2:SetRotation(ma2);
	Frame.Mask3:SetRotation(ma3);
	Frame.Mask4:SetRotation(ma4);
		
	local hypo1 = math.sqrt(2*x1^2 + 2*x2^2);
	local hypo2 = math.sqrt(2*x2^2 + 2*x4^2);
	local hypo3 = math.sqrt(2*x4^2 + 2*x3^2);
	local hypo4 = math.sqrt(2*x3^2 + 2*x1^2);

	if (hypo1 - 4) > 0 then
		Frame.MaskLine1:Show();
		Frame.MaskLine1:SetWidth(hypo1 - 4)
	else
		Frame.MaskLine1:Hide();
	end

	if (hypo2 - 4) > 0 then
		Frame.MaskLine2:Show();
		Frame.MaskLine2:SetWidth(hypo2 - 4)
	else
		Frame.MaskLine2:Hide();
	end

	if (hypo3 - 4) > 0 then
		Frame.MaskLine3:Show();
		Frame.MaskLine3:SetWidth(hypo3 - 4)
	else
		Frame.MaskLine3:Hide();
	end

	if (hypo4 - 4) > 0 then
		Frame.MaskLine4:Show();
		Frame.MaskLine4:SetWidth(hypo4 - 4)
	else
		Frame.MaskLine4:Hide();
	end

	Frame.MaskLine1:SetRotation(ma1);
	Frame.MaskLine1:SetPoint("CENTER", mx1, my1);
	Frame.MaskLine2:SetRotation(ma2);
	Frame.MaskLine2:SetPoint("CENTER", mx2, my2);
	Frame.MaskLine3:SetRotation(ma3);
	Frame.MaskLine3:SetPoint("CENTER", mx3, my3);
	Frame.MaskLine4:SetRotation(ma4);
	Frame.MaskLine4:SetPoint("CENTER", mx4, my4);

	Frame.Mask1:SetPoint("CENTER", mx1, my1);
	Frame.Mask2:SetPoint("CENTER", mx2, my2);
	Frame.Mask3:SetPoint("CENTER", mx3, my3);
	Frame.Mask4:SetPoint("CENTER", mx4, my4);


	Frame.MaskedBackground:SetAlpha(0.4);
	Frame.MaskedBackground2:SetAlpha(0.4);

	if UnitLevel("player") < 20 then
		Frame.MaskedLine1:Hide();
		Frame.MaskedLine2:Hide();
		Frame.MaskedLine3:Hide();
		Frame.MaskedLine4:Hide();
		Frame.MaskedBackground:Hide();
		Frame.MaskedBackground2:Hide();
	end
end


function Pref_SetBackgroundColor(self)
	local FrameID = self:GetID()
	local R, G, B = ColorTable[ColorIndex][1], ColorTable[ColorIndex][2], ColorTable[ColorIndex][3];
	local r, g, b = R/255, G/255 ,B/255;
	if FrameID % 2 == 0 then
		if self.Color then
			self.Color:SetColorTexture(r, g, b, 0.75);
			return;
		elseif self.Color1 and self.Color2 then
			self.Color1:SetColorTexture(r, g, b, 0.75);
			self.Color2:SetColorTexture(r, g, b, 0.75);
		end
	else
		if self.Color then
			self.Color:SetColorTexture(0.1, 0.1, 0.1, 0.75);
			return;
		elseif self.Color1 and self.Color2 then
			self.Color1:SetColorTexture(0.1, 0.1, 0.1, 0.75);
			self.Color2:SetColorTexture(0.1, 0.1, 0.1, 0.75);
		end
	end
end

function AttributeTemplate_OnLoad(self)
	local numericValue;
	tinsert(self, numericValue)
	
	Pref_SetBackgroundColor(self);
end

function XmogList_OnLoad(self)
	Pref_SetBackgroundColor(self);
end

local function Status_OnLoad(self)
	if not self then
		return;
	end
	local FrameName = self:GetName();
	local name, num;

	if FrameName == "ADPrimary" or FrameName == "ACPrimary" then
		SetPrimary(self);
		return;
	elseif FrameName == "ADStamina" or FrameName == "ACStamina" then
		SetStamina(self);
		return;
	elseif FrameName == "ADHealth" or FrameName == "ACHealth" then
		SetHealth(self)
		return;
	elseif FrameName == "ADEnergy" or FrameName == "ACEnergy" then
		SetPower(self);
		return;
	elseif FrameName == "ADRegen" or FrameName == "ACRegen" then
		SetRegen(self)
		return;
	elseif FrameName == "ADCrit" or FrameName == "ACCrit" then
		SetCrit(self)
		return;
	elseif FrameName == "ADHaste" or FrameName == "ACHaste" then
		SetHaste(self)
		return;
	elseif FrameName == "ADMastery" or FrameName == "ACMastery" then
		SetMastery(self)
		return;
	elseif FrameName == "ADVersatility" or FrameName == "ACVersatility" then
		SetVersatility(self)
		return;
	elseif FrameName == "ADLeech" or FrameName == "ACLeech" then
		SetLeech(self)
		return;
	elseif FrameName == "ADAvoidance" or FrameName == "ACAvoidance" then
		SetAvoidance(self)
		return;
	elseif FrameName == "ADSpeed" or FrameName == "ACSpeed" then
		SetSpeed(self)
		return;
	elseif FrameName == "ADMovementSpeed" then
		SetMovementSpeed(self)
		return;
	elseif FrameName == "ADDamage" then
		SetDamage(self);
		return;
	elseif FrameName == "ADAttackSpeed" then
		SetAttackSpeed(self);
		return;
	elseif FrameName == "ADArmor" then
		SetArmor(self);
		return;
	elseif FrameName == "ADReduction" then
		SetReduction(self);
		return;	
	elseif FrameName == "ADDodge" then
		SetDodge(self);
		return;		
	elseif FrameName == "ADParry" then
		SetParry(self);
		return;		
	elseif FrameName == "ADBlock" then
		SetBlock(self);
		return;					
	end

	self.Label:SetText(name)
	self.Value:SetText(num)
end

local function RefreshStatus(id, frame)
	local frame = frame or "Detailed";

	if frame == "Detailed" then
		if statTable[id] then
			Status_OnLoad(statTable[id])
		end
	elseif frame == "Concise" then
		if statTable[id] then
			Status_OnLoad(statTable_Short[id])
		end
	end
end

local function RefreshAllStatus()
	for i=1, #statTable do
		RefreshStatus(i);
	end

	for i=1, #statTable_Short do
		RefreshStatus(i, "Concise");
	end
end

local function PlayAttributeAnimation()
	for i=1, #statTable do
		statTable[i].animIn.A2:SetToAlpha(statTable[i]:GetAlpha());
		statTable[i].animIn:Play();
	end
	Narci_RadarChartFrame.animIn:Play();
end

local function ShowAttributeButton(bool)
	local state = bool or true;
	if state then
		if NarcissusDB.DetailedIlvlInfo then
			AAADetailedStatFrame:SetShown(true);
			AAAConsiceStatFrame:SetShown(false);
		else
			AAADetailedStatFrame:SetShown(false);
			AAAConsiceStatFrame:SetShown(true);
		end
		Narci_IlvlInfoFrame:SetShown(true);
	else
		AAADetailedStatFrame:SetShown(false);
		AAAConsiceStatFrame:SetShown(false);
		Narci_IlvlInfoFrame:SetShown(false);
	end

end

local function AssignFrame()
	local slotFrame = Narci_Character;

	slotTable[1] = slotFrame.HeadSlot;
	slotTable[2] = slotFrame.NeckSlot;
	slotTable[3] = slotFrame.ShoulderSlot;
	slotTable[4] = slotFrame.ShirtSlot;
	slotTable[5] = slotFrame.ChestSlot;
	slotTable[6] = slotFrame.WaistSlot;
	slotTable[7] = slotFrame.LegsSlot;
	slotTable[8] = slotFrame.FeetSlot;
	slotTable[9] = slotFrame.WristSlot;
	slotTable[10] = slotFrame.HandsSlot;
	slotTable[11] = slotFrame.Finger0Slot;
	slotTable[12] = slotFrame.Finger1Slot;
	slotTable[13] = slotFrame.Trinket0Slot;
	slotTable[14] = slotFrame.Trinket1Slot;
	slotTable[15] = slotFrame.BackSlot;
	slotTable[16] = slotFrame.MainHandSlot;
	slotTable[17] = slotFrame.SecondaryHandSlot;
	slotTable[18] = slotFrame.TabardSlot;		--=RangedSlot; --abandoned
	slotTable[19] = slotFrame.TabardSlot;

	local statFrame = AAADetailedStatFrame;
	statTable[1] = statFrame.Primary;
	statTable[2] = statFrame.Stamina;
	statTable[3] = statFrame.Damage;
	statTable[4] = statFrame.AttackSpeed;
	statTable[5] = statFrame.Energy;
	statTable[6] = statFrame.Regen;
	statTable[7] = statFrame.Health;
	statTable[8] = statFrame.Armor;
	statTable[9] = statFrame.Reduction;
	statTable[10]= statFrame.Dodge;
	statTable[11]= statFrame.Parry;
	statTable[12]= statFrame.Block;
	statTable[13]= statFrame.Crit;
	statTable[14]= statFrame.Haste;
	statTable[15]= statFrame.Mastery;
	statTable[16]= statFrame.Versatility;
	statTable[17]= statFrame.Leech;
	statTable[18]= statFrame.Avoidance;
	statTable[19]= statFrame.MovementSpeed;
	statTable[20]= statFrame.Speed;

	local statFrame_Short = AAAConsiceStatFrame;
	statTable_Short[1]  = statFrame_Short.Primary;
	statTable_Short[2]  = statFrame_Short.Stamina;
	statTable_Short[3]  = statFrame_Short.Health;
	statTable_Short[4]  = statFrame_Short.Energy;
	statTable_Short[5]  = statFrame_Short.Regen;
	statTable_Short[6]  = statFrame_Short.Crit;
	statTable_Short[7]  = statFrame_Short.Haste;
	statTable_Short[8]  = statFrame_Short.Mastery;
	statTable_Short[9]  = statFrame_Short.Versatility;
	statTable_Short[10] = statFrame_Short.Leech;
	statTable_Short[11] = statFrame_Short.Avoidance;
	statTable_Short[12] = statFrame_Short.Speed;
end

function Narci_AliasButton_OnClick(self)
	local editBox = PlayerInfoFrame.PlayerName;
	NarcissusDB_PC.UseAlias = not NarcissusDB_PC.UseAlias;

	if NarcissusDB_PC.UseAlias then
		self.Label:SetText(NARCI_ALIAS_USE_PLAYER_NAME)
		editBox:Enable()
		editBox:SetFocus();
		editBox:SetText(NarcissusDB_PC.PlayerAlias or UnitName("player"))
		editBox:HighlightText();
	else
		self.Label:SetText(NARCI_ALIAS_USE_ALIAS)

		local text = strtrim(editBox:GetText());
		editBox:SetText(text);
		NarcissusDB_PC.PlayerAlias = text;
		editBox:Disable();
		editBox:HighlightText(0,0)
		editBox:SetText(UnitName("player"));
	end
	self:SetWidth(self.Label:GetWidth() + 12)
	local LetterNum = editBox:GetNumLetters()
	local w = math.max(LetterNum*16, 160)
	editBox:SetWidth(w);
end


ACL:Hide();
ACL:RegisterEvent("VARIABLES_LOADED");
ACL:RegisterEvent("PLAYER_ENTERING_WORLD");
ACL:RegisterEvent("UNIT_NAME_UPDATE");
ACL:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
ACL:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE");
ACL:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
ACL:RegisterEvent("PLAYER_LEVEL_UP");
ACL:RegisterEvent("UNIT_MAXPOWER");
ACL:RegisterEvent("PLAYER_REGEN_DISABLED");
ACL:SetScript("OnEvent",function(self,event,...)
	--print(event)
		
	if event == "VARIABLES_LOADED" then
		local function ShouldShowSplash()
			if Current_Version > NarcissusDB.Version then
				if not Narci_Splash then
					CreateFrame("Frame", "Narci_Splash", nil, "Narci_Splash_Template")
				end
				VignetteRightLarge.animIn:SetScript("OnFinished", function()
					NarcissusDB.Version = Current_Version;
					Narci_Vignette_OnFinished();
					Narci_Splash.Black.animIn:Play();
					VignetteRightLarge.animIn:SetScript("OnFinished", Narci_Vignette_OnFinished);
				end)
			end
		end
		ShouldShowSplash()
		AssignFrame();
		Narci_AliasButton_SetState();
		Narci_SetActiveBorderTexture();
		AAAStatus_OnLoad(Narci_Attribute);
		Narci_MinimapButton_OnLoad();
		C_Timer.After(2, function()
			RefreshAllStatus();
			SetRadarChart();
			CacheSourceInfo();
			XmogName_OnLoad();
		end)
		C_Timer.After(5, function()
			RefreshAllSlot();					--Using "MogIt" seems to cause problem, so it has to cache 2 times (this is a temporary workaround)
		end)
	elseif event == "PLAYER_ENTERING_WORLD" then
		ShowDetailedIlvlInfo()
		CharacterInfoFrame_OnLoad()
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		local InventorySlotId, isItem = ...;
		CacheSourceInfo(InventorySlotId)

		if Narci_EquipmentFlyoutFrame:IsShown() and Narci_EquipmentFlyoutFrame.slotID == InventorySlotId then
			Narci_BuildFlyout(InventorySlotId)
		end
		
		RefreshSlot(InventorySlotId);
		CacheSourceInfo(InventorySlotId);
	elseif event == "PLAYER_AVG_ITEM_LEVEL_UPDATE" then
		SetIlvlBackground();
	elseif event == "UNIT_NAME_UPDATE" then
		local UnitID = ...;
		if UnitID == "player" then
			CharacterInfoFrame_OnLoad()
		end

	elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
		CharacterInfoFrame_OnLoad()

	elseif event == "PLAYER_LEVEL_UP" then
		local NewLevel = ...;
		CharacterInfoFrame_OnLoad(NewLevel)

	elseif ( event == "COMBAT_RATING_UPDATE" or
			 event == "UNIT_MAXPOWER" or
			 event == "UNIT_AURA") then
		RefreshAllStatus();
		if event == "COMBAT_RATING_UPDATE" then
			if Narci_Character:IsShown() then
				SetRadarChart();
			end
		end
	elseif event == "PLAYER_TARGET_CHANGED" then
		RefreshStatus(9) 		--Damage Reduction
	elseif event == "UNIT_MODEL_CHANGED" then
		local unit = ...;
		if unit == "player" then
			Narci_CharacterModelFrame:Dress()
		end
	elseif event == "UPDATE_SHAPESHIFT_FORM" then
		ModifyCameraForShapeshifter();
		AAACameraZoomIn(ZoomInValue);
		--print("Shape shift")
	elseif event == "PLAYER_MOUNT_DISPLAY_CHANGED" then
		ModifyCameraForMounts();
		AAACameraZoomIn(ZoomInValue);
	elseif event == "PLAYER_REGEN_DISABLED" then
		Narci_Character:Hide();
	elseif event == "PLAYER_STARTED_MOVING" then
		MoveViewRightStop();
	end
end)
ACL:SetScript("OnShow",function(self)
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("COMBAT_RATING_UPDATE");
	self:RegisterEvent("UNIT_AURA");
	self:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED");
	self:RegisterEvent("PLAYER_STARTED_MOVING");
end)
ACL:SetScript("OnHide",function(self)
	self:UnregisterEvent("COMBAT_RATING_UPDATE");
	self:UnregisterEvent("PLAYER_TARGET_CHANGED");
	self:UnregisterEvent("UNIT_AURA");
	self:UnregisterEvent("UPDATE_SHAPESHIFT_FORM");
	self:UnregisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED");
	self:UnregisterEvent("PLAYER_STARTED_MOVING");
end)

--local defaultVolume
local MusicIO = CreateFrame("Frame", "Narci_MusicInOut");
MusicIO.TimeSinceLastUpdate = 0;
MusicIO:Hide()

local function MusicIO_Update(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
	local volume;
	if self.State then
		volume = math.max((self.TimeSinceLastUpdate/2), CVar_Temp.MusicVolume)
	else
		volume = math.max((self.StartVolume - self.TimeSinceLastUpdate/2), CVar_Temp.MusicVolume)
	end
	SetCVar("Sound_MusicVolume",volume)

	if (self.State and volume >= 1) or ((not self.State) and volume <= tonumber(CVar_Temp.MusicVolume)) then
		self:Hide()
		self.TimeSinceLastUpdate = 0;
	end
end

MusicIO:SetScript("OnShow", function(self)
	self.StartVolume = GetCVar("Sound_MusicVolume") or 1;
end)
MusicIO:SetScript("OnUpdate", MusicIO_Update)
MusicIO:SetScript("OnHide", function(self)
	self.TimeSinceLastUpdate = 0;
end)

local function SmoothMusicVolume(state)
	if state then
		if not NarcissusDB.FadeMusic then
			return;
		end
	end

	MusicIO:Hide()
	MusicIO.State = state
	MusicIO:Show()
end

function Narci_Open()
	
	--ForceTooltipToShow(); --Make GameTooltip visible while the UIParent is hidden
	PhotoModeController.PhotoModeController_AnimFrame.toAlpha = 1;
	if not OpenViaClick then
		if InCombatLockdown() then
			return;
		end
		CVar_Temp.ActioncamState = tonumber(GetCVar("test_cameraDynamicPitch"));
		CVar_Temp.OverShoulder = GetCVar("test_cameraOverShoulder");
		CVar_Temp.MusicVolume = GetCVar("Sound_MusicVolume");
		SaveView(5)
		ModifyCameraForShapeshifter();
		xmogMode = 0;
		Narci_CharacterModelFrame.xmogMode = 0;
		hasSet = false;
		local speedFactor = 180/(GetCVar("cameraYawMoveSpeed") or 180);
		ZoomFactor.EndSpeed = speedFactor*ZoomFactor.EndSpeedBasic;
		ZoomFactor.StartSpeed = speedFactor*ZoomFactor.StartSpeedBasic;
		Narci_FlyoutBlack:SetAlpha(0);
		SmoothMusicVolume(true);
		RefreshAllSlot();
		SetRadarChart();
		ACL:Show();
		Narci_LetterboxAnimation();
		PhotoModeController:Show();
		OpenViaClick = true;
		XmogButton:Enable();
		
		ZoomTest()
		Narci_Vignette.VignetteLeft:SetAlpha(VignetteAlpha);
		Narci_Vignette.VignetteRight:SetAlpha(VignetteAlpha);
		Narci_Vignette.VignetteRightSmall:SetAlpha(0);
		UIFrameFadeIn(Narci_Vignette, 1, Narci_Vignette:GetAlpha(), 1);
		Narci_Vignette.VignetteRight.animIn:Play();
		Narci_Vignette.VignetteLeft.animIn:Play();

		if UIParent:IsShown() then
			--UIFrameFadeOut(UIParent, 0.5, 1, 0)
			UIPA:Show();
		end
		SetCVar("test_cameraDynamicPitchSmartPivotCutoffDist", 10);

		C_Timer.After(0.5, function()
			SetUIVisibility(false); 		--Same as pressing Alt + Z
		end)

		C_Timer.After(0.8, function()
			UIParent:SetAlpha(1);
		end)
	else
		PlaySlotAnimOut();
		ResetCamera();
		SmoothMusicVolume(false);
		Narci_LetterboxAnimation("OUT");
		if Narci_TitleManager_Switch.IsOn then
			Narci_TitleManager_Switch:Click();
		end
		Narci_EquipmentFlyoutFrame:Hide();
		Narci_TitleManager_TitleTooltip:Hide();		--TitleManager

		local frame = PhotoModeController;
		frame.PhotoModeController_AnimFrame.OppoDirection = true;
		frame.PhotoModeController_AnimFrame:Hide();
		frame.PhotoModeController_AnimFrame.EndPointY = "-80"
		frame.PhotoModeController_AnimFrame.toAlpha = 0;
		frame.PhotoModeController_AnimFrame:Show();
		TakeOutFromUIParent(GameTooltip, "TOOLTIP", false);
		TakeOutFromUIParent(AzeriteEmpoweredItemUI, "MEDIUM", false);
		TakeOutFromUIParent(AzeriteEssenceUI, "MEDIUM", false);
		TakeOutFromUIParent(ArtifactFrame, "MEDIUM", false);
		TakeOutFromUIParent(ItemSocketingFrame, "MEDIUM", false);
	end
end

local function LanguageDetector(string)
	local str = string
	local len = strlen(str)
	local i = 1
	while i <= len do
		local c = string.byte(str, i)
		local shift = 1
		--print(c)
		if (c > 0 and c <= 127)then
			shift = 1
		elseif c== 195 then
			shift = 2	--Latin/Greek
		elseif (c >= 208 and c <=211) then
			shift = 2
			return "RU" --RU included
		elseif (c >= 224 and c <= 227) then
			shift = 3	--JP
			return "JP"
		elseif (c >= 228 and c <= 233) then
			shift = 3	--CN
			return "CN"
		elseif (c >= 234 and c <= 237) then
			shift = 3	--KR
			return "KR"
		elseif (c >= 240 and c <= 244) then
			shift = 4	--Unknown invalid
		end
		local char = string.sub(str, i, i+shift-1)
		i = i + shift
	end
	return "RM"
end

--[[
function LDTest(string)
	local str = string
	local lenInByte = #str
	
	for i=1,lenInByte do
		local char = strsub(str, i,i)
		local curByte = string.byte(str, i)
		print(char.." "..curByte)
	end
	return "roman"
end

local Eng = "abcdefghijklmnopqrstuvwxyz" --abcdefghijklmnopqrstuvwxyz Z~90 z~122 1-1
local DE =  "äöüß" --195 1-2
local CN =  "乀氺" --228 229 230 233 HEX E4-E9 Hexadecimal UTF-8 CJK
local KR = "제" --237 236 235 234 1-3  EB-ED
local RU = "ѱӧ" --D0400-D04C0  208 209 210 211 1-2
local FR = "ÀÃÇÊÉÕàãçêõáéíóúà" --1-2 195 C3 -PR
local JP = "ひらがな" --1-3 227 E3 Kana
--LDTest("繁體繁体")
--local language = LanguageDetector("繁體中文")
--print("Str is: "..language)
--]]

local PlayerNameFont={
	["CN"] = "Interface\\AddOns\\Narcissus\\Font\\NotoSansCJKsc-Medium.otf",
	["RM"] = "Interface\\AddOns\\Narcissus\\Font\\SemplicitaPro-Semibold.otf",
	["RU"] = "Interface\\AddOns\\Narcissus\\Font\\NotoSans-Medium.ttf",
	["KR"] = "Interface\\AddOns\\Narcissus\\Font\\NotoSansCJKsc-Medium.otf",
	["JP"] = "Interface\\AddOns\\Narcissus\\Font\\NotoSansCJKsc-Medium.otf",
}

function SmartFontType(self)
	local str = self:GetText();
	local Language = LanguageDetector(str);
	--print("Language is: "..Language);
	local Height = self:GetHeight();
	if Language and PlayerNameFont[Language] then
		self:SetFont(PlayerNameFont[Language] , Height);
	end
	--[[
	if Language == "CN" then
		self:SetFont(PlayerNameFont["CN"] , Height)
	else
		self:SetFont(PlayerNameFont["RM"] , Height)
	end
	--]]
end

function Narci_AliasButton_SetState()
	local editBox = PlayerInfoFrame.PlayerName;
	local button = Narci_AliasButton;

	if NarcissusDB_PC.UseAlias then
		editBox:Enable();
		editBox:SetText((NarcissusDB_PC.PlayerAlias or UnitName("player")));
		button.Label:SetText(NARCI_ALIAS_USE_PLAYER_NAME);
	else
		editBox:Disable();
		button.Label:SetText(NARCI_ALIAS_USE_ALIAS);
	end

	local LetterNum = editBox:GetNumLetters()
	local w = math.max(LetterNum*16, 160)
	editBox:SetWidth(w);

	button:SetWidth(button.Label:GetWidth() + 12)
end

function Narci_SetPlayerName(self)
	local Height = 24
	local playerName = UnitName("player");
	local Language = LanguageDetector(playerName)
	if Language and PlayerNameFont[Language] then
		self.PlayerName:SetFont(PlayerNameFont[Language] , Height);
	end

	self.PlayerName:SetShadowColor(0, 0, 0)
	self.PlayerName:SetShadowOffset(2, -2)
	self.PlayerName:SetText(playerName);
end

---Widgets---

function CameraControllerThumb_OnLoad(self)
	self:RegisterForClicks("RightButtonUp")
	self:RegisterForDrag("LeftButton")
	self.Reading:SetText(string.format(Format_Digit, 0))
end

local function CameraControlBarThumb_Reposition(self, ofsx)
	self:GetParent().Thumb:SetPoint("CENTER", ofsx, 0);
	CameraOffsetControlBar.PosX = ofsx
	SetCVar("test_cameraOverShoulder", 0 - ofsx/20)	--Ajust the Zoom - Shoulder factor
	--Shoulder_Factor2 = Shoulder_Factor2_Defalut + ofsx/100
	--Shoulder_Factor1 = Shoulder_Factor1_Defalut + ofsx/100
	--Smooth_ShoulderCvar(Shoulder_Factor1*Zoom - Shoulder_Factor2)
	local currentShoulder = GetCVar("test_cameraOverShoulder")
	local Zoom = GetCameraZoom()
	--self:GetParent().Thumb.Reading:SetText(Zoom.." | "..string.format("%.4f", currentShoulder))
end

function CameraControlBar_DraggingFrame_OnUpdate(self)
	local scale = self:GetParent():GetEffectiveScale()
	local xpos, _ = GetCursorPosition() / scale
	--xpos = xpos	* scale
	local xmin, xmax = self:GetParent():GetLeft() + 18 , self:GetParent():GetRight() - 18
	CameraOffsetControlBar.Range = xmax - xmin
	--xmin, xmax = xmin *scale, xmax *scale
	--print(xmin.." "..xmax)
	local xcenter, _ = self:GetParent():GetCenter()
	local ofsx;
	if xpos < xmin then
		ofsx = xmin - xcenter;
	elseif xpos > xmax then
		ofsx = xmax - xcenter;
	else
		ofsx = xpos - xcenter;
	end
	--print(ofsx)
	CameraControlBarThumb_Reposition(self, ofsx) 
end

function CameraControlBarThumb_OnClick(self, button, down)
	--self:GetParent().Thumb:SetPoint("CENTER", 0, 0);
	self:Disable()
	CameraControlBar_ResetPosition_AnimFrame.OppoDirection = true
	CameraControlBar_ResetPosition_AnimFrame:Show();
	C_Timer.After(0.6, function()
		self:Enable()
		CameraOffsetControlBar.PosX = 0;
		CameraOffsetControlBar.PosRadian = 0;
	end)
	local Zoom = GetCameraZoom()
	Smooth_ShoulderCvar(Shoulder_Factor1*Zoom - Shoulder_Factor2)
	self:GetParent().Thumb.Reading:SetText(string.format(0))
end

local function rotateFrame(frame, Degree)
    local ag = frame:CreateAnimationGroup()    
    local a1 = ag:CreateAnimation("Rotation")
	a1:SetDegrees(Degree)
	a1:SetOrigin("LEFT",0 ,0) 
	a1:SetOrder(1)
	a1:SetDuration(0)
	local a2 = ag:CreateAnimation("Rotation")
	a2:SetDegrees(0)
	a2:SetOrigin("LEFT",0 ,0) 
	a2:SetOrder(2)
    a2:SetDuration(1)       
	ag:Play()
	ag:Pause()  
end

local Shaftdiameter = 53;
local lastDegree = 0;
local tinyIncre = 1000;

local function TinyZoom(degree, lastDegree)
	if (degree >= 0 and lastDegree >= 0) or (degree <= 0 and lastDegree <= 0) then
		if degree < lastDegree then
			CameraZoomIn((lastDegree - degree)/tinyIncre);
		elseif degree > lastDegree then
			CameraZoomOut((degree - lastDegree)/tinyIncre);
		end
	elseif degree >= 0 and lastDegree < 0 then
		if degree >= 90 then
			CameraZoomIn((180 - degree)/tinyIncre);
		else
			CameraZoomOut((0 + degree)/tinyIncre);
		end
	elseif degree <= 0 and lastDegree > 0 then
		if degree <= -90 then
			CameraZoomOut((180 + degree)/tinyIncre);
		else
			CameraZoomIn((0 - degree)/tinyIncre);
		end
	end
end

local function RotateShaftNode(radian)
	local ofsx = Shaftdiameter*math.cos(radian)
	local ofsy = Shaftdiameter*math.sin(radian)
	CameraControllerNode:SetPoint("CENTER", "CameraControllerThumb", "CENTER", ofsx, ofsy);
	CameraControllerThumb.Shaft:SetRotation(radian)
end

function CameraZoomController_DraggingFrame_OnUpdate(self)
	local scale = self:GetParent():GetEffectiveScale()
	local xpos, ypos = GetCursorPosition()
	xpos, ypos = xpos/scale, ypos/scale
	local radian = math.atan2( (ypos - self.cy),(xpos - self.cx))
	RotateShaftNode(radian);
	CameraOffsetControlBar.PosRadian = radian;
	local degree = math.deg(radian)

	--rotateFrame(self:GetParent().Shaft, degree - lastDegree)
	if not self.isPressed then
		TinyZoom(degree, lastDegree)
	else
		if degree < 0 then
			CameraZoomIn( (-degree)/tinyIncre)
		elseif degree > 0 then
			CameraZoomOut( (degree)/tinyIncre)
		end
	end

	lastDegree = degree;
end



------------------------------------------------------
------------------Photo Mode Controller---------------
------------------------------------------------------
SetCVar("screenshotQuality", 10)

function KeyListener_OnEscapePressed()
	if OpenViaClick then
		Narci_MinimapButton:Click()
	end
end

local function TokenButton_ClearMarker(self)
	local parent = self:GetParent();
	if parent.buttons then
		for i=1, #parent.buttons do
			parent.buttons[i].HighlightColor:Hide();
		end
	end
end

---Set Graphics Settings to Ultra---
local PhotoMode_Cvar_GraphicsBackup = {};
local PhotoMode_Cvar_GraphicsList = {
	["ffxAntiAliasingMode"] = 2,

	["graphicsTextureResolution"] = 3,
	["graphicsTextureFiltering"] = 6,
	["graphicsProjectedTextures"] = 2,

	["graphicsViewDistance"] = 10,
	["graphicsEnvironmentDetail"] = 10,
	["graphicsGroundClutter"] = 10,

	["graphicsShadowQuality"] = 6,
	["graphicsLiquidDetail"] = 4,
	["graphicsSunshafts"] = 3,
	["graphicsParticleDensity"] = 5,
	["graphicsSSAO"] = 5,
	["graphicsDepthEffects"] = 4,
	--["graphicsLightingQuality"] = 3,
	["lightMode"] = 2,
	["MSAAQuality"] = 4,	--4 is invalid. But used for backup
}

---Hide Names and Bubbles---
local PhotoMode_Cvar_TrackingList = 1		--Track Battle Pet
local PhotoMode_Cvar_TrackingBAK = true;
local PhotoMode_Cvar_NamesBackup = {};
local PhotoMode_Cvar_NamesList = {			--Unit Name CVars
	["UnitNameOwn"] = 0,
	["UnitNameNonCombatCreatureName"] = 0,
	["UnitNameFriendlyPlayerName"] = 0,
	["UnitNameFriendlyPetName"] = 0,
	["UnitNameFriendlyMinionName"] = 0,
	["UnitNameFriendlyGuardianName"] = 0,
	["UnitNameEnemyPlayerName"] = 0,
	["UnitNameEnemyPetName"] = 0,
	["UnitNameEnemyGuardianName"] = 0,
	["UnitNameNPC"] = 0,
	["UnitNameInteractiveNPC"] = 0,
	["UnitNameHostleNPC"] = 0,
	["chatBubbles"] = 0,
	["floatingCombatTextCombatDamage"] = 0,
	["floatingCombatTextCombatHealing"] = 0,
};

local function PhotoMode_BackupCvar(BackupTable, OriginalTable)
	if OriginalTable then
		for k, v in pairs(OriginalTable) do
			BackupTable[k] = GetCVar(k) or 0;
		end
	end
end

local function PhotoMode_RestoreCvar(BackupTable) --it can also be used to set CVars to pre-defined values
	if BackupTable then
		for k, v in pairs(BackupTable) do
			SetCVar(k, v)
			--print(k.." "..v)
		end
	end
end

local function PhotoMode_ZeroCvar(BackupTable)
	if BackupTable then
		for k, v in pairs(BackupTable) do
			SetCVar(k, 0)
		end
	end	
end

local function PhotoMode_GetTrackingInfo(id)
	local id = 1;
	local _, _, active = GetTrackingInfo(id)
	PhotoMode_Cvar_TrackingBAK = active;
end

local ControllerButtonTooltip = {
    -- [ Name ] = { HeadLine, Line, Special } 
	["PhotoModeButton"] = {
		L["Photo Mode"],
		L["Photo Mode Tooltip Open"],
		L["Photo Mode Tooltip Close"],
		L["Photo Mode Tooltip Special"],
	},

	["XmogButton"] = {
		L["Xmog Button"],
		L["Xmog Button Tooltip Open"],
		L["Xmog Button Tooltip Close"],
		L["Xmog Button Tooltip Special"],
	},

	["EmoteButton"] = {
		L["Emote Button"],
		L["Emote Button Tooltip Open"],
		nil,
		L["Emote Button Tooltip Special"],
	},

	["HideTextsButton"] = {
		L["HideTexts Button"],
		L["HideTexts Button Tooltip Open"],
		L["HideTexts Button Tooltip Close"],
		L["HideTexts Button Tooltip Special"],
	},

	["TopQualityButton"] = {
		L["TopQuality Button"],
		L["TopQuality Button Tooltip Open"],
		L["TopQuality Button Tooltip Close"],
		L["HideTexts Button Tooltip Special"],
	},
}

function ControllerButtonTemplate_OnLoad(self)
	self.IsOn = false;
	local name = self:GetName();

	if ControllerButtonTooltip[name] then
		self.tooltipHeadline = ControllerButtonTooltip[name][1];
		self.tooltipLineOpen = ControllerButtonTooltip[name][2];
		if ControllerButtonTooltip[name][3] then
			self.tooltipLineClose = ControllerButtonTooltip[name][3];
		else
			self.tooltipLineClose = self.tooltipLineOpen;
		end
		self.tooltipSpecial = ControllerButtonTooltip[name][4];
	end

	if self.Pushed and self.Icon then
		self.Pushed:SetTexture(self.Icon:GetTexture())
	end
end

local function TemporarilyHidePopUp(frame)
	if frame:IsShown() then
		frame.AnimFrame:Hide();
		frame.AnimFrame.OppoDirection = true		
		frame.AnimFrame:Show();
		frame.AnimFrame.EndPointY = -20;
	end
end

function Narci_ShowXmogSlot()
	local scale = Narci_Finger0Slot:GetEffectiveScale()
	Narci_GuideLineFrame.VirtualLineRight:SetPoint("RIGHT", -10, 0);
	Narci_GuideLineFrame.VirtualLineRight.AnimFrame.StartPoint = -10;
	Narci_GuideLineFrame.VirtualLineRight.AnimFrame.EndPoint = -80 - scale*Narci_Finger0Slot:GetWidth()/2;
	--UIFrameFadeIn(Narci_Character, 0.6, 0, 1);
	FadeFrame(Narci_Character, 0.6, "Forced_IN")
	Narci_GuideLineFrame.VirtualLineLeft.AnimFrame:Show();
	Narci_GuideLineFrame.VirtualLineRight.AnimFrame:Show();
end

function XmogButtonPopUp_OnShow(self)
	SetWidgetColor(self.Color);
	SetWidgetColor(self.Option);
end

function XmogButtonPopUp_OnLoad(self)
	self.CopyButton.Label:SetText(NARCI_COPY_TEXTS)
	self.ModeButton.Background:SetColorTexture(0.06, 0.06, 0.06, 0.8)
	self.ModeButton.Label:SetText(NARCI_LAYOUT)
	self.ModeButton.Option:SetText(NARCI_LAYOUT_SYMMETRY)
	self.ModelToggle.Label:SetText(NARCI_3DMODEL)
	SetWidgetColor(self.ModeButton.Option)

	local SyntaxButton = self.CopyButton.GearTexts
	SyntaxButton.PlainText.Background:SetColorTexture(0.06, 0.06, 0.06, 0.8)
	SyntaxButton.BBSCode.Background:SetColorTexture(0.06, 0.06, 0.06, 0.8)
	SyntaxButton.Markdown.Background:SetColorTexture(0.06, 0.06, 0.06, 0.8)
	SyntaxButton.PlainText.Label:SetText(NARCI_SYNTAX_PLAIN_TEXT)
	SyntaxButton.BBSCode.Label:SetText(NARCI_SYNTAX_BBCODE)
	SyntaxButton.Markdown.Label:SetText(NARCI_SYNTAX_MARKDOWN)

end

local function HidePlayerModel()
	if (not Narci_CharacterModelFrame:IsShown()) or (NarcissusDB.AlwaysShowModel) then	return; end
	PlayerModelAnimOut:Show()
	C_Timer.After(0.4, function()
		FadeFrame(Narci_CharacterModelFrame, 0.5 , "OUT")
	end)
end

local function UseXmogLayout(index)
	if index == 1 then
		xmogMode = 1;
		Narci_CharacterModelFrame.xmogMode = 1;
		Narci_XmogButtonPopUp_ModeButton.Option:SetText(NARCI_LAYOUT_SYMMETRY)
		SP:Show()
		HidePlayerModel()
		Smooth_Shoulder.EndPoint = 0.01;
		Smooth_Shoulder:Show()
		Narci_GuideLineFrame.VirtualLineRight.AnimFrame.EndPoint = -80;
		Narci_GuideLineFrame.VirtualLineRight.AnimFrame:Show()
		Smooth_ShoulderCvar(0.01)
		Narci_XmogButtonPopUp_ModeButton.ShowModel = false;

		if NarcissusDB.AlwaysShowModel then
			Narci_CharacterModelFrame.Color1:Hide();
			ModelVignetteRightSmall:Hide();
		end
	elseif index == 2 then
		xmogMode = 2;
		Narci_CharacterModelFrame.xmogMode = 2;
		FadeFrame(Narci_CharacterModelFrame.Color1, 0.5, "IN")
		Narci_XmogButtonPopUp_ModeButton.Option:SetText(NARCI_LAYOUT_ASYMMETRY)
		if not Narci_CharacterModelFrame:IsShown() then
			PlayerModelAnimIn:Show()
		end
		ModelVignetteRightSmall:Show();
		Narci_GuideLineFrame.VirtualLineRight.AnimFrame.EndPoint = -600
		Narci_GuideLineFrame.VirtualLineRight.AnimFrame:Show()
		Narci_XmogButtonPopUp_ModeButton.ShowModel = true;
	end
end

local function ActiveXmogMode()
	Narci_GuideLineFrame.VirtualLineRight.AnimFrame:Hide();

	if TransmogMode then
		FadeFrame(Narci_Attribute, 0.5, "OUT")
		FadeFrame(Narci_XmogNameFrame, 0.5, "IN")
		local DefaultLayout = NarcissusDB.DefaultLayout;
		if DefaultLayout == 1 then
			xmogMode = 1;
		elseif DefaultLayout == 2 then
			xmogMode = 2;
		elseif DefaultLayout == 3 then
			xmogMode = 2;
		end

		UseXmogLayout(xmogMode);
		--print(xmogMode)
		Narci_CharacterModelFrame.xmogMode = xmogMode;
	else
		Narci_GuideLineFrame.VirtualLineRight.AnimFrame.EndPoint = Narci_GuideLineFrame.VirtualLineRight.AnimFrame.EndPointBAK
		if PhotoModeController:IsShown() then
			Narci_GuideLineFrame.VirtualLineRight.AnimFrame:Show()
			FadeFrame(Narci_Attribute, 0.5, "IN")
			local Zoom = GetCameraZoom()
			Smooth_ShoulderCvar(Shoulder_Factor1*Zoom - Shoulder_Factor2)
		end
		FadeFrame(Narci_XmogNameFrame, 0.5, "OUT")
		ShowAttributeButton(true);
		xmogMode = 0;
		Narci_CharacterModelFrame.xmogMode = 0;
	end
end

function XmogButton_OnClick(self)
	self.IsOn = not self.IsOn
	MoveViewRightStop();
	Narci_EquipmentFlyoutFrame:Hide();
	if not hasSet then
		hasSet = true;
		--SaveView(4)
	end

	TransmogMode = not TransmogMode;
	local PopUp = Narci_XmogButtonPopUp;
	if not self.IsOn then
		FadeFrame(VignetteRightSmall, 0.5, "OUT");
		UIFrameFadeIn(VignetteRightLarge, 0.5, VignetteRightLarge:GetAlpha(), NarcissusDB.VignetteStrength);

		Narci_SnowEffect(true);
		Narci_LetterboxAnimation();
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		self.Icon:SetTexCoord(0, 0.5, 0, 1);
		if NarcissusDB.EnableGrainEffect then
			FadeFrame(FullScreenFilterGrain, 0.5, "IN");
			FadeFrame(FullScreenFilterGrain2, 0.5, "IN");
		end
		PopUp.AnimFrame:Hide();
		PopUp.AnimFrame.OppoDirection = true
		PopUp.AnimFrame:Show();
		PopUp.AnimFrame.EndPointY = -20;
		if Narci_CharacterModelFrame:IsShown() then
			if OpenViaClick then
				SmoothPitchContainer:Show()
			else
				Smooth_ShoulderCvar(0)
			end
			PlayerModelAnimOut:Show()
			C_Timer.After(0.4, function()
				FadeFrame(Narci_CharacterModelFrame, 0.5 , "OUT")
			end)
		end
	else
		UIFrameFadeIn(VignetteRightSmall, 0.5, VignetteRightSmall:GetAlpha(), NarcissusDB.VignetteStrength);
		FadeFrame(VignetteRightLarge, 0.5, "OUT");
		FadeFrame(FullScreenFilterGrain, 0.5, "OUT");
		FadeFrame(FullScreenFilterGrain2, 0.5, "OUT");
		Narci_SnowEffect(false);
		Narci_LetterboxAnimation("OUT");
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		self.Icon:SetTexCoord(0.5, 1, 0, 1);
		PopUp:Show();
		PopUp.AnimFrame:Hide();
		PopUp.AnimFrame.OppoDirection = false		
		PopUp.AnimFrame:Show();
		PopUp.AnimFrame.EndPointY = 8;
		Narci_XmogNameFrame.PlayerName:SetText(PlayerInfoFrame.PlayerName:GetText())
		if NarcissusDB.AlwaysShowModel then
			PlayerModelAnimIn:Show()
		end
	end
	
	RefreshAllSlot();
	ActiveXmogMode();

	C_Timer.After(1, function()			--solve cache issue
		RefreshAllSlot()
	end)

	HideButtonTooltip();

	TemporarilyHidePopUp(EmoteButtonPopUp)
end

function XmogName_OnLoad()
	local Frame = Narci_XmogNameFrame;
	Narci_SetPlayerName(Frame)
	local currentSpecName;
	local currentSpec = GetSpecialization()
	if currentSpec then
	   _, currentSpecName = GetSpecializationInfo(currentSpec)
	else
		currentSpecName = " "
	end

	local className, englishClass, classID = UnitClass("player");
	local _, _, _, rgbHex = GetClassColor(englishClass);

	local ArmorType
	local Token

	if IsSpellKnown(76273) or IsSpellKnown(106904) or IsSpellKnown(202782) or IsSpellKnown(76275) then
		--ArmorType = "Leather"
		Token = 159300
	elseif IsSpellKnown(76250) or IsSpellKnown(76272) then
		--ArmorType = "Mail"
		Token = 159371
	elseif IsSpellKnown(76276) or IsSpellKnown(76277) or IsSpellKnown(76279) then
		--ArmorType = "Cloth"
		Token = 159243
	elseif IsSpellKnown(76271) or IsSpellKnown(76282) or IsSpellKnown(76268) then
		--ArmorType = "Plate"
		Token = 159418
	end

	local _, _, ArmorType = GetItemInfoInstant(Token)
	--Leather 76273		Mail 76250		Cloth 76276	76279	Plate 76271 76282
	ArmorType = ArmorType or "ArmorType"
	Frame.Miscellaneous:SetText("|cFFFFD100"..ArmorType.."|r".."  |  ".."|c"..rgbHex..currentSpecName.." "..className.."|r");
end


local function CopyTexts(type, subType)
	local texts = Narci_XmogNameFrame.PlayerName:GetText() or "My Transmog";
	local type = type or "TEXT"
	local subType = subType or "Wowhead"
	local showItemID = Narci_XmogButtonPopUp.CopyButton.showItemID or false;
	local source;
	if type == "TEXT" then
		texts = texts.."\n"
		for i=1, #xmogTable do
			local index =  xmogTable[i][1]
			if slotTable[index] and slotTable[index].Name:GetText() then
				local text = "|cFFFFD100"..xmogTable[i][2]..":|r "..(slotTable[index].Name:GetText() or " ")

				if showItemID and slotTable[index].itemID then
					text = text.." |cFFacacac"..slotTable[index].itemID.."|r";
				end
				
				source = slotTable[index].ItemLevel:GetText()
				if source ~= " " then
				text = text.." |cFF40C7EB("..source..")|r"
				end
				if text then
					texts = texts.."\n"..text;
				end
			end
		end

	elseif type == "BBS" then
		if subType == "Wowhead" then
			texts = "|cFF959595[table border=2 cellpadding=4]\n[tr][td colspan=3 align=center][b]|r"..texts.."|r|cFF959595[/b][/td][/tr]\n[tr][td align=center]Slot[/td][td align=center]Name[/td][td align=center]Source[/td][/tr]|r"
		elseif subType == "NGA" then
			texts = "|cFF959595[table]\n[tr][td colspan=3][align=center][b]|r"..texts.."|r|cFF959595[/b][/align][/td][/tr]\n[tr][td][align=center]部位[/align][/td][td][align=center]装备名称[/align][/td][td][align=center]来源[/align][/td][/tr]|r"
		elseif subType == "mmo-champion" then
			texts =	"|cFF959595[table=\"width: 640, class: grid\"]\n[tr][td=\"colspan: 3\"][center][b]|r"..texts.."|r|cFF959595[/b][/center][/td][/tr]\n[tr][td][center]Slot[/center][/td][td][center]Name[/center][/td][td][center]Source[/center][/td][/tr]|r"
		end

		
		for i=1, #xmogTable do
			local index =  xmogTable[i][1]
			if slotTable[index] and slotTable[index].Name:GetText() then
				local text = "|cFF959595[tr][td]|r".."|cFFFFD100"..xmogTable[i][2].."|r|cFF959595[/td][td]|r"
				if showItemID and slotTable[index].itemID then
					if subType == "Wowhead" then
						text = text.."[item="..slotTable[index].itemID.."|r|cFF959595][/td]|r"
					elseif subType == "NGA" then
						text = text.."|cFF959595[url=https://www.wowhead.com/item="..slotTable[index].itemID.."]|r"..(slotTable[index].Name:GetText() or " ").."|cFF959595[/url][/td]|r"
					elseif subType == "mmo-champion" then
						text = text.."|cFF959595[url=https://www.wowdb.com/items/"..slotTable[index].itemID.."]|r"..(slotTable[index].Name:GetText() or " ").."|cFF959595[/url][/td]|r"
					end
				else
					text = text..(slotTable[index].Name:GetText() or " ").."|r|cFF959595[/td]|r"
				end
				source = slotTable[index].ItemLevel:GetText()
				if source then
					text = text.."|cFF959595[td]|r|cFF40C7EB"..source.."|r|cFF959595[/td]|r"
				else
					text = text.."|cFF959595[td] [/td]|r"
				end
				if text then
					texts = texts.."\n"..text.."|cFF959595[/tr]|r";
				end
			end
		end
		texts = texts.."\n|cFF959595[/table]|r"

	elseif type == "MARKDOWN" then	
		texts = "|cFF959595**|r"..texts.."|cFF959595**\n\n| Slot | Name | Source |".."\n".."|:--|:--|:--|"
		for i=1, #xmogTable do
			local index =  xmogTable[i][1]
			if slotTable[index] and slotTable[index].Name:GetText() then
				local text = "|cFF959595| |r|cFFFFD100"..xmogTable[i][2].."|r |cFF959595| |r"
				if	showItemID and slotTable[index].itemID then
					text = text.."|cFF959595[|r"..(slotTable[index].Name:GetText() or " ").."|cFF959595](https://www.wowhead.com/item=|r"..slotTable[index].itemID..")|r"
				else
					text = text..(slotTable[index].Name:GetText() or " ")
				end
				source = slotTable[index].ItemLevel:GetText()
				if source then
				text = text.." |cFF959595| |r|cFF40C7EB"..source.."|r |cFF959595| |r"
				else
					text = text.." |cFF959595| |r"
				end
				if text then
					texts = texts.."\n"..text;
				end
			end
		end
		texts = texts.."\n"
	end
	return texts;
end

local WebsiteTable = {
	[0] = {"reddit", "Interface/AddOns/Narcissus/Art/Logos/reddit"},
	[1] = {"Wowhead", "Interface/AddOns/Narcissus/Art/Logos/Wowhead"},
	[2] = {"NGA", "Interface/AddOns/Narcissus/Art/Logos/NGA"},
	[3] = {"mmo-champion", "Interface/AddOns/Narcissus/Art/Logos/mmo-champion"},
	--[4] = {"Vanion", "Interface/AddOns/Narcissus/Art/Logos/Vanion"},
}

function WebsiteButton_OnLoad(self)
	local index = self:GetID() or 2;
	if WebsiteTable[index] then
		self.NormalTex:SetTexture(WebsiteTable[index][2]);
		self.PushedTex:SetTexture(WebsiteTable[index][2]);
		if not self:GetParent().buttons then
			self:GetParent().buttons = {};
		end
		tinsert(self:GetParent().buttons, self);
	else
		self:Hide()
	end
end

local function WebsiteButton_DesatureLogo(self)
	local parent = self:GetParent();
	if parent.buttons then
		for i=1, #parent.buttons do
			parent.buttons[i].NormalTex:SetTexCoord(0, 0.5, 0, 1);
			parent.buttons[i].PushedTex:SetTexCoord(0, 0.5, 0, 1);
			parent.buttons[i].IsOn = false;
		end
	end
end

function WebsiteButton_OnClick(self)
	WebsiteButton_DesatureLogo(self)
	self.NormalTex:SetTexCoord(0.5, 1, 0, 1);
	self.PushedTex:SetTexCoord(0.5, 1, 0, 1);
	self.IsOn = true;
	self:GetParent().subType = WebsiteTable[self:GetID()][1];
	self:GetParent():Click();
end

local function SetClipboard(self, type, subType)
	local frame = self or Narci_XmogButtonPopUp.CopyButton;
	local type = type or frame.CodeType or "TEXT"
	local subType = subType or frame.GearTexts.BBSCode.subType or "Wowhead"
	local texts = CopyTexts(type, subType);
	frame.GearTexts:SetText(texts)

	if frame.GearTexts then
	frame.GearTexts:HighlightText()
	end
end

local CodeTokenList = {
	[1] = "TEXT",	[2] = "BBS", [3] = "MARKDOWN"
}

function CodeTokenButton_OnClick(self)
	self:GetParent():GetParent().CodeType = CodeTokenList[self:GetID()]
	SetClipboard()
	TokenButton_ClearMarker(self)
	self.HighlightColor:Show();

	self.AnimFrame.Anim:SetScale(1.8)
	self.AnimFrame.Anim.Bling:Play()
end

function IncludeIDButton_OnClick(self)
	self.IsOn = not self.IsOn
	if self.IsOn then
		self.Tick:Show();
		Narci_XmogButtonPopUp.CopyButton.showItemID = true;
	else
		self.Tick:Hide();
		Narci_XmogButtonPopUp.CopyButton.showItemID = false;
	end
	SetClipboard()
end

function CopyButton_OnClick(self)
	self.IsOn = not self.IsOn;
	if self.IsOn then
		SetClipboard(self)
		FadeFrame(self.GearTexts, 0.25, "IN")
	else
		FadeFrame(self.GearTexts, 0.25, "OUT")
	end

	self.AnimFrame.Anim:SetScale(1.5)
	self.AnimFrame.Anim.Bling:Play()
end

--EmoteButton
local EmoteTokenList = {
	[1] = {{"Talk", EMOTE94_CMD1},	{"TALKEX", EMOTE95_CMD1} , {"TALKQ", EMOTE96_CMD2} , {"Flee", YELL} },
	[2] = {{"Kiss", EMOTE59_CMD1}, {"Salute", EMOTE79_CMD1}	, {"Bye", EMOTE102_CMD1}, {"Bow", EMOTE17_CMD1} },
	[3] = {{"Dance", EMOTE35_CMD1}, {"Read", EMOTE453_CMD2}, {"Train", EMOTE155_CMD1}, {"Chicken", EMOTE22_CMD1} },
	[4] = {{"Clap", EMOTE24_CMD1}, {"Cheer", EMOTE21_CMD1}, {"Cackle", EMOTE61_CMD1} },
	[5] = {{"Nod", EMOTE68_CMD1}, {"Doubt", EMOTE67_CMD1}, {"Point", EMOTE73_CMD1} },
	[6] = {{"Rude", EMOTE78_CMD1}, {"Flex", EMOTE42_CMD1}, {"ROAR", EMOTE76_CMD1}},
	[7] = {{"Cower", EMOTE29_CMD1}, {"Beg", EMOTE8_CMD1}, {"Cry", EMOTE32_CMD1}},
	[8] = {{"Laydown", EMOTE62_CMD1}, {"Stand", EMOTE143_CMD1}, {"Sit", EMOTE87_CMD1}, {"Kneel", EMOTE60_CMD1}},
}

local function EmoteButton_CreateList(self, buttonTemplate, List)
	local PopUp = self;
	local button, buttonWidth, buttonHeight, buttons, numButtons;

	local parentName = self:GetName();
	local buttonName = parentName and (parentName .. "Button") or nil;

	local initialPoint = "TOPLEFT";
	local initialRelative = "TOPLEFT";
	local point = "TOPLEFT";
	local relativePoint = "TOPRIGHT";
	local offsetX = 0;

	buttons = {}

	local subListNum, subListNum_Max = 1, 1

	if List and List[1] then
		for i = 1, #List do
			subListNum = #List[i]
			subListNum_Max = math.max(subListNum, subListNum_Max);
		end
	end
	--print("subListNum_Max: "..subListNum_Max)
	for i=1, #List do
		--print(i.." Total: "..#List[i])
		for j=1, subListNum_Max do
			
			button = CreateFrame("BUTTON", buttonName and (buttonName ..(i+j-1) ) or nil, PopUp, buttonTemplate);

			if List[i][j] then
				local text = ltrim(List[i][j][2],"/"); 									--remove the slash
				if LanguageDetector(text) == "RM" then
					text = strupper(string.sub(text, 1, 1)) .. string.sub(text, 2)		--upper initial
				end
				button.Label:SetText(text)
				button.Token = List[i][j][1]
			else
				button.Label:SetText(" ")
				button.Token = nil
				button:Disable();
			end

			if i % 2 == 0 then
				button.Background:SetColorTexture(0.06, 0.06, 0.06, 0.8)
			end
			buttonWidth = button:GetWidth();
			buttonHeight = button:GetHeight();

			local offsetY = (1-i)*buttonHeight
			if not buttons then
				button:SetPoint(initialPoint, PopUp, initialRelative, 0, offsetY);
			elseif j == 1 then
				button:SetPoint(initialPoint, PopUp, initialRelative, 0, offsetY);
			else
				local index = #buttons
				button:SetPoint(point, buttons[index], relativePoint, 0, 0);
			end
			tinsert(buttons, button);
		end
	end

	self.buttons = buttons;

	local PopUpHeight = #List * buttonHeight
	local PopUpWidth = 4 * buttonWidth
	PopUp:SetHeight(PopUpHeight)
	PopUp:SetWidth(PopUpWidth)
end

function EmoteButtonPopUp_OnLoad(self) 
	EmoteButton_CreateList(self, "EmoteTokenButtonTemplate", EmoteTokenList)
	self.autoCapture = false;
end

function EmoteButton_OnClick(self)
	self.IsOn = not self.IsOn
	if not self.IsOn then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		self.Icon:SetTexCoord(0, 0.5, 0, 1);
		self.UpdateFrame:Hide();

		EmoteButtonPopUp.AnimFrame:Hide();
		EmoteButtonPopUp.AnimFrame:Show();
		EmoteButtonPopUp.AnimFrame.EndPointY = -40;
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		self.Icon:SetTexCoord(0.5, 1, 0, 1);
		--self.UpdateFrame.Emote = "cry";
		--self.UpdateFrame.duration = 3.5;
		--self.UpdateFrame:Show();
		EmoteButtonPopUp:Show();

		EmoteButtonPopUp.AnimFrame:Hide();
		EmoteButtonPopUp.AnimFrame:Show();
		EmoteButtonPopUp.AnimFrame.EndPointY = 8;
	end

	GameTooltip:Hide();

	if XmogButton.IsOn then
		Narci_XmogButtonPopUp.AnimFrame:Hide();
		Narci_XmogButtonPopUp.AnimFrame:Show();
		Narci_XmogButtonPopUp.AnimFrame.EndPointY = -20;
	end
end

function EmoteButtonPopUp_AnimFrame_OnUpdate(self, elapsed)
	local duration = 0.35;
	local EndPoint = self.EndPointY
	local StartPoint = self.StartPointY
	local offSet;
	local t = self.TimeSinceLastUpdate;
	local frame = self:GetParent();
	offSet = outSine(t, StartPoint, EndPoint - StartPoint , duration)
	frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, self.EndPoint, offSet);
	if not self.OppoDirection then
		frame:SetAlpha(2*t/duration);
	else
		frame:SetAlpha(1 - 1.5*t/duration);
	end

	if t >= duration then
		frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, self.EndPoint, EndPoint);
		if not self.OppoDirection then
			frame:SetAlpha(1)
			frame:Show()
		else
			frame:SetAlpha(0)
			frame:Hide()
		end

		self:Hide()
		return;
	end
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
end

function EmoteButton_UpdateFrame_OnShow(self)
	self.TimeSinceLastUpdate = 0;
	self.duration = self.duration or 0;
	
	DoEmote(self.Emote, "none");

	if self.duration == 0 then
		self:Hide();
	end

	if EmoteButtonPopUp.autoCapture then
		C_Timer.After(0.8, function()
			Screenshot()
		end)
	end
end

function EmoteButton_UpdateFrame_OnUpdate(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	if self.TimeSinceLastUpdate >=	self.duration then
		DoEmote(self.Emote, "none");
		self.TimeSinceLastUpdate = 0;
		--print("end")
	end
end

function AutoCaptureButton_OnClick(self)
	self.IsOn = not self.IsOn
	if self.IsOn then
		self.Tick:Show();
		self:GetParent().autoCapture = true;
	else
		self.Tick:Hide();
		self:GetParent().autoCapture = false;
	end
end

function Narci_SetButtonColor(self)
	SetWidgetColor(self.Color);
	SetWidgetColor(self.HighlightColor);
end

function EmoteTokenButton_OnClick(self)
	TokenButton_ClearMarker(self)
	self.HighlightColor:Show()
	EmoteButton.UpdateFrame.Emote = self.Token;
	if EmoteButton.IsOn then
		EmoteButton.UpdateFrame:Hide();
		EmoteButton.UpdateFrame:Show();
	end

	self.AnimFrame.Anim.Bling:Play();
end

function HideTextsButton_OnClick(self)
	self.IsOn = not self.IsOn
	NarcissusDB.PhotoModeButton.HideTexts = self.IsOn

	if not self.IsOn then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		PhotoMode_RestoreCvar(PhotoMode_Cvar_NamesBackup);
		SetTracking(1, PhotoMode_Cvar_TrackingBAK);

		self.Icon:SetTexCoord(0, 0.5, 0, 1);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

		PhotoMode_BackupCvar(PhotoMode_Cvar_NamesBackup, PhotoMode_Cvar_NamesList);
		PhotoMode_ZeroCvar(PhotoMode_Cvar_NamesBackup);
		PhotoMode_GetTrackingInfo();
		SetTracking(1, false);

		self.Icon:SetTexCoord(0.5, 1, 0, 1);
	end

	GameTooltip:Hide();
end

function TopQualityButton_OnClick(self)
	self.IsOn = not self.IsOn
	if not self.IsOn then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		PhotoMode_RestoreCvar(PhotoMode_Cvar_GraphicsBackup);
		self.Icon:SetTexCoord(0, 0.5, 0, 1);
		FadeFrame(TopQualityButton_MSAASlider, 0.25, "OUT");
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		PhotoMode_BackupCvar(PhotoMode_Cvar_GraphicsBackup, PhotoMode_Cvar_GraphicsList);
		PhotoMode_RestoreCvar(PhotoMode_Cvar_GraphicsList);
		self.Icon:SetTexCoord(0.5, 1, 0, 1);
		FadeFrame(TopQualityButton_MSAASlider, 0.25, "IN");
	end

	GameTooltip:Hide();
end

function TopQualityButton_MSAASlider_OnValueChanged(self, value, userInput)
	if not self:IsShown() then
		return;
	end
    self.VirtualThumb:SetPoint("CENTER", self.Thumb, "CENTER", 0, 0)
    if value ~= self.oldValue then
		self.oldValue = value
		local value, valueText = tonumber(value), "";
		if value ~= 0 then
			if value == 1 then
				valueText = "2x";
			elseif value == 2 then
				valueText = "4x";
			elseif value == 3 then
				valueText = "8x";
			end
			valueText = "|cfffced00"..valueText;
		else
			valueText = "|cffee3224"..OFF;
		end
		self.KeyLabel2:SetText(MULTISAMPLE_ANTI_ALIASING.." "..valueText)
		if value ~=0 then
			ConsoleExec("MSAAQuality "..value..",0" )
		else
			ConsoleExec("MSAAQuality 0")
		end
	end
end

function Narci_Vignette_OnFinished()
	Narci_GuideLineFrame.VirtualLineLeft:SetPoint("LEFT", 0, 0);
	Narci_Character:Show()
	if TransmogMode then
		Narci_GuideLineFrame.VirtualLineRight:SetPoint("RIGHT", -15, 0);
		Narci_GuideLineFrame.VirtualLineRight.AnimFrame.StartPoint = -15
		--UIFrameFadeIn(Narci_Attribute, 0.4, 0, 0);
		FadeFrame(Narci_Attribute, 0.4, "OUT")
	else
		Narci_GuideLineFrame.VirtualLineRight.AnimFrame.StartPoint = -404
		Narci_GuideLineFrame.VirtualLineRight.AnimFrame.EndPoint = Narci_GuideLineFrame.VirtualLineRight.AnimFrame.EndPointBAK
		--UIFrameFadeIn(Narci_Attribute, 0.4, 0, 1);
		FadeFrame(Narci_Attribute, 0.4, "Forced_IN")
	end
	RefreshAllStatus();
	PlayAttributeAnimation();
	--UIFrameFadeIn(Narci_Character, 0.6, 0, 1);
	FadeFrame(Narci_Character, 0.6, "IN")
	Narci_GuideLineFrame.VirtualLineRight.AnimFrame:Show()
	Narci_GuideLineFrame.VirtualLineLeft.AnimFrame:Show()
	C_Timer.After(0.3, function()
		ShowDetailedIlvlInfo()	
	end)
	Narci_SnowEffect(true);
end

----------------------------
local EndWidth = 220;
function PhotoModeController_UpdateFrame_OnUpdate(self, elapsed)
	local radian, offSet;
	local t = self.TimeSinceLastUpdate;
	local IsOn = self:GetParent().Switch.IsOn;

	if IsOn then
		radian = outSine(t, self.StartDegree, 1.25*pi - self.StartDegree, 0.6)
		offSet = outSine(t, self.StartOffSet, EndWidth - self.StartOffSet, 0.6)
	else
		radian = outSine(t, self.StartDegree, 2*pi - self.StartDegree, 0.6)
		offSet = outSine(t, self.StartOffSet, 40 - self.StartOffSet, 0.6)
	end
	self:GetParent().Switch.Ring:SetRotation(radian)
	self:GetParent().Bar:SetWidth(offSet)
	if t >= 0.6 then	--duration_Controller
		if IsOn then
			self:GetParent().Switch.Ring:SetRotation(1.25*pi)
			self:GetParent().Bar:SetWidth(EndWidth)
			PhotoModeControllerBar:SetClipsChildren(false)
		else
			self:GetParent().Switch.Ring:SetRotation(2*pi)
			self:GetParent().Bar:SetWidth(40)
			PhotoModeControllerBar:SetClipsChildren(true)
		end
		self:Hide()
		self.TimeSinceLastUpdate = 0;
		return;
	end
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
end

local duration_FlyIn = 0.4;
function PhotoModeController_AnimFrame_OnUpdate(self, elapsed)
	local duration = duration_FlyIn;
	local EndPoint = self.EndPointY;
	local StartPoint = self.StartPointY;
	local offSet, alpha;
	local t = self.TimeSinceLastUpdate;
	local frame = self:GetParent();
	offSet = outSine(t, StartPoint, EndPoint - StartPoint , duration);
	alpha = outSine(t, self.fromAlpha, self.toAlpha - self.fromAlpha , duration);
	frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, self.EndPoint, offSet);
	frame:SetAlpha(alpha)

	if t >= duration then
		frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, self.EndPoint, self.EndPointY);
		if not self.OppoDirection then
			frame:SetAlpha(self.toAlpha);
			frame:Show();
			PhotoModeControllerBar:SetAlpha(1)
		else
			frame:SetAlpha(0);
			frame:Hide();
		end

		self:Hide();
		return;
	end
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
end

function PhotoModeController_AnimFrame_OnHide(self)
	self.TimeSinceLastUpdate = 0;
end


local duration_Translation = 0.8;

function LeftLineAnimFrame_OnUpdate(self, elapsed)
	local EndPoint = self.EndPoint;
	local offSet;
	local t = self.TimeSinceLastUpdate;
	local frame = self:GetParent();
	offSet = outSine(t, EndPoint - 120, 120 , duration_Translation);
	frame:SetPoint(self.AnchorPoint, offSet, 0);

	if t >= duration_Translation then
		frame:SetPoint(self.AnchorPoint, EndPoint, 0);
		self:Hide();
		return;
	end
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
end

function RightLineAnimFrame_OnUpdate(self, elapsed)
	local StartPoint = self.StartPoint;
	local EndPoint = self.EndPoint;
	local offSet;
	local t = self.TimeSinceLastUpdate;
	local frame = self:GetParent();
	offSet = outSine(t, StartPoint, EndPoint - StartPoint, duration_Translation);
	frame:SetPoint(self.AnchorPoint, offSet, 0);

	if t >= duration_Translation then
		frame:SetPoint(self.AnchorPoint, EndPoint, 0);
		--print(EndPoint)
		self:Hide();
		return;
	end
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
end

function IlvlButtonLeftAnimFrame_OnUpdate(self, elapsed)
	local StartPoint = self.StartPoint;
	local EndPoint = 24;
	local Distance = self.Width + 10;
	local offSet;
	local t = self.TimeSinceLastUpdate;
	local frame = self:GetParent();

	if not self.OppoDirection then
		offSet = outSine(t, StartPoint, EndPoint - StartPoint , duration_FlyIn);
		frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, offSet, 0);

		if t >= duration_FlyIn then
			frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, EndPoint, 0);
			self:Hide()
			return;
		end
	else
		offSet = outSine(t, StartPoint, Distance - StartPoint, duration_FlyIn);
		frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, offSet, 0);

		if t >= duration_FlyIn then
			frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, Distance, 0);
			self:Hide();
			frame:Hide();
			return;
		end
	end

	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
end

function IlvlButtonRightAnimFrame_OnUpdate(self, elapsed)
	local StartPoint = self.StartPoint;
	local EndPoint = -24;
	local Distance = self.Width + 10;
	local offSet;
	local t = self.TimeSinceLastUpdate;
	local frame = self:GetParent();

	if not self.OppoDirection then	
		offSet = outSine(t, StartPoint , EndPoint - StartPoint, duration_FlyIn)
		frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, offSet, 0);

		if t >= duration_FlyIn then
			frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, EndPoint, 0);
			self:Hide()
			return;
		end
	else
		offSet = outSine(t, StartPoint, -Distance - StartPoint , duration_FlyIn)
		frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, offSet, 0);

		if t >= duration_FlyIn then
			frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, -Distance, 0);
			self:Hide();
			frame:Hide();
			return;
		end
	end

	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
end
--[[
Set Graphics Settings to Ultra


ffxAntiAliasingMode 2-3
MSAAQuality = not advanced

graphicsTextureResolution 3
graphicsTextureFiltering 6
graphicsProjectedTextures 2

graphicsViewDistance 10
graphicsEnvironmentDetail 10
graphicsGroundClutter 10

graphicsShadowQuality 6
graphicsLiquidDetail 6
graphicsSunshafts 3
graphicsParticleDensity 5
graphicsSSAO 5
graphicsDepthEffects 4
graphicsLightingQuality 3
--]]

------Photo Mode Switch------

function SwitchMode_OnClick(self, key)
	if key == "MiddleButton" then		--Emergency Stop --PH
		UIParent:SetAlpha(1);
		MoveViewRightStop();
		ResetView(5);
		ConsoleExec( "pitchlimit 88");
		CVar_Temp.OverShoulder = 0;
		SetUIVisibility(true);
		ConsoleExec( "actioncam off" )
		Narci_CharacterModelFrame:Hide();
		Narci_CharacterModelSettings:Hide();
		return;
	elseif key == "RightButton" then
		return;
	end

	self.IsOn = not self.IsOn;
	self:GetParent().PhotoModeController_UpdateFrame.TimeSinceLastUpdate = 0;
	self:GetParent().PhotoModeController_UpdateFrame:Hide();
	self:GetParent().PhotoModeController_UpdateFrame:Show();
	if self.IsOn then
		self.Icon:SetTexCoord(0.25, 0.5, 0.75, 1);
		PhotoModeControllerBar:SetAlpha(1)
	else
		self.Icon:SetTexCoord(0, 0.25, 0.75, 1);
		PhotoModeControllerBar:SetClipsChildren(true);
	end

	--GameTooltip:Hide();
	ShowButtonTooltip(self);
	TemporarilyHidePopUp(Narci_XmogButtonPopUp);
	TemporarilyHidePopUp(EmoteButtonPopUp);
end

function PhotoModeController_Disable()
	if EmoteButton.IsOn then
		EmoteButton:Click();
	end

	if HideTextsButton.IsOn then
		HideTextsButton:Click();
		NarcissusDB.PhotoModeButton.HideTexts = true
	end

	if XmogButton.IsOn then
		XmogButton:Click()		--Quit Xmog Mode
	end
	
	if TopQualityButton.IsOn then
		TopQualityButton:Click();
	end
end

function PhotoModeController_OnHide(self)
	PhotoModeController_Disable()
	self:UnregisterEvent("PLAYER_LEAVING_WORLD");
end

function PhotoModeController_OnShow(self)
	self:RegisterEvent("PLAYER_LEAVING_WORLD");
	self:SetScript("OnEvent",function()
		PhotoModeController_Disable();
		SetCVar("Sound_MusicVolume", CVar_Temp.MusicVolume);
		if CVar_Temp.ActioncamState ~= 1 then		--Restore the acioncam state
			SetCVar("test_cameraDynamicPitch", 0);
			ConsoleExec( "actioncam off");
		end
		ResetView(5);
	end)

	self.PhotoModeController_AnimFrame:Hide()
	self.PhotoModeController_AnimFrame.EndPointY = "10"
	self.PhotoModeController_AnimFrame.OppoDirection = false
	self.PhotoModeController_AnimFrame:Show()

	SetColorThemeBasedOnMapID();
end


hooksecurefunc("SetUIVisibility", function(bool)
	if not bool then
		local frame = PhotoModeController
		if not frame:IsShown() then
			CVar_Temp.OverShoulder = GetCVar("test_cameraOverShoulder");
		end
		frame.PhotoModeController_AnimFrame.toAlpha = 0
		frame:Show()
		frame.PhotoModeController_AnimFrame.OppoDirection = false;

		if NarcissusDB.PhotoModeButton.HideTexts and (not HideTextsButton.IsOn) then
			HideTextsButton:Click();
		end

		if  not OpenViaClick then
			XmogButton:Disable();
		end
	elseif not OpenViaClick then
		Smooth_ShoulderCvar(CVar_Temp.OverShoulder)
		local frame = PhotoModeController
		frame.PhotoModeController_AnimFrame:Hide()
		frame.PhotoModeController_AnimFrame.OppoDirection = true
		frame.PhotoModeController_AnimFrame.EndPointY = "-80"
		frame.PhotoModeController_AnimFrame:Show()
	end
end)

SLASH_NARCI1 = "/narci"
SLASH_NARCI2 = "/narcissus"
SlashCmdList["NARCI"] = function(Msg)
	local msg = strlower(Msg);
	if msg == "" then
		Narci_MinimapButton:Click();
	elseif msg == "minimap" then
		Narci_MinimapButton:Show();
		NarcissusDB.ShowMinimapButton = true;
		print("Minimap button has been re-enabled.")
	else
		local scale = tonumber(msg)
		if scale and type(scale) == "number" and scale >= 0.65 and scale < 1.25 then
			Narci_Pref_SetFrameScale(scale)
		else
			print("Invalid!")
		end
	end
end

--[[
Global Strings:

SoundKit
54133		UI_70_Artifact_Forge_Toast_TraitAvailable


powerType, powerTypeString = UnitPowerType(UnitId);
local id, name, description, icon, _, primaryStat = GetSpecializationInfo(shownSpec, nil, self.isPet, nil, sex)
SPEC_FRAME_PRIMARY_STAT_AGILITY 
SPEC_FRAME_PRIMARY_STAT_INTELLEC
SPEC_FRAME_PRIMARY_STAT_STRENGTH

STAT_ARMOR
STAT_BLOCK
STAT_PARRY
DODGE_CHANCE

STAT_DODGE
STAT_ENERGY_REGEN
STAT_RUNE_REGEN
STAT_MANA_TOOLTIP
STAT_CRITICAL_STRIKE
STAT_HASTE
STAT_MASTERY
STAT_VERSATILITY

STAT_LIFESTEAL
STAT_AVOIDANCE

ITEM_MOD_MANA_REGENERATION_SHORT
MANA_REGEN_COMBAT

STAT_ENERGY_REGEN = "Energy Regen";
STAT_ENERGY_REGEN_TOOLTIP = "Energy regenerated every second.";
STAT_ENERGY_TOOLTIP = "Maximum energy.  Energy is consumed when using abilities and is restored automatically over time.";

STAT_CHI_TOOLTIP
STAT_DPS_SHORT

STAT_FOCUS_REGEN = "Focus Regen";
STAT_FOCUS_REGEN_TOOLTIP = "Focus regenerated every second.";
STAT_FOCUS_TOOLTIP = "Maximum focus.  Focus is consumed when using abilities and is restored automatically over time.";

PlayerModel

/run Narci_CharacterModelFrame:SetLight(true, false, 1, 1, 1.732, 1, 0.8, 0.8, 0.8, 1, 0.8, 0.8, 0.8)
/run Narci_CharacterModelFrame:SetLight(true, false, -0.2, 1, -1, 1, 0.8, 0.8, 0.8, 1, 1, 0.6, 0.6)
/run Narci_CharacterModelFrame:SetLight(true, false, -0.5, 0.5, -0.5, 0.8, 0.5, 0.5, 0.8, 1, 0.8, 0.8, 0.8)  

/run Narci_CharacterModelFrame:SetLight(true, false, -0.5, 0.5, -0.5, 0.8, 0.7, 0.5, 0.8, 1, 0.8, 0.8, 0.8)
/run Narci_CharacterModelFrame:FreezeAnimation(1)
SetPortraitZoom(0.3)
SetPosition(0,0,-0.06)
Narci_CharacterModelFrame:SetFacing(-.4)
Narci_CharacterModelFrame:SetSequenceTime(68)
/run PlayerModelAnimIn:Show()
--]]
-------------------------
---- Custom Lighting ----
-------------------------

function ColorButton_OnLoad(self)
	local r, g, b = 0, 0, 0;
	local id = self:GetID();

	if id == 1 then
		r, g, b = 172, 172, 172;
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

	self.r = r/255;
	self.g = g/255;
	self.b = b/255;

	self.Color:SetColorTexture(self.r, self.g, self.b, 1);

	if not self:GetParent().Colors then
		self:GetParent().Colors = {};
	end
	tinsert(self:GetParent().Colors, self)
end

function Narci_ColorButton_OnClick(self)
	local frame = Narci_CharacterModelFrame
	local enabled, omni, dirX, dirY, dirZ, ambIntensity, ambR, ambG, ambB, dirIntensity, dirR, dirG, dirB = frame:GetLight();
	frame:SetLight(enabled, omni, dirX, dirY, dirZ, ambIntensity, self.r, self.g, self.b, dirIntensity, dirR, dirG, dirB)
	
	Narci_CharacterModelSettings.TopView.LightColor:SetColorTexture(self.r, self.g, self.b)
	Narci_CharacterModelSettings.LeftView.LightColor:SetColorTexture(self.r, self.g, self.b)

	--


	local ColorButtons = self:GetParent().Colors
	for i=1, #ColorButtons do
		ColorButtons[i].Border:SetTexCoord(0.75, 0.8359375, 0, 0.171875)
	end
	self.Border:SetTexCoord(0.8359375, 0.921875, 0, 0.171875)
end

function Narci_ModelToggle_OnClick(self)
	self:Disable()
	C_Timer.After(1, function()
		self:Enable()
	end)
	self.AnimFrame.Anim:SetScale(1.5)
	self.AnimFrame.Anim.Bling:Play();
	NarcissusDB.AlwaysShowModel = not NarcissusDB.AlwaysShowModel;
	self.IsOn = NarcissusDB.AlwaysShowModel;
	self.Tick:SetShown(self.IsOn);
	Narci_AlwaysShowModelSwitch.Tick:SetShown(self.IsOn);
	if self.IsOn and xmogMode == 1 then
		if not Narci_CharacterModelFrame:IsShown() then
			if xmogMode == 1 then
				Narci_CharacterModelFrame.Color1:Hide();
			end
			PlayerModelAnimIn:Show()
		end
	elseif xmogMode ~= 2 then
		HidePlayerModel()
	end

end

function Narci_XmogLayoutButton_OnClick(self)
	self:Disable()
	C_Timer.After(0.8, function()
		self:Enable()
	end)
	
	self.ShowModel = not self.ShowModel;
	if self.ShowModel then
		UseXmogLayout(2)
	else
		UseXmogLayout(1)
	end

	self.AnimFrame.Anim:SetScale(1.5)
	self.AnimFrame.Anim.Bling:Play()
end


local AnimSequenceInfo = 
{	["Controller"] = {
		["TotalFrames"] = 30,
		["cX"] = 0.205078125,
		["cY"] = 0.1171875,
		["Column"] = 4,
		["Row"] = 8	
	},

	["Heart"] = {
		["TotalFrames"] = 28,
		["cX"] = 0.25,
		["cY"] = 0.140625,
		["Column"] = 4,
		["Row"] = 7
	},
}

local function AAAPlayAnimationSequence(index, SequenceInfo, Texture)
	local Texture = Texture or PhotoModeControllerTransition.Sequence;
	local SequenceInfo = SequenceInfo or AnimSequenceInfo["Controller"];
	local Frames = SequenceInfo["TotalFrames"];
	local cX, cY = SequenceInfo["cX"], SequenceInfo["cY"];
	local Column, Row = SequenceInfo["Column"], SequenceInfo["Row"]

	if index > Frames or index < 1 then
		return false;
	end

	local n = math.modf((index -1)/ Row) + 1;
	local m = index % Row
	if m == 0 then
		m = Row;
	end

	local left, right = (n-1)*cX, n*cX;
	local top, bottom = (m-1)*cY, m*cY;
	Texture:SetTexCoord(left, right, top, bottom);
	
	Texture:SetAlpha(1)
	return true;
end

local function HideContollerButton(state)
	if state then
		XmogButton:Hide()
		EmoteButton:Hide()
		HideTextsButton:Hide()
		TopQualityButton:Hide()
	else
		XmogButton:Show()
		EmoteButton:Show()
		HideTextsButton:Show()
		TopQualityButton:Show()
	end
end

function PhotoMode_WheelEventContrainer_OnMouseWheel(self, delta)
	if PhotoModeButton.IsOn then
		if CameraOffsetControlBar:IsShown() then
			CameraControlBar_ResetPosition(true)
		end
		TemporarilyHidePopUp(Narci_XmogButtonPopUp);
		TemporarilyHidePopUp(EmoteButtonPopUp);
		AnimationSequenceContainer_Controller:Hide()
		AnimationSequenceContainer_Controller:Show()
	end
end

local function TemporarilyDisableWheel(frame)
	frame:SetScript("OnMouseWheel", function(self, delta)
	end)

	C_Timer.After(0.2, function()
		frame:SetScript("OnMouseWheel", PhotoMode_WheelEventContrainer_OnMouseWheel)
	end)
end

local ASC = CreateFrame("Frame","AnimationSequenceContainer_Controller");
ASC:Hide()
local function InitializeAnimationContainer(frame, SequenceInfo, TargetFrame)
	frame.OppoDirection = false;
	frame.TimeSinceLastUpdate = 0
	frame.TotalTime = 0;
	frame.Index = 1;
	frame.Pending = false;
	frame.IsPlaying = false;	
	frame.SequenceInfo = SequenceInfo;
	frame.Target = TargetFrame
end

local function AnimationContainer_OnHide(self)
	self.TotalTime = 0;
	self.TimeSinceLastUpdate = 0;
	self.OppoDirection = not self.OppoDirection
	if self.Index <= 0 then
		self.Index = 0;
	end
end

local function Controller_AnimationSequence_OnUpdate(self, elapsed)
	if self.Pending then
		return;
	end

	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
	self.TotalTime = self.TotalTime + elapsed;
	
	if self.TimeSinceLastUpdate >= FrameGap then
		self.TimeSinceLastUpdate = 0;
		if self.OppoDirection then
			self.Index = self.Index - 1;
		else
			self.Index = self.Index + 1;
		end

		if not AAAPlayAnimationSequence(self.Index, self.SequenceInfo, self.Target) then
			PhotoModeButton:SetAlpha(1);
			PhotoModeControllerBar:SetAlpha(1);
			if self.OppoDirection then
				UIFrameFadeOut(PhotoModeControllerTransition.Sequence, 0.2, 1 , 0)
				HideContollerButton(false)
				PhotoModeButton:SetAlpha(1);
				PhotoModeControllerBar:SetAlpha(1);
				CameraOffsetControlBar:Hide()
				--print("Hide")
			else
				HideContollerButton(true)
				CameraOffsetControlBar:Show()
				CameraOffsetControlBar:SetAlpha(1);
				UIFrameFadeOut(PhotoModeControllerTransition.Sequence, 0.2, 1 , 0)
				C_Timer.After(0.25, function()
					CameraControlBar_ResetPosition(false)
				end)
			end
			TemporarilyDisableWheel(PhotoMode_WheelEventContrainer);
			self:Hide()
			self.IsPlaying = false;
			return;
		end
		--CameraOffsetControlBar:SetAlpha(0);
		PhotoModeButton:SetAlpha(0);
		PhotoModeControllerBar:SetAlpha(0);
	end
end

ASC:SetScript("OnUpdate", Controller_AnimationSequence_OnUpdate)
ASC:SetScript("OnHide", AnimationContainer_OnHide)
ASC:SetScript("OnShow", function(self)
	self.IsPlaying = true;
end)

local ASC2 = CreateFrame("Frame","AnimationSequenceContainer_Heart");
ASC2.Delay = 5;
ASC2.IsPlaying = false;
ASC2:Hide();

local function Generic_AnimationSequence_OnUpdate(self, elapsed)
	if self.Pending then
		return;
	end

	self.TotalTime = self.TotalTime + elapsed;
	if (not self.OppoDirection and self.TotalTime < self.Delay) and (not self.IsPlaying) then
		return;
	elseif not self.IsPlaying then
		FadeFrame(HeartofAzeroth_AnimFrame, 0.25, "IN")
		C_Timer.After(0.3, function()
			HeartofAzeroth_AnimFrame.Background:SetAlpha(1);
			HeartofAzeroth_AnimFrame.Quote:SetAlpha(1);
			HeartofAzeroth_AnimFrame.SN:SetAlpha(1);
		end)
		self.IsPlaying = true;
	end
	
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	if self.TimeSinceLastUpdate >= FrameGap then
		self.TimeSinceLastUpdate = 0;
		if self.OppoDirection then
			self.Index = self.Index - 1;
		else
			self.Index = self.Index + 1;
		end

		if not AAAPlayAnimationSequence(self.Index, self.SequenceInfo, self.Target) then
			self:Hide()
			self.IsPlaying = false;
			if not self.OppoDirection then
				HeartofAzeroth_AnimFrame.Background:SetAlpha(0);
				HeartofAzeroth_AnimFrame.Quote:SetAlpha(0);
				HeartofAzeroth_AnimFrame.SN:SetAlpha(0);
				FadeFrame(HeartofAzeroth_AnimFrame, 0.25, "OUT")
			end
			return;
		end
	end
end

ASC2:SetScript("OnUpdate", Generic_AnimationSequence_OnUpdate)
ASC2:SetScript("OnHide", AnimationContainer_OnHide)
ASC2:SetScript("OnShow", function(self)

end)

local IAC = CreateFrame("Frame");
IAC:RegisterEvent("VARIABLES_LOADED")
IAC:SetScript("OnEvent",function(self,event,...)
	InitializeAnimationContainer(ASC2, AnimSequenceInfo["Heart"], HeartofAzeroth_AnimFrame.Sequence)
	InitializeAnimationContainer(ASC, AnimSequenceInfo["Controller"], PhotoModeControllerTransition.Sequence)
	local HeartSerialNumber = strsub(UnitGUID("player"), 8, 15);
	HeartofAzeroth_AnimFrame.SN:SetText("No."..HeartSerialNumber)
end)

function CameraControlBar_ResetPosition_AnimFrame_OnShow(self)
	local StartX = CameraOffsetControlBar.PosX or 0;
	local StartAngle = CameraOffsetControlBar.PosRadian or 0;
	self.tOut = math.max(math.abs(StartX) / CameraOffsetControlBar.Range, math.abs(StartAngle)/(2*pi), 0.2)
end

function CameraControlBar_ResetPosition_AnimFrame_OnUpdate(self, elapsed)

	AnimationSequenceContainer_Controller.Pending = true;
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
	local StartX, EndX, StartAngle, EndAngle, t;
	if self.OppoDirection then
		StartX = CameraOffsetControlBar.PosX or 0;
		EndX = 0;
		StartAngle = CameraOffsetControlBar.PosRadian or 0;
		EndAngle = 0;
		t = self.tOut
	else
		StartX = 0;
		EndX = CameraOffsetControlBar.PosX or 0;
		StartAngle = 0;
		EndAngle = CameraOffsetControlBar.PosRadian or 0; --CameraOffsetControlBar.PosRadian or
		t = 0.5
	end

	local Value_Angle = outSine(self.TimeSinceLastUpdate, StartAngle, EndAngle - StartAngle, t)
	local Value_X = outSine(self.TimeSinceLastUpdate, StartX, EndX - StartX, t)
	RotateShaftNode(Value_Angle)
	CameraControllerThumb:SetPoint("CENTER", Value_X, 0);

	if self.TimeSinceLastUpdate >= t then
		RotateShaftNode(EndAngle)
		CameraControllerThumb:SetPoint("CENTER", EndX, 0);
		self:Hide();
		AnimationSequenceContainer_Controller.Pending = false;
		CameraOffsetControlBar.PosRadian = 0;
	end	
end

function CameraControlBar_ResetPosition(bool)
	--print("Last: "..CameraOffsetControlBar.PosRadian)
	if CameraOffsetControlBar:IsShown() and (not AnimationSequenceContainer_Controller.IsPlaying) then
		CameraControlBar_ResetPosition_AnimFrame.OppoDirection = bool
		AnimationSequenceContainer_Controller.Pending = true;
		CameraControlBar_ResetPosition_AnimFrame:Show();
	end
end

local raceList = {
  --[RaceID] = {[GenderID] = {offsetX, offsetY, distance, angle, CameraIndex, {animation} }}
	[1]  = {[2] = {10, -10, 0.75, false, 0},	--Human Male √
		    [3] = {12, -10, 0.71, false, 1, 2},	-- 	    Female	 √
		},

	[2]  = {[2] = {12, -16, 1.3, 1.1, 0},	--Orcs Male  √
		    [3] = {18, -16, 0.72, 1.1, 0, 1},	-- 	    Female	 √
		},

	[3]  = {[2] = {14, -20, 0.88, 0.9, 1},	--Dwarf Male
		    [3] = {2, -12, 0.75, false, 0},	-- 	    Female	 √
		},	

	[4]  = {[2] = {16, -5, 1, 1.5, 0},		--NE	Male
		    [3] = {8, -10, 0.75, false, 0},	-- 	    Female
		},	

	[5]  = {[2] = {16, -6, 0.6, 0.8, 1},	--UD 	Male
		    [3] = {10, -6, 0.68, 1.0, 1, 3},	-- 	    Female
		},

	[6]  = {[2] = {24, -15, 2.4, 0.6, 0},		--Tauren Male	√
		    [3] = {24, -8, 1.6, false, 0},	-- 	     Female
		},	

	[7]  = {[2] = {14, -14, 0.8, 0.5, 0},	--Gnome Male
		    [3] = {14, -14, 0.75, 0.5, 1},	-- 	    Female
		},

	[8]  = {[2] = {16, -4, 1.15, 1.3, 0},	--Troll Male √
		    [3] = {18, -10, 0.75, 1.3, 0},	-- 	    Female	 √
		},

	[9] = {[2] = {8, 0, 0.8, 0.6, 0},		--Goblin Male 	 √
			[3] = {20, -14, 0.85, 0.8, 0},	-- 	    Female 	 √
		},	

	[10] = {[2] = {8, -5, 0.75, 1.2, 0},		--	BE Male
			[3] = {0, -4, 0.53, 1.1, 0},	-- 	    Female
		},	

	[11] = {[2] = {15, -12, 1, 1.4, 0},		--	Goat Male
			[3] = {10, -10, 0.66, 1.4, 0},	-- 	    Female
		},	

	[22]  = {[2] = {10, -10, 0.75, false, 0},	--Worgen Male Human Form
		    [3] = {12, -12, 0.72, 1.1, 1},		--Female	 √
		},

	[24]  = {[2] = {14, 0, 1.1, 1.15, 0},		--Pandaren Male		√
		    [3] = {12, 4, 1.0, 1.1, 0},			--Female	 
		},

	[27]  = {[2] = {24, -10, 0.72, false, 0},	--Highborne Male		√
		    [3] = {16, -4, 0.70, false, 0},			--Female	 
		},

	[28]  = {[2] = {24, -15, 2.4, 0.6, 0},		--Tauren Male	√
		    [3] = {4, -10, 0.62, false, 0},	-- 	     Female
		},	

	[128]  = {[2] = {18, -18, 1.4, 0.85, 0},	--Worgen Male Wolf Form
		    [3] = {18, -15, 1.1, 1.25, 0},		--Female	 √
		},

	[31]  = {[2] = {4, 0, 1.2, 1.6, 0},		--Zandalari Male √
		    [3] = {18, -12, 0.95, 1.6, 0},		-- 	    Female	 √
		},

	[32]  = {[2] = {10, -16, 1.25, 1.15, 1},	--Kul'tiran Male	√
		    [3] = {12, -10, 0.9, 1.5, 0},			--Female	 
		},

	[36]  = {[2] = {14, -10, 1.2, 1.2, 0, 2},		--Mag'har Male
		    [3] = {20, -20, 0.75, false, 0, 1},		-- 	    Female	 √
		},	
}

function PortraitPieces_OnLoad(self)
	local unit = "player"

	self:SetUnit(unit);
	self:SetSheathed(false)

	self:SetFacing(-math.pi/24)	--Front pi/6
	self:SetAnimation(804, 1);	--804
	self:SetLight(true, false, - 0.44699833180028 ,  0.72403680806459 , -0.52532198881773, 0.8, 0.7, 0.5, 0.8, 1, 0.8, 0.8, 0.8)
	--self:SetCameraDistance(0.6)
	--self:Undress()
	--self:TryOn(GetInventoryItemLink(unit, 1))
	--self:TryOn(GetInventoryItemLink(unit, 5))
	--134112 Hidden Shoulder 1Head 5Chest
	--[[
	local HiddenShoulderLink = "|cff1eff00|Hitem:134112::::::::120:::::|h[Hidden Shoulder]|h|r"
	local WeaponLink = "|cffa335ee|Hitem:39420::::::::120:::::|h[Anarchy]|h|r"
	local offHandLink = "|cff0070dd|Hitem:18425::::::::120:::::|h[Kreeg's Mug]|h|r"
	local HiddenHelmLink = "|cff1eff00|Hitem:134110::::::::120:::::|h[Hidden Helm]|h|r"
	local MainHandWeaponLink = "|cffa335ee|Hitem:128827::::::::120:::1:0:|h[Anarchy]|h|r"		--Equip this so Two-handed weapon no longer exceed the model border
	self:TryOn(HiddenShoulderLink)
	self:TryOn(MainHandWeaponLink)
	self:TryOn(offHandLink)
	self:TryOn(HiddenHelmLink)
	--]]
	self:UndressSlot(1);
	self:UndressSlot(3);
	self:UndressSlot(16);
	self:UndressSlot(17);

	local a1, a2, a3 

	local _, _, raceID = UnitRace(unit)
	local GenderID = UnitSex(unit)

	--print("raceID: "..raceID)

	if raceID == 34 then	 --DarkIron
		raceID = 3;
	elseif raceID == 29 then --VE
		raceID = 10
	elseif raceID == 28 then --Highmountain
		raceID = 6
	elseif raceID == 30 then --LightForged
		raceID = 11
	elseif raceID == 25 or raceID == 26 then --Pandaren A|H
		raceID = 24
	elseif raceID == 22 then --Worgen
		local _, inAlternateForm = HasAlternateForm();
		if not inAlternateForm	then
			raceID = 128;
		end
	end

	if raceList[raceID] and raceList[raceID][GenderID] then
		self:SetCamera(raceList[raceID][GenderID][5]);
		self:MakeCurrentCameraCustom();
		if raceList[raceID][GenderID][3] then
			self:SetCameraDistance(raceList[raceID][GenderID][3])
		end
		
		if raceList[raceID][GenderID][4] then
			a1, a2, a3 = self:GetCameraPosition()
			self:SetCameraPosition(a1, a2, raceList[raceID][GenderID][4])
		end

		if FigureModelReference then
			FigureModelReference:SetPoint("CENTER", raceList[raceID][GenderID][1], raceList[raceID][GenderID][2])
		end

		if raceList[raceID][GenderID][6] then
			self:SetAnimation(2, raceList[raceID][GenderID][6])
		end
	else
		self:SetCamera(0);
		self:MakeCurrentCameraCustom();
		a1, a2, a3 = self:GetCameraPosition()
		self:SetCameraPosition(a1, a2, 1.1)
	end
end

--[[
function Te(a,b,r)
	local rad, cos, sin, sqrt, max, min = math.rad, math.cos, math.sin, math.sqrt, math.max, math.min

	local rX = sin(a)*sin(b)*r
	local rY = -sin(a)*cos(b)*r
	local rZ = -cos(a)*rX

	Test1:SetCameraPosition(rX, rY, rZ)
end
--Te(math.pi/2, math.pi/2, 2)
--Test1:SetCameraDistance() 0.4589388



function Ce(a)
	local a1, a2, a3 = Test1:GetCameraPosition()
	--print(a1.." "..a2.." "..a3)
	Test1:SetCameraPosition(a1, a2, a)
end

--]]

local DoubleClickThreshold = 0.25;		--Clicks within (this value) seconds are deemed consecutive

local function Narci_DoubleClickTrigger_OnUpdate(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
	if self.TimeSinceLastUpdate > DoubleClickThreshold then
		self:SetScript("OnUpdate", function()
		end);
	end
end

function Narci_DoubleClickTrigger_OnShow(self)
	self.TimeSinceLastUpdate = 0;
	self:SetScript("OnUpdate", Narci_DoubleClickTrigger_OnUpdate);
end

function Narci_DouleClickTrigger_OnHide(self)
	if (self.TimeSinceLastUpdate < DoubleClickThreshold) and NarcissusDB.EnableDoubleTap then
		Narci_MinimapButton:Click();
	end
	self.TimeSinceLastUpdate = 0;
end

function Narci_Bridge_DragStratEvent()
	if Bridge_AzeriteUI_ShowActionBars then
		UIFrameFadeOut(PhotoModeController, 0.2, PhotoModeController:GetAlpha(), 0);
		--Bridge_AzeriteUI_ShowActionBars(true);
		--Narci_SharedAnimatedParent.animIn:Play();
		--Narci_SharedAnimatedParent_Anim:Show()
	else
		return;
	end
end

function Narci_Bridge_DragEndEvent()
	if Bridge_AzeriteUI_ShowActionBars then
		--Bridge_AzeriteUI_ShowActionBars(false);
		--Narci_SharedAnimatedParent.animOut:Play();
	else
		return;
	end
end


function Narci_SetActiveBorderTexture()
	local name;
	BorderTexture, minimapTexture, Name = NarciAPI_GetBorderTexture();
	if Name == "Dark" then
		for i=1, #slotTable do
			if slotTable[i] then
				RefreshSlot(i);
				slotTable[i].RuneSlot.Background:SetAlpha(0);
				slotTable[i].Shadow:Show();
				slotTable[i].Icon:SetSize(44, 44);
				slotTable[i]:SetWidth(70);
				slotTable[i]:SetHeight(72);
			end
		end
		if IsAddOnLoaded("AzeriteUI") then
			Narci_MinimapButton.Background:SetSize(80, 80);
		else
			Narci_MinimapButton.Background:SetSize(58, 58)
		end
	else
		for i=1, #slotTable do
			if slotTable[i] then
				RefreshSlot(i);
				slotTable[i].RuneSlot.Background:SetAlpha(1);
				slotTable[i].Shadow:Hide();
				slotTable[i].Icon:SetSize(48, 48);
				slotTable[i]:SetWidth(64);
				slotTable[i]:SetHeight(64);
			end
		end
		Narci_MinimapButton.Background:SetSize(36, 36);	
	end
	Narci_MinimapButton.Background:SetTexture(minimapTexture);
	Narci_MinimapButton.Color:SetTexture(minimapTexture);
end