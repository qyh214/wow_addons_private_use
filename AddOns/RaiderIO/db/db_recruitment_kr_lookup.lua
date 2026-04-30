--
-- Copyright (c) 2025 by RaiderIO, Inc.
-- All rights reserved.
--
local provider={name=...,data=3,region="kr",date="2025-11-07T08:38:41Z",numCharacters=27926,lookup={},recordSizeInBytes=2,encodingOrder={0,1,3}}
local F

-- chunk size: 6
F = function() provider.lookup[1] = ";\4;\4;\4" end F()

F = nil
RaiderIO.AddProvider(provider)
