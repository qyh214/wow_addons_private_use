--[[

         Titan Panel [Item Count]
         70000 1.2.3

]]--

TitanItemCount = LibStub("AceAddon-3.0"):NewAddon("TitanItemCount", "AceConsole-3.0", 
   "AceComm-3.0", "AceEvent-3.0", "AceSerializer-3.0", "AceTimer-3.0", "AceHook-3.0");
TitanItemCount.version = "60002-1.2.2";
TitanItemCount.author = "Solage of Greymane";

local C_YELLOW = "|cffffff00"
local C_GREEN  = "|cff00ff00"
local C_WHITE  = "|cffffffff"
local C_RED    = "|cffff0000"
local C_TURQ   = "|cff22ee55"
local C_AQUA   = "|cff22ee77"
local C_MGNTA  = "|cffff0088"
local C_PURPLE = "|cffEE22aa"

local menutext = "Titan Item Count "..C_TURQ.."("..
   GetAddOnMetadata("TitanItemCount", "Version")..")";
local buttonlabel = "Item Count: "
local ID = "ItmC"

local elapQoH, QoH, prevQoH = 0, 0.0, -2
local startVal = 0
local GoalIsMet = false
local AlreadyAlerted = true
local AllowDebug = false

local format = string.format
local join = string.join
local floor = math.floor
local wipe = table.wipe

local Bells = {
   AllianceBell = "Sound/Doodad/Belltollalliance.Ogg",
   HordeBell    = "Sound/Doodad/Belltollhorde.Ogg",
   NelfBell     = "Sound/Doodad/Belltollnightelf.Ogg",
   TribalBell   = "Sound/Doodad/Belltolltribal.Ogg",
   Ahoy         = "Sound/Creature/Budd/Vo_Qe_Vj_Budd_Allianceship01.Ogg",
   Sailing      = "Sound/Creature/Budd/Vo_Qe_Vj_Budd_Allianceship02.Ogg",
   CannonDeath  = "Sound/Creature/Cannon/Cannondeath.Ogg",
   Hua          = "Sound/Character/Human/Male/Humanmaleaggroa.Ogg",
   Erudax       = "Sound/Creature/Erudax/Vo_Gb_Erudax_Attack01.Ogg",
   FelReaver    = "Sound/Creature/Felreaver/Felreaverpreaggro.Ogg",
   LaochinHua   = "Sound/Creature/Laochen/Vo_Laochin_Attackcrit_01.Ogg",
   Firecrackers = "Sound/Doodad/Firecrackerstringexplode.Ogg",
   PetTrap      = "Sound/Doodad/Fx_Petbattles_Trap_Success_01.Ogg",
   Mortar       = "Sound/Doodad/G_Mortar.Ogg",
   RockExplode  = "Sound/Doodad/Go_Explodingstoneimpact01_01.Ogg",
   DivineBell   = "Sound/Doodad/Go_Pa_Divinebell_Ring_Pure.Ogg",
   FogHorn      = "Sound/Doodad/Lighthousefoghorn.Ogg",
   HornCall     = "Sound/Events/Gruntling_Horn_Bb.Ogg",
   Cheer        = "Sound/Events/Guldancheers.Ogg",
   ScourgeHorn  = "Sound/Events/Scourge_Horn.Ogg",
   WaterElem	 = "Sound/Spells/Waterelemental_Impact_Base.Ogg",
   BrokenHeart	 = "Sound/Spells/Valentines_Brokenheart.Ogg",
   Valentine	 = "Sound/Spells/Valentines_Lookingforloveheart.Ogg",
   Vanish	    = "Sound/Spells/Vanish.Ogg",
   UnfAdvan	    = "Sound/Spells/Unfairadvantage_Cast.Ogg",
   Thunderclap	 = "Sound/Spells/Thunderclap.Ogg",
   Taunt	       = "Sound/Spells/Taunt.Ogg",
   Sleep	       = "Sound/Spells/Sleepimpact.Ogg",
   Sindragosa	 = "Sound/Spells/Sindragosa_Tailsmash_01.Ogg",
   ShaysBell	 = "Sound/Spells/Shaysbell.Ogg",
   PetCall	    = "Sound/Spells/Petcall.Ogg",
   JennyWhistle = "Sound/Spells/Jennyswhistle.Ogg",
   FireBomb	    = "Sound/Spells/Firebomb1.Ogg",
   Pounce	    = "Sound/Spells/Druid_Pounce.Ogg",
   SunChime	    = "Sound/Spells/Fx_Chimeelemental_Sun_01.Ogg",
   KaraBell     = "Sound/Doodad/Kharazahnbelltoll.Ogg",
   MopGong	    = "Sound/Doodad/Wow_Mop_Intro_Sfx_Bell_Nogong_Mono.Ogg",
}
-- it would be nice to be able to control the order of appearance in the dropdown, but
-- we'll save that for the next devel cycle
local BellsIndex = {}
local BellsLabel = {}
local ix = 0
for k,v in pairs(Bells) do
   BellsLabel[ix] = k
   BellsIndex[k] = ix
   ix = ix + 1
