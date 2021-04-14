--[[
This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/.
--]]

--Settings storaged in NarcissusDB
local Narci = Narci;

Narci.refreshCombatRatings = true;

local slotTable = {};
local statTable = {};
local statTable_Short = {};
local L = Narci.L;
local VIGNETTE_ALPHA = 0.5;
local IS_OPENED = false;									--Addon was opened by clicking
local MOG_MODE = false;
local xmogMode = 0;											-- 0 off	1 "Texts Only" 	2 "Texts & Model"

local GetItemEnchantID = NarciAPI.GetItemEnchantID;
local GetItemEnchantText = NarciAPI.GetItemEnchantText;
local EnchantInfo = Narci_EnchantInfo;						--Bridge/GearBonus.lua
local IsItemSourceSpecial = NarciAPI.IsItemSourceSpecial;
local Narci_LetterboxAnimation = NarciAPI_LetterboxAnimation;
local SmartFontType = NarciAPI.SmartFontType;
local LanguageDetector = NarciAPI.LanguageDetector;
local IsItemSocketable = NarciAPI.IsItemSocketable;
--local GetCorruptedItemAffix = NarciAPI_GetCorruptedItemAffix;
local Narci_AlertFrame_Autohide = Narci_AlertFrame_Autohide;
local C_Item = C_Item;
local C_TransmogCollection = C_TransmogCollection;
local After = C_Timer.After;
local ItemLocation = ItemLocation;

local floor = math.floor;
local sin = math.sin;
local cos = math.cos;
local pi = math.pi;
local max = math.max;

local FadeFrame = NarciFadeUI.Fade;
local UIParent = _G.UIParent;
local EquipmentFlyoutFrame;
local ItemLevelFrame;
local Toolbar;
local RadarChart;
local MiniButton;

local NarciThemeUtil = NarciThemeUtil;
--[[
function PlaceHolderFeature_OnLoad(self)
	self.tooltipHeadline = "Button-PH";
	self.tooltipLineOpen = "Placeholder: RP addon support, player statistics";
	self.tooltipSpecial = "In development";
end
--]]

hooksecurefunc("StaticPopup_Show", function(name)
	if name == "EXPERIMENTAL_CVAR_WARNING" then
		StaticPopup_Hide(name);
	end
end)

local EL = CreateFrame("Frame");	--Event Listener
EL:Hide();

function Narci:UpdateVignetteStrength()
	local alpha = tonumber(NarcissusDB.VignetteStrength) or 0.5;
	VIGNETTE_ALPHA = alpha;
	Narci_Vignette.VignetteLeft:SetAlpha(alpha);
	Narci_Vignette.VignetteRight:SetAlpha(alpha);
	Narci_Vignette.VignetteRightSmall:SetAlpha(alpha);
	Narci_PlayerModelGuideFrame.VignetteRightSmall:SetAlpha(alpha);
end

--[[
local TakenOutFrames = {
	[2] = AzeriteEmpoweredItemUI, 		--
	[3] = ItemSocketingFrame,			--
	[4] = ArtifactFrame,				--
}
--]]

local function TakeOutFromUIParent(frame, FrameStrata, bool) --take out frames from UIParent, so they will still be visible when UI is hidden
	local effectiveScale = UIParent:GetEffectiveScale();
	FrameStrata = FrameStrata or "MEDIUM";

	if frame then
		if bool == true then
			frame:SetParent(nil);
			frame:SetFrameStrata(FrameStrata);
			frame:SetScale(effectiveScale);
		elseif bool == false or bool == nil then
			frame:SetScale(1);
			frame:SetParent(UIParent);
			frame:SetFrameStrata(FrameStrata);
		end
	end
end

local DefaultTooltip;
function Narci_ShowButtonTooltip(self)
	DefaultTooltip:Hide();
	DefaultTooltip:SetOwner(self, "ANCHOR_NONE");
	if not self.tooltipHeadline then
		return
	end

	DefaultTooltip:SetText(self.tooltipHeadline);
	if self.IsOn then
		DefaultTooltip:AddLine(self.tooltipLineClose, 1, 1, 1, true);
	else
		DefaultTooltip:AddLine(self.tooltipLineOpen, 1 ,1 ,1 ,true);
	end

	if self.tooltipSpecial then
		DefaultTooltip:AddLine(" ");
		DefaultTooltip:AddLine(self.tooltipSpecial, 0.25, 0.78, 0.92, true);
	end

	DefaultTooltip:SetAlpha(0);
	NarciAPI_ShowDelayedTooltip("BOTTOM", self, "TOP", 0, 2);	
end

function Narci:HideButtonTooltip()
	DefaultTooltip:Hide();	
	--DefaultTooltip:SetFrameStrata("TOOLTIP");
end

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

local function linear(t, b, e, d)
	return (e - b) * t / d + b
end

local function outSine(t, b, e, d)
	return (e - b) * sin(t / d * (pi / 2)) + b
end

local function inOutSine(t, b, e, d)
	return (b - e) / 2 * (cos(pi * t / d) - 1) + b
end

--------------------------------
local UIPA = CreateFrame("Frame");	--UIParentAlphaAnimation
UIPA:Hide()
UIPA.t = 0;
UIPA.totalTime = 0;
UIPA.frame = UIParent;
local function UIParent_AnimIn(self, elapsed)
	self.t = self.t + elapsed
	self.totalTime = self.totalTime + elapsed;
	if self.t < 0.08 then
		return;
	else
		self.t = 0;
	end
	
	local alpha = linear(self.totalTime, self.startAlpha, self.endAlpha, 0.5);

	if self.totalTime >= 0.5 then
		alpha = self.endAlpha;
		self:Hide();
	end

	self.frame:SetAlpha(alpha);
end


UIPA:SetScript("OnShow", function(self)
	self.startAlpha = self.frame:GetAlpha();
end);
UIPA:SetScript("OnUpdate", UIParent_AnimIn);
UIPA:SetScript("OnHide", function(self)
	self.t = 0;
	self.totalTime = 0;
end);


--------------------------------
-----------CVar Backup----------
--------------------------------
local ConsoleExec = ConsoleExec;
local GetCVar = GetCVar;
local SetCVar = SetCVar;

ConsoleExec( "pitchlimit 88");

local CVarTemp = {};

function CVarTemp:BackUp()
	self.ZoomLevel = GetCameraZoom();
	self.DynamicPitch = tonumber(GetCVar("test_cameraDynamicPitch"));
	self.OverShoulder = GetCVar("test_cameraOverShoulder");
	self.MusicVolume = GetCVar("Sound_MusicVolume");
	self.CameraViewBlendStyle = GetCVar("cameraViewBlendStyle");
end

function CVarTemp:BackUpDynamicCam()
	self.DynmicCamShoulderOffsetZoomUpperBound = DynamicCam.db.profile.shoulderOffsetZoom.lowerBound;	--New
	DynamicCam.db.profile.shoulderOffsetZoom.lowerBound = 0;
end

function CVarTemp:RestoreDynamicCam()
	DynamicCam.db.profile.shoulderOffsetZoom.lowerBound = self.DynmicCamShoulderOffsetZoomUpperBound;
end

local function GetKeepActionCam()
	return CVarTemp.isDynamicCamLoaded or Narci.keepActionCam
end

CVarTemp.OverShoulder = GetCVar("test_cameraOverShoulder");
CVarTemp.DynamicPitch = tonumber(GetCVar("test_cameraDynamicPitch"));		--No CVar directly shows the current state of ActionCam. Check this CVar for the moment. 1~On  2~Off
CVarTemp.MusicVolume = GetCVar("Sound_MusicVolume");
CVarTemp.ZoomLevel = 2;

local ZoomFactor = {};
ZoomFactor.Time = 1.5;			--1.5 outSine
--ZoomFactor.Amplifier = 0.65; 	--0.65
ZoomFactor.EndSpeedBasic = 0.004;	--yawmovespeed 180
ZoomFactor.StartSpeedBasic = 1.05;	--yawmovespeed 180
ZoomFactor.EndSpeed = 0.005;	--yawmovespeed 180
ZoomFactor.StartSpeed = 1.0;	--yawmovespeed 180 outSine 1.4 
ZoomFactor.SpeedFactor = 180 / GetCVar("cameraYawMoveSpeed");
ZoomFactor.Goal = 2.5; --2.5 with dynamic pitch

local MogModeOffset = 0;
local ZoomValuebyRaceID = {
	--[raceID] = {ZoomValue Bust, factor1, factor2, ZoomValue for XmogMode},
	[0] = {[2] = {2.1, 0.361, -0.1654, 4},},		--Default Value

	[1] = {[2] = {2.1, 0.3283, -0.02, 4},		--1 Human √
		   [3] = {2.0, 0.38, 0.0311, 3.6}},

	[2] = {[2] = {2.4, 0.2667, -0.1233, 5.2},	--2 Orc √
		   [3] = {2.1, 0.3045, -0.0483, 5}},

	[3] = {[2] = {2.0, 0.2667, -0.0267, 3.6},	--3 Dwarf √
		   [3] = {1.8, 0.3533, -0.02, 3.6}},

	[4] = {[2] = {2.1, 0.30, -0.0404, 5},		--4 NE √
		   [3] = {2.1, 0.329, 0.025, 4.6}},

	[5] = {[2] = {2.1, 0.3537, -0.15, 4.2},		--5 UD √
		   [3] = {2.0, 0.3447, 0.03, 3.6}},

	[6] = {[2] = {4.5, 0.2027, -0.18, 5.5},		--6 Tauren Male √
		   [3] = {3.0, 0.2427, -0.1867, 5.5}},

	[7] = {[2] = {2.1, 0.329, 0.0517, 3.2},		--7 Gnome √
		   [3] = {2.1, 0.329, -0.012, 3.1}},

	[8] = {[2] = {2.1, 0.2787, 0.04, 5.2},		--8 Troll √
		   [3] = {2.1, 0.355, -0.1317, 5}},

	[9] = {[2] = {2.1, 0.2787, 0.04, 4.2},		--9 Goblin √
		   [3] = {2.1, 0.3144, -0.054, 4}},

	[10] = {[2] = {2.1, 0.361, -0.1654, 4},		--10 BloodElf Male √
		    [3] = {2.1, 0.3177, 0.0683, 3.8}},

	[11] = {[2] = {2.4, 0.248, -0.02, 5.5},		--11 Goat Male √
			[3] = {2.1, 0.3177, 0, 5}},
			
	[24] = {[2] = {2.5, 0.2233, -0.04, 5.2},		--24 Pandaren Male √
		    [3] = {2.5, 0.2433, 0.04, 5.2}},

	[27] = {[2] = {2.1, 0.3067, -0.02, 5.2},		--27 Nightborne √
		   [3] = {2.1, 0.3347, -0.0563, 4.7}},

	[28] = {[2] = {3.5, 0.2027, -0.18, 5.5},		--28 Tauren Male √
		   [3] = {2.3, 0.2293, 0.0067, 5.5}},

	[29] = {[2] = {2.1, 0.3556, -0.1038, 4.5},		--24 VE √
			[3] = {2.1, 0.3353, -0.02, 3.8}},

	[31] = {[2] = {2.3, 0.2387, -0.04, 5.5},		--32 Zandalari √
		   [3] = {2.1, 0.2733, -0.1243, 5.5}},

	[32] = {[2] = {2.3, 0.2387, 0.04, 5.2},			--32 Kul'Tiran √
		   [3] = {2.1, 0.312, -0.02, 4.7}},

	[35] = {[2] = {2.1, 0.31, -0.03, 3.1},			--35 Vulpera √
		   [3] = {2.1, 0.31, -0.03, 3.1}},	

	["Wolf"] = {[2] = {2.6, 0.2266, -0.02, 5},	--22 Worgen Wolf form √
		   	[3] = {2.1, 0.2613, -0.0133, 4.7}},
	
	["Druid"] = {[1] = {3.71, 0.2027, -0.02, 5},		--Cat
				 [5] = {4.8, 0.1707, -0.04, 5},			--Bear
				 [31] = {4.61, 0.1947, -0.02, 5},		--Moonkin
				 [4] = {4.61, 0.1307, -0.04, 5},		--Swim
				 [27] = {3.61, 0.1067, -0.02, 5},		--Fly Swift
				 [29] = {3.61, 0.1067, -0.02, 5},		--Fly
				 [3] = {4.91, 0.184, -0.02, 5},			--Travel Form
				 [36] = {4.2, 0.1707, -0.04, 5},		--Treant
				 [2] = {5.4, 0.1707, -0.04, 5},			--Tree of Life
				},

	["Mounted"] = {[1] = {8, 1.2495, -4, 5.5}},
	
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
local distanceIndex = 1;
local ZoomInValue = ZoomValuebyRaceID[0][1];
local Shoulder_Factor1 = ZoomValuebyRaceID[0][2];
local Shoulder_Factor2 = ZoomValuebyRaceID[0][3];

local function ReIndexRaceID(raceID)
	if raceID == 25 or raceID == 26 then	--Pandaren A|H
		raceID = 24;
	elseif raceID == 30 then				--Lightforged
		raceID = 11;
	elseif raceID == 36 then				--Mag'har Orc
		raceID = 2;
	elseif raceID == 34 then				--DarkIron
		raceID = 3;
	elseif raceID == 37 then				--Mechagnome
		raceID = 7;
	end
	return raceID
end

playerRaceID = ReIndexRaceID(playerRaceID)
ReIndexRaceID = nil;

for raceKey, data in pairs(ZoomValuebyRaceID) do
	local id = tonumber(raceKey);
	if id and id > 1 and id ~= playerRaceID then
		ZoomValuebyRaceID[raceKey] = nil;
	end
end

function Narci:InitializeCameraFactors()
	if NarcissusDB and not NarcissusDB.UseBustShot then
		distanceIndex = 4;
	else
		distanceIndex = 1;
	end
end

local function ModifyCameraForMounts()
	if IsMounted() then
		local index = "Mounted";
		ZoomInValue = ZoomValuebyRaceID[index][1][1];
		Shoulder_Factor1 = ZoomValuebyRaceID[index][1][2];
		Shoulder_Factor2 = ZoomValuebyRaceID[index][1][3];
	else
		local zoom = ZoomValuebyRaceID[playerRaceID] or ZoomValuebyRaceID[1];
		ZoomInValue = defaultZoomInValue;
		Shoulder_Factor1 = zoom[playerGenderID][2];
		Shoulder_Factor2 = zoom[playerGenderID][3];
		ZoomInValue_XmogMode = zoom[playerGenderID][4];		
	end
end

local function ModifyCameraForShapeshifter()
	if IsMounted() then
		local index = "Mounted";
		ZoomInValue = ZoomValuebyRaceID[index][1][1];
		Shoulder_Factor1 = ZoomValuebyRaceID[index][1][2];
		Shoulder_Factor2 = ZoomValuebyRaceID[index][1][3];
		return;
	end

	if playerRaceID ~= 22 and playerClassID ~= 11 then	--22 Worgen 11 druid
		local zoom = ZoomValuebyRaceID[playerRaceID] or ZoomValuebyRaceID[1];
		ZoomInValue = zoom[playerGenderID][distanceIndex];
		Shoulder_Factor1 = zoom[playerGenderID][2];
		Shoulder_Factor2 = zoom[playerGenderID][3];
		ZoomInValue_XmogMode = zoom[playerGenderID][4];
		return;
	end

	local raceID_shouldUse = 1;
	
	if playerClassID ~= 11 then
		--Not Druid
		local _, inAlternateForm = HasAlternateForm();
		if not inAlternateForm then						--Is curren in wolf form
			raceID_shouldUse = "Wolf";
		else
			raceID_shouldUse = 1;
		end
		ZoomInValue = ZoomValuebyRaceID[raceID_shouldUse][playerGenderID][distanceIndex];
		Shoulder_Factor1 = ZoomValuebyRaceID[raceID_shouldUse][playerGenderID][2];
		Shoulder_Factor2 = ZoomValuebyRaceID[raceID_shouldUse][playerGenderID][3];
		ZoomInValue_XmogMode = ZoomValuebyRaceID[raceID_shouldUse][playerGenderID][4];
		return;
	else
		--Druid
		raceID_shouldUse = "Druid";
		EL:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
		local formID = GetShapeshiftFormID();
		
		if ( not formID ) or ( not ZoomValuebyRaceID[raceID_shouldUse][formID] ) then
			if playerRaceID == 22 then
				local _, inAlternateForm = HasAlternateForm();
				if not inAlternateForm then						--Is curren in wolf form
					raceID_shouldUse = "Wolf";
				else
					raceID_shouldUse = 1;
				end
			else
				raceID_shouldUse = playerRaceID;
			end
			formID = playerGenderID;
		elseif formID == 31 then
			local _, GlyphID = GetCurrentGlyphNameForSpell(24858);		--Moonkin form with Glyph of Stars use regular configuration
			if GlyphID and GlyphID == 114301 then
				local zoom = ZoomValuebyRaceID[playerRaceID] or ZoomValuebyRaceID[1];
				ZoomInValue = zoom[playerGenderID][distanceIndex];
				Shoulder_Factor1 = zoom[playerGenderID][2];
				Shoulder_Factor2 = zoom[playerGenderID][3];
				ZoomInValue_XmogMode = zoom[playerGenderID][4];
				return;
			end
		end
		ZoomInValue = ZoomValuebyRaceID[raceID_shouldUse][formID][distanceIndex];
		Shoulder_Factor1 = ZoomValuebyRaceID[raceID_shouldUse][formID][2];
		Shoulder_Factor2 = ZoomValuebyRaceID[raceID_shouldUse][formID][3];
		ZoomInValue_XmogMode = ZoomValuebyRaceID[raceID_shouldUse][formID][4];
	end
end


local SmoothShoulder = CreateFrame("Frame");
SmoothShoulder.t = 0;
SmoothShoulder.duration = 1;
SmoothShoulder:Hide();

local function SmoothShoulder_Update(self, elapsed)
	self.t = self.t + elapsed;
	local value = outSine(self.t, self.StartPoint, self.EndPoint, self.duration);

	if self.t >= self.duration then
		value = self.EndPoint;
		self:Hide();
	end

	SetCVar("test_cameraOverShoulder", value);
end


SmoothShoulder:SetScript("OnShow", function(self)
	self.StartPoint = GetCVar("test_cameraOverShoulder");
end);
SmoothShoulder:SetScript("OnUpdate", SmoothShoulder_Update);
SmoothShoulder:SetScript("OnHide", function(self)
	self.t = 0
end);

local function SmoothShoulderCVar(EndPoint)
	SmoothShoulder:Hide();
	SmoothShoulder.EndPoint = EndPoint;
	SmoothShoulder:Show();
end

local UpdateShoulderCVar = {};
function UpdateShoulderCVar:Start(increment)
	if ( not self.pauseUpdate ) then
		self.zoom = GetCameraZoom();
		self.pauseUpdate = true;
		After(0.1, function()    -- Execute after 0.1s
			self.pauseUpdate = nil;
			SmoothShoulderCVar(self.zoom * Shoulder_Factor1 + Shoulder_Factor2 + MogModeOffset);
		end)
	end
	self.zoom = self.zoom + increment;
end

local duration_Lock = 1.5;
local duration_Translation = 0.8;

function LeftLineAnimFrame_OnUpdate(self, elapsed)
	local EndPoint = self.EndPoint;
	local t = self.TimeSinceLastUpdate;
	local frame = self:GetParent();
	local offSet = outSine(t, EndPoint - 120, EndPoint , duration_Translation);

	if t >= duration_Translation then
		offSet = EndPoint;
		After(0, function()
			self:Hide();
		end);
	end
	frame:SetPoint(self.AnchorPoint, offSet, 0);
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
end

function RightLineAnimFrame_OnUpdate(self, elapsed)
	local StartPoint = self.StartPoint;
	local EndPoint = self.EndPoint;
	local offSet;
	local t = self.TimeSinceLastUpdate;
	local frame = self:GetParent();
	offSet = outSine(t, StartPoint, EndPoint, duration_Translation);
	
	if t >= duration_Translation then
		offSet = EndPoint;
		self:Hide();
		After(0, function()
			self:Hide();
		end);
	end
	frame:SetPoint(self.AnchorPoint, offSet, 0);
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
end

--Views
local ViewProfile = {
	isEnabled = true,
};

function ViewProfile:Disable()
	self.isEnabled = false;
	print("Dynamic Cam Enabled")
end

function ViewProfile:SaveView(index)
	if self.isEnabled then
		SaveView(index);
	end
end

function ViewProfile:ResetView(index)
	if self.isEnabled then
		ResetView(index);
	end
end

---Camera
--[[
hooksecurefunc("CameraZoomIn", function(increment)
	if IS_OPENED and (xmogMode ~= 1) then
		UpdateShoulderCVar:Start(-increment);
	end
end)

hooksecurefunc("CameraZoomOut", function(increment)
	if IS_OPENED and (xmogMode ~= 1)then
		UpdateShoulderCVar:Start(increment);
	end
end)
--]]

local CameraMover = {};
Narci.CameraMover = CameraMover;


function CameraMover:ZoomIn(EndPoint)
	local goal = EndPoint or ZoomFactor.Goal;
	ZoomFactor.Current = GetCameraZoom();
	if ZoomFactor.Current >= goal then
		CameraZoomIn(ZoomFactor.Current - goal);
	else
		CameraZoomOut(-ZoomFactor.Current + goal);
	end
end

function CameraMover:OnCameraChanged()
	if not self.pauseUpdate then
		self.pauseUpdate = true;
		After(0.05, function()
			self:ZoomIn(ZoomInValue);
			self.pauseUpdate = nil;
		end);
	end
end

function CameraMover:SetBlend(enable)
	local divisor;
	if enable then
		--Smooth
		duration_Lock = 1.5;
		duration_Translation = 0.8;
		divisor = 20;
	else
		--Instant
		duration_Lock = 0.4;
		duration_Translation = 0.4;
		divisor = 80;
	end

	for k, slot in pairs(statTable) do
		local delay = (slot:GetID())/divisor;
		if slot.animIn then
			slot.animIn.A2:SetStartDelay(delay);
		end
	end

	for k, slot in pairs(statTable_Short) do
		local delay = (slot:GetID())/divisor;
		slot.animIn.A2:SetStartDelay(delay);
	end

	RadarChart.animIn.A2:SetStartDelay(9/divisor);
	self.blend = enable;
end

CameraMover.smoothYaw = NarciAPI_CreateAnimationFrame(1.5);
CameraMover.smoothYaw:SetScript("OnUpdate", function(frame, elapsed)
	frame.total = frame.total + elapsed;
	local factor = ZoomFactor;
	local speed = inOutSine(frame.total, factor.StartSpeed, factor.EndSpeed, 1.5);
	MoveViewRightStart(speed);
	
	if frame.total >= 1.5 then
		if not IsPlayerMoving() then
			MoveViewRightStart(factor.EndSpeed);
		else
			MoveViewRightStop();
		end
		frame:Hide();
	end
end);


CameraMover.smoothPitch = NarciAPI_CreateAnimationFrame(1.65);
CameraMover.smoothPitch:SetScript("OnUpdate", function(frame, elapsed)
	frame.total = frame.total + elapsed
	local x = frame.total;
	local EndDistance = ZoomFactor.Goal;
	local PL = tostring(outSine(frame.total, 88,  0, frame.duration));
	ConsoleExec( "pitchlimit "..PL)
	if frame.total >= frame.duration then
		ConsoleExec( "pitchlimit 0");
		After(0, function()
			ConsoleExec( "pitchlimit 88");
		end)
		frame:Hide();
	end
end);


function CameraMover:InstantZoomIn()
	SetCVar("cameraViewBlendStyle", 2);
	SetView(4);

	ConsoleExec( "pitchlimit 0");
	After(0, function()
		ConsoleExec( "pitchlimit 88");
	end)
	
	local zoom = ZoomInValue or GetCameraZoom();
	local shoulderOffset = zoom * Shoulder_Factor1 + Shoulder_Factor2 + MogModeOffset;
	SetCVar("test_cameraOverShoulder", shoulderOffset);		--CameraZoomIn(0.0)	--Smooth
	
	self:ZoomIn(ZoomInValue);
	
	self:ShowFrame();
	SetUIVisibility(false);
	if not IsPlayerMoving() and NarcissusDB.CameraOrbit then
		MoveViewRightStart(ZoomFactor.EndSpeed);
	end
end

function CameraMover:HideUI()
	if UIParent:IsShown() then
		UIPA.endAlpha = 0;
		UIPA:Show();
	end

	After(0.5, function()
		SetUIVisibility(false); 		--Same as pressing Alt + Z
		After(0.3, function()
			UIParent:SetAlpha(1);
		end)
	end)
end

function CameraMover:Enter()
	SetCVar("test_cameraDynamicPitch", 1);

	if self.blend then
		if NarcissusDB.CameraOrbit and not IsPlayerMoving() then
			if NarcissusDB.CameraOrbit then
				self.smoothYaw:Show();
			end
			SetView(2);	
		end

		if not IsFlying("player") then
			self.smoothPitch:Show();
		end
		
		After(0.1, function()
			self:ZoomIn(ZoomInValue);
			After(0.8, function()
				self:ShowFrame();
			end)
		end)

		self:HideUI();
	else
		if not self.hasInitialized then
			if NarcissusDB.CameraOrbit then
				self.smoothYaw:Show();
			end
			SetView(2);
			self.smoothPitch:Show();
			After(0.1, function()
				self:ZoomIn(ZoomInValue);
				After(0.8, function()
					self:ShowFrame();
				end)
			end)
			After(1, function()
				if not IsMounted() then
					self.hasInitialized = true;
					SaveView(1);
				end
			end)
			self:HideUI();
		else
			self:InstantZoomIn();
		end
	end
end

function CameraMover:Pitch()
	self.smoothPitch:Show();
end


------------------------------


------------------------------


local function ExitFunc()
	IS_OPENED = false;
	xmogMode = 0;
	MogModeOffset = 0;
	NarciPlayerModelFrame1.xmogMode = 0;
	EL:Hide();
	MoveViewRightStop();
	if not GetKeepActionCam() then		--(not CVarTemp.isDynamicCamLoaded and CVarTemp.DynamicPitch == 0) or not Narci.keepActionCam
		SetCVar("test_cameraDynamicPitch", 0);								--Note: "test_cameraDynamicPitch" may cause camera to jitter while reseting the player's view
		SmoothShoulderCVar(0);
		After(1, function()
			ConsoleExec( "actioncam off" );
			MoveViewRightStop();
		end)
	else
		--Restore the acioncam state
		SmoothShoulderCVar(CVarTemp.OverShoulder);
		SetCVar("test_cameraDynamicPitch", CVarTemp.DynamicPitch);
		After(1, function()
			MoveViewRightStop();
		end)
	end

	ConsoleExec( "pitchlimit 88");
	
	FadeFrame(Narci_Vignette, 0.5, 0);
	if Narci_Attribute:IsVisible() then
		Narci_Attribute.animOut:Play();
	end
	UIParent:SetAlpha(0);
	After(0.1, function()
		UIPA.startAlpha = 0;
		UIPA.endAlpha = 1;
		UIPA:Show();
		SetUIVisibility(true);
		--UIFrameFadeIn(UIParent, 0.5, 0, 1);	--cause frame rate drop
		Minimap:Show();
		local CameraFollowStyle = GetCVar("cameraSmoothStyle");
		if CameraFollowStyle == "0" and ViewProfile.isEnabled then		--workaround for auto-following
			SetView(5);
		else
			SetView(2);
			CameraMover:ZoomIn(CVarTemp.ZoomLevel);
		end
		SetCVar("cameraViewBlendStyle", CVarTemp.CameraViewBlendStyle);
	end)	
	--Narci_Attribute:Show();

	Narci.isActive = false;
	Narci.isAFK = false;

	DefaultTooltip:Hide();
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


function Narci:EmergencyStop()
	print("Camera has been reset.");
	UIParent:SetAlpha(1);
	MoveViewRightStop();
	MoveViewLeftStop();
	ViewProfile:ResetView(5);
	ConsoleExec( "pitchlimit 88");
	CVarTemp.OverShoulder = 0;
	SetCVar("test_cameraOverShoulder", 0);
	SetCVar("cameraViewBlendStyle", 1);
	ConsoleExec( "actioncam off" );
	Narci_ModelContainer:Hide();
	Narci_ModelSettings:Hide();
	Narci_Character:Hide();
	Narci_Attribute:Hide();
	Narci_Vignette:Hide();
	IS_OPENED = false;
	xmogMode = 0;
	MogModeOffset = 0;
	NarciPlayerModelFrame1.xmogMode = 0;
	EL:Hide();
end


NarciMinimapButtonMixin = {};

function NarciMinimapButtonMixin:CreatePanel()
	local Panel = self.Panel;
	local button;
	local buttons = {};

	local LOCALIZED_NAMES = {L["Photo Mode"], DRESSUP_FRAME, "Wardrobe (WIP)", ACHIEVEMENT_BUTTON};	-- CHARACTER_BUTTON, "Character Info" "Dressing Room" "Achievements"
	local frameNames = {};
	frameNames[4] = "Narci_Achievement";

	local func = {
		Narci_OpenGroupPhoto,
		
		function()
			Narci_ShowDressingRoom();
		end,

		nil,	--Narci_Outfit:Open();

		function()
			Narci_AchievementFrame:SetShown(not Narci_AchievementFrame:IsShown());
		end
	};

	local numButtons = #LOCALIZED_NAMES;

	local BUTTON_HEIGHT = 24;
	local offsetY = BUTTON_HEIGHT * (numButtons - 1) / 2;
	local middleHeight = 48 + (numButtons - 4) * BUTTON_HEIGHT;
	local button1OffsetY = offsetY - middleHeight/2 + BUTTON_HEIGHT/2
	local buttonFrameLevel = Panel:GetFrameLevel() + 1;

	local ClipFrame = Panel.ClipFrame;
	ClipFrame:SetFrameLevel(buttonFrameLevel + 1);
	ClipFrame:ClearAllPoints();
	ClipFrame:SetPoint("CENTER", Panel.Middle, "CENTER", 0, offsetY);
	ClipFrame.Highlight:SetTexture("Interface/AddOns/Narcissus/Art/Minimap/Panel", nil, nil, "TRILINEAR");
	ClipFrame.PushedHighlight:SetTexture("Interface/AddOns/Narcissus/Art/Minimap/Panel", nil, nil, "TRILINEAR");

	local animHighlight = NarciAPI_CreateAnimationFrame(0.25);
	animHighlight.object = ClipFrame;

	Panel:SetHeight(numButtons * BUTTON_HEIGHT + self:GetHeight());
	Panel:SetScript("OnLeave", function(frame)
		if not frame:IsMouseOver() then
			self:ShowPopup(false);
		end
	end)
	Panel:SetScript("OnHide", function(frame)
		frame:SetAlpha(0);
		frame:Hide();
		animHighlight:Hide();
		ClipFrame:SetPoint("CENTER", Panel.Middle, "CENTER", 0, offsetY);
		ClipFrame:Hide();
		self:UnregisterEvent("GLOBAL_MOUSE_DOWN");
	end)

	-----------------------------------------------------------

	animHighlight:SetScript("OnUpdate", function(frame, elapsed)
		frame.total = frame.total + elapsed;
		local y = inOutSine(frame.total, frame.fromY, frame.toY, frame.duration);
		if frame.total >= frame.duration then
			y = frame.toY;
			frame:Hide();
		end
		frame.object:SetPoint("CENTER", Panel.Middle, "CENTER", 0, y);
	end);

	self.lastIndex = 1;
	local function UpdateHighlight(buttonIndex)
		ClipFrame:Show();
		if animHighlight:IsShown() then
			local newDirection;
			if buttonIndex > self.lastIndex then
				newDirection = -1;
			else
				newDirection = 1;
			end
			if newDirection ~= self.lastDirection then
				animHighlight:Hide();
				local _;
				_, _, _, _, animHighlight.fromY = ClipFrame:GetPoint();
			else
				--animHighlight.total = animHighlight.total / 2;
			end
		else
			local _;
			_, _, _, _, animHighlight.fromY = ClipFrame:GetPoint();
		end
		animHighlight.toY = offsetY - (buttonIndex - 1)*24;
		animHighlight:Show();
	end

	function self:IsInBound()
		for i = 1, numButtons do
			if buttons[i]:IsMouseOver() then
				return true
			end
		end
		return false
	end

	-----------------------------------------------------------
	local panelEntrance = NarciAPI_CreateAnimationFrame(0.25);
	self.panelEntrance = panelEntrance;
	panelEntrance.object = Panel.Middle;
	Panel.Middle:SetHeight(middleHeight);
	panelEntrance.toHeight = middleHeight;

	local pow = math.pow;
	local function outQuart(t, b, e, d)
		t = t / d - 1
		return (b - e) * (pow(t, 4) - 1) + b
	end

	panelEntrance:SetScript("OnUpdate", function(frame, elapsed)
		frame.total = frame.total + elapsed;
		local height = outSine(frame.total, frame.fromHeight, frame.toHeight, frame.duration);
		local buttonDistance = outSine(frame.total, 12, 0, frame.duration);
		local alpha = min(Panel:GetAlpha() + elapsed/frame.duration, 1);
		if frame.total >= frame.duration then
			height = frame.toHeight;
			buttonDistance = 0;
			alpha = 1;
			frame:Hide();
		end
		frame.object:SetHeight(height);
		for i = 1, numButtons do
			if i == 1 then
				buttons[i]:SetPoint("TOP", Panel.Middle, "TOP", 0, button1OffsetY + buttonDistance);
			else
				buttons[i]:SetPoint("TOP", buttons[i - 1], "BOTTOM", 0, buttonDistance * sqrt(i));
			end
		end
		Panel:SetAlpha(alpha);
	end)

	Panel:SetScript("OnShow", function()
		panelEntrance.total = 0;
		if panelEntrance:IsShown() then
			panelEntrance.fromHeight = Panel:GetHeight();
		else
			panelEntrance.fromHeight = 1;
			panelEntrance:Show();
		end
	end)
	-----------------------------------------------------------
	local function OnEnter(button)
		if not ClipFrame:IsShown() then
			FadeFrame(ClipFrame, 0.2, 1);
		end
		if button:IsEnabled() then
			UpdateHighlight(button.index);
		end
		SetCursor("Interface/CURSOR/Item.blp");
	end

	local function OnLeave(button)
		if not self:IsInBound() then
			FadeFrame(ClipFrame, 0.2, 0);
			ResetCursor();
		end
		if not Panel:IsMouseOver() then
			self:ShowPopup(false);
		end
	end

	
	local function OnMouseDown()
		ClipFrame.PushedHighlight:Show();
	end

	local function OnMouseUp()
		ClipFrame.PushedHighlight:Hide();
	end

	for i = 1, numButtons do
		local frameName = frameNames[i];
		if frameName then
			frameName = frameName.."_MinimapButton";
		end
		button = CreateFrame("Button", frameName, Panel, "NarciMinimapPanelButtonTemplate");
		tinsert(buttons, button);
		button:SetFrameLevel(buttonFrameLevel);
		button.BlackText:SetText(LOCALIZED_NAMES[i]);
		button.WhiteText:SetText(LOCALIZED_NAMES[i]);
		button.BlackText:SetParent(ClipFrame);
		button.index = i;
		button.func = func[i];

		if i == 1 then
			button:SetPoint("TOP", Panel.Middle, "TOP", 0, button1OffsetY);
		else
			button:SetPoint("TOP", buttons[i - 1], "BOTTOM", 0, 0);
			--button:SetPoint("TOP", Panel.Middle, "TOP", 0, offsetY - middleHeight/2 + BUTTON_HEIGHT/2 - BUTTON_HEIGHT * (i - 1) );
		end

		button:SetScript("OnEnter", OnEnter);
		button:SetScript("OnLeave", OnLeave);
		button:SetScript("OnMouseDown", OnMouseDown);
		button:SetScript("OnMouseUp", OnMouseUp);
		button:SetScript("OnClick", function(frame)
			self:ShowPopup(false);
			if frame.func then
				frame.func();
			end
		end);

		if not func[i] then
			button:Disable();
		end
	end
	self.buttons = buttons;
	
	self.CreatePanel = nil;
end

function NarciMinimapButtonMixin:OnLoad()
	MiniButton = self;
	self:RegisterForClicks("LeftButtonUp","RightButtonUp","MiddleButtonUp");
	self:RegisterForDrag("LeftButton");
	self.endAlpha = 1;

	self:CreatePanel();

	--Create Popup Delay
	local delay = NarciAPI_CreateAnimationFrame(0.35);	--Mouseover Delay
	self.onEnterDelay = delay;
	delay:SetScript("OnUpdate", function(frame, elapsed)
		frame.total = frame.total + elapsed;
		if frame.total >= frame.duration then
			if self:IsMouseOver() then
				self:ShowPopup(true);
			end
			frame:Hide();
		end
	end)

	local tooltip = self.TooltipFrame;
	tooltip.Left:SetVertexColor(0.686, 0.914, 0.996);
	tooltip.Middle:SetVertexColor(0.686, 0.914, 0.996);
	tooltip.Right:SetVertexColor(0.686, 0.914, 0.996);

	self:SetScript("OnLoad", nil);
	self.OnLoad = nil;
end

function NarciMinimapButtonMixin:IsAnchoredToMinimap()
	local D = Minimap:GetWidth() / 2 + 12;
	local x0, y0 = Minimap:GetCenter(); 
	local x1, y1 = self:GetCenter();
	local d = sqrt( (x1 - x0)^2 + (y1 - y0)^2 );
	if d <= D then
		return true;
	else
		return false;
	end
end

function NarciMinimapButtonMixin:SetTooltipText(text)
	local tooltip = self.TooltipFrame;
	tooltip.Description:SetText(text);
	local textWidth = tooltip.Description:GetWidth();
	tooltip:SetWidth(max(32, textWidth + 8));
	tooltip:ClearAllPoints();

	local scale = UIParent:GetEffectiveScale();
	local x, y = self:GetCenter();
	y = y + 36;
	tooltip:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x*scale, y*scale);
	tooltip:Show();
