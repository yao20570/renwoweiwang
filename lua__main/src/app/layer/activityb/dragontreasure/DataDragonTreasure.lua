----------------------------------------------------- 
-- author: dengshulan
-- updatetime: 2017-12-07 16:54:54
-- Description: 寻龙夺宝数据
-----------------------------------------------------
local Activity = require("app.data.activity.Activity")

local DataDragonTreasure = class("DataDragonTreasure", function()
	return Activity.new(e_id_activity.dragontreasure) 
end)
--创建自己(方便管理)
tActivityDataList[e_id_activity.dragontreasure] = function (  )
	return DataDragonTreasure.new()
end

function DataDragonTreasure:ctor()
   self:myInit()
end


function DataDragonTreasure:myInit( )
	self.nCostItemCnt = 0 			--寻龙盘个数
	self.tOb = nil 					--抽奖得到的物品
	self.tTob = nil 				--达到目标次数得到的物品
	self.nGetTimes = 0 				--抽了多少次
	self.nDc = 0 					--今日掉落次数
	self.nTdc = 0 					--总掉落次数
	self.nCostItemId = nil 			--抽奖消耗的物品id
	self.tCost = nil 				--购买抽奖物品需要的物品
	self.nOneC = 0 					--抽一次的消耗
	self.nTenC = 0 					--抽十次的消耗
	self.tTinfo = nil 				--目标达到可以换的物品
	self.tTurnConfVo = nil 			--转盘配置
	self.tGrids = nil 				--转到哪些格子
end


-- 读取服务器中的数据
function DataDragonTreasure:refreshDatasByServer( _tData )
	-- dump(_tData, "寻龙夺宝数据 ===")
	if not _tData then
	 	return
	end
	--转盘配置
	if _tData.conf then
		if self.tTurnConfVo then
			self.tTurnConfVo:update(_tData.conf)
		else
			local DragonTurnConfVo = require("app.layer.activityb.dragontreasure.DragonTurnConfVo")
			self.tTurnConfVo = DragonTurnConfVo.new(_tData.conf)
		end
	end
	--目标达到可以换的物品
	if _tData.tinfo then
		if self.tTinfo then
			self.tTinfo:update(_tData.tinfo)
		else
			local DragonTurnConfVo = require("app.layer.activityb.dragontreasure.DragonTurnConfVo")
			self.tTinfo = DragonTurnConfVo.new(_tData.tinfo)
		end
	end

	self.nCostItemCnt 			= _tData.p or self.nCostItemCnt 	--寻龙盘个数
	self.tOb 					= _tData.ob or self.tOb 			--List<Pair<Integer,Integer>>抽奖得到的物品
	self.tTob 					= _tData.tob or  self.tTob			--List<Pair<Integer,Integer>>达到目标次数得到的物品
	self.nGetTimes 				= _tData.tc or self.nGetTimes 		--抽了多少次
	self.nDc 					= _tData.dc or self.nDc 			--今日掉落次数
	self.nTdc 					= _tData.tdc or self.nTdc 			--总掉落次数
	self.nCostItemId 			= _tData.item or self.nCostItemId  	--抽奖消耗的物品id
	self.tCost 					= _tData.cost or self.tCost 		--List<Pair<Integer,Integer>>购买抽奖物品需要的物品
	self.nOneC 					= _tData.oneC or self.nOneC 		--抽一次的消耗
	self.nTenC 					= _tData.tenC or self.nTenC 		--抽十次的消耗
	self.tGrids 				= _tData.grids or self.tGrids 		--List<Integer>转到哪些格子
	

	self:refreshActService(_tData)--刷新活动共有的数据
end


-- 获取红点方法
function DataDragonTreasure:getRedNums()
	local nNums = 0
	if self.nCostItemCnt  >=  self.nOneC then
		nNums = nNums + 1
	end
	nNums = self.nLoginRedNums + nNums
	return nNums
end




return DataDragonTreasure