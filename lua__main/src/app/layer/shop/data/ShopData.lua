----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-10 15:01:54
-- Description: 商店数据
-----------------------------------------------------
local VipDiscount = require("app.layer.shop.data.VipDiscount")
local MaterialBuyNumVo = require("app.layer.shop.data.MaterialBuyNumVo")

--翻牌中间下标
local nCenterIndex = 5

--商店类型
e_type_shop = {
	vip = 1, --vip商店
	goods = 2, -- 道具商店
	material = 3, -- 材料商店
}



--商店数据类
local ShopData = class("ShopData")

function ShopData:ctor(  )
	self.tVipDiscounts = {} --VIP商店购买打折物品记录
	self.bDayFreeIds = {} --商店每天免费购买物品
	self.bDiscountIds = {}
	self.bIsBoughtTreasure = false --今日是否已购买珍宝阁物品
	self.nFlipCardCd = 0
	self.nFlipCardCdSystemTime = 0
	self.tTreasureIdList = {} --珍宝阁物品队列(兑换ID)
	self.tFTreasureIdList = {} --珍宝阁已翻牌队列(兑换ID)
	self.nShopTeamCd = 0
	self.nShopTeamCdLastLoadTime = 0
	self.tMaterialBuyNums = {} --材料商店物品购买次数
end

function ShopData:release(  )
end

--[8502]加载数据
function ShopData:onShopLoad( tData )
	if not tData then
		return
	end
	--discounts	List<VipDiscount>	VIP商店购买打折物品记录
	if tData.discounts then
		for i=1,#tData.discounts do
			local tVipDiscount = VipDiscount.new(tData.discounts[i])
			self.tVipDiscounts[tVipDiscount.nExchangeId] = tVipDiscount
		end
	end
	
	self:setDayFreeIds(tData.fb)--fb	Set<Integer>	商店每天免费购买物品
	self:setDiscountIds(tData.p) --p	Set<Integer>	道具商店折扣物品
	self:setBoughtTreasure(tData.b) --Integer	今日是否已购买珍宝阁物品 1.已购买 0.未购买
	self:setFlipCardCd(tData.dc) --Integer	翻牌倒计时
	self:setTreasureIdList(tData.tq) --List<Integer>	珍宝阁物品队列(兑换ID)
	self:setFTreasureIdList(tData.dq)--List<Integer>	珍宝阁已翻牌队列(兑换ID)
	self:setMaterialBuyNums(tData.mos) --mos	List<MaterialBuyNumVo>	材料商店物品购买次数
	self.nShopTeamCd = tData.cul	--Integer	商队累计CD时间
	self.nShopTeamCdLastLoadTime = getSystemTime()

	--mos	List<MaterialBuyNumVo>	材料商店物品购买次数
end

--设置今天材料购买vo
function ShopData:setMaterialBuyNums( tData )
	self.tMaterialBuyNums = {}
	if tData then
		for i=1,#tData do
			local tMaterialBuyNumVo = MaterialBuyNumVo.new(tData[i])
			self.tMaterialBuyNums[tMaterialBuyNumVo.nId] = tMaterialBuyNumVo
		end
	end
end

--设置道具商店折扣物品
function ShopData:setDiscountIds( tData)
	self.bDiscountIds = {}
	if tData then	
		for i=1,#tData do
			self.bDiscountIds[tData[i]] = true
		end
	end
end

--商店每天免费购买物品
function ShopData:setDayFreeIds( tData)
	self.bDayFreeIds = {}
	if tData then
		for i=1,#tData do
			self.bDayFreeIds[tData[i]] = true
		end
	end
end

--设置今日是否已购买珍宝阁物品
function ShopData:setBoughtTreasure( nValue )
	self.bIsBoughtTreasure = nValue == 1 --Integer	今日是否已购买珍宝阁物品 1.已购买 0.未购买
end

