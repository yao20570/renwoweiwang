----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-14 11:24:53
-- Description: 道具商店
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ShopArrowTitle = require("app.layer.shop.ShopArrowTitle")
local ItemShopItems = require("app.layer.shop.ItemShopItems")
local ScrollViewEx = require("app.common.listview.ScrollViewEx")
local ItemShop = class("ItemShop", function(pSize)
	local pView = MCommonView.new(TYPE_LAYER.LAYER_MFILLLAYER)
	pView:setContentSize(pSize)
	return pView
end)

function ItemShop:ctor( pSize )
	local tDiscountShopBaseList = {}
	local tShopBaseList = getOpenShopBaseDataByKind(e_type_shop.goods)
	for i=1,#tShopBaseList do
		if Player:getShopData():getIsDiscountId(tShopBaseList[i].exchange) then
			table.insert(tDiscountShopBaseList, tShopBaseList[i])
		end
	end

	local pUis = {}
	table.insert(pUis, ShopArrowTitle.new(getConvertedStr(3, 10331), 1))
	table.insert(pUis, ItemShopItems.new(tDiscountShopBaseList))
	table.insert(pUis, ShopArrowTitle.new(getConvertedStr(3, 10332), 1))
	table.insert(pUis, ItemShopItems.new(tShopBaseList))	
	local nWidth, nHeight = pSize.width, pSize.height
	local nInnerHeight = 0
	for i=1,#pUis do
		local pUiSize = pUis[i]:getContentSize()
		nInnerHeight = nInnerHeight + pUiSize.height
	end

	--滚动内容面板
	local pLayScrollInner = MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
	local nLayScrollInnerHeight = math.max(nHeight, nInnerHeight)
	pLayScrollInner:setContentSize(nWidth, nLayScrollInnerHeight)
	--加入子节点
	local nBeginY = nLayScrollInnerHeight
	for i=1,#pUis do
		local pUiSize = pUis[i]:getContentSize()
		nBeginY = nBeginY - pUiSize.height
		pUis[i]:setPosition(0, nBeginY)
		pLayScrollInner:addView(pUis[i])
	end

	--生成垂直滚动层
	self.pScrollView = ScrollViewEx.new( pSize.width, pSize.height )
	--上下箭头
	local pUpArrow, pDownArrow = getUpAndDownArrow()
	self.pScrollView:setUpAndDownArrow(pUpArrow, pDownArrow)	
	self.pScrollView:setAnchorPoint(0,0) 
	self.pScrollView:addView(pLayScrollInner)		
	self:addView(self.pScrollView)
	pLayScrollInner:setPosition(0,0)
	self.pScrollView:setScrollViewContent(pLayScrollInner)	
	self.pScrollView:scrollToBegin(false)
	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemShop", handler(self, self.onItemShopDestroy))
end

-- 析构方法
function ItemShop:onItemShopDestroy(  )
    self:onPause()
end

function ItemShop:regMsgs(  )
end

function ItemShop:unregMsgs(  )
end

function ItemShop:onResume(  )
	self:regMsgs()
end

function ItemShop:onPause(  )
	self:unregMsgs()
end

function ItemShop:setupViews(  )
end

function ItemShop:updateViews(  )
	
end

return ItemShop


