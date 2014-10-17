local QuickMark = LibStub("AceAddon-3.0"):NewAddon("QuickMark", "AceConsole-3.0")

--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------
local borders = {
   ["Interface\\DialogFrame\\UI-DialogBox-Border"] = "Classic",
   ["Interface\\DialogFrame\\UI-DialogBox-Gold-Border"] = "Classic Gold",
   ["Interface\\Tooltips\\UI-Tooltip-Border"] = "Slick",
   ["Interface\\ACHIEVEMENTFRAME\\UI-Achievement-WoodBorder"] = "Wood",
   ["Interface\\FriendsFrame\\UI-Toast-Border"] = "Hefty",
   [""] = "None",
   ["Interface\\LFGFRAME\\LFGBorder"] = "Graphite"
}

local backgrounds = {
   ["Interface\\ChatFrame\\ChatFrameBackground"] = "ChatFrameBackground",
   ["Interface\\DialogFrame\\UI-DialogBox-Background"] = "DialogBoxBackground"
}

local options = {
    name = "QuickMark",
    handler = QuickMark,
    type = 'group',
    args = {
       -- Locking
       lock_gui = {type = 'toggle', name = 'Lock', desc = 'Lock the QuickMark bar.', set = 'ToggleLocked', get = 'IsLocked', cmdHidden = true, order = 1},
       lock =    {type = 'toggle', name = 'Lock', desc = 'Lock the QuickMark bar.', set = 'SetLocked',    get = 'IsLocked', guiHidden = true},
       l =       {type = 'toggle', name = 'Lock', desc = 'Lock the QuickMark bar.', set = 'SetLocked',    get = 'IsLocked', guiHidden = true},
       unlock =  {type = 'toggle', name = 'Lock', desc = 'Unlock the QuickMark bar.', set = 'SetUnlocked',  get = 'IsLocked', guiHidden = true},
       u =       {type = 'toggle', name = 'Lock', desc = 'Unlock the QuickMark bar.', set = 'SetUnlocked',  get = 'IsLocked', guiHidden = true},

       -- Hide
       hide_gui = {type = 'toggle', name = 'Hide', desc = 'Hide the QuickMark bar.', set = 'ToggleHidden', get = 'IsHidden', cmdHidden = true, order = 2},
       hide =    {type = 'toggle', name = 'Hide', desc = 'Hide the QuickMark bar.', set = 'SetHidden',    get = 'IsHidden', guiHidden = true},
       h =       {type = 'toggle', name = 'Hide', desc = 'Hide the QuickMark bar.', set = 'SetHidden',    get = 'IsHidden', guiHidden = true},

       -- Show
       show = {type = 'toggle', name = 'Show', desc = 'Show the QuickMark bar.', set = 'SetShown', get = 'IsShown', guiHidden = true},
       s =    {type = 'toggle', name = 'Show', desc = 'Show the QuickMark bar.', set = 'SetShown', get = 'IsShown', guiHidden = true},

       -------------------------------------------------------------------------
       -- APPEARANCE
       -------------------------------------------------------------------------
       appearance_header = {type = 'header', name = 'Appearance', order = 10},

       -- Border
       border = {type = 'select', name = 'Border', desc = 'Set the border of the QuickMark bar.', style = 'dropdown', set = 'SetBorder', get = 'GetBorder', values = borders, cmdHidden = true, order = 12},

       -- Background color
       background_color = {type = 'color', name = 'Background Color', desc = 'Set the color of the background of the QuickMark bar.', get = 'GetBackgroundColor', set = 'SetBackgroundColor', hasAlpha = true, cmdHidden = true, order = 11},

       -------------------------------------------------------------------------
       -- APPEARANCE
       -------------------------------------------------------------------------
       size_and_orientation_header = {type='header', name = 'Size and Orientation', order = 20},

       -- Flip
       flip = {type = 'toggle', name = 'Flip', desc = 'Invert the QuickMark bar orientation.', set = 'Flip', get = 'GetHorizontal', guiHidden = true},
       f =    {type = 'toggle', name = 'Flip', desc = 'Invert the QuickMark bar orientation.', set = 'Flip', get = 'GetHorizontal', guiHidden = true},

       -- Horizontal
       horizontal_gui = {type = 'toggle', name = 'Horizontal', desc = 'Display the QuickMark bar horizontally.', set = 'Flip',          get = 'GetHorizontal', cmdHidden = true},
       horizontal =    {type = 'toggle', name = 'Horizontal', desc = 'Display the QuickMark bar horizontally.', set = 'SetHorizontal', get = 'GetHorizontal', guiHidden = true },
       hor =           {type = 'toggle', name = 'Horizontal', desc = 'Display the QuickMark bar horizontally.', set = 'SetHorizontal', get = 'GetHorizontal', guiHidden = true},

       -- Vertical
       vertical = {type = 'toggle', name = 'Vertical', desc = 'Display the QuickMark bar vertically.', set = 'SetVertical', get = 'GetVertical', guiHidden = true},
       vert =     {type = 'toggle', name = 'Vertical', desc = 'Display the QuickMark bar vertically.', set = 'SetVertical', get = 'GetVertical', guiHidden = true},

       -- Toggle
       toggle = {type = 'toggle', name = 'Toggle', desc = 'Toggle the display of the QuickMark bar.', set = 'ToggleHidden', get = 'IsHidden', guiHidden = true},
       t =      {type = 'toggle', name = 'Toggle', desc = 'Toggle the display of the QuickMark bar.', set = 'ToggleHidden', get = 'IsHidden', guiHidden = true},

       -- Scale
       scale = {type = 'range', name = 'Scale', desc = 'Scale controls the size of the QuickMark bar.', set = 'SetScale', get = 'GetScale', min = 0.1, max = 5.0, cmdHidden = true},
    },
}

