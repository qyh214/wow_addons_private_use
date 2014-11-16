TARGETCHARMS_VERSION = GetAddOnMetadata("TargetCharms", "Version");
TARGETCHARMS_DB_VERSION = "1.6.1";

local Defaults =
{ 
	["TargetCharms"] = {	
		["X"] = nil,
		["Y"] = nil,
		["enabled"] = true,
		["partyOnly"] = false,
		["barscale"] = 1.0,
		["Xspacing"] = 0,
		["Yspacing"] = 0,
		["draggable"] = true,
		["toggleicon"] = false,
		["alphaVal"] = 0.5,
		["showontarget"] = true,
		["buttonTemplate"] = ">1>5v6<2v3>7v8<4v_>0",
		},
	["ReadyCharm"] = {
		["X"] = nil,
		["Y"] = nil,
		["enabled"] = true,
		["partyOnly"] = false,
		["barscale"] = 1.0,			
		["draggable"] = true,
		["alphaVal"] = 0.5,
		["width"] = 60,
		["text"] = TARGETCHARMS_READYCHECK_TEXT,
		},
	["FlareCharms"] = {
		["X"] = nil,
		["Y"] = nil,
		["enabled"] = true,
		["partyOnly"] = false,
		["barscale"] = 1.0,			
		["draggable"] = true,
		["alphaVal"] = 0.5,
		["Xspacing"] = 0,
		["Yspacing"] = 0,
		["showicons"] = false,
		["buttonTemplate"] = ">DvW>RvS<BvG>PvY<OV_>X",
		},
	
};
local frameNames = {"TargetCharms","TopCharm","ReadyCharm","TopReady","FlareCharms","TopFlare","TargetCharmsSetup"};
local buttonCharm = {["TargetCharms"]={},["FlareCharms"]={}};
local texturePaths = {"interface\\targetingframe\\UI-RaidTargetingIcons.blp","interface\\buttons\\UI-Quickslot.blp","interface\\buttons\\UI-GroupLoot-Pass-Up.blp","interface\\icons\\ability_hunter_snipershot.blp"};

function TargetCharms_msg(text)
	DEFAULT_CHAT_FRAME:AddMessage(TARGETCHARMS_MSG_TAG..text);
end

function TargetCharms_Command(msg)
	orig_msg = msg
	msg = string.lower(msg)
	a,b,cmd,arg = string.find(msg,"(%S+)%s*(%S*)")	
	if cmd==TargetCharms_CMDS[1] then
		TargetCharms_Reset();
		TargetCharms_msg("Position and Values Reset");
	elseif cmd==TargetCharms_CMDS[2] then
		ShowSetup();
	else
		TargetCharms_msg(TARGETCHARMS_CMD_HELP);
	end
    CheckReadyButtonViewState();
    CheckFrameViewState();
    CheckFlareFrameViewState();
end

function resetTop(frame,offset)
		
end

function TargetCharms_OnLoad(self)
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("PARTY_LEADER_CHANGED");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	SetTargetHideShow();
	SLASH_TargetCharms1 = TARGETCHARMS_SLASH1;
	SLASH_TargetCharms2 = TARGETCHARMS_SLASH2;
	SlashCmdList["TargetCharms"] = TargetCharms_Command;
end

--Code by Grayhoof (SCT)
function CloneTable(t)				-- return a copy of the table t
	local new = {};					-- create a new table
	local i, v = next(t, nil);		-- i is an index of t, v = t[i]
	while i do
		if type(v)=="table" then 
			v=CloneTable(v);
		end 
		new[i] = v;
		i, v = next(t, i);			-- get next index
	end
	return new;
end

function CopyValues(t,f)	
	if(f~=nil) then
		for i=1,5,2 do
			--if ( f[frameNames[i]]~=nil) then
				for key,value in pairs(f[frameNames[i]]) do 
					t[frameNames[i]][key]=value ;
				end
			--end	
		end 
	end
	return t;
end

function CopyOldValues(t,f)
	local temp = CloneTable(t);
	CopyValues(temp,f);
	return temp;
end

