-- DataOnlineWelfare.lua
---------------------------------------------
-- Author: xiesite
-- Date: 2017-12-20 20:22:00
-- 在线福利
---------------------------------------------
local Activity = require("app.data.activity.Activity")

local DataOnlineWelfare = class("DataOnlineWelfare", function()
	return Activity.new(e_id_activity.onlinewelfare) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.onlinewelfare] = function (  )
	return DataOnlineWelfare.new()
end

function DataOnlineWelfare:ctor()
	-- body
   self:myInit()
end


function DataOnlineWelfare:myInit( )
	self.tConfLogList	   = {}   --List	签到配置数据
 	self.nTake             = 0    --set     已经领取的
 	self.nOt		       = 0    --long	已经在线的时间
 	self.nStartST 		   = getSystemTime()    --long	用于计算倒计时
end

-- 读取服务器中的数据
function DataOnlineWelfare:refreshDatasByServer( _tData )
	if not _tData then
	 	return
	end
	-- dump(_tData,"在线福利",100)
	self.tConfLogList	   = _tData.conf    or self.tConfLogList --List	签到配置数据
	self.nTake	       	   = _tData.take    or self.nTake	  --set     已经领取的
	self.nOt		       = _tData.ot   	or self.nOt   --long 已经在线的时间			

	--物品排序
	for i=1,#self.tConfLogList do
		sortGoodsList(self.tConfLogList[i])
	end
	--
	self:refreshActService(_tData)                        --刷新活动共有的数据
end

--该奖励是否已领取
function DataOnlineWelfare:getIsRewarded(_s)
	for k, v in pairs(self.nTake) do
		if _s == v then
			return true
		end
	end
	return false
end

--是否可领取
function DataOnlineWelfare:getIsCanReward(_s)
	local nTime = self.nOt+(getSystemTime()-self.nStartST)
	if self:getIsRewarded(_s) then
		return false
	end
	if nTime >= _s then
		return true
	else
		return false
	end
end

--没达到
function DataOnlineWelfare:getNotLog(_s)
	local nTime = self.nOt+(getSystemTime()-self.nStartST)
	if nTime >= _s then
		return false
	else
		return true
	end
end

--获得排序
function DataOnlineWelfare:resetSort()
	if not self.tConfLogList then
       return
	end

	for k,v in pairs(self.tConfLogList) do
		local nSort = 0
		if self:getIsRewarded(v.seconds) == true then
		 	nSort = 1
		end 
		v.nSort = nSort
	end

	table.sort(self.tConfLogList,function (a,b)
		if a.nSort == b.nSort then
			return a.seconds < b.seconds
		else
			return a.nSort < b.nSort
		end
	end)

end

--是否显示CD
function DataOnlineWelfare:isShowCD(_s)
	--只有未达到的第一个才会显示
	local nSec = nil
	for i=1, #self.tConfLogList do
		if self:getNotLog(self.tConfLogList[i].seconds) then
			nSec = self.tConfLogList[i].seconds
			break
		end
	end

	if not nSec then
		return false
	elseif nSec == _s then
		return true
	else
		return false
	end
end
 

-- 获取红点方法
function DataOnlineWelfare:getRedNums()
	local nNums = 0
	for i=1, #self.tConfLogList do
		if self:getIsCanReward(self.tConfLogList[i].seconds) then
			nNums = 1
			break
		end
	end
 	return nNums
end

return DataOnlineWelfare