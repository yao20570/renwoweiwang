--[[
PacketBuffer receive the byte stream and analyze them, then pack them into a message packet.
The method name, message metedata and message body will be splited, and return to invoker.
@see https://github.com/zrong/as3/blob/master/src/org/zengrong/net/PacketBuffer.as
@author zrong(zengrong.net)
Creation: 2013-11-14
]]

local PacketBuffer = class("PacketBuffer")
local Protocol = import(".Protocol")
local json = require("framework.json")
local lz  = require("zlib")
cc.utils = require("framework.cc.utils.init")

-- 战争时刻使用小端
-- PacketBuffer.ENDIAN = cc.utils.ByteArrayVarint.ENDIAN_LITTLE
-- 帝国霸业使用大端，无论是标准的socket还是websocket
PacketBuffer.ENDIAN = cc.utils.ByteArrayVarint.ENDIAN_BIG

PacketBuffer.MASK1 = 0x86
PacketBuffer.MASK2 = 0x7b
PacketBuffer.RANDOM_MAX = 10000
PacketBuffer.PACKET_MAX_LEN = 2100000000

--[[
packet bit structure
TYPE short|BODY_LEN int|ID int|VER byte|STATE int
]]
PacketBuffer.HEAD_LEN = 15
--PacketBuffer.TYPE_LEN = 2	-- 消息类型, 2byte
--PacketBuffer.BODY_LEN = 4	-- 整个消息的长度(包头+包体), 4byte
--PacketBuffer.ID_LEN = 4	-- 消息ID, 4byte
--PacketBuffer.VER_LEN = 1	-- 协议版本号, 1byte
--PacketBuffer.STATE_LEN = 4	-- 消息状态, 4byte
local compress =lz.deflate()
local uncompress = lz.inflate()

local _DATA_TYPE = 
{
	R = 0,	-- Unsigned Varint int
	S = 1,	-- String
	r = 2,	-- Varint int
}

local function _getDataTypeValue(__type)
	for __k, __v in pairs(_DATA_TYPE) do
		if __v == __type then return __k end
	end
	error(__type .. " is a unavailable type value! You can only use a type value in 012.")
	return nil
end

local function _getKeyFromi(i, __keys)
	if not __keys then return i end
	if __keys[i] then return __keys[i] end
	return i
end

--- 生成包头
function PacketBuffer.createHead(__type, __Len, __Ver)
	local __buf = PacketBuffer.getBaseBA()
	__buf:writeShort(__type)
	__buf:writeInt(__Len)
	__buf:writeInt(0)
	__buf:writeByte(__Ver)
	__buf:writeInt(0)
	return __buf
end

--- 解析包头
function PacketBuffer.parseHead(__buf)
	local __meta = {}
	__meta.type = __buf:readShort()
	__meta.bodylen = __buf:readInt()
	__meta.id = __buf:readInt()
	__meta.ver = __buf:readByte()
	__meta.state = __buf:readInt()
	return __meta
end

