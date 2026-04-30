--
-- Copyright (c) 2025 by RaiderIO, Inc.
-- All rights reserved.
--
local provider={name=...,data=3,region="eu",date="2026-01-20T06:08:01Z",numCharacters=20,db={}}
local F

F = function() provider.db["Hoptallus"]={0,"Arizara","Drdottington","Eruveena","Feronya","Ludidoktor","Ludidoktorr","Ludidokttor","Nacugivara","Nikotako","Noshecant","Palladan","Psyvise","Rualan"} end F()
F = function() provider.db["Norushen"]={26,"Seruss","Tonzil"} end F()
F = function() provider.db["Garalon"]={30,"Mirabile"} end F()
F = function() provider.db["Everlook"]={32,"Rawzom"} end F()

F = nil
RaiderIO.AddProvider(provider)
