--
-- Author: dengshulan
-- Date: 2018-1-19 16:48:31
--特惠礼包(送审)数据结构
local Activity = require("app.data.activity.Activity")
local ShowPacketVO = require("app.layer.activitya.packetgift.ShowPacketVO")

local DataPacketShowRes = class("DataPacketShowRes", function()
	return Activity.new(e_id_activity.packetgift) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.packetgift] = function (  )
	return DataPacketShowRes.new()
end

function DataPacketShowRes:ctor()
	-- body
   self:myInit()
end


function DataPacketShowRes:myInit( )
 	self.tBuys           		= {}   --List<Long>         已经领取的奖励阶段
 	self.tAllPackets            = {}   --List<ShowPacketVO> 奖励配置信息
 	self.nRechargeNum           = 0    --Long               累计消费金币数
end

-- 读取服务器中的数据
function DataPacketShowRes:refreshDatasByServer( _tData )
	-- dump(_tData, "特惠礼包数据 ===", 100)
	if not _tData then
	 	return
	end
	self.tBuys 			= _tData.buys or self.tBuys 	    --已购买商品索引集合
	if _tData.ps then
		for i = 1, #_tData.ps do
			local tData2 = ShowPacketVO.new(_tData.ps[i])
			tData2.sPackName = self:getPacketName(tData2.nIndex)
			tData2.bIsTake = false
			for _, index  in pairs(self.tBuys) do
				if tData2.nIndex == index then
					tData2.bIsTake = true -- 该商品已购买
					break
				end
			end
			table.insert(self.tAllPackets, tData2)
		end
		table.sort(self.tAllPackets, function(a, b)
			-- body
			return a.nIndex < b.nIndex
		end)
	else
		for i, vo in pairs(self.tAllPackets) do
			for _, index  in pairs(self.tBuys) do
				if vo.nIndex == index then
					vo.bIsTake = true -- 该商品已购买
					break
				end
			end
		end
	end

	self:refreshActService(_tData)                        --刷新活动共有的数据
end

--_index: 索引
function DataPacketShowRes:getPacketName(_index)
	-- body
	local sName = ""
	local tPa = luaSplitMuilt2(self.tParam, "#", ",")
	for k, v in pairs(tPa) do
		if tonumber(v[1]) == _index then
			sName = v[3]
			return sName
		end
	end
end

--是否全部已购买
function DataPacketShowRes:getIsBoughtAll()
	-- body
	local nBuyNum = table.nums(self.tBuys)
	local nConfNum = table.nums(self.tAllPackets)
	if nBuyNum >= nConfNum then
		return true
	end
	return false
end


-- 获取红点方法
function DataPacketShowRes:getRedNums()
	local nNums = 0
	
	nNums = self.nLoginRedNums + nNums	
	return nNums
end

return DataPacketShowRes