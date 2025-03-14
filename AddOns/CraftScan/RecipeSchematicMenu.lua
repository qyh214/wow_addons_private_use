local CraftScan = select(2, ...)

local LID = CraftScan.CONST.TEXT;
local function L(id)
    return CraftScan.LOCAL:GetText(id);
end

CRAFT_SCAN_EXCLUSION_INSTRUCTIONS = L(LID.EXCLUSION_INSTRUCTIONS)
CRAFT_SCAN_KEYWORD_INSTRUCTIONS = L(LID.KEYWORD_INSTRUCTIONS)
CRAFT_SCAN_GREETING_INSTRUCTIONS = L(LID.GREETING_INSTRUCTIONS)
CRAFT_SCAN_SECONDARY_KEYWORD_INSTRUCTIONS = L(LID.SECONDARY_KEYWORD_INSTRUCTIONS);
CRAFT_SCAN_COMMISSION_INSTRUCTIONS = L(LID.COMMISSION_INSTRUCTIONS);

-- References to our saved variables. These are populated as we get the
-- information needed to populate them.
local cur = {}
local playerNameWithRealm = nil;
local db_player = nil
local db_prof = nil
local db_parent_prof = nil
local db_recipes = nil

local saved = CraftScan.Utils.saved

local function dbCat(createDefault)
    local db_cats = saved(db_prof, 'categories', createDefault and {} or nil)
    return saved(db_cats, cur.recipe.categoryID, createDefault and {} or nil)
end

local function canShowScanButton()
    return cur.recipe and cur.recipe.learned and not cur.recipe.isRecraft
end

-- When the user checks 'Scan all recipes', we need to remember which recipes
-- this character has learned so we can reply to them on alts. We create
-- recipeID entries for each learned recipe, but we don't touch the enabled
-- state, so that when unchecked, each recipe remembers its prior enabled state.
local function scanAllRecipes()
    -- This returns all recipes for all expansions. There must be a better way
    -- to filter it to only the current expansion, but not finding it, so we
    -- manually look up the profession of each recipe and ignore those that
    -- don't match the current expansion profession.
    for _, id in pairs(C_TradeSkillUI.GetAllRecipeIDs()) do
        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(id)
        local profInfo = C_TradeSkillUI.GetProfessionInfoByRecipeID(id)
        if profInfo.professionID == cur.profession.professionID and recipeInfo.learned then
            saved(db_recipes, id, {})
        end
    end
end

local function clearEmptyRecipes()
    local toBeRemoved = {}
    for key, value in pairs(db_recipes) do
        if not next(value) then
            table.insert(toBeRemoved, key)
        end
    end
    for _, key in ipairs(toBeRemoved) do
        db_recipes[key] = nil
    end
end

local scanEnabledCheckBox
local menuShownButton
local menuFrames = {}
local function onSchematicChange()
    if scanEnabledCheckBox then
        scanEnabledCheckBox.updateDisplay()
    end

    if menuShownButton.isSelected then
        for _, entry in ipairs(menuFrames) do
            entry.updateDisplay()
        end
    end
end

CraftScan_CraftScanFrameMixin = {}

CraftScan_CraftScanFrame_HelpPlate =
{
    FramePos = { x = 5, y = -22 },
};

-- Now that the layout is complete and we know where the frames will be
-- located, we can wrap each frame in its help box.
local function HelpFrameAttributes(frame, description, rightXPadding, leftXPadding)
    -- Lots of wonky offsets here, but this gets it wrapping all the frames
    -- we need in a generic way, but it's gross. I'm not understanding
    -- something about how it works. The examples in Bliz code are all
    -- hardcoded positions, so maybe it's just a wonky API.
    local pX = frame:GetLeft() - CraftScanFrame.ScrollFrame.Content:GetLeft();
    local pY = frame:GetTop() - CraftScanFrame.ScrollFrame.Content:GetTop();
    local width = frame:GetWidth();
    if frame.label then
        width = width + frame.label:GetWidth() + 20;
    end
    width = width + (rightXPadding or 0) + (leftXPadding or 0);
    pX = pX - (leftXPadding or 0);
    local height = frame:GetHeight();
    return {
        ButtonPos = { x = pX + width - 35, y = pY + 32 },
        HighLightBox = { x = pX - 15, y = pY + 22, width = width + 15, height = height + 3 },
        ToolTipDir = "RIGHT",
        ToolTipText = L(description),
    };
