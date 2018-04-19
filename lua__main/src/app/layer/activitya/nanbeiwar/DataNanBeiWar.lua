-- Author: liangzhaowei
-- Date: 2017-06-20 17:08:13
-- 南征北战数据
local Activity = require("app.data.activity.Activity")
local CountryWarActMission = require("app.layer.activitya.nanbeiwar.CountryWarActMission")

local DataNanBeiWar = class("DataNanBeiWar", function()
	return Activity.new(e_id_activity.nanbeiwar) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.nanbeiwar] = function (  )
	return DataNanBeiWar.new()
end

-- _index
function DataNanBeiWar:ctor()
	-- body
   self:myInit()
end


function DataNanBeiWar:myInit( )

  self.tMissions	 =    {}       --List<CountryWarActMission>	任务数据
  self.tFinishInfo   = 	  {}       --List<Pair<Integer,Integer>>	各任务已达成次数 Pair K:任务ID V:达成次数
  self.tRewarded	 =    {}       --List<Integer>	            已领取奖励的任务ID

end


-- 读取服务器中的数据
function DataNanBeiWar:refreshDatasByServer( _tData )
	-- dump(_tData,"数据",20)
	if not _tData then
	 	return
	end

	self:setMissions(_tData.missions) --List<CountryWarActMission>	任务数据
	self:setFinishInfo(_tData.finishInfo)--List<Pair<Integer,Integer>>	各任务已达成次数 Pair K:任务ID V:达成次数
    self:setRewarded(_tData.rewarded) --List<Integer>	            已领取奖励的任务ID
    self:sortMissions()

	self:refreshActService(_tData)--刷新活动共有的数据

end

--设置任务数据
function DataNanBeiWar:setMissions( tMissions )
	if not tMissions then
		return
	end
	self.tMissions = {}
	for i=1,#tMissions do
		local tMission = CountryWarActMission.new(tMissions[i])
		tMission:setDesc(self.tSubtitle[i])
		table.insert(self.tMissions, tMission)
	end
end


function DataNanBeiWar:sortMissions(  )
	--排序
	table.sort(self.tMissions, function ( a, b )
		--可领奖
		--未完成
		--已完成
		local bIsCanGetA = self:getIsCanGetReward(a)
		local bIsCanGetB = self:getIsCanGetReward(b)
		if bIsCanGetA ~= bIsCanGetB then --两个中有一个是可领奖励
			if bIsCanGetA == true then
				return true
			else
				return false
			end
		else
			if bIsCanGetA == true then --两个都是可领奖
				return a.nId < b.nId
			else
				--两个都是未完成
				local bIsGotRewardA = self:getIsRewarded(a.nId)
				local bIsGotRewardB = self:getIsRewarded(b.nId)
				if bIsGotRewardA ~= bIsGotRewardB then --两个中有一个是已奖励
					if bIsGotRewardA == true then
						return false
					else
						return true
					end
				else
					return a.nId < b.nId
				end
			end
		end
		return a.nId < b.nId
	end)
end

--设置完成次数数据 
function DataNanBeiWar:setFinishInfo( tFinishInfo )
	if not tFinishInfo then
		return
	end
	self.tFinishInfo = {}
	for i=1,#tFinishInfo do
		local nTaskId = tFinishInfo[i].k
		local nTimes = tFinishInfo[i].v
		self.tFinishInfo[nTaskId] = nTimes
	end
end

--设置已领取奖励的任务ID
function DataNanBeiWar:setRewarded( tRewarded )
	if not tRewarded then
		return
	end
	self.tRewarded = {}
	for i=1,#tRewarded do
		local nTaskId = tRewarded[i]
		self.tRewarded[nTaskId] = true
	end
end

--获取任务数据
function DataNanBeiWar:getMissions( )
	return self.tMissions
end

--获取完成次数
function DataNanBeiWar:getFinishTimes( nTaskId )
	if not self.tFinishInfo then
		return 0
	end
	return self.tFinishInfo[nTaskId] or 0
end

--获取是否已领取
function DataNanBeiWar:getIsRewarded( nTaskId )
	if not self.tRewarded then
		return false
	end

	return self.tRewarded[nTaskId] or false
end

--获取是否可以领取
function DataNanBeiWar:getIsCanGetReward( tMission )
	--是否已经领取
    local bIsGot = self:getIsRewarded(tMission.nId)
    if bIsGot then
    	return false
    end
	local nCurrTimes = self:getFinishTimes(tMission.nId)
	local nNeedTimes = tMission.nTimes
	return nCurrTimes >= nNeedTimes
end

-- 获取红点方法
function DataNanBeiWar:getRedNums()
	local nNums = 0
	for k,v in pairs(self.tMissions) do
		if self:getIsCanGetReward(v) then
			nNums = nNums + 1
		end
	end
	nNums = self.nLoginRedNums + nNums
	return nNums
end


--获取是否所有任务都领取完
function DataNanBeiWar:getIsGotAllReward( )
	for k,v in pairs(self.tMissions) do
		if not self:getIsRewarded(v.nId) then
			return false
		end
	end
	return true
end



return DataNanBeiWar