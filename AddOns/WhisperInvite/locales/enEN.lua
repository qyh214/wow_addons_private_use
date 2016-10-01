local ADDONNAME, WIC = ...

--@DEBUG@
local debug = true
--@END-DEBUG@

local L = LibStub("AceLocale-3.0"):NewLocale(ADDONNAME, "enUS", true, debug)

L["A "] = true
L["Active"] = true
L["Active module"] = true
L["Add a new keyword."] = true
L["Add here your invite keywords, one per line."] = true
L["Add keyword"] = true
L["Addon name not found!"] = true
L["Advanced"] = true
L["AFK/DND Protection"] = true
L["All entry are case sensitive."] = true
L["Alliance toons: %s"] = true
L["ALLOW"] = true
L["And show me this infos: %s"] = true
L["Answer"] = true
L["A%s"] = true
L["Auto convert"] = true
L["Basic"] = true
L["Battle.net Channels"] = true
L["Battle.net Channels where message will be checked for invite keywords."] = true
L["BLOCK"] = true
L["Block invites"] = true
L["Block invites when you are AFK"] = true
L["Block invites when you are DND"] = true
L["BNET_TAG"] = true
L["B%s"] = true
L["Cache has been cleaned."] = true
L["Cache has been reset."] = true
L["Can't load module. %s"] = true
L["Can't load module %s because %s"] = true
L["Case sensitive"] = true
L["Case sensitive keyword matching."] = true
L["Channels"] = true
L["Channels where message will be checked for invite keywords."] = true
L["CHAT_MSG_BN_CONVERSATION"] = true
L["CHAT_MSG_BN_INLINE_TOAST_BROADCAST"] = true
L["CHAT_MSG_BN_WHISPER"] = true
L["CHAT_MSG_CHANNEL"] = true
L["CHAT_MSG_GUILD"] = true
L["CHAT_MSG_OFFICER"] = true
L["CHAT_MSG_WHISPER"] = true
L["Choose active module."] = true
L[ [=[Choose when you don't want to automatic invite other players when you are AFK or DND.
And if to send a message.]=] ] = true
L[ [=[Choose when you don't want to automatic invite other players when you are in a LF-Queue.
]=] ] = true
L[ [=[Choose which Type of filter you want to add, all entries are case sensitive.

|cFF70DBFF%s:|r Filter only on playername 
|cFF70DBFF%s:|r Filter on playername and realm
|cFF70DBFF%s:|r Filter on guild (this will mostly only work with player of your realm)
|cFF70DBFF%s:|r Filter on guild and realm 
|cFF70DBFF%s:|r Filter player on realm
|cFF70DBFF%s:|r Filter player on Battle.net Tag (this work only with yours Battle.net friends. This will save Battle.net Tags to your SavedVariables for caching.)
|cFF70DBFF%s:|r Enter an existing filter to remove.]=] ] = true
L[ [=[Choose which way the filter work.
|cFF70DBFF%s:|r Allow any where is not on the list
|cFF70DBFF%s:|r Allow only where is on the list]=] ] = true
L["<command>"] = true
L["Convert group to raid when group has reached maximal size."] = true
L["CS "] = true
L["Custom block message"] = true
L["Delay(seconds) needed between to invites of the same player before, WhisperInvite can send a new invite."] = true
L["Delete"] = true
L["disable"] = true
L["Disabled"] = true
L["Display this custom message when a invite is blocked."] = true
L["Do you really want to remove the keyword %q?"] = true
L["E.g: %s"] = true
L["enable"] = true
L["Enabled"] = true
L["Entry"] = true
L["Entry is not valid."] = true
L["Entry Type"] = true
L["Filtering"] = true
L["Filter type"] = true
L["FM "] = true
L["Full match"] = true
L["G%s "] = true
L["GUILD"] = true
L["Guild Name"] = true
L["GUILD_REALM"] = true
L["help"] = true
L["Horde toons: %s"] = true
L["I'm currently AFK"] = true
L["I'm currently DND"] = true
L["I'm currently in a LF-Queue"] = true
L["Incorrect Battle.net Tag. %s"] = true
L["Input"] = true
L["Invite player when they whisper you with a defined keyword."] = true
L["Invite player when they whisper you with a defined keyword where they are allowed to use."] = true
L["Invite Throttle"] = true
L["Is blocked."] = true
L["Is not allowed."] = true
L["Is this keyword in use."] = true
L["Is this profile enabled."] = true
L["Keywords"] = true
L["LF-Queue Protection"] = true
L["LIST_ENTRY_TYPES_REMOVE"] = true
L["Maximal group size"] = true
L["Maximal group size reached. Can't invite %s"] = true
L["Message has to exactly match with the keyword."] = true
L["Module hasn't needed functions."] = true
L["Module not found."] = true
L["Modules: %s"] = true
L["No description for this module."] = true
L["No module selected!"] = true
L["No Modules Registered"] = true
L["<No name given>"] = true
L["No realm entered. %s"] = true
L["<No toon name given>"] = true
L["No value entered."] = true
L["off"] = true
L["on"] = true
L["Pattern free matching"] = true
L["PF "] = true
L["PLAYER"] = true
L["PLAYER_REALM"] = true
L["Profile"] = true
L["REALM"] = true
L["Realm can't have '-' characters. %s"] = true
L["Realm can't have white-space characters. %s"] = true
L["Remove this keyword."] = true
L["Run /wi modules or /wi options to setup WisperInvite."] = true
L["Send a message to inform that you are AFK."] = true
L["Send a message to inform that you are DND."] = true
L["Send a message to inform that you have not send an invite because your are in a LF-Queue."] = true
L["Send an answer"] = true
L["%s Filter: %s"] = true
L["Show a message when a invite is blocked because of filtering."] = true
L["Show block message"] = true
L["%s is not online in World of Warcraft."] = true
L["%s is with more then one toon online. Choose which toons should be invited. Click on the name to invite."] = true
L["%s - %s"] = true
L["%s (%s)"] = true
L["%s was not invited %s"] = true
L["%s was not invited: %s"] = true
L["The message you will send."] = true
L["The size the group can reach before this keyword stops to invite."] = true
L["toggle"] = true
L["Type: %s"] = true
L["usage"] = true
L["Usage: guild-realm e.g: %s-%s"] = true
L["Usage: name-realm e.g: %s-%s"] = true
L["Usage: /wia %s"] = true
L[ [=[Usage: /wi <command>
Commands: modules, options]=] ] = true
L["Usage: /wi modules moduleName (case sensitive)"] = true
L["Use %s entry type."] = true
L["When in the %q Queue block invites."] = true
L["WhisperInvite Basic Settings"] = true
L["/wia cache clean||reset – Clean-up or reset cache"] = true
L["/wia op||option – Open WhisperInviteAdvanced Options"] = true
L["WisperInvite Advanced Settings"] = true
L["WisperInvite Core Settings"] = true
L["Without pattern matching."] = true
L["You are in an instance group and not in LFR or LFG group. When you can invite here players let me know it."] = true
L["You can run /wienable to enable WisperInvite."] = true
L["Your are AFK. Invite to %s was not sent."] = true
L["Your are DND. Haven't send an invite to %s"] = "Your are DND. Invite to %s was not sent."
L["Your are DND. Invite to %s was not sent."] = true
L["Your are in a LF-Queue. Can't invite %s"] = true
L["TOC/Notes"] = "Auto-invite with keywords"
L["TOC/Notes.Advanced"] = "Advanced invite module"
L["TOC/Notes.Basic"] = "Basic invite module"
L["TOC/Title"] = "WhisperInvite"
L["TOC/Title.Advanced"] = "WhisperInvite Advanced"
L["TOC/Title.Basic"] = "WhisperInvite Basic"
