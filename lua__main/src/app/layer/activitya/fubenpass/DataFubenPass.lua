-- DataFubenPass.lua
---------------------------------------------
-- Author: dshulan
-- Date: 2018-02-27 11:13
-- 副本推进数据
---------------------------------------------
local Activity = require("app.data.activity.Activity")
local DragonAdvanceActConfVo = require("app.layer.activitya.fubenpass.DragonAdvanceActConfVo")

local DataFubenPass = class("DataFubenPass", function()
	return Activity.new(e_id_activity.fubenpass) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.fubenpass] = function (  )
	return DataFubenPass.new()
end

function DataFubenPass:ctor()
	-- body
   self:myInit()
end


function DataFubenPass:myInit( )
 	self.tGotAwdList           = {}   --List<Long>         已经领取的奖励阶段
 	self.tConfs           	   = {}   --List<DragonAdvanceActConfVo>    奖励信息
 	self.nCurPassId            = nil
end

-- 读取服务器中的数据
function DataFubenPass:refreshDatasByServer( _tData )
	-- dump(_tData,"副本推进数据",20)
	if not _tData then
	 	return
	end
	self.tGotAwdList       		= _tData.alaw or self.tGotAwdList   --Set<Integer>      已经领取的奖励阶段
	if _tData.c then 												--章节id每次更新要判断, 更新最大的
		if self.nCurPassId == nil then
			self.nCurPassId = _tData.c
		else
			if _tData.c > self.nCurPassId then
				self.nCurPassId = _tData.c
			end
		end
	end
	
	if _tData.conf then
		for i = 1, #_tData.conf do
			local tData2 = DragonAdvanceActConfVo.new(_tData.conf[i])
			table.insert(self.tConfs, tData2)
		end
		--物品排序
		for i=1,#self.tConfs do
			sortGoodsList(self.tConfs[i].tAwards)
		end
	end
	--列表排序
	self:sortAwards(self.tConfs)

	self:refreshActService(_tData)                        --刷新活动共有的数据

end

--列表排序
function DataFubenPass:sortAwards(_tAwd)
	-- body
	if table.nums(_tAwd) == 0 then return end
	--把已领取的nTake置1,未领取为0
	for _, v in pairs(_tAwd) do
		if self:getIsRewarded(v.nIndex) then
			v.nTake = 1
		else
			v.nTake = 0
		end
    end
	--排序,已领取的置后
    table.sort(self.tConfs, function(a, b)
		-- body
		if a.nTake == b.nTake then
			return a.nIndex < b.nIndex
		else
			return  a.nTake < b.nTake
		end
	end)

end

--未达到
function DataFubenPass:getIsNotReach(_target)
	-- body
	return _target > self.nCurPassId
end

--该奖励是否可领
function DataFubenPass:getIsCanReward(_index)
	-- body
	local tConfs = nil
	for k, v in pairs(self.tConfs) do
		if v.nIndex == _index then
			tConfs = v
			break
		end
	end
	if tConfs == nil then
		return
	end
	if self.nCurPassId >= tConfs.nTarFubenId and not self:getIsRewarded(_index) then
		return true
	else
		return false
	end
end

--该奖励是否已领取
function DataFubenPass:getIsRewarded(_index)
	for k, v in pairs(self.tGotAwdList) do
		if v == _index then
			return true
		end
	end
	return false
end


-- 获取红点方法
function DataFubenPass:getRedNums()
	local nNums = 0
	for k, v in pairs(self.tConfs) do
		if self:getIsCanReward(v.nIndex) then
			nNums = 1
			break
		end
	end
	nNums = self.nLoginRedNums + nNums	
	return nNums
end

return DataFubenPass