end

local BellsList = {}

TitanItemCount_UpdateInterval = 1.0;  -- does this really do anything?


--[[
-- ------------------[ Settings for the Addon Options Panel ]---------------
]]--

local options = {
	name = "Titan ItemCount",
	handler = TitanItemCount,
	type = "group",
	args = {
		info1 = {
			type		= "description",
			name		= "Version "..TitanItemCount.version,
			order		= 0,
		},
		info2 = {
			type		= "description",
			name		= "Authors: "..TitanItemCount.author,
			order		= 10,
		},
		header = {
			type		= "header",
			name		= "General Options",
			order		= 20,
		},
		Item = {
			type     = 'input',
			name     = "Item to Count",
			desc     = "Inventory item to track quantity",
			get      = function() return TitanItemCount.db.char.Item end,
			set      = "SetItem",
		   validate = "ValidItem",
		   usage    = "Enter an item from your inventory - type, drag, or alt-click",
			width    = full,
			order    = 30,
		},
		info2a = {
		   type     = "description",
		   name     = "Type an item, or drag from your bags and drop here",
		   order    = 35,
		},
		space1 = {
		   type     = "description",
		   name     = "",
		   order    = 40,
		},
		ShowItem = {
		   type     = 'toggle',
		   name     = "Show Item Name",
		   desc     = "Show the item name in the Titan button?",
		   get      = function() return TitanGetVar(ID,"ShowItem") end,
		   set      = "SetShowItem",
		   width    = full,
		   order    = 50,
		},
		space2 = {
		   type     = "description",
		   name     = "",
		   order    = 60,
		},
		Goal = {
		   type     = 'input',
		   name     = "Goal Quantity",
		   desc     = "Zero to disable, positive integer for alert when qty reached",
		   get      = function() return tostring(TitanItemCount.db.char.Goal) end,
		   set      = "SetGoal",
		   validate = "ValidGoal",
		   usage    = "Enter an integer zero or higher",
		   width    = full,
		   order    = 70,
		},
		info3 = {
			type		= "description",
			name		= "Set Goal Quantity to zero if you don't want to hear about it.",
			order		= 80,
		},
		space3 = {
		   type     = "description",
		   name     = "",
		   order    = 90,
		},
		BellSound = {
		   type     = 'select',
		   name     = "Bell Sound",
		   style    = "dropdown",
		   values   = BellsLabel,
		   set      = "SetBell",
		   get      = function() return BellsIndex[TitanItemCount.db.char.BellSound] end,
		   order    = 100,
		}
	}
};


--[[
-- ------------------[ Saved Variable Data Table ]---------------
]]--

local defaults = {
	char = {
		Item = "Linen Cloth",
		ShowItem = true,
		Goal = 0,
		BellSound = "AllianceBell",  -- arbitrary default
		debug = false,
	}
};


--[[
-- ------------------[ Addon Object Functions ]---------------
]]--

function TitanItemCount:OnInitialize()
	-- Load Options DB
	self.db = LibStub("AceDB-3.0"):New("TitanItemCountDB", defaults);

	-- Initialize Config Panels
	self:InitConfig();

   -- Register Events

	-- Delay welcome message.
	self:ScheduleTimer(function() 
			self:Print("version ("..self.version..") loaded.")
			self:Print("Currently tracking "..TitanItemCount.db.char.Item)
		end, 4);

   TitanItemCount:ResetCountStatus()
   prevQoH = 0 -- 
   TitanPanelButton_UpdateButton(ID)  -- update qty on the button
   FirstRun = true -- don't alert until qty changes

end


function TitanItemCount:InitConfig()
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Titan ItemCount", options, "tic");
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Titan ItemCount");
end


function TitanItemCount:ticAnnounce()
   self:Print(C_YELLOW.."now counting "..TitanItemCount.db.char.Item..C_YELLOW..".")
end


function TitanItemCount:qtyAnnounce()
   self:Print(C_YELLOW.."Goal Quantity is now "..C_WHITE..TitanItemCount.db.char.Goal..C_YELLOW..".")
end


function TitanItemCount:soundAnnounce()
   self:Print(C_YELLOW.."will use "..C_WHITE..TitanItemCount.db.char.BellSound..C_YELLOW.." for alerts.")
end


function TitanItemCount:OnEnable()
	self:Hook("ContainerFrameItemButton_OnModifiedClick", true)
end