end

function NarciMinimapButtonMixin:StartRepositioning()
	self:ShowPopup(false);
	self:StopMovingOrSizing();
	self.DraggingFrame:Hide();
	self.TooltipFrame:Hide();
	self:ClearAllPoints();
	if not IsShiftKeyDown() and self:IsAnchoredToMinimap() then
		self:SetTooltipText("Hold Shift for free move");
		self.DraggingFrame:Show();
		NarcissusDB.AnchorToMinimap = true;
	else
		self:StartMoving();
		NarcissusDB.AnchorToMinimap = false;
	end
	self:RegisterEvent("MODIFIER_STATE_CHANGED");
end

function NarciMinimapButtonMixin:OnDragStart()
	self:StartRepositioning();
end

function NarciMinimapButtonMixin:OnDragStop()
	self.DraggingFrame:Hide();
	self:StopMovingOrSizing();
	self:SetUserPlaced(true);
	if self:IsMouseOver() then
		self:OnEnter();
	end
	self:UnregisterEvent("MODIFIER_STATE_CHANGED");
	self.TooltipFrame:Hide();
end

function NarciMinimapButtonMixin:PostClick(button, down)
	if button == "MiddleButton" then
		Narci:EmergencyStop();
	end
end

function NarciMinimapButtonMixin:OnMouseDown()
	self.onEnterDelay:Hide();
end

function NarciMinimapButtonMixin:OnClick(button, down)
	self.onEnterDelay:Hide();
	GameTooltip:Hide();

	if button == "MiddleButton" then
		return;
	elseif button == "RightButton" then
		if IsShiftKeyDown() then
			NarcissusDB.ShowMinimapButton = false;
			print("Minimap button has been hidden. You may type /Narci minimap to re-enable it.");
			self:Hide();
			Narci_MinimapButtonSwitch.Tick:Hide();
		else
			if self.showPanelOnMouseOver then
				Narci_OpenGroupPhoto();
				GameTooltip:Hide();
				self:Disable();
				After(duration_Lock, function()
					self:Enable()
				end)
			else
				self:ShowPopup(true);
			end
		end
		return;
	end
	
	--"LeftButton"
	if IsShiftKeyDown() then
		DressUpFrame_Show(DressUpFrame);
		Narci_UpdateDressingRoom();
		--FadeFrame(Narci_ItemParser, 0.25, 1);
		return;
	end

	self:Disable();	
	Narci_Open();

	After(duration_Lock, function()
		self:Enable();
	end)
end

function NarciMinimapButtonMixin:SetBackground(index)
	if not index then
		index = C_Covenants.GetActiveCovenantID();
	end
	local minimapTexture = "Interface/AddOns/Narcissus/Art/Minimap/LOGO-";
	if index == 2 then
		--Venthyr
		minimapTexture = minimapTexture.."Brown";
	elseif index == 4 then
		--Necrolord
		minimapTexture = minimapTexture.."Green";
	else
		minimapTexture = minimapTexture.."Cyan";
	end
	self.Background:SetTexture(minimapTexture);
	self.Color:SetTexture(minimapTexture);
end

function NarciMinimapButtonMixin:SetIconScale(scale)
	self.Background:SetScale(scale);
end

function NarciMinimapButtonMixin:OnEnter()
	--[[

	--]]
	if IsMouseButtonDown() then return; end;
	self:ShowMouseMotionVisual(true);
	if (not IsShiftKeyDown()) then
		if self.showPanelOnMouseOver then
			self.onEnterDelay:Show();
		elseif not self.Panel:IsShown() then
			GameTooltip:SetOwner(self, "ANCHOR_NONE");
			GameTooltip:SetPoint("TOPRIGHT", self, "BOTTOM", 0, 0);
			GameTooltip:SetText(NARCI_GRADIENT);
			
			--Normal Tooltip
			local HotKey1, HotKey2 = GetBindingKey("TOGGLECHARACTER0");
			local KeyText;
			local LeftClickText = L["Minimap Tooltip Left Click"];
			if HotKey1 and NarcissusDB.EnableDoubleTap then
				KeyText = "("..HotKey1..")";
				if HotKey2 then
					KeyText = KeyText .. "|cffffffff or |r("..HotKey2..")";
				end
				LeftClickText = LeftClickText.." |cffffffff".."/".." |r"..L["Minimap Tooltip Double Click"].." "..KeyText.."|r";
			end
		
			local bindAction = "CLICK MiniButton:LeftButton";
			local keyBind = GetBindingKey(bindAction);
			if keyBind and keyBind ~= "" then
				LeftClickText = LeftClickText.." |cffffffff".."/|r "..keyBind;
			end
		
		
			GameTooltip:AddLine(LeftClickText.." "..L["Minimap Tooltip To Open"], nil, nil, nil, false);
			GameTooltip:AddLine(L["Minimap Tooltip Right Click"].." "..L["Minimap Tooltip Module Panel"], nil, nil, nil, false);
			GameTooltip:AddLine(L["Minimap Tooltip Shift Left Click"].." "..L["Toggle Dressing Room"], nil, nil, nil, true);
			GameTooltip:AddLine(L["Minimap Tooltip Shift Right Click"].." "..L["Minimap Tooltip Hide Button"], nil, nil, nil, true);
			GameTooltip:AddLine(L["Minimap Tooltip Middle Button"], nil, nil, nil, true);
			GameTooltip:AddLine(" ", nil, nil, nil, true);
			GameTooltip:AddDoubleLine(NARCI_VERSION_INFO, NARCI_DEVELOPER_INFO, 0.8, 0.8, 0.8, 0.8, 0.8, 0.8);
			GameTooltip:AddLine("https://wow.curseforge.com/projects/narcissus", 0.5, 0.5, 0.5, false);
		
			GameTooltip:Show();
		end
	end
end

function NarciMinimapButtonMixin:ShowMouseMotionVisual(visible)
	if not self:IsShown() then return end;
	if visible then
		SetCursor("Interface/CURSOR/Item.blp");
		self.Color:Show();
		self:SetIconScale(1.1);
		FadeFrame(self.Color, 0.2, 1);
		FadeFrame(self, 0.2, 1);
	else
		ResetCursor();
		FadeFrame(self.Color, 0.2, 0);
		FadeFrame(self, 0.2, self.endAlpha);
		self:SetIconScale(1);
	end
end

function NarciMinimapButtonMixin:PlayBling()
	self.Bling:Show();
	self.Bling.animScale:Play();
end

function NarciMinimapButtonMixin:OnLeave()
	GameTooltip:Hide();
	if self.DraggingFrame:IsShown() then
		return;
	end
	if self:IsShown() then
		if not (self.Panel:IsMouseOver() and self.Panel:IsShown() ) then
			self:ShowPopup(false);
		end
	else
		self.Color:SetAlpha(0);
	end
end

function NarciMinimapButtonMixin:OnHide()
	self:ShowPopup(false);
	self.Panel.ClipFrame:Hide();
	self:UnregisterEvent("MODIFIER_STATE_CHANGED");
end

function NarciMinimapButtonMixin:ShowPopup(visible)
	if visible then
		self.Panel:Show();
		self:RegisterEvent("GLOBAL_MOUSE_DOWN");
	else
		FadeFrame(self.Panel, 0.15, 0);
		self:ShowMouseMotionVisual(false);
		self.onEnterDelay:Hide();
		self.panelEntrance:Hide();
		self:UnregisterEvent("GLOBAL_MOUSE_DOWN");
	end
end

function NarciMinimapButtonMixin:OnEvent(event)
	if event == "GLOBAL_MOUSE_DOWN" then
		if not self:IsInBound() then
			self:ShowPopup(false);
		end
	elseif event == "MODIFIER_STATE_CHANGED" then
		if self:IsDragging() then
			self:StartRepositioning();
		end
	end
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

local MAP_CORNER_RADIUS = 10;	--minimapbutton offset
local function MinimapButton_UpdateAngle(radian)
	local x, y, q = cos(radian), sin(radian), 1;
	if x < 0 then q = q + 1 end
	if y > 0 then q = q + 2 end
	local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND";
	local quadTable = minimapShapes[minimapShape];
	local w = (Minimap:GetWidth() / 2) + MAP_CORNER_RADIUS	--10
	local h = (Minimap:GetHeight() / 2) + MAP_CORNER_RADIUS
	if quadTable[q] then
		x, y = x*w, y*h
	else
		local diagRadiusW = sqrt(2*(w)^2) - MAP_CORNER_RADIUS	--  -10
		local diagRadiusH = sqrt(2*(h)^2) - MAP_CORNER_RADIUS
		x = max(-w, min(x*diagRadiusW, w));
		y = max(-h, min(y*diagRadiusH, h));
	end
	MiniButton:SetPoint("CENTER", "Minimap", "CENTER", x, y);
end

function Narci_MinimapButton_OnLoad(self)
	if NarcissusDB.AnchorToMinimap then
		MiniButton:ClearAllPoints();
		local radian = NarcissusDB.MinimapButton.Position;
		MinimapButton_UpdateAngle(radian);
	end
end

function Narci_MinimapButton_DraggingFrame_OnUpdate()
	local radian;
	local mx, my = Minimap:GetCenter();
	local px, py = GetCursorPosition();
	local scale = Minimap:GetEffectiveScale();
	px, py = px / scale, py / scale;
	radian = math.atan2(py - my, px - mx);

	MinimapButton_UpdateAngle(radian);
	NarcissusDB.MinimapButton.Position = radian;
