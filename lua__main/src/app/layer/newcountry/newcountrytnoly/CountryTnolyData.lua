-- CountryTnolyData.lua
-----------------------------------------------------
-- Author: dshulan
-- Date: 2018-03-30 18:53:53
-- Description: 国家科技基础数据
-----------------------------------------------------
-- local CountryTnoly = require("app.layer.newcountry.newcountrytnoly.CountryTnoly")
-- 国家科技数据类
local CountryTnolyData = class("CountryTnolyData")


function CountryTnolyData:ctor(  )
	self:myInit()
end

function CountryTnolyData:myInit(  )		
	self.nStage 					= 1 				--科技阶段
	self.tAllTnoly 					= {}				--该阶段所有的科技集合
	self.tUpdateTnoly 				= {}				--更新的科技集合
	self.nLeftDonate 				= 0 				--剩余捐献次数
	self.nRCd 						= nil 				--恢复捐献次数CD时间
	self.nGoldDonate 				= 0 				--今日使用的黄金捐献次数
	self.fLastLoadTime 				= nil 				--（long）最后一次加载倒计时时间
end

--刷新服务器数据
function CountryTnolyData:refreshDatasByService( _tData )
	-- dump(_tData, "国家科技数据 ==== ")
	if not _tData then
	 	return
	end
	self.nStage 					= _tData.s or self.nStage			--科技阶段
	self.nLeftDonate 				= _tData.d or self.nLeftDonate		--剩余捐献次数
	if _tData.rcd then
		self.nRCd 					= _tData.rcd						--恢复捐献次数CD时间
		self.fLastLoadTime 			= getSystemTime() 			       	--（long）最后一次加载倒计时时间
	end
	self.nGoldDonate 				= _tData.gd or self.nGoldDonate		--今日使用的黄金捐献次数


	--该阶段所有的科技集合
	if _tData.ss and table.nums(_tData.ss) > 0 then
		for k, v in pairs(_tData.ss) do
			local tTnoly = getCountryTnoly(v.i)
			if tTnoly then
				tTnoly:updateByService(v)
				self.tAllTnoly[v.i] = tTnoly
			end
		end
	end
	--更新的科技集合
	if _tData.us and table.nums(_tData.us) > 0 then
		for k, v in pairs(_tData.us) do
			local tTnoly = getCountryTnoly(v.i)
			if tTnoly then
				tTnoly:updateByService(v)
				self.tUpdateTnoly[v.i] = tTnoly
			end
		end
	end
	if _tData.o then
		--获取物品效果
		showGetAllItems(_tData.o)
	end

	--发送刷新消息
	sendMsg(gud_refresh_country_tnoly)
end

-- 获取恢复捐献次数剩下时间
-- return(int):返回剩余时长
function CountryTnolyData:getRecoverDonateLeftTime(  )
	if self.fLastLoadTime == nil or self.nRCd == nil then
		return -999
	end
	-- 单位是秒
	local fCurTime = getSystemTime()
	-- 总共剩余多少秒
	local fLeft = self.nRCd - (fCurTime - self.fLastLoadTime)
	if(fLeft < 0) then 
		fLeft = 0
	end
	return fLeft
end

--根据id获取国家科技
function CountryTnolyData:getCountryTnolyById(_id)
	if not _id then
		return
	end
	return self.tAllTnoly[_id]
end

--获取捐献消耗量和获得的贡献量
function CountryTnolyData:getDonateCostAndAwards()
	local sParam = getCountryParam("donate")
	local tParam = luaSplitMuilt(sParam, ";", ",")
	local nCount = table.nums(tParam)
	local nPlayerLv = Player:getPlayerInfo().nLv
	if nPlayerLv >= tonumber(tParam[nCount][1]) then
		return tonumber(tParam[nCount][2]), tonumber(tParam[nCount][3])
	end
	for i = 1, nCount do
		if nPlayerLv >= tonumber(tParam[i][1]) and nPlayerLv < tonumber(tParam[i+1][1]) then
			return tonumber(tParam[i][2]), tonumber(tParam[i][3])
		end
	end
end

--获取已推荐科技数量
function CountryTnolyData:getDidRecommendNum()
	local nDidRecNum = 0
	local tAllTnoly = getCountryTnolyData()
	for k, v in pairs(tAllTnoly) do
		if v.nRecommend == 1 then
			nDidRecNum = nDidRecNum + 1
		end
	end
	return nDidRecNum
end

--是否可以推荐科技
function CountryTnolyData:getIsCanRecommend()
	-- body
	--推荐科技数量上限
	local nRecoNum = tonumber(getCountryParam("scienceNum"))
	--已推荐数量
	local nDidRecNum = self:getDidRecommendNum()
	return nDidRecNum < nRecoNum
end

--获取是否该阶段科技已解锁
--_stage: 阶段
-- function CountryTnolyData:getIsCoTnolyOpen(_stage)
-- 	-- body
-- 	if _stage <= 1 then
-- 		return true
-- 	end
-- 	--判断上一阶段所有科技是否全部满级
-- 	local tTnolyList = getCountryTnolysByStage(_stage-1)
-- 	for k, v in pairs(tTnolyList) do
-- 		if v.nLevel < v.nMaxLevel then
-- 			return false
-- 		end
-- 	end
-- 	return true
-- end


--判断红点
function CountryTnolyData:getRedNum()
	local nRedNum = 0
	local nDonateLimit = tonumber(getCountryParam("donateLimit"))
	if self.nLeftDonate >= nDonateLimit then
		nRedNum = 1
	end
	return nRedNum
end

return CountryTnolyData
