-- DataRegress.lua
---------------------------------------------
-- Author: xiesite
-- Date: 2018-04-09 14:55:00
-- 回归有礼
---------------------------------------------
local Activity = require("app.data.activity.Activity")

local DataRegress = class("DataRegress", function()
	return Activity.new(e_id_activity.regress) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.regress] = function (  )
	return DataRegress.new()
end

function DataRegress:ctor()
    -- body
	self:myInit()
end


function DataRegress:myInit( )
	self.tConfLogList = {}		--签到配置数据
	self.nDay = 0 			-- 签到天数据
	self.tGetList = {} 		-- 领取奖励天数据
end

-- 读取服务器中的数据
function DataRegress:refreshDatasByServer( _tData )
	-- dump(_tData,"七天登录数据",20)
	if not _tData then
	 	return
	end
	
	self.tConfLogList = _tData.ss or self.tConfLogList
	self.nDay = _tData.d or self.nDay
	self.tGetList = _tData.ts or self.tGetList
	--

	self:refreshActService(_tData)                        --刷新活动共有的数据
end

--获得排序
function DataRegress:resetSort()
	if not self.tConfLogList then
       return
	end

	for k,v in pairs(self.tConfLogList) do
		local nSort = 0
		if self:getIsRewarded(v.d) == true then
		 	nSort = 1
		end 
		v.nSort = nSort
	end

	table.sort(self.tConfLogList,function (a,b)
		if a.nSort == b.nSort then
			return a.d < b.d
		else
			return a.nSort < b.nSort
		end
	end)
end

--未达到
function DataRegress:getNotLog(_d)
	if not _d then
		return false
	end
	return _d > self.nDay
end

--奖励是否可领(天数)
function DataRegress:getIsCanReward(_d)
	if self:getNotLog(_d) then
		return false
	end
	-- body
	for i=1, #self.tGetList do
		if self.tGetList[i] == _d then
			return false
		end
	end
	return true
end

--是否已签到(天数)
function DataRegress:getIsRewarded(_d)
 	if not self:getNotLog(_d) then
		for i=1, #self.tGetList do
			if self.tGetList[i] == _d then
				return true
			end
		end
	end
	return false
end


-- 获取红点方法
function DataRegress:getRedNums()
	local nNums = 0
	--是否有奖励没领
	for i = 1, self.nDay do
		if self:getIsCanReward(i) then
			nNums = i
			break
		end
	end
	nNums = self.nLoginRedNums + nNums
	return nNums
end

return DataRegress