end


---------------End of derivation---------------

local BorderTexture = NarciAPI.GetBorderTexture();

local RunePlateTexture = {
	[0] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-Black",		--Enchantable but unenchanted
	[1] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-Black",
	[2] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-Uncommon",
	[3] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-Rare",
	[4] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-Epic",
	[5] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-Legendary",
	[6] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-Artifact",
	[7] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-Heirloom",

	["NZoth"] = "Interface/AddOns/Narcissus/Art/Runes/RunePlate-NZoth",
}

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
	{1, INVTYPE_HEAD}, {3, INVTYPE_SHOULDER}, {15, INVTYPE_CLOAK}, {5, INVTYPE_CHEST}, {4, INVTYPE_BODY}, {19, INVTYPE_TABARD}, {9, INVTYPE_WRIST},		--Left 	**slotID for TABARD is 19
	{10, INVTYPE_HAND}, {6, INVTYPE_WAIST}, {7, INVTYPE_LEGS}, {8, INVTYPE_FEET},																		--Right
	{16, INVTYPE_WEAPONMAINHAND}, {17, INVTYPE_WEAPONOFFHAND},																							--Weapon
};

--[[
local function ShareHyperLink()																	--Send transmog hyperlink to chat
	local delay = 0;																			--Keep message in order
	print(MYMOG_GRADIENT)
	for i=1, #xmogTable do
		local index =  xmogTable[i][1]
		if slotTable[index] and slotTable[index].hyperlink then			
			After(delay, function()
				SendChatMessage(xmogTable[i][2]..": "..slotTable[index].hyperlink, "GUILD")
			end)
			delay = delay + 0.1;
		end
	end
end
--]]

local GetInventoryItemCooldown = GetInventoryItemCooldown;

local function SetItemSocketingFramePosition(self)		--Let ItemSocketingFrame appear on the side of the slot
	if ItemSocketingFrame then																		
		if self.GemSlot:IsShown() then
			ItemSocketingFrame:Show()
		else
			ItemSocketingFrame:Hide()
			return;
		end
		ItemSocketingFrame:ClearAllPoints();
		if self.isRight then
			ItemSocketingFrame:SetPoint("TOPRIGHT", self, "TOPLEFT", 4, 0);
		else
			ItemSocketingFrame:SetPoint("TOPLEFT", self, "TOPRIGHT", -4, 0);
		end
		DefaultTooltip:Hide();
	end
end

local function ShowOrHideEquiment(self)
	if not self.sourceID then return; end;
	self.isSlotHidden = not self.isSlotHidden;
	local slotID = self:GetID();
	if self.isSlotHidden then
		NarciPlayerModelFrame1:UndressSlot(slotID);	
	else
		NarciPlayerModelFrame1:TryOn(self.sourceID, Narci.SlotIDtoName[slotID][1]);	--weapon enchant
	end
end

local IsItemEnchantable = {
	[11] = true,
	[12] = true,
	[16] = true,
	[17] = true,
	[5]  = true,
};

local RunicLetters = {
	["crit"] = "ᚲ\nᚱ\nᛁ",	  --CRI
	["haste"] = "ᚼ\nᛆ\nᛋ",	 --HAS
	["mastery"] = "ᛘ\nᛋ\nᛐ", --MST
	["versatility"] = "ᚡ\nᚽ\nᚱ",	 --VER
	["STR"] = "ᛊ\nᛏ\nᚱ",	 --STR
	["AGI"] = "ᛆ\nᚵ\nᛁ",	 --AGI
	["INT"] = "ᛁ\nᚾ\nᛐ",	 --INT
	["speed"] = "ᛋ\nᛕ\nᛑ",	 --SPF
	["armor"] = "ᛆ\nᚱ\nᛘ",	 --ARM
	["heal"] = "ᚺ\nᛁ\nᛚ", 	 --HIL
	["leech"] = "ᛒ\nᛚ\nᛑ",	 --BLD
	["spell"] = "ᛗ\nᚷ\nᚲ",	 --MGC
}

local function DisplayRuneSlot(equipmentSlot, slotID, itemQuality, itemLink)
	if not equipmentSlot.RuneSlot then
		return;
	elseif (itemQuality == 0) or (not itemLink) then
		equipmentSlot.RuneSlot:Hide();
		return;
	end

	if IsItemEnchantable[slotID] then
		equipmentSlot.RuneSlot:Show();
		equipmentSlot.RuneSlot.Background:SetTexture(RunePlateTexture[itemQuality])
	else
		equipmentSlot.RuneSlot:Hide();
		return;
	end

	local enchantID = GetItemEnchantID(itemLink);
	if enchantID ~= 0 then
		equipmentSlot.RuneSlot.RuneLetter:Show();
		if EnchantInfo[enchantID] then
			equipmentSlot.RuneSlot.RuneLetter:SetText(RunicLetters[ EnchantInfo[enchantID][1] ])
			equipmentSlot.RuneSlot.spellID = EnchantInfo[enchantID][3]
		end
	else
		equipmentSlot.RuneSlot.Background:SetTexture(RunePlateTexture[0])	--if the item is enchantable but unenchanted, set its texture to black
		equipmentSlot.RuneSlot.spellID = nil;
		equipmentSlot.RuneSlot.RuneLetter:Hide();
	end
end

function Narci_RuneButton_OnEnter(self)
	local spellID = self.spellID;
	if (not spellID) then
		return;
	end
	DefaultTooltip:SetOwner(self, "ANCHOR_NONE");
	DefaultTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 0);
	DefaultTooltip:SetSpellByID(spellID);
	DefaultTooltip:Show()
end

---------------------------------------------------
local USE_DELAY = true;
local function AssignDelay(id, forced)
	if USE_DELAY or forced then
		local time = 0;
		if id == 1 then
			time = 1;
		elseif id == 2 then
			time = 2;
		elseif id == 3 then
			time = 3;
		elseif id == 15 then	--back
			time = 4;
		elseif id == 5 then
			time = 5;
		elseif id == 9 then
			time = 6;
		elseif id == 16 then
			time = 7;
		elseif id == 17 then
			time = 8;
		elseif id == 4 then		--shirt
			time = 9;
		elseif id == 10 then
			time = 10;
		elseif id == 6 then
			time = 11;
		elseif id == 7 then
			time = 12;
		elseif id == 8 then
			time = 13;
		elseif id == 11 then
			time = 14;
		elseif id == 12 then
			time = 15;
		elseif id == 13 then
			time = 16;	
		elseif id == 14 then
			time = 17;	
		elseif id == 19 then
			time = 18;
		end
		
		time = time/20;
		return time;
	else
		return 0;
	end;
end

local function GetTraitsIcon(itemLocation)
    if not itemLocation then return; end
    local TierInfos = C_AzeriteEmpoweredItem.GetAllTierInfo(itemLocation);
	if not TierInfos then return; end
	local powerIDs, icon, _;
	local isRightSpec = true;
	local traitIcons = {};
	local specIndex = GetSpecialization() or 1;
	local specID = GetSpecializationInfo(specIndex);
	local MAX_TIERS = 5;

    for i = 1, MAX_TIERS do
        if (not TierInfos[i]) or (not TierInfos[i].azeritePowerIDs) then         
            return traitIcons;
        end
		powerIDs = TierInfos[i].azeritePowerIDs;
        for k, powerID in pairs(powerIDs) do
			if C_AzeriteEmpoweredItem.IsPowerSelected(itemLocation, powerID) then
				local PowerInfo = C_AzeriteEmpoweredItem.GetPowerInfo(powerID)
				isRightSpec = isRightSpec and C_AzeriteEmpoweredItem.IsPowerAvailableForSpec(powerID, specID);
				_, _, icon = GetSpellInfo(PowerInfo and PowerInfo.spellID);
                traitIcons[i] = icon;
                break;
            else
                traitIcons[i] = "";
            end
        end
	end

    return traitIcons, isRightSpec;
end


local GetSlotVisualID = NarciAPI.GetSlotVisualID;
local GetGemBorderTexture = NarciAPI.GetGemBorderTexture;
local GetItemQualityColor = NarciAPI.GetItemQualityColor;

local QueueFrame = NarciAPI.CreateProcessor();

NarciEquipmentSlotMixin = {};

function NarciEquipmentSlotMixin:Refresh()
	local _;
	local slotID = self:GetID();
	local itemLocation = ItemLocation:CreateFromEquipmentSlot(slotID)
	--print(slotName..slotID)
	--local texture = CharacterHeadSlot.popoutButton.icon:GetTexture()
	local itemLink = "";
	local itemIcon, itemName, itemQuality, effectiveLvl, GemName, GemLink;
	local borderTex;
	local isAzeriteEmpoweredItem = false;		--3 Pieces	**likely to be changed in patch 8.2
	local isAzeriteItem = false;				--Heart of Azeroth
	--local isCorruptedItem = false; 

	if C_Item.DoesItemExist(itemLocation) then
		if MOG_MODE then
			self:UntrackCooldown();

			self.isSlotHidden = false;	--Undress an item from player model
			self.RuneSlot:Hide();		
			self.GradientBackground:Show();
			local appliedSourceID, appliedVisualID = GetSlotVisualID(slotID);
			if appliedVisualID > 0 then
				local sourceInfo = {};
				if appliedVisualID ~= self.appliedVisualID or (not (self.sourceInfo and self.sourceInfo.name)) then
					--print("Caching...#"..slotID)
					self.appliedVisualID = appliedVisualID;
					sourceInfo = C_TransmogCollection.GetSourceInfo(appliedSourceID);
					self.sourceInfo = sourceInfo;
					_, self.sourceID = C_TransmogCollection.GetItemInfo(sourceInfo.itemID, sourceInfo.itemModID);
					if sourceInfo.sourceType == 1 then
						self.drops = C_TransmogCollection.GetAppearanceSourceDrops(self.sourceID);
					end
				else
					sourceInfo = self.sourceInfo;
					--print("Slot #"..slotID.." is using cache.")
				end
				self.itemID = sourceInfo.itemID;																						--saved for export
				itemName = sourceInfo.name; 																							--sourceitemName
				--local _, sourceID = C_TransmogCollection.GetItemInfo(sourceInfo.itemID, sourceInfo.itemModID)							--appearanceID, sourceID
				itemQuality = sourceInfo.quality;																					--sourceitemQuality
				itemIcon = C_TransmogCollection.GetSourceIcon(appliedSourceID);
				local _, _, _, hex = GetItemQualityColor(itemQuality);
				_, self.hyperlink = GetItemInfo(sourceInfo.itemID);
				self.itemModID = sourceInfo.itemModID;

				local sourceType = sourceInfo.sourceType;
				local difficulty;
				local bonusID;

				if sourceType == 1 then	--TRANSMOG_SOURCE_BOSS_DROP = 1
					local drops = self.drops	--C_TransmogCollection.GetAppearanceSourceDrops(self.sourceID)
					if drops and drops[1] then
						effectiveLvl = drops[1].encounter.." ".."|cFFFFD100"..drops[1].instance.."|r|CFFf8e694";
						self.sourcePlainText = drops[1].encounter.." "..drops[1].instance;
						
						if sourceInfo.itemModID == 0 then 
							difficulty = PLAYER_DIFFICULTY1;
							bonusID = 3561;
							self.hyperlink = "|c"..hex.."|Hitem:"..sourceInfo.itemID.."::::::::120::::2:356".."1"..":1476:|h|r";
						elseif sourceInfo.itemModID == 1 then 
							difficulty = PLAYER_DIFFICULTY2;
							bonusID = 3562;
							self.hyperlink = "|c"..hex.."|Hitem:"..sourceInfo.itemID.."::::::::120::::2:356".."2"..":1476:|h|r";
						elseif sourceInfo.itemModID == 3 then 
							difficulty = PLAYER_DIFFICULTY6;
							bonusID = 3563;
							self.hyperlink = "|c"..hex.."|Hitem:"..sourceInfo.itemID.."::::::::120::::2:356".."3"..":1476:|h|r";
						elseif sourceInfo.itemModID == 4 then
							difficulty = PLAYER_DIFFICULTY3;
							bonusID = 3564;
							self.hyperlink = "|c"..hex.."|Hitem:"..sourceInfo.itemID.."::::::::120::::2:356".."4"..":1476:|h|r";
						end

						if difficulty then
							effectiveLvl = effectiveLvl.." "..difficulty;
							self.sourcePlainText = self.sourcePlainText.." "..difficulty;
						end
					end
				else
					if sourceType == 2 then --quest
						effectiveLvl = TRANSMOG_SOURCE_2
						if sourceInfo.itemModID == 3 then 
							self.hyperlink = "|c"..hex.."|Hitem:"..sourceInfo.itemID.."::::::::120::::2:512".."6"..":1562:|h|r";
							bonusID = 5126;
						elseif sourceInfo.itemModID == 2 then 
							self.hyperlink = "|c"..hex.."|Hitem:"..sourceInfo.itemID.."::::::::120::::2:512".."5"..":1562:|h|r";
							bonusID = 5125;
						elseif sourceInfo.itemModID == 1 then 
							self.hyperlink = "|c"..hex.."|Hitem:"..sourceInfo.itemID.."::::::::120::::2:512".."4"..":1562:|h|r";
							bonusID = 5124;
						end
					elseif sourceType == 3 then --vendor
						effectiveLvl = TRANSMOG_SOURCE_3;
					elseif sourceType == 4 then --world drop
						effectiveLvl = TRANSMOG_SOURCE_4;
					elseif sourceType == 5 then --achievement
						effectiveLvl = TRANSMOG_SOURCE_5;
					elseif sourceType == 6 then	--profession
						effectiveLvl = TRANSMOG_SOURCE_6;
					else
						if itemQuality == 6 then
							effectiveLvl = ITEM_QUALITY6_DESC;
						elseif itemQuality == 5 then
							effectiveLvl = ITEM_QUALITY5_DESC;
						end
					end
					self.sourcePlainText = effectiveLvl;
				end
				if self.hyperlink then
					_, self.hyperlink = GetItemInfo(self.hyperlink);																		--original hyperlink cannot be printed (workaround)
				end

				if itemQuality == 6 then
					if slotID == 16 then
						bonusID = (sourceInfo.itemModID or 0);	--Artifact use itemModID "7V0" + modID - 1
					else
						bonusID = 0;
					end
				end
				self.bonusID = bonusID;

				if effectiveLvl == nil then
					local _, sourceName = IsItemSourceSpecial(self.itemID);
					effectiveLvl = sourceName or " ";
				end

				if slotID == 15 then
					--Backslot
					self.VFX:Hide();
				end
			else	--irrelevant slot
				itemName = " ";
				itemQuality = 0;
				self.Icon:SetDesaturated(true);
				self.Name:Hide();
				self.ItemLevel:Hide();
				self.GradientBackground:Hide();
				self.bonusID = nil;
			end
		else
			self:TrackCooldown();
			
			self.Icon:SetDesaturated(false)
			self.Name:Show();
			self.ItemLevel:Show();
			self.GradientBackground:Show();
	
			--[[
			local current, maximum = GetInventoryItemDurability(slotID);
			if current and maximum then
				self.durability = (current / maximum);
			end
			--]]
	
			itemIcon = GetInventoryItemTexture("player", slotID);
			itemLink = C_Item.GetItemLink(itemLocation);
			itemName = C_Item.GetItemName(itemLocation);
			itemQuality = C_Item.GetItemQuality(itemLocation);
			effectiveLvl = C_Item.GetCurrentItemLevel(itemLocation);
			self.IlvlCenter.ItemLevelCenter:SetText(effectiveLvl);

			--Debug
			--if effectiveLvl and effectiveLvl > 1 then
			--	NarciDebug:CalculateAverage(effectiveLvl);
			--end
			
			if slotID == 13 or slotID == 14 then
				local itemID = GetItemInfoInstant(itemLink);
				if itemID == 167555 then	--Pocket-Sized Computation Device
					GemName, GemLink = IsItemSocketable(itemLink, 2);
				else
					GemName, GemLink = IsItemSocketable(itemLink);
				end
			else
				GemName, GemLink = IsItemSocketable(itemLink);
			end
	
			self.hyperlink = nil;
			self.GemSlot.ItemLevel = effectiveLvl;
			self.GemLink = GemLink;		--Later used in OnEnter func in NarciSocketing.lua
	
			if slotID == 2 then
				isAzeriteItem = C_AzeriteItem.IsAzeriteItem(itemLocation);
			elseif slotID == 1 or slotID == 3 or slotID == 5 then
				isAzeriteEmpoweredItem = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation);
			else
				--isCorruptedItem = IsCorruptedItem(itemLink);
			end

			if slotID == 15 then
				--Backslot
				local itemID = GetItemInfoInstant(itemLink);
				if itemID == 169223 then 	--Ashjra'kamas, Shroud of Resolve Legendary Cloak
					local rank, corruptionResistance = NarciAPI.GetItemRank(itemLink, "ITEM_MOD_CORRUPTION_RESISTANCE");
					effectiveLvl = effectiveLvl.."  "..rank.."  |cFFFFD100"..corruptionResistance.."|r";
					borderTex = BorderTexture.BlackDragon;
					self.VFX:Show();
				else
					self.VFX:Hide();
				end
			end
		
			local enchantText = GetItemEnchantText(itemLink, true);
			if enchantText then
				if self.isRight then
					effectiveLvl = enchantText.."  "..effectiveLvl;
				else
					effectiveLvl = effectiveLvl.."  "..enchantText;
				end		
			end
	
			--Enchant Frame--
			if itemQuality then
				DisplayRuneSlot(self, slotID, itemQuality, itemLink);
			end
		end
	else
		self:UntrackCooldown();
		self.GradientBackground:Hide();
		self.Icon:SetDesaturated(false);
		self.itemID = nil;
		self.bonusID = nil;
		itemQuality = 0;
		itemIcon = self.emptyTexture;
		itemName = " " ;
		effectiveLvl = "";
		DisplayRuneSlot(self, slotID, 0);
	end

	if not itemName or itemName == "" then
		QueueFrame:Add(self, self.Refresh);
		return
	end

	self.itemQuality = itemQuality;
	
	local Br, Bg, Bb = 1, 1, 1;
	if itemQuality then --itemQuality sometimes return nil. This is a temporary solution
		Br, Bg, Bb = GetItemQualityColor(itemQuality);
		borderTex = BorderTexture[itemQuality];
	end

	if isAzeriteEmpoweredItem then
		borderTex = BorderTexture[8];
		if not MOG_MODE then
			local icons, isRightSpec = GetTraitsIcon(itemLocation);
			for i = 1, #icons do
				effectiveLvl = effectiveLvl.." |T"..icons[i]..":12:12:0:0:64:64:4:60:4:60|t";
			end
		end
	end

	if isAzeriteItem then
		local heartLevel = C_AzeriteItem.GetPowerLevel(itemLocation);
		local xp_Current, xp_Needed =  C_AzeriteItem.GetAzeriteItemXPInfo(itemLocation);
		local GetEssenceInfo = C_AzeriteEssence.GetEssenceInfo;
		local GetMilestoneEssence = C_AzeriteEssence.GetMilestoneEssence; 
		if not C_AzeriteItem.IsAzeriteItemAtMaxLevel() then
			heartLevel = heartLevel .. "  |CFFf8e694" .. floor((xp_Current/xp_Needed)*100 + 0.5) .. "%";
		end
		effectiveLvl = effectiveLvl.."  |cFFFFD100"..heartLevel;
		
		local EssenceID = GetMilestoneEssence(115);
		if EssenceID then
			borderTex = BorderTexture.Heart;
			local EssenceInfo = GetEssenceInfo(EssenceID);
			Br, Bg, Bb = GetItemQualityColor(EssenceInfo.rank + 1);
			itemName = EssenceInfo.name;
			itemIcon = EssenceInfo.icon;

			--Gem glow
			self.VFX:Show();
		end

		for i = 116, 119 do
			--116, 117, 119  3 minor slots
			if i ~= 118 then
				EssenceID = GetMilestoneEssence(i);
				if EssenceID then
					local icon = GetEssenceInfo(EssenceID).icon;
					effectiveLvl = effectiveLvl.." |T"..icon..":12:12:0:0:64:64:4:60:4:60|t";
				end
			end
		end
	else
		if slotID == 2 then
			self.VFX:Hide();
		end
	end

	--[[
	if isCorruptedItem then
		borderTex = BorderTexture.NZoth;
		if not MOG_MODE then
			local corruption = GetItemStats(itemLink)["ITEM_MOD_CORRUPTION"];
			if corruption then
				local Affix = GetCorruptedItemAffix(itemLink);
				if Affix then
					if self.isRight then
						effectiveLvl = Affix.."  |cff946dd1"..corruption.."|r  "..effectiveLvl;
					else
						effectiveLvl = effectiveLvl.."  "..Affix.."  |cff946dd1"..corruption.."|r";
					end
				else
					if self.isRight then
						effectiveLvl = "|cff946dd1"..corruption.."|r  "..effectiveLvl;
					else
						effectiveLvl = effectiveLvl.."  |cff946dd1"..corruption.."|r";
					end				
				end
			end
			itemQuality = "NZoth";
		end
	end
	--]]
	

	--Gem Slot--
	self:StopAnimating();
	if GemName ~= nil then
		if GemLink then
			--local _, _, _, _, _, _, _, _, _, GemIcon, _, _, itemSubClassID = GetItemInfo(GemLink);
			local id, _, _, _, GemIcon, _, itemSubClassID = GetItemInfoInstant(GemLink);
			local GemTexture = GetGemBorderTexture(itemSubClassID, id);
			self.GemSlot.GemBorder:SetTexture(GemTexture);
			self.GemSlot.GemIcon:SetTexture(GemIcon);
			self.GemSlot.GemIcon:Show();
			self.GemSlot.itemID = id;
		else
			self.GemSlot.GemBorder:SetTexture("Interface/AddOns/Narcissus/Art/GemBorder/GemSlot");	--empty socket
			self.GemSlot.GemIcon:SetTexture(nil);
			self.GemSlot.GemIcon:Hide();
		end
		if self:IsVisible() then
			self.GemSlot.animIn:Play();
		else
			self.GemSlot:Show();
		end
	else
		if self:IsVisible() then
			self.GemSlot.animOut:Play();
		else
			self.GemSlot:Hide();
		end
	end
	--------------------------------------------------
	--Display Texts: Transition Animation --solve frame rate drop
	if self:IsVisible() then
		self.BorderOverlay:SetTexture(borderTex);
		self.Border.anim:Play();
		if itemIcon then
			self.IconOverlay:SetTexture(itemIcon);
			self.Icon.anim:Play();
		end
		self.ItemLevel.anim1:SetScript("OnFinished", function()
			self.ItemLevel:SetText(effectiveLvl);
			self.ItemLevel.anim2:Play();
		end)
		self.Name.anim1:SetScript("OnFinished", function()
			self.Name:SetText(itemName);
			self.Name:SetTextColor(Br, Bg, Bb);
			self.Name.anim2:Play();
			After(0, function()
				self:UpdateGradientSize();
			end)
		end)
		self.ItemLevel.anim1:Play();
		self.Name.anim1:Play();
	else
		self.ItemLevel:SetText(effectiveLvl);
		self.Name:SetText(itemName);
		self.Name:SetTextColor(Br, Bg, Bb);
		self.Border:SetTexture(borderTex);
		if itemIcon then
			self.Icon:SetTexture(itemIcon);
		end
		self:UpdateGradientSize();
	end
	--self.GradientBackground:SetHeight(self.Name:GetHeight() + self.ItemLevel:GetHeight() + 18);

	return true
end

