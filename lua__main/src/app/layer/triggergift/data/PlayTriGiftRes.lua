local PlayTriGiftRes = class("PlayTriGiftRes")

function PlayTriGiftRes:ctor( tData )
	self.bIsTake = false
	self.bIsOffLine = false
	--专用于活动剩余时间
	self.nType = 1
	self:update(tData)
end

function PlayTriGiftRes:update( tData )
	if not tData then
		return
	end
	self.nPid = tData.pid or self.nPid	--Integer	触发礼包的id
	if not self.tItemKVList then
		self.tItemKVList = {}
		local tConf = getTriGiftData(self.nPid)
		if tConf then
			local tDropList = getDropById(tConf.item)
			for i=1,#tDropList do
				table.insert(self.tItemKVList, {k = tDropList[i].sTid, v = tDropList[i].nCt})
			end
		end
	end

	if tData.cd then
		self.nCd = tData.cd	--Long	倒计时时间
		self.nCdSystemTime = getSystemTime()
	end

	if tData.cd2 then
		self.nCd2 = tData.cd2 --用来表示在活动内显示的倒计时
		self.nCdSystemTime2 = getSystemTime()
	end

	if tData.take then
		self.bIsTake = tData.take == 1	--Integer	是否购买
	end
	if tData.off then
		self.bIsOffLine = tData.off == 1 --Integer  是否离线触发
	end
end

function PlayTriGiftRes:getCd( )
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

function PlayTriGiftRes:getCd2( )
	if self.nCd2 and self.nCd2 > 0 then
		local fCurTime = getSystemTime()
		local fLeft = self.nCd2 - (fCurTime - self.nCdSystemTime2)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
end

function PlayTriGiftRes:getItemKVList(  )
	return self.tItemKVList or {}
end

--专用于活动界面剩余时间
function PlayTriGiftRes:getRemainTime( )
	local sTime = getConvertedStr(5, 10210) 
	return "(".. sTime..getTimeLongStr(self:getCd2(),false,true)..")"
end


return PlayTriGiftRes