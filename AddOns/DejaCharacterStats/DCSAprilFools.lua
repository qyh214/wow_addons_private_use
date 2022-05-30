local ADDON_NAME, namespace = ... 	--localization
local L = namespace.L 				--localization
local _, gdbprivate = ...
local weekday, month, day, year
local collapse = 0
local ResFrostFS
local ResFireFS
local ResNatureFS
local ResArcaneFS
local ResShadowFS
local StatNameFS
local StatValueFS
local DCS_AF_AmmoItemFrameFS
	
local function DCSAFFrameTexture(frame)
	if frame.texture then
		return
	else
		texture = frame:CreateTexture(nil,"BACKGROUND")
		texture:SetTexture("Interface\\FrameGeneral\\UI-Background-Marble.blp")
		texture:SetPoint("TOPLEFT", frame, 4, -4);
		texture:SetPoint("BOTTOMRIGHT", frame, -4, 4);
		frame.texture = texture
	end
end

if (LOCALE_koKR) then
	DCS_FONT_SIZE = 11
	DCS_STANDARD_TEXT_FONT = "Fonts\\2002.TTF";
	DCS_UNIT_NAME_FONT = "Fonts\\2002B.TTF";
	DCS_DAMAGE_TEXT_FONT = "Fonts\\K_Damage.TTF";
elseif (LOCALE_zhCN) then
	DCS_FONT_SIZE = 14
	DCS_STANDARD_TEXT_FONT = "Fonts\\ARKai_T.ttf";
	DCS_UNIT_NAME_FONT = "Fonts\\ARKai_T.ttf";
	DCS_DAMAGE_TEXT_FONT = "Fonts\\ARKai_C.ttf";
elseif (LOCALE_zhTW) then
	DCS_FONT_SIZE = 16
	DCS_STANDARD_TEXT_FONT = "Fonts\\blei00d.TTF";
	DCS_UNIT_NAME_FONT = "Fonts\\blei00d.TTF";
	DCS_DAMAGE_TEXT_FONT = "Fonts\\bKAI00M.TTF";
elseif (LOCALE_ruRU) then
	DCS_FONT_SIZE = 11
	DCS_STANDARD_TEXT_FONT = "Fonts\\FRIZQT___CYR.TTF";
	DCS_UNIT_NAME_FONT = "Fonts\\FRIZQT___CYR.TTF";
	DCS_DAMAGE_TEXT_FONT = "Fonts\\FRIZQT___CYR.TTF";
else
	DCS_FONT_SIZE = 11
	DCS_STANDARD_TEXT_FONT = "Fonts\\FRIZQT__.TTF";
	DCS_UNIT_NAME_FONT = "Fonts\\FRIZQT__.TTF";
	DCS_DAMAGE_TEXT_FONT = "Fonts\\FRIZQT__.TTF";
end

