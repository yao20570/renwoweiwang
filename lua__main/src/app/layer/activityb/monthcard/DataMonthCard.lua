-- DataMonthCard.lua
---------------------------------------------
-- Author: dshulan
-- Date: 2018-01-27 16:08:00
-- 只是个月卡入口而已, 没有其他数据
---------------------------------------------

local Activity = require("app.data.activity.Activity")

local DataMonthCard = class("DataMonthCard", function()
	return Activity.new(e_id_activity.mothcard) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.mothcard] = function (  )
	return DataMonthCard.new()
end

-- _index
function DataMonthCard:ctor()
	-- body
   self:myInit()
end


function DataMonthCard:myInit( )
	
end


-- 读取服务器中的数据
function DataMonthCard:refreshDatasByServer( _tData )
	self:refreshActService(_tData)--刷新活动共有的数据
end


-- 获取红点方法
function DataMonthCard:getRedNums()
	local nNums = 0
	nNums = self.nLoginRedNums + nNums

	return nNums
end




return DataMonthCard