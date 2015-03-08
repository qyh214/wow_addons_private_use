-- **************************************************************************
-- * Titan Currency .lua - VERSION 5.4
-- **************************************************************************
-- * by Greenhorns @ Vek'Nilash
-- * This mod will display all the Currency you have on the curent toon
-- * in a tool tip.  It shows the curent Toons Gold amount on the Titan Panel
-- * bar.
-- *
-- **************************************************************************

-- ******************************** Constants *******************************
local TITAN_CURRENCY_ID = "Currency";
local TITAN_CURRENCY_COUNT_FORMAT = "%d";
local TITAN_CURRENCY_VERSION = "5.1";
local TITAN_CURRENCY_SPACERBAR = "--------------------";
local TITAN_CURRENCY_BLUE = {r=0.4,b=1,g=0.4};
local TITAN_CURRENCY_RED = {r=1,b=0,g=0};
local TITAN_CURRENCY_GREEN = {r=0,b=0,g=1};
-- ******************************** Variables *******************************
local CURRENCY_INITIALIZED = false;
local CURRENCY_VARIABLES_LOADED = false;
local CURRENCY_ENTERINGWORLD = false;
local CURRENCY_INDEX = "";
local CURRENCY_COLOR;
local CURRENCY_SESS_STATUS;
local CURRENCY_PERHOUR_STATUS;
local CURRENCY_STARTINGGOLD;
local CURRENCY_SESSIONSTART;
local REMEMBER_VIEWALL;
local REMEMBER_SORTBYNAME;
local REMEMBER_SHOWGPH;
local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)
local LB = LibStub("AceLocale-3.0"):GetLocale("Titan_Currency", true)
local TitanCurrency = LibStub("AceAddon-3.0"):NewAddon("TitanCurrency", "AceHook-3.0", "AceTimer-3.0")
local CurrencyTimer = nil;
local _G = getfenv(0);
-- ******************************** Functions *******************************

-- **************************************************************************
-- NAME : TitanPanelCurrencyButton_OnLoad()
-- DESC : Registers the add on upon it loading
-- **************************************************************************
function TitanPanelCurrencyButton_OnLoad(self)
     self.registry = { 
          id = TITAN_CURRENCY_ID,
          -- builtIn = nil,
          category = "Information",
          version = TITAN_CURRENCY_VERSION,
          menuText = LB["TITAN_CURRENCY_MENU_TEXT"], 
          tooltipTitle = LB["TITAN_CURRENCY_TOOLTIP"],
          tooltipTextFunction = "TitanPanelCurrencyButton_GetTooltipText",
          buttonTextFunction = "TitanPanelCurrencyButton_GetButtonText",
        controlVariables = {
			DisplayOnRightSide = true,
		},
        savedVariables = {
			DisplayOnRightSide = false,             
		},
     };

     self:RegisterEvent("PLAYER_ENTERING_WORLD");
     self:RegisterEvent("PLAYER_MONEY");
     self:RegisterEvent("VARIABLES_LOADED");
     self:RegisterEvent("UNIT_NAME_UPDATE");
     MoneyFrame_Update("TitanPanelCurrencyButton", TitanPanelCurrencyButton_FindGold());
     -- support for picking up money     
     
     if (not CurrencyArray) then 
          CurrencyArray={};
          CurrencyArray["VIEWALL"] = true
          CurrencyArray["DISPLAYGPH"] = true
     end
     
end

function TitanCurrency_OnEvent(self, event, ...)

     if (event == "VARIABLES_LOADED") then
          CURRENCY_VARIABLES_LOADED = true;
          if (CURRENCY_ENTERINGWORLD) then
               TitanPanelCurrencyButton_Initialize_Array(self);
          end
          return;
     end

     if ( event == "PLAYER_ENTERING_WORLD" ) then
          CURRENCY_ENTERINGWORLD = true;
          if (CURRENCY_VARIABLES_LOADED) then          		
               TitanPanelCurrencyButton_Initialize_Array(self);
          end
          return;
     end

     if (event == "PLAYER_MONEY") then
          if (CURRENCY_INITIALIZED) then
               MoneyFrame_Update("TitanPanelCurrencyButton", TitanPanelCurrencyButton_FindGold());
          end
          return;
     end
end
 
-- *******************************************************************************************
-- NAME: TitanPanelCurrencyButton_GetTooltipText()
-- DESC: Gets our tool-tip text, what appears when we hover over our item on the Titan bar.
-- *******************************************************************************************
function TitanPanelCurrencyButton_GetTooltipText()
   local display="";
   local tooltip="";
   local name, isHeader, isExpanded, isUnused, isWatched, count, icon, maximum, hasWeeklyLimit, currentWeeklyAmount, unknown;
   cCount = GetCurrencyListSize();
   for index=1, cCount do 
      name, isHeader, isExpanded, isUnused, isWatched, count, icon, maximum, hasWeeklyLimit, currentWeeklyAmount, unknown = GetCurrencyListInfo(index)
      if (count~=0) and not isUnused then
            if icon~=nil then
         display=name.."--".."\t"..count.." |T"..icon..":16|t"
            end
         -- trace(display)
         tooltip=strconcat(tooltip,display,"|r\n")
      end
      
      
      myindex=index
   end 
final_tooltip=tooltip
     return ""..final_tooltip;    
end


-- *******************************************************************************************
-- NAME: TitanPanelCurrencyButton_FindGold()
-- DESC: This routines determines which gold total the ui wants (server or player) then calls it and returns it
-- *******************************************************************************************
function TitanPanelCurrencyButton_FindGold()
     
    
    local ttlgold = 0;
    ttlgold = GetMoney("player");
    return ttlgold;
end


function TitanPanelCurrencyButton_Initialize_Array(self)

     if (not CurrencyArray["INITIALIZED"]) then
          CurrencyArray = {};
          CurrencyArray["INITIALIZED"] = true;
          CurrencyArray["VIEWALL"] = true;
          CurrencyArray["DISPLAYGPH"] = true;
          CurrencyArray["SORTBYNAME"] = true;
          CurrencyArray["VERSION2"] = true;
     end


     CURRENCY_INITIALIZED = true;
     MoneyFrame_Update("TitanPanelCurrencyButton", TitanPanelCurrencyButton_FindGold());
end

function TitanPanelCurrency_BreakMoney(money)
     -- Non-negative money only
     if (money >= 0) then
          local gold = floor(money / (COPPER_PER_SILVER * SILVER_PER_GOLD));
          local silver = floor((money - (gold * COPPER_PER_SILVER * SILVER_PER_GOLD)) / COPPER_PER_SILVER);
          local copper = mod(money, COPPER_PER_SILVER);
          return gold, silver, copper;
     end
end     

