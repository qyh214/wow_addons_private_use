-- threeDimensionsCode.lua 客户端通讯
-- @Date   : 07/02/2024, 10:01:07 AM
--
BuildEnv(...)

if bit==nil and bit32~=nil then
	bitfunc = bit32
else
	bitfunc = bit
end

local show_log = {
	verbose = false ,
	info = false ,
	errro = true ,
}
local function verbose(...)
   if show_log.verbose then print("[verbose]",...) end
end
local function info(...)
   if show_log.info then print("[verbose]",...) end
end
local function error(...)
   if show_log.errro then print("[verbose]",...) end
end
function cmd3dcode_pipe_showlog(name,show)
	if name==nil then name = "verbose" end
	if show==nil then show = true end
	show_log[name] = show
end

local bitReceiveInterval = 3


-- --------------------------------------------------
local data = ""
local headbyte1 = -1
local headbyte2 = -1
local cmdid = -1
local datalen = 0
local byteidx = 0

local receivingByte = 0
local bitidx = 0

local startReceiveTime = 0
local lastBitReceiveTime = 0

local function resetBit()
	receivingByte = 0
	bitidx = 0
end

local function resetReceive()
	data = ""
	headbyte1 = -1
	headbyte2 = -1

	cmdid = -1
	datalen = 0
	byteidx = 0

	lastBitReceiveTime = 0
	startReceiveTime = 0

	resetBit()
end
resetReceive()

local function receiveByte(byte)

	verbose("receive",(byteidx+1).."/"..datalen,"byte",byte,string.char(byte))

	if headbyte1<0 then
		headbyte1 = byte
		return
	elseif headbyte2<0 then
		headbyte2 = byte

		-- head receive over
		cmdid = headbyte1
		datalen = headbyte2

		info("cmd id",cmdid,"data len",datalen)

		if datalen<1 then
			resetReceive()
		end

		return
	end

	data = data .. string.char(byte)
	byteidx = byteidx + 1

	if byteidx>= datalen then

		local cmdnum = string.byte(data:sub(1,1))
		local cmd = ThreeDimensionsCode_SafePipe_CmdHandles[cmdnum]
		local args

		-- 字节型命令
		if cmd then
			args = data:sub(2)
			cmd = ThreeDimensionsCode_SafePipe_CmdHandles[cmd]
		end
		--

		if cmd then
			cmd( cmdid, args )
		end

		info("receive over, time",GetTime()-startReceiveTime,"cmd id",cmdid )
		info(data)
		-- verbose(">>", #data, (#data<32 and data) or (data:sub(1,32).."..."))

		resetReceive()
		return
	end
end


local function receiveBit(bit)

	local now = GetTime()
	if lastBitReceiveTime==0 then
		startReceiveTime = now
		verbose("first bit come in")
	else
		if now-lastBitReceiveTime>bitReceiveInterval then
			verbose("safe pipe 超时关闭")

			-- 遇到超时并不立即 return ，而是最为第一个位 继续接收这个数据
			resetReceive()
			startReceiveTime = now
		end
	end
	lastBitReceiveTime = now

	if bit>0 then
		receivingByte = bitfunc.bor( receivingByte, bitfunc.lshift(bit,7-bitidx) )
	end
	bitidx = bitidx+1

	if bitidx>=8 then

		receiveByte(receivingByte)

		-- 重置bit
		resetBit(receivingByte)
	end

end


function ThreeDimensionsCode_Savepipe_Yin()
	receiveBit(0)
end
function ThreeDimensionsCode_Savepipe_Yang()
	receiveBit(1)
end

ThreeDimensionsCode_SafePipe_CmdHandles = {

	"joinRoom" ,		-- 1

	joinRoom = function(cmdid)
		_G.isOpenVoiceRoom = true
	end ,
}
