-----------------------------------------------------
-- author: wangxs
-- updatetime:  2017-05-09 16:01:45 星期二
-- Description: 科技结构体
-----------------------------------------------------

local Goods = require("app.data.Goods")

local Tnoly = class("Tnoly", Goods)


function Tnoly:ctor(  )
	Tnoly.super.ctor(self,e_type_goods.type_tnoly)
	-- body
	self:myInit()
end


function Tnoly:myInit(  )
	self.nMaxLv 			= 		0 		--最大等级上限
	self.nOrder 			= 		0 		--排序
	self.sKeyTree 			= 		"" 		--科技树key值
	self.bLocked 			= 		false 	--是否锁住
	self.tLimitUpData 		= 		nil 	--升级数据

	self.nCurIndex 			= 		0 		--当前段数
	self.fLastStudytime     =       0       --上次完成研究时间

	--升级中的数据
	self.fStudingCd 		= 		nil 	--当前研究的科技剩余CD
	self.fStudingAllTime 	= 		nil 	--当前研究的科技总时间
	self.fLastLoadingTime 	= 		nil 	--最后加载的时间点 	
	self.nRecruitFood       =       0       --招募士兵耗粮
	self.nRecommend			= 		0 		--推荐顺序
	self.nHelp 				= 		0       --是否请求帮助
end


-- 用配置表DB中的数据来重置基础数据
function Tnoly:initDatasByDB( tData )
	-- body
	self.sTid 				= 		tData.id  			           			 --科技id
	self.sName 				= 		tData.name 			           			 --科技名称
	self.nMaxLv 			= 		tData.maxlv or self.nMaxLv  			 --等级上限
	self.nOrder 			= 		tData.sequence or self.nOrder  			 --排序
	self.sIcon 				= 		"#"..tData.icon .. ".png"      			 --icon
	self.sSmallIcon 		= 		"#"..tData.icon .. "_s.png"    			 --icon
	self.sKeyTree 			= 		tData.area or self.sKeyTree    			 --科技树key值
	self.nRecruitFood       =       tData.recruitfood or self.nRecruitFood   --招募士兵耗粮
	self.nRecommend 		= 		tData.recommend or self.nRecommend 		 --推荐顺序
end

--从服务端获取数据刷新
function Tnoly:refreshDatasByService( tData )
	-- dump(tData, "Tnoly:refreshDatasByServic =>", 100)
	-- body
	self.nPreIndex          =       self.nCurIndex
	if tData then
		self.nLv 			= 		tData.lv or self.nLv 			--等级
		self.nCurIndex 		=  		tData.st or self.nCurIndex 		--段数
		self.fLastStudytime =       tData.ft or self.fLastStudytime --上次完成研究时间
		self.nHelp 			=    	tData.rh or self.nHelp --是否请求帮助

		--重置一下升级数据
		self:initLimitData()
	end
end

--刷新升级中的科技
function Tnoly:refreshUpingDatasByService( tData )
	--dump(tData, "Tnoly:refreshUpingDatasByService =>", 100)
	-- body
	self.fStudingCd 			= 		tData.cd or self.fStudingCd 	 --当前研究的科技剩余CD
	self.fStudingAllTime 		= 		tData.nd or self.fStudingAllTime --当前研究的科技总时间
	self.nHelp 					=    	tData.rh or self.nHelp           --是否请求帮助
	if tData.cd then
		self.fLastLoadingTime 	= 		getSystemTime() 	             --最后加载的时间点 
	end
end