function CheckFrameViewState()
	local charmBar = _G[frameNames[2]];
	
	if IsInSetup() then
		if(not charmBar:IsShown()) then
			charmBar:Show();
		end
	else
		if TargetCharms_Options["TargetCharms"]["enabled"] then
			if not TargetCharms_Options["TargetCharms"]["partyOnly"] then
				SetHideShow(frameNames[2]);
			else
				if (((GetNumGroupMembers()>0) and not UnitInRaid("player")) or (UnitInRaid("player") and (UnitIsGroupAssistant("player") or UnitIsGroupLeader("player"))))  then
					SetHideShow(frameNames[2]);
				else
					if(charmBar:IsShown()) then
						charmBar:Hide();
					end               
				end
			end
		elseif(charmBar:IsShown()) then
			charmBar:Hide();
		end
		
	end	
end

function CheckFlareFrameViewState()
    if (not InCombatLockdown()) then
		local charmBar = _G[frameNames[6]];

		if IsInSetup() then
			if(not charmBar:IsShown()) then
				charmBar:Show();
			end
		else
			if TargetCharms_Options[frameNames[5]]["enabled"] then

				if not TargetCharms_Options[frameNames[5]]["partyOnly"] then
					if (not charmBar:IsShown()) then
						charmBar:Show();
					end
				else
					if (((GetNumGroupMembers()>0) and not UnitInRaid("player")) or (UnitInRaid("player") and (UnitIsGroupAssistant("player") or UnitIsGroupLeader("player"))))  then
						if (not charmBar:IsShown()) then
							charmBar:Show();
						end
					else
						if(charmBar:IsShown()) then
							charmBar:Hide();
						end               
					end
				end
			elseif(charmBar:IsShown()) then
				charmBar:Hide();
			end    
		end
    else
		_G[frameNames[1]]:RegisterEvent("PLAYER_REGEN_ENABLED");
    end
end

function CheckReadyButtonViewState()
	charmBar = _G[frameNames[4]];
	charmBar:Show();
	charmBar = _G[frameNames[3]];
	charmBar:Show();

	if IsInSetup() then
		if(not charmBar:IsShown()) then
			charmBar:Show();
		end
	else
		if TargetCharms_Options[frameNames[3]]["enabled"] then
			if not TargetCharms_Options[frameNames[3]]["partyOnly"] then
				if (not charmBar:IsShown()) then
					charmBar:Show();
				end
			else
				if (((GetNumGroupMembers()>0 or UnitInRaid("player")) and (UnitIsGroupAssistant("player") or UnitIsGroupLeader("player")))) then
					if (not charmBar:IsShown()) then
						charmBar:Show();
					end
				else
					if(charmBar:IsShown()) then
						charmBar:Hide();
					end               
				end
			end
		elseif(charmBar:IsShown()) then
			charmBar:Hide();
		end   
		
	end
end

function IsInSetup()
 local TargetCharmsSetup = _G[frameNames[7]];
 if TargetCharmsSetup~=nil then
	if (TargetCharmsSetup:IsShown()) then
		return true;
	end
 end 
 return false;
end

function SetHideShow(frame)
 local charmBar = _G[frame];
 if (TargetCharms_Options[frameNames[1]]["showontarget"]) then
	
	if (UnitExists("target")) then
		if (not charmBar:IsShown()) then
			charmBar:Show();
		end
	else
		if (charmBar:IsShown()) then
			charmBar:Hide();
		end
	end
 else	
	if (not charmBar:IsShown()) then
		charmBar:Show();
	end	
 end
end

function SetTargetHideShow()
	RegisterUnitWatch(_G[frameNames[2]], true) 
end