function ShopData:setFlipCardCd( nValue )
	self.nFlipCardCd = nValue	 --Integer	翻牌倒计时
	self.nFlipCardCdSystemTime = getSystemTime()

	-- sendMsg(ghd_treasure_shop_flip_card_cdchange_msg)
	sendMsg(gud_refresh_activity) --通知刷新界面
	--刷新活动红点
	sendMsg(gud_refresh_act_red)
end

function ShopData:setTreasureIdList( tData )
	if tData then
		self.tTreasureIdList = tData	--List<Integer>	珍宝阁物品队列(兑换ID)
		--特殊处理，格子下标是1的放在中间
		local nTargetIndex = nil
		for i=1,#self.tTreasureIdList do
			local nIndex = self.tTreasureIdList[i]
			local tTreasure = getShopTreasure(nIndex)
			if tTreasure then
				if tTreasure.area == 1 then
					nTargetIndex = i
					break
				end
			end
		end
		if nTargetIndex then
			if nTargetIndex ~= nCenterIndex then
				local nId = self.tTreasureIdList[nCenterIndex]
				self.tTreasureIdList[nCenterIndex] = self.tTreasureIdList[nTargetIndex]
				self.tTreasureIdList[nTargetIndex] = nId
			end
		end
	end
end

function ShopData:setFTreasureIdList( tData )
	if tData then
		self.tFTreasureIdList = tData	--List<Integer>	珍宝阁已翻牌队列(兑换ID)
	end
end

--[8503]珍宝阁翻牌
function ShopData:onTreasureShopFlip( tData )
	if not tData then
		return
	end
	self:setFlipCardCd(tData.dc)	--Integer	翻牌倒计时
	table.insert(self.tFTreasureIdList,tData.i)--	Integer	翻牌兑换ID
end

--[8504]购买珍宝阁物品
function ShopData:onTreasureShopBuy( tData )
	if not tData then
		return
	end
	-- o	List<Pair<Integer,Long>>	获得物品
	self:setBoughtTreasure(tData.b) --Integer	今日是否已购买珍宝阁物品 1.已购买 0.未购买	
	self:setFlipCardCd(tData.dc)	--Integer	翻牌倒计时
	self:setTreasureIdList(tData.tq) --List<Integer>	珍宝阁物品队列(兑换ID)
	self:setFTreasureIdList(tData.dq)--List<Integer>	珍宝阁已翻牌队列(兑换ID)
end

--[8506]商队兑换
function ShopData:onMerchantsExchange(tData)
	-- body
	if not tData then return end
	-- o	List<Pair<Integer,Long>>	兑换获得物品
	showGetAllItems(tData.o)
	self:setExchangeCD(tData.cul)   --Integer  兑换累计CD时间
	self.nShopTeamCdLastLoadTime = getSystemTime()
end

--[8501]商店数据更新推送
function ShopData:onShopUpdate( tData )
	if not tData then
		return
	end
	self:setDiscountIds(tData.p) --p	Set<Integer>	道具商店折扣物品
	self:setDayFreeIds(tData.fb)--fb	Set<Integer>	商店每天免费购买物品
	self:setBoughtTreasure(tData.b) --Integer	今日是否已购买珍宝阁物品 1.已购买 0.未购买	
	self:setFlipCardCd(tData.dc)	--Integer	翻牌倒计时
	self:setTreasureIdList(tData.tq) --List<Integer>	珍宝阁物品队列(兑换ID)
	self:setFTreasureIdList(tData.dq)--List<Integer>	珍宝阁已翻牌队列(兑换ID)
	self:setMaterialBuyNums(tData.mo) --mo	List<MaterialBuyNumVo>	材料商店物品购买次数
end

--更新VIP商店购买打折物品记录
function ShopData:updateVipDiscount( tData )
	if not tData then
		return
	end
	local nExchangeId = tData.e
	if self.tVipDiscounts[nExchangeId] then
		self.tVipDiscounts[nExchangeId]:update(tData)
	else
		local tVipDiscount = VipDiscount.new(tData)
		self.tVipDiscounts[tVipDiscount.nExchangeId] = tVipDiscount
	end
end