local function AFSetupFrames()
	CharacterModelFrame:SetHeight(230)
	CharacterModelFrame:SetPoint("TOP", CharacterFrameInset, "TOP", 0, 300);
	
	local CMFtexture = CharacterModelFrame:CreateTexture(nil,"LOW")
	CMFtexture:SetPoint("TOPLEFT", CharacterModelFrame, 0, 0);
	CMFtexture:SetPoint("BOTTOMRIGHT", CharacterModelFrame, 0, -120);
	CMFtexture:SetTexture("Interface\\FrameGeneral\\UI-Background-Marble.blp")
	CharacterModelFrame.CMFtexture = CMFtexture
	
	local DCSAFLeftframe = CreateFrame("Frame", "DCSAFLeftframe", CharacterModelFrame, "OptionsBoxTemplate")
	DCSAFLeftframe:ClearAllPoints()
	DCSAFLeftframe:SetWidth(116)
	DCSAFLeftframe:SetHeight(86)
	DCSAFLeftframe:SetPoint("TOPRIGHT", CharacterModelFrame, "BOTTOM", 1, 18)
	DCSAFLeftframe:Show()
	DCSAFFrameTexture(DCSAFLeftframe)
	
	local DCSAFBottomRightframe = CreateFrame("Frame", "DCSAFBottomRightframe", CharacterModelFrame, "OptionsBoxTemplate")
	DCSAFBottomRightframe:ClearAllPoints()
	DCSAFBottomRightframe:SetWidth(116)
	DCSAFBottomRightframe:SetHeight(44)
	DCSAFBottomRightframe:SetPoint("TOPLEFT", CharacterModelFrame, "BOTTOM", -1, -24)
	DCSAFBottomRightframe:Show()
	DCSAFFrameTexture(DCSAFBottomRightframe)
	
	local DCSAFTopRightframe = CreateFrame("Frame", "DCSAFTopRightframe", CharacterModelFrame, "OptionsBoxTemplate")
	DCSAFTopRightframe:ClearAllPoints()
	DCSAFTopRightframe:SetWidth(116)
	DCSAFTopRightframe:SetHeight(45)
	DCSAFTopRightframe:SetPoint("TOPLEFT", CharacterModelFrame, "BOTTOM", -1, 18)
	DCSAFTopRightframe:Show()
	DCSAFFrameTexture(DCSAFTopRightframe)
	
	CharacterMainHandSlot:ClearAllPoints()
	CharacterMainHandSlot:SetPoint("TOP", DCSAFLeftframe, "BOTTOM", 15, -6);
	
	local DCS_AF_RangedItemFrame = CreateFrame("Frame", "DCS_AF_RangedItemFrame", CharacterModelFrame)
	DCS_AF_RangedItemFrame:SetWidth(36)
	DCS_AF_RangedItemFrame:SetHeight(36)
	DCS_AF_RangedItemFrame:SetPoint("TOPLEFT", CharacterSecondaryHandSlot, "TOPRIGHT", 4, 0);
	DCS_AF_RangedItemFrame:Show()
	
	-- local DCS_AF_RangedItemFrameTexture = DCS_AF_RangedItemFrame:CreateTexture(nil,"ARTWORK") --Debugging texture
	-- 	DCS_AF_RangedItemFrameTexture:SetAllPoints(DCS_AF_RangedItemFrame)
	-- 	DCS_AF_RangedItemFrameTexture:SetColorTexture(1, 1, 1, 1)
	
	local DCS_AF_RangedItemFrameOutlineTexture = DCS_AF_RangedItemFrame:CreateTexture(nil,"ARTWORK",nil,-7)
	DCS_AF_RangedItemFrameOutlineTexture:SetPoint("TOPLEFT", DCS_AF_RangedItemFrame, "TOPLEFT", 0, 0);
	DCS_AF_RangedItemFrameOutlineTexture:SetPoint("BOTTOMRIGHT", DCS_AF_RangedItemFrame, "BOTTOMRIGHT", 2, -1);
	
	local DCS_AF_RangedItemFramehighlightTexture = DCS_AF_RangedItemFrame:CreateTexture(nil, "HIGHLIGHT",nil,-7)
	DCS_AF_RangedItemFramehighlightTexture:SetPoint("TOPLEFT", DCS_AF_RangedItemFrame, "TOPLEFT", -1, 1);
	DCS_AF_RangedItemFramehighlightTexture:SetPoint("BOTTOMRIGHT", DCS_AF_RangedItemFrame, "BOTTOMRIGHT", 3, -2);
	
	local DCS_AF_RangedItemIconFrametexture = CharacterSecondaryHandSlot:CreateTexture(nil,"TOOLTIP",nil,-6)
	DCS_AF_RangedItemIconFrametexture:SetPoint("TOPLEFT", CharacterSecondaryHandSlot, "TOPRIGHT", 7, -2);
	DCS_AF_RangedItemIconFrametexture:SetWidth(32)
	DCS_AF_RangedItemIconFrametexture:SetHeight(32)
	CharacterSecondaryHandSlot.DCS_AF_RangedItemIconFrametexture = DCS_AF_RangedItemIconFrametexture
	
	local DCS_AF_AmmoItemFrame = CreateFrame("Frame", "DCS_AF_AmmoItemFrame", DCSAFBottomRightframe)
	DCS_AF_AmmoItemFrame:SetWidth(28)
	DCS_AF_AmmoItemFrame:SetHeight(28)
	DCS_AF_AmmoItemFrame:SetPoint("TOPRIGHT", DCSAFBottomRightframe, "BOTTOMRIGHT", -13, -11);
	DCS_AF_AmmoItemFrame:Show()
	
	-- local DCS_AF_AmmoItemFrameTexture = DCS_AF_AmmoItemFrame:CreateTexture(nil,"ARTWORK") --Debugging texture
	-- 	DCS_AF_AmmoItemFrameTexture:SetAllPoints(DCS_AF_AmmoItemFrame)
	-- 	DCS_AF_AmmoItemFrameTexture:SetColorTexture(1, 1, 1, 1)
	
	local DCS_AF_AmmoItemFrameOutlineTexture = DCS_AF_AmmoItemFrame:CreateTexture(nil,"ARTWORK",nil,-7)
	DCS_AF_AmmoItemFrameOutlineTexture:SetAllPoints(DCS_AF_AmmoItemFrame)
	-- DCS_AF_AmmoItemFrameOutlineTexture:SetPoint("TOPLEFT", DCS_AF_AmmoItemFrame, "TOPLEFT", 0, 0);
	-- DCS_AF_AmmoItemFrameOutlineTexture:SetPoint("BOTTOMRIGHT", DCS_AF_AmmoItemFrame, "BOTTOMRIGHT", 2, -1);
	
	local DCS_AF_AmmoItemFramehighlightTexture = DCS_AF_AmmoItemFrame:CreateTexture(nil, "HIGHLIGHT",nil,-7)
	DCS_AF_AmmoItemFramehighlightTexture:SetPoint("TOPLEFT", DCS_AF_AmmoItemFrame, "TOPLEFT", -1, 1);
	DCS_AF_AmmoItemFramehighlightTexture:SetPoint("BOTTOMRIGHT", DCS_AF_AmmoItemFrame, "BOTTOMRIGHT", 1, -1);
	
	local DCS_AF_AmmoItemIconFrametexture = DCS_AF_AmmoItemFrame:CreateTexture(nil,"TOOLTIP",nil,-6)
	DCS_AF_AmmoItemIconFrametexture:SetPoint("CENTER", DCS_AF_AmmoItemFrame, "CENTER", 0, 0);
	DCS_AF_AmmoItemIconFrametexture:SetWidth(26)
	DCS_AF_AmmoItemIconFrametexture:SetHeight(26)
	DCS_AF_AmmoItemFrame.DCS_AF_AmmoItemIconFrametexture = DCS_AF_AmmoItemIconFrametexture
	
	local DCS_AF_AmmoItemFrameFS = DCS_AF_AmmoItemFrame:CreateFontString("FontString","OVERLAY","GameTooltipText")
	DCS_AF_AmmoItemFrameFS:SetPoint("BOTTOM",DCS_AF_AmmoItemFrame,"BOTTOM",2,3) 
	DCS_AF_AmmoItemFrameFS:SetFont(DCS_STANDARD_TEXT_FONT, DCS_FONT_SIZE, "THINOUTLINE")
	DCS_AF_AmmoItemFrameFS:SetJustifyH("CENTER")
	DCS_AF_AmmoItemFrameFS:SetFormattedText("")

	local function DCS_AF_EgansBlasterItemFrame_OnEnter(self)
		GameTooltip:SetOwner(DCS_AF_RangedItemFrame, "ANCHOR_RIGHT");
		GameTooltip:SetText("Egan's Blaster", 1, 1, 1, 1, true)
		GameTooltip:AddLine("Quest Item", 1, 1, 1, true)
		GameTooltip:AddLine("Unique", 1, 1, 1, true)
		GameTooltip:AddLine("Use: Use to free Spectral and Ghostly Citizens.", 0, 255, 0, true)
		GameTooltip:Show()
	end
	
	local function DCS_AF_EgansBlasterItemFrame_OnLeave(self)
		GameTooltip_Hide()
	end
	
	local function DCS_AF_RhokdelarItemFrame_OnEnter(self)
		GameTooltip:SetOwner(DCS_AF_RangedItemFrame, "ANCHOR_RIGHT");
		GameTooltip:SetText("Rhok'delar, Longbow of the Ancient Keepers", 0.64, 0.21, 0.93, 1, false)
		GameTooltip:AddLine("Binds when picked up", 1, 1, 1, true)
		GameTooltip:AddLine("Unique", 1, 1, 1, true)
		GameTooltip:AddLine("Ranged                                                            Bow", 1, 1, 1, false)
		GameTooltip:AddLine("89 - 166 Damage                                  Speed 2.90", 1, 1, 1, false)
		GameTooltip:AddLine("(44.0 damage per second)", 1, 1, 1, false)
		GameTooltip:AddLine("Durability 90 / 90", 1, 1, 1, true)
		GameTooltip:AddLine("Classes: Hunter", 1, 1, 1, true)
		GameTooltip:AddLine("Requires Level 60", 1, 1, 1, true)
		GameTooltip:AddLine("Equip: Improves your chance to get a critical strike by 1%.", 0, 255, 0, true)
		GameTooltip:AddLine("Equip: +17 ranged Attack Power.", 0, 255, 0, true)
		GameTooltip:Show()
	end
	
	local function DCS_AF_RhokdelarItemFrame_OnLeave(self)
		GameTooltip_Hide()
	end
	
	local function DCS_AF_StrikersMarkItemFrame_OnEnter(self)
		GameTooltip:SetOwner(DCS_AF_RangedItemFrame, "ANCHOR_RIGHT");
		GameTooltip:SetText("Striker's Mark", 0.64, 0.21, 0.93, 1, true)
		GameTooltip:AddLine("Binds when picked up", 1, 1, 1, true)
		GameTooltip:AddLine("Ranged                                         Bow", 1, 1, 1, false)
		GameTooltip:AddLine("69 - 129 Damage               Speed 2.50", 1, 1, 1, false)
		GameTooltip:AddLine("(39.6 damage per second)", 1, 1, 1, false)
		GameTooltip:AddLine("Durability 90 / 90", 1, 1, 1, true)
		GameTooltip:AddLine("Requires Level 60", 1, 1, 1, true)
		GameTooltip:AddLine("Equip: +22 Attack Power.", 0, 255, 0, true)
		GameTooltip:AddLine("Equip: Improves your chance to hit by 1%.", 0, 255, 0, true)
		GameTooltip:Show()
	end
	
	local function DCS_AF_StrikersMarkItemFrame_OnLeave(self)
		GameTooltip_Hide()
	end
	
	local function DCS_AF_ThoriumArrowItemFrame_OnEnter(self)
		GameTooltip:SetOwner(DCS_AF_AmmoItemFrame, "ANCHOR_RIGHT");
		GameTooltip:SetText("Thorium Headed Arrow", 0.10, 1, 0, 1, true)
		GameTooltip:AddLine("Projectile                       Arrow", 1, 1, 1, false)
		GameTooltip:AddLine("Adds 17.5 damage per second", 1, 1, 1, true)
		GameTooltip:AddLine("Requires Level 52", 1, 1, 1, true)
		GameTooltip:Show()
	end
	
	local function DCS_AF_ThoriumArrowItemFrame_OnLeave(self)
		GameTooltip_Hide()
	end
	
	local function DCS_AF_EssenceGathererItemFrame_OnEnter(self)
		GameTooltip:SetOwner(DCS_AF_RangedItemFrame, "ANCHOR_RIGHT");
		GameTooltip:SetText("Essence Gatherer", 0.64, 0.21, 0.93, 1, true)
		GameTooltip:AddLine("Binds when picked up", 1, 1, 1, true)
		GameTooltip:AddLine("Ranged                                            Wand", 1, 1, 1, false)
		GameTooltip:AddLine("83 - 156 Arcane Damage         Speed 1.40", 1, 1, 1, false)
		GameTooltip:AddLine("(85.4 damage per second)", 1, 1, 1, false)
		GameTooltip:AddLine("+7 Intellect", 1, 1, 1, true)
		GameTooltip:AddLine("+5 Stamina", 1, 1, 1, true)
		GameTooltip:AddLine("Durability 75 / 75", 1, 1, 1, true)
		GameTooltip:AddLine("Requires Level 60", 1, 1, 1, true)
		GameTooltip:AddLine("Equip: Restores 5 mana per 5 sec.", 0, 255, 0, true)
		GameTooltip:Show()
	end
	
	local function DCS_AF_EssenceGathererItemFrame_OnLeave(self)
		GameTooltip_Hide()
	end
	
	local function DCS_AF_TouchofChaosItemFrame_OnEnter(self)
		GameTooltip:SetOwner(DCS_AF_RangedItemFrame, "ANCHOR_RIGHT");
		GameTooltip:SetText("Touch of Chaos", 0.64, 0.21, 0.93, 1, true)
		GameTooltip:AddLine("Binds when picked up", 1, 1, 1, true)
		GameTooltip:AddLine("Ranged                                                  Wand", 1, 1, 1, false)
		GameTooltip:AddLine("86 - 160 Shadow Damage              Speed 1.50", 1, 1, 1, false)
		GameTooltip:AddLine("(82.0 damage per second)", 1, 1, 1, false)
		GameTooltip:AddLine("Durability 75 / 75", 1, 1, 1, true)
		GameTooltip:AddLine("Requires Level 60", 1, 1, 1, true)
		GameTooltip:AddLine("Equip: Increases damage and healing done by magical spells and effects by up to 18.", 0, 255, 0, true)
		GameTooltip:Show()
	end
	
	local function DCS_AF_TouchofChaosItemFrame_OnLeave(self)
		GameTooltip_Hide()
	end
	
	local function DCS_AF_ColdSnapItemFrame_OnEnter(self)
		GameTooltip:SetOwner(DCS_AF_RangedItemFrame, "ANCHOR_RIGHT");
		GameTooltip:SetText("Cold Snap", 0.64, 0.21, 0.93, 1, true)
		GameTooltip:AddLine("Binds when picked up", 1, 1, 1, true)
		GameTooltip:AddLine("Ranged                                                  Wand", 1, 1, 1, false)
		GameTooltip:AddLine("101 - 189 Frost Damage                Speed 1.70", 1, 1, 1, false)
		GameTooltip:AddLine("(85.3 damage per second)", 1, 1, 1, false)
		GameTooltip:AddLine("+7 Intellect", 1, 1, 1, true)
		GameTooltip:AddLine("Durability 75 / 75", 1, 1, 1, true)
		GameTooltip:AddLine("Requires Level 60", 1, 1, 1, true)
		GameTooltip:AddLine("Equip: Increases damage done by Frost spells and effects by up to 20.", 0, 255, 0, true)
		GameTooltip:Show()
	end
	
	local function DCS_AF_ColdSnapItemFrame_OnLeave(self)
		GameTooltip_Hide()
	end
	
	local _, class = UnitClass("player");
	local primaryTalentTree = GetSpecialization();
	local specName, _;
	
	if (primaryTalentTree) then
		_, specName = GetSpecializationInfo(primaryTalentTree, nil, nil, nil, UnitSex("player"));
	end
	
	if (class == "HUNTER") then
		DCS_AF_RangedItemFrameOutlineTexture:SetTexture("Interface\\COMMON\\WhiteIconFrame.blp")
		DCS_AF_RangedItemFrameOutlineTexture:SetVertexColor(0.75, 0.25, 1);
		
		DCS_AF_RangedItemFramehighlightTexture:SetTexture("Interface\\COMMON\\WhiteIconFrame.blp")
		DCS_AF_RangedItemFramehighlightTexture:SetVertexColor(0.7, 0.7, 1, 1);
		
		DCS_AF_RangedItemIconFrametexture:SetTexture("Interface\\ICONS\\INV_Weapon_Bow_01.blp")
		DCS_AF_RangedItemFrame:SetScript("OnEnter", DCS_AF_RhokdelarItemFrame_OnEnter)
		DCS_AF_RangedItemFrame:SetScript("OnLeave", DCS_AF_RhokdelarItemFrame_OnLeave)
	elseif (class == "MAGE") then
		DCS_AF_RangedItemFrameOutlineTexture:SetTexture("Interface\\COMMON\\WhiteIconFrame.blp")
		DCS_AF_RangedItemFrameOutlineTexture:SetVertexColor(0.75, 0.25, 1);
		
		DCS_AF_RangedItemFramehighlightTexture:SetTexture("Interface\\COMMON\\WhiteIconFrame.blp")
		DCS_AF_RangedItemFramehighlightTexture:SetVertexColor(0.7, 0.7, 1, 1);
		
		DCS_AF_RangedItemIconFrametexture:SetTexture("Interface\\ICONS\\INV_Wand_01.blp")
		DCS_AF_RangedItemFrame:SetScript("OnEnter", DCS_AF_ColdSnapItemFrame_OnEnter)
		DCS_AF_RangedItemFrame:SetScript("OnLeave", DCS_AF_ColdSnapItemFrame_OnLeave)
	elseif (class == "WARLOCK")  or (specName == "Shadow") then
		DCS_AF_RangedItemFrameOutlineTexture:SetTexture("Interface\\COMMON\\WhiteIconFrame.blp")
		DCS_AF_RangedItemFrameOutlineTexture:SetVertexColor(0.75, 0.25, 1);
		
		DCS_AF_RangedItemFramehighlightTexture:SetTexture("Interface\\COMMON\\WhiteIconFrame.blp")
		DCS_AF_RangedItemFramehighlightTexture:SetVertexColor(0.7, 0.7, 1, 1);
		
		DCS_AF_RangedItemIconFrametexture:SetTexture("Interface\\ICONS\\INV_Wand_09.blp")
		DCS_AF_RangedItemFrame:SetScript("OnEnter", DCS_AF_TouchofChaosItemFrame_OnEnter)
		DCS_AF_RangedItemFrame:SetScript("OnLeave", DCS_AF_TouchofChaosItemFrame_OnLeave)
	elseif (class == "PRIEST") then
		DCS_AF_RangedItemFrameOutlineTexture:SetTexture("Interface\\COMMON\\WhiteIconFrame.blp")
		DCS_AF_RangedItemFrameOutlineTexture:SetVertexColor(0.75, 0.25, 1);
		
		DCS_AF_RangedItemFramehighlightTexture:SetTexture("Interface\\COMMON\\WhiteIconFrame.blp")
		DCS_AF_RangedItemFramehighlightTexture:SetVertexColor(0.7, 0.7, 1, 1);
		
		DCS_AF_RangedItemIconFrametexture:SetTexture("Interface\\ICONS\\INV_Wand_06.blp")
		DCS_AF_RangedItemFrame:SetScript("OnEnter", DCS_AF_EssenceGathererItemFrame_OnEnter)
		DCS_AF_RangedItemFrame:SetScript("OnLeave", DCS_AF_EssenceGathererItemFrame_OnLeave)
	elseif (class == "WARRIOR") or (class == "ROGUE") then
		DCS_AF_RangedItemFrameOutlineTexture:SetTexture("Interface\\COMMON\\WhiteIconFrame.blp")
		DCS_AF_RangedItemFrameOutlineTexture:SetVertexColor(0.75, 0.25, 1);
		
		DCS_AF_RangedItemFramehighlightTexture:SetTexture("Interface\\COMMON\\WhiteIconFrame.blp")
		DCS_AF_RangedItemFramehighlightTexture:SetVertexColor(0.7, 0.7, 1, 1);
		
		DCS_AF_RangedItemIconFrametexture:SetTexture("Interface\\ICONS\\INV_Weapon_Bow_08.blp")
		DCS_AF_RangedItemFrame:SetScript("OnEnter", DCS_AF_StrikersMarkItemFrame_OnEnter)
		DCS_AF_RangedItemFrame:SetScript("OnLeave", DCS_AF_StrikersMarkItemFrame_OnLeave)
	else
		DCS_AF_RangedItemFrameOutlineTexture:SetTexture("Interface\\COMMON\\WhiteIconFrame.blp")
		DCS_AF_RangedItemFrameOutlineTexture:SetVertexColor(1, 1, 1, 0.5);
		
		DCS_AF_RangedItemFramehighlightTexture:SetTexture("Interface\\COMMON\\WhiteIconFrame.blp")
		DCS_AF_RangedItemFramehighlightTexture:SetVertexColor(1, 1, 1, 0.5);
		
		DCS_AF_RangedItemIconFrametexture:SetTexture("Interface\\ICONS\\INV_Weapon_Rifle_05.blp")
		DCS_AF_RangedItemFrame:SetScript("OnEnter", DCS_AF_EgansBlasterItemFrame_OnEnter)
		DCS_AF_RangedItemFrame:SetScript("OnLeave", DCS_AF_EgansBlasterItemFrame_OnLeave)
	end
	
	if (class == "HUNTER") or (class == "WARRIOR") or (class == "ROGUE") then
		local rand = random(400, 999)		
		DCS_AF_AmmoItemFrameFS:SetFormattedText(rand)
		
		DCS_AF_AmmoItemFrameOutlineTexture:SetTexture("Interface\\COMMON\\WhiteIconFrame.blp")
		DCS_AF_AmmoItemFrameOutlineTexture:SetVertexColor(0.10, 1, 0);
		
		DCS_AF_AmmoItemFramehighlightTexture:SetTexture("Interface\\COMMON\\WhiteIconFrame.blp")
		DCS_AF_AmmoItemFramehighlightTexture:SetVertexColor(1, 1, 1, 0.7);
		
		DCS_AF_AmmoItemIconFrametexture:SetTexture("Interface\\ICONS\\INV_Ammo_Arrow_02.blp")
		DCS_AF_AmmoItemFrame:SetScript("OnEnter", DCS_AF_ThoriumArrowItemFrame_OnEnter)
		DCS_AF_AmmoItemFrame:SetScript("OnLeave", DCS_AF_ThoriumArrowItemFrame_OnLeave)
	end
	
	-- local DCS_AF_FrostResFrame = CreateFrame("Frame", "DCS_AF_FrostResFrame", CharacterModelFrame)
	-- 	DCS_AF_FrostResFrame:SetHeight(230)
	-- 	DCS_AF_FrostResFrame:SetPoint("TOP", CharacterFrameInset, "TOP", 0, 300);
	
	local OldRangedWeaponSlotFrametexture = CharacterSecondaryHandSlot:CreateTexture(nil,"BACKGROUND")
	OldRangedWeaponSlotFrametexture:SetPoint("TOPLEFT", CharacterSecondaryHandSlot, "TOPRIGHT", -11, 24);
	OldRangedWeaponSlotFrametexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-CharacterTab-BottomLeft.blp")
	OldRangedWeaponSlotFrametexture:SetTexCoord(0.78, 0.97, 0.48, 0.67) --LRTB TL=0,0 BR=1,1
	OldRangedWeaponSlotFrametexture:SetScale(0.19)
	CharacterSecondaryHandSlot.OldRangedWeaponSlotFrametexture = OldRangedWeaponSlotFrametexture
	
	local BG_OldRangedWeaponSlotFrametexture = CharacterSecondaryHandSlot:CreateTexture(nil,"LOW",nil,-8)
	BG_OldRangedWeaponSlotFrametexture:SetPoint("TOPLEFT", CharacterSecondaryHandSlot, "TOPRIGHT", 7, 2);
	BG_OldRangedWeaponSlotFrametexture:SetTexture("Interface\\PaperDoll\\UI-PaperDoll-Slot-Ranged.blp")
	BG_OldRangedWeaponSlotFrametexture:SetScale(0.6)
	CharacterSecondaryHandSlot.BG_OldRangedWeaponSlotFrametexture = BG_OldRangedWeaponSlotFrametexture
	
	local AmmoSlotFrametexture = DCSAFBottomRightframe:CreateTexture(nil,"BACKGROUND",nil,-4)
	AmmoSlotFrametexture:SetPoint("TOPRIGHT", DCSAFBottomRightframe, "BOTTOMRIGHT", -12, -8);
	AmmoSlotFrametexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-AmmoSlot.blp")
	AmmoSlotFrametexture:SetTexCoord(0, 0.6, 0, 0.6) --LRTB TL=0,0 BR=1,1
	AmmoSlotFrametexture:SetScale(0.6)
	DCSAFBottomRightframe.AmmoSlotFrametexture = AmmoSlotFrametexture
	
	local BG_OldAmmoRangedWeaponSlotFrametexture = DCSAFBottomRightframe:CreateTexture(nil,"LOW")
	BG_OldAmmoRangedWeaponSlotFrametexture:SetPoint("TOPRIGHT", DCSAFBottomRightframe, "BOTTOMRIGHT", -30, -28);
	BG_OldAmmoRangedWeaponSlotFrametexture:SetTexture("Interface\\PaperDoll\\UI-PaperDoll-Slot-Ranged.blp")
	BG_OldAmmoRangedWeaponSlotFrametexture:SetScale(0.42)
	CharacterSecondaryHandSlot.BG_OldAmmoRangedWeaponSlotFrametexture = BG_OldAmmoRangedWeaponSlotFrametexture
	
	local AmmoSlotArrowFrametexture = DCSAFBottomRightframe:CreateTexture(nil,"TOOLTIP",nil,-1)
	AmmoSlotArrowFrametexture:SetPoint("TOPRIGHT", DCSAFBottomRightframe, "BOTTOMRIGHT", -48, 0);
	AmmoSlotArrowFrametexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-AmmoSlot.blp")
	AmmoSlotArrowFrametexture:SetTexCoord(0.6, 1, 0, 0.5) --LRTB TL=0,0 BR=1,1
	AmmoSlotArrowFrametexture:SetScale(0.6)
	DCSAFBottomRightframe.AmmoSlotArrowFrametexture = AmmoSlotArrowFrametexture
	
	local ResiststextureL = DCSAFBottomRightframe:CreateTexture(nil,"TOOLTIP")
	ResiststextureL:SetWidth(33)
	ResiststextureL:SetHeight(28)
	ResiststextureL:SetPoint("TOPRIGHT", DCSAFBottomRightframe, "TOPRIGHT", -2, 252);
	ResiststextureL:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ResistanceIcons.blp")
	ResiststextureL:SetTexCoord(0, 1, 0.23, 0.34) --LRTB TL=0,0 BR=1,1
	DCSAFBottomRightframe.ResiststextureL = ResiststextureL
	
	local ResiststextureTR = DCSAFBottomRightframe:CreateTexture(nil,"TOOLTIP")
	ResiststextureTR:SetWidth(33)
	ResiststextureTR:SetHeight(60)
	ResiststextureTR:SetPoint("TOPRIGHT", DCSAFBottomRightframe, "TOPRIGHT", -2, 225);
	ResiststextureTR:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ResistanceIcons.blp")
	ResiststextureTR:SetTexCoord(0, 1, 0, 0.23) --LRTB TL=0,0 BR=1,1
	DCSAFBottomRightframe.ResiststextureTR = ResiststextureTR
	
	local ResiststextureBR = DCSAFBottomRightframe:CreateTexture(nil,"TOOLTIP")
	ResiststextureBR:SetWidth(33)
	ResiststextureBR:SetHeight(166)
	ResiststextureBR:SetPoint("TOPRIGHT", DCSAFBottomRightframe, "TOPRIGHT", -2, 165);
	ResiststextureBR:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ResistanceIcons.blp")
	ResiststextureBR:SetTexCoord(0, 1, 0.34, 1) --LRTB TL=0,0 BR=1,1
	DCSAFBottomRightframe.ResiststextureBR = ResiststextureBR
	
	local DCSAF_ResistFrame = CreateFrame("Frame", "DCSAF_ResistFrame", CharacterModelFrame, "OptionsBoxTemplate")
	DCSAF_ResistFrame:ClearAllPoints()
	DCSAF_ResistFrame:SetWidth(30)
	DCSAF_ResistFrame:SetHeight(145)
	DCSAF_ResistFrame:SetPoint("TOPRIGHT", DCSAFBottomRightframe, "TOPRIGHT", -3, 252);
	DCSAF_ResistFrame:Show()
	
	-- local DCSAF_ResistFrameTexture = DCSAF_ResistFrame:CreateTexture(nil,"ARTWORK") --Debugging texture
	-- 	DCSAF_ResistFrameTexture:SetAllPoints(DCSAF_ResistFrame)
	-- 	DCSAF_ResistFrameTexture:SetColorTexture(1, 1, 1, 1)
	
	ResFrostFS = DCSAF_ResistFrame:CreateFontString("FontString","OVERLAY","GameTooltipText")
	ResFrostFS:SetPoint("CENTER",DCSAF_ResistFrame,"CENTER",0,52) 
	ResFrostFS:SetFont(DCS_STANDARD_TEXT_FONT, DCS_FONT_SIZE, "THINOUTLINE")
	ResFrostFS:SetJustifyH("CENTER")
	ResFrostFS:SetFormattedText("")

	ResFireFS = DCSAF_ResistFrame:CreateFontString("FontString","OVERLAY","GameTooltipText")
	ResFireFS:SetPoint("CENTER",DCSAF_ResistFrame,"CENTER",0,23) 
	ResFireFS:SetFont(DCS_STANDARD_TEXT_FONT, DCS_FONT_SIZE, "THINOUTLINE")
	ResFireFS:SetJustifyH("CENTER")
	ResFireFS:SetFormattedText("")
	
	ResNatureFS = DCSAF_ResistFrame:CreateFontString("FontString","OVERLAY","GameTooltipText")
	ResNatureFS:SetPoint("CENTER",DCSAF_ResistFrame,"CENTER",0,-6) 
	ResNatureFS:SetFont(DCS_STANDARD_TEXT_FONT, DCS_FONT_SIZE, "THINOUTLINE")
	ResNatureFS:SetJustifyH("CENTER")
	ResNatureFS:SetFormattedText("")
	
	ResArcaneFS = DCSAF_ResistFrame:CreateFontString("FontString","OVERLAY","GameTooltipText")
	ResArcaneFS:SetPoint("CENTER",DCSAF_ResistFrame,"CENTER",0,-36) 
	ResArcaneFS:SetFont(DCS_STANDARD_TEXT_FONT, DCS_FONT_SIZE, "THINOUTLINE")
	ResArcaneFS:SetJustifyH("CENTER")
	ResArcaneFS:SetFormattedText("")
	
	ResShadowFS = DCSAF_ResistFrame:CreateFontString("FontString","OVERLAY","GameTooltipText")
	ResShadowFS:SetPoint("CENTER",DCSAF_ResistFrame,"CENTER",0,-64) 
	ResShadowFS:SetFont(DCS_STANDARD_TEXT_FONT, DCS_FONT_SIZE, "THINOUTLINE")
	ResShadowFS:SetJustifyH("CENTER")
	ResShadowFS:SetFormattedText("")
	
	local f = CreateFrame("Frame", "FarmootPlayerPortrait", CharacterFrame)
	f:SetSize(60, 60)
	f:SetPoint("TOPLEFT", -4, 8)
	f.Texture = f:CreateTexture("$parent_Texture", "BACKGROUND")
	f.Texture:SetAllPoints()
	SetPortraitTexture(f.Texture, "player")
	-- f.Border = f:CreateTexture("$parent_Border", "BORDER")
	-- f.Border:SetPoint("TOPLEFT", -6, 4)
	-- f.Border:SetPoint("BOTTOMRIGHT", 6, -10)
	-- f.Border:SetTexture("Interface/PLAYERFRAME/UI-PlayerFrame-Deathknight-Ring")
	-- f.Border:SetVertexColor(1, 1, 0, 1)
	f:RegisterUnitEvent("UNIT_PORTRAIT_UPDATE", "player")
	f:SetScript("OnEvent", function(self) SetPortraitTexture(self.Texture, "player") end)
	
	local RotationLeftButtontexture = DCSAFBottomRightframe:CreateTexture(nil,"TOOLTIP")
	RotationLeftButtontexture:SetWidth(36)
	RotationLeftButtontexture:SetHeight(36)
	RotationLeftButtontexture:SetPoint("TOPRIGHT", DCSAFBottomRightframe, "TOPRIGHT", -192, 252);
	RotationLeftButtontexture:SetTexture("Interface\\BUTTONS\\UI-RotationLeft-Button-Up.blp")
	DCSAFBottomRightframe.RotationLeftButtontexture = RotationLeftButtontexture
	
	local RotationRightButtontexture = DCSAFBottomRightframe:CreateTexture(nil,"TOOLTIP")
	RotationRightButtontexture:SetWidth(36)
	RotationRightButtontexture:SetHeight(36)
	RotationRightButtontexture:SetPoint("TOPRIGHT", DCSAFBottomRightframe, "TOPRIGHT", -157, 252);
	RotationRightButtontexture:SetTexture("Interface\\BUTTONS\\UI-RotationRight-Button-Up.blp")
	DCSAFBottomRightframe.RotationRightButtontexture = RotationRightButtontexture