function TargetCharms_OnEvent(self, event)
	if event=="VARIABLES_LOADED" then	
		if TargetCharms_OptionsGlobal == nil or TARGETCHARMS_DB_VERSION ~= TargetCharms_OptionsGlobal["Version"] then
			TargetCharms_OptionsGlobal = CopyOldValues(Defaults,Defaults);
			TargetCharms_OptionsGlobal["Version"] = TARGETCHARMS_DB_VERSION;
			TargetCharms_OptionsGlobal["Name"] = UnitName("player");
			TargetCharms_Options = CopyOldValues(TargetCharms_OptionsGlobal, TargetCharms_OptionsGlobal);
		end
		if TargetCharms_Options == nil or TARGETCHARMS_DB_VERSION ~= TargetCharms_Options["Version"] then
			TargetCharms_Options = CopyOldValues(TargetCharms_OptionsGlobal,TargetCharms_Options);
			CopyValues(TargetCharms_Options,TargetCharms_OptionsGlobal);
			TargetCharms_Options["Version"] = TARGETCHARMS_DB_VERSION;			
		end
		
		SetupTargetCharms();

		local panel = CreateFrame( "Frame", "TargetCharmsPanel", UIParent, "TargetCharmsPanelTemplate");

		panel.name = "TargetCharms" ;
		panel.okay = function (self) TargetCharmsInterface_Close(); end;
		panel.cancel = function (self)  TargetCharmsPanel_CancelOrLoad();  end;
		panel.refresh = function (self)  TargetCharmsPanel_OnShow();  end;
		panel.default = function (self)  TargetCharms_Reset();  end;
	    	InterfaceOptions_AddCategory(panel);
		panel:Hide()

		TargetCharms_msg(TARGETCHARMS_VERSION.." - "..TARGETCHARMS_LOADED);
	end
	if event~= "PLAYER_TARGET_CHANGED" then
		CheckReadyButtonViewState();
		CheckFlareFrameViewState();
		if event=="PLAYER_REGEN_ENABLED" then
			_G[frameNames[1]]:UnregisterEvent("PLAYER_REGEN_ENABLED");
			--LockFlares();
		end
	end
	CheckFrameViewState();
	
end

function SetupTargetCharms()
	SetupFrames();		
	SetupButtons(frameNames[1],frameNames[1]);	
	SetupButtons(frameNames[5],frameNames[5]);	
	SetUpReadyButton();
end

function TargetCharms_Reset()
		TargetCharms_Options =  CopyValues(CloneTable(Defaults),Defaults);
		TargetCharms_Options["Name"] = UnitName("player");
		local tmpFrame = _G[frameNames[1]];
		tmpFrame:SetScale(TargetCharms_Options[frameNames[1]]["barscale"]);
		tmpFrame:SetPoint("TOPLEFT", 0, 0);
		tmpFrame = _G[frameNames[2]];
		tmpFrame:ClearAllPoints() 
		tmpFrame:SetPoint("TOPLEFT", _G["UIParent"],"TOP", 0, -20);
		tmpFrame:SetAlpha(TargetCharms_Options[frameNames[1]]["alphaVal"]);
		tmpFrame = _G[frameNames[4]];
		tmpFrame:SetAlpha(1);
		tmpFrame:SetScale(1);
		tmpFrame:ClearAllPoints();
		tmpFrame:SetPoint("TOPLEFT",_G["UIParent"],"TOP", 0, 0);
		tmpFrame = _G[frameNames[3]];
		tmpFrame:SetAlpha(TargetCharms_Options[frameNames[3]]["alphaVal"]);
		tmpFrame:SetScale(1);
		tmpFrame:ClearAllPoints();
		tmpFrame:SetPoint("TOPLEFT", 0, 0);
		tmpFrame:SetWidth(TargetCharms_Options[frameNames[3]]["width"]);
		tmpFrame = _G[frameNames[4]];
		tmpFrame:SetWidth(TargetCharms_Options[frameNames[3]]["width"]);
		tmpFrame = _G[frameNames[5]];
		tmpFrame:SetScale(TargetCharms_Options[frameNames[5]]["barscale"]);
		tmpFrame:SetPoint("TOPLEFT", 0, 0);
		tmpFrame = _G[frameNames[6]];
		tmpFrame:ClearAllPoints() 
		tmpFrame:SetPoint("TOPLEFT", _G["UIParent"],"TOP", 100,0);
		tmpFrame:SetAlpha(TargetCharms_Options[frameNames[5]]["alphaVal"]);
		tmpFrame = _G[frameNames[7]];
		if (tmpFrame~=nil) then
			tmpFrame:ClearAllPoints();
			tmpFrame:SetPoint("CENTER", offset, 0);	
		end
		UpdateGlobal();
end