end

local categoryLabel = nil;
local professionLabel = nil;
local expansionLabel = nil;

function CraftScan_CraftScanFrameMixin:ShowTutorial()
    -- We want out help content to be in the scroll window, so we replace its
    -- parent while we show it, and set it up restore original values when
    -- hidden.

    -- XXX: The simple act of setting any parent except UIParent for any amount
    -- of time causes the the collapse animation to no longer work on any other
    -- help boxes. I doubt many people are scrolling around various places askin
    -- for help, and it's just an animation, so oh well.
    local helpPlateParent = HelpPlate:GetParent();
    local helpPlateFrameLevel = HelpPlate:GetFrameLevel();

    HelpPlate:SetParent(self.ScrollFrame.Content)
    HelpPlate:SetFrameLevel(1000)

    local function UpdateHelp(index, frame, description, rightXPadding, leftXPadding)
        CraftScan_CraftScanFrame_HelpPlate[index] = HelpFrameAttributes(frame, description, rightXPadding, leftXPadding);
    end

    UpdateHelp(1, categoryLabel, LID.HELP_CATEGORY_SECTION, 20);
    UpdateHelp(2, expansionLabel, LID.HELP_EXPANSION_SECTION, 20);
    UpdateHelp(3, professionLabel, LID.HELP_PROFESSION_SECTION, 20);

    HelpPlate_Show(CraftScan_CraftScanFrame_HelpPlate, self.ScrollFrame.Content, self.TutorialButton);

    HelpPlate:SetScript("OnHide", function(self)
        HelpPlate:SetScript("OnHide", nil);

        HelpPlate:SetParent(helpPlateParent);
        helpPlateParent = nil;

        HelpPlate:SetFrameLevel(helpPlateFrameLevel);
        helpPlateFrameLevel = nil;
    end);
end

function CraftScan_CraftScanFrameMixin:IsTutorialShown()
    return HelpPlate_IsShowing(CraftScan_CraftScanFrame_HelpPlate);
end

function CraftScan_CraftScanFrameMixin:OnHide()
    if HelpPlate_IsShowing(CraftScan_CraftScanFrame_HelpPlate) then
        HelpPlate_Hide(false);
    end
end

function CraftScan_CraftScanFrameMixin:ToggleTutorial()
    if self:IsTutorialShown() then
        HelpPlate_Hide(true);
    else
        self:ShowTutorial();
    end
end

function CraftScan.UpdateShowButtonHeight()
    if menuShownButton then
        if CraftScan.DB.settings.show_button_height then
            menuShownButton:SetPoint("TOPLEFT", ProfessionsFrame.CraftingPage.SchematicForm, "BOTTOMLEFT", 2,
                -4 + CraftScan.DB.settings.show_button_height);
        else
            menuShownButton:SetPoint("TOPLEFT", ProfessionsFrame.CraftingPage.SchematicForm, "BOTTOMLEFT", 2, -4);
        end
    end
end

local menuShownButtonInitialized = false;
local function CreateMenuShownButton()
    menuShownButton = CreateFrame("Button", "ToggleScannerConfigButton",
        ProfessionsFrame.CraftingPage.SchematicForm,
        "CraftScan_ScannerConfigButtonTemplate");
    menuShownButton:SetText(L(LID.SCANNER_CONFIG_SHOW));
    CraftScan.UpdateShowButtonHeight();
    menuShownButtonInitialized = true;
end

CraftScan_CloseCraftScanFrameMixin = {}

function CraftScan_CloseCraftScanFrameMixin:OnClick(button)
    menuShownButton:OnClick();
end

local function OnConfigChange()
    CraftScanComm:ShareCharacterModification(playerNameWithRealm, cur.profession.parentProfessionID);
    CraftScan.Scanner.LoadConfig()