end

local function AFStatFrames(FrameParent, NameX, NameYStat, statName, NameClose, ValueX, ValueFont, ValueColor, Stat)
	StatNameFS:SetFormattedText("|cffffd100"..statName..NameClose)
	StatValueFS:SetFormattedText(ValueColor..Stat.."|r")
end

local function ResistTextfunction(health, Armor, Strength, Agility, Stamina, Intellect, FrostRes, FireRes, NatureRes, ArcaneRes, ShadowRes)
	ResFrostFS:SetFormattedText("|cff1ffc1f"..FrostRes.."|r")
	ResFireFS:SetFormattedText("|cff1ffc1f"..FireRes.."|r")
	ResNatureFS:SetFormattedText("|cff1ffc1f"..NatureRes.."|r")
	ResArcaneFS:SetFormattedText("|cff1ffc1f"..ArcaneRes.."|r")
	ResShadowFS:SetFormattedText("|cff1ffc1f"..ShadowRes.."|r")
end

local function mystrangefunction()
	local level = UnitLevel("player")
	local health = UnitHealthMax("player")
	local power = UnitPowerMax("player") or 0
	local Strength = UnitStat("player", 1)
	local Agility = UnitStat("player", 2)
	local Stamina = UnitStat("player", 3)
	local Intellect = UnitStat("player", 4)
	local Spirit = floor( ( ((health + power)/level)  +  (Intellect + Strength) ) / 3  )
	local _ , Armor = UnitArmor("player");
	local NewCharacterLevelText = level
	local classDisplayName, class = UnitClass("player");
	local race = UnitRace("player");
	
	if (NewCharacterLevelText > 59) then
		NewCharacterLevelText = 60
	end
	
	CharacterLevelText:SetFormattedText("Level "..NewCharacterLevelText.." "..race.." "..classDisplayName);
	
	-- Calculations based on my Classic character with max resists as a bear tank. Image is here: https://i.imgur.com/WcAzViA.jpg
	local FrostRes = floor( (health / (Armor + Strength)) * 2.3)
	local FireRes = floor( (health / (Armor + Agility) * 4.7))
	local NatureRes = floor( (health / (Armor + Stamina) * 3.4))
	local ArcaneRes = floor( (health / (Armor + Intellect) * 1))
	local ShadowRes = floor( (health / (Armor + Spirit) * 1.4))
	ResistTextfunction(health, Armor, Strength, Agility, Stamina, Intellect, FrostRes, FireRes, NatureRes, ArcaneRes, ShadowRes)
	
	for i=1, 12 do
		local statIndex = i
		local Stat
		local statName
		local FrameParent = DCSAFLeftframe
		local NameX = 5
		local ValueX = -3
		local NameYStat = (-( (floor(DCSAFLeftframe:GetHeight()/7) + 1)  * (i-1) ) -6)
		local ValueFont = (DCS_FONT_SIZE - 1) --This is == 10
		local ValueColor = "|cff1ffc1f"
		local NameClose = ":|r"
		
		-- if (statIndex < 5) then
		-- 	Stat = UnitStat("player", statIndex);
		-- 	statName = _G["SPELL_STAT"..statIndex.."_NAME"]
		-- end
		
		if (statIndex == 1) then
			Stat = UnitStat("player", statIndex);
			statName = L["Strength"];
		end

		if (statIndex == 2) then
			Stat = UnitStat("player", statIndex);
			statName = L["Agility"];
		end

		if (statIndex == 3) then
			Stat = UnitStat("player", statIndex);
			statName = L["Stamina"];
		end

		if (statIndex == 4) then
			Stat = UnitStat("player", statIndex);
			statName = L["Intellect"];
		end

		if (statIndex == 5) then
			-- Spirit = (MaxHP+MaxPower/level)+(Int+Str)/3
			Stat = Spirit 
			statName = L["Spirit"];
		end

		if (statIndex == 6) then
			Stat = Armor
			statName = L["Armor"];
		end
		
		if (statIndex == 7) then
			i = 1
			FrameParent = DCSAFTopRightframe
			NameX = 7
			ValueX = -1
			NameYStat = (-( (floor(DCSAFLeftframe:GetHeight()/7) + 1)  * (i-1) ) -4)
			ValueColor = "|cffffffff"
			NameClose = "|r"
			if (level < 60) then 
				Stat = (level * 5)
			else
				Stat = 300
			end
			statName = L["Melee Attack"]
		end
		
		if (statIndex == 8) then
			i = 2
			FrameParent = DCSAFTopRightframe
			NameX = 13
			NameYStat = (-( (floor(DCSAFLeftframe:GetHeight()/7) + 1)  * (i-1) ) -3)
			ValueX = -1
			ValueColor = "|cffffffff"
			base, posBuff, negBuff = UnitAttackPower("player");
			Stat = base
			if (Stat == 0) then
				Stat = "--"
			end
			statName = L["Power"]
		end
		
		if (statIndex == 9) then
			i = 3
			FrameParent = DCSAFTopRightframe
			NameX = 13
			NameYStat = (-( (floor(DCSAFLeftframe:GetHeight()/7) + 1)  * (i-1) ) -2)
			ValueX = -1
			ValueColor = "|cffffffff"
			local lowDmg, hiDmg, offlowDmg, offhiDmg, posBuff, negBuff, percentmod = UnitDamage("player");
			if (lowDmg > 999) then
				ValueFont = (DCS_FONT_SIZE - 2) -- 9 is standard
			end
			Stat =  floor(lowDmg).."-"..ceil(hiDmg)
			statName = L["Damage"]
		end
		
		if (statIndex == 10) then
			i = 1
			FrameParent = DCSAFBottomRightframe
			NameX = 7
			ValueX = -1
			NameYStat = (-( (floor(DCSAFLeftframe:GetHeight()/7) + 1)  * (i-1) ) -6)
			ValueColor = "|cffffffff"
			NameClose = "|r"
			if (level < 60) then 
				Stat = (level * 5)
			else
				Stat = 300
			end
			statName = L["Ranged Attack"]
		end
		
		if (statIndex == 11) then
			i = 2
			FrameParent = DCSAFBottomRightframe
			NameX = 13
			ValueX = -1
			NameYStat = (-( (floor(DCSAFLeftframe:GetHeight()/7) + 1)  * (i-1) ) -4)
			ValueColor = "|cffffffff"
			base, posBuff, negBuff = UnitRangedAttackPower("player");
			Stat = base
			if (Stat == 0) then
				Stat = "--"
			end
			statName = L["Power"]
		end
		
		if (statIndex == 12) then
			i = 3
			FrameParent = DCSAFBottomRightframe
			NameX = 13
			ValueX = -1
			NameYStat = (-( (floor(DCSAFLeftframe:GetHeight()/7) + 1)  * (i-1) ) -3.5)
			ValueColor = "|cffffffff"
			local attackTime, minDamage, maxDamage, bonusPos, bonusNeg, percent = UnitRangedDamage("player");
			if (minDamage > 999) then
				ValueFont = (DCS_FONT_SIZE - 2) -- 9 is standard
			end		
			Stat =  floor(minDamage).."-"..ceil(maxDamage)
			statName = L["Damage"]
		end
		
		StatNameFS = FrameParent:CreateFontString("FontString","OVERLAY","GameTooltipText")
		StatNameFS:SetPoint("TOPLEFT",FrameParent,"TOPLEFT",NameX,NameYStat) 
		StatNameFS:SetFont(DCS_UNIT_NAME_FONT, DCS_FONT_SIZE, "THINOUTLINE")
		StatNameFS:SetJustifyH("LEFT")
		StatNameFS:SetFormattedText("")

		StatValueFS = FrameParent:CreateFontString("FontString","OVERLAY","GameTooltipText") 
		StatValueFS:SetPoint("TOPRIGHT",FrameParent,"TOPRIGHT",ValueX,NameYStat) 
		StatValueFS:SetFont(DCS_STANDARD_TEXT_FONT, ValueFont, "THINOUTLINE")
		StatValueFS:SetJustifyH("RIGHT")
		StatValueFS:SetFormattedText("")
		
		AFStatFrames(FrameParent, NameX, NameYStat, statName, NameClose, ValueX, ValueFont, ValueColor, Stat)
	end
