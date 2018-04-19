-- Author: liangzhaowei
-- Date: 2017-07-05 17:00:43
-- 翻倍经验数据
local Activity = require("app.data.activity.Activity")

local DataDoubleExp = class("DataDoubleExp", function()
	return Activity.new(e_id_activity.doubleexp) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.doubleexp] = function (  )
	return DataDoubleExp.new()
end

function DataDoubleExp:ctor()
	-- body
   self:myInit()
end


function DataDoubleExp:myInit( )
 	
end

-- 读取服务器中的数据
function DataDoubleExp:refreshDatasByServer( _tData )
	-- dump(_tData,"数据",20)
	if not _tData then
	 	return
	end

	--只有公共部分

	self:refreshActService(_tData)--刷新活动共有的数据
end

-- 获取红点方法
function DataDoubleExp:getRedNums()
	local nNums = 0
	nNums = self.nLoginRedNums + nNums
	return nNums
end

return DataDoubleExp