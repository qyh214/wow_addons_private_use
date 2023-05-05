local E, L, C = select(2, ...):unpack()

if E.isClassic then E.changelog = [=[
v1.14.3.2750
	minor bug fixes
]=]
elseif E.isBCC then E.changelog = [=[
v2.5.4.2722
	Fixed sync for cross realm group members
]=]
elseif E.isWOTLKC then E.changelog = [=[
v3.4.1.2750
	minor bug fixes
]=]
else E.changelog = [=[
v10.1.0.2750
	Patch 10.1 updates
]=]
end

E.changelog = E.changelog .. "\n\n|cff808080Full list of changes can be found in the CHANGELOG file"
