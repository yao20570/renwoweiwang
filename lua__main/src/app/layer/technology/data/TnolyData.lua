-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-05-09 15:50:03 星期二
-- Description: 科技数据
-----------------------------------------------------


local TnolyData = class("TnolyData")

function TnolyData:ctor(  )
	-- body
	self:myInit()
end


function TnolyData:myInit(  )

	self.tAllTnolyDatas  		=		{} 		--所有科技

	self.tUpingTnoly 			= 		nil 	--升级中的科技

	--初始化所有的科技
	self:initAllTnolyDatas() 
	--研究员信息
	self.nId 					= 		nil		--研究员ID
	self.fCD 					= 		nil 	--研究员剩余时间 
	self.nFast 					= 		false 	--研究员加速标志 1:可加速 0:不可加速

	self.nLastLoadResearcherTime = 		nil     --记录最后一次刷新研究员信息的时间
end

--从服务端获取数据刷新
function TnolyData:refreshDatasByService( tData )
	--dump(tData,"科技数据tData=",100)
	
	--刷新升级中的科技
	self:refreshUpingTnoly(tData)

	--刷新已创建的科技数据
	self:refreshTnolyDatas(tData.sciences)
	--研究员倒计时不为空，则刷新研究员信息
	self:refreshResercherByService(tData)
end



--刷新升级中的科技
function TnolyData:refreshUpingTnoly( tData )
	-- body
	if tData.nid then
		self.tUpingTnoly = self:getTnolyByIdFromAll(tData.nid)
		if self.tUpingTnoly then
			self.tUpingTnoly:refreshUpingDatasByService(tData)
		end
	end
	self.nFast 					= 		tData.sp  			--加速标志 1:可加速 0:不可加速
end

--科技操作数据刷新
--nType：操作类型 1.研究员加速 2.元宝加速3.完成科技
function TnolyData:refreshUpingTnolyByAction( tData, nType )
	-- body
	if self.tUpingTnoly then
		--刷新升级数据
		self.tUpingTnoly:refreshUpingDatasByService(tData)
		--刷新等级相关数据
		self.tUpingTnoly:refreshDatasByService(tData)
	end
	if nType == 3 then --完成科技
		local sTip = self.tUpingTnoly:getUpTnolyTipsByType(nType)
		TOAST(sTip)
		--刷新等级相关数据
		self.tUpingTnoly:refreshDatasByService(tData)
		self.tUpingTnoly = nil
	end
	if tData.sp ~= nil then
		self.nFast 					= 		tData.sp  			--加速标志 1:可加速 0:不可加速
	end
	if nType == 4 then
		self:refreshResercherByService(tData)
	end
end

--通过推送刷新数据
--_nType: 1:是否免费加速
function TnolyData:refreshByPush( _nType, _tData )
	-- body
	if _nType == 1 then
		if _tData.sp ~= nil then
			self.nFast 				= 		_tData.sp  			--加速标志 1:可加速 0:不可加速
		end
	end
end

--获得升级中的科技
function TnolyData:getUpingTnoly(  )
	-- body
	return self.tUpingTnoly
end

--刷新已经创建的科技数据
function TnolyData:refreshTnolyDatas( tData )
	-- body
	if tData and table.nums(tData) > 0 then
		for k, v in pairs (tData) do
			local tTnoly = self:getTnolyByIdFromAll(v.id)
			if tTnoly then
				tTnoly:refreshDatasByService(v)
			end
		end
	end
end

--获得所有的科技
function TnolyData:initAllTnolyDatas(  )
	-- body
	self.tAllTnolyDatas = getAllTechnologyFromDB()
end

--获得所有的科技
function TnolyData:getAllTnolyDatas(  )
	-- body
	return self.tAllTnolyDatas
end

--根据id获得某个科技
function TnolyData:getTnolyByIdFromAll( _nId )
	-- body
	return self.tAllTnolyDatas[_nId]
end

--根据关键字获取科技树对应位置的科技
function TnolyData:getTnolyByKeyFromAll( _sKey )
	-- body
	local tTonly = nil
	if self.tAllTnolyDatas and table.nums(self.tAllTnolyDatas) > 0 then
		for k, v in pairs (self.tAllTnolyDatas) do
			if v.sKeyTree == _sKey then
				tTonly = v
				break
			end
		end
	end
	return tTonly
