-- DataWelcomeBack.lua
---------------------------------------------
-- Author: dshulan
-- Date: 2018-04-12 17:39:00
-- 王者归来数据
---------------------------------------------

local Activity = require("app.data.activity.Activity")
local KingReturnConfVo = require("app.layer.activityb.welcomeback.KingReturnConfVo")

e_get_state = 
{
	canget 			= 1, 		--可领
	cannotget 		= 2, 		--不可领
	havegot 		= 3 		--已领
}

local DataWelcomeBack = class("DataWelcomeBack", function()
	return Activity.new(e_id_activity.welcomeback) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.welcomeback] = function (  )
	return DataWelcomeBack.new()
end

-- _index
function DataWelcomeBack:ctor()
	-- body
   self:myInit()
end


function DataWelcomeBack:myInit( )
	self.tConf = {} 			--配置
	self.tTaskReach = {} 		--任务完成情况
	self.tGotList = {} 			--已领取列表
end

-- 读取服务器中的数据
function DataWelcomeBack:refreshDatasByServer( _tData )
	-- dump(_tData,"王者归来数据", 20)
	if not _tData then
	 	return
	end
	--配置
	if _tData.conf then
		for k, v in pairs(_tData.conf) do
			if self.tConf[v.day] then
				self.tConf[v.day]:update(v)
			else
				self.tConf[v.day] = KingReturnConfVo.new(v, self.tSubtitle)
			end
		end
	end
	self.tTaskReach 	 = _tData.fi    or self.tTaskReach    --List<Pair<Integer,Long>> 任务完成情况
	self.tGotList    	 = _tData.yaw    or self.tGotList     --Set<Integer>已完成任务并领取了奖励天数列表

	--检查任务完成情况和奖励领取情况
	if _tData.yaw and table.nums(_tData.yaw) or _tData.fi then
		for _, v in pairs(self.tConf) do
			for _, day in pairs(self.tGotList) do
				if day == v.nDay then
					v.nGot = e_get_state.havegot --已领
				end
			end
			for _, data in pairs(self.tTaskReach) do
				if data.k == v.nDay then
					--如果任务已完成并还没领取奖励
					if data.v >= v.nNum and v.nGot ~= e_get_state.havegot then
						v.nGot = e_get_state.canget --可领
					end
				end
			end
		end
	end

	--排序
	self:sortConf()
 
	self:refreshActService(_tData)--刷新活动共有的数据
end

--排序，已领取的置后
function DataWelcomeBack:sortConf()
	table.sort(self.tConf, function(a, b)
		if a.nGot == b.nGot then
			return a.nDay < b.nDay
		else
			return a.nGot < b.nGot
		end
	end)
	--物品排序
	for i=1,#self.tConf do
		sortGoodsList(self.tConf[i].tAwards)
	end
end

--是否已领
function DataWelcomeBack:checkIsGot(_day)
	return self.tConf[_day].nGot == e_get_state.havegot
end

--是否有奖励可领
function DataWelcomeBack:checkIsCanGet()
	for k, v in pairs(self.tConf) do
		if v.nGot == e_get_state.canget then
			return true
		end
	end
	return false
end

-- 获取红点方法
function DataWelcomeBack:getRedNums()
	local nNums = 0
	if self:checkIsCanGet() then
		nNums = nNums + 1
	end
	nNums = self.nLoginRedNums + nNums
	
	return nNums
end




return DataWelcomeBack