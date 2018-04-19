----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-07-04 15:08:32
-- Description: 全民返利数据
-----------------------------------------------------
local Activity = require("app.data.activity.Activity")
local PeopleRecBackCountryVo = require("app.layer.activityb.peoplerebate.PeopleRecBackCountryVo")
local PeopleRecBackAllVo = require("app.layer.activityb.peoplerebate.PeopleRecBackAllVo")

local DataPeopleRebate = class("DataPeopleRebate", function()
	return Activity.new(e_id_activity.peoplerebate) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.peoplerebate] = function (  )
	return DataPeopleRebate.new()
end

-- _index
function DataPeopleRebate:ctor()
   self:myInit()
end


function DataPeopleRebate:myInit( )
	self.tGets = {}
	self.tCGolds = {}
	self.tCulGoldAwardConf = {}
	self.nAGold = 0
end


-- 读取服务器中的数据
function DataPeopleRebate:refreshDatasByServer( tData )
	if not tData then
	 	return
	end

	if tData.gets then --Set<Integer>	已领取的玩家累计充值奖励
		self.tGets = {}
		for i=1,#tData.gets do
			local nId = tData.gets[i]
			self.tGets[nId] = true
		end
	end

	if tData.cGold then --List<PeopleRecBackCountryVo>	国家累计充值金币
		self.tCGolds = {}
		for i=1,#tData.cGold do
			local tPeopleRecBackCountryVo = PeopleRecBackCountryVo.new(tData.cGold[i])
			table.insert(self.tCGolds, tPeopleRecBackCountryVo)
		end
	end
	
	self.nAGold = tData.aGold or self.nAGold --	Long	全服累计充值金币

	self.tCRankAwardConf = tData.cRankAwardConf or self.tCRankAwardConf --List<Pair<Integer,Long>>	国家最高排名奖励配置

	if tData.culGoldAwardConf then --	List<PeopleRecBackAllVo>	全服累计金币奖励配置
		self.tCulGoldAwardConf = {}
		for i=1,#tData.culGoldAwardConf do
			table.insert(self.tCulGoldAwardConf, PeopleRecBackAllVo.new(tData.culGoldAwardConf[i]))
		end
	end
	--设置排序
	self:setSortCulGoldAwardConf()

	--刷新
	self:refreshActService(tData)--刷新活动共有的数据
end

-- 获取国家排列列表
function DataPeopleRebate:getCountryRecharges( )
	return self.tCGolds
end


--获取全服奖励排序的列表
function DataPeopleRebate:getCulGoldAwardConf( )
	return self.tCulGoldAwardConf
end

--获取最家国家奖励礼包
function DataPeopleRebate:getCountryGiftId( )
	if self.tCRankAwardConf[1] then
		return self.tCRankAwardConf[1].k
	end
	return nil
end

-- 设置排序 已达成目标未领取奖励项＞当前充值累计目标项＞已领取奖励项
function DataPeopleRebate:setSortCulGoldAwardConf( )
	table.sort(self.tCulGoldAwardConf, function(a, b)
		local nGoldId1 = a.nGold
		local nGoldId2 = b.nGold
		local bIsGot1 = self:getIsGotReward(nGoldId1)
		local bIsGot2 = self:getIsGotReward(nGoldId2)
		if bIsGot1 == bIsGot2 then
			if bIsGot1 == false then
				local bIsCanGet1 = self:getIsCanGetReward(nGoldId1)
				local bIsCanGet2 = self:getIsCanGetReward(nGoldId2)
				if bIsCanGet1 ~= bIsCanGet2 then
					if bIsCanGet1 then
						return true
					else
						return false
					end
				end
			end
			return nGoldId1 < nGoldId2
		else
			if bIsGot1 then
				return false
			else
				return true
			end
		end
	end)
end

--获取充值黄金列表
function DataPeopleRebate:getRechargeGolds( )
	local tRes = {}
	for i=1,#self.tCulGoldAwardConf do
		table.insert(tRes, self.tCulGoldAwardConf[i].nGold)
	end
	table.sort(tRes, function(a, b)
		return a < b
	end)
	return tRes
end

--获取是否可以领取
--nGold:累计充值黄金
function DataPeopleRebate:getIsCanGetReward( nGold )
	if self:getIsGotReward(nGold) then
		return false
	end
	return self.nAGold >= nGold
end

--获取是否已领去
function DataPeopleRebate:getIsGotReward( nGold )
	if self.tGets[nGold] then
		return true
	end
	return false
end


--获取积分进度
function DataPeopleRebate:getScoreBoxPercent(  )
	local nCurScore = self.nAGold
	local tGolds = self:getRechargeGolds()
	local nIndex = nil
	for i=1,#tGolds do
		if nCurScore < tGolds[i] then
			nIndex = i
			break
		end
	end
	--超过所有
	if nIndex == nil then
		return 100
	end

	local nPrevIndex = nIndex - 1
	local nPrevScore = tGolds[nPrevIndex] or 0
	local nSubScore = nCurScore - nPrevScore
	local nSubScoreMax = tGolds[nIndex] - nPrevScore

	local fSubPercent = (nSubScore/nSubScoreMax) * (1/#tGolds*100)
	local fPrevPercent = (nPrevIndex/#tGolds * 100)
	return fSubPercent + fPrevPercent
end

-- 获取红点方法
function DataPeopleRebate:getRedNums()
	local nNums = 0
	for k,v in pairs(self.tCulGoldAwardConf) do
		if self:getIsCanGetReward(v.nGold) then
			nNums = nNums + 1
		end
	end

	nNums = self.nLoginRedNums + nNums
	
	return nNums
end


return DataPeopleRebate