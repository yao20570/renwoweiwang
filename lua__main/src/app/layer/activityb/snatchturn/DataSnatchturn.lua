----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-08-05 11:25:11
-- Description: 夺宝转盘数据
-----------------------------------------------------
local Activity = require("app.data.activity.Activity")

local DataSnatchturn = class("DataSnatchturn", function()
	return Activity.new(e_id_activity.snatchturn) 
end)
--创建自己(方便管理)
tActivityDataList[e_id_activity.snatchturn] = function (  )
	return DataSnatchturn.new()
end

function DataSnatchturn:ctor()
   self:myInit()
end


function DataSnatchturn:myInit( )

end


-- 读取服务器中的数据
function DataSnatchturn:refreshDatasByServer( _tData )
	if not _tData then
	 	return
	end

	if _tData.tco then
		if self.tTurnConfVo then
			self.tTurnConfVo:update(_tData.tco)
		else
			local TurnConfVo = require("app.layer.activityb.snatchturn.TurnConfVo")
			self.tTurnConfVo = TurnConfVo.new(_tData.tco) --转盘配置
		end
	end

	if _tData.ino then
		if self.tSnatchTurnInfoVo then
			self.tSnatchTurnInfoVo:update(_tData.ino)
		else
			local SnatchTurnInfoVo = require("app.layer.activityb.snatchturn.SnatchTurnInfoVo")
			self.tSnatchTurnInfoVo = SnatchTurnInfoVo.new(_tData.ino)--	SnatchTurnInfoVo	转盘保存数据
		end
	end

	

	self:refreshActService(_tData)--刷新活动共有的数据
end


-- 获取红点方法
function DataSnatchturn:getRedNums()
	local nNums = 0
	local tData = Player:getActById(e_id_activity.snatchturn)
	if tData then
		if tData.tTurnConfVo then
			local bIsFree = false
			if tData.tSnatchTurnInfoVo then
				nNums = math.max(tData.tTurnConfVo:getFreeNumMax() - tData.tSnatchTurnInfoVo.nFreeUsed, 0)
			end
		end
	end

	return nNums
end




return DataSnatchturn