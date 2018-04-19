-- Author: dshulan
-- Date: 2017-11-17 17:26:36
-- 新首冲好礼数据
local Activity = require("app.data.activity.Activity")

local DataNewFirstRecharge = class("DataNewFirstRecharge", function()
	return Activity.new(e_id_activity.newfirstrecharge) 
end)
--创建自己(方便管理)
tActivityDataList[e_id_activity.newfirstrecharge] = function (  )
	return DataNewFirstRecharge.new()
end

function DataNewFirstRecharge:ctor()
    self:myInit()
end


function DataNewFirstRecharge:myInit( )
	self.nT  	=	0   --Integer	领取状态 0不可领取 1可领取 2已经领取
	self.tGs	=	{} --	List<Pair<Integer,Long>>	领取奖励天数据
end


-- 读取服务器中的数据
function DataNewFirstRecharge:refreshDatasByServer( _tData )
	-- dump(_tData, "新首充活动数据 ====")
	if not _tData then
	 	return
	end
	self.nT  	=	_tData.t	or self.nT   --Integer	领取状态 0不可领取 1可领取 2已经领取
	self.tGs	=	_tData.gs   or self.tGs --	List<Pair<Integer,Long>>	领取奖励天数据

	self:refreshActService(_tData)--刷新活动共有的数据

end

--首充奖励是否可领
function DataNewFirstRecharge:isCanGetRechargeAwa()
	-- body
	return self.nT == 1
end


-- 获取红点方法
function DataNewFirstRecharge:getRedNums()
	local nNums = 0

	-- if self.nT == 1 then
	-- 	nNums =  1
	-- end

	-- nNums = self.nLoginRedNums + nNums

	return nNums
end




return DataNewFirstRecharge