end	
	
local function DCS_ShowClassicStatFrames()
	AFSetupFrames()
	mystrangefunction()

	PaperDollFrame:HookScript("OnShow", function(self)
		mystrangefunction()
		if (collapse == 0) then 
			CharacterFrame_Collapse()
		end
		collapse = 1
	end)
	
	PaperDollFrame:HookScript("OnHide", function(self)
		StatNameFS:SetFormattedText("")
		StatValueFS:SetFormattedText("")
	end)
	
	hooksecurefunc("CharacterFrame_Expand", function() mystrangefunction() end)
	hooksecurefunc("CharacterFrame_Collapse", function() mystrangefunction() end)
end

gdbprivate.gdbdefaults.gdbdefaults.DCSShowClassicChecked = {
	SetChecked = false,
	IsAprilFools = false,
	DCSShowAFChecked = false,
	Count = 0,
}	

local DCS_ShowClassicCheck = CreateFrame("CheckButton", "DCS_ShowClassicCheck", DejaCharacterStatsPanel, "InterfaceOptionsCheckButtonTemplate")
	DCS_ShowClassicCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ShowClassicCheck:ClearAllPoints()
	DCS_ShowClassicCheck:SetPoint("LEFT", 150, -225)
	DCS_ShowClassicCheck:SetScale(1)
	DCS_ShowClassicCheck.tooltipText = L["Displays a simulation of Classic WoW's character stats panels. Disabling initiates a UI reload."] --Creates a tooltip on mouseover.
	_G[DCS_ShowClassicCheck:GetName() .. "Text"]:SetText(L["Classic Stats"])
	
	DCS_ShowClassicCheck:SetScript("OnEvent", function(self, event, arg1)
		local checked = gdbprivate.gdb.gdbdefaults.DCSShowClassicChecked.SetChecked
		self:SetChecked(checked)
		if checked then
			DCS_ShowClassicStatFrames()
		end
	end)

	DCS_ShowClassicCheck:SetScript("OnClick", function(self,event,arg1) 
		local checked = self:GetChecked()
		gdbprivate.gdb.gdbdefaults.DCSShowClassicChecked.SetChecked = checked
		if checked == true then
			DCS_ShowClassicStatFrames()
		else
			ReloadUI();
		end
	end)
	