LibStub("AceConfigDialog-3.0"):AddToBlizOptions("QuickMark", "QuickMark")
LibStub("AceConfig-3.0"):RegisterOptionsTable("QuickMark", options, {"quickmark", "qm"})
local AceGUI = LibStub("AceGUI-3.0")

--------------------------------------------------------------------------------
-- QUICKMARK FRAME CREATION FUNCTION
--------------------------------------------------------------------------------
function QuickMark:CreateQuickMarkFrame()
   local qmFrame = AceGUI:Create("QuickMarkFrame")

   for i=1, 8 do
      local targetIcon = AceGUI:Create("Icon")
      targetIcon:SetImage("INTERFACE/TARGETINGFRAME/UI-RaidTargetingIcon_" .. i)
      targetIcon:SetWidth(20)
      targetIcon:SetHeight(20)
      targetIcon:SetImageSize(20,20)
      targetIcon:SetCallback("OnClick", function(self, button)
                                           if GetRaidTargetIndex("target") ~= i then
                                              SetRaidTarget("target", i)
                                           else
                                              SetRaidTarget("target", 0)
                                           end
                                        end)
      qmFrame:AddChild(targetIcon)
   end

   return qmFrame
end

local QM_FRAME = QuickMark:CreateQuickMarkFrame()
local DEBUG = false

--------------------------------------------------------------------------------
-- Layout
--------------------------------------------------------------------------------
function QuickMark:SetHorizontalLayout()
   QM_FRAME:SetWidth(195)
   QM_FRAME:SetHeight(48)
   QM_FRAME:SetLayout("Flow")
   self.db.char.horizontal = true
   if DEBUG then QuickMark:Print("Horizontal Layout") end
   return self.db.char.horizontal
end

function QuickMark:SetVerticalLayout()
   QM_FRAME:SetWidth(45)
   QM_FRAME:SetHeight(260)
   QM_FRAME:SetLayout("List")
   QuickMark.db.char.horizontal = false
   if DEBUG then QuickMark:Print("Vertical Layout") end
   return self.db.char.horizontal
