local Narci = Narci;
local NarciAnimationInfo = NarciAnimationInfo;
local FadeFrame = NarciFadeUI.Fade;

local After = C_Timer.After;

local BrowserFrame, QuickFavoriteButton;

local max = math.max;
local min = math.min;
local cos = math.cos;
local sin = math.sin;
local sqrt = math.sqrt;
local ceil = math.ceil;
local floor = math.floor;
local pow = math.pow;
local abs = math.abs;
local pi = math.pi;

local trim = strtrim;

local function outSine(t, b, e, d)
	return (e - b) * sin(t / d * (pi / 2)) + b
end

local function outQuart(t, b, e, d)
    t = t / d - 1;
    return (b - e) * (pow(t, 4) - 1) + b
end

local function FlyInText(button)
    local textWidth = button.Name:GetWidth();
    if textWidth > 94 then
        local offset = textWidth - 90;
        button.FlyIn:Stop();
        button.FlyIn.offset:SetOffset( -offset, 0 );
        button.FlyIn.offset:SetDuration( offset / 12);
        button.FlyIn:Play();
    end
end

local delayedAction = NarciAPI_CreateAnimationFrame(0.25);
delayedAction:SetScript("OnUpdate", function(self, elapsed)
    self.total = self.total + elapsed;
    if self.total >= self.duration then
        self:Hide();
        FlyInText(self.object);
    end
end)

local function AnimationButton_OnEnter(self)
    FadeFrame(self.Highlight, 0.12, 1);

    delayedAction:Hide();
    delayedAction.object = self;
    delayedAction:Show();

    local Star = QuickFavoriteButton;
    Star:ClearAllPoints();
    Star:SetPoint("CENTER", self.Star, "CENTER", 0.4, 0);   --Can't properly be aligned with it Why!!!!!!!
    Star.parent = self;
    Star:Show();
    Star.animationID = self.animationID;
    Star:SetFavorite(self.isFavorite);
end

local function AnimationButton_OnClick(self, button)
    local model = Narci:GetActiveActor();
    local id = self.animationID;
    model:PlayAnimation(id);
    NarciModelControl_AnimationIDEditBox:SetText(id);
    if button == "RightButton" then
        BrowserFrame:Close();
    end
end

----------------------------------------------------
--Animation Cache
local DataProvider = {};

DataProvider.playerAnimations = {};
DataProvider.npcAnimations = {};
if select(4, GetBuildInfo() ) > 89999 then
	DataProvider.maxAnimID = 1498 - 1;
else
	DataProvider.maxAnimID = 1484 - 1;
end


function DataProvider:GetAvailableAnimationsForModel(model, forcedUpdate)
    local type = model:GetObjectType();
    local id = model.buttonIndex;
    local animations;
    if type == "CinematicModel" then
        animations = self.npcAnimations;
    else
        animations = self.playerAnimations;
    end

    if (not model.isAnimationCached) or forcedUpdate then
        if animations[id] then
            wipe(animations[id]);
        else
            animations[id] = {};
        end

        for i = 0, self.maxAnimID do
            if model:HasAnimation(i) then
                tinsert(animations[id], { i, NarciAnimationInfo:GetInfo(i) } );
            end
        end
        model.isAnimationCached = true;
    end

    return animations[id];
end

----------------------------------------------------
--Animation Browser

NarciAnimationBrowserMixin = {};

