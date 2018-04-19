-- Author: wenzongyao
-- Date: 2018-01-20 11:23:56
-- 每日抢答入口(创建活动只为显示入口)
local Activity = require("app.data.activity.Activity")

local DataExamActivity = class("DataExamActivity", function()
	return Activity.new(e_id_activity.exam) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.exam] = function (  )
	return DataExamActivity.new()
end

function DataExamActivity:ctor()
	-- body
   self:myInit()
end


function DataExamActivity:myInit( )
 	
end

-- 读取服务器中的数据
function DataExamActivity:refreshDatasByServer( _tData )
	-- dump(_tData,"数据",20)
	if not _tData then
	 	return
	end

	--只有公共部分

	self:refreshActService(_tData)--刷新活动共有的数据
end

-- 获取红点方法
function DataExamActivity:getRedNums()
    local nums = 0

    if Player:getExamData():isReadyStart() then
        nums = 1
    end

    if Player:getExamData():isCanGetRankReward() then
        nums = 1
    end

    return nums
end

return DataExamActivity