-- Author: liangzhaowei
-- Date: 2017-07-05 18:23:01
-- 乱军迁城数据

local Activity = require("app.data.activity.Activity")

local DataEnemyRemoval = class("DataEnemyRemoval", function()
	return Activity.new(e_id_activity.enemyremoval) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.enemyremoval] = function (  )
	return DataEnemyRemoval.new()
end

function DataEnemyRemoval:ctor()
	-- body
   self:myInit()
end


function DataEnemyRemoval:myInit( )
 	self.nX  = 1 --倍数
end

-- 读取服务器中的数据
function DataEnemyRemoval:refreshDatasByServer( _tData )
	-- dump(_tData,"数据",20)
	if not _tData then
	 	return
	end

	self.nX = _tData.x or self.nX --倍数

	self:refreshActService(_tData)--刷新活动共有的数据
end

-- 获取红点方法
function DataEnemyRemoval:getRedNums()
	local nNums = 0
	nNums = self.nLoginRedNums + nNums
	return nNums
end

return DataEnemyRemoval