-- AltClick Handling
function TitanItemCount:ContainerFrameItemButton_OnModifiedClick(...)
   if select(2,...) == "LeftButton" and IsAltKeyDown() and 
      not IsControlKeyDown() and not IsShiftKeyDown() and 
      not CursorHasItem() then

		bagID, slot = (...):GetParent():GetID(), (...):GetID()
      texture, itemCount, locked, quality, readable, lootable, itemLink = 
         GetContainerItemInfo(bagID, slot);

      TitanItemCount:SetItem("nothing", itemLink)

   end
end


function TitanItemCount:DoAlert()
   PlaySoundFile(Bells[TitanItemCount.db.char.BellSound], "Master")
   CombatText_AddMessage("Item Count Goal Attainied", CombatText_StandardScroll, 
      0.9, 0.2, 0.5, nil, true, nil);
end


function TitanItemCount:ResetCountStatus()

   -- this should happen only whenever item or goal change

   QoH = GetItemCount(TitanItemCount.db.char.Item)
   prevQoH = QoH
   GoalIsMet = (QoH >= TitanItemCount.db.char.Goal)
   AlreadyAlerted = GoalIsMet
   if AllowDebug and TitanGetVar(ID,"debug") then
      self:Print("Item: "..tostring(TitanItemCount.db.char.Item)..
         " - Goal: "..tostring(TitanItemCount.db.char.Goal)..
         " - QoH: "..tostring(QoH)..
         " - AlreadyAlerted: "..tostring(AlreadyAlerted)..
         " - GoalIsMet: "..tostring(GoalIsMet))
   end

end


--[[    Interface with AceConfig Options Panel   ]]--


function TitanItemCount:SetBell(info, input)
   TitanItemCount.db.char.BellSound = BellsLabel[input]
   TitanItemCount:soundAnnounce()
   PlaySoundFile(Bells[TitanItemCount.db.char.BellSound], "Master")
end


-- assumes this is only run when the item changes...
function TitanItemCount:SetItem(info, input)
   TitanItemCount.db.char.Item = input
   TitanItemCount:ResetCountStatus()
   TitanPanelButton_UpdateButton(ID)
   TitanItemCount:ticAnnounce()
end


-- assumes this is only run when the goal changes...
function TitanItemCount:SetGoal(info, input)
   TitanItemCount.db.char.Goal = tonumber(input)
   TitanItemCount:ResetCountStatus()
   TitanPanelButton_UpdateButton(ID)
   TitanItemCount:qtyAnnounce()
end


function TitanItemCount:SetShowItem(info, input)
   TitanSetVar(ID, "ShowItem", input);
   TitanItemCount.db.char.ShowItem = input;
   TitanPanelButton_UpdateButton(ID)
end


function TitanItemCount:ValidItem(info, input)
   local tcount
   tcount = GetItemCount(input)
   if tcount < 1 then 
      self:Print("Tracked item must be something in your bags.")
      return false
   end
   return true
end


function TitanItemCount:ValidGoal(info, input)
   local tnum
   tnum = tonumber(input)
   if not tnum or tnum < 0 then 
      self:Print("You must enter an integer zero or higher")
      return false
   end
   return true
end


--[[
-- ------------------[ Titan Panel Button Event handlers ]---------------
]]--

function TitanPanelItmCButton_OnLoad(self)
   if not TitanPanelButton_UpdateButton then
      return;
   end

	self.registry = {
		id = ID,
		menuText = menutext,
		buttonTextFunction = "TitanPanelItmCButton_GetButtonText",
		tooltipTitle = GREEN_FONT_COLOR_CODE.."Item Count",
		tooltipTextFunction = "TitanPanelItmCButton_GetTooltipText",
		frequency = 2,
		icon = "Interface\\AddOns\\TitanBag\\TitanBag",
		iconWidth = 16,
		category = "Information",
		savedVariables = {
			ShowIcon = 1,
			ShowLabelText = false,
			ShowItem = false,
			debug = false,
		},
	}

end


function TitanPanelItmCButton_OnUpdate(this, elapsed)

   if elapsed == nil then elapsed = 2; end
   elapQoH = elapQoH + elapsed;
   if elapQoH < 1 then return end

   QoH = GetItemCount(TitanItemCount.db.char.Item)

   -- only update the button and alert if qty has changed
   if QoH == prevQoH then return end

   GoalIsMet = (QoH >= TitanItemCount.db.char.Goal)

   -- in case the quantity has gone down (sold, converted, turned in, whatever)
   if QoH < prevQoH and not GoalIsMet then AlreadyAlerted = false; end

   prevQoH = QoH

   if GoalIsMet and not FirstRun and not AlreadyAlerted then
      TitanItemCount:DoAlert()
      AlreadyAlerted = true
   end
   TitanPanelButton_UpdateButton(ID)
   elapQoH = 0
   FirstRun = false

