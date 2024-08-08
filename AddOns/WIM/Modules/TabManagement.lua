--imports
local WIM = WIM;
local _G = _G;
local table = table;
local unpack = unpack;
local string = string;
local pairs = pairs;

--set namespace
setfenv(1, WIM);

db_defaults.tabs.whispers = {
    enabled = false,
    friends = false,
    guild = false,
};
db_defaults.tabs.chat = {
    enabled = false,
    aswhisper = false,
};

local Tabs = WIM.CreateModule("Tabs", true);

local Whispers = windows.active.whisper;
local Chats = windows.active.chat;



-- get first tab group found which contains a friend.
local function getFriendGroup()
    local ungrouped = nil;
    for _user, win in pairs(Whispers) do
		local user = win.theUser;
        if(lists.friends[user]) then
            if(win.tabStrip) then
                return win.tabStrip;
            else
                ungrouped = win;
            end
        end
    end
    if(ungrouped) then
        local tabStrip = GetAvailableTabGroup();
	tabStrip:Attach(ungrouped);
        return tabStrip;
    else
        return nil;
    end
end

-- get first tab group found which contains a guild member.
local function getGuildGroup()
    local ungrouped = nil;
    for _user, win in pairs(Whispers) do
		local user = win.theUser;
        if(lists.guild[user]) then
            if(win.tabStrip) then
                return win.tabStrip;
            else
                ungrouped = win;
            end
        end
    end
    if(ungrouped) then
        local tabStrip = GetAvailableTabGroup();
	tabStrip:Attach(ungrouped);
        return tabStrip;
    else
        return nil;
    end
end

-- get first whisper related tab group found
local function getAvailableWhisperGroup()
    local ungrouped = nil;
    for _user, win in pairs(Whispers) do
		local user = win.theUser;
        if(not (db.tabs.whispers.friends and lists.friends[user]) and not (db.tabs.whispers.guild and lists.guild[user]) ) then
            if(win.tabStrip) then
                return win.tabStrip;
            else
                ungrouped = win;
            end
        end
    end
    if(ungrouped) then
        local tabStrip = GetAvailableTabGroup();
	tabStrip:Attach(ungrouped);
        return tabStrip;
    else
        return nil;
    end
end

-- get first chat related tab group found
local function getAvailableChatGroup()
    local ungrouped = nil;
    for user, win in pairs(Chats) do
        if(win.tabStrip) then
            return win.tabStrip;
        else
            ungrouped = win;
        end
    end
    if(ungrouped) then
        local tabStrip = GetAvailableTabGroup();
	tabStrip:Attach(ungrouped);
        return tabStrip;
    else
        return nil;
    end
end

function Tabs:OnWindowCreated(win)
    if(db.tabs.whispers.enabled and win.type == "whisper") then
        local group = nil;
        if(db.tabs.whispers.friends and lists.friends[win.theUser]) then
            group = getFriendGroup();
            if(group) then
                group:Attach(win);
            end
            return;
        end
        if(db.tabs.whispers.guild and lists.guild[win.theUser]) then
            group = getGuildGroup();
            if(group) then
                group:Attach(win);
            end
            return;
        end

		-- look for whisper group
        group = getAvailableWhisperGroup();

		-- if it exists, attach
        if(group) then
            group:Attach(win);

		-- otherwise, first check if we are grouping whisers and chats together, if so look for chat
		elseif (db.tabs.chat.aswhisper) then
			group = getAvailableChatGroup();

			-- if there's a chat group, attach to it.
			if (group) then
				group:Attach(win);
			end
        end
    elseif(db.tabs.chat.enabled and win.type == "chat") then
        local group = db.tabs.chat.aswhisper and getAvailableWhisperGroup() or getAvailableChatGroup();
        if(group) then
            group:Attach(win);
        end
    end
end

-- This module will always remain running.
Tabs.canDisable = false;
Tabs:Enable();
