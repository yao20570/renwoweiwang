--
-- Author: tanqian
-- Date: 2017-09-09 14:42:02
--活动每日手收贡数据体
local Activity = require("app.data.activity.Activity")
local DataDayLoginAward = class("DataDayLoginAward", function()
	return Activity.new(e_id_activity.dayloginaward) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.dayloginaward] = function (  )
	return DataDayLoginAward.new()
end


function DataDayLoginAward:ctor()
	-- body
   self:myInit()
end


function DataDayLoginAward:myInit( )
 	self.tAllAwdInfo           = {}   --List<AwardInfo>    奖励配置信息
 	self.nRecevAward           = 0    --Long               今日奖励是否领取，0是没有领取，1是已经领取
 	self.nLastReloadTime 	   = 0    --Long 				上一次加载数据的时间       
 	self.nRefreshGetTime 		   = 0 	  --Long 				奖励领取刷新时间
end

-- 读取服务器中的数据
function DataDayLoginAward:refreshDatasByServer( _tData )
	if not _tData then
	 	return
	end
	self:refreshActService(_tData)                        --刷新活动共有的数据
	self.nRecevAward           = _tData.rece or self.nRecevAward    
	self.tAllAwdInfo           = _tData.show or self.tAllAwdInfo  
	self.nLastReloadTime 	   = getSystemTime(true) 
	self.nRefreshGetTime 	   = _tData.t or self.nRefreshGetTime



end



--通过玩家等级获取奖励
function DataDayLoginAward:getAwdInfoByLv(_nLv)
	if not _nLv then
		return 
	end
	for k, v in pairs(self.tAllAwdInfo) do
		
		if v and  (_nLv >= v.lv[1] and _nLv <= v.lv[2]) then
			return v.info
		end
	end
end

--获取第二天奖励倒计时
function DataDayLoginAward:getLeftTime()
	
	local nNowTime = getSystemTime(true)
	-- self.nRefreshGetTime = 60000
	local nTime  = (self.nRefreshGetTime / 1000) - (nNowTime-self.nLastReloadTime)
	if nTime <= 0 then
	    nTime = 0
	end
	return nTime 
end


-- 获取红点方法
function DataDayLoginAward:getRedNums()
	local nNums = 0
	if self.nRecevAward == 0  then
		nNums = nNums + 1
	end
	nNums = self.nLoginRedNums + nNums	
	return nNums
end

return DataDayLoginAward