-- DataDoubleEgg.lua
---------------------------------------------
-- Author: xiesite
-- Date: 2017-12-11 11:22:00
-- 双旦活动
---------------------------------------------
local Activity = require("app.data.activity.Activity")

local DataDoubleEgg = class("DataDoubleEgg", function()
	return Activity.new(e_id_activity.doubleegg) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.doubleegg] = function (  )
	return DataDoubleEgg.new()
end

function DataDoubleEgg:ctor()
	-- body
   self:myInit()
end


function DataDoubleEgg:myInit( )
	self.tConfLogList	   = {}   --List	签到配置数据
 	self.nLogDay           = 0    --int     已签到天数
 	self.nSign		       = 0    --int     当天是否已经签到
end

-- 读取服务器中的数据
function DataDoubleEgg:refreshDatasByServer( _tData )
	-- dump(_tData,"双旦活动",20)
	if not _tData then
	 	return
	end
	self.tConfLogList	   = _tData.ss   or self.tConfLogList --List	签到配置数据
	self.nLogDay	       = _tData.d    or self.nLogDay	  --int     已签到天数
	self.nSign		       = _tData.s   or self.nSign   --int 当天是否已经签到 0:否 1:是

	--物品排序
	for i=1,#self.tConfLogList do
		sortGoodsList(self.tConfLogList[i].is)
	end
	--
	self:refreshActService(_tData)                        --刷新活动共有的数据
end

--该奖励是否已领取
function DataDoubleEgg:getIsRewarded(_d)
	if _d <= self.nLogDay then
 		return true
 	else
 		return false
	end
end

--是否可领取
function DataDoubleEgg:getIsCanReward(_d)
	if self.nSign == 0 then
		return self.nLogDay + 1 == _d
	end
end

--没达到
function DataDoubleEgg:getNotLog(_d)
	if self.nSign == 0 then
		if _d > self.nLogDay + 1 then
 			return true
 		else
 			return false
		end
	else
		if _d > self.nLogDay then
 			return true
		else
			return false
		end
	end
end

--获得排序
function DataDoubleEgg:resetSort()
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

 

-- 获取红点方法
function DataDoubleEgg:getRedNums()
	local nNums = 0
	if self.nSign == 0 then
		nNums = 1
	end
 	return nNums
end

return DataDoubleEgg