-- DataRechargeGift.lua
---------------------------------------------
-- Author: dshulan
-- Date: 2017-06-29 15:00:00
-- 礼包兑换数据
---------------------------------------------
local Activity = require("app.data.activity.Activity")

local DataRechargeGift = class("DataRechargeGift", function()
	return Activity.new(e_id_activity.giftrecharge) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.giftrecharge] = function (  )
	return DataRechargeGift.new()
end

function DataRechargeGift:ctor()
	-- body
   self:myInit()
end


function DataRechargeGift:myInit( )
	self.tGetAwards	   = {}   --List<Pair<Integer,Long>>	cdkey领取的奖励
 	self.sGiftName     = ""   --cdkey礼包名字
end

-- 读取服务器中的数据
function DataRechargeGift:refreshDatasByServer( _tData )
	-- dump(_tData,"礼包兑换数据 ---- ",20)
	if not _tData then
	 	return
	end
	self.tGetAwards	   = _tData.ob   or self.tGetAwards   --List<Pair<Integer,Long>>	cdkey领取的奖励
	self.sGiftName	   = _tData.n    or self.sGiftName	  --cdkey礼包名字
	

	self:refreshActService(_tData)                        --刷新活动共有的数据
end

-- 获取红点方法
function DataRechargeGift:getRedNums()
	local nNums = 0
	nNums = self.nLoginRedNums + nNums
	return nNums
end

return DataRechargeGift