function NarciEquipmentSlotMixin:UpdateGradientSize()
	self.GradientBackground:SetHeight(self.Name:GetHeight() + self.ItemLevel:GetHeight() + 18);
	self.GradientBackground:SetWidth(max(self.Name:GetWrappedWidth(), self.ItemLevel:GetWrappedWidth()) + 48);
end

function NarciEquipmentSlotMixin:OnLoad()
	local slotName = self.slotName;
	local slotID, textureName = GetInventorySlotInfo(slotName);
	self.emptyTexture = textureName;
	self:SetID(slotID);
	self:SetAttribute("type2", "item");
	self:SetAttribute("item", slotID);
	self:RegisterForDrag("LeftButton");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	if self:GetParent() then
		if not self:GetParent().slotTable then
			self:GetParent().slotTable = {}
		end
		tinsert(self:GetParent().slotTable, self);
	end

	self:SetScript("OnLoad", nil);
	self.OnLoad = nil;
end

function NarciEquipmentSlotMixin:OnEvent(event, ...)
	if event == "MODIFIER_STATE_CHANGED" then
		local key, state = ...;
		if ( key == "LALT" and self:IsMouseOver() ) then
			local flyout = EquipmentFlyoutFrame;
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
	elseif event == "UI_ERROR_MESSAGE" then
		self:UnregisterErrorEvent();
		local _, msg = ...
		Narci_AlertFrame_Autohide:AddMessage(msg, true);
	end
end

function NarciEquipmentSlotMixin:UntrackCooldown()
	--self.trackCD = nil;
	if self.CooldownFrame then
		self.CooldownFrame.Cooldown:Clear();
	end
end

function NarciEquipmentSlotMixin:TrackCooldown()
	local start, duration, enable = GetInventoryItemCooldown("player", self:GetID());
	if enable and enable ~= 0 and start > 0 and duration > 0 then
		if not self.CooldownFrame then
			self.CooldownFrame = CreateFrame("Frame", nil, self, "Narci_CooldownFrameTemplate");
		end
		local frame = self.CooldownFrame.Cooldown; 
		frame:SetCooldown(start, duration);
		frame:SetHideCountdownNumbers(false);
		return true
	else
		self:UntrackCooldown();
	end
	return false
end

function NarciEquipmentSlotMixin:ResetAnimation()
	self.Icon.scaleUp:Stop();
	self.Border.scaleUp:Stop();
	self.IconMask.scaleUp:Stop();
	self.Icon:SetScale(1);
	self.Border:SetScale(1);
	self.IconMask:SetScale(1);
end

function NarciEquipmentSlotMixin:OnEnter(motion, isGamepad)
	self:RegisterEvent("MODIFIER_STATE_CHANGED");

	if isGamepad then
		self.Icon.scaleUp:Play();
		self.Border.scaleUp:Play();
		self.IconMask.scaleUp:Play();
	else
		FadeFrame(self.Highlight, 0.15, 1);
	end

	if IsAltKeyDown() and not MOG_MODE then
		Narci_EquipmentFlyout_Show(self, self:GetID());
		EquipmentFlyoutFrame.Arrow:Show();
	end

	if EquipmentFlyoutFrame:IsShown() then
		Narci_Comparison_SetComparison(EquipmentFlyoutFrame.BaseItem, self);
		return;
	end

	DefaultTooltip:SetOwner(self, "ANCHOR_NONE");

	if self.isRight then
		DefaultTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", DefaultTooltip.offsetX, DefaultTooltip.offsetY);
	else
		DefaultTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", -DefaultTooltip.offsetX, DefaultTooltip.offsetY);
	end

	if (self.hyperlink) then
		DefaultTooltip:SetHyperlink(self.hyperlink);
		DefaultTooltip:Show();
		return;
	end

	local hasItem, hasCooldown, repairCost = DefaultTooltip:SetInventoryItem("player", self:GetID(), nil, true);

	if isGamepad then
		DefaultTooltip:SetAlpha(0);
		if self.isRight then
			NarciAPI_ShowDelayedTooltip("TOPRIGHT", self, "TOPLEFT", DefaultTooltip.offsetX, DefaultTooltip.offsetY);
		else
			NarciAPI_ShowDelayedTooltip("TOPLEFT", self, "TOPRIGHT", -DefaultTooltip.offsetX, DefaultTooltip.offsetY);
		end
	else
		DefaultTooltip:Show();
		if hasItem then
			DefaultTooltip.HotkeyFrame:FadeIn();
		end
	end
end

function NarciEquipmentSlotMixin:OnLeave()
	self:UnregisterEvent("MODIFIER_STATE_CHANGED");
	self:UnregisterErrorEvent();
	FadeFrame(self.Highlight, 0.25, 0);
	Narci:HideButtonTooltip();

	self:ResetAnimation();
end

function NarciEquipmentSlotMixin:OnHide()
	self.Highlight:Hide();
	self.Highlight:SetAlpha(0);

	self:ResetAnimation();
end

function NarciEquipmentSlotMixin:PostClick(button)
	if CursorHasItem() then
		EquipCursorItem(self:GetID());
		return
	end

	ClearCursor();
	if ( IsModifiedClick() ) then
		if IsAltKeyDown() and button == "LeftButton" then
			local action = EquipmentManager_UnequipItemInSlot(self:GetID())
			if action then
				EquipmentManager_RunAction(action)
			end
			return;
		elseif IsShiftKeyDown() and button == "LeftButton" then
			if self.hyperlink then
				SendChatMessage(self.hyperlink)
			end
			--ShareHyperLink()
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
			if MOG_MODE then	--Undress an item from player model while in Xmog Mode
				ShowOrHideEquiment(self);
			else	
				Narci_EquipmentFlyout_Show(self, self:GetID());
			end
		elseif button == "RightButton" then
			Narci_AlertFrame_Autohide:SetAnchor(self, -24, true);
		end
	end
end

function NarciEquipmentSlotMixin:OnDragStart()
	local itemLocation = ItemLocation:CreateFromEquipmentSlot(self:GetID())
	if C_Item.DoesItemExist(itemLocation) then
		C_Item.UnlockItem(itemLocation);
		PickupInventoryItem(self:GetID());
	end
end

function NarciEquipmentSlotMixin:OnReceiveDrag()
	PickupInventoryItem(self:GetID());	--In fact, attemp to equip cursor item
end

function NarciEquipmentSlotMixin:RegisterErrorEvent()
	self:RegisterEvent("UI_ERROR_MESSAGE");
end

function NarciEquipmentSlotMixin:UnregisterErrorEvent()
	self:UnregisterEvent("UI_ERROR_MESSAGE");
end


