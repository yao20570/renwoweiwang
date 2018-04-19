-- Author: maheng
-- Date: 2018-02-28 17:08:13
-- 攻城拔寨
local Activity = require("app.data.activity.Activity")
local ArtifactUpConfVo = require("app.layer.activitya.artifactmake.ArtifactUpConfVo")
local DataAttackVillage = class("DataAttackVillage", function()
	return Activity.new(e_id_activity.attackvillage) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.attackvillage] = function (  )
	return DataAttackVillage.new()
end

-- _index
function DataAttackVillage:ctor()
	-- body
   self:myInit()
end

function DataAttackVillage:myInit( )
 	self.tGotAwdList           = {}   --List<Long>         已经领取的奖励阶段
 	self.tConfs           	   = {}   --List<ArtifactUpConfVo>    奖励信息
 	self.tProgresses 		   = {} 	--完成活动情况
end


-- 读取服务器中的数据
function DataAttackVillage:refreshDatasByServer( _tData )
	-- dump(_tData,"数据DataAttackVillage",20)
	if not _tData then
	 	return
	end
	self.tGotAwdList       		= _tData.yaw or self.tGotAwdList   --Set<Integer> 已经领取的奖励阶段
	--配置情况
	if _tData.conf then
		for i = 1, #_tData.conf do
			local tData2 = ArtifactUpConfVo.new(_tData.conf[i])
			table.insert(self.tConfs, tData2)
		end
		--物品排序
		for i=1,#self.tConfs do
			sortGoodsList(self.tConfs[i].tAwards)
		end
	end
	if _tData.al then
		for i = 1, #_tData.al do
			local tData2 = ArtifactUpConfVo.new(_tData.al[i])
			table.insert(self.tProgresses, tData2) 				--List<ArtifactUpConfVo> 完成活动进度数据
		end
	end

	--列表排序
	self:sortAwards(self.tConfs)
	
	self:refreshActService(_tData)--刷新活动共有的数据
end
--列表排序
function DataAttackVillage:sortAwards(_tAwd)
	-- body
	if table.nums(_tAwd) == 0 then return end
	--把已领取的nTake置1,未领取为0
	for _, v in pairs(_tAwd) do
		if self:getIsRewarded(v.nIndex) then
			v.nTake = 1
		else
			v.nTake = 0
		end
		for k, data in pairs(self.tProgresses) do
			if v.nIndex == data.nIndex then
				v.nPro = data.nPro
			end
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

--该奖励是否可领
function DataAttackVillage:getIsCanReward(_index)
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
	
	if tConf.nPro >= tConf.nTargetNum and not self:getIsRewarded(_index) then
		return true
	else
		return false
	end
end

--该奖励是否已领取
function DataAttackVillage:getIsRewarded(_index)
	for k, v in pairs(self.tGotAwdList) do
		if v == _index then
			return true
		end
	end
	return false
end


-- 获取红点方法
function DataAttackVillage:getRedNums()
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

return DataAttackVillage