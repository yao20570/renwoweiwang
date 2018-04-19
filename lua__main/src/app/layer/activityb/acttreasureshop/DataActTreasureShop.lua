-- Author: liangzhaowei
-- Date: 2017-08-14 11:23:56
-- 珍宝阁入口(创建活动只为显示入口)
local Activity = require("app.data.activity.Activity")

local DataActTreasureShop = class("DataActTreasureShop", function()
	return Activity.new(e_id_activity.acttreasureshop) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.acttreasureshop] = function (  )
	return DataActTreasureShop.new()
end

function DataActTreasureShop:ctor()
	-- body
   self:myInit()
end


function DataActTreasureShop:myInit( )
 	
end

-- 读取服务器中的数据
function DataActTreasureShop:refreshDatasByServer( _tData )
	-- dump(_tData,"数据",20)
	if not _tData then
	 	return
	end

	--只有公共部分

	self:refreshActService(_tData)--刷新活动共有的数据
end

-- 获取红点方法
function DataActTreasureShop:getRedNums()
	local nNums = 0
	if self:isFlipForFree() then
		nNums = nNums + 1
	end
	nNums = self.nLoginRedNums + nNums
	return nNums
end

--珍宝阁是否有免费翻牌
function DataActTreasureShop:isFlipForFree()
	-- body
	local tShopData = Player:getShopData()
	--是否已购买
	local bBought = tShopData:getIsBoughtTreasure()
	if bBought then
		return false
	end
	--已翻牌队列
	local tList = tShopData:getFTreasureIdList()
	--是否在CD时间之内
	local nCd = tShopData:getFlipCardCd()
	if nCd == 0 and #tList < 8 then
		return true
	else
		return false
	end
end

return DataActTreasureShop