function SetupFrames()
	local tmpFrame = _G[frameNames[1]];
	if (TargetCharms_Options[frameNames[1]]["X"]~=nil) then
		_G[frameNames[2]]:ClearAllPoints() 
		_G[frameNames[2]]:SetPoint("BOTTOMLEFT",TargetCharms_Options[frameNames[1]]["X"], TargetCharms_Options[frameNames[1]]["Y"]);
	else
		_G[frameNames[2]]:ClearAllPoints() 
		_G[frameNames[2]]:SetPoint("TOPLEFT", _G["UIParent"],"TOP", 0, -20);
	end
	tmpFrame:SetScale(TargetCharms_Options[frameNames[1]]["barscale"]);
	tmpFrame = _G[frameNames[2]];
	tmpFrame:SetAlpha(TargetCharms_Options[frameNames[1]]["alphaVal"]);
	tmpFrame = _G[frameNames[5]];
	if (TargetCharms_Options[frameNames[5]]["X"]~=nil) then
		_G[frameNames[6]]:ClearAllPoints();
		_G[frameNames[6]]:SetPoint("BOTTOMLEFT",  TargetCharms_Options[frameNames[5]]["X"], TargetCharms_Options[frameNames[5]]["Y"]);	
	else
		_G[frameNames[6]]:ClearAllPoints() 
		_G[frameNames[6]]:SetPoint("TOPLEFT", _G["UIParent"],"TOP", 100,0);
	end
	tmpFrame:SetScale(TargetCharms_Options[frameNames[5]]["barscale"]);
	tmpFrame = _G[frameNames[6]];
	tmpFrame:SetAlpha(TargetCharms_Options[frameNames[5]]["alphaVal"]);
end

function SetUpReadyButton()
	local tmpFrame = _G[frameNames[4]];
	if (TargetCharms_Options[frameNames[3]]["X"]~=nil) then
		_G[frameNames[4]]:ClearAllPoints();
		_G[frameNames[4]]:SetPoint("BOTTOMLEFT",  TargetCharms_Options[frameNames[3]]["X"], TargetCharms_Options[frameNames[3]]["Y"]);
	else
		_G[frameNames[4]]:ClearAllPoints();
		_G[frameNames[4]]:SetPoint("TOPLEFT",_G["UIParent"],"TOP", 0, 0);
	end
	tmpFrame:SetAlpha(TargetCharms_Options[frameNames[3]]["alphaVal"]);
	tmpFrame:SetScale(TargetCharms_Options[frameNames[3]]["barscale"]);
	tmpFrame:SetWidth(TargetCharms_Options[frameNames[3]]["width"]);
	tmpFrame = _G[frameNames[3]];
	tmpFrame:SetWidth(TargetCharms_Options[frameNames[3]]["width"]);
	tmpFrame:SetText(TargetCharms_Options[frameNames[3]]["text"]);
end

function UpdateLocation(frameId, x, y)
	local frame = frameNames[frameId];
	TargetCharms_Options[frame]["X"] = x;
	TargetCharms_Options[frame]["Y"] = y;
	if TargetCharms_OptionsGlobal["Name"]== UnitName("player") then
		TargetCharms_OptionsGlobal[frame]["X"] = TargetCharms_Options[frame]["X"];
		TargetCharms_OptionsGlobal[frame]["Y"] = TargetCharms_Options[frame]["Y"];
	end
end

function MakeButton(frame, buttonNum, isMacro)
	local button = _G[frame.."Charm"..buttonNum];
	local template = "CharmTemplate";
	if isMacro then 
		template = "SecureCharmTemplate";
	end
	if button == nil then
		button = CreateFrame("Button", frame.."Charm"..buttonNum, _G[frame], template) 
		button:RegisterForClicks("AnyDown");
		button:SetID(buttonNum);
		button:SetHeight(32);
		button:SetWidth(32);
		local texture = button:CreateTexture(button:GetName().."CharmTex");
		if isMacro then
			button:SetAttribute("type", "macro")
			button:SetHeight(32);
			button:SetWidth(32);
			local textureColor = button:CreateTexture(button:GetName().."TextureColor");
			textureColor:SetPoint("TOPLEFT", button,"TOPLEFT", 4, -4);
			textureColor:SetPoint("BOTTOMRIGHT", button,"BOTTOMRIGHT", -4.5, 4.5);
			local textureIcon = button:CreateTexture(button:GetName().."TextureIcon");
			textureColor:SetPoint("TOPLEFT", button,"TOPLEFT", 4, -4)
			textureColor:SetPoint("BOTTOMRIGHT", button,"BOTTOMRIGHT", -4.5, 4.5)
		end
	end
	return button;