end


function TitanPanelItmCButton_GetButtonText()
	local QoHtext, countcolor, alertcolor
	countcolor = C_WHITE  -- default white
	alertcolor = C_MGNTA  -- alert redviolet?
	QoHtext = "-"
	if not QoH then
	   QoH = 0
	end
	if TitanItemCount.db.char.Goal > 0 and GoalIsMet then
	   countcolor = alertcolor
	end
   QoHtext = countcolor..string.format(" %.0f ", QoH).."|r"
	if TitanGetVar(ID, "ShowItem") then
	   QoHtext = QoHtext..TitanItemCount.db.char.Item
	end
	return buttonlabel, QoHtext
end


function TitanPanelItmCButton_GetTooltipText()
   local ttString
   ttString = C_YELLOW.."Item \t"..C_WHITE..TitanItemCount.db.char.Item.."|r"..
      "\n"..C_YELLOW.."Qty on hand\t"..C_WHITE..string.format("%.0f", QoH).."|r"
   if TitanItemCount.db.char.Goal > 0 then
	   ttString = ttString..
	      "\n"..C_YELLOW.."Goal quantity\t"..C_WHITE..tostring(TitanItemCount.db.char.Goal).."|r"
	   ttString = ttString..
	      "\n"..C_YELLOW.."Alert Sound\t"..C_WHITE..tostring(TitanItemCount.db.char.BellSound).."|r"
      if GoalIsMet then
         ttString = ttString.."\n"..C_PURPLE.."GOAL QUANTITY ACHIEVED|r"
      end
	end
   ttString = ttString.."\n\n"..C_GREEN.."Left-click to open Options Panel,\n"..
      C_GREEN.."or use the "..C_WHITE.."/tic"..C_GREEN.." slash command."
   if AllowDebug and TitanGetVar(ID,"debug") then
      ttString = ttString.."\n"
      ttString = ttString.."\n"..C_YELLOW.."First Run:\t"..tostring(FirstRun)
      ttString = ttString.."\n"..C_YELLOW.."GoalIsMet:\t"..tostring(GoalIsMet)
      ttString = ttString.."\n"..C_YELLOW.."AlreadyAlerted:\t"..tostring(AlreadyAlerted)
      ttString = ttString.."\n"..C_YELLOW.."prevQoH:\t"..tostring(prevQoH)
   end
   return ttString
end


function TitanPanelItmCButton_OnShow(self)
	TitanPanelButton_OnShow(self);
end


function TitanPanelItmCButton_OnHide()
end


function TitanPanelItmCButton_OnClick(self, button)
   if (button == "LeftButton") then
      InterfaceOptionsFrame_OpenToCategory("Titan ItemCount")
   end
end


--[[
-- ------------------[ Titan Panel Functions ]---------------
]]--

local temp = {}
local function UIDDM_Add(text, func, checked, keepShown)
	temp.text, temp.func, temp.checked, temp.keepShownOnClick = text, 
	   func, checked, keepShown;
	UIDropDownMenu_AddButton(temp)
end


function TitanPanelRightClickMenu_PrepareItmCMenu(frame, level, menuList)
   local info = UIDropDownMenu_CreateInfo()
   if level == 1 then
      TitanPanelRightClickMenu_AddTitle(TitanPlugins[ID].menuText, level)
      info.text = "Alert Sound"
      info.menuList = "AlertSound"
      info.hasArrow = true
      info.notCheckable = true
      info.keepShownOnClick = true
      UIDropDownMenu_AddButton(info, level)
      TitanPanelRightClickMenu_AddToggleIcon(ID, level)
      TitanPanelRightClickMenu_AddToggleLabelText(ID, level)
      TitanPanelRightClickMenu_AddToggleVar("Show Item Name", ID, "ShowItem", nil, level)
      TitanPanelRightClickMenu_AddSpacer()
      if AllowDebug == true then
         TitanPanelRightClickMenu_AddToggleVar("Debug", ID, "debug", nil, level)
      end
      TitanPanelRightClickMenu_AddCommand("Hide", ID, TITAN_PANEL_MENU_FUNC_HIDE, level)
   elseif level == 2 and menuList == "AlertSound" then
      for k,v in pairs(Bells) do
         info.text = k
         info.value = k
         info.arg1 = k
         info.checked = (TitanItemCount.db.char.BellSound == k)
         info.func = function()
            TitanItemCount.db.char.BellSound = k
            PlaySoundFile(Bells[k], "Master")
            print(C_AQUA.."TitanItemCount"..": " ..C_YELLOW.. "alert sound is "..C_WHITE..TitanItemCount.db.char.BellSound)
         end
         UIDropDownMenu_AddButton(info, level)
      end
   end
      
end
