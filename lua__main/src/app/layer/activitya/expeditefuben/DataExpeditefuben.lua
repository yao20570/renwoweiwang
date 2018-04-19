-- Author: liangzhaowei
-- Date: 2017-06-21 15:04:12
-- 副本加速数据
local Activity = require("app.data.activity.Activity")

local DataExpeditefuben = class("DataExpeditefuben", function()
	return Activity.new(e_id_activity.expeditefuben) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.expeditefuben] = function (  )
	return DataExpeditefuben.new()
end

function DataExpeditefuben:ctor()
	-- body
   self:myInit()
end


function DataExpeditefuben:myInit( )
 	
end

-- 读取服务器中的数据
function DataExpeditefuben:refreshDatasByServer( _tData )
	-- dump(_tData,"数据",20)
	if not _tData then
	 	return
	end

	--只有公共部分

	self:refreshActService(_tData)--刷新活动共有的数据
end

-- 获取红点方法
function DataExpeditefuben:getRedNums()
	local nNums = 0
	nNums = self.nLoginRedNums + nNums
	return nNums
end

return DataExpeditefuben