local E, L, C = select(2, ...):unpack()

if E.isClassic then E.changelog = [=[
v1.14.3.2755
	Readiness will reset Deterrence, Feign Death and Trap abilities, instead of all Hunter abilities
]=]
elseif E.isBCC then E.changelog = [=[
v2.5.4.2722
	Fixed sync for cross realm group members
]=]
elseif E.isWOTLKC then E.changelog = [=[
v3.4.1.2755
	Fixed an issue that prevented CD bars from attaching to the party frames
	Readiness will no longer reset Roar of Sacrifice
	Added arena season 7, 8 equip bonus items
]=]
else E.changelog = [=[
v10.1.0.2757
	Fixed Quick Witted CDR when interrupting Penance
	Fixed Invigorating Shadowdust CDR
	Fixed nil error on Flow State removal
	Fixed Ironbark CD 60>45s (Guardian, APRIL 5, 2023 hotfixes)

v10.1.0.2756
	JUNE 5, 2023 hotfixes
		Amplify Curse CD 30>60s
		Teachings of the Satyr CDR 10>15s
		Thunderlord CDR 1>1.5s
	MAY 15, 2023 hotfixes
		BM HUnter, Aberrus (4) Set bonus CDR 1>2s
		Sharpen Blade CD 25>30s

v10.1.0.2755
	TL;DR
		Fixed incorrect CDRs for Prot Paladin and Brewmaster Monk
		CD sync revamped - |cffff2020no longer communicates with older versions!|r
		10.1.5 compatibility updates

# Released a new addon to track auras. Link in the AddOns tab
]=]
end

E.changelog = E.changelog .. "\n\n|cff808080Full list of changes can be found in the CHANGELOG file"
