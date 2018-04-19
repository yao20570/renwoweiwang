local MakeVo = class("MakeVo")

function MakeVo:ctor( tData )
	self:update(tData)
end

function MakeVo:update( tData )
	if not tData then
		return
	end
	self.nId = tData.i or self.nId --int	打造的装备ID
	self.nCd = tData.cd	or self.nCd --long	打造完成CD时间
	self.nSpeed = tData.sp or self.nSpeed--long 铁匠加速时间
	self.nHelp = tData.rh or self.nHelp --是否已经求助 1是0不是
	if tData.cd then
		self.nCdSystemTime = getSystemTime()
	end
end

function MakeVo:getCd(  )
	if self.nCd and self.nCd > 0 then
		local fCurTime = getSystemTime()
		local fLeft = self.nCd - (fCurTime - self.nCdSystemTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
end
--获取装备打造立即完成黄金消耗
function MakeVo:getEquipMakeCost( )
	-- body
	return getGoodByMakeTime(self:getCd())
end

function MakeVo:getConfigData(  )
	-- body
	return getBaseEquipDataByID(self.nId)
end
return MakeVo