local function SetStatTooltipText(self)
	DefaultTooltip:ClearAllPoints();
	DefaultTooltip:SetOwner(self, "ANCHOR_NONE");
	DefaultTooltip:SetText(self.tooltip);
	if ( self.tooltip2 ) then
		DefaultTooltip:AddLine(self.tooltip2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	end
	if ( self.tooltip3 ) then
		DefaultTooltip:AddLine(" ");
		DefaultTooltip:AddLine(self.tooltip3, RAID_CLASS_COLORS["MAGE"].r, RAID_CLASS_COLORS["MAGE"].g, RAID_CLASS_COLORS["MAGE"].b, true);
	end
	if ( self.tooltip4 ) then
		DefaultTooltip:AddLine(" ");
		DefaultTooltip:AddDoubleLine(self.tooltip4[1], self.tooltip4[2], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);		
	end
end

function Narci_ShowStatTooltip(self, direction)
	if ( not self.tooltip ) then
		return;
	end
	SetStatTooltipText(self)
	if (not direction) then
		DefaultTooltip:SetPoint("TOPRIGHT",self,"TOPLEFT", -4, 0)
	elseif direction=="RIGHT" then
		DefaultTooltip:SetPoint("LEFT",self,"RIGHT", 0, 0)
	elseif direction=="TOP" then
		DefaultTooltip:SetPoint("BOTTOM",self,"TOP", 0, -4)
	elseif direction=="CURSOR" then
		DefaultTooltip:SetOwner(self, "ANCHOR_CURSOR");
	end

	DefaultTooltip:Show();
end

function Narci_ShowStatTooltipDelayed(self)
	if ( not self.tooltip ) then
		return;
	end
	SetStatTooltipText(self);
	DefaultTooltip:SetAlpha(0);
	NarciAPI_ShowDelayedTooltip("BOTTOM",self,"TOP", 0, -4);
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

--[[local RegenList = {
	[2] = STAT_FOCUS_REGEN,
	[3] = STAT_ENERGY_REGEN,
	[5] = STAT_RUNE_REGEN,
}--]]

local function trim(s)
	if s ~= nil then
		return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
	else
		return nil
	end
end

local function PlayIlvlInfoAnimation()
	local frame = Narci_ItemLevelFrame;
	local frame1 = frame.LeftButton;
	local frame2 = frame.RightButton;

	if NarcissusDB.DetailedIlvlInfo and not frame1:IsVisible() and not MOG_MODE then
		frame1.AnimFrame:Show();
		frame2.AnimFrame:Show();
		frame1:Show();
		frame2:Show();
	end
end

local function ShowDetailedIlvlInfo(self)
	if NarcissusDB.DetailedIlvlInfo then
		FadeFrame(Narci_DetailedStatFrame, 0, 1);
		FadeFrame(RadarChart, 0, 1);
		FadeFrame(Narci_ConciseStatFrame, 0, 0);
	else
		FadeFrame(Narci_DetailedStatFrame, 0, 0);
		FadeFrame(RadarChart, 0, 0);
		FadeFrame(Narci_ConciseStatFrame, 0, 1);
	end
end

local slotIdTable = {
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

NarciItemLevelFrameMixin = {};

function NarciItemLevelFrameMixin:OnLoad()
	ItemLevelFrame = self;
end

function NarciItemLevelFrameMixin:Update(playerLevel)
	playerLevel = playerLevel or UnitLevel("player");
	local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel();
	local avgItemLevelBase = floor(avgItemLevel);
	avgItemLevel = floor(avgItemLevel * 100 + 0.5)/100;
	avgItemLevelEquipped = floor(avgItemLevelEquipped * 100 + 0.5)/100;

	self.LeftButton.Level:SetText(avgItemLevelEquipped);
	
	local r, g, b = 0.25, 0.25, 0.25;
	local colorName, qualityIndex;
	local covenantID;
	if playerLevel >= 50 then
		covenantID = C_Covenants.GetActiveCovenantID();
	end
	if covenantID and covenantID ~= 0 then
		self:UpdateRenownLevel();
		if covenantID == 1 then
			colorName = "CovenantKyrian";
			r, g, b = 0.76, 0.89, 0.94;
		elseif covenantID == 2 then
			colorName = "CovenantVenthyr";
			r, g, b = 0.55, 0, 0.19;
		elseif covenantID == 3 then
			colorName = "CovenantNightFae";
			r, g, b = 0.11, 0.42, 0.80;
		elseif covenantID == 4 then
			colorName = "CovenantNecrolord";
			r, g, b = 0, 0.63, 0.43;
		end
	else
		self:UpdateRenownLevel(0);
		if playerLevel <= 15 then
			colorName = "Grey";
			qualityIndex = 0;
		elseif playerLevel <= 30 then
			colorName = "Green";
			qualityIndex = 2;
		elseif playerLevel <= 45 then
			colorName = "Blue";
			qualityIndex = 3;
		elseif playerLevel > 45 then
			if avgItemLevel < 85 then
				colorName = "Blue";
				qualityIndex = 3;
			else
				colorName = "Purple";
				qualityIndex = 4;
			end
		elseif playerLevel > 50 then
			if avgItemLevel < 158 then
				colorName = "Green";
				qualityIndex = 2;
			elseif avgItemLevel < 183 then
				colorName = "Blue";
				qualityIndex = 3;
			else
				colorName = "Purple";
				qualityIndex = 4;
			end
		end
		r, g, b = GetItemQualityColor(qualityIndex);
	end

	local frame = self.CenterButton;
	frame.Background:SetTexture("Interface\\AddOns\\Narcissus\\ART\\Solid\\"..colorName);
	frame.Background:SetTexCoord(0, 1, 0, 1);
	frame.Fluid:SetColorTexture(r, g, b);

	local percentage = avgItemLevel - avgItemLevelBase;

	local height;		--Set the bar(Fluid) height in the Tube
	if percentage < 0.10 then
		height = 0.1;
	elseif percentage > 0.90 then
		height = 84;
	else
		height = 84 * percentage;
	end
	frame.Fluid:SetHeight(height);
	frame.Level:SetText(avgItemLevelBase);

	frame.tooltip = STAT_AVERAGE_ITEM_LEVEL .." "..avgItemLevel;
end

function NarciItemLevelFrameMixin:UpdateRenownLevel(newLevel)
	local renownLevel = newLevel or C_CovenantSanctumUI.GetRenownLevel() or 0;

	local frame = self.RightButton;
	frame.Header:SetText("RN");
	frame.tooltipHeadline = format(COVENANT_SANCTUM_LEVEL, renownLevel);
	frame.Number:SetText(renownLevel);

	if renownLevel == 0 then
		frame.tooltipLineOpen = "You will be able to join a Covenant and progress Renown level once you reach 60.";
	else
		frame.tooltipLineOpen = COVENANT_RENOWN_TUTORIAL_PROGRESS;
	end
end


NarciItemLevelCenterButtonMixin = {};

function NarciItemLevelCenterButtonMixin:OnLoad()
	self.tooltip2 = HIGHLIGHT_FONT_COLOR_CODE .. STAT_AVERAGE_ITEM_LEVEL_TOOLTIP .. FONT_COLOR_CODE_CLOSE;
	--self.tooltip3 = L["Toggle Equipment Set Manager"];

	self:SetScript("OnLoad", nil);
	self.OnLoad = nil;
end

function NarciItemLevelCenterButtonMixin:OnEnter()
	FadeFrame(self.Highlight, 0.2, 1);

	--EquipmentSetManager

	--corruption or not
	if self.isCorrupted then
		NarciAPI_RunDelayedFunction(self, 0.2, function()
			local frame = Narci_CorruptionTooltip;
			if not frame:IsVisible() and not self.isSetManagerOpen and not IsMouseButtonDown() then
				frame:ClearAllPoints();
				frame.ModelScene.Background:SetGradientAlpha("VERTICAL", 1, 1, 1, 1, 1, 1, 1, 1);
				frame:SetScale(self:GetScale());
				frame:SetParent(self);
				frame:SetPoint("TOP", self, "BOTTOM", 0, -12);
				frame:SetHitRectInsets(-32, -32, -32, -32);
				FadeFrame(frame, 0.25, 1);
			end
		end);
	else
		Narci_ShowStatTooltipDelayed(self);
	end
end

function NarciItemLevelCenterButtonMixin:OnMouseDown()
	self.Background:SetPoint("CENTER", 0, -4);
	if self.isCorrupted then
		NarciAPI_FadeFrame(Narci_CorruptionTooltip, 0.2, 0);
	end
end

function NarciItemLevelCenterButtonMixin:OnMouseUp()
	self.Background:SetPoint("CENTER", 0, 0);
end

function NarciItemLevelCenterButtonMixin:OnLeave()
	FadeFrame(self.Highlight, 0.3, 0);
	Narci:HideButtonTooltip();
end

function NarciItemLevelCenterButtonMixin:OnClick()
	Narci_NavBar:ToggleView(2);
end

function NarciItemLevelCenterButtonMixin:OnHide()
	if self.onHideFunc then
		self.onHideFunc(self);
	end
end

function NarciItemLevelCenterButtonMixin:ShowItemLevel()
	ItemLevelFrame:Update();
end




local function UpdateCharacterInfoFrame(newLevel)
	local level = newLevel or UnitLevel("player");

	local _, currentSpecName;
	local currentSpec = GetSpecialization();
	if currentSpec then
	   _, currentSpecName = GetSpecializationInfo(currentSpec);
	else
		currentSpecName = " ";
	end

	local className, englishClass = UnitClass("player");
	local _, _, _, rgbHex = GetClassColor(englishClass);
	local frame = Narci_PlayerInfoFrame;
	if currentSpecName then
		local titleID = GetCurrentTitle();
		local titleName = GetTitleName(titleID);
		if titleName then
			titleName = strtrim(titleName); --delete the space in Title
			frame.Miscellaneous:SetText(titleName.."  |  ".."|cFFFFD100"..level.."|r  ".." ".."|c"..rgbHex..currentSpecName.." "..className.."|r");
		else
			frame.Miscellaneous:SetText("Level".." |cFFFFD100"..level.."|r  ".."|c"..rgbHex..currentSpecName.." "..className.."|r");
		end
	end

	ItemLevelFrame:Update(level);
end

local function RefreshSlot(slotID)
	if slotTable[slotID] then
		After(AssignDelay(slotID), function()
			slotTable[slotID]:Refresh();
		end)
	end
end

local function RefreshAllSlot()
	for i = 1, #slotTable do
		RefreshSlot(i);
	end
end

local function PlaySlotAnimOut()
	if not InCombatLockdown() then
		for i = 1, #slotTable do
			if slotTable[i] then
				slotTable[i].animOut:Play();
			end
		end
	end
	Narci_Character.animOut:Play();
end

local function CacheSourceInfo(slotID)
	local appliedSourceID, appliedVisualID 
	if slotID then
		After(AssignDelay(slotID, true), function()
			appliedSourceID, appliedVisualID = GetSlotVisualID(slotID);
			if appliedVisualID > 0 then
				local sourceInfo = C_TransmogCollection.GetSourceInfo(appliedSourceID);
				local sources = C_TransmogCollection.GetAppearanceSources(appliedVisualID);
			
				if slotTable[slotID] then
					local slot = slotTable[slotID];
					slot.sourceInfo = sourceInfo;
					slot.appliedVisualID = appliedVisualID;
					local _, sourceID = C_TransmogCollection.GetItemInfo(sourceInfo.itemID, sourceInfo.itemModID);
					if sourceInfo and sourceInfo.sourceType == 1 then
						slot.drops = C_TransmogCollection.GetAppearanceSourceDrops(sourceID);
					end
				end
				--print("Caching Slot... #"..slotID)
			end
		end)
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


------------------------------------------------------------------
-----Some of the codes are derivated from EquipmentFlyout.lua-----
------------------------------------------------------------------
local itemTable = {}; 					-- Used for items and locations
local itemDisplayTable = {} 			-- Used for ordering items by location
local itemDisplayTable_ilvl = {}		-- *Sorted by item level
local SLOT_MAX_ITEM_LEVEL = 0;

local function SortedbyIlvl(a,b)
	return tonumber(a.Level)> tonumber(b.Level)
end

NarciEquipmentFlyoutButtonMixin = {};

function NarciEquipmentFlyoutButtonMixin:OnClick(button, down, isGamepad)
	local action = EquipmentManager_EquipItemByLocation(self.location, self.id)
	if action then
		Narci_AlertFrame_Autohide:SetAnchor(self, -24, true);
		EquipmentManager_RunAction(action)
	end
	self:Disable();
	if isGamepad then
		EquipmentFlyoutFrame.gamepadButton = self;
	end
end

function NarciEquipmentFlyoutButtonMixin:OnLeave()
	FadeFrame(self.Highlight, 0.25, 0);
	Narci:HideButtonTooltip();
	self:ResetAnimation();
end

function NarciEquipmentFlyoutButtonMixin:OnEnter(motion, isGamepad)
	FadeFrame(self.Highlight, 0.15, 1);
	Narci_Comparison_SetComparison(self.itemLocation, self);
	if isGamepad then
		self.Icon.scaleUp:Play();
		self.Border.scaleUp:Play();
		self.IconMask.scaleUp:Play();
	end
end

function NarciEquipmentFlyoutButtonMixin:OnEvent(event, msg)
	local frame = Narci_AlertFrame_Autohide;
	frame.Text:SetText(msg)
	frame:SetHeight(frame.Background:GetHeight())
	FadeFrame(frame, 0.2, 1);
	self:UnregisterErrorEvent();
end

function NarciEquipmentFlyoutButtonMixin:ResetAnimation()
	self.Icon.scaleUp:Stop();
	self.Border.scaleUp:Stop();
	self.IconMask.scaleUp:Stop();
	self.Icon:SetScale(1);
	self.Border:SetScale(1);
	self.IconMask:SetScale(1);
end

function NarciEquipmentFlyoutButtonMixin:RegisterErrorEvent()
	self:RegisterEvent("UI_ERROR_MESSAGE");
end

function NarciEquipmentFlyoutButtonMixin:UnregisterErrorEvent()
	self:UnregisterEvent("UI_ERROR_MESSAGE");
end

function Narci_FlyoutBlack_OnUpdate(self, elapsed)
	local alpha;
	local t = self.TimeSinceLastUpdate;
	local blackFrame = self:GetParent();
	local AnimDuration = 0.25;

	if self.OppoDirection then
		alpha = outSine(t, self.startAlpha, 0, AnimDuration);
	else
		alpha = outSine(t, self.startAlpha, 1, AnimDuration);
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
	local frame = EquipmentFlyoutFrame
	local perRow = 5.0;	--EQUIPMENTFLYOUT_ITEMS_PER_ROW
	local buttons = frame.buttons;
	local buttonAnchor = frame.buttonFrame;
	local numButtons = #buttons;

	local button = CreateFrame("Button", "EquipmentFlyoutFrameButton" .. numButtons + 1, buttonAnchor, "NarciEquipmentFlyoutButtonTemplate");
	button:SetFrameStrata("DIALOG");
	local pos = numButtons/perRow;
	if pos == 0 then
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
	elseif ( floor(pos) == pos ) then
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
	self:StopAnimating();

	if Narci_Character.animOut:IsPlaying() then return; end
	Narci_FlyoutBlack.AnimFrame:Hide();
	Narci_FlyoutBlack.AnimFrame:Show();
end

function Narci_EquipmentFlyoutFrame_OnEvent(self, event, ...)	--Hide Flyout if Left-Alt is released
	if ( event == "MODIFIER_STATE_CHANGED" ) then
		local key, state = ...;
		if ( key == "LALT" ) then
			local flyout = EquipmentFlyoutFrame
			if state == 0 and flyout:IsShown() then
				flyout:Hide()
			end
		end
	end
end

function Narci_EquipmentFlyout_Show(self, slotID)
	--self: Item slot
	if MOG_MODE then
		return;
	end
	
	local flyout = EquipmentFlyoutFrame;
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
	flyout.slotID = slotID;
	Narci_BuildFlyout();
	flyout:SetParent(self);
	flyout:ClearAllPoints();
	if self.isRight then
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
	flyout:SetFrameLevel(20);
	Narci:HideButtonTooltip();
	ShowLessInformation(self, true)
	
	--Reposition Comparison Tooltip if it reaches the top of the screen--
	local Tooltip = Narci_Comparison;
	Tooltip:ClearAllPoints();
	Tooltip:SetPoint("BOTTOMLEFT", EquipmentFlyoutFrame, "TOPLEFT", 8, 12);
	if self:GetTop() > Tooltip:GetBottom() then
    	Tooltip:ClearAllPoints();
    	Tooltip:SetPoint("TOPLEFT", EquipmentFlyoutFrame, "BOTTOMLEFT", 8, -12);
	end
	Narci_Comparison_SetComparison(EquipmentFlyoutFrame.BaseItem, self);
	Tooltip:Show();
end

function Narci_BuildFlyout(slotID)
	local flyout = EquipmentFlyoutFrame;
	local LoadItemData = C_Item.RequestLoadItemData;	--Cache Item Info

	flyout:Show();
	local id = slotID or flyout.slotID;
	
	--print(id)
	flyout.BaseItem = ItemLocation:CreateFromEquipmentSlot(id)
	local buttons = flyout.buttons;
	SLOT_MAX_ITEM_LEVEL = 0;
	
	wipe(itemDisplayTable);
	wipe(itemTable);
	wipe(itemDisplayTable_ilvl);
	GetInventoryItemsForSlot(id, itemTable);
	local itemLocation, itemLevel, tableOutput;
	for location, itemID in next, itemTable do
		if ( location - id == ITEM_INVENTORY_LOCATION_PLAYER ) then -- Remove the currently equipped item from the list
			itemTable[location] = nil;
		else
			local _, _, bags, _, slot, bag = EquipmentManager_UnpackLocation(location);
			if bags then
				itemLocation = ItemLocation:CreateFromBagAndSlot(bag, slot)
				itemLevel = C_Item.GetCurrentItemLevel(itemLocation)
				NarciCacheTooltip:SetHyperlink(C_Item.GetItemLink(itemLocation))
				SLOT_MAX_ITEM_LEVEL = max(SLOT_MAX_ITEM_LEVEL, itemLevel)
				LoadItemData(itemLocation)
				tableOutput = {["Level"] = itemLevel, ["itemLocation"] = itemLocation, ["location"] = location}
				tinsert(itemDisplayTable_ilvl, tableOutput);
			end 
		end
	end

	table.sort(itemDisplayTable); -- Sort by location. This ends up as: inventory, backpack, bags, bank, and bank bags.
	table.sort(itemDisplayTable_ilvl, SortedbyIlvl);
	local numTotalItems = #itemDisplayTable_ilvl;
	local buttonWidth, buttonHeight = Narci_Finger0Slot:GetWidth(), Narci_Finger0Slot:GetHeight();
	buttonWidth, buttonHeight = floor(buttonWidth + 0.5), floor(buttonHeight + 0.5);
	flyout:SetWidth(max(buttonWidth, math.min(numTotalItems, 5.0)*buttonWidth))
	--print(numTotalItems)
	local numPageItems = min(numTotalItems, 20.0);	--EQUIPMENTFLYOUT_ITEMS_PER_PAGE
	flyout:SetHeight(max(floor((numPageItems-1)/5.0 + 1)*buttonHeight, buttonHeight))
	local index = 1;
	while #buttons < numPageItems do -- Create any buttons we need.
		local button = Narci_EquipmentFlyout_CreateButton();
	end
	
	local gamepadButton = flyout.gamepadButton;
	flyout.gamepadButton = nil;

	for i = 1, #buttons do
		local button = buttons[i];
		if i <= numPageItems then
			button.itemLocation = itemDisplayTable_ilvl[i].itemLocation;
			button.location = itemDisplayTable_ilvl[i].location;
			button.id = id;
			Narci_EquipmentFlyout_DisplayButton(button);
			button:Show();
			button:SetSize(buttonWidth, buttonHeight);
			button:Enable();
			if button == gamepadButton then
				Narci_Comparison_SetComparison(gamepadButton.itemLocation, gamepadButton);
				Narci_GamepadOverlayContainer.SlotBorder:UpdateQualityColor(gamepadButton);
			end
		else
			button:Hide();
		end
	end

	flyout.numTotalItems = numTotalItems;
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
	local itemLink = C_Item.GetItemLink(location)

	if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(location) then
		itemQuality = 8;	--AzeriteEmpoweredItem
	elseif IsCorruptedItem(itemLink) then
		itemQuality = "NZoth";
	end

	if itemLevel < SLOT_MAX_ITEM_LEVEL - 29 then
		itemQuality = 0;
		button.Icon:SetDesaturated(true);
	else
		button.Icon:SetDesaturated(false);
	end
	
	button.Icon:SetTexture(itemIcon)
	button.Border:SetTexture(BorderTexture[itemQuality])
	button.IlvlCenter.ItemLevelCenter:SetText(itemLevel)
	button.IlvlCenter:Show()

	if itemLink then
		DisplayRuneSlot(button, button.id, itemQuality, itemLink);
	end
end
-----------------------------------------------------------
------------------------Color Theme------------------------
-----------------------------------------------------------
local ColorUtil = {};
ColorUtil.themeColor = NarciThemeUtil:GetColorTable();

function ColorUtil:UpdateByMapID()
	local mapID = C_Map.GetBestMapForUnit("player");
	--print("mapID:".. mapID)
	if mapID then	--and NarcissusDB.AutoColorTheme
		if mapID == self.mapID then
			self.requireUpdate = false;
		else
			self.mapID = mapID;
			self.requireUpdate = true;
			self.themeColor = NarciThemeUtil:SetColorIndex(mapID);
			RadarChart:UpdateColor();

			Narci_NavBar:SetThemeColor(self.themeColor);
		end
	else
		self.requireUpdate = false;
	end
end

function ColorUtil:SetWidgetColor(frame)
	if not self.requireUpdate then return end;

	local r, g, b = self.themeColor[1], self.themeColor[2], self.themeColor[3];
	local type = frame:GetObjectType();

	if type == "FontString" then
		local sqrt = math.sqrt;
		r, g, b = sqrt(r), sqrt(g), sqrt(b);
		frame:SetTextColor(r, g, b);
	else
		frame:SetColorTexture(r, g, b);
	end
end

---------------------------------------------
NarciRadarChartMixin = {}

function NarciRadarChartMixin:OnLoad()
	RadarChart = self;

	local circleTex = "Interface\\AddOns\\Narcissus\\Art\\Widgets\\RadarChart\\Radar-Vertice";
	local filter = "TRILINEAR";
	local tex;
	local texs = {};
	for i = 1, 4 do
		tex = self:CreateTexture(nil, "OVERLAY", nil, 2);
		tinsert(texs, tex);
		tex:SetSize(12, 12);
		tex:SetTexture(circleTex, nil, nil, filter);
	end

	self.vertices = texs;

	self:SetScript("OnLoad", nil);
	self.OnLoad = nil;
end

function NarciRadarChartMixin:OnShow()
	self.MaskedBackground:SetAlpha(0.4);
	self.MaskedBackground2:SetAlpha(0.4);
end

function NarciRadarChartMixin:OnHide()
	self:StopAnimating();
end

function NarciRadarChartMixin:SetVerticeSize(attributeFrame, size)
	local name = attributeFrame.token;
	local vertice;
	if name == "Crit" then
		vertice = self.vertices[1];
	elseif name == "Haste" then
		vertice = self.vertices[2];
	elseif name == "Mastery" then
		vertice = self.vertices[3];
	elseif name == "Versatility" then
		vertice = self.vertices[4];
	end
	vertice:SetSize(size, size);
end

function NarciRadarChartMixin:UpdateColor()
	ColorUtil:SetWidgetColor(self.MaskedBackground)
	ColorUtil:SetWidgetColor(self.MaskedBackground2)
	ColorUtil:SetWidgetColor(self.MaskedLine1)
	ColorUtil:SetWidgetColor(self.MaskedLine2)
	ColorUtil:SetWidgetColor(self.MaskedLine3)
	ColorUtil:SetWidgetColor(self.MaskedLine4)
end

local GetEffectiveCrit = Narci.GetEffectiveCrit;

function NarciRadarChartMixin:SetValue(c, h, m, v, manuallyInPutSum)
	--c, h, m, v: Input manually or use combat ratings
	local deg = math.deg;
	local rad = math.rad;
	local atan2 = math.atan2;
	local sqrt = math.sqrt;
	local Radar = self;

	local chartWidth = 96 / 2;	--In half

	local crit, haste, mastery, versatility;
	if c then
		crit = c;
	else
		local _, rating = GetEffectiveCrit();
		crit = GetCombatRating(rating) or 0;
	end
	if h then
		haste = h;
	else
		h = GetCombatRating(CR_HASTE_MELEE) or 0;
	end
	if m then
		mastery = m;
	else
		m = GetCombatRating(CR_MASTERY) or 0;
	end
	if v then
		versatility = v;
	else
		versatility = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE) or 0;
	end

	--		|	p1(x1,y1)	  Line4		p3(x3,y3)
	--		|			*				*
	--		|			 	*		*
	--		|	Line1		 	*		   Line3
	--		|			 	*		*
	--		|			*				*
	--		|	p2(x2,y2)	  Line2		p4(x4,y4)

	local v1, v2, v3, v4, v5, v6 = true, true, true, true, true, true;
	if crit == 0 and haste == 0 and mastery == 0 and versatility == 0 then
		v1, v2, v3, v4, v5, v6 = false, false, false, false, false, false;
	else
		if crit == 0 and haste == 0 then v1 = false; end;
		if haste == 0 and versatility == 0 then v2 = false; end;
		if mastery == 0 and versatility == 0 then v3 = false; end;
		if crit == 0 and mastery == 0 then v4 = false; end;
		crit, haste, mastery = crit + 0.03, haste + 0.02, mastery + 0.01;				--Avoid some mathematical issues
	end
	Radar.MaskedLine1:SetShown(v1);
	Radar.MaskedLine2:SetShown(v2);
	Radar.MaskedLine3:SetShown(v3);
	Radar.MaskedLine4:SetShown(v4);
	Radar.MaskedBackground:SetShown(v5);
	Radar.MaskedBackground2:SetShown(v6);

	--[[
		--4500 9.0 Stats Sum Level 50
		Enchancements on ilvl 445 (Mythic Eternal Palace) Player Lvl 120
		Neck 159 Weapon 25 Back 51 Wrist 28 Hands 37 Waist 36 Legs 50 Feet 37 Ring 89 Trinket 35	Max:696 + 12*7 ~= 800
		Player Lvl 60 iLvl 233(Mythic Castle Nathria):	Back 82 Leg 141 Chest 141 Neck 214 Waist 105 Hand 105 Feet 105 Wrist 79 Ring 226 Shoulder 109  Head 146 Trinket 200 ~=1900

		ilvl 240 (Mythic Antorus) Player Lvl 110
		Head 87 Shoulder 64 Chest 88 Weapon 152 Back 49 Wrist 49 Hands 64 Waist 64 Legs 87 Feet 63 Ring 165 Trinket 62	Max ~= 1100
		ilvl 149 (Mythic HFC) Player Lvl 100
		Head 48 Shoulder 36 Chest 48 Weapon 24 Back 28 Wrist 27 Hands 36 Waist 36 Legs 48 Feet 35 Ring 27 Trinket 32	Max ~= 510
		Heirlooms Player Lvl 20
		Weapon 4 Back 4 Wrist 4 Hands 6 Waist 6 Legs 8 Feet 6 Ring 5 Trinket 6	 ~= 60
	--]]

	local Sum = manuallyInPutSum or 0;
	local maxNum = max(crit + haste + mastery + versatility, 1);
	if maxNum > 0.95 * Sum then
		Sum = maxNum;
	end

	local d1, d2, d3, d4 = (crit / Sum), (haste / Sum) , (mastery / Sum) , (versatility / Sum);
	local a;
	if (d1 + d4) ~= 0 and (d2 + d3) ~= 0 then
		--a = chartWidth * math.sqrt(0.618/(d1 + d4)/(d2 + d3)/2)* 96;
		a = 1.414 * chartWidth;
	else
		a = 0;
	end

	local x1, x2, x3, x4 = -d1*a, -d2*a, d3*a, d4*a;
	local y1, y2, y3, y4 = d1*a, -d2*a, d3*a, -d4*a;
	local mx1, mx2, mx3, mx4 = (x1 + x2)/2, (x2 + x4)/2, (x3 + x4)/2, (x1 + x3)/2;
	local my1, my2, my3, my4 = (y1 + y2)/2, (y2 + y4)/2, (y3 + y4)/2, (y1 + y3)/2;

	local ma1 = atan2((y1 - y2), (x1 - x2));
	local ma2 = atan2((y2 - y4), (x2 - x4));
	local ma3 = atan2((y4 - y3), (x4 - x3));
	local ma4 = atan2((y3 - y1), (x3 - x1));

	if my1 == 0 then
		my1 = 0.01;
	end
	if my3 == 0 then
		my1 = -0.01;
	end
	if deg(ma1) == 90 then
		ma1 = rad(89);
	end
	if deg(ma3) == -90 then
		ma1 = rad(-89);
	end

	Radar.vertices[1]:SetPoint("CENTER", x1, y1);
	Radar.vertices[2]:SetPoint("CENTER", x2, y2);
	Radar.vertices[3]:SetPoint("CENTER", x3, y3);
	Radar.vertices[4]:SetPoint("CENTER", x4, y4);

	Radar.Mask1:SetRotation(ma1);
	Radar.Mask2:SetRotation(ma2);
	Radar.Mask3:SetRotation(ma3);
	Radar.Mask4:SetRotation(ma4);
		
	local hypo1 = sqrt(2*x1^2 + 2*x2^2);
	local hypo2 = sqrt(2*x2^2 + 2*x4^2);
	local hypo3 = sqrt(2*x4^2 + 2*x3^2);
	local hypo4 = sqrt(2*x3^2 + 2*x1^2);

	if (hypo1 - 4) > 0 then
		Radar.MaskLine1:SetWidth(hypo1 - 4);	--Line length
	else
		Radar.MaskLine1:SetWidth(0.1);
	end

	if (hypo2 - 4) > 0 then
		Radar.MaskLine2:SetWidth(hypo2 - 4);
	else
		Radar.MaskLine2:SetWidth(0.1);
	end

	if (hypo3 - 4) > 0 then
		Radar.MaskLine3:SetWidth(hypo3 - 4);
	else
		Radar.MaskLine3:SetWidth(0.1);
	end

	if (hypo4 - 4) > 0 then
		Radar.MaskLine4:SetWidth(hypo4 - 4);
	else
		Radar.MaskLine4:SetWidth(0.1);
	end

	Radar.MaskLine1:ClearAllPoints();
	Radar.MaskLine1:SetRotation(0);
	Radar.MaskLine1:SetRotation(ma1);
	Radar.MaskLine1:SetPoint("CENTER", Radar, "CENTER", mx1, my1);
	Radar.MaskLine2:ClearAllPoints();
	Radar.MaskLine2:SetRotation(0);
	Radar.MaskLine2:SetRotation(ma2);
	Radar.MaskLine2:SetPoint("CENTER", Radar, "CENTER", mx2, my2);
	Radar.MaskLine3:ClearAllPoints();
	Radar.MaskLine3:SetRotation(0);
	Radar.MaskLine3:SetRotation(ma3);
	Radar.MaskLine3:SetPoint("CENTER", Radar, "CENTER", mx3, my3);
	Radar.MaskLine4:ClearAllPoints();
	Radar.MaskLine4:SetRotation(0);
	Radar.MaskLine4:SetRotation(ma4);
	Radar.MaskLine4:SetPoint("CENTER", Radar, "CENTER", mx4, my4);
	Radar.Mask1:SetPoint("CENTER", mx1, my1);
	Radar.Mask2:SetPoint("CENTER", mx2, my2);
	Radar.Mask3:SetPoint("CENTER", mx3, my3);
	Radar.Mask4:SetPoint("CENTER", mx4, my4);

	Radar.MaskedBackground:SetAlpha(0.4);
	Radar.MaskedBackground2:SetAlpha(0.4);

	Radar.n1, Radar.n2, Radar.n3, Radar.n4 = crit, haste, mastery, versatility;
end

function NarciRadarChartMixin:AnimateValue(c, h, m, v)
	--Update the radar chart using animation
	local Radar = self;
	local UpdateFrame = Radar.UpdateFrame;
	if not UpdateFrame then
		UpdateFrame = CreateFrame("Frame", nil, Radar, "NarciUpdateFrameTemplate");
		Radar.UpdateFrame = UpdateFrame;
		Radar.n1, Radar.n2, Radar.n3, Radar.n4 = 0, 0, 0, 0;
	end

	local s1, s2, s3, s4 = Radar.n1, Radar.n2, Radar.n3, Radar.n4;	--start/end point
	local critChance, critRating = GetEffectiveCrit();
	local e1 = c or GetCombatRating(critRating) or 0;
	local e2 = h or GetCombatRating(CR_HASTE_MELEE) or 0;
	local e3 = m or GetCombatRating(CR_MASTERY) or 0;
	local e4 = v or GetCombatRating(CR_VERSATILITY_DAMAGE_DONE) or 0;

	local duration = 0.2;

	local playerLevel = UnitLevel("player");
	local sum;
	if playerLevel == 50 then
		sum = max(e1 + e2 + e3 + e4 , 800);		--Status Sum for 8.3 Raid
	elseif playerLevel == 60 then
		sum = max(e1 + e2 + e3 + e4 , 1880);	--Status Sum for 9.0 Raid
	else
		--sum = 31 * math.exp( 0.04 * UnitLevel("player")) + 40;
		sum = (e1 + e2 + e3 + e4) * 1.5;
	end

	local function UpdateFunc(frame, elapsed)
		local t = frame.t;
		frame.t = t + elapsed;
		local v1 = outSine(t, s1, e1, duration);
		local v2 = outSine(t, s2, e2, duration);
		local v3 = outSine(t, s3, e3, duration);
		local v4 = outSine(t, s4, e4, duration);
		
		if t >= duration then
			v1, v2, v3, v4 = e1, e2, e3, e4;
			frame:Hide();
		end
		Radar:SetValue(v1, v2, v3, v4, sum);
	end

	UpdateFrame:Hide();
	UpdateFrame:SetScript("OnUpdate", UpdateFunc);
	UpdateFrame:Show();

	if self.Primary:IsShown() then
		self.Primary:Update();
		self.Health:Update();
	end
end

function NarciRadarChartMixin:TogglePrimaryStats(state)
	state = false;
	
	if state then
		self.Primary.Color:SetColorTexture(0.24, 0.24, 0.24, 0.75);
		self.Health.Color:SetColorTexture(0.15, 0.15, 0.15, 0.75);
		FadeFrame(self.Primary, 0.15, 1);
		FadeFrame(self.Health, 0.15, 1);
		self.Primary:Update();
		self.Health:Update();
	else
		FadeFrame(self.Primary, 0.25, 0);
		FadeFrame(self.Health, 0.25, 0);
	end
end

function Narci_AttributeFrame_UpdateBackgroundColor(self)
	local frameID = self:GetID() or 0;
	local themeColor = ColorUtil.themeColor;
	local r, g, b = themeColor[1], themeColor[2], themeColor[3];
	if frameID % 2 == 0 then
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

function Narci_AttributeFrame_OnLoad(self)
	Narci_AttributeFrame_UpdateBackgroundColor(self);
end

function XmogList_OnLoad(self)
	Narci_AttributeFrame_UpdateBackgroundColor(self);
end

local function RefreshStats(id, frame)
	local frame = frame or "Detailed";

	if frame == "Detailed" then
		if statTable[id] then
			statTable[id]:Update();
		end
	elseif frame == "Concise" then
		if statTable_Short[id] then
			statTable_Short[id]:Update();
		end
	end
end

local StatsUpdator = CreateFrame("Frame");
StatsUpdator:Hide();
StatsUpdator.t = 0;
StatsUpdator.index = 1;
StatsUpdator:SetScript("OnUpdate", function(self, elpased)
	self.t = self.t + elpased;
	if self.t > 0.05 then
		self.t = 0;
		local i = self.index;
		if statTable[i] then
			statTable[i]:Update();
		end
		if statTable_Short[i] then
			statTable_Short[i]:Update();
		end
		if i >= 20 then
			self:Hide();
			self.index = 1;
		else
			self.index = i + 1;
		end
	end
end);

function StatsUpdator:Gradual()
	ItemLevelFrame:Update();
	self.index = 1;
	self.t = 0;
	self:Show();
end

function StatsUpdator:Instant()
	if not StatsUpdator.pauseUpdate then
		StatsUpdator.pauseUpdate = true;
		After(0, function()
			for i = 1, 20 do
				RefreshStats(i);
			end
			for i = 1, 12 do
				RefreshStats(i, "Concise");
			end
			StatsUpdator.pauseUpdate = nil;
		end);
	end
end

function StatsUpdator:UpdateCooldown()
	local slot;
	for i = 1, #slotTable do
		slot = slotTable[i];
		if slot then
			slot:TrackCooldown();
		end
	end
end

Narci.RefreshAllSlot = RefreshAllSlot;
Narci.RefreshAllStats = StatsUpdator.Instant;

local function PlayAttributeAnimation()
	if not NarcissusDB.DetailedIlvlInfo then
		RadarChart:AnimateValue();
		return
	end
	local anim;
	for i = 1, 20 do
		anim = statTable[i].animIn;
		if anim then
			anim.A2:SetToAlpha(statTable[i]:GetAlpha());
			anim:Play();
		end
	end
	RadarChart.animIn:Play();
end

local function ShowAttributeButton(bool)
	if NarcissusDB.DetailedIlvlInfo then
		Narci_DetailedStatFrame:SetShown(true);
		Narci_ConciseStatFrame:SetShown(false);
		RadarChart:SetShown(true);
	else
		Narci_DetailedStatFrame:SetShown(false);
		Narci_ConciseStatFrame:SetShown(true);
		RadarChart:SetShown(false);
	end

	ItemLevelFrame:SetShown(true);
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
	slotTable[18] = slotFrame.NeckSlot;		--=RangedSlot; --abandoned
	slotTable[19] = slotFrame.TabardSlot;

	Narci.slotTable = slotTable;

	local statFrame = Narci_DetailedStatFrame;
	local radar = RadarChart;
	statTable[1] = statFrame.Primary;
	statTable[2] = statFrame.Stamina;
	statTable[3] = statFrame.Damage;
	statTable[4] = statFrame.AttackSpeed;
	statTable[5] = statFrame.Power;
	statTable[6] = statFrame.Regen;
	statTable[7] = statFrame.Health;
	statTable[8] = statFrame.Armor;
	statTable[9] = statFrame.Reduction;
	statTable[10]= statFrame.Dodge;
	statTable[11]= statFrame.Parry;
	statTable[12]= statFrame.Block;
	statTable[13]= radar.Crit;
	statTable[14]= radar.Haste;
	statTable[15]= radar.Mastery;
	statTable[16]= radar.Versatility;
	statTable[17]= statFrame.Leech;
	statTable[18]= statFrame.Avoidance;
	statTable[19]= statFrame.MovementSpeed;
	statTable[20]= statFrame.Speed;

	local statFrame_Short = Narci_ConciseStatFrame;
	statTable_Short[1]  = statFrame_Short.Primary;
	statTable_Short[2]  = statFrame_Short.Stamina;
	statTable_Short[3]  = statFrame_Short.Health;
	statTable_Short[4]  = statFrame_Short.Power;
	statTable_Short[5]  = statFrame_Short.Regen;
	statTable_Short[6]  = statFrame_Short.Crit;
	statTable_Short[7]  = statFrame_Short.Haste;
	statTable_Short[8]  = statFrame_Short.Mastery;
	statTable_Short[9]  = statFrame_Short.Versatility;
	statTable_Short[10] = statFrame_Short.Leech;
	statTable_Short[11] = statFrame_Short.Avoidance;
	statTable_Short[12] = statFrame_Short.Speed;
end

function Narci_SetPlayerName(self)
	local playerName = UnitName("player");
	self.PlayerName:SetShadowColor(0, 0, 0);
	self.PlayerName:SetShadowOffset(2, -2);
	self.PlayerName:SetText(playerName);
	SmartFontType(self.PlayerName);
end

function Narci_AliasButton_SetState()
	local editBox = Narci_PlayerInfoFrame.PlayerName;
	local button = Narci_AliasButton;

	if NarcissusDB_PC.UseAlias then
		editBox:Enable();
		editBox:SetText((NarcissusDB_PC.PlayerAlias or UnitName("player")));
		button.Label:SetText(L["Use Player Name"]);
	else
		editBox:Disable();
		editBox:SetText(UnitName("player"));
		button.Label:SetText(L["Use Alias"]);
	end

	local LetterNum = editBox:GetNumLetters();
	local w = max(LetterNum*16, 160);
	editBox:SetWidth(w);

	button:SetWidth(button.Label:GetWidth() + 12);
end

function Narci_AliasButton_OnClick(self)
	local editBox = Narci_PlayerInfoFrame.PlayerName;
	NarcissusDB_PC.UseAlias = not NarcissusDB_PC.UseAlias;

	if NarcissusDB_PC.UseAlias then
		self.Label:SetText(L["Use Player Name"]);
		editBox:Enable();
		editBox:SetFocus();
		editBox:SetText(NarcissusDB_PC.PlayerAlias or UnitName("player"));
		editBox:HighlightText();
	else
		self.Label:SetText(L["Use Alias"]);
		local text = strtrim(editBox:GetText());
		editBox:SetText(text);
		NarcissusDB_PC.PlayerAlias = text;
		editBox:Disable();
		editBox:HighlightText(0,0)
		editBox:SetText(UnitName("player"));
	end
	self:SetWidth(self.Label:GetWidth() + 12);
	local LetterNum = editBox:GetNumLetters();
	local w = max(LetterNum*16, 160);
	editBox:SetWidth(w);
end


--Music Fade In/Out
local MusicIO = CreateFrame("Frame", "Narci_MusicInOut");
MusicIO.t = 0;
MusicIO:Hide()

local function MusicIO_Update(self, elapsed)
	self.t = self.t + elapsed
	local volume;
	if self.state then
		volume = max((self.t/2), CVarTemp.MusicVolume)
	else
		volume = max((self.fromVolume - self.t/2), CVarTemp.MusicVolume)
	end
	SetCVar("Sound_MusicVolume",volume)

	if (self.state and volume >= 1) or ((not self.state) and volume <= tonumber(CVarTemp.MusicVolume)) then
		self:Hide()
		self.t = 0;
	end
end

MusicIO:SetScript("OnShow", function(self)
	self.fromVolume = GetCVar("Sound_MusicVolume") or 1;
end)
MusicIO:SetScript("OnUpdate", MusicIO_Update)
MusicIO:SetScript("OnHide", function(self)
	self.t = 0;
end)

function MusicIO:In()
	if not NarcissusDB.FadeMusic then
		return;
	end
	self:Hide();
	self.state = true;
	self:Show();
end

function MusicIO:Out()
	self:Hide();
	self.state = false;
	self:Show();
end

function Narci_Open()
	if not IS_OPENED then
		if InCombatLockdown() then
			--[[
			--Can't open the default character pane either
			ShowUIPanel(CharacterFrame);
			local subFrame = _G["PaperDollFrame"];
			if not subFrame:IsShown() then
				ToggleCharacter("PaperDollFrame");
			end
			--]]
			return;
		end
		IS_OPENED = true;
		CVarTemp:BackUp();
		ViewProfile:SaveView(5);
		ModifyCameraForShapeshifter();
		xmogMode = 0;
		MogModeOffset = 0;
		NarciPlayerModelFrame1.xmogMode = 0;
		local speedFactor = 180/(GetCVar("cameraYawMoveSpeed") or 180);
		ZoomFactor.EndSpeed = speedFactor * ZoomFactor.EndSpeedBasic;
		ZoomFactor.StartSpeed = speedFactor * ZoomFactor.StartSpeedBasic;
		Narci_FlyoutBlack:SetAlpha(0);
		MusicIO:In();
		EL:Show();

		Toolbar:Show();
		Narci_XmogButton:Enable();

		DefaultTooltip:SetScale(UIParent:GetEffectiveScale() or 1);

		After(0, function()
			CameraMover:Enter();
			RadarChart:SetValue(0,0,0,0,1);
			Narci_LetterboxAnimation();
			local Vignette = Narci_Vignette;
			Vignette.VignetteLeft:SetAlpha(VIGNETTE_ALPHA);
			Vignette.VignetteRight:SetAlpha(VIGNETTE_ALPHA);
			Vignette.VignetteRightSmall:SetAlpha(0);
			FadeFrame(Vignette, 0.5, 1);
			Vignette.VignetteRight.animIn:Play();
			Vignette.VignetteLeft.animIn:Play();
			After(0, function()
				StatsUpdator:Gradual();
			end);
		end);
		
		Narci.refreshCombatRatings = true;
		Narci.isActive = true;
	else
		if Narci.showExitConfirm and not InCombatLockdown() then
			local ExitConfirm = Narci_ExitConfirmationDialog;
			if not ExitConfirm:IsShown() then
				FadeFrame(ExitConfirm, 0.25, 1);

				--"Nullify" ShowUI
				UIParent:SetAlpha(0);
				Minimap:Hide();
				After(0, function()
					SetUIVisibility(false);
					MiniButton:Enable();
					UIParent:SetAlpha(1);
					Minimap:Show()
				end);

				return;
			else
				FadeFrame(ExitConfirm, 0.15, 0);
			end
		end
		PlaySlotAnimOut();
		ExitFunc();
		MusicIO:Out();
		Narci_LetterboxAnimation("OUT");
		if Narci_TitleManager_Switch.IsOn then
			Narci_TitleManager_Switch:Click();
		end
		EquipmentFlyoutFrame:Hide();
		Narci_TitleManager_TitleTooltip:Hide();		--TitleManager
		Narci_ModelSettings:Hide();

		local frame = Toolbar;
		frame.PhotoModeControllerAnimFrame.OppoDirection = true;
		frame.PhotoModeControllerAnimFrame:Hide();
		frame.PhotoModeControllerAnimFrame.EndPointY = "-80"
		frame.PhotoModeControllerAnimFrame.toAlpha = 0;
		frame.PhotoModeControllerAnimFrame:Show();
		TakeOutFromUIParent(AzeriteEmpoweredItemUI, "MEDIUM", false);
		TakeOutFromUIParent(AzeriteEssenceUI, "MEDIUM", false);
		TakeOutFromUIParent(ArtifactFrame, "MEDIUM", false);
		TakeOutFromUIParent(ItemSocketingFrame, "MEDIUM", false);

		Narci.showExitConfirm = false;
	end
end

function Narci_OpenGroupPhoto()
	if not IS_OPENED then
		if InCombatLockdown() then
			return;
		end
		IS_OPENED = true;
		CVarTemp:BackUp();
		ViewProfile:SaveView(5);
		ModifyCameraForShapeshifter();
		SetCVar("test_cameraDynamicPitch", 1)

		local xmogMode_Temp = NarcissusDB.DefaultLayout;
		NarcissusDB.DefaultLayout = 2;

		Narci_XmogButton:Enable();
		Narci_XmogButton:Click();

		After(0.4, function()
			NarcissusDB.DefaultLayout = xmogMode_Temp;
		end)
		
		local speedFactor = 180/(GetCVar("cameraYawMoveSpeed") or 180);
		ZoomFactor.EndSpeed = speedFactor*ZoomFactor.EndSpeedBasic;
		ZoomFactor.StartSpeed = speedFactor*ZoomFactor.StartSpeedBasic;
		Narci_FlyoutBlack:SetAlpha(0);
		EL:Show();
		
		CameraMover:Pitch();

		DefaultTooltip:SetScale(UIParent:GetEffectiveScale() or 1);

		After(0, function()
			RefreshAllSlot();
			local Vignette = Narci_Vignette;
			Vignette.VignetteLeft:SetAlpha(VIGNETTE_ALPHA);
			Vignette.VignetteRight:SetAlpha(VIGNETTE_ALPHA);
			Vignette.VignetteRightSmall:SetAlpha(0);
			FadeFrame(Vignette, 0.8, 1);
			Vignette.VignetteRight.animIn:Play();
			Vignette.VignetteLeft.animIn:Play();

			if UIParent:IsShown() then
				UIPA.endAlpha = 0;
				UIPA:Show();
			end

			After(0, function()
				if not Narci_PhotoModeButton.IsOn then
					Narci_PhotoModeButton:Click();
				end
				Toolbar:Show();

				After(0.5, function()
					SetUIVisibility(false); 		--Same as pressing Alt + Z

					After(0.3, function()
						UIParent:SetAlpha(1);
					end)
				end)
			end)
		end)
		
		Narci.isActive = true;
	end
end



---Widgets---

function CameraControllerThumb_OnLoad(self)
	self:RegisterForClicks("RightButtonUp");
	self:RegisterForDrag("LeftButton");
	self.Reading:SetText(string.format("%.2f", 0));
end

local function CameraControlBarThumb_Reposition(self, ofsx)
	self:GetParent().Thumb:SetPoint("CENTER", ofsx, 0);
	CameraOffsetControlBar.PosX = ofsx;
	SetCVar("test_cameraOverShoulder", 0 - ofsx/20)	--Ajust the Zoom - Shoulder factor
	local currentShoulder = GetCVar("test_cameraOverShoulder");
	local Zoom = GetCameraZoom();
end

function CameraControlBar_DraggingFrame_OnUpdate(self)
	local scale = self:GetParent():GetEffectiveScale();
	local xpos = GetCursorPosition() / scale;
	local xmin, xmax = self:GetParent():GetLeft() + 18 , self:GetParent():GetRight() - 18;

	CameraOffsetControlBar.Range = xmax - xmin;

	local xcenter = self:GetParent():GetCenter();
	local ofsx;
	if xpos < xmin then
		ofsx = xmin - xcenter;
	elseif xpos > xmax then
		ofsx = xmax - xcenter;
	else
		ofsx = xpos - xcenter;
	end

	CameraControlBarThumb_Reposition(self, ofsx);
end

function CameraControlBarThumb_OnClick(self, button, down)
	--self:GetParent().Thumb:SetPoint("CENTER", 0, 0);
	self:Disable()
	CameraControlBar_ResetPosition_AnimFrame.OppoDirection = true
	CameraControlBar_ResetPosition_AnimFrame:Show();
	After(0.6, function()
		self:Enable();
		CameraOffsetControlBar.PosX = 0;
		CameraOffsetControlBar.PosRadian = 0;
	end)
	local Zoom = GetCameraZoom()
	SmoothShoulderCVar(Shoulder_Factor1*Zoom + Shoulder_Factor2)
	self:GetParent().Thumb.Reading:SetText(string.format(0))
end

local shaftDiameter = 53;
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
	local ofsx = shaftDiameter*math.cos(radian)
	local ofsy = shaftDiameter*math.sin(radian)
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
function Narci_KeyListener_OnEscapePressed()
	if IS_OPENED then
		MiniButton:Click();
	end
end

function Narci_ExitButton_OnClick(self)
	if IS_OPENED then
		Narci_Open();
		SetUIVisibility(true);
	end
end

local function TokenButton_ClearMarker(self)
	local parent = self:GetParent();
	if parent.buttons then
		for i = 1, #parent.buttons do
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
	["shadowrt"] = -1,		--invalid
}

