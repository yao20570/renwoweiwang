-- Author: maheng
-- Date: 2017-12-07 16:55:12
-- 王宫采集
local Activity = require("app.data.activity.Activity")

local DataPalaceCollect = class("DataPalaceCollect", function()
	return Activity.new(e_id_activity.palacecollect) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.palacecollect] = function (  )
	return DataPalaceCollect.new()
end

function DataPalaceCollect:ctor()
	-- body
   self:myInit()
end


function DataPalaceCollect:myInit( )
 	
end

-- 读取服务器中的数据
function DataPalaceCollect:refreshDatasByServer( _tData )
	--dump(_tData,"数据",20)
	if not _tData then
	 	return
	end

	--只有公共部分

	self:refreshActService(_tData)--刷新活动共有的数据
end

-- 获取红点方法
function DataPalaceCollect:getRedNums()
	local nNums = 0
	nNums = self.nLoginRedNums + nNums
	return nNums
end

return DataPalaceCollect