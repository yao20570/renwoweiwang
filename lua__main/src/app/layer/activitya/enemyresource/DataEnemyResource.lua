-- Author: liangzhaowei
-- Date: 2017-06-29 11:30:54
-- 乱军资源数据

local Activity = require("app.data.activity.Activity")

local DataEnemyResource = class("DataEnemyResource", function()
	return Activity.new(e_id_activity.enemyresource) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.enemyresource] = function (  )
	return DataEnemyResource.new()
end

function DataEnemyResource:ctor()
	-- body
   self:myInit()
end


function DataEnemyResource:myInit( )
	self.nX = 1 --翻倍倍数
end

-- 读取服务器中的数据
function DataEnemyResource:refreshDatasByServer( _tData )
	-- dump(_tData,"数据",20)
	if not _tData then
	 	return
	end

	self.nX = _tData.x or self.nX --翻倍倍数
	

	self:refreshActService(_tData)--刷新活动共有的数据
end

-- 获取红点方法
function DataEnemyResource:getRedNums()
	local nNums = 0
	nNums = self.nLoginRedNums + nNums
	return nNums
end

return DataEnemyResource