---Hide Names and Bubbles---
--local PhotoMode_Cvar_TrackingList = 1		--Track Battle Pet
local PhotoMode_Cvar_TrackingBAK = true;
local PhotoMode_Cvar_NamesBackup = {};
local PhotoMode_Cvar_NamesList = {			--Unit Name CVars
	["UnitNameOwn"] = 0,
	["UnitNameNonCombatCreatureName"] = 0,
	["UnitNameFriendlyPlayerName"] = 0,
	["UnitNameFriendlyPetName"] = 0,
	["UnitNameFriendlyMinionName"] = 0,
	["UnitNameFriendlyGuardianName"] = 0,
	["UnitNameFriendlySpecialNPCName"] = 0,
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
    -- [ Name ] = { HeadLine, Line, Special, Guide Pic Index } 
	["Narci_PhotoModeButton"] = {
		L["Photo Mode"],
		L["Photo Mode Tooltip Open"],
		L["Photo Mode Tooltip Special"],
	},

	["Narci_XmogButton"] = {
		L["Xmog Button"],
		L["Xmog Button Tooltip Open"],
		L["Xmog Button Tooltip Special"],
	},

	["Narci_EmoteButton"] = {
		L["Emote Button"],
		L["Emote Button Tooltip Open"],
		L["Emote Button Tooltip Special"],
	},

	["Narci_HideTextsButton"] = {
		L["HideTexts Button"],
		L["HideTexts Button Tooltip Open"],
		L["HideTexts Button Tooltip Special"],
		1,
	},

	["Narci_TopQualityButton"] = {
		L["TopQuality Button"],
		L["TopQuality Button Tooltip Open"],
		L["HideTexts Button Tooltip Special"],
		2,
	},
}

function Narci_PhotoModeButton_OnLoad(self)
	self.IsOn = false;
	local name = self:GetName();

	if ControllerButtonTooltip[name] then
		if ControllerButtonTooltip[name][3] then	--special notes
			self.tooltip = {ControllerButtonTooltip[name][1], ControllerButtonTooltip[name][2] .. "\n|cff6b6b6b".. ControllerButtonTooltip[name][3]};	--42% Grey
		else
			self.tooltip = {ControllerButtonTooltip[name][1], ControllerButtonTooltip[name][2]};
		end

		if ControllerButtonTooltip[name][4] then
			self.guideIndex = ControllerButtonTooltip[name][4];
		end

		wipe(ControllerButtonTooltip[name]);
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


function NarciXmogButtonPopUp_OnShow(self)
	ColorUtil:SetWidgetColor(self.Color);
	ColorUtil:SetWidgetColor(self.Option);
end

function XmogButtonPopUp_OnLoad(self)
	self.CopyButton.Label:SetText(L["Copy Texts"]);
	self.ModeButton.Background:SetColorTexture(0.06, 0.06, 0.06, 0.8);
	self.ModeButton.Label:SetText(L["Layout"]);
	self.ModeButton.Option:SetText(L["Symmetry"]);
	self.ModelToggle.Label:SetText(L["3D Model"]);
	ColorUtil:SetWidgetColor(self.ModeButton.Option);

	local SyntaxButton = self.CopyButton.GearTexts;
	SyntaxButton.PlainText.Background:SetColorTexture(0.06, 0.06, 0.06, 0.8);
	SyntaxButton.BBSCode.Background:SetColorTexture(0.06, 0.06, 0.06, 0.8);
	SyntaxButton.Markdown.Background:SetColorTexture(0.06, 0.06, 0.06, 0.8);
	SyntaxButton.PlainText.Label:SetText(L["Plain Text"]);
	SyntaxButton.BBSCode.Label:SetText(L["BB Code"]);
	SyntaxButton.Markdown.Label:SetText(L["Markdown"]);

end

local function HidePlayerModel()
	if (not Narci_ModelContainer:IsVisible()) or (NarcissusDB.AlwaysShowModel) then	return; end
	Narci_PlayerModelAnimOut:Show()
	After(0.4, function()
		FadeFrame(NarciPlayerModelFrame1, 0.5 , 0)
	end)
end

local function UseXmogLayout(index)
	if index == 1 then
		xmogMode = 1;
		NarciPlayerModelFrame1.xmogMode = 1;
		Narci_XmogButtonPopUp_ModeButton.Option:SetText(L["Asymmetry"]);
		CameraMover:Pitch();
		HidePlayerModel();
		SmoothShoulder.EndPoint = 0.01;
		SmoothShoulder:Show();
		Narci_GuideLineFrame.VirtualLineRight.AnimFrame.EndPoint = -80;
		Narci_GuideLineFrame.VirtualLineRight.AnimFrame:Show();
		SmoothShoulderCVar(0.01);
		Narci_XmogButtonPopUp_ModeButton.ShowModel = false;

		if NarcissusDB.AlwaysShowModel then
			NarciModel_RightGradient:Hide();
			Narci_PlayerModelGuideFrame.VignetteRightSmall:Hide();
			if not NarciPlayerModelFrame1:IsVisible() then
				Narci_PlayerModelAnimIn:Show();
			end
		end
	elseif index == 2 then
		xmogMode = 2;
		MogModeOffset = 0.2;
		NarciPlayerModelFrame1.xmogMode = 2;
		if Narci_Character:IsVisible() then
			FadeFrame(NarciModel_RightGradient, 0.5, 1);
		end
		Narci_XmogButtonPopUp_ModeButton.Option:SetText(L["Symmetry"]);
		if not NarciPlayerModelFrame1:IsVisible() then
			Narci_PlayerModelAnimIn:Show();
		end
		Narci_PlayerModelGuideFrame.VignetteRightSmall:Show();
		Narci_GuideLineFrame.VirtualLineRight.AnimFrame.EndPoint = -600;
		Narci_GuideLineFrame.VirtualLineRight.AnimFrame:Show();
		Narci_XmogButtonPopUp_ModeButton.ShowModel = true;
		After(0, function()
			if not IsMounted() then
				CameraMover:Pitch();
				CameraMover:ZoomIn(ZoomInValue_XmogMode);	--ajust by raceID
			else
				CameraMover:ZoomIn(8);	--ajust by raceID
			end
		end)
	end
end

local function PlayCheckSound(self, state)
	if not self.enableSFX then return;
	elseif state then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
end

local function ActiveXmogMode()
	Narci_GuideLineFrame.VirtualLineRight.AnimFrame:Hide();

	if MOG_MODE then
		FadeFrame(Narci_Attribute, 0.5, 0)
		FadeFrame(Narci_XmogNameFrame, 0.2, 1, 0)
		local DefaultLayout = NarcissusDB.DefaultLayout;
		if DefaultLayout == 1 then
			xmogMode = 1;
		elseif DefaultLayout == 2 then
			xmogMode = 2;
			MogModeOffset = 0.2;
		elseif DefaultLayout == 3 then
			xmogMode = 2;
			MogModeOffset = 0.2;
		end

		UseXmogLayout(xmogMode);
		NarciPlayerModelFrame1.xmogMode = xmogMode;
	else
		Narci_GuideLineFrame.VirtualLineRight.AnimFrame.EndPoint = Narci_GuideLineFrame.VirtualLineRight.AnimFrame.EndPointBAK
		if Toolbar:IsShown() then
			Narci_GuideLineFrame.VirtualLineRight.AnimFrame:Show()
			FadeFrame(Narci_Attribute, 0.5, 1)
			local Zoom = GetCameraZoom()
			SmoothShoulderCVar(Shoulder_Factor1*Zoom + Shoulder_Factor2)
		end
		FadeFrame(Narci_XmogNameFrame, 0.2, 0)
		ShowAttributeButton();
		xmogMode = 0;
		MogModeOffset = 0;
		NarciPlayerModelFrame1.xmogMode = 0;
	end
end

function Narci_XmogButton_OnClick(self)
	self.IsOn = not self.IsOn
	MoveViewRightStop();
	EquipmentFlyoutFrame:Hide();
	MOG_MODE = not MOG_MODE;
	local PopUp = Narci_XmogButtonPopUp;
	if not self.IsOn then
		--Exit Xmog mode
		FadeFrame(Narci_VignetteRightSmall, 0.5, 0);
		FadeFrame(Narci_VignetteRightLarge, 0.5, NarcissusDB.VignetteStrength);
		Narci_SnowEffect(true);
		Narci_LetterboxAnimation();
		PlayCheckSound(self, false)
		self.Icon:SetTexCoord(0, 0.5, 0, 1);
		if NarcissusDB.EnableGrainEffect then
			FadeFrame(Narci_Vignette.Grain, 0.5, 1);
			FadeFrame(Narci_Vignette.Grain2, 0.5, 1);
		end
		PopUp.AnimFrame:Hide();
		PopUp.AnimFrame.OppoDirection = true
		PopUp.AnimFrame:Show();
		PopUp.AnimFrame.EndPointY = -20;
		if Narci_ModelContainer:IsVisible() then
			if IS_OPENED then
				CameraMover:Pitch();
			else
				SmoothShoulderCVar(0)
			end
			Narci_PlayerModelAnimOut:Show()
			After(0.4, function()
				FadeFrame(NarciPlayerModelFrame1, 0.5 , 0)
			end)
		end
		Narci_ModelSettings:Hide();
		self.tooltip = {L["Xmog Button"], L["Xmog Button Tooltip Open"] .. "\n|cff6b6b6b"..L["Xmog Button Tooltip Special"]};

		if not Narci_ExitConfirmationDialog:IsShown() then
			Narci.showExitConfirm = false;
		end
	else
		FadeFrame(Narci_VignetteRightSmall, 0.5, NarcissusDB.VignetteStrength);
		FadeFrame(Narci_VignetteRightLarge, 0.5, 0);
		FadeFrame(Narci_Vignette.Grain, 0.5, 0);
		FadeFrame(Narci_Vignette.Grain2, 0.5, 0);
		Narci_SnowEffect(false);
		Narci_LetterboxAnimation("OUT");
		PlayCheckSound(self, true)
		self.Icon:SetTexCoord(0.5, 1, 0, 1);
		PopUp:Show();
		PopUp.AnimFrame:Hide();
		PopUp.AnimFrame.OppoDirection = false		
		PopUp.AnimFrame:Show();
		PopUp.AnimFrame.EndPointY = 8;
		Narci_XmogNameFrame.PlayerName:SetText(Narci_PlayerInfoFrame.PlayerName:GetText())
		self.tooltip = {L["Xmog Button"], L["Xmog Button Tooltip Close"]};
	end
	
	RefreshAllSlot();
	After(0.1, function()
		ActiveXmogMode();
	end)

	NarciTooltip:FadeOut();

	TemporarilyHidePopUp(Narci_EmoteButtonPopUp)
end

local function UpdateXmogName(SpecOnly)
	local frame = Narci_XmogNameFrame;

	local currentSpec = GetSpecialization();
	if not currentSpec then
	   return;
	end

	local ArmorType;
	local Token = 159243;

	if not SpecOnly then
		Narci_SetPlayerName(frame);
		if IsSpellKnown(76273) or IsSpellKnown(106904) or IsSpellKnown(202782) or IsSpellKnown(76275) then
			--ArmorType = "Leather"
			Token = 159300;
		elseif IsSpellKnown(76250) or IsSpellKnown(76272) then
			--ArmorType = "Mail"
			Token = 159371;
		elseif IsSpellKnown(76276) or IsSpellKnown(76277) or IsSpellKnown(76279) then
			--ArmorType = "Cloth"
			Token = 159243;
		elseif IsSpellKnown(76271) or IsSpellKnown(76282) or IsSpellKnown(76268) then
			--ArmorType = "Plate"
			Token = 159418;
		end
		local _;
		_, _, ArmorType = GetItemInfoInstant(Token);
		frame.armorType = ArmorType;
	end
	--Leather 76273		Mail 76250		Cloth 76276	76279	Plate 76271 76282

	ArmorType = frame.armorType or ArmorType or "ArmorType";

	local _, currentSpecName = GetSpecializationInfo(currentSpec);
	currentSpecName = currentSpecName or " ";

	local className, englishClass, _ = UnitClass("player");
	local _, _, _, rgbHex = GetClassColor(englishClass);
	frame.ArmorString:SetText("|cFFFFD100"..ArmorType.."|r".."  |  ".."|c"..rgbHex..currentSpecName.." "..className.."|r");
end

local function GetWowHeadDressingRoomURL()
	local slot;
	local ItemList = {};
	for i = 1, #xmogTable do
		slot = xmogTable[i][1];
		if slotTable[slot] and slotTable[slot].itemID then
			ItemList[slot] = {slotTable[slot].itemID, slotTable[slot].bonusID};
		end
	end
	return NarciAPI.EncodeItemlist(ItemList);
end