function NarciAnimationBrowserMixin:OnLoad()
    BrowserFrame = self;

    --Expand Animation
    self:SetHeight(8);      --Collapsed Height
    self:SetAlpha(0);
    local animExpand = NarciAPI_CreateAnimationFrame(0.25);
    self.animExpand = animExpand;
    animExpand:SetScript("OnUpdate", function(frame, elapsed)
        frame.total = frame.total + elapsed;
        local height = outQuart(frame.total, frame.fromHeight, frame.toHeight, frame.duration);
        if frame.total >= frame.duration then
            height = frame.toHeight;
            frame:Hide();
        end
        self:SetHeight(height);
    end);
    
    --Expand Button
    local ExpandButton = self:GetParent().ExpandButton;
    self.ExpandButton = ExpandButton;
    self.ExpandArrow = ExpandButton.Arrow;


    --Create Buttons
    self.buttons = {};
    local buttons = self.buttons;
    

    --Scroll Frame
    local ScrollFrame = self.ScrollFrame;
    local renderRange = 18;
    local buttonHeight = 16;
    local numButtons = 12;
    local numButtonsPerPage = 8;
    
    local function UpdateRenderArea(scrollOffset, delta)
        local renderRange = renderRange;
        local pos = 1 + floor(scrollOffset / 16 + 0.5);
        for i = pos - renderRange, pos - renderRange - 4, -1 do
            if buttons[i] then
                buttons[i]:Hide();
            else
                break;
            end
        end

        for i = pos + renderRange, pos + renderRange + 4 do
            if buttons[i] then
                buttons[i]:Hide();
            else
                break;
            end
        end

        for i = pos - renderRange + 1, pos + renderRange - 1 do
            if buttons[i] then
                buttons[i]:Show();
            end
        end
    end

    local totalHeight = floor(numButtons * buttonHeight + 0.5);
    local maxScroll = floor((numButtons - numButtonsPerPage) * buttonHeight + 0.5);
    ScrollFrame.scrollBar:SetMinMaxValues(0, maxScroll)
    ScrollFrame.scrollBar:SetValueStep(0.001);
    ScrollFrame.buttonHeight = totalHeight;
    ScrollFrame.range = maxScroll;
    ScrollFrame.scrollBar:SetScript("OnValueChanged", function(bar, value)
        ScrollFrame:SetVerticalScroll(value);
        --UpdateInnerShadowStates(self, nil, false);
    end)
    NarciAPI_SmoothScroll_Initialization(ScrollFrame, nil, nil, 4/(numButtons), 0.14, nil, UpdateRenderArea);


    --Quick Favorite
    QuickFavoriteButton = ScrollFrame.QuickFavoriteButton;

    local IDEditbox = BrowserFrame:GetParent().IDEditBox;
    local IDEditboxFavoriteButton = BrowserFrame:GetParent().FavoriteButton;

    local function QuickFavoriteButton_OnClick(button)
        local isFavorite = not button.isFav;
        button.parent.isFavorite = isFavorite;
        button.isFav = isFavorite;

        local animationID = button.animationID;
        if isFavorite then
            NarciAnimationInfo:AddFavorite(button.animationID);
        else
            NarciAnimationInfo:RemoveFavorite(button.animationID);
        end
        button:PlayVisual();
        BrowserFrame.forcedUpdate = true;

        if IDEditbox:GetNumber() == animationID then
            IDEditboxFavoriteButton:SetVisual(isFavorite);
        end
    end

    QuickFavoriteButton:SetScript("OnClick", QuickFavoriteButton_OnClick);
end

local sort = table.sort;

local function SortFunc(a, b)
    --favorite, id -
    if a[3] ~= b[3] then
        return a[3]
    else
        return a[1] < b[1]
    end
end

function NarciAnimationBrowserMixin:RefreshList()
    --{id, name, isFavorite}
    sort(self.availableAnimations, SortFunc);
    After(0, function()
        self:UpdateButtons();
    end)
end

function NarciAnimationBrowserMixin:UpdateButtons()
    local button;
    local buttons = self.buttons;
    local ScrollChild = self.ScrollFrame.ScrollChild;
    local numButtons = #self.availableAnimations;
    local info;
    for i = 1, numButtons do
        if not buttons[i] then
            buttons[i] = CreateFrame("Button", nil, ScrollChild, "Narci_AnimationButtonTemplate");
            buttons[i]:SetScript("OnEnter", AnimationButton_OnEnter);
            buttons[i]:SetScript("OnClick", AnimationButton_OnClick);
        end
        button = buttons[i];
        button:SetPoint("TOP", ScrollChild, "TOP", 0, 16*(1 - i));

        info = self.availableAnimations[i];
        local id = info[1];
        local isFavorite = info[3];
        button.ID:SetText(id);
        button.Name:SetText(info[2]);
        button.Star:SetShown(isFavorite);
        button.animationID = id;
        button.isFavorite = isFavorite;

        if i <= 20 then
            button:Show();
            button.FlyIn:Stop();
        else
            button:Hide();
        end
    end

    local buttonHeight = 16;
    local numButtonsPerPage = 8;
    local totalHeight = floor(numButtons * buttonHeight + 0.5);
    local maxScroll = max(0, floor((numButtons - numButtonsPerPage) * buttonHeight + 0.5));
    self.ScrollFrame.scrollBar:SetMinMaxValues(0, maxScroll);
    self.ScrollFrame.range = maxScroll;
    self.ScrollFrame.scrollBar:SetValue(0);

    if maxScroll == 0 then
        self.ScrollFrame.scrollBar:Hide();
    else
        self.ScrollFrame.scrollBar:Show();
    end

    if numButtons < numButtonsPerPage then
        for i = numButtons + 1, numButtonsPerPage do
            if buttons[i] then
                buttons[i]:Hide();
            end
        end
    end

    self.Editbox.numResults = numButtons;

    QuickFavoriteButton:Hide();
end

function NarciAnimationBrowserMixin:RefreshFavorite(animationID)
    self.forcedUpdate = true;
    
    if self:IsShown() then
        local button;
        local buttons = self.buttons;
        local numButtons = #self.availableAnimations;
        for i = 1, numButtons do
            button = buttons[i];
            if button and (button.animationID == animationID) then
                local isFavorite = NarciAnimationInfo:IsFavorite(animationID);
                button.isFavorite = isFavorite;
                button.Star:SetShown(isFavorite);
                break
            end
        end

        self.forcedUpdate = true;
        QuickFavoriteButton:Hide();
    end
end