end

-- Create and position the frames we'll need for user input.
-- onSchematicChange will reference these frames and update their visibility and state.
local menuInitialized = false
local function initMenu()
    if not menuShownButtonInitialized then
        CreateMenuShownButton()
    end

    scanEnabledCheckBox = CraftScan.Frames.createCheckBox(L(LID.ITEM_SCAN_CHECK),
        ProfessionsFrame.CraftingPage.SchematicForm,
        function(self, button, down)
            saved(db_recipes, cur.recipe.recipeID, {}).enabled = self:GetChecked()
            onSchematicChange()
            OnConfigChange();
        end, function()
            local db_recipe = cur.recipe and saved(db_recipes, cur.recipe.recipeID)
            local isChecked = db_recipe and db_recipe.enabled;
            local isShown = canShowScanButton();

            -- Was originally hiding the checkbox. Swapped to disabling it instead.
            scanEnabledCheckBox:SetEnabled(not db_prof.all_enabled);

            return isShown and (isChecked or db_prof.all_enabled), isShown;
        end)
    scanEnabledCheckBox:SetPoint("TOPLEFT", menuShownButton, "TOPRIGHT", 2, 1);

    local frame = CraftScanFrame

    frame:SetTitle(L(LID.CRAFT_SCAN_OPTIONS));
    frame:SetParent(ProfessionsFrame.CraftingPage.SchematicForm)
    frame:ClearAllPoints()
    frame:SetPoint("TOPLEFT", ProfessionsFrame, "TOPRIGHT", 12)
    CraftScan.Frames.makeMovable(frame)

    local scrollFrame = frame.ScrollFrame;
    local contentFrame = scrollFrame.Content

    -- The global menu for all professions
    local exclusions = CraftScan.Frames.createTextInput(nil, contentFrame, 335, 30,
        L("Excluded keywords"),
        CraftScan.DB.settings.exclusions,
        "CraftScan_Exclusions", function(self)
            CraftScan.DB.settings.exclusions = self:GetText()
            OnConfigChange();
        end,
        nil,
        scrollFrame);
    local inclusions = CraftScan.Frames.createTextInput(nil, contentFrame, 335, 30, L("Keywords"),
        CraftScan.DB.settings.inclusions,
        "CraftScan_Keywords",
        function(self)
            CraftScan.DB.settings.inclusions = self:GetText()
            OnConfigChange();
        end,
        nil,
        scrollFrame)

    -- The parent profession menu
    local profKeywords = CraftScan.Frames.createTextInput(nil, contentFrame, 335, 30, L("Keywords"), nil,
        "CraftScan_Keywords",
        function(self)
            db_parent_prof.keywords = self:GetText()
            OnConfigChange();
        end, function()
            return db_parent_prof.keywords or
                L(CraftScan.CONST.PROFESSION_DEFAULT_KEYWORDS[cur.profession.parentProfessionID])
        end,
        scrollFrame)

    local profExclusions = CraftScan.Frames.createTextInput(nil, contentFrame, 335, 30, L("Excluded keywords"), nil,
        "CraftScan_Exclusions",
        function(self)
            db_parent_prof.exclusions = self:GetText()
            OnConfigChange();
        end, function()
            return db_parent_prof.exclusions or ""
        end,
        scrollFrame)

    -- The profession menu
    local profEnableAll = CraftScan.Frames.createCheckBox(L(LID.SCAN_ALL_RECIPES), contentFrame,
        function(self, button, down)
            db_prof.all_enabled = self:GetChecked()
            if db_prof.all_enabled then
                scanAllRecipes()
            else
                clearEmptyRecipes()
            end
            onSchematicChange()
            OnConfigChange();
        end, function()
            return db_prof.all_enabled, true
        end)
    local profIsPrimary = CraftScan.Frames.createCheckBox(L("Primary expansion"), contentFrame,
        function(self, button, down)
            local isChecked = self:GetChecked()
            db_parent_prof.primary_expansion = isChecked and cur.profession.professionID or nil
            OnConfigChange();
        end, function()
            return db_parent_prof.primary_expansion and db_parent_prof.primary_expansion == cur.profession.professionID,
                true
        end)
    local profGreeting = CraftScan.Frames.createTextInput(nil, contentFrame, 335, 45, L("Profession greeting"), nil,
        "CraftScan_Greeting",
        function(self)
            db_prof.greeting = self:GetText()
            OnConfigChange();
        end, function()
            return db_prof.greeting or ""
        end,
        scrollFrame)
    local profCommission = CraftScan.Frames.createTextInput(nil, contentFrame, 335, 30, L("Profession commission"), nil,
        "CraftScan_CommissionInput",
        function(self)
            db_prof.commission = self:GetText()
        end, function()
            return db_prof.commission or ""
        end,
        scrollFrame)
    profCommission.needsExtraYPadding = 20; -- No idea why, but this one does

    -- The category (Weapons/Armory/Toxic etc...) menu
    local catKeywords = CraftScan.Frames.createTextInput(nil, contentFrame, 335, 30, L("Keywords"), nil,
        "CraftScan_Keywords",
        function(self)
            dbCat(true).keywords = self:GetText()
            OnConfigChange();
        end, function()
            local db_cat = dbCat()
            return db_cat and db_cat.keywords or ""
        end,
        scrollFrame)
    local catGreeting = CraftScan.Frames.createTextInput(nil, contentFrame, 335, 45, L("Category greeting"), nil,
        "CraftScan_Greeting",
        function(self)
            dbCat(true).greeting = self:GetText()
            OnConfigChange();
        end, function()
            local db_cat = dbCat()
            return db_cat and db_cat.greeting or ""
        end,
        scrollFrame)
    local catOverride = CraftScan.Frames.createCheckBox(L("Override greeting"), contentFrame,
        function(self, button, down)
            dbCat(true).override = self:GetChecked()
            OnConfigChange();
        end, function()
            local db_cat = dbCat()
            return db_cat and db_cat.override, true
        end)

    -- The specific item menu
    local itemKeywords = CraftScan.Frames.createTextInput(nil, contentFrame, 335, 30, L("Keywords"), "",
        "CraftScan_Keywords",
        function(self)
            saved(db_recipes, cur.recipe.recipeID, {}).keywords = self:GetText()
            OnConfigChange();
        end, function()
            local db_recipe = saved(db_recipes, cur.recipe.recipeID)
            return db_recipe and db_recipe.keywords or ""
        end,
        scrollFrame)
    local itemSecondaryKeywords = CraftScan.Frames.createTextInput(nil, contentFrame, 335, 30, L("Secondary Keywords"),
        "",
        "CraftScan_SecondaryKeywords",
        function(self)
            saved(db_recipes, cur.recipe.recipeID, {}).secondary_keywords = self:GetText()
            OnConfigChange();
        end, function()
            local db_recipe = saved(db_recipes, cur.recipe.recipeID)
            return db_recipe and db_recipe.secondary_keywords or ""
        end,
        scrollFrame)

    local itemGreeting = CraftScan.Frames.createTextInput(nil, contentFrame, 335, 45, L("Item greeting"), "",
        "CraftScan_Greeting",
        function(self)
            saved(db_recipes, cur.recipe.recipeID, {}).greeting = self:GetText()
            OnConfigChange();
        end, function()
            local db_recipe = saved(db_recipes, cur.recipe.recipeID)
            return db_recipe and db_recipe.greeting or ""
        end,
        scrollFrame)
    local itemCommission = CraftScan.Frames.createTextInput(nil, contentFrame, 335, 22, L("Commission"), "",
        "CraftScan_CommissionInput",
        function(self)
            saved(db_recipes, cur.recipe.recipeID, {}).commission = self:GetText()
        end, function()
            local db_recipe = saved(db_recipes, cur.recipe.recipeID)
            return db_recipe and db_recipe.commission or "";
        end,
        scrollFrame)

    local itemOverride = CraftScan.Frames.createCheckBox(L("Override greeting"), contentFrame,
        function(self, button, down)
            saved(db_recipes, cur.recipe.recipeID, {}).override = self:GetChecked()
            OnConfigChange();
        end, function()
            local db_recipe = saved(db_recipes, cur.recipe.recipeID)
            return db_recipe and db_recipe.override, true
        end)

    CraftScan_CraftScanFrame_HelpPlate.FrameSize = { width = contentFrame:GetWidth(), height = contentFrame:GetHeight() };

    -- Arrange the frames via the organizer helper
    local anchor = AnchorUtil.CreateAnchor("TOPLEFT", contentFrame, "TOPLEFT");
    local organizer = CraftScan.Frames.CreateVerticalLayoutOrganizer(anchor, 5, 5);
    local sectionOrganizer, sectionFrame

    local function add(frame, yPadding)
        sectionOrganizer:Add(frame, 10, yPadding)
        if frame.updateDisplay then
            table.insert(menuFrames, frame)
        end
    end

    sectionOrganizer, sectionFrame = CraftScan.Frames.createOptionsBlock(nil, contentFrame, organizer, function(OnDone)
        local itemIDs = CraftScan.Utils.GetOutputItems(cur.recipe);
        local itemID = itemIDs and itemIDs[1]
        if itemID then
            local item = Item:CreateFromItemID(itemID)
            item:ContinueOnItemLoad(function()
                OnDone(item:GetItemLink());
            end)
        else
            return "Item: " .. cur.recipe.name;
        end
    end)
    add(itemKeywords, 8)
    add(itemSecondaryKeywords, 8)
    add(itemGreeting, 8)
    add(itemCommission, 8)
    add(itemOverride, 3)

    local enabledIndicator = CreateFrame("Frame", "CraftScan_ItemIndiciator", sectionFrame,
        "CraftScan_RecipeEnabledIndicatorTemplate");
    enabledIndicator:SetPoint("RIGHT", sectionFrame.Label, "LEFT", -2, 0)
    enabledIndicator.updateDisplay = function()
        if scanEnabledCheckBox:GetChecked() then
            enabledIndicator.EnabledIcon:SetAtlas("common-icon-checkmark")
        else
            enabledIndicator.EnabledIcon:SetAtlas("common-icon-redx")
        end
    end
    table.insert(menuFrames, enabledIndicator)

    table.insert(menuFrames, sectionFrame)

    sectionOrganizer, sectionFrame = CraftScan.Frames.createOptionsBlock(nil, contentFrame, organizer, function()
        return cur.category.name
    end)
    add(catKeywords, 8)
    add(catGreeting, 8)
    add(catOverride, 3)
    table.insert(menuFrames, sectionFrame)
    categoryLabel = sectionFrame.Label;

    sectionOrganizer, sectionFrame = CraftScan.Frames.createOptionsBlock(nil, contentFrame, organizer, function()
        return CraftScan.Utils.ColorizeProfessionName(cur.profession.parentProfessionID, cur.profession.professionName)
    end)
    add(profEnableAll, 3)
    add(profIsPrimary, 3)
    add(profGreeting, 8)
    add(profCommission, 8)
    table.insert(menuFrames, sectionFrame)
    expansionLabel = sectionFrame.Label;

    sectionOrganizer, sectionFrame = CraftScan.Frames.createOptionsBlock(nil, contentFrame, organizer, function()
        return CraftScan.Utils.ColorizeProfessionName(cur.profession.parentProfessionID, cur.profession
            .parentProfessionName)
    end)
    add(profKeywords, 0)
    add(profExclusions, 5)
    table.insert(menuFrames, sectionFrame)
    professionLabel = sectionFrame.Label;

    sectionOrganizer, sectionFrame = CraftScan.Frames.createOptionsBlock(L(LID.PRIMARY_KEYWORDS), contentFrame, organizer)
    add(inclusions, 8)
    add(exclusions, 8)
    local primaryKeywordsSectionFrame = sectionFrame

    organizer:Layout()
    organizer:Resize(contentFrame)

    local scrollFrame = frame.ScrollFrame;
    scrollFrame:SetScrollChild(contentFrame)
    scrollFrame:SetVerticalScroll(0)

    -- Now that the layout is complete and we know where the frames will be
    -- located, we can wrap each frame in its help box.
    local function AddHelp(frame, description, rightXPadding)
        table.insert(CraftScan_CraftScanFrame_HelpPlate,
            HelpFrameAttributes(frame, description, rightXPadding)
        );
    end

    -- Placeholders for the Labels that change size based on selection. These
    -- are updated prior to displaying help each time.
    table.insert(CraftScan_CraftScanFrame_HelpPlate, {});
    table.insert(CraftScan_CraftScanFrame_HelpPlate, {});
    table.insert(CraftScan_CraftScanFrame_HelpPlate, {});

    AddHelp(primaryKeywordsSectionFrame.Label, LID.HELP_PRIMARY_KEYWORDS, 20);

    AddHelp(itemKeywords, LID.HELP_ITEM_KEYWORDS);
    AddHelp(itemSecondaryKeywords, LID.HELP_ITEM_SECONDARY_KEYWORDS);
    AddHelp(itemGreeting, LID.HELP_ITEM_GREETING);
    AddHelp(itemCommission, LID.HELP_ITEM_COMMISSION);
    AddHelp(itemOverride, LID.HELP_ITEM_OVERRIDE);

    AddHelp(catKeywords, LID.HELP_CATEGORY_KEYWORDS);
    AddHelp(catGreeting, LID.HELP_CATEGORY_GREETING);
    AddHelp(catOverride, LID.HELP_CATEGORY_OVERRIDE);

    AddHelp(profEnableAll, LID.HELP_SCAN_ALL);
    AddHelp(profIsPrimary, LID.HELP_PRIMARY_EXPANSION);
    AddHelp(profGreeting, LID.HELP_EXPANSION_GREETING);
    AddHelp(profCommission, LID.HELP_ITEM_COMMISSION);

    AddHelp(profKeywords, LID.HELP_PROFESSION_KEYWORDS);
    AddHelp(profExclusions, LID.HELP_PROFESSION_EXCLUSIONS);

    AddHelp(inclusions, LID.HELP_GLOBAL_KEYWORDS);
    AddHelp(exclusions, LID.HELP_GLOBAL_EXCLUSIONS);