local function CopyTexts(type, subType)
	local texts = Narci_XmogNameFrame.PlayerName:GetText() or "My Transmog";
	local type = type or "TEXT";
	local subType = subType or "Wowhead";
	local showItemID = Narci_XmogButtonPopUp.CopyButton.showItemID or false;
	local source;
	if type == "TEXT" then
		texts = texts.."\n"
		for i = 1, #xmogTable do
			local index =  xmogTable[i][1]
			if slotTable[index] and slotTable[index].Name:GetText() then
				local text = "|cFFFFD100"..xmogTable[i][2]..":|r "..(slotTable[index].Name:GetText() or " ");

				if showItemID and slotTable[index].itemID then
					text = text.." |cFFacacac"..slotTable[index].itemID.."|r";
				end
				
				source = slotTable[index].ItemLevel:GetText();
				if source and source ~= " " then
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
					texts = texts.."\n"..text.."|cFF959595[/tr]|r"
				end
			end
		end
		texts = texts.."\n|cFF959595[/table]|r"


		-----
		if subType == "Wowhead" then
			texts = GetWowHeadDressingRoomURL();
		end
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

function Narci_WebsiteButton_OnLoad(self)
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
	local type = type or frame.CodeType or "TEXT";
	local subType = subType or frame.GearTexts.BBSCode.subType or "Wowhead";
	local texts = CopyTexts(type, subType);
	frame.GearTexts:SetText(texts);

	if frame.GearTexts then
		frame.GearTexts:SetFocus();
		frame.GearTexts:HighlightText();
	end
end

local CodeTokenList = {
	[1] = "TEXT",	[2] = "BBS", [3] = "MARKDOWN",
}

function Narci_CodeTokenButton_OnClick(self)
	self:GetParent():GetParent().CodeType = CodeTokenList[self:GetID()];
	SetClipboard();
	TokenButton_ClearMarker(self);
	self.HighlightColor:Show();
	self.AnimFrame.Anim:SetScale(1.8);
	self.AnimFrame.Anim.Bling:Play();
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

function Narci_CopyButton_OnClick(self)
	self.IsOn = not self.IsOn;
	if self.IsOn then
		SetClipboard(self);
		FadeFrame(self.GearTexts, 0.25, 1);
	else
		FadeFrame(self.GearTexts, 0.25, 0);
	end

	self.AnimFrame.Anim:SetScale(1.5);
	self.AnimFrame.Anim.Bling:Play();
end

--Narci_EmoteButton
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
	local ltrim = string.trim;
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
			subListNum_Max = max(subListNum, subListNum_Max);
		end
	end

	for i = 1, #List do
		for j=1, subListNum_Max do
			
			button = CreateFrame("Button", buttonName and (buttonName ..(i+j-1) ) or nil, PopUp, buttonTemplate);

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

	EmoteTokenList = nil;
end

function Narci_EmoteButtonPopUp_OnLoad(self) 
	EmoteButton_CreateList(self, "NarciEmoteTokenButtonTemplate", EmoteTokenList)
	self.autoCapture = false;
end

function Narci_EmoteButton_OnClick(self)
	self.IsOn = not self.IsOn
	local popupFrame = Narci_EmoteButtonPopUp;
	if not self.IsOn then
		PlayCheckSound(self, false)
		self.Icon:SetTexCoord(0, 0.5, 0, 1);
		self.UpdateFrame:Hide();
		popupFrame.AnimFrame:Hide();
		popupFrame.AnimFrame:Show();
		popupFrame.AnimFrame.EndPointY = -40;
	else
		PlayCheckSound(self, true)
		self.Icon:SetTexCoord(0.5, 1, 0, 1);
		popupFrame:Show();
		popupFrame.AnimFrame:Hide();
		popupFrame.AnimFrame:Show();
		popupFrame.AnimFrame.EndPointY = 8;
	end

	NarciTooltip:FadeOut();

	if Narci_XmogButton.IsOn then
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
	offSet = outSine(t, StartPoint, EndPoint, duration)
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

	if Narci_EmoteButtonPopUp.autoCapture then
		After(0.8, function()
			Screenshot()
		end)
	end
end

function EmoteButton_UpdateFrame_OnUpdate(self, elapsed)
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

	if self.TimeSinceLastUpdate >=	self.duration then
		DoEmote(self.Emote, "none");
		self.TimeSinceLastUpdate = 0;
	end
end

function Narci_AutoCaptureButton_OnClick(self)
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
	ColorUtil:SetWidgetColor(self.Color);
	ColorUtil:SetWidgetColor(self.HighlightColor);
end

function Narci_EmoteTokenButton_OnClick(self)
	TokenButton_ClearMarker(self)
	self.HighlightColor:Show()
	Narci_EmoteButton.UpdateFrame.Emote = self.Token;
	if Narci_EmoteButton.IsOn then
		Narci_EmoteButton.UpdateFrame:Hide();
		Narci_EmoteButton.UpdateFrame:Show();
	end

	self.AnimFrame.Anim.Bling:Play();
end

function Narci_HideTextsButton_OnClick(self)
	self.IsOn = not self.IsOn
	NarcissusDB.PhotoModeButton.HideTexts = self.IsOn

	if not self.IsOn then
		PlayCheckSound(self, false)
		PhotoMode_RestoreCvar(PhotoMode_Cvar_NamesBackup);
		SetTracking(1, PhotoMode_Cvar_TrackingBAK);		--Track Battle Pet
		self.Icon:SetTexCoord(0, 0.5, 0, 1);
		self.tooltip = {L["HideTexts Button"], L["HideTexts Button Tooltip Open"] .. "\n|cff6b6b6b"..L["HideTexts Button Tooltip Special"]};
	else
		PlayCheckSound(self, true)

		PhotoMode_BackupCvar(PhotoMode_Cvar_NamesBackup, PhotoMode_Cvar_NamesList);
		PhotoMode_ZeroCvar(PhotoMode_Cvar_NamesBackup);
		PhotoMode_GetTrackingInfo();
		SetTracking(1, false);
		self.Icon:SetTexCoord(0.5, 1, 0, 1);
		self.tooltip = {L["HideTexts Button"], L["HideTexts Button Tooltip Close"] .. "\n|cff6b6b6b"..L["HideTexts Button Tooltip Special"]};
	end

	NarciTooltip:FadeOut();
end

function TopQualityButton_OnClick(self)
	self.IsOn = not self.IsOn
	if not self.IsOn then
		PlayCheckSound(self, false)
		PhotoMode_RestoreCvar(PhotoMode_Cvar_GraphicsBackup);
		self.Icon:SetTexCoord(0, 0.5, 0, 1);
		FadeFrame(TopQualityButton_MSAASlider, 0.25, 0);
		TopQualityButton_RayTracingToggle:FadeOut();
		self.tooltip = {L["TopQuality Button"], L["TopQuality Button Tooltip Open"] .. "\n|cff6b6b6b"..L["HideTexts Button Tooltip Special"]};
	else
		PlayCheckSound(self, true)
		PhotoMode_BackupCvar(PhotoMode_Cvar_GraphicsBackup, PhotoMode_Cvar_GraphicsList);
		PhotoMode_RestoreCvar(PhotoMode_Cvar_GraphicsList);
		self.Icon:SetTexCoord(0.5, 1, 0, 1);
		FadeFrame(TopQualityButton_MSAASlider, 0.25, 1);
		TopQualityButton_RayTracingToggle:FadeIn();
		self.tooltip = {L["TopQuality Button"], L["TopQuality Button Tooltip Close"] .. "\n|cff6b6b6b"..L["HideTexts Button Tooltip Special"]};
	end

	NarciTooltip:FadeOut();
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
			valueText = "|cffee3224".."OFF";
		end
		self.KeyLabel2:SetText(MULTISAMPLE_ANTI_ALIASING.." "..valueText)
		if value ~=0 then
			ConsoleExec("MSAAQuality "..value..",0" )
		else
			ConsoleExec("MSAAQuality 0")
		end
	end
end

function CameraMover:ShowFrame()
	local GuideLineFrame = Narci_GuideLineFrame;
	local VirtualLineRight = GuideLineFrame.VirtualLineRight;
	VirtualLineRight.AnimFrame:Hide();
	VirtualLineRight:SetPoint("RIGHT", - 404, 0);
	GuideLineFrame.VirtualLineLeft:SetPoint("LEFT", 0, 0);
	if MOG_MODE then
		FadeFrame(Narci_Attribute, 0.4, 0)
	else
		VirtualLineRight.AnimFrame.EndPoint = GuideLineFrame.VirtualLineRight.AnimFrame.EndPointBAK;
		FadeFrame(Narci_Attribute, 0.4, 1, 0);
	end
	VirtualLineRight.AnimFrame:Show();
	GuideLineFrame.VirtualLineLeft.AnimFrame:Show();
	PlayAttributeAnimation();
	After(0, function()
		FadeFrame(Narci_Character, 0.6, 1);
		After(0.3, function()
			PlayIlvlInfoAnimation();
		end)

		--SetCVar("test_cameraDynamicPitchSmartPivotCutoffDist", 10);
	end)

	Narci_SnowEffect(true);
end


----------------------------

local DURATION_FLY_IN = 0.4;
function PhotoModeControllerAnimFrame_OnUpdate(self, elapsed)
	local duration = DURATION_FLY_IN;
	local EndPoint = self.EndPointY;
	local StartPoint = self.StartPointY;
	local offSet, alpha;
	local t = self.TimeSinceLastUpdate;
	local frame = self:GetParent();
	offSet = outSine(t, StartPoint, EndPoint, duration);
	alpha = outSine(t, self.fromAlpha, self.toAlpha, duration);
	frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, self.EndPoint, offSet);
	frame:SetAlpha(alpha)

	if t >= duration then
		frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, self.EndPoint, self.EndPointY);
		if not self.OppoDirection then
			frame:SetAlpha(self.toAlpha);
			frame:Show();
			PhotoModeControllerBar:SetAlpha(1);
		else
			frame:SetAlpha(0);
			frame:Hide();
		end

		self:Hide();
		return;
	end
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
end

function PhotoModeControllerAnimFrame_OnHide(self)
	self.TimeSinceLastUpdate = 0;
end

function IlvlButtonLeftAnimFrame_OnUpdate(self, elapsed)
	local StartPoint = self.StartPoint;
	local EndPoint = 24;
	local Distance = self.Width + 10;
	local offSet;
	local t = self.TimeSinceLastUpdate;
	local frame = self:GetParent();

	if not self.OppoDirection then
		offSet = outSine(t, StartPoint, EndPoint , DURATION_FLY_IN);
		frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, offSet, 0);

		if t >= DURATION_FLY_IN then
			frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, EndPoint, 0);
			self:Hide()
			return;
		end
	else
		offSet = outSine(t, StartPoint, Distance, DURATION_FLY_IN);
		frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, offSet, 0);

		if t >= DURATION_FLY_IN then
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
		offSet = outSine(t, StartPoint , EndPoint, DURATION_FLY_IN)
		frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, offSet, 0);

		if t >= DURATION_FLY_IN then
			frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, EndPoint, 0);
			self:Hide()
			return;
		end
	else
		offSet = outSine(t, StartPoint, -Distance, DURATION_FLY_IN)
		frame:SetPoint(self.AnchorPoint, self.relativeTo, self.relativePoint, offSet, 0);

		if t >= DURATION_FLY_IN then
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


------Photo Mode Toolbar------
NarciPhotoModeToolbarMixin = {};

function NarciPhotoModeToolbarMixin:OnLoad()
	Toolbar = self;

	local animRotation = NarciAPI_CreateAnimationFrame(0.6);
	self.animRotation = animRotation;

	animRotation:SetScript("OnUpdate", function(frame, elapsed)
		local t = frame.total;
		frame.total = t + elapsed;
		local radian = outSine(t, frame.fromRadian, frame.toRadian, frame.duration);
		local width = outSine(t, frame.fromWidth, frame.toWidth, frame.duration);
		if frame.total >= frame.duration then
			radian = frame.toRadian;
			width = frame.toWidth;
			frame:Hide();
			if self.Switch.IsOn then
				self.Bar:SetClipsChildren(false);
			else
				self.Bar:SetClipsChildren(true);
			end
		end
		self.Switch.Ring:SetRotation(radian);
		self.Bar:SetWidth(width);
	end)

	animRotation:SetScript("OnShow", function(frame)
		frame.fromRadian = self.Switch.Ring:GetRotation();
		frame.fromWidth = self.Bar:GetWidth();
	end)

	self.Switch.Ring:SetRotation(2*pi);

	self:SetScript("OnLoad", nil);
	self.OnLoad = nil;
end

function NarciPhotoModeToolbarMixin:DisableAll()
	local Bar = self.Bar;
	if Bar.Emote.IsOn then
		Bar.Emote:Click();
	end

	if Bar.HideTexts.IsOn then
		Bar.HideTexts:Click();
		NarcissusDB.PhotoModeButton.HideTexts = true;
	end

	if Bar.Xmog.IsOn then
		Bar.Xmog:Click()		--Quit Xmog Mode
	end
	
	if Bar.TopQuality.IsOn then
		Bar.TopQuality:Click();
	end
end

function NarciPhotoModeToolbarMixin:OnHide()
	self:DisableAll();
	self:UnregisterEvent("PLAYER_LOGOUT");
end

function NarciPhotoModeToolbarMixin:OnShow()
	self:RegisterEvent("PLAYER_LOGOUT");

	self.PhotoModeControllerAnimFrame:Hide();
	self.PhotoModeControllerAnimFrame.EndPointY = "10";
	self.PhotoModeControllerAnimFrame.OppoDirection = false;
	self.PhotoModeControllerAnimFrame:Show()

	ColorUtil:UpdateByMapID();
end

function NarciPhotoModeToolbarMixin:OnEvent(event)
	self:DisableAll();
	SetCVar("Sound_MusicVolume", CVarTemp.MusicVolume);
	if CVarTemp.DynamicPitch ~= 1 then		--Restore the acioncam state
		SetCVar("test_cameraDynamicPitch", 0);
		ConsoleExec( "actioncam off");
	end
	ViewProfile:ResetView(5);
end

function Narci_PhotoModeButton_OnClick(self, key)
	self.IsOn = not self.IsOn;
	local updateFrame = self:GetParent().animRotation;
	updateFrame:Hide();
	local barWidth = self:GetParent().Bar:GetWidth();
	if self.IsOn then
		updateFrame.duration = min(0.6, sqrt(0.4 * (220 - barWidth)/180) );
		updateFrame.toRadian = 1.25*pi;
		updateFrame.toWidth = 220;
	else
		updateFrame.duration = min(0.6, sqrt(0.4 * (barWidth - 40)/180) );
		updateFrame.toRadian = 2*pi;
		updateFrame.toWidth = 40;
	end
	updateFrame:Show();
	
	if self.IsOn then
		self.Icon:SetTexCoord(0.25, 0.5, 0.75, 1);
		PhotoModeControllerBar:SetAlpha(1)
	else
		self.Icon:SetTexCoord(0, 0.25, 0.75, 1);
		PhotoModeControllerBar:SetClipsChildren(true);
	end

	NarciTooltip:FadeOut();
	TemporarilyHidePopUp(Narci_XmogButtonPopUp);
	TemporarilyHidePopUp(Narci_EmoteButtonPopUp);
end

hooksecurefunc("SetUIVisibility", function(bool)
	if IS_OPENED then		--when Narcissus hide the UI
		if not bool then
			if NarcissusDB.PhotoModeButton.HideTexts and (not Narci_HideTextsButton.IsOn) then
				Narci_HideTextsButton:Click();
			end
			local frame = Toolbar;
			frame.ExitButton:Show();
			if not frame:IsShown() then
				frame:Show();
				frame.PhotoModeControllerAnimFrame.OppoDirection = false;
			end
		end
	else						--when user hide the UI manually
		if not bool then
			local frame = Toolbar;
			if not frame:IsShown() then
				CVarTemp.OverShoulder = GetCVar("test_cameraOverShoulder");
			end
			frame.PhotoModeControllerAnimFrame.toAlpha = 0;
			frame:Show();
			frame.PhotoModeControllerAnimFrame.OppoDirection = false;

			if NarcissusDB.PhotoModeButton.HideTexts and (not Narci_HideTextsButton.IsOn) then
				Narci_HideTextsButton:Click();
			end
			
			Narci_XmogButton:Disable();
			frame.ExitButton:Hide();
		else
			--When player closes the full-screen world map, SetUIVisibility(true) fires twice, and WorldMapFrame:IsShown() returns true and false.
			--Thus, use this VisibilityTracker instead to check if WorldMapFrame has been closed recently.
			--WorldMapFrame.VisibilityTracker.state
			if Narci_Character:IsShown() then return; end
			SmoothShoulderCVar(CVarTemp.OverShoulder);
			if not GetKeepActionCam() then
				After(0.6, function()
					ConsoleExec( "actioncam off" );
				end)
			end
			local frame = Toolbar;
			if frame:IsShown() then
				frame.PhotoModeControllerAnimFrame:Hide();
				frame.PhotoModeControllerAnimFrame.OppoDirection = true;
				frame.PhotoModeControllerAnimFrame.EndPointY = "-80";
				frame.PhotoModeControllerAnimFrame:Show();
				CameraOffsetControlBar.Thumb:SetPoint("CENTER", 0, 0);
			end
		end
	end

end)

SLASH_NARCI1 = "/narci";
SLASH_NARCI2 = "/narcissus";
SlashCmdList["NARCI"] = function(msg)
	msg = strlower(msg);
	if msg == "" then
		MiniButton:Click();
	elseif msg == "minimap" then
		MiniButton:Show();
		MiniButton:PlayBling();
		NarcissusDB.ShowMinimapButton = true;
		print("Minimap button has been re-enabled.");
	elseif msg == "itemlist" then
		DressUpFrame_Show(DressUpFrame);
	elseif msg == "parser" then
		FadeFrame(Narci_ItemParser, 0.25, 1);
	else
		local color = "|cff40C7EB";
		print(color.."Show Minimap Button:|r /narci minimap");
		print(color.."Copy Item List:|r /narci itemlist");
		print(color.."Corruption Item Parser:|r /narci parser");
	end
end

--[[
Global Strings:

SoundKit
54133		UI_70_Artifact_Forge_Toast_TraitAvailable


powerType, powerTypeString = UnitPowerType(unit);
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

/run NarciPlayerModelFrame1:SetLight(true, false, 1, 1, 1.732, 1, 0.8, 0.8, 0.8, 1, 0.8, 0.8, 0.8)
/run NarciPlayerModelFrame1:SetLight(true, false, -0.2, 1, -1, 1, 0.8, 0.8, 0.8, 1, 1, 0.6, 0.6)
/run NarciPlayerModelFrame1:SetLight(true, false, -0.5, 0.5, -0.5, 0.8, 0.5, 0.5, 0.8, 1, 0.8, 0.8, 0.8)  

/run NarciPlayerModelFrame1:SetLight(true, false, -0.5, 0.5, -0.5, 0.8, 0.7, 0.5, 0.8, 1, 0.8, 0.8, 0.8)
/run NarciPlayerModelFrame1:FreezeAnimation(1)
SetPortraitZoom(0.3)
SetPosition(0,0,-0.06)
NarciPlayerModelFrame1:SetFacing(-.4)
NarciPlayerModelFrame1:SetSequenceTime(68)
/run Narci_PlayerModelAnimIn:Show()
--]]


function Narci_ModelToggle_OnClick(self)
	self:Disable()
	After(1, function()
		self:Enable()
	end)
	self.AnimFrame.Anim:SetScale(1.5)
	self.AnimFrame.Anim.Bling:Play();
	NarcissusDB.AlwaysShowModel = not NarcissusDB.AlwaysShowModel;
	self.IsOn = NarcissusDB.AlwaysShowModel;
	self.Tick:SetShown(self.IsOn);
	Narci_AlwaysShowModelToggle.Tick:SetShown(self.IsOn);
	if self.IsOn and xmogMode == 1 then
		if not NarciPlayerModelFrame1:IsVisible() then
			if xmogMode == 1 then
				NarciModel_RightGradient:Hide();
			end
			Narci_PlayerModelAnimIn:Show()
		end
	elseif xmogMode ~= 2 then
		HidePlayerModel()
	end

end

