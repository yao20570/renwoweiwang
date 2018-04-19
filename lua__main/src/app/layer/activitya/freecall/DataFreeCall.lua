-- Author: maheng
-- Date: 2017-12-05 16:55:24
-- 免费召唤

local Activity = require("app.data.activity.Activity")

local DataFreeCall = class("DataFreeCall", function()
	return Activity.new(e_id_activity.freecall) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.freecall] = function (  )
	return DataFreeCall.new()
end

function DataFreeCall:ctor()
	-- body
   self:myInit()
end


function DataFreeCall:myInit( )
 	self.nTct  = 0 --免费召唤总次数
 	self.nFct  = 0 --已经使用的免费召唤次数
end

-- 读取服务器中的数据
function DataFreeCall:refreshDatasByServer( _tData )
	--dump(_tData,"DataFreeCall免费召唤",20)
	if not _tData then
	 	return
	end
 	self.nTct  = _tData.tct or self.nTct
 	self.nFct  = _tData.fct or self.nFct
	

	self:refreshActService(_tData)--刷新活动共有的数据
	sendMsg(ghd_refresh_actfreecall_msg)
end

function DataFreeCall:getActFreeCallTimes(  )
	-- body
	return self.nTct - self.nFct  
end

-- 获取红点方法
function DataFreeCall:getRedNums()
	local nNums = 0
	nNums = self.nLoginRedNums + nNums
	return nNums
end

return DataFreeCall