--- 生成包体
function PacketBuffer.createBody(jsonstr)
	local ver = 0  -- 加密类型
	local strzip = jsonstr
	local eof = nil
	if #jsonstr > 0 then -- 需要压缩数据
		if(SOCKET_ENCRYPT_KEY ~= nil and AccountCenter.acc ~= nil) then			
			local sKey = SOCKET_ENCRYPT_KEY .. AccountCenter.acc
			strzip = cc.Crypto:encryptXXTEA(jsonstr, string.len(jsonstr), sKey, string.len(sKey))			
			ver = 6
		elseif (#jsonstr > 200) then
			strzip, eof = compress(jsonstr, "finish")		
			ver = 5
		else
			ver = 0
		end
	end
	local bodybuf = PacketBuffer.getBaseBA()
	bodybuf:writeString(strzip)	
	return bodybuf,ver
end

--- 解析包体
function PacketBuffer._parseBody(__buf, __head)
	local __body = {}
	-- 把json字符串解析为一个表
    local len    
    if __buf:getAvailable() < __head.bodylen then
        len = __buf:getAvailable()
    else
        len = __head.bodylen
    end

	local str = __buf:readStringBytes(len)
    -- 如果压缩了,需要解压
    local strzip = str
    if __head.ver == 5 then
    	strzip = lz.inflate()(str, "finish") 
    	-- myprint("解压数据包")
    elseif(__head.ver == 6) then
    	-- 此处还需加上帐号(待正式化)
    	local sKey = SOCKET_ENCRYPT_KEY .. AccountCenter.acc
    	strzip = cc.Crypto:decryptXXTEA(str, string.len(str), 
    		sKey, string.len(sKey))
    end	
	return strzip
end

function PacketBuffer.getBaseBA()
	return cc.utils.ByteArrayVarint.new(PacketBuffer.ENDIAN)
end

--- 生成发送包
-- @param __msgDef the define of message, a table
-- @param __msgBodyTable the message body with key&value, a table
function PacketBuffer.createPacket(msgDef, msgBodyTable)	
	--生成包体的表
	local temp = {}
	for i=1,#msgDef.keys do
		temp[msgDef.keys[i]] = msgBodyTable[i]
	end
	--将表转化为Json格式的字符串
	local jsonstr = json.encode(temp)
	--生成包体
	local bodybuf,ver = PacketBuffer.createBody(jsonstr)

	--计算包头长度,包体长度	
	local bodyLen = bodybuf:getLen()
	--生成包头
	local headbuf = PacketBuffer.createHead(msgDef.ID, bodyLen, ver)
	if SHOW_NET_LOG then
		myprint("SENT: [type=" .. msgDef.ID.. ", len=" .. bodyLen .. ", ver=" .. ver .. "], body=" .. jsonstr)
	end	
	--构建消息
	local msgBuf = PacketBuffer.getBaseBA()	
	msgBuf:writeBytes(headbuf)	
	msgBuf:writeBytes(bodybuf)
	return msgBuf
end

function PacketBuffer:ctor()
	self:init()
end

function PacketBuffer:init()
	self._buf = PacketBuffer.getBaseBA()
end

--解析整包
--- Get a byte stream and analyze it, return a splited table
-- Generally, the table include a message, but if it receive 2 packets meanwhile, then it includs 2 messages.
function PacketBuffer:parsePackets(__byteString)
	local __msgs = {}
	local __pos = 0
	self._buf:setPos(self._buf:getLen()+1)
    -- 在buffer中已有数据的情况下, writeBuf方法写入的数据不对
    -- 暂用以下方法代替
	-- self._buf:writeBuf(__byteString)
--    for i=1, #__byteString do
--        local b = string.byte(__byteString, i)
--        self._buf:writeByte(b)
--    end
    for k, v in  pairs(__byteString) do        
        self._buf:writeByte(v)
    end
	self._buf:setPos(1)
	local __preLen = PacketBuffer.HEAD_LEN
	
    -- 检测当前buffer是否超过包头长度
    while self._buf:getAvailable() >= __preLen do
        local __msg = {}
	    local __pos = self._buf:getPos()
        -- 解析包头
	    local __head = PacketBuffer.parseHead(self._buf)
	    if __head.bodylen <= self._buf:getAvailable() then
            -- 检测当前buffer是否完整包含当前消息
		    __msg.head = __head
			local bodyjson = PacketBuffer._parseBody(self._buf, __head)
		    __msg.body = json.decode(bodyjson)
			if SHOW_NET_LOG then
				myprint("RECEIVED: [type="..__head.type ..", len=" .. __head.bodylen .. ", ver=" .. __head.ver.. "], body=" .. bodyjson)
			end
            __msgs[#__msgs+1] = __msg
        else
	        self._buf:setPos(__pos)
            break
        end
    end

	-- 所有数据读完
	if self._buf:getAvailable() <= 0 then
		self:init()
	else
		-- 有一些数据还没读完,把它写到一个新的消息中
		local __tmp = PacketBuffer.getBaseBA()
		self._buf:readBytes(__tmp, 1, self._buf:getAvailable())
		self._buf = __tmp

	end
	return __msgs
end

return PacketBuffer