-- 获取建筑升级剩下时间
-- return(int):返回剩余时长
function Tnoly:getUpingFinalLeftTime(  )
	-- 单位是秒
	if  self.fStudingCd and  self.fStudingCd > 0 then
		local fCurTime = getSystemTime()
		-- 总共剩余多少秒
		local fLeft = self.fStudingCd - (fCurTime - self.fLastLoadingTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
end

--获得当前金币完成所需要的值
--注意：加速消耗金币会受到多方面影响，统一处理，统一调用
function Tnoly:getTnolyCurrentFinishValue(  )
	-- body
	--完成需要的时间
	local lCurLeftTime = self:getUpingFinalLeftTime()
	return getGoldByTime(lCurLeftTime)
end

--根据等级获得升级数据
--_nLv：等级
function Tnoly:getLimitDataByLv( _nLv )
	-- body
	local tLimitData = nil
	if _nLv < 10 then
		_nLv = "0" .. _nLv
	end
	local nUpId = self.sTid .. _nLv
	tLimitData = getTnolyUpDataByIdFromDB(nUpId)
	return tLimitData
end

--初始化升级数据
function Tnoly:initLimitData(  )
	-- body
	if self.tLimitUpData then
		self.tLimitUpData = nil
	end
	local nNextLv = self.nLv + 1
	if nNextLv > self.nMaxLv then
		self.tLimitUpData = self:getLimitDataByLv(self.nLv)
	else
		self.tLimitUpData = self:getLimitDataByLv(nNextLv)
	end
end

--获得下一级升级数据
function Tnoly:getNextLimitData(  )
	-- body
	if self.tLimitUpData == nil then
		self:initLimitData()
	end
	return self.tLimitUpData
end

--获得下一级升级时间
function Tnoly:getUpTime()
	local nUpTime = self.tLimitUpData.uptime
	--科技buff缩短科研时间
	local nLessPer = Player:getBuffData():getBuffPercentAdds(e_buff_key.technology_time_plus)
	nUpTime = nUpTime * (1 - nLessPer)
	return nUpTime
end

--获得当前已经升级数据
function Tnoly:getCurLimitData(  )
	-- body
	return self:getLimitDataByLv(self.nLv)
end

--获取上一等级的升级数据
function Tnoly:getPreLimitData()
	if self.nLv == 0 then
		return self:getLimitDataByLv(0)
	else
		return self:getLimitDataByLv(self.nLv - 1)
	end
	
end

--判断是否最大等级
function Tnoly:isMaxLv(  )
	-- body
	return self.nLv >= self.nMaxLv
end


--返回解锁具体情况
function Tnoly:getLockState()
	if self.tLimitUpData == nil then
		self:initLimitData()
	end
	local sTips = {}
	if self.tLimitUpData then
		local _sStr = self.tLimitUpData.unlock
		local  tT = luaSplitMuilt( _sStr,";",",")
		if tT then
			if tT[1] and table.nums(tT[1]) == 2 then
				local nLimitId = tonumber(tT[1][1]) --前置科技id
				local nLimitLv = tonumber(tT[1][2]) --前置科技等级（限制）
				if nLimitId ~= 0 then
					local nLimitTnoly = Player:getTnolyData():getTnolyByIdFromAll(nLimitId)
					if nLimitTnoly then
						local bLocked = false
						if nLimitTnoly.nLv < nLimitLv then
							bLocked = true
						end
						table.insert(sTips, {bLocked, nLimitTnoly.sName .. string.format(getConvertedStr(1, 10190),nLimitLv)})
					end
					end
			end

			--2.判断科技院等级是否满足
			if tT[2] then
				local tBuildInfo = Player:getBuildData():getBuildById(e_build_ids.tnoly)
				local nBuildLv = 0
				local name = getConvertedStr(7, 10161)
				if tBuildInfo then
					nBuildLv = tBuildInfo.nLv
				end
				local nLimitBuildLv = tonumber(tT[2])
				local bLocked_2 = false
				if nBuildLv < nLimitBuildLv then
					bLocked_2 = true
				end
				table.insert(sTips, {bLocked_2, name .. string.format(getConvertedStr(1, 10191), nLimitBuildLv)})
			end

			--3.判断主公等级是否满足
			if tT[3] then
				local nLimitPlayerLv = tonumber(tT[3])
				local bLocked_3 = false
				if Player:getPlayerInfo().nLv < nLimitPlayerLv then
					bLocked_3 = true
				end
				--条件大于1才显示
				if nLimitPlayerLv > 1 then
					table.insert(sTips, {bLocked_3, string.format(getConvertedStr(1, 10192), nLimitPlayerLv)})
				end 
			end
		end
	end
	return sTips
end

--判断是否未解锁
-- bNeedTips:是否需要提示语
function Tnoly:checkisLocked( bNeedTips )
	-- body
	if bNeedTips == nil then
		bNeedTips = false
	end
	if self:isMaxLv() then
		return false
	end
	if self.tLimitUpData == nil then
		self:initLimitData()
	end
	local bLocked = true
	local sTips = ""
	local nLockedType = nil --锁住阶段(前置科技为1, 科技院等级为2, 主公等级为3)
	if self.tLimitUpData then
		local _sStr = self.tLimitUpData.unlock
		if _sStr then
			local tT = luaSplitMuilt( _sStr,";",",")
			if tT then

				--1.判断是都有前置科技
				if tT[1] and table.nums(tT[1]) == 2 then
					local nLimitId = tonumber(tT[1][1]) --前置科技id
					local nLimitLv = tonumber(tT[1][2]) --前置科技等级（限制）
					if nLimitId ~= 0 then --表示有限制
						local nLimitTnoly = Player:getTnolyData():getTnolyByIdFromAll(nLimitId)
						if nLimitTnoly then
							if nLimitTnoly.nLv >= nLimitLv then
								bLocked = false
							else
								sTips = nLimitTnoly.sName .. string.format(getConvertedStr(1, 10190),nLimitLv)
							end 
						end
					else 			--表示没限制
						bLocked = false
					end
				end

				--如果已经是未解锁状态（表示有前置科技限制到了，可以直接返回）不需要解锁信息
				-- if bLocked and bNeedTips == false then
				-- 	return true
				-- end

				if bLocked then
					nLockedType = 1
					if bNeedTips == false then
						return true
					else
						return bLocked, sTips, nLockedType
					end
				end

				--2.判断科技院等级是否满足
				if tT[2] then
					local tBuildInfo = Player:getBuildData():getBuildById( e_build_ids.tnoly)
					if tBuildInfo then
						local nLimitBuildLv = tonumber(tT[2])
						if tBuildInfo.nLv >= nLimitBuildLv then
							bLocked = false
						else
							sTips = tBuildInfo.sName .. string.format(getConvertedStr(1, 10191), nLimitBuildLv)
							bLocked = true
						end
					end
				end

				--如果已经是未解锁状态（表示有前置科技限制到了，可以直接返回）不需要解锁信息
				-- if bLocked and bNeedTips == false then
				-- 	return true
				-- end
				if bLocked then
					nLockedType = 2
					if bNeedTips == false then
						return true
					else
						return bLocked, sTips, nLockedType
					end
				end

				--3.判断主公等级是否满足
				if tT[3] then
					local nLimitPlayerLv = tonumber(tT[3])
					if Player:getPlayerInfo().nLv >= nLimitPlayerLv then
						bLocked = false
					else
						sTips = string.format(getConvertedStr(1, 10192), nLimitPlayerLv)
						nLockedType = 3
						bLocked = true
					end
				end
			end
		end
	end
	return bLocked, sTips, nLockedType
end

--获得提示语
--_nType：1.研究员加速2.元宝加速3.完成科技
function Tnoly:getUpTnolyTipsByType( _nType )
	-- body
	local sTips = ""
	if _nType == 3 then
		sTips = self.sName ..  getLvString(self.nLv, true) 
			.. "(" ..  getConvertedStr(1,10176) .. (self.nPreIndex + 1) .. ")"
			.. getConvertedStr(1, 10183) --.. "\n" .. getConvertedStr(1, 10184)
	end
	return sTips
end

--在研究倒计时结束后获得提示语
function Tnoly:getUpTnolyTips()
	-- body
	local sTips = ""
	sTips = self.sName ..  getLvString(self.nLv+1, true) 
		.. "(" ..  getConvertedStr(1,10176) .. (self.nPreIndex + 1) .. ")"
		.. getConvertedStr(1, 10183)
	return sTips
end

--是否有前置科技
function Tnoly:isHadPreTonly(  )
	-- body
	local bHad = false
	if self.tLimitUpData == nil then
		self:initLimitData()
	end
	if self.tLimitUpData then
		local _sStr = self.tLimitUpData.unlock
		if _sStr then
			local tT = luaSplitMuilt( _sStr,";",",")
			if tT then
				--1.判断是都有前置科技
				if tT[1] and table.nums(tT[1]) == 2 then
					local nLimitId = tonumber(tT[1][1]) --前置科技id
					if nLimitId ~= 0 then --表示有限制
						bHad = true
					else 			--表示没限制
						bHad = false
					end
				end
			end
		end
	end
	return bHad
end

--获得解锁需求
function Tnoly:getUnlockedLimit(  )
	-- body
	local bLocked, sTips = self:checkisLocked(true)
	return sTips or ""
end


return Tnoly
