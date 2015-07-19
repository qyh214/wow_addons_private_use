Learning Aid version 1.12 Beta 3
Compatible with World of Warcraft version 6.2.0
Learning Aid is copyright © 2008-2015 Jamash (Kil'jaeden US Horde)
Email: jamash.kj@gmail.com

=== BEGIN LEGAL BOILERPLATE ===

This file is part of Learning Aid.

  Learning Aid is free software: you can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License as
  published by the Free Software Foundation, either version 3 of the
  License, or (at your option) any later version.

  Learning Aid is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with Learning Aid.  If not, see
  <http://www.gnu.org/licenses/>.

To download the latest official version of Learning Aid, please visit 
either Curse or WowInterface at one of the following URLs: 

http://wow.curse.com/downloads/wow-addons/details/learningaid.aspx

http://www.wowinterface.com/downloads/info10622-LearningAid.html

Other sites that host Learning Aid are not official and may contain 
outdated or modified versions. If you have obtained Learning Aid from 
any other source, I strongly encourage you to use Curse or WoWInterface 
for updates in the future. 

=== END LEGAL BOILERPLATE ===

 Learning Aid helps you put new spells, abilities, and tradeskills on 
your action bars or in your macros when you learn them, without having 
to waste time paging through your Spellbook. When you learn something 
new, Learning Aid pops up a window with an icon for the newly learned 
action. You may then drag the icon to your action bar, or use it to 
paste a link into chat or text into a macro. You can also use the new 
action directly by clicking on the icon. When you're done, you can 
easily dismiss the window. 

User Interface Reference

Learning Aid Window
  Left-click and drag the titlebar to move the window.
  Click the close box or middle-click on the titlebar to close the window.
  Click on the lock icon to lock the window (to prevent it from moving) or unlock it.

Action Buttons
  * Left- or right-click to perform the action.
  * Middle-click to dismiss a button.  Dismissing the only button closes the window.
  * Shift-click on a button to create a chat link or paste the ability name into the macro window.
  * Ctrl-click on a button to ignore the spell on it when searching for missing actions.

Slash Command Reference

Type

/learningaid command [arguments]

or

/la command [arguments]


Slash Commands

/la
  Print help text to the default chat window.

/la config
  Open the Learning Aid configuration window.

/la restoreactions [on|off]
  Toggle whether to restore talent-based actions to action bars when they are
  relearned.

/la filter [0|1|2]
  Set whether to filter "You have learned" and "You have unlearned" chat messages.
    0 - Show All: Do not filter learning and unlearning messages.
    1 - Summarize: Reduce multiple lines of messages to a one or two line summary.
    2 - Show None: Filter out all learning and unlearning messages.
    Default: 1.

/la search
  Scan through your action bars to find any spells you have learned
  but not placed on an action bar.

/la close
  Close the window.

/la reset
  Reset the window's position to default.

/la lock on
  Lock the window's position so it cannot be dragged.

/la lock off
/la unlock
  Unlock the window's position so it can be dragged.

/la lock
  Toggle whether the window is locked.

/la tracking [on|off]
  Set whether /la search searches for tracking abilities.

/la shapeshift [on|off]
  Set whether /la search will find shapeshift forms, stances, auras,
  presences, etc.

/la macros [on|off]
  Set whether /la search will look inside macros for abilities in use.

/la totem [on|off]
  Set whether /la search will find Shaman totems.

/la ignore Name of Ability
  Ignore this ability when using /la search.

/la ignore
  List all ignored abilities.

/la unignore Name of Ability
  No longer ignore this ability when using /la search.

/la unignoreall
  Clear all abilities from the ignore list.

Advanced Slash Commands

/la advanced framestrata [TOOLTIP|BACKGROUND|MEDIUM|HIGH|DIALOG|FULLSCREEN_DIALOG|LOW|FULLSCREEN]
  Set the frame strata of the Learning Aid window. Only necessary if you 
 are having problems with the Learning Aid window interacting poorly with 
 other windows. 
