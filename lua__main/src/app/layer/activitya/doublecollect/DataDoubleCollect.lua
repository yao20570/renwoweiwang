-- Author: liangzhaowei
-- Date: 2017-07-05 14:44:03
-- 采集翻倍数据

local Activity = require("app.data.activity.Activity")

local DataDoubleCollect = class("DataDoubleCollect", function()
	return Activity.new(e_id_activity.doublecollect) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.doublecollect] = function (  )
	return DataDoubleCollect.new()
end

function DataDoubleCollect:ctor()
	-- body
   self:myInit()
end


function DataDoubleCollect:myInit( )
 	self.nX  = 1 --倍数
end

-- 读取服务器中的数据
function DataDoubleCollect:refreshDatasByServer( _tData )
	-- dump(_tData,"数据",20)
	if not _tData then
	 	return
	end
	self.nX = _tData.x or self.nX --倍数
	
	self:refreshActService(_tData)--刷新活动共有的数据
end

-- 获取红点方法
function DataDoubleCollect:getRedNums()
	local nNums = 0
	nNums = self.nLoginRedNums + nNums
	return nNums
end

return DataDoubleCollect