local DCS_ShowAFCheck = CreateFrame("CheckButton", "DCS_ShowAFCheck", PaperDollFrame, "InterfaceOptionsCheckButtonTemplate")
	DCS_ShowAFCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_ShowAFCheck:ClearAllPoints()
	DCS_ShowAFCheck:SetPoint("TOPLEFT", PaperDollFrame, "TOPLEFT", 14, 38)
	DCS_ShowAFCheck:SetScale(1)
	DCS_ShowAFCheck.tooltipText = L["|cff00c0ffClassic Stats for April Fools! \n\nThey will automatically dissappear tomorrow. \n\nIf you like them, head over to the Interface Options Panel and turn them on at your whim! \n\nIf ya don't like them simply click this checkbox to initiate a UI reload and disable this prank! Your character frame will be set back exactly how it was. \n\nApril Fools!  \n\n|cffff0000<3|r Deja    |r|TInterface\\Addons\\DejaCharacterStats\\DCSArt\\DejaBearPawLogoDejaBlue.blp:40|t"] --Creates a tooltip on mouseover.
	_G[DCS_ShowAFCheck:GetName() .. "Text"]:SetText("|TInterface\\Addons\\DejaCharacterStats\\DCSArt\\DejoLogo.blp:40|t|cff00c0ffAPRIL FOOLS!|r")
	
	DCS_ShowAFCheck:SetScript("OnEvent", function(self, event, arg1)
		local checked = gdbprivate.gdb.gdbdefaults.DCSShowClassicChecked.DCSShowAFChecked
		self:SetChecked(checked)
		if checked then
			DCS_ShowClassicStatFrames()
		end
	end)

	DCS_ShowAFCheck:SetScript("OnClick", function(self,event,arg1) 
		local checked = self:GetChecked()
		gdbprivate.gdb.gdbdefaults.DCSShowClassicChecked.DCSShowAFChecked = checked
		if checked == true then
			DCS_ShowClassicStatFrames()
		else
			ReloadUI();
		end
	end)

