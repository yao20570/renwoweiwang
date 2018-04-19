-- Author: liangzhaowei
-- Date: 2017-06-29 09:30:01
-- 乱军图纸数据

local Activity = require("app.data.activity.Activity")

local DataEnemyDrawing = class("DataEnemyDrawing", function()
	return Activity.new(e_id_activity.enemydrawing) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.enemydrawing] = function (  )
	return DataEnemyDrawing.new()
end

function DataEnemyDrawing:ctor()
	-- body
   self:myInit()
end


function DataEnemyDrawing:myInit( )
 	self.nX  = 1 --倍数
end

-- 读取服务器中的数据
function DataEnemyDrawing:refreshDatasByServer( _tData )
	-- dump(_tData,"数据",20)
	if not _tData then
	 	return
	end

	self.nX = _tData.x or self.nX --倍数
	

	self:refreshActService(_tData)--刷新活动共有的数据
end

-- 获取红点方法
function DataEnemyDrawing:getRedNums()
	local nNums = 0
	nNums = self.nLoginRedNums + nNums
	return nNums
end

return DataEnemyDrawing