-- DataPlayerLvUp.lua
---------------------------------------------
-- Author: dshulan
-- Date: 2018-02-26 16:54
-- 主公升级数据
---------------------------------------------
local Activity = require("app.data.activity.Activity")
local AvatarLevelUpConfVo = require("app.layer.activitya.playerlvup.AvatarLevelUpConfVo")

local DataPlayerLvUp = class("DataPlayerLvUp", function()
	return Activity.new(e_id_activity.playerlvup) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.playerlvup] = function (  )
	return DataPlayerLvUp.new()
end

function DataPlayerLvUp:ctor()
	-- body
   self:myInit()
end


function DataPlayerLvUp:myInit( )
 	self.tGotAwdList           = {}   --List<Long>         已经领取的奖励阶段
 	self.tConfs           	   = {}   --List<AvatarLevelUpConfVo>    奖励信息
 	self.nPlayerLv         	   = Player:getPlayerInfo().nLv
end

-- 读取服务器中的数据
function DataPlayerLvUp:refreshDatasByServer( _tData )
	-- dump(_tData,"主公升级数据",20)
	if not _tData then
	 	return
	end
	self.tGotAwdList       		= _tData.yaw or self.tGotAwdList   --Set<Integer>      已经领取的奖励阶段
	self.nPlayerLv         		= _tData.alv or self.nPlayerLv    --主公等级
	
	if _tData.conf then
		for i = 1, #_tData.conf do
			local tData2 = AvatarLevelUpConfVo.new(_tData.conf[i])
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
function DataPlayerLvUp:sortAwards(_tAwd)
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
function DataPlayerLvUp:getIsNotReach(_targetLv)
	-- body
	return _targetLv > Player:getPlayerInfo().nLv
end

--该奖励是否可领
function DataPlayerLvUp:getIsCanReward(_index)
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
	local nPlayerLv = Player:getPlayerInfo().nLv
	if nPlayerLv >= tConfs.nTarget and not self:getIsRewarded(_index) then
		return true
	else
		return false
	end
end

--该奖励是否已领取
function DataPlayerLvUp:getIsRewarded(_index)
	for k, v in pairs(self.tGotAwdList) do
		if v == _index then
			return true
		end
	end
	return false
end


-- 获取红点方法
function DataPlayerLvUp:getRedNums()
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

return DataPlayerLvUp