end

local function HideSchematicOptions()
    CraftScanFrame:Hide();
    if menuShownButton then
        menuShownButton:UncheckAndHide();
    end
    if scanEnabledCheckBox then
        scanEnabledCheckBox:Hide();
    end
end

local function ShowSchematicOptions()
    if menuShownButton then
        menuShownButton:ResetEnabled();
        menuShownButton:Show();
    end
    if scanEnabledCheckBox then
        scanEnabledCheckBox:Show();
    end
end

local seen_profs = {};
local function OnRecipeSelected()
    cur.recipe = ProfessionsFrame.CraftingPage.SchematicForm:GetRecipeInfo()
    if not cur.recipe then
        onSchematicChange()
        return
    end

    cur.profession = C_TradeSkillUI.GetProfessionInfoByRecipeID(cur.recipe.recipeID)

    if not cur.profession.isPrimaryProfession or not cur.profession.parentProfessionID or not CraftScan.CONST.PROFESSION_DEFAULT_KEYWORDS[cur.profession.parentProfessionID] then
        -- Ignore Cooking, Fishing, gathering professions (we don't have
        -- default keywords for them), and weird 'professions' like Emerald
        -- Dream rep boxes (no parentProfessionID).
        HideSchematicOptions();
        return
    end

    if not seen_profs[cur.profession.parentProfessionID] then
        seen_profs[cur.profession.parentProfessionID] = true;
        CraftScan.Scanner.UpdateAnalyticsProfIDs(cur.profession.parentProfessionID);
    end

    -- At this point, the player has opened a tradeskill window, so it makes
    -- sense to start tracking that character. Initialize the saved variables.
    playerNameWithRealm = CraftScan.GetPlayerName(true)
    db_player = saved(CraftScan.DB.characters, playerNameWithRealm, {})

    -- my_uuid is initialized when linked to a new account, at which point all
    -- current characters are tagged. If this character is added after account
    -- linking, tag it as well.
    if not db_player.sourceID and CraftScan.DB.settings.my_uuid then
        db_player.sourceID = CraftScan.DB.settings.my_uuid;
    end

    db_player.parent_professions = db_player.parent_professions or {}
    db_parent_prof = db_player.parent_professions[cur.profession.parentProfessionID]
    local is_new = not db_parent_prof
    if is_new then
        db_parent_prof = CraftScan.Utils.DeepCopy(CraftScan.CONST.DEFAULT_PPCONFIG);
        db_player.parent_professions[cur.profession.parentProfessionID] = db_parent_prof
    end

    if db_parent_prof.character_disabled then
        HideSchematicOptions();

        if not menuShownButtonInitialized then
            CreateMenuShownButton()
        end

        menuShownButton:SetDisabled();
        return;
    end

    db_player.professions = db_player.professions or {}

    db_prof = saved(db_player.professions, cur.profession.professionID, {})
    db_prof.parentProfID = cur.profession.parentProfessionID

    db_recipes = saved(db_prof, "recipes", {})

    cur.category = C_TradeSkillUI.GetCategoryInfo(cur.recipe.categoryID)

    CraftScan.State.professionID = cur.profession.parentProfessionID;
    CraftScan.Frames.MainButton:UpdateIcon();

    ShowSchematicOptions();
    if not menuInitialized then
        initMenu()

        menuInitialized = true
    end

    if is_new then
        -- Seed the profession on any linked accounts
        CraftScanComm:ShareCharacterData()
    end
    onSchematicChange()