function Narci_XmogLayoutButton_OnClick(self)
	self:Disable()
	After(0.8, function()
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

local function HideContollerButton(state)
	if state then
		Narci_XmogButton:Hide()
		Narci_EmoteButton:Hide()
		Narci_HideTextsButton:Hide()
		Narci_TopQualityButton:Hide()
	else
		Narci_XmogButton:Show()
		Narci_EmoteButton:Show()
		Narci_HideTextsButton:Show()
		Narci_TopQualityButton:Show()
	end
end

function PhotoMode_WheelEventContrainer_OnMouseWheel(self, delta)
	if Narci_PhotoModeButton.IsOn then
		if CameraOffsetControlBar:IsShown() then
			CameraControlBar_ResetPosition(true)
		end
		TemporarilyHidePopUp(Narci_XmogButtonPopUp);
		TemporarilyHidePopUp(Narci_EmoteButtonPopUp);
		AnimationSequenceContainer_Controller:Hide()
		AnimationSequenceContainer_Controller:Show()
	end
end

local function TemporarilyDisableWheel(frame)
	frame:SetScript("OnMouseWheel", function(self, delta)
	end)

	After(0.2, function()
		frame:SetScript("OnMouseWheel", PhotoMode_WheelEventContrainer_OnMouseWheel)
	end)
end

----------------
--3D Animation--
local ASC = CreateFrame("Frame","AnimationSequenceContainer_Controller");
ASC:Hide()
local function InitializeAnimationContainer(frame, SequenceInfo, TargetFrame)
	frame.OppoDirection = false;
	frame.t = 0
	frame.totalTime = 0;
	frame.Index = 1;
	frame.Pending = false;
	frame.IsPlaying = false;	
	frame.SequenceInfo = SequenceInfo;
	frame.Target = TargetFrame
end

local function AnimationContainer_OnHide(self)
	self.totalTime = 0;
	self.TimeSinceLastUpdate = 0;
	self.OppoDirection = not self.OppoDirection
	if self.Index <= 0 then
		self.Index = 0;
	end
end

local PlayAnimationSequence = NarciAPI_PlayAnimationSequence;

local function Controller_AnimationSequence_OnUpdate(self, elapsed)
	if self.Pending then
		return;
	end

	self.t = self.t + elapsed;
	self.totalTime = self.totalTime + elapsed;
	
	if self.t >= 0.01666 then
		self.t = 0;
		if self.OppoDirection then
			self.Index = self.Index - 1;
		else
			self.Index = self.Index + 1;
		end

		if not PlayAnimationSequence(self.Index, self.SequenceInfo, self.Target) then
			Narci_PhotoModeButton:SetAlpha(1);
			PhotoModeControllerBar:SetAlpha(1);
			if self.OppoDirection then
				FadeFrame(PhotoModeControllerTransition.Sequence, 0.2, 0)
				HideContollerButton(false)
				Narci_PhotoModeButton:SetAlpha(1);
				PhotoModeControllerBar:SetAlpha(1);
				CameraOffsetControlBar:Hide()
			else
				HideContollerButton(true)
				CameraOffsetControlBar:Show()
				CameraOffsetControlBar:SetAlpha(1);
				FadeFrame(PhotoModeControllerTransition.Sequence, 0.2, 0)
				After(0.25, function()
					CameraControlBar_ResetPosition(false)
				end)
			end
			TemporarilyDisableWheel(PhotoMode_WheelEventContrainer);
			self:Hide()
			self.IsPlaying = false;
			return;
		end
		--CameraOffsetControlBar:SetAlpha(0);
		Narci_PhotoModeButton:SetAlpha(0);
		PhotoModeControllerBar:SetAlpha(0);
	end
end

ASC:SetScript("OnUpdate", Controller_AnimationSequence_OnUpdate)
ASC:SetScript("OnHide", AnimationContainer_OnHide)
ASC:SetScript("OnShow", function(self)
	self.IsPlaying = true;
end)

local ASC2 = CreateFrame("Frame", "AnimationSequenceContainer_Heart");
ASC2.Delay = 5;
ASC2.IsPlaying = false;
ASC2:Hide();

local function Generic_AnimationSequence_OnUpdate(self, elapsed)
	if self.Pending then
		return;
	end

	self.totalTime = self.totalTime + elapsed;
	if (not self.OppoDirection and self.totalTime < self.Delay) and (not self.IsPlaying) then
		return;
	elseif not self.IsPlaying then
		if not self.OppoDirection then		--box closing
			FadeFrame(HeartofAzeroth_AnimFrame, 0.25, 1)
			After(0.3, function()
				HeartofAzeroth_AnimFrame.Background:SetAlpha(1);
				HeartofAzeroth_AnimFrame.Quote:SetAlpha(1);
				HeartofAzeroth_AnimFrame.SN:SetAlpha(1);
			end)
		end
		self.IsPlaying = true;
	end
	
	self.t = self.t + elapsed;

	if self.t >= 0.01666 then
		self.t = 0;
		if self.OppoDirection then
			self.Index = self.Index - 1;
		else
			self.Index = self.Index + 1;
		end

		if not PlayAnimationSequence(self.Index, self.SequenceInfo, self.Target) then
			self:Hide()
			self.IsPlaying = false;
			if not self.OppoDirection then
				HeartofAzeroth_AnimFrame.Background:SetAlpha(0);
				HeartofAzeroth_AnimFrame.Quote:SetAlpha(0);
				HeartofAzeroth_AnimFrame.SN:SetAlpha(0);
				FadeFrame(HeartofAzeroth_AnimFrame, 0.25, 0)
			end
			return;
		end
	end
end

ASC2:SetScript("OnUpdate", Generic_AnimationSequence_OnUpdate);
ASC2:SetScript("OnHide", AnimationContainer_OnHide);


function CameraControlBar_ResetPosition_AnimFrame_OnShow(self)
	local StartX = CameraOffsetControlBar.PosX or 0;
	local StartAngle = CameraOffsetControlBar.PosRadian or 0;
	self.tOut = max(math.abs(StartX) / CameraOffsetControlBar.Range, math.abs(StartAngle)/(2*pi), 0.2)
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

	local Value_Angle = outSine(self.TimeSinceLastUpdate, StartAngle, EndAngle, t)
	local Value_X = outSine(self.TimeSinceLastUpdate, StartX, EndX, t)
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
	if CameraOffsetControlBar:IsShown() and (not AnimationSequenceContainer_Controller.IsPlaying) then
		CameraControlBar_ResetPosition_AnimFrame.OppoDirection = bool
		AnimationSequenceContainer_Controller.Pending = true;
		CameraControlBar_ResetPosition_AnimFrame:Show();
	end
end

local raceList = {	--For 3D Portait on the top-left
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

	[6]  = {[2] = {24, -15, 3, 0.6, 1},		--Tauren Male	√
		    [3] = {24, -8, 1.8, false, 1},	-- 	     Female
		},	

	[7]  = {[2] = {10, -14, 1, 0.5, 1},			--Gnome Male
		    [3] = {14, -14, 0.8, 0.55, 0},	-- 	    Female
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

	[35]  = {[2] = {18, -8, 0.7, false, 1, 2},		--Vulpera Male
		    [3] = {18, -8, 0.7, false, 1, 2},	-- 	    Female 	 √
		},
}

function Narci_PortraitPieces_OnLoad(self)
	local unit = "player";
	local a1, a2, a3;
	local ModelPieces = self.Pieces;
	local _, _, raceID = UnitRace(unit);
	local GenderID = UnitSex(unit);

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
	elseif raceID == 37 then				--Mechagnome
		raceID = 7;
	elseif raceID == 22 then --Worgen
		local _, inAlternateForm = HasAlternateForm();
		if not inAlternateForm	then
			raceID = 128;
		end
	end

	local model;
	if raceList[raceID] and raceList[raceID][GenderID] then
		if Narci_FigureModelReference then
			Narci_FigureModelReference:SetPoint("CENTER", raceList[raceID][GenderID][1], raceList[raceID][GenderID][2])
		end

		for i = 1, #ModelPieces do
			model = ModelPieces[i];
			model:SetUnit(unit);
			model:SetCamera(raceList[raceID][GenderID][5]);
			model:MakeCurrentCameraCustom();
			if raceList[raceID][GenderID][3] then
				model:SetCameraDistance(raceList[raceID][GenderID][3])
			end
			if raceList[raceID][GenderID][4] then
				a1, a2, a3 = model:GetCameraPosition();
				model:SetCameraPosition(a1, a2, raceList[raceID][GenderID][4])
			end
			if raceList[raceID][GenderID][6] then
				model:SetAnimation(2, raceList[raceID][GenderID][6])
			end
		end
	else
		for i = 1, #ModelPieces do
			model = ModelPieces[i];
			model:SetCamera(0);
			model:MakeCurrentCameraCustom();
			a1, a2, a3 = model:GetCameraPosition();
			model:SetCameraPosition(a1, a2, 1.1);
		end
	end

	for i = 1, #ModelPieces do
		model = ModelPieces[i];
		model:SetFacing(-math.pi/24)	--Front pi/6
		model:SetAnimation(804, 1);	--804
		model:SetLight(true, false, - 0.44699833180028 ,  0.72403680806459 , -0.52532198881773, 0.8, 0.7, 0.5, 0.8, 1, 0.8, 0.8, 0.8)
		model:UndressSlot(1);
		model:UndressSlot(3);
		model:UndressSlot(15);		--Remove the cloak
		model:UndressSlot(16);
		model:UndressSlot(17);
	end
end

--Static Events
EL:RegisterEvent("ADDON_LOADED");
EL:RegisterEvent("PLAYER_ENTERING_WORLD");
EL:RegisterEvent("UNIT_NAME_UPDATE");
EL:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
EL:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE");
EL:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED");
EL:RegisterEvent("PLAYER_LEVEL_CHANGED");

--These events might become deprecated in future expansions
EL:RegisterEvent("AZERITE_ESSENCE_ACTIVATED");
EL:RegisterEvent("COVENANT_CHOSEN");
EL:RegisterEvent("COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED");

EL:SetScript("OnEvent",function(self,event,...)
	--print(event)
	if event == "ADDON_LOADED" then
		local name = ...;
		if name ~= "Narcissus" then
			return;
		end
		self:UnregisterEvent(event);
		
		AssignFrame();
		AssignFrame = nil;

		ShowDetailedIlvlInfo();
		After(2, function()
			Narci_AliasButton_SetState();
			Narci_MinimapButton_OnLoad();
			Narci_SetActiveBorderTexture();
			StatsUpdator:Instant();
			RadarChart:SetValue(0,0,0,0,1);
			UpdateXmogName();
		end)

		local AnimSequenceInfo = Narci.AnimSequenceInfo;
		InitializeAnimationContainer(ASC2, AnimSequenceInfo["Heart"], HeartofAzeroth_AnimFrame.Sequence)
		InitializeAnimationContainer(ASC, AnimSequenceInfo["Controller"], PhotoModeControllerTransition.Sequence)
		local HeartSerialNumber = strsub(UnitGUID("player"), 8, 15);
		HeartofAzeroth_AnimFrame.SN:SetText("No."..HeartSerialNumber)
		
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent(event);
		UpdateXmogName();
		SetCVar("CameraKeepCharacterCentered", 0);
		--CameraMover:SetBlend(NarcissusDB.CameraTransition);	--Load in Preference.lua
		DefaultTooltip = NarciGameTooltip;	--Created in NarciAPI.lua
		DefaultTooltip:SetParent(Narci_Character);
		DefaultTooltip:SetFrameStrata("TOOLTIP");
		DefaultTooltip.offsetX = 6;
		DefaultTooltip.offsetY = -18;
		DefaultTooltip:SetIgnoreParentScale(true);
		DefaultTooltip:SetIgnoreParentAlpha(true);
		local HotkeyFrame = CreateFrame("Frame", nil, Narci_Attribute, "NarciHotkeyNotificationTemplate");
		HotkeyFrame:SetKey(NARCI_MODIFIER_ALT, "LeftButton", L["Swap items"]);
		HotkeyFrame:SetPoint("BOTTOM", DefaultTooltip, "TOP", -2, 8);
		HotkeyFrame:SetFrameStrata("TOOLTIP");
		HotkeyFrame:SetIgnoreParentScale(true);
		DefaultTooltip.HotkeyFrame = HotkeyFrame;
		DefaultTooltip:HookScript("OnHide", function()
			HotkeyFrame:FadeOut();
		end)
		EquipmentFlyoutFrame = Narci_EquipmentFlyoutFrame;
		MiniButton:SetBackground();
		
		if IsAddOnLoaded("DynamicCam") then
			CVarTemp.isDynamicCamLoaded = true;
			
			--Check validity
			if not (DynamicCam.BlockShoulderOffsetZoom and DynamicCam.AllowShoulderOffsetZoom) then return end;
			hooksecurefunc("Narci_Open", function()
				if IS_OPENED then
					DynamicCam:BlockShoulderOffsetZoom();
				else
					DynamicCam:AllowShoulderOffsetZoom();
				end
			end)
			hooksecurefunc("Narci_OpenGroupPhoto", function()
				DynamicCam:BlockShoulderOffsetZoom();
			end)

			ViewProfile:Disable();

		end

		After(1.7, function()
			UpdateCharacterInfoFrame();
			
			hooksecurefunc("CameraZoomIn", function(increment)
				if IS_OPENED and (xmogMode ~= 1) then
					UpdateShoulderCVar:Start(-increment);
				end
			end)
			
			hooksecurefunc("CameraZoomOut", function(increment)
				if IS_OPENED and (xmogMode ~= 1)then
					UpdateShoulderCVar:Start(increment);
				end
			end)
		end)

		--Cache
		MiniButton:Disable();			--Disable minimap button while caching
		After(1.3, function()
			CacheSourceInfo();
		end)
		After(2.9, function()
			MOG_MODE = true;
			USE_DELAY = true;
			RefreshAllSlot();					--Cache transmog appearance sources
		end)
		After(3.7, function()
			MOG_MODE = false;
			RefreshAllSlot();
			MiniButton:Enable();
			MiniButton:SetMotionScriptsWhileDisabled(false);
		end)
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		local slotID, isItem = ...;
		CacheSourceInfo(slotID)
		USE_DELAY = false;
		RefreshSlot(slotID);
		if EquipmentFlyoutFrame:IsShown() and EquipmentFlyoutFrame.slotID == slotID then
			Narci_BuildFlyout(slotID);
		end
		USE_DELAY = true;

	elseif event == "AZERITE_ESSENCE_ACTIVATED" then
		RefreshSlot(2);		--Heart of Azeroth

	elseif event == "PLAYER_AVG_ITEM_LEVEL_UPDATE" then
        if not self.isRefreshing then
            self.isRefreshing = true;
            After(0, function()    -- only want 1 update per 0.1s
				ItemLevelFrame:Update();
				After(0.1, function()
					self.isRefreshing = nil;
				end)
            end)
		end

	elseif event == "COVENANT_CHOSEN" then
		local covenantID = ...;
		ItemLevelFrame:Update();
		MiniButton:SetBackground(covenantID);

	elseif event == "COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED" then
		local newRenownLevel = ...;
		ItemLevelFrame:UpdateRenownLevel(newRenownLevel);

	elseif event == "UNIT_NAME_UPDATE" then
		local unit = ...;
		if unit == "player" then
			UpdateCharacterInfoFrame();
		end

	elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
		UpdateCharacterInfoFrame();
		UpdateXmogName(true);

	elseif event == "PLAYER_LEVEL_CHANGED" then
		local oldLevel, newLevel = ...;
		UpdateCharacterInfoFrame(newLevel)

	elseif ( event == "COMBAT_RATING_UPDATE" or
			 event == "UNIT_MAXPOWER" or
			 event == "UNIT_STATS" or
			 event == "UNIT_DAMAGE" or event == "UNIT_ATTACK_SPEED" or event == "UNIT_MAXHEALTH" or event == "UNIT_AURA"
			) and Narci.refreshCombatRatings then
		-- don't refresh stats when equipment set manager is activated
		StatsUpdator:Instant();
		if event == "COMBAT_RATING_UPDATE" then
			if Narci_Character:IsShown() then
				RadarChart:AnimateValue();
			end
		end
	elseif event == "PLAYER_TARGET_CHANGED" then
		RefreshStats(8);		--Armor
		RefreshStats(9); 		--Damage Reduction

	elseif event == "UPDATE_SHAPESHIFT_FORM" then
		ModifyCameraForShapeshifter();
		CameraMover:OnCameraChanged();

	elseif event == "PLAYER_MOUNT_DISPLAY_CHANGED" then
		ModifyCameraForMounts();
		CameraMover:OnCameraChanged();

	elseif event == "PLAYER_REGEN_DISABLED" then
		if Narci.isAFK and Narci.isActive then
			--exit when entering combat during AFK mode
			MiniButton:Click();
			Narci:PlayVoice("DANGER");
		end

	elseif event == "PLAYER_STARTED_MOVING" then
		self:UnregisterEvent(event);
		MoveViewRightStop();
		if Narci.isAFK and Narci.isActive then
			--exit when entering combat during AFK mode
			MiniButton:Click();
		end

	elseif event == "PLAYER_STARTED_TURNING" and not MOG_MODE then
		NarciAR.Turning.radian = GetPlayerFacing();
		NarciAR.Turning:Show();

	elseif event == "PLAYER_STOPPED_TURNING" and not MOG_MODE then
		NarciAR.Turning:Hide();

	elseif event == "BAG_UPDATE_COOLDOWN" then
		StatsUpdator:UpdateCooldown();
	end
end)

function EL:ToggleDynamicEvents(state)
	local dynamicEvents = {"PLAYER_TARGET_CHANGED", "COMBAT_RATING_UPDATE", "PLAYER_MOUNT_DISPLAY_CHANGED",
	"PLAYER_STARTED_MOVING", "PLAYER_REGEN_DISABLED", "UNIT_MAXPOWER", "PLAYER_STARTED_TURNING", "PLAYER_STOPPED_TURNING",
	"BAG_UPDATE_COOLDOWN", "UNIT_STATS",
	};
	local unitEvents = {"UNIT_DAMAGE", "UNIT_ATTACK_SPEED", "UNIT_MAXHEALTH", "UNIT_AURA"};
	
	if state then
		for i = 1, #dynamicEvents do
			self:RegisterUnitEvent(dynamicEvents[i]);
		end
		for i = 1, #unitEvents do
			self:RegisterUnitEvent(unitEvents[i], "player");
		end
	else
		for i = 1, #dynamicEvents do
			self:UnregisterEvent(dynamicEvents[i]);
		end
		for i = 1, #unitEvents do
			self:UnregisterEvent(unitEvents[i]);
		end
	end

	dynamicEvents = nil;
	unitEvents = nil;
end

EL:SetScript("OnShow",function(self)
	self:ToggleDynamicEvents(true);
	if NarciAR then
		NarciAR:Show();
	end
end)

EL:SetScript("OnHide",function(self)
	self:ToggleDynamicEvents(false);
	self:UnregisterEvent("UPDATE_SHAPESHIFT_FORM");
	if NarciAR then
		NarciAR:Hide();
	end
end)


----------------------------------------------------------------------
--Double-click PaperDoll Button to open Narcissus
NarciPaperDollDoubleClickTriggerMixin = {};

local function Narci_DoubleClickTrigger_OnUpdate(self, elapsed)
	self.t = self.t + elapsed;
	if self.t > 0.25 then
		self:SetScript("OnUpdate", nil);
	end
end

function NarciPaperDollDoubleClickTriggerMixin:OnLoad()
	self.t = 0;

	self:SetScript("OnLoad", nil);
	self.OnLoad = nil;
end

function NarciPaperDollDoubleClickTriggerMixin:OnShow()
	self.t = 0;
	self:SetScript("OnUpdate", Narci_DoubleClickTrigger_OnUpdate);
end


function NarciPaperDollDoubleClickTriggerMixin:OnHide()
	if (self.t < 0.25) and NarcissusDB.EnableDoubleTap then
		MiniButton:Click();
	end
end

----------------------------------------------------------------------
function Narci_SetActiveBorderTexture()
	local minimapTexture, themeName;
	BorderTexture, minimapTexture, themeName = NarciAPI.GetBorderTexture();
	local MinimapButton = MiniButton;
	local minimapBackgroundSize = 42;
	local slot;
	local slotWidth, slotHeight, iconSize, slotShadow, runePlateAlpha;
	if themeName == "Dark" then
		slotWidth = 70;
		slotHeight = 72;
		iconSize = 44;
		slotShadow = true;
		runePlateAlpha = 0;
	else
		slotWidth = 64;
		slotHeight = 68;
		iconSize = 48;
		slotShadow = false;
		runePlateAlpha = 1;
	end

	for i=1, #slotTable do
		slot = slotTable[i];
		if slot then
			slot.RuneSlot.Background:SetAlpha(runePlateAlpha);
			slot.Shadow:SetShown(slotShadow);
			slot.Icon:SetSize(iconSize, iconSize);
			slot:SetSize(slotWidth, slotHeight);
			RefreshSlot(i);
		end
	end

	--Optimize this minimap button's radial offset
	if IsAddOnLoaded("AzeriteUI") then
		MAP_CORNER_RADIUS = 18;
		minimapBackgroundSize = 48;
		--Skin Tooltip
		--Background gets reset once gametooltip is hidden. Ask Goldpaw some day.
		
		local backdropInfo = {
			bgFile = "Interface\\AddOns\\AddOns\\Narcissus\\Art\\Masks\\Full",
			edgeFile = "Interface\\AddOns\\AzeriteUI\\media\\tooltip_border_hex",
			tile = true,
			tileEdge = true,
			tileSize = 24,
			edgeSize = 24,
			insets = { left = 8, right = 8, top = 8, bottom = 8 },
		};
		DefaultTooltip.offsetX = 2;
		DefaultTooltip.offsetY = -12;
		DefaultTooltip:HookScript("OnShow", function(self)
			self:SetBackdrop(backdropInfo);
			self:SetPadding(8, 8, 8, 8);
			self:SetBackdropColor(0, 0, 0, 0.9);
		end)
		
	elseif IsAddOnLoaded("DiabolicUI") then
		MAP_CORNER_RADIUS = 12;
	elseif IsAddOnLoaded("GoldieSix") then
		--GoldpawUI
		MAP_CORNER_RADIUS = 18;
	elseif IsAddOnLoaded("GW2_UI") then
		MAP_CORNER_RADIUS = 44;
	elseif IsAddOnLoaded("SpartanUI") then
		MAP_CORNER_RADIUS = 8;
	else
		MAP_CORNER_RADIUS = 10;
	end

	MinimapButton.Background:SetSize(minimapBackgroundSize, minimapBackgroundSize);	
end

function Narci_GuideLineFrame_OnSizing(self, offset)
	local W;
	local W0, H = WorldFrame:GetSize();
	if (W0 and H) and H ~= 0 then
		self:ClearAllPoints();
		self:SetPoint("TOP", UIParent, "TOP", 0, 0);
		self:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 0);
		local offset = offset or 0;
		W = math.min(H / 9 * 16, W0);
		W = floor(W + 0.5);
		--print("Original: "..W0.." Calculated: "..W);
		self:SetWidth(W - offset);
	else
		W = self:GetWidth();
	end

	local C = W*0.618;

	self.VirtualLineRight:SetPoint("RIGHT", C - W +32, 0);
	self.VirtualLineRight.EndPointBAK = C - W +32;

	local AnimFrame = self.VirtualLineRight.AnimFrame;
	AnimFrame.OppoDirection = false;
	AnimFrame.TimeSinceLastUpdate = 0;

	AnimFrame.AnchorPoint, AnimFrame.relativeTo, AnimFrame.relativePoint, AnimFrame.EndPoint, AnimFrame.EndPointY = AnimFrame:GetParent():GetPoint();
	AnimFrame.EndPointBAK = AnimFrame.EndPoint;
end

function Narci:SetReferenceFrameOffset(offset)
	--A positive offset expands the reference frame.
	Narci_GuideLineFrame_OnSizing(Narci_GuideLineFrame, -offset);
end


NarciRayTracingToggleMixin = {};

function NarciRayTracingToggleMixin:SetVisual(level)
	if level and level > 0 then
		self.Label:SetText("|cffd9d9d9RTX|r ".. level);
		self.Fill:SetWidth(level * 42/3);
		self.Fill:Show();
	else
		self.Label:SetText("|cffd9d9d9RTX|r OFF");
		self.Fill:Hide();
	end
end

function NarciRayTracingToggleMixin:SetLevel(level)
	level = tonumber(level) or 0;
	if level > 3 then
		level = 3;
	end
	self:SetVisual(level);
	SetCVar("shadowrt", level);
end

function NarciRayTracingToggleMixin:Restore()
	if self.oldValue then
		self:SetLevel(self.oldValue);
	end
end

function NarciRayTracingToggleMixin:OnClick()
	self.IsOn = not self.IsOn;
	if self.IsOn then
		self:SetLevel(3);
	else
		self:Restore();
	end
end

function NarciRayTracingToggleMixin:OnShow()
	local level = tonumber(GetCVar("shadowrt"));
	self.oldValue = level;
	self:SetVisual(level);
end

function NarciRayTracingToggleMixin:OnHide()
	self.IsOn = false;
end

function NarciRayTracingToggleMixin:OnEnter()
	self.Fill:SetAlpha(1);
	self.Background:SetAlpha(1);
end

function NarciRayTracingToggleMixin:OnLeave()
	self.Fill:SetAlpha(0.5);
	self.Background:SetAlpha(0.5);
end

function NarciRayTracingToggleMixin:OnLoad()
	local validity;
	if Advanced_RTShadowQualityDropDown then
		validity = true;
	end
	local info = { GetToolTipInfo(1, 4, "shadowrt", 0, 1, 2, 3) };
	for i = 1, #info do
		if info[i] ~= 0 then
			validity = validity and false;
			break;
		end
	end
	
	self.isValid = validity;
	if not validity then
		self:Hide();
		self:Disable();
		TopQualityButton_MSAASlider:SetPoint("TOPLEFT", Narci_XmogButton, "BOTTOMLEFT", 4, -12);
	end

	self:SetScript("OnLoad", nil);
	self.OnLoad = nil;
end

function NarciRayTracingToggleMixin:FadeIn()
	if self.isValid then
		FadeFrame(TopQualityButton_RayTracingToggle, 0.25, 1);
	end
end

function NarciRayTracingToggleMixin:FadeOut()
	if self.isValid then
		FadeFrame(TopQualityButton_RayTracingToggle, 0.25, 0);
	end
end

--[[
	C_BarberShop.GetAvailableCustomizations();
	/run BarberShopFrame:SetPropagateKeyboardInput(true)
	CharCustomizeFrame:SetCustomizationChoice
    hooksecurefunc(CharCustomizeFrame, "SetCustomizationChoice", function(optionID, choiceID) print("Set ",optionID, choiceID) end)
	hooksecurefunc(CharCustomizeFrame, "PreviewCustomizationChoice", function(optionID, choiceID) print("Preview ", optionID, choiceID) end)
	Blizzard_CharacterCustomize
	Blizzard_BarbershopUI

	slotID shoulder ~ 3
	C_Transmog.SetPending(self.transmogLocation, sourceID, self.activeCategory);

	WardrobeCollectionFrame.ItemsCollectionFrame:SelectVisual()
	/run WardrobeCollectionFrame.ItemsCollectionFrame.RightShoulderCheckbox:Show();

	/run GetMouseFocus().transmogLocation = TransmogUtil.GetTransmogLocation(3, 0, 0)	--96875

	New APIs:
	CenterCamera();

	/run CenterCamera();
--]]