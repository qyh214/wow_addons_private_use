--
-- Copyright (c) 2025 by RaiderIO, Inc.
-- All rights reserved.
--
local provider={name=...,data=3,region="us",date="2026-01-20T06:08:01Z",numCharacters=20,db={}}
local F

F = function() provider.db["Galakras"]={0,"Warpando"} end F()
F = function() provider.db["Pagle"]={2,"Arborious","Powersticks"} end F()

F = nil
RaiderIO.AddProvider(provider)