end


CraftScan_ScannerConfigButtonMixin = { isSelected = false, isEnabled = true }

function CraftScan_ScannerConfigButtonMixin:SetDisabled()
    self.isSelected = false;
    self.isEnabled = false;
    self:SetText(L(LID.SCANNER_CONFIG_DISABLED))
    self:Show();
end

function CraftScan_ScannerConfigButtonMixin:OnClick(button)
    if not self.isEnabled then
        self.isEnabled = true;
        self.isSelected = false;
        db_parent_prof.character_disabled = false;

        CraftScanComm:ShareCharacterModification(playerNameWithRealm, cur.profession.parentProfessionID);

        OnRecipeSelected();
    else
        self.isSelected = not self.isSelected;
    end

    if self.isSelected then
        CraftScanFrame:Show()
        onSchematicChange();
        self:SetText(L(LID.SCANNER_CONFIG_HIDE));
    else
        self:SetText(L(LID.SCANNER_CONFIG_SHOW));
        CraftScanFrame:Hide()
    end
end

function CraftScan_ScannerConfigButtonMixin:UncheckAndHide()
    self.isSelected = false;
    self:SetText(L(LID.SCANNER_CONFIG_SHOW));
    self:Hide()
end

function CraftScan_ScannerConfigButtonMixin:ResetEnabled()
    if not self.isEnabled then
        self.isEnabled = true;
        self.isSelected = false;
        self:SetText(L(LID.SCANNER_CONFIG_SHOW));
    end
end

CraftScan_RecipeEnabledIndicatorMixin = {}

function CraftScan_RecipeEnabledIndicatorMixin:OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_TOP");
    if scanEnabledCheckBox:GetChecked() then
        GameTooltip:SetText(string.format(L(LID.SCANNING_ENABLED),
            db_prof.all_enabled and L(LID.SCAN_ALL_RECIPES) or L(LID.ITEM_SCAN_CHECK)))
    else
        GameTooltip:SetText(L(cur.recipe.learned and LID.SCANNING_DISABLED or LID.RECIPE_NOT_LEARNED))
    end
    GameTooltip:Show()
end

function CraftScan_RecipeEnabledIndicatorMixin:OnLeave()
    GameTooltip:Hide()
end

CraftScan.Utils.onLoad(function()
    hooksecurefunc(ProfessionsFrame.CraftingPage, "SelectRecipe", OnRecipeSelected);
end)
