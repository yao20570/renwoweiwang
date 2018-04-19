local PlayTpackVo = class("PlayTpackVo")

function PlayTpackVo:ctor( tData )
	self.bIsTake = false
	self.bIsOffLine = false
	--专用于活动剩余时间
	self.nType = 1
	self:update(tData)
end

function PlayTpackVo:update( tData )
	if not tData then
		return
	end
	self.nPid = tData.p or self.nPid	--Integer	触发礼包的id
	self.nGid = tData.g or self.nGid	--Integer	礼品id

	if not self.tItemKVList then
		self.tItemKVList = {}
		local tConf = getTpackData(self.nPid, self.nGid)
		if tConf then
			local tDropList = getDropById(tConf.dropid)
			for i=1,#tDropList do
				table.insert(self.tItemKVList, {k = tDropList[i].sTid, v = tDropList[i].nCt})
			end
		end
	end

	if tData.c1 then
		self.nCd = tData.c1	--Long	界面倒计时时间
		self.nCdSystemTime = getSystemTime()
	end

	if tData.c2 then
		self.nCd2 = tData.c2 --用来表示在活动内显示的倒计时
		self.nCdSystemTime2 = getSystemTime()
	end

	if tData.b then
		self.bIsTake = tData.b == 1	--Integer	是否购买
	end
	if tData.of then
		self.bIsOffLine = tData.of == 1 --Integer  是否离线触发
	end
end

--获取主界面显示的cd时间
function PlayTpackVo:getCd( )
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

--获取活动内显示的cd时间
function PlayTpackVo:getCd2( )
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

function PlayTpackVo:getItemKVList(  )
	return self.tItemKVList or {}
end

--专用于活动界面剩余时间
function PlayTpackVo:getRemainTime( )
	local sTime = getConvertedStr(5, 10210) 
	return "(".. sTime..getTimeLongStr(self:getCd2(),false,true)..")"
end


return PlayTpackVo