end

--获得可以升级的科技队列
function TnolyData:getCanUpTnolyLists( )
	-- body
	local tT = nil
	if self.tAllTnolyDatas and table.nums( self.tAllTnolyDatas) > 0 then
		tT = {}
		for k, v in pairs (self.tAllTnolyDatas) do
			--未锁住的科技，并且当前没有在研究中...还有未满级
			-- if v:checkisLocked() == false and not v:isMaxLv() then 
				--判断是否在研究中
				if self.tUpingTnoly and v.sTid == self.tUpingTnoly.sTid then
					
				else
					table.insert(tT, v)
				end
			-- end
		end
	end
	return tT
end


--获取加成效果值
--_tBuff：buff数据
function TnolyData:getEffectsValue( _tBuff )
	-- body
	local sValue = ""
	local nType = 0
	if _tBuff then
		local tEffects = _tBuff:getEffects()
		--科技只认第一个效果
		if tEffects and table.nums(tEffects) >= 0 then
			local tT = tEffects[1]
			if tT then
				--获得效果数据
				local tE = getEffectDataByIdFromDB(tT[1])
				if tE.keytype == 1 then --百分比
					sValue = math.floor(tonumber(tT[2]) * 100) .. "%"
					nType = 1
				elseif tE.keytype == 2 then --数值
					sValue = "" .. tT[2]
					nType = 2
				end
			end
		end
	end
	return sValue, nType
end
--刷新研究员数据
function TnolyData:refreshResercherByService( tData )
	-- body
	if tData.rd then
		self.nId = tData.rId or self.nId
		self.fCD = tData.rd or self.fCD
		self.nLastLoadResearcherTime = getSystemTime() --记录最后一次刷新研究员信息的时间
		if self.fCD <= 0 then
			self.nId = nil
		end
		--发送雇用研究院消息
		sendMsg(ghd_refresh_researcher_msg)
	end
end

--是否可以免费加速(研究员加速)
function TnolyData:isCanFreeUp(  )
	-- body
	local bCan = false
	local tUpingTnoly = self:getUpingTnoly()
	if tUpingTnoly and tUpingTnoly:getUpingFinalLeftTime() > 0 and self.nFast == 1 then
		bCan = true
	end
	return bCan
end

--获取研究员数据
function TnolyData:getResearcherBaseData(  )
	-- body
	if not self.nId or self:getCurResearcherCD() <= 0 then
		return nil
	end
	return getResearcherDataByID(self.nId)
end

--获取当前文官的剩余时间
function TnolyData:getCurResearcherCD(  )
	-- body
	-- 单位是秒
	if self.fCD then		
		local fCurTime = getSystemTime()
		-- 总共剩余多少秒
		local fLeft = self.fCD - (fCurTime - self.nLastLoadResearcherTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
	 
end

--科技在研究弹窗列表中是否存在
function TnolyData:isInScienceList( nTarScienceId )
	-- body
	if not nTarScienceId then
		return false
	end
	if self.tUpingTnoly and  self.tUpingTnoly.sTid == nTarScienceId then
		return true
	end
	local tCanUp = self:getCanUpTnolyLists()
	if tCanUp and #tCanUp > 0 then
		for k, v in pairs(tCanUp) do
			if v.sTid == nTarScienceId then
				return true
			end
		end
	end
	return false
end

--是否有已完成研究的科技
function TnolyData:isTnolyOK()
	-- body
	local tUpingTnoly = self:getUpingTnoly()
	if tUpingTnoly then
		if tUpingTnoly:getUpingFinalLeftTime() <= 0 then
			return true
		else
			return false
		end
	else
		return false
	end
end

--获得列表底部的推荐科技(不包含已满的)
function TnolyData:getRecommendLists()
	-- body
	local tT = {}
	if self.tAllTnolyDatas and table.nums( self.tAllTnolyDatas) > 0 then
		for k, v in pairs (self.tAllTnolyDatas) do
			if v.nRecommend > 0 and not v:isMaxLv() then 
				table.insert(tT, v)
			end
		end
		--排序, 序号小的优先
		if #tT > 1 then
			table.sort(tT, function(a, b)
				return a.nRecommend < b.nRecommend
			end)
		end
	end
	return tT
end


return TnolyData