function NarciAnimationBrowserMixin:Open()
    local animExpand = self.animExpand;
    animExpand.fromHeight = self:GetHeight();
    animExpand.toHeight = 150;      --Full Height
    animExpand:Show();
    FadeFrame(self, 0.2, 1);
    self.ExpandArrow:SetTexCoord(0, 1, 0, 1);
end

function NarciAnimationBrowserMixin:Close()
    local animExpand = self.animExpand;
    animExpand.fromHeight = self:GetHeight();
    animExpand.toHeight = 8;        --Collapsed Height
    animExpand:Show();
    FadeFrame(self, 0.25, 0);
    self.ExpandArrow:SetTexCoord(0, 1, 1, 0);
end

function NarciAnimationBrowserMixin:Toggle()
    if self.animExpand:IsShown() then
        return
    end

    if self:IsShown() then
        self:Close();
    else
        if self.forcedUpdate then
            self.forcedUpdate = nil;
            self:BuildListForModel(true);
        else
            self:BuildListForModel();
        end
        After(0, function()
            self:Open();
        end)
    end
end

function NarciAnimationBrowserMixin:BuildListForModel(forcedUpdate)
    local model = Narci:GetActiveActor();
    local fileID = model:GetModelFileID();
    if fileID ~= self.lastFileID or forcedUpdate then
        self.lastFileID = fileID;
        self.availableAnimations = DataProvider:GetAvailableAnimationsForModel(model, forcedUpdate);
        self.Editbox:ClearText();
        self:RefreshList();
    end
end

function NarciAnimationBrowserMixin:OnShow()
    self:RegisterEvent("GLOBAL_MOUSE_DOWN");
    DataProvider.activeModel = Narci:GetActiveActor();
end

function NarciAnimationBrowserMixin:OnHide()
    self:UnregisterEvent("GLOBAL_MOUSE_DOWN");
end

function NarciAnimationBrowserMixin:OnEvent(event)
    if event == "GLOBAL_MOUSE_DOWN" then
        if not self:IsMouseOver(0, -20, 0, 0) then
            if not self.animExpand:IsShown() then
                self:Close();
            end
        end
    end
end

function NarciAnimationBrowserMixin:OnMouseDown()
    return
end

function NarciAnimationBrowserMixin:SearchAnimation(keyword)
    keyword = gsub(keyword, "^%s+", "");  --trim left
    if keyword and keyword ~= "" then
        self.availableAnimations = NarciAnimationInfo:SearchByName(keyword);
        self:RefreshList();
    else
        self:BuildListForModel(true);
    end
end

--------------------------------------------------
NarciAnimationSearchBoxMixin = {};

function NarciAnimationSearchBoxMixin:OnLoad()
    local delayedSearch = NarciAPI_CreateAnimationFrame(0.5);
    self.delayedSearch = delayedSearch;
    delayedSearch:SetScript("OnUpdate", function(frame, elapsed)
        frame.total = frame.total + elapsed;
        if frame.total >= frame.duration then
            frame:Hide();
            Narci_AnimationBrowser:SearchAnimation( self:GetText() )
        end
    end)
end

function NarciAnimationSearchBoxMixin:OnShow()
    if self.numResults then
        self.DefaultText:SetText("  ".. self.numResults.. " available");
    end
    self.DefaultText.FadeOut:Play();
    self:SetFocus();
end

function NarciAnimationSearchBoxMixin:OnHide()
    self:StopAnimating();
    self.delayedSearch:Hide();
end

function NarciAnimationSearchBoxMixin:OnEnter()
    self.DefaultText:SetTextColor(0.88, 0.88, 0.88);
end

function NarciAnimationSearchBoxMixin:OnLeave()
    if not self:IsMouseOver() then
        self.DefaultText:SetTextColor(0.72, 0.72, 0.72);
    end
end

function NarciAnimationSearchBoxMixin:OnTextChanged(isUserInput)
    local str = self:GetText();
    if str and str ~= "" then
        self.DefaultText:Hide();
        self.EraseButton:Show();
    else
        self.DefaultText:Show();
        self.EraseButton:Hide();
    end

    if isUserInput then
        self:Search(true);
    end
end

function NarciAnimationSearchBoxMixin:QuitEdit()
    self:ClearFocus();
end

function NarciAnimationSearchBoxMixin:ClearText(reset)
    self:SetText("");
    self.DefaultText:Show();
    self.EraseButton:Hide();
    if reset then
        --Unfilter search
        self:Search(true);
    end
end

function NarciAnimationSearchBoxMixin:OnTabPressed()
    self:HighlightText();
end

function NarciAnimationSearchBoxMixin:OnEditFocusGained()
    self:HighlightText();
end

function NarciAnimationSearchBoxMixin:OnEditFocusLost()
    --self.KeyListener:Hide();
    self:HighlightText(0, 0);
    self:OnLeave();

    if self:IsMouseOver() and IsMouseButtonDown("LeftButton") then
        self.EraseButton.isEditing = true;
    else
        self.EraseButton.isEditing = false;
    end
end

function NarciAnimationSearchBoxMixin:Search(on)
    self.delayedSearch:Hide();
    if on then
        self.delayedSearch:Show();
    end
end