end

function SetupButtons(frameInfo,frameTarget)
	local buttonString = TargetCharms_Options[frameInfo]["buttonTemplate"];
	local maxlen = strlen(buttonString);
	if mod(maxlen,2) == 1 then
		maxlen=maxlen-1
	end
	local buttonNum=1;
	if maxlen > 40 then
		maxlen = 40;
	end
	
	local t
	for t=1,maxlen,2 do
		FormatButton(frameTarget, buttonNum, strsub(buttonString,t,t), strsub(buttonString,t+1,t+1),TargetCharms_Options[frameInfo]["Xspacing"],TargetCharms_Options[frameInfo]["Yspacing"]);
		buttonNum=buttonNum+1;
	end

	for t=buttonNum,20 do
		local button = _G[frameTarget.."Charm"..buttonNum];
		if button ~= nil then 
			button:Hide();
		end
	end
end 

function FormatButton(frame, buttonNum ,posChar, typeNum, xSpacing, ySpacing)
	
	if frame == frameNames[1] then
		if typeNum == TARGETCHARMS_CHARM0 then
			button = MakeButton(frame, buttonNum, false);
			MakeCharm(frame,button,buttonNum,0,2,0.15,0.85,0.15,0.85,0,0,32,32);
			button:Show();
		elseif typeNum == TARGETCHARMS_CHARM1 then
			button = MakeButton(frame, buttonNum, false);
			MakeCharm(frame,button,buttonNum,1,1,0,0.25,0,0.25,2,-2,28,28);
			button:Show();
		elseif typeNum == TARGETCHARMS_CHARM2 then
			button = MakeButton(frame, buttonNum, false);
			MakeCharm(frame,button,buttonNum,2,1,0.25,0.5,0,0.25,2,-2,28,28);
			button:Show();
		elseif typeNum == TARGETCHARMS_CHARM3 then
			button = MakeButton(frame, buttonNum, false);
			MakeCharm(frame,button,buttonNum,3,1,0.5,0.75,0,0.25,2,-2,28,28);
			button:Show();
		elseif typeNum == TARGETCHARMS_CHARM4 then
			button = MakeButton(frame, buttonNum, false);
			MakeCharm(frame,button,buttonNum,4,1,0.75,1,0,0.25,2,-2,28,28);
			button:Show();
		elseif typeNum == TARGETCHARMS_CHARM5 then
			button = MakeButton(frame, buttonNum, false);
			MakeCharm(frame,button,buttonNum,5,1,0,0.25,0.25,0.5,2,-2,28,28);
			button:Show();
		elseif typeNum == TARGETCHARMS_CHARM6 then
			button = MakeButton(frame, buttonNum, false);
			MakeCharm(frame,button,buttonNum,6,1,0.25,0.5,0.25,0.5,2,-2,28,28);
			button:Show();
		elseif typeNum == TARGETCHARMS_CHARM7 then
			button = MakeButton(frame, buttonNum, false);
			MakeCharm(frame,button,buttonNum,7,1,0.5,0.75,0.25,0.5,2,-2,28,28);
			button:Show();
		elseif typeNum == TARGETCHARMS_CHARM8 then
			button = MakeButton(frame, buttonNum, false);
			MakeCharm(frame,button,buttonNum,8,1,0.75,1,0.25,0.5,2,-2,28,28);
			button:Show();
		elseif typeNum == TARGETCHARMS_CHARM9 then
			button = MakeButton(frame, buttonNum, false);
			MakeCharm(frame,button,buttonNum,9,4,0,1,0,1,0,0,32,32);
			button:Show();
		else
			button = MakeButton(frame, buttonNum, false);
			button:Hide();
		end
	else
		if typeNum == TARGETCHARMS_DRAG then
			button = _G[frame.."Charm"..buttonNum];
			if button == nil then
				button = CreateFrame("Button", frame.."Charm"..buttonNum, _G[frame], "DragCharmTemplate") 
			end
			button:SetID(buttonNum);
			if TargetCharms_Options["FlareCharms"]["draggable"] then
				button:RegisterForClicks("AnyDown");
				button:Show();
			else
				button:Hide();
			end
		elseif typeNum == TARGETCHARMS_BLUEFLARE then
			button = MakeButton(frame, buttonNum, true);
			MakeCharm(frame,button,buttonNum,1, 2,0.15,0.85,0.15,0.85,0,0,32,32);
			if TargetCharms_Options[frameNames[5]]["showicons"] then
				SetTexture(button, _G[button:GetName().."TextureIcon"],1,0.25,0.5,0.25,0.5,6,-5,20,20);
			else
				_G[button:GetName().."TextureIcon"]:SetTexture();
			end
			local textureColor = _G[button:GetName().."TextureColor"];
			textureColor:SetTexture(0,.5,1);
			button:SetAttribute("macrotext", "/cwm 1\n/wm 1");	
			button:Show();
		elseif typeNum == TARGETCHARMS_GREENFLARE then
			button = MakeButton(frame, buttonNum, true);
			MakeCharm(frame,button,buttonNum,2,2,0.15,0.85,0.15,0.85,0,0,32,32);
			if TargetCharms_Options[frameNames[5]]["showicons"] then
				SetTexture(button, _G[button:GetName().."TextureIcon"],1,0.75,1,0,0.25,6,-5,20,20);
			else
				_G[button:GetName().."TextureIcon"]:SetTexture();
			end
			local textureColor = _G[button:GetName().."TextureColor"];
			textureColor:SetTexture(0,1,.2);
			button:SetAttribute("macrotext", "/cwm 2\n/wm 2");
			button:Show();
		elseif typeNum == TARGETCHARMS_PURPLEFLARE then
			button = MakeButton(frame, buttonNum, true);
			MakeCharm(frame,button,buttonNum,3,2,0.15,0.85,0.15,0.85,0,0,32,32);
			if TargetCharms_Options[frameNames[5]]["showicons"] then
				SetTexture(button, _G[button:GetName().."TextureIcon"],1,0.5,0.75,0,0.25,6,-5,20,20);
			else
				_G[button:GetName().."TextureIcon"]:SetTexture();
			end
			local textureColor = _G[button:GetName().."TextureColor"];
			textureColor:SetTexture(.5,0,1);
			button:SetAttribute("macrotext", "/cwm 3\n/wm 3");
			button:Show();
		elseif typeNum == TARGETCHARMS_REDFLARE then
			button = MakeButton(frame, buttonNum, true);
			MakeCharm(frame,button,buttonNum,4,2,0.15,0.85,0.15,0.85,0,0,32,32);
			if TargetCharms_Options[frameNames[5]]["showicons"] then
				SetTexture(button, _G[button:GetName().."TextureIcon"],1,0.5,0.75,0.25,0.5,6,-5,20,20);
			else
				_G[button:GetName().."TextureIcon"]:SetTexture();
			end
			local textureColor = _G[button:GetName().."TextureColor"];
			textureColor:SetTexture(1,0,0);
			button:SetAttribute("macrotext", "/cwm 4\n/wm 4");
			button:Show();
		elseif typeNum == TARGETCHARMS_YELLOWFLARE then
			button = MakeButton(frame, buttonNum, true);
			MakeCharm(frame,button,buttonNum,5,2,0.15,0.85,0.15,0.85,0,0,32,32);
			if TargetCharms_Options[frameNames[5]]["showicons"] then
				SetTexture(button, _G[button:GetName().."TextureIcon"],1,0,0.25,0,0.25,6,-5,20,20);
			else
				_G[button:GetName().."TextureIcon"]:SetTexture();
			end
			local textureColor = _G[button:GetName().."TextureColor"];
			textureColor:SetTexture(1,1,0);
			button:SetAttribute("macrotext", "/cwm 5\n/wm 5");			
			button:Show();
		elseif typeNum == TARGETCHARMS_ORANGEFLARE then
			button = MakeButton(frame, buttonNum, true);
			MakeCharm(frame,button,buttonNum,6,2,0.15,0.85,0.15,0.85,0,0,32,32);
			if TargetCharms_Options[frameNames[5]]["showicons"] then
				SetTexture(button, _G[button:GetName().."TextureIcon"],1,0.25,0.5,0,0.25,6,-5,20,20);
			else
				_G[button:GetName().."TextureIcon"]:SetTexture();
			end
			local textureColor = _G[button:GetName().."TextureColor"];
			textureColor:SetTexture(1,.5,0);
			button:SetAttribute("macrotext", "/cwm 6\n/wm 6");	
			button:Show();
		elseif typeNum == TARGETCHARMS_SILVERFLARE then
			button = MakeButton(frame, buttonNum, true);
			MakeCharm(frame,button,buttonNum,7,2,0.15,0.85,0.15,0.85,0,0,32,32);
			if TargetCharms_Options[frameNames[5]]["showicons"] then
				SetTexture(button, _G[button:GetName().."TextureIcon"],1,0,0.25,0.25,0.5,6,-5,20,20);
			else
				_G[button:GetName().."TextureIcon"]:SetTexture();
			end
			local textureColor = _G[button:GetName().."TextureColor"];
			textureColor:SetTexture(.5,.5,.5);
			button:SetAttribute("macrotext", "/cwm 7\n/wm 7");
			button:Show();
		elseif typeNum == TARGETCHARMS_WHITEFLARE then
			button = MakeButton(frame, buttonNum, true);
			MakeCharm(frame,button,buttonNum,8,2,0.15,0.85,0.15,0.85,0,0,32,32);
			if TargetCharms_Options[frameNames[5]]["showicons"] then
				SetTexture(button, _G[button:GetName().."TextureIcon"],1,0.75,1,0.25,0.5,6,-5,20,20);
			else
				_G[button:GetName().."TextureIcon"]:SetTexture();
			end
			local textureColor = _G[button:GetName().."TextureColor"];
			textureColor:SetTexture(1,1,1);
			button:SetAttribute("macrotext", "/cwm 8\n/wm 8");		
			button:Show();
		elseif typeNum == TARGETCHARMS_CLEARFLARE then
			button = MakeButton(frame, buttonNum, true);
			MakeCharm(frame,button,buttonNum,0,2,0.15,0.85,0.15,0.85,0,0,32,32);
			SetTexture(button, _G[button:GetName().."TextureIcon"],3,0,1,0,1,3,-2,26,26);
			_G[button:GetName().."TextureColor"]:SetTexture();
			button:SetAttribute("macrotext", "/cwm 0");
			button:Show();
		else
			button = MakeButton(frame, buttonNum, true);
			button:Hide();
		end
	end
	if button ~= nil then
		button:ClearAllPoints();
		if strlower(posChar) == TARGETCHARMS_POSITION_DOWN then
			button:SetPoint("TOPLEFT", _G[frame.."Charm"..tostring(buttonNum-1)],"BOTTOMLEFT",0,0-ySpacing);
		elseif posChar == TARGETCHARMS_POSITION_UP then
			button:SetPoint("BOTTOMLEFT", _G[frame.."Charm"..tostring(buttonNum-1)],"TOPLEFT",0,0+ySpacing);
		elseif posChar == TARGETCHARMS_POSITION_RIGHT then
			button:SetPoint("TOPLEFT", _G[frame.."Charm"..tostring(buttonNum-1)],"TOPRIGHT",0+xSpacing,0);
		elseif posChar == TARGETCHARMS_POSITION_LEFT then
			button:SetPoint("TOPRIGHT", _G[frame.."Charm"..tostring(buttonNum-1)],"TOPLEFT",0-xSpacing,0);
		else
			--ERROR--
			button:SetPoint("TOPLEFT", _G[frame.."Charm"..tostring(buttonNum-1)],"TOPRIGHT",0,0-ySpacing);
			buttonCharm[frame][buttonNum] = 0;
			button:Hide();
			print(TARGETCHARMS_ERROR_INVALIDCHAR); 
			return false;
		end
	end
	return true;
