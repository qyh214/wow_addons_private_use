@echo off
echo This script will now prepare the files for using SharedMedia_BMW

if exist ..\SharedMedia_BMW goto has_folder
echo Creating the folders...
mkdir ..\SharedMedia_BMW
mkdir ..\SharedMedia_BMW\background
mkdir ..\SharedMedia_BMW\border
mkdir ..\SharedMedia_BMW\font
mkdir ..\SharedMedia_BMW\sound
mkdir ..\SharedMedia_BMW\statusbar
echo You can now put your media files into the subfolders found at World of Warcraft\Interface\Addons\SharedMedia_BMW
goto end_of_file

:has_folder
echo Creating the file...
echo local LSM = LibStub("LibSharedMedia-3.0") > ..\SharedMedia_BMW\BMWMedia.lua

echo    LANGUAGE MASK
echo -- ----- >> ..\SharedMedia_BMW\BMWMedia.lua
echo -- LANGUAGE MASK >> ..\SharedMedia_BMW\BMWMedia.lua
echo -- ----- >> ..\SharedMedia_BMW\BMWMedia.lua
echo local koKR = LSM.LOCALE_BIT_koKR >> ..\SharedMedia_BMW\BMWMedia.lua
echo local ruRU = LSM.LOCALE_BIT_ruRU >> ..\SharedMedia_BMW\BMWMedia.lua
echo local zhCN = LSM.LOCALE_BIT_zhCN >> ..\SharedMedia_BMW\BMWMedia.lua
echo local zhTW = LSM.LOCALE_BIT_zhTW >> ..\SharedMedia_BMW\BMWMedia.lua
echo local western = LSM.LOCALE_BIT_western >> ..\SharedMedia_BMW\BMWMedia.lua

echo    BACKGROUND
echo.>> ..\SharedMedia_BMW\BMWMedia.lua
echo -- ----- >> ..\SharedMedia_BMW\BMWMedia.lua
echo -- BACKGROUND >> ..\SharedMedia_BMW\BMWMedia.lua
echo -- ----- >> ..\SharedMedia_BMW\BMWMedia.lua
for %%F in (..\SharedMedia_BMW\background\*.*) do (
echo       %%~nF
echo LSM:Register("background", "%%~nF", [[Interface\Addons\SharedMedia_BMW\background\%%~nxF]]^) >> ..\SharedMedia_BMW\BMWMedia.lua
)

echo    BORDER
echo.>> ..\SharedMedia_BMW\BMWMedia.lua
echo -- ----- >> ..\SharedMedia_BMW\BMWMedia.lua
echo --  BORDER >> ..\SharedMedia_BMW\BMWMedia.lua
echo -- ---- >> ..\SharedMedia_BMW\BMWMedia.lua
for %%F in (..\SharedMedia_BMW\border\*.*) do (
echo       %%~nF
echo LSM:Register("border", "%%~nF", [[Interface\Addons\SharedMedia_BMW\border\%%~nxF]]^) >> ..\SharedMedia_BMW\BMWMedia.lua
)

echo    FONT
echo.>> ..\SharedMedia_BMW\BMWMedia.lua
echo -- ----->> ..\SharedMedia_BMW\BMWMedia.lua
echo --   FONT>> ..\SharedMedia_BMW\BMWMedia.lua
echo -- ----->> ..\SharedMedia_BMW\BMWMedia.lua
for %%F in (..\SharedMedia_BMW\font\*.ttf) do (
echo       %%~nF
echo LSM:Register("font", "%%~nF", [[Interface\Addons\SharedMedia_BMW\font\%%~nxF]],zhCN^) >> ..\SharedMedia_BMW\BMWMedia.lua
)
echo LSM:Register("font", "%%~nF", [[Interface\Addons\SharedMedia_BMW\font\%%~nxF]],western^) >> ..\SharedMedia_BMW\BMWMedia.lua
)
echo    SOUND
echo.>> ..\SharedMedia_BMW\BMWMedia.lua
echo -- ----->> ..\SharedMedia_BMW\BMWMedia.lua
echo --   SOUND>> ..\SharedMedia_BMW\BMWMedia.lua
echo -- ----->> ..\SharedMedia_BMW\BMWMedia.lua
for %%F in (..\SharedMedia_BMW\sound\*.*) do (
echo       %%~nF
echo LSM:Register("sound", "%%~nF", [[Interface\Addons\SharedMedia_BMW\sound\%%~nxF]]^) >> ..\SharedMedia_BMW\BMWMedia.lua
)

echo    STATUSBAR
echo.>> ..\SharedMedia_BMW\BMWMedia.lua
echo -- ----->> ..\SharedMedia_BMW\BMWMedia.lua
echo --   STATUSBAR>> ..\SharedMedia_BMW\BMWMedia.lua
echo -- ----->> ..\SharedMedia_BMW\BMWMedia.lua
for %%F in (..\SharedMedia_BMW\statusbar\*.*) do (
echo       %%~nF
echo LSM:Register("statusbar", "%%~nF", [[Interface\Addons\SharedMedia_BMW\statusbar\%%~nxF]]^) >> ..\SharedMedia_BMW\BMWMedia.lua
)

:end_of_file
pause