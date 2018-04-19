----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-09-05 20:25:36
-- Description: 耗铁有礼
-----------------------------------------------------
local Activity = require("app.data.activity.Activity")

local DataConsumeiron = class("DataConsumeiron", function()
	return Activity.new(e_id_activity.consumeiron) 
end)
--创建自己(方便管理)
tActivityDataList[e_id_activity.consumeiron] = function (  )
	return DataConsumeiron.new()
end

function DataConsumeiron:ctor()
   self:myInit()
end


function DataConsumeiron:myInit( )
	self.nFreeTurn = 0
	self.nConsumeAgain = 0
	self.nBuyPrice = 0
	self.nBuy10Price = 0
	self.tGirdVos = {}
	-- self.tGotGrids = {}
end


-- 读取服务器中的数据
--_tData(ConsumeIronRes)
function DataConsumeiron:refreshDatasByServer( _tData )
	if not _tData then
	 	return
	end
	self.nFreeTurn = _tData.t or self.nFreeTurn --Integer	转盘次数
	self.nConsumeAgain = _tData.c or self.nConsumeAgain --	Integer	再消耗X量,免费获得转盘一次
	self.nBuyPrice =   _tData.b or self.nBuyPrice --	Integer	购买转盘花费
	self.nBuy10Price = _tData.tb or self.nBuy10Price -- Integer 购买转盘10花费
	if _tData.gs then --	List<GridVo>	转盘格子获品
		self.tGirdVos = {}
		local GridVo = require("app.layer.activityb.consumeiron.GridVo")
		for i=1,#_tData.gs do
			table.insert(self.tGirdVos, GridVo.new(_tData.gs[i]))
		end
		--按钮序列排
		table.sort(self.tGirdVos, function ( a, b )
			return a.nGrid < b.nGrid
		end)
	end
	-- if _tData.as then --List<Integer>	转盘获得物品下标
	-- 	self.tGotGrids = {}
	-- 	for i=1,#_tData.gs do
	-- 		table.insert(self.tGotGrids, _tData.gs[i])
	-- 	end
	-- end

	self:refreshActService(_tData)--刷新活动共有的数据
end

function DataConsumeiron:getGirdVos( )
	return self.tGirdVos
end

function DataConsumeiron:getBuyPrice( )
	return self.nBuyPrice
end

function DataConsumeiron:getBuyTenPrice( )
	-- return self.nBuyPrice * 10
	return self.nBuy10Price
end

function DataConsumeiron:getFreeTurn( )
	return self.nFreeTurn
end

-- function DataConsumeiron:getGotGrids( )
-- 	return self.tGotGrids
-- end

-- 获取红点方法
function DataConsumeiron:getRedNums()
	local nNums = self.nFreeTurn
	return nNums
end




return DataConsumeiron