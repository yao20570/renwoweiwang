local CallInfo = class("CallInfo")
--召唤信息
function CallInfo:ctor( tData )
	self.nCallCdMax = 0
	self:update(tData)
end

function CallInfo:update( tData )
	if not tData then
		return
	end
	self.nCanCallPlayer  = tData.c	--Integer	可召唤人数
	self.nResponse = tData.r	--Integer	已响应人数
	self.nReCallMsgCd = tData.sc	--Integer	重发召唤消息的CD/秒
	self.nReCallMsgCdSystemTime = getSystemTime()
	self.nReCallCd = tData.cc	--Integer	重新召唤的CD/秒
	self.nReCallCdSystemTime = getSystemTime()
	self.nCallCdMax = tData.ts or self.nCallCdMax --Integer 召唤的总时长/秒
end

function CallInfo:getReCallMsgCd( )
	if self.nReCallMsgCd and self.nReCallMsgCd > 0 then
		local fCurTime = getSystemTime()
		local fLeft = self.nReCallMsgCd - (fCurTime - self.nReCallMsgCdSystemTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
end

function CallInfo:getReCallCd( )
	if self.nReCallCd and self.nReCallCd > 0 then
		local fCurTime = getSystemTime()
		local fLeft = self.nReCallCd - (fCurTime - self.nReCallCdSystemTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
end

return CallInfo

