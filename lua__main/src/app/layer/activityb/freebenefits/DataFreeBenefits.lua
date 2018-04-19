-- Author: liangzhaowei
-- Date: 2017-08-14 11:29:20
-- 免费福利入口(创建活动只为显示入口)

local Activity = require("app.data.activity.Activity")

local DataFreeBenefits = class("DataFreeBenefits", function()
	return Activity.new(e_id_activity.freebenefits) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.freebenefits] = function (  )
	return DataFreeBenefits.new()
end

function DataFreeBenefits:ctor()
	-- body
   self:myInit()
end


function DataFreeBenefits:myInit( )
 	
end

-- 读取服务器中的数据
function DataFreeBenefits:refreshDatasByServer( _tData )
	-- dump(_tData,"数据",20)
	if not _tData then
	 	return
	end

	--只有公共部分

	self:refreshActService(_tData)--刷新活动共有的数据
end

-- 获取红点方法
function DataFreeBenefits:getRedNums()
	local nNums = 0
	-- nNums = self.nLoginRedNums + nNums
	return nNums
end

return DataFreeBenefits