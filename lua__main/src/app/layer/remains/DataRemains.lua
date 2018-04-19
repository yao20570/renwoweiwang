----------------------------------------------------- 
-- author: maheng
-- Date: 2018-3-2 19:30:41
-- Description: 韬光养晦数据
-----------------------------------------------------

local DataRemains = class("DataRemains")
local RemainsTaskVo = require("app.layer.remains.RemainsTaskVo")
function DataRemains:ctor(  )
	self.nType 	= 1
	self.nFg 	= 0     --	fg	Integer	是否已经领取韬光养晦免费奖励 0:否 1:是
	self.tRemainsTask = getRemainsTaskDatas()
	self.tGets 	= {}    --  gets	Set<Integer>	已领取
	self.tTfs 	= {}    --  tfs	List<Pair<Integer,Integer>>	任务完成进度 Pair的k:任务ID v:完成次数
	self.nCd 	= 0 	--  cd  Integer 活动倒计时
	self.nLastLoadTime = nil
end

function DataRemains:refreshDatasByService( tData )
	if not tData then
		return
	end
	self.nFg = tData.fg or self.nFg    --	fg	Integer	是否已经领取韬光养晦免费奖励 0:否 1:是
	self.tGets = tData.gets or self.tGets     --gets	Set<Integer>	已领取
	self.tTfs = tData.tfs or self.tTfs      --tfs	List<Pair<Integer,Integer>>	任务完成进度 Pair的k:任务ID v:完成次数	
	if tData.gets then
		self:updateRewardStatus()
	end
	if tData.tfs then
		self:updateTaskProgress()
	end
	self.nCd = tData.cd or self.nCd
	if tData.cd then
		self.nLastLoadTime = getSystemTime() --最后一次刷新cd的时间
	end	
end
--刷新任务奖励状态
function DataRemains:updateRewardStatus(  )
	-- body
	for k, v in pairs(self.tRemainsTask) do
		v:updateRewardStatus(self:isGetTaskRewardById(v.nId))
	end
end
--刷新任务进度
function DataRemains:updateTaskProgress(  )
	-- body
	for k, v in pairs(self.tRemainsTask) do
		v:setTaskSchedule(self:getTaskProgressById(v.nId))
	end
end
--是否已经领取奖励
function DataRemains:isGetTaskRewardById( _id )
	-- body
	if not _id then
		return false
	end
	for k, v in pairs(self.tGets) do
		if v == _id then
			return true
		end
	end
	return false
end

--任务完成进度
function DataRemains:getTaskProgressById( _id )
	-- body
	if not _id then
		return 0
	end
	for k, v in pairs(self.tTfs) do
		if _id == v.k then
			return v.v
		end
	end
	return 0
end

--获取任务数据
function DataRemains:getTaskDataById( _id )
	-- body
	if not _id then
		return
	end
	local pData = nil
	for k, v in pairs(self.tRemainsTask) do
		if v.nId == _id then
			pData = v
			break
		end
	end
	return pData
end

--获取任务数据列表
function DataRemains:getTaskDatasByStage( )
	-- body
	local tTask = {}
	local nStage = Player:getWorldData():getWorldOpenState()
	for k, v in pairs(self.tRemainsTask) do
		if v.nStage == nStage then
			table.insert(tTask, v)
		end
	end
	return tTask
end

--时间
function DataRemains:getRemainTime( )
	-- body	
	local sTime = ""
	sTime = getConvertedStr(5, 10210)
	local nNowTime = getSystemTime()
	local nTime  = self.nCd - (nNowTime - (self.nLastLoadTime or 0))
	sTime = "(".. sTime..getTimeLongStr(nTime,false,true)..")"
	return sTime
end
--是否开启
function DataRemains:isOpen( )
	-- body	
	local nNowTime = getSystemTime()
	local nTime  = self.nCd - (nNowTime - (self.nLastLoadTime or 0))
	return nTime > 0
end

function DataRemains:getFreeRewards(  )
	-- body
	local tReward = {}
	local nStage = Player:getWorldData():getWorldOpenState()
	local nDropID = nil 
	if nStage == 1 then--州
		nDropID = getStrongerParam("freedrop1")
	else--阿房宫
		nDropID = getStrongerParam("freedrop2")
	end
	tReward = getDropById(nDropID)
	if tReward and #tReward > 0 then
		table.sort(tReward, function(a, b)
			return a.nQuality > b.nQuality
		end)
	end
	return tReward
end

function DataRemains:getRewardRedNum(  )
	-- body
	local nNum = 0
	if self.nFg == 0 then
		nNum = nNum + 1
	end
	local tTasks = self:getTaskDatasByStage()
	for k, v in pairs(tTasks) do
		if v:isCanGetReward() then
			nNum = nNum + 1
		end
	end
	return nNum
end
return DataRemains