end

function MakeCharm(frame, button, buttonNum, id, textureID, o1,o2,o3,o4,a1,a2,w,h)
	buttonCharm[frame][buttonNum] = id;
	local texture = _G[button:GetName().."CharmTex"];
	SetTexture(button, texture, textureID, o1,o2,o3,o4,a1,a2,w,h);
end

function SetTexture(button, texture, textureID, o1,o2,o3,o4,a1,a2,w,h)
	texture:SetPoint("TOPLEFT", button,"TOPLEFT",a1,a2);
	texture:SetWidth(w);
	texture:SetHeight(h);
	texture:SetTexture(texturePaths[textureID]);
	texture:SetTexCoord(o1,o2,o3,o4)
end

function SelectTarget(frame, targetId, btn, name)
	local charmId = buttonCharm[frame][tonumber(targetId)];
	if (frame == frameNames[1]) then	
		if (not TargetCharms_Options[frameNames[1]]["toggleicon"]) then
			if (GetRaidTargetIndex("target")~=charmId) then
				SetRaidTarget("target", charmId)
			end
		else
			SetRaidTargetIcon("target", charmId)
		end
	else
		if charmId~=0 then
			PlaceRaidMarker(charmId)
		else
			ClearRaidMarker()
		end
	end

end

function SetFrameScale(scale,id)
	local tmpFrame = _G[frameNames[id]];
	tmpFrame:SetScale(scale);
