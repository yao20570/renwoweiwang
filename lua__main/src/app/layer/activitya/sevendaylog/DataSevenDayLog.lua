-- DataSevenDayLog.lua
---------------------------------------------
-- Author: dshulan
-- Date: 2017-07-04 16:29:00
-- 七日登录数据
---------------------------------------------
local Activity = require("app.data.activity.Activity")

local DataSevenDayLog = class("DataSevenDayLog", function()
	return Activity.new(e_id_activity.sevendaylog) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.sevendaylog] = function (  )
	return DataSevenDayLog.new()
end

function DataSevenDayLog:ctor()
	-- body
   self:myInit()
end


function DataSevenDayLog:myInit( )
	self.tConfLogList	   = {}   --List	签到配置数据
 	self.nLogDay           = 0    --int     已签到天数
 	self.tLogedList        = {}   --List<Integer>    已领取奖励天数据
end

-- 读取服务器中的数据
function DataSevenDayLog:refreshDatasByServer( _tData )
	-- dump(_tData,"七天登录数据",20)
	if not _tData then
	 	return
	end
	self.tConfLogList	   = _tData.ss   or self.tConfLogList --List	签到配置数据
	self.nLogDay	       = _tData.d    or self.nLogDay	  --int     已签到天数
	self.tLogedList        = _tData.ts   or self.tLogedList   --List<Integer>    已领取奖励天数据
	--物品排序
	for i=1,#self.tConfLogList do
		sortGoodsList(self.tConfLogList[i].is)
	end
	--
	self:refreshActService(_tData)                        --刷新活动共有的数据


end

--获得排序
function DataSevenDayLog:resetSort()
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
function DataSevenDayLog:getNotLog(_d)
	-- body
	return _d > self.nLogDay
end

--奖励是否可领(天数)
function DataSevenDayLog:getIsCanReward(_d)
	-- body
	if _d <= self.nLogDay and not self:getIsRewarded(_d) then
		return true
	else
		return false
	end
end

--是否已签到(天数)
function DataSevenDayLog:getIsRewarded(_d)
	for k, v in pairs(self.tLogedList) do
		if v == _d then
			return true
		end
	end
	return false
end


-- 获取红点方法
function DataSevenDayLog:getRedNums()
	local nNums = 0
	--是否有奖励没领
	for i = 1, 7 do
		if self:getIsCanReward(i) then
			nNums = i
		end
	end
	nNums = self.nLoginRedNums + nNums	
	return nNums
end

return DataSevenDayLog