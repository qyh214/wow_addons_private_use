--
-- Copyright (c) 2023 by Ludicrous Speed, LLC
-- All rights reserved.
--
local provider={name=...,data=3,region="tw",date="2023-02-11T20:05:14Z",numCharacters=37774,lookup={},recordSizeInBytes=2,encodingOrder={0,1,3}}
local F

-- chunk size: 116
F = function() provider.lookup[1] = ";\16<\13<\13;\8\4\4;\4s\29<\13\5\4<\13<\13;\16<\13s\29s\29s\29s\29s\29s\29s\29\14\8s\29;\4s\29<\13s\29;\8;\16\128\6?\13?\13?\13?\13?\13?\13?\13?\13?\13?\13\4\8?\29?\29?\29?\29?\29?\29?\29?\29?\29?\29;\4?\9?\9?\9;\16;\16;\16;\4" end F()

F = nil
RaiderIO.AddProvider(provider)