end

function MoveFlares()
	local frame = _G[frameNames[5]];
	frame:EnableMouse(true);
	_G[frameNames[5].."_Tex"]:SetTexture(0,1,0);
	_G[frameNames[5].."Text"]:SetText(TARGETCHARMS_OPTIONS_FLARE_MOVE_TEXT);

	for buttonNum=1,20 do
		local button = _G[frameNames[5].."Charm"..buttonNum];
		if button ~= nil then 
			button:Hide();
		end
	end
	
	local frame = _G["FlareMoveButton"];
	frame:SetText(TARGETCHARMS_OPTIONS_FLARE_LOCK_BUTTON);
end

function LockFlares()
	if (not InCombatLockdown()) then
		local frame = _G[frameNames[5]];
		frame:EnableMouse(false);
		_G[frameNames[5].."_Tex"]:SetTexture();
		_G[frameNames[5].."Text"]:SetText();

		local button = _G["FlareMoveButton"];
		if button~=nil then
			button:SetText(TARGETCHARMS_OPTIONS_FLARE_MOVE_BUTTON);
		end
		SetupButtons(frameNames[5],frameNames[5]);
	end
end

function ShowSetup()
	--InterfaceOptionsFrame_OpenToCategory("TargetCharms");
	local setupFrame = _G[frameNames[7]];
	if setupFrame == nil then
		setupFrame = CreateFrame("Frame",frameNames[7],UIParent,"TargetCharmsSetupTemplate");
		for i,v in ipairs(TargetCharms_LayoutDefaults) do 
			button = CreateFrame("Button", "ButtonPresetOptions"..i, setupFrame , "PresetOptionsTemplate");
			button:SetID(i);
			_G[button:GetName().."Text"]:SetText(i);
			button:SetPoint("TOP", setupFrame,"TOP",(setupFrame:GetLeft() - button:GetLeft() + 22 * i),button:GetTop()- setupFrame:GetTop());	

		end
		for i,v in ipairs(Flare_LayoutDefaults) do 
			button = CreateFrame("Button", "ButtonFlarePresetOptions"..i, setupFrame , "FlarePresetOptionsTemplate");
			button:SetID(i);
			_G[button:GetName().."Text"]:SetText(i);
			button:SetPoint("TOP", setupFrame,"TOP",(setupFrame:GetLeft() - button:GetLeft()  + 22 * i),button:GetTop()- setupFrame:GetTop());			
		end
	end
	setupFrame:Show();
	CheckFrameViewState(); 
	CheckReadyButtonViewState();
	CheckFlareFrameViewState();
end

function HideSetup()
	local setupFrame = _G[frameNames[7]];
	if setupFrame ~= nil then
		setupFrame:Hide();
	end
	UpdateGlobal();	
end

function TargetCharmsPanel_Close()
end

function TargetCharmsPanel_CancelOrLoad()
end

function TargetCharmsPanel_OnShow()
end
function CopySetup()
	HideSetup();
	TargetCharms_Options = CopyOldValues(CloneTable(TargetCharms_OptionsGlobal),TargetCharms_OptionsGlobal);
	SetupTargetCharms();
	ShowSetup();
end
function UpdateGlobal()
	if TargetCharms_OptionsGlobal["Name"]== UnitName("player") then
		TargetCharms_OptionsGlobal = CopyOldValues(CloneTable(TargetCharms_OptionsGlobal),TargetCharms_Options);
	end
end 