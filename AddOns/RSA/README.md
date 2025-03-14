# RSA - Raeli's Spell Announcer
Easy spell announcements

## Download
<https://www.curseforge.com/wow/addons/rsa>

# About
RSA is an addon that can announce spell casts in the chat. It comes with a selection of spells already setup for every class, and can announce racial abilities and various other utilities such as repair bots or feasts.

## What about my old settings?
The new version of RSA stores its settings in the same file as your old settings, but it saves them seperately. Your settings are all stored inside the RSA.lua file in the following folder:

    World of Warcraft\_retail_\WTF\Account\AccountID#\SavedVariables\

If you want to go and copy old messages, you'll be able to easily find them all there, and then copy and paste them in-game to RSA5. Or if you go back to the previous version of RSA, they'll be there waiting.

# Options & Features
You can open RSA's configuration window by typing **/rsa** in chat. You can alternatively go to the addon settings tab in the Interface options, and find RSA in your list of addons, which has a button to open RSA's configuration panel.

## Environments
Environments are settings that configure where RSA is allowed to announce spells in. These can be configured on a global level, but each spell can also individually have its own options that can differ from the global settings, allowing you finer control.

As an example, you can make sure that your interrupts can always announce, but your defensive cooldowns only announce when you're inside a raid.

## Announcements
Every spell has it's own section where you can configure everything about it from what in-game channel RSA announces the spell in, to what RSA says when it does announce that spell.

## Tags
RSA allows you to completely customise the message sent to chat when you cas a spell. Tags are a way of replacing part of the message with relevant information such as who the spell was cast on, or what spell you interrupted.

Each spell shows which tags are valid for that spell. Advanced users adding their own spells will need to specify which tags are valid for that spell.

To use a tag just write it as you see below in your message, including the square brackets.

* **[SPELL]** will be replaced with the name of the spell.
* **[LINK]** will be replaced by a clickable spell link of the spell cast.
* **[TARGET]** will be replaced with the target of the spell.
* **[AMOUNT]** will be replaced with the amount of damage or healing done.
* **[MISSTYPE]** will be replaced with Immune/Blocked/Resisted etc.

There are options that define the grammar of the replacements for MISSTYPE in the Tag Options tab, so that you can configure RSA's announcements to be gramatically correct in your own language.

There are also two final tags that can do different things depending on the supported spell. These are:
* **[EXTRA]**
* **[EXTRALINK]**

With a like Purge, these would function like the **[SPELL]** and **[LINK]** tags, but they would instead be replaced with the buff that Purge removed. With an interrupt, they would show which the enemy was trying to cast. It also works when someone breaks CC effects to show what ability broke the effect.

## Channels
Each spell can be announced in a variety of different channels:

* **Local Output** - Sends a message locally only visible to you. You can choose which part of your UI this is sent to in the Local Message Output Area in the General Options.
* **Instance** - Sends to /instance if you're in an instance group.
* **Raid** - Sends to /raid or /instance depending on what is most appropriate.
* **Party** -Sends to /party or /instance depending on what is most appropriate.
* **Smart Group Channel** - Sends to /instance, /raid, or /party depending on what is most appropriate.
* **Say** - Can only be used inside instances.
* **Yell** - Can only be used inside instances.
* **Emote**
* **Whisper** - sends a whisper to the target of the spell.

Many of these are affected by other settings. For example, Say, Yell, Emote, and Whisper all have options to only allow them to work when you are in a group of some sort.

# Feedback & Support

You can report issues on [Github](https://github.com/Caedilla/RSA/issues), [Curseforge](https://wow.curseforge.com/projects/rsa/issues), or on my [Discord](https://discord.gg/99QZ6sd) server.

I've setup a Patreon to go toward my WoW subscription. If you'd like to throw me a dollar to keep my addons working, check out the link below. Cheers.

[![Support me on Patreon](https://c5.patreon.com/external/logo/become_a_patron_button.png "")](https://www.patreon.com/join/raeli "")

## Localisation

RSA supports localisation, if you want to help me out by localising RSA, please go to the [localisation page on Curseforge](https://wow.curseforge.com/projects/rsa/localization).