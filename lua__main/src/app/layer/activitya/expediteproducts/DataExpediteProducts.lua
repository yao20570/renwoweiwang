-- Author: liangzhaowei
-- Date: 2017-07-05 17:20:57
-- 物产加速数据

local Activity = require("app.data.activity.Activity")

local DataExpediteProducts = class("DataExpediteProducts", function()
	return Activity.new(e_id_activity.expediteproducts) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.expediteproducts] = function (  )
	return DataExpediteProducts.new()
end

function DataExpediteProducts:ctor()
	-- body
   self:myInit()
end


function DataExpediteProducts:myInit( )
 	self.nSp  = 1 --物产加速减少百分比
end

-- 读取服务器中的数据
function DataExpediteProducts:refreshDatasByServer( _tData )
	-- dump(_tData,"数据",20)
	if not _tData then
	 	return
	end

	self.nSp = _tData.sp or self.nSp --物产加速减少百分比
	

	self:refreshActService(_tData)--刷新活动共有的数据
end

-- 获取红点方法
function DataExpediteProducts:getRedNums()
	local nNums = 0
	nNums = self.nLoginRedNums + nNums
	return nNums
end

return DataExpediteProducts