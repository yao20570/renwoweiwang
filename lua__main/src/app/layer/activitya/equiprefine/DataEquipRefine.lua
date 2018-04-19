-- DataEquipRefine.lua
---------------------------------------------
-- Author: dshulan
-- Date: 2018-02-27 14:16
-- 装备洗炼数据
---------------------------------------------
local Activity = require("app.data.activity.Activity")
local EquipTrainActConfVo = require("app.layer.activitya.equiprefine.EquipTrainActConfVo")

local DataEquipRefine = class("DataEquipRefine", function()
	return Activity.new(e_id_activity.equiprefine) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.equiprefine] = function (  )
	return DataEquipRefine.new()
end

function DataEquipRefine:ctor()
	-- body
   self:myInit()
end


function DataEquipRefine:myInit( )
 	self.tGotAwdList           = {}   --List<Long>         已经领取的奖励阶段
 	self.tConfs           	   = {}   --List<EquipTrainActConfVo>    奖励信息
 	self.nTrainTimes           = 0 	  --已经洗炼的次数
end

-- 读取服务器中的数据
function DataEquipRefine:refreshDatasByServer( _tData )
	-- dump(_tData,"装备洗炼数据",20)
	if not _tData then
	 	return
	end
	self.tGotAwdList       		= _tData.alaw or self.tGotAwdList   --Set<Integer>      已经领取的奖励阶段
	self.nTrainTimes 			= _tData.tn or self.nTrainTimes 	--已经洗炼的次数
	
	if _tData.conf then
		for i = 1, #_tData.conf do
			local tData2 = EquipTrainActConfVo.new(_tData.conf[i])
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
function DataEquipRefine:sortAwards(_tAwd)
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
function DataEquipRefine:getIsNotReach(_target)
	-- body
	return _target > self.nTrainTimes
end

--该奖励是否可领
function DataEquipRefine:getIsCanReward(_index)
	-- body
	local tConf = nil
	for k, v in pairs(self.tConfs) do
		if v.nIndex == _index then
			tConf = v
			break
		end
	end
	if tConf == nil then
		return
	end
	if self.nTrainTimes >= tConf.nTarTimes and not self:getIsRewarded(_index) then
		return true
	else
		return false
	end
end

--该奖励是否已领取
function DataEquipRefine:getIsRewarded(_index)
	for k, v in pairs(self.tGotAwdList) do
		if v == _index then
			return true
		end
	end
	return false
end


-- 获取红点方法
function DataEquipRefine:getRedNums()
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

return DataEquipRefine