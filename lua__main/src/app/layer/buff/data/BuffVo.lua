local BuffVo = class("BuffVo")

function BuffVo:ctor( tData )
	self:update(tData)
end

function BuffVo:update( tData )
	self.nId = tData.b or self.nId	--Integer	buff id
	self.nTime = tData.t or self.nTime --	Long	持续时间[time]
	self.nRemainCd = tData.r or self.nRemainCd --	Long	剩余时间[remain]
	if tData.r then
		self.nRemainCdSystemTime = getSystemTime()
	else
		self.nRemainCd = -999
	end
end

function BuffVo:getRemainCd(  )
	if self.nRemainCd and self.nRemainCd > 0 then
		local fCurTime = getSystemTime()
		local fLeft = self.nRemainCd - (fCurTime - self.nRemainCdSystemTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return -999
	end
end

function BuffVo:getBuffEffects(  )
	local tEffectDict = {}
	local tEffects = {}
	local tData = getBuffDataByIdFromDB(self.nId)
	if tData then
		if tData.nTime == -1 then
			tEffects = tData:getEffects()
		else
			if self:getRemainCd() <= 0 then
				tEffects = {}
			else
				tEffects = tData:getEffects()
			end
		end
	end
	for k,v in pairs(tEffects) do
		local nKey = tonumber(v[1])
		local nValue = tonumber(v[2])
		if nKey and nValue then
			tEffectDict[nKey] = nValue
		end
	end
	return tEffectDict
end

--获取buff相关加乘
function BuffVo:getBuffPercentAdd( nBuffKey )
	local tData = getBuffDataByIdFromDB(self.nId)
	if tData then
		if tData.nTime == -1 or self:getRemainCd() > 0 then
			return tData:getBuffPercentAdd(nBuffKey)
		end
	end
	return 0
end

return BuffVo