--更新材料商店物品购买次数
function ShopData:updateMaterialBuyNumVo( tData )
	if not tData then
		return
	end
	local nId = tData.i
	if self.tMaterialBuyNums[nId] then
		self.tMaterialBuyNums[nId]:update(tData)
	else
		local tMaterialBuyNumVo = MaterialBuyNumVo.new(tData)
		self.tMaterialBuyNums[tMaterialBuyNumVo.nId] = tMaterialBuyNumVo
	end
end

--设置况换时间
function ShopData:setExchangeCD( tData )
	-- body
	self.nShopTeamCd = tData
end

--获取商队兑换累计CD时间
function ShopData:getExchangeCD()
	-- body
	return self.nShopTeamCd
end

--获得商队兑换剩余时间
function ShopData:getShopTeamCDLeftTime()
	-- body
	if self.nShopTeamCd > 0 then
		-- 单位是秒
		local fCurTime = getSystemTime()
		-- 总共剩余多少秒
		local fLeft = self.nShopTeamCd - (fCurTime - self.nShopTeamCdLastLoadTime or 0)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
end

--获取资源兑换剩余次数
function ShopData:getResChangeLeftCnt()
	local fLeftTime = self:getShopTeamCDLeftTime()
	local nBuyOnceCD = tonumber(getShopInitParam("buyOnceCD"))  --商队购买一次cd时间(秒)
	local nMaxLimitCD = tonumber(getShopInitParam("maxLimitCD")) + nBuyOnceCD --CD上限时间
	local nCnt = math.floor((nMaxLimitCD - fLeftTime)/nBuyOnceCD)
	return nCnt or 0
end

--获取今日是否已购买珍宝阁物品
function ShopData:getIsBoughtTreasure( )
	return self.bIsBoughtTreasure
end

--获取翻牌倒计时
function ShopData:getFlipCardCd(  )
	if self.nFlipCardCd and self.nFlipCardCd > 0 then
		local fCurTime = getSystemTime()
		local fLeft = self.nFlipCardCd - (fCurTime - self.nFlipCardCdSystemTime)
		if(fLeft < 0) then
			fLeft = 0
		end
		return fLeft
	else
		return 0
	end
end

--获取珍宝阁列表
function ShopData:getTreasureIdList(  )
	return self.tTreasureIdList
end

--珍宝阁已翻牌队列
function ShopData:getFTreasureIdList(  )
	return self.tFTreasureIdList
end

--获取除中间外的是否已经翻牌了
--nIndex 卡牌下标
function ShopData:getCardIsFliped( nIndex )
	if nCenterIndex == nIndex then
		return true
	end

	local nExchangeId = self.tTreasureIdList[nIndex]
	for i=1,#self.tFTreasureIdList do
		if self.tFTreasureIdList[i] == nExchangeId then
			return true
		end
	end
	return false
end

--获取未开牌的可能存在的商品集
function ShopData:getUnknowTreasureIds()
	local tTreasureIds = {}
	for i=1,9 do
		local bIsFliped = self:getCardIsFliped(i)
		if not bIsFliped then
			table.insert(tTreasureIds, self.tTreasureIdList[i])
		end
	end
	return tTreasureIds
end

--获取今天vip商品已购买次数
--nExchange:商品id
function ShopData:getVipDiscountBought( nExchange )
	if self.tVipDiscounts[nExchange] then
		return self.tVipDiscounts[nExchange].nDiscount
	end
	return 0
end

--获取今天材料今天已购买次数
--nExchange:商品id
function ShopData:geMaterialBuyNum( nExchange )
	if self.tMaterialBuyNums[nExchange] then
		return self.tMaterialBuyNums[nExchange].nNum
	end
	return 0
end

--获取是否折扣道具商品
--nExchange:商品id
function ShopData:getIsDiscountId( nExchange)
	return self.bDiscountIds[nExchange] or false
end

--获取是否商店每天免费购买物品
--nExchange:商品id
function ShopData:getIsDayFreeId( nExchange)
	return self.bDayFreeIds[nExchange] or false
end


return ShopData