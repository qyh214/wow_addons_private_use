local CraftScan = select(2, ...)

local LID = CraftScan.CONST.TEXT;
local function L(id)
    return CraftScan.LOCAL:GetText(id);
end

CraftScan.CONST.CURRENT_VERSION = 'v1.3.2';

local function CompareVersions(version1, version2)
    local function extractVersion(version)
        local numbers = {}
        for num in version:gmatch("%d+") do
            table.insert(numbers, tonumber(num))
        end
        return numbers
    end

    local v1 = extractVersion(version1);
    local v2 = extractVersion(version2);
    for i = 1, 3 do
        if v1[i] < v2[i] then return -1 end
        if v1[i] > v2[i] then return 1 end
    end
    return 0
end

function CraftScan.IsRemoteVersionMoreRecent(remoteVersion)
    return CompareVersions(remoteVersion, CraftScan.CONST.CURRENT_VERSION) > 0;
end

local function NotifyRecentChanges(lastLoadedVersion)
    if type(lastLoadedVersion) ~= 'string' then
        lastLoadedVersion = CraftScan.Utils.GetSetting('last_loaded_version');
        if type(lastLoadedVersion) ~= 'string' then
            lastLoadedVersion = 'v0.0.0';
        end
    end

    if CompareVersions(CraftScan.CONST.CURRENT_VERSION, lastLoadedVersion) <= 0 then
        return;
    end

    local releaseNotes = {
        {
            version = 'v1.0.0',
            id = LID.RN_WELCOME,
        },
        {
            version = 'v1.0.0',
            id = LID.RN_INITIAL_SETUP,
        },
        {
            version = 'v1.0.0',
            id = LID.RN_INITIAL_TESTING,
        },
        {
            version = 'v1.0.0',
            id = LID.RN_MANAGING_CRAFTERS,
        },
        {
            version = 'v1.0.0',
            id = LID.RN_MANAGING_CUSTOMERS,
        },
        {
            version = 'v1.0.0',
            id = LID.RN_KEYBINDS,
        },
        {
            version = 'v1.0.10',
            id = LID.RN_CLEANUP,
        },
        {
            version = 'v1.2.0',
            id = LID.RN_LINKED_ACCOUNTS,
        },
        {
            version = 'v1.2.5',
            id = LID.RN_ANALYTICS,
        },
        {
            version = 'v1.2.6',
            id = LID.RN_ALERT_ICON_ANCHOR,
        },
        {
            version = 'v1.3.0',
            id = LID.RN_MANUAL_MATCH,
        },
        {
            version = 'v1.3.0',
            id = LID.RN_CUSTOM_EXPLANATIONS,
        },
        {
            version = 'v1.3.0',
            id = LID.RN_BUSY_MODE,
        },
        {
            version = 'v1.3.1',
            id = LID.RN_SECONDARY_KEYWORDS,
        },
        {
            version = 'v1.3.2',
            id = LID.RN_CUSTOMER_SEARCH,
        },
    };

    local frame = CreateFrame("Frame", "CraftScan_ReleaseNotes", UIParent, "CraftScanRecentUpdatesFrameTemplate")

    local anchor = AnchorUtil.CreateAnchor("TOP", frame.ScrollFrame.Content, "TOP");
    local organizer = CraftScan.Frames.CreateVerticalLayoutOrganizer(anchor, 0, 0);

    local function CreateSection(section)
        local frame = CreateFrame("Frame", nil, frame.ScrollFrame.Content,
            "CraftScan_RecentUpdatesSectionTemplate");
        organizer:Add(frame);

        frame.Header:SetText(L(section.id));
        frame.Version:SetText(string.format("%s %s", L("Version"), section.version));

        local body = L(section.id + 1);
        local i = 2;
        local b = L(section.id + i);
        while b ~= section.id + i do
            body = body .. '\n\n' .. b;
            i = i + 1;
            b = L(section.id + i);
        end
        frame.Body:SetText(body);
        frame:SetSize(360, frame.Body:GetStringHeight() + 40)
    end

    for _, entry in ipairs(releaseNotes) do
        if CompareVersions(entry.version, lastLoadedVersion) > 0 then
            CreateSection(entry);
        end
    end

    if not organizer:Empty() then
        organizer:Layout();
        CraftScan.Frames.makeMovable(frame)
        frame.ScrollFrame:SetScrollChild(frame.ScrollFrame.Content)
        frame:SetTitle(L("CraftScan Release Notes"));
        frame:Show();
    end
end

CraftScan.NotifyRecentChanges = NotifyRecentChanges;

CraftScan_RecentUpdatesMixin = {}

function CraftScan_RecentUpdatesMixin:OnHide()
    CraftScan.DB.settings.last_loaded_version = CraftScan.CONST.CURRENT_VERSION;
end

CraftScan_ReleaseNotesButtonMixin = {};

function CraftScan_ReleaseNotesButtonMixin:OnLoad()
    self:SetText(L("Release Notes"))
    self:FitToText();
end

function CraftScan_ReleaseNotesButtonMixin:OnClick()
    NotifyRecentChanges('v0.0.0');
end
