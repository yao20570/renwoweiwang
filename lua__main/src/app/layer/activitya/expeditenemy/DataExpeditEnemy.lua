-- Author: liangzhaowei
-- Date: 2017-07-05 13:58:43
-- 乱军加速数据

local Activity = require("app.data.activity.Activity")

local DataExpeditEnemy = class("DataExpeditEnemy", function()
	return Activity.new(e_id_activity.expeditenemy) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.expeditenemy] = function (  )
	return DataExpeditEnemy.new()
end

function DataExpeditEnemy:ctor()
	-- body
   self:myInit()
end


function DataExpeditEnemy:myInit( )
	self.tOb	=  {}     --乱军加速物品生效
end

-- 读取服务器中的数据
function DataExpeditEnemy:refreshDatasByServer( _tData )
	if not _tData then
	 	return
	end

	self.tOb	=  _tData.ob or self.tOb	     --乱军加速物品生效
	--提示获得乱军加速物品
	-- if _tData.ob and table.nums(_tData.ob)> 0 then
	-- 	--发送消息更新冒泡
	-- 	-- sendMsg(gud_refresh_build_bubble)
	-- 	for k,v in pairs(_tData.ob) do
	-- 		if v.k and v.v > 0 then
	-- 			local pGoods = getGoodsByTidFromDB(v.k)
	-- 			-- if pGoods and pGoods.sName then
	-- 				-- TOAST(pGoods.sName)
	-- 			-- end
				
	-- 			if pGoods and pGoods.nEffectType == e_speed_effect_type.build_speed then
	-- 				NLASTSHOWSPEEDCELLIDX = nil
	-- 			end
	-- 		end
	-- 	end
	-- end
	self:refreshActService(_tData)--刷新活动共有的数据
end

--获取乱军加速获得的道具buff
function DataExpeditEnemy:getExpeditEnemySpeedBuff()
	-- body
	return self.tOb
end

-- 获取红点方法
function DataExpeditEnemy:getRedNums()
	local nNums = 0
	nNums = self.nLoginRedNums + nNums
	return nNums
end

return DataExpeditEnemy