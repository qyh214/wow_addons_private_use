== About ==
Standard UIDropDownMenu global functions using protected frames and causing taints 
when used by third-party addons. But it is possible to avoid taints by using same 
functionality with that library.

== What is it ==
Library is standard code from Blizzard's files EasyMenu.lua, UIDropDownMenu.lua, 
UIDropDownMenu.xml and UIDropDownMenuTemplates.xml with frames, tables, variables 
and functions renamed to:
* constants : "L_" added at the start
* functions: "L_" added at the start

== How to use it (for addon developer) ==
* Embed LibUIDropDownMenu to your addon, you can specify to the folder to 
  LibUIDropDownMenu\LibUIDropDownMenu if you feel this keep the folder cleaner.
* Add LibUIDropDownMenu.xml to your toc or your embeds.xml / libs.xml. 
* If your addon doesn't embed LibStub, you will need it.
* Like ordinal code for UIDropDownMenu with "L_" instead.

== Constants ==
* L_UIDROPDOWNMENU_MINBUTTONS
* L_UIDROPDOWNMENU_MAXBUTTONS
* L_UIDROPDOWNMENU_MAXLEVELS
* L_UIDROPDOWNMENU_BUTTON_HEIGHT
* L_UIDROPDOWNMENU_BORDER_HEIGHT
* L_UIDROPDOWNMENU_OPEN_MENU
* L_UIDROPDOWNMENU_INIT_MENU
* L_UIDROPDOWNMENU_MENU_LEVEL
* L_UIDROPDOWNMENU_MENU_VALUE
* L_UIDROPDOWNMENU_SHOW_TIME
* L_UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT
* L_OPEN_DROPDOWNMENUS

== Functions ==
* L_EasyMenu
* L_EasyMenu_Initialize

* L_UIDropDownMenuDelegate_OnAttributeChanged
* L_UIDropDownMenu_InitializeHelper
* L_UIDropDownMenu_Initialize
* L_UIDropDownMenu_SetInitializeFunction
* L_UIDropDownMenu_RefreshDropDownSize
* L_UIDropDownMenu_OnUpdate
* L_UIDropDownMenu_StartCounting
* L_UIDropDownMenu_StopCounting
* L_UIDropDownMenu_CreateInfo
* L_UIDropDownMenu_CreateFrames
* L_UIDropDownMenu_AddSeparator
* L_UIDropDownMenu_AddButton
* L_UIDropDownMenu_AddSeparator
* L_UIDropDownMenu_GetMaxButtonWidth
* L_UIDropDownMenu_GetButtonWidth
* L_UIDropDownMenu_Refresh
* L_UIDropDownMenu_RefreshAll
* L_UIDropDownMenu_SetIconImage
* L_UIDropDownMenu_SetSelectedName
* L_UIDropDownMenu_SetSelectedValue
* L_UIDropDownMenu_SetSelectedID
* L_UIDropDownMenu_GetSelectedName
* L_UIDropDownMenu_GetSelectedID
* L_UIDropDownMenu_GetSelectedValue
* L_UIDropDownMenuButton_OnClick
* L_HideDropDownMenu
* L_ToggleDropDownMenu
* L_CloseDropDownMenus
* L_UIDropDownMenu_OnHide
* L_UIDropDownMenu_SetWidth
* L_UIDropDownMenu_SetButtonWidth
* L_UIDropDownMenu_SetText
* L_UIDropDownMenu_GetText
* L_UIDropDownMenu_ClearAll
* L_UIDropDownMenu_JustifyText
* L_UIDropDownMenu_SetAnchor
* L_UIDropDownMenu_GetCurrentDropDown
* L_UIDropDownMenuButton_GetChecked
* L_UIDropDownMenuButton_GetName
* L_UIDropDownMenuButton_OpenColorPicker
* L_UIDropDownMenu_DisableButton
* L_UIDropDownMenu_EnableButton
* L_UIDropDownMenu_SetButtonText
* L_UIDropDownMenu_SetButtonNotClickable
* L_UIDropDownMenu_SetButtonClickable
* L_UIDropDownMenu_DisableDropDown
* L_UIDropDownMenu_EnableDropDown
* L_UIDropDownMenu_IsEnabled
* L_UIDropDownMenu_GetValue

