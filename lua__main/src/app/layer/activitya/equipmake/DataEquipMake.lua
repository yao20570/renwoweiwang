-- DataEquipMake.lua
---------------------------------------------
-- Author: xiesite
-- Date: 2018-02-24 10:36:00
-- 装备打造
---------------------------------------------
local Activity = require("app.data.activity.Activity")

local DataEquipMake = class("DataEquipMake", function()
	return Activity.new(e_id_activity.equipmake) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.equipmake] = function (  )
	return DataEquipMake.new()
end

function DataEquipMake:ctor()
	-- body
   self:myInit()
end


function DataEquipMake:myInit( )
	self.tConfLogList	   = {}   --List	活动配置情况
 	self.tOB               = {}   --set     奖励物品
 	self.tYaw		       = {}   --List	已经获得的奖励
 	self.tAl 	 		   = {}   --List	玩家完成活动情况
end

-- 读取服务器中的数据
function DataEquipMake:refreshDatasByServer( _tData )
	if not _tData then
	 	return
	end
	-- dump(_tData,"装备打造",100)
	self.tConfLogList	   = _tData.conf    or self.tConfLogList  --List	签到配置数据
	self.tYaw		       = _tData.yaw   	or self.tYaw          --List 	已经获得的奖励			
	self.tAl		       = _tData.al   	or self.tAl          --List 	玩家完成活动情况

	--物品排序
	for i=1,#self.tConfLogList do
		sortGoodsList(self.tConfLogList[i].aw)
	end
	--
	self:refreshActService(_tData)                        --刷新活动共有的数据
end

--该奖励是否已领取
function DataEquipMake:getIsRewarded(_id)
	for k, v in pairs(self.tYaw) do
		if v == _id then
			return true
		end
	end
	return false
end

--是否可领取
function DataEquipMake:getIsCanReward(_id)
	if self:getIsRewarded(_id) then
		return false
	end
	local nAlEn = self:getAlEn(_id)
	local nConfEn = self:getConfEn(_id)
	if nAlEn >= nConfEn then
		return true
	end
 	return false
end

--没达到
function DataEquipMake:getNotLog(_id)
	local nAlEn = self:getAlEn(_id)
	local nConfEn = self:getConfEn(_id)
	if nAlEn < nConfEn then
		return true
	end
 	return false
end

--获得排序
function DataEquipMake:resetSort()
 	if not self.tConfLogList then
       return
	end
	for k,v in pairs(self.tConfLogList) do
		local nSort = 0
		if self:getIsRewarded(v.ci) == true then
		 	nSort = 1
		end
		if self:getIsCanReward(v.ci) == true then
		 	nSort = 3
		end
		if self:getNotLog(v.ci) == true then
		 	nSort = 2
		end 
		v.nSort = nSort
	end

	table.sort(self.tConfLogList,function (a,b)
		if a.nSort == b.nSort then
			return a.ci < b.ci
		else
			return a.nSort > b.nSort
		end
	end)
end

--获得完成情况的件数
function DataEquipMake:getAlEn(_id)
	if self.tAl then
		for k, v in pairs(self.tAl) do
			if _id == v.ci then
				return v.en
			end
		end
	end
	return 0
end

--获得完成情况的件数
function DataEquipMake:getConfEn(_id)
	if self.tConfLogList then
		for k, v in pairs(self.tConfLogList) do
			if _id == v.ci then
				return v.en
			end
		end
	end
	return 0
end
 
--获取完成情况的描述
function DataEquipMake:getAlText(_id)
	local tConTable = {}
	--文本
	local tLabel = {
		{self:getAlEn(_id).."",getC3B(_cc.green)},
		{"/"..self:getConfEn(_id),getC3B(_cc.pwhite)},
	}
	tConTable.tLabel = tLabel
	return tConTable
end

--获取红点方法
function DataEquipMake:getRedNums()
	local nNums = 0
	for i=1, #self.tConfLogList do
		if self:getIsCanReward(self.tConfLogList[i].ci) then
			nNums = 1
			break
		end
	end
	nNums = self.nLoginRedNums + nNums
 	return nNums
end

return DataEquipMake