local DCS_AFLoginCheck = CreateFrame("Frame", "DCS_AFLoginCheck", CharacterModelFrame)
DCS_AFLoginCheck:RegisterEvent("PLAYER_LOGIN")
	DCS_AFLoginCheck:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	DCS_AFLoginCheck:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	
	DCS_AFLoginCheck:SetScript("OnEvent", function(self, event, ...)
		local logincounter = gdbprivate.gdb.gdbdefaults.DCSShowClassicChecked.Count
		local d = C_DateAndTime.GetCurrentCalendarTime()
		-- print(d.monthDay, d.month, logincounter)
		-- print(format("The time is %02d:%02d, %s, %d %s %d", d.hour, d.minute, CALENDAR_WEEKDAY_NAMES[d.weekday], d.monthDay, CALENDAR_FULLDATE_MONTH_NAMES[d.month], d.year))
		if d.monthDay==1 and d.month==4 then --April Fools
			if logincounter == 0 then
				DCS_ShowAFCheck:Show()
				DCS_ShowAFCheck:SetChecked(true)
				DCS_ShowClassicStatFrames()
				gdbprivate.gdb.gdbdefaults.DCSShowClassicChecked.DCSShowAFChecked = true
				gdbprivate.gdb.gdbdefaults.DCSShowClassicChecked.Count = logincounter + 1
			elseif logincounter > 0 then
				local AFchecked = DCS_ShowAFCheck:GetChecked()
				gdbprivate.gdb.gdbdefaults.DCSShowClassicChecked.DCSShowAFChecked = AFchecked
				if AFchecked == true then
					DCS_ShowAFCheck:Show()
					DCS_ShowClassicStatFrames()
				else
					DCS_ShowAFCheck:Hide()
					DCS_ShowAFCheck:SetChecked(false)
					gdbprivate.gdb.gdbdefaults.DCSShowClassicChecked.DCSShowAFChecked = false
				end
			end
		else
			DCS_ShowAFCheck:Hide()
			gdbprivate.gdb.gdbdefaults.DCSShowClassicChecked.DCSShowAFChecked = false
			gdbprivate.gdb.gdbdefaults.DCSShowClassicChecked.Count = 0
		end
	end)