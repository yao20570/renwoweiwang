-- Author: liangzhaowei
-- Date: 2017-06-29 10:26:24
-- 工坊加速数据

local Activity = require("app.data.activity.Activity")

local DataExpediteWorkshop = class("DataExpediteWorkshop", function()
	return Activity.new(e_id_activity.expediteworkshop) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.expediteworkshop] = function (  )
	return DataExpediteWorkshop.new()
end

function DataExpediteWorkshop:ctor()
	-- body
   self:myInit()
end


function DataExpediteWorkshop:myInit( )
	self.nSp = 0 ----工坊加速速率(小数)
end

-- 读取服务器中的数据
function DataExpediteWorkshop:refreshDatasByServer( _tData )
	-- dump(_tData,"数据",20)
	if not _tData then
	 	return
	end

	self.nSp =  _tData.sp or self.nSp --工坊加速速率(小数)


	self:refreshActService(_tData)--刷新活动共有的数据
end

-- 获取红点方法
function DataExpediteWorkshop:getRedNums()
	local nNums = 0
	nNums = self.nLoginRedNums + nNums	
	return nNums
end

return DataExpediteWorkshop