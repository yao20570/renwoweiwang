----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-3-8 11:53:00
-- Description:  限时Boss

-----------------------------------------------------
local Activity = require("app.data.activity.Activity")
local DataTLBoss = class("DataTLBoss", function()
	return Activity.new(e_id_activity.tlboss) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.tlboss] = function (  )
	return DataTLBoss.new()
end

-- _index
function DataTLBoss:ctor()
   self:myInit()
end


function DataTLBoss:myInit( )

end


-- 读取服务器中的数据
function DataTLBoss:refreshDatasByServer( _tData )
	if not _tData then
	 	return
	end
	self:refreshActService(_tData)--刷新活动共有的数据
end

-- 获取红点方法
function DataTLBoss:getRedNums()
	local nState = Player:getTLBossData():getTk()
	local nState2 = Player:getTLBossData():getTf()
	local nState3 = Player:getTLBossData():getTh()
	if nState == e_tlboss_award.get or nState2 == e_tlboss_award.get or nState3 == e_tlboss_award.get then
		return 1
	end
	return 0
end

return DataTLBoss