end

function QuickMark:GetHorizontal(info)
   return self.db.char.horizontal
end

function QuickMark:SetHorizontal(info, input)
   return QuickMark:SetHorizontalLayout()
end

function QuickMark:GetVertical(info)
   return not self.db.char.horizontal
end

function QuickMark:SetVertical(info, input)
   return QuickMark:SetVerticalLayout()
end

function QuickMark:Flip(info, input)
   if self.db.char.horizontal then
      QuickMark:SetVerticalLayout()
   else
      QuickMark:SetHorizontalLayout()
   end
end

--------------------------------------------------------------------------------
-- Locking
--------------------------------------------------------------------------------
function QuickMark:Lock()
   QM_FRAME:Lock()
   self.db.char.locked = true
   if DEBUG then QuickMark:Print("Locked") end
end

function QuickMark:Unlock()
   QM_FRAME:Unlock()
   self.db.char.locked = false
   if DEBUG then QuickMark:Print("Unlocked") end
end

function QuickMark:IsLocked(info)
   return self.db.char.locked
end

function QuickMark:ToggleLocked(info, input)
   if self.db.char.locked then
      QuickMark:Unlock()
   else
      QuickMark:Lock()
   end
end

function QuickMark:SetLocked(info, input)
   QuickMark:Lock()
end

function QuickMark:SetUnlocked(info, input)
   QuickMark:Unlock()
end

--------------------------------------------------------------------------------
-- Positioning
--------------------------------------------------------------------------------
function QuickMark:SetPosition(point, relativePoint, x, y)
   QM_FRAME:ClearAllPoints()
   QM_FRAME:SetPoint(point, UIParent, relativePoint, x, y)
   if DEBUG then
      QuickMark:Print("Positioning at " .. x .. ", " .. y .. " relative to " .. relativePoint)
   end
end

--------------------------------------------------------------------------------
-- Scaling
--------------------------------------------------------------------------------
function QuickMark:Scale(scale)
   QM_FRAME.frame:SetScale(scale)
   self.db.char.scale = scale
   if DEBUG then QuickMark:Print("Scale set to " .. scale*100 .. "%") end
end

function QuickMark:GetScale(info)
   return self.db.char.scale
end

function QuickMark:SetScale(info, scale)
   QuickMark:Scale(scale)
end

--------------------------------------------------------------------------------
-- Displaying
--------------------------------------------------------------------------------
function QuickMark:Toggle()
   if self.db.char.hidden then
      return QuickMark:Show()
   else
      return QuickMark:Hide()
   end
end

function QuickMark:Show()
   QM_FRAME:Show()
   self.db.char.hidden = false
   if DEBUG then QuickMark:Print("Shown") end
end

function QuickMark:Hide()
   QM_FRAME:Hide()
   self.db.char.hidden = true
   if DEBUG then QuickMark:Print("Hidden") end
end

function QuickMark:IsShown(info)
   return not self.db.char.hidden
end

function QuickMark:IsHidden(info)
   return self.db.char.hidden
end

function QuickMark:SetShown(info, input)
   QuickMark:Show()
end

function QuickMark:SetHidden(info, input)
   QuickMark:Hide()
end

function QuickMark:ToggleHidden(info, input)
   if self.db.char.hidden then
      QuickMark:Show()
   else
      QuickMark:Hide()
   end
end

--------------------------------------------------------------------------------
-- Appearance
--------------------------------------------------------------------------------
function QuickMark:Border(edge_file)
   self.db.char.edge_file = edge_file
   QM_FRAME:SetBackdrop(self.db.char.edge_file, self.db.char.bg_color_r, self.db.char.bg_color_g, self.db.char.bg_color_b, self.db.char.bg_color_a)
   if DEBUG then QuickMark:Print("Border changed") end
end

function QuickMark:GetBorder(info, input)
   return self.db.char.edge_file
end

function QuickMark:SetBorder(info, input)
   QuickMark:Border(input)
end

function QuickMark:BackgroundColor(r, g, b, a)
   self.db.char.bg_color_r = r
   self.db.char.bg_color_g = g
   self.db.char.bg_color_b = b
   self.db.char.bg_color_a = a
   QM_FRAME:SetBackdrop(self.db.char.edge_file, self.db.char.bg_color_r, self.db.char.bg_color_g, self.db.char.bg_color_b, self.db.char.bg_color_a)
   if DEBUG then QuickMark:Print("Color changed") end
end

function QuickMark:GetBackgroundColor(info, r, g, b, a)
   return self.db.char.bg_color_r, self.db.char.bg_color_g, self.db.char.bg_color_b, self.db.char.bg_color_a
end

function QuickMark:SetBackgroundColor(info, r, g, b, a)
   QuickMark:BackgroundColor(r,g,b,a)
end

-- DEPRECATED: Only here for those using the 2.0 API, use QuickMark:Toggle() instead.
function QuickMark_ToggleForm()
   QuickMark:Toggle()
end

--------------------------------------------------------------------------------
-- Load Settings
--------------------------------------------------------------------------------
function QuickMark:LoadSettings()
   -- Set Position
   if self.db.char.point ~= nil then
      QuickMark:SetPosition(self.db.char.point, self.db.char.relativePoint, self.db.char.xOfs, self.db.char.yOfs)
   end

   -- Set Orientation
   if self.db.char.horizontal then
      QuickMark:SetHorizontalLayout()
   else
      QuickMark:SetVerticalLayout()
   end

   -- Set Locked Status
   if self.db.char.locked then
      QuickMark:Lock()
   else
      QuickMark:Unlock()
   end

   -- Set Hidden Status
   if self.db.char.hidden then
      QuickMark:Hide()
   else
      QuickMark:Show()
   end

   -- Set Scale
   if self.db.char.scale then
      QuickMark:Scale(self.db.char.scale)
   else
      QuickMark:Scale(1.0)
   end

   -- Set Border
   if self.db.char.edge_file then
      QuickMark:Border(self.db.char.edge_file)
   else
      QuickMark:Border("Interface\\Tooltips\\UI-Tooltip-Border")
   end

   if self.db.char.bg_color_r and self.db.char.bg_color_g and self.db.char.bg_color_b and self.db.char.bg_color_a then
      QuickMark:BackgroundColor(self.db.char.bg_color_r, self.db.char.bg_color_g, self.db.char.bg_color_b, self.db.char.bg_color_a)
   else
      QuickMark:BackgroundColor(0,0,0,0.3)
   end

end

--------------------------------------------------------------------------------
-- INITIALIZATION FUNCTION
--------------------------------------------------------------------------------
function QuickMark:OnInitialize()
   if DEBUG then QuickMark:Print("Initializing settings") end

   self.db = LibStub("AceDB-3.0"):New("QuickMarkDB")

   -- XXX: This might have performance problems but it is safe in terms of data consistency.
   QM_FRAME.frame:SetScript("OnLeave", function()
                                        point, relativeTo, relativePoint, xOfs, yOfs = QM_FRAME.frame:GetPoint()
                                        if relativeTo == nil then
                                           self.db.char.point = point
                                           self.db.char.relativePoint = relativePoint
                                           self.db.char.xOfs = xOfs
                                           self.db.char.yOfs = yOfs
                                           if DEBUG then
                                              QuickMark:Print("Positioning at " .. point .. " at "  .. xOfs .. ", " .. yOfs .. " relative to " .. relativePoint)
                                           end
                                        end
                                     end)

   QuickMark:LoadSettings()
end

function QuickMark:OnEnable()
   if DEBUG then QuickMark:Print("Enabled") end
end

function QuickMark:OnDisable()
   if DEBUG then QuickMark:Print("Disabled") end
end