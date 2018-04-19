-- DataSpecialSale.lua
---------------------------------------------
-- Author: dshulan
-- Date: 2017-07-04 17:38:00
-- 特价卖场数据
---------------------------------------------

local Activity = require("app.data.activity.Activity")

local DataSpecialSale = class("DataSpecialSale", function()
	return Activity.new(e_id_activity.specialsale) 
end)

--创建自己(方便管理)
tActivityDataList[e_id_activity.specialsale] = function (  )
	return DataSpecialSale.new()
end

-- _index
function DataSpecialSale:ctor()
	-- body
   self:myInit()
end


function DataSpecialSale:myInit( )
	self.tGoodsList    = {}   --List<DiscountShopPacketVO>	特价商品列表
	self.tBoughtList   = {}   --List<Pair<Integer,Integer>>	已购买列表
	self.tGotList      = {}   --List<Pair<Integer,Long>>    获得列表
	self.nCd           = 0    --剩余刷新时间
end


-- 读取服务器中的数据
function DataSpecialSale:refreshDatasByServer( _tData )
	-- dump(_tData,"特价卖场数据", 20)
	if not _tData then
	 	return
	end

	self.tGoodsList   = _tData.packetVOs   or self.tGoodsList   --List<GrowFundAwardVO>	   特价商品列表
	self.tBoughtList  = _tData.buy         or self.tBoughtList  --List<Pair<Integer,Long>> 已购买列表
	self.tGotList     = _tData.ob          or self.tGotList     --获得
	self.nCd          = _tData.cd          or self.nCd          --剩余刷新时间

	self.nLastLoadTime = getSystemTime()

	if _tData.ob then
		showGetAllItems(_tData.ob, 1)
	end
	--礼包排序
	table.sort(self.tGoodsList, function(a, b)
		return a.index < b.index
	end)
	--物品排序
	for i=1,#self.tGoodsList do
		sortGoodsList(self.tGoodsList[i].award)
	end
	--
 
	self:refreshActService(_tData)--刷新活动共有的数据
end

--获取礼包名字
--_index:服务器下发的index
function DataSpecialSale:getGiftName(_index)
	-- body
	local tParam = {}
	local tParams = luaSplitMuilt2(self.tParam, "#", "|")
	for _, v in pairs(tParams) do
		for _, data in pairs(v) do
			local tStr = luaSplit(data, ",")
			if _index == tonumber(tStr[#tStr]) then
				return tStr[6]
			end
		end
	end
end

--距离下次礼包刷新时间
function DataSpecialSale:getNextRefreshTime()
	local sTime = ""
	local nNowTime = getSystemTime()
	local nTime  = self.nCd - (nNowTime-self.nLastLoadTime)
	sTime = formatTimeToHms(nTime, false, true)

	return sTime
end

--获取当前购买次数
function DataSpecialSale:getBuyTimes(_type)
	-- body
	local nBoughtTimes = 0
	for idx, info in pairs(self.tBoughtList) do
		if _type == info.k then
			nBoughtTimes = info.v
			break
		end
	end
	return nBoughtTimes
end


--是否还有购买次数(_type:礼包类型)
function DataSpecialSale:isCanBuy(_type)
	-- body
	local nBoughtTimes = self:getBuyTimes(_type)
	
	-- dump(self.tGoodsList)
	for k, v in pairs(self.tGoodsList) do
		if v.index == _type and nBoughtTimes < v.limit then
			return true
		end
	end
	return false
end

--根据uid获取充值配表数据
function DataSpecialSale:getRechargeInfo(_uid)
	-- body
	local tData = getSpecialSaleDlgData()
	for k, v in pairs(tData) do
		if _uid == v.pid then
			return v
		end
	end
end

-- 获取红点方法
function DataSpecialSale:getRedNums()
	local nNums = 0
	--入口移到外面, 屏蔽红点
	-- nNums = self.nLoginRedNums + nNums

	return nNums
end




return DataSpecialSale