----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-14 17:20:23
-- Description: 道具商城 道具集合 道具
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ShopFunc = require("app.layer.shop.ShopFunc")
local ItemShopItem = class("ItemShopItem", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

-- tShopBase:表格数据
function ItemShopItem:ctor( tShopBase )
	self.tShopBase = tShopBase
	--解析文件
	parseView("tem_item_shop_goods", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemShopItem:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemShopItem", handler(self, self.onItemShopItemDestroy))
end

-- 析构方法
function ItemShopItem:onItemShopItemDestroy(  )
    self:onPause()
end

function ItemShopItem:regMsgs(  )
	regMsg(self, gud_shop_data_update_msg, handler(self, self.updateViews))
end

function ItemShopItem:unregMsgs(  )
	unregMsg(self, gud_shop_data_update_msg)
end

function ItemShopItem:onResume(  )
	self:regMsgs()
end

function ItemShopItem:onPause(  )
	self:unregMsgs()
end

function ItemShopItem:setupViews(  )
	self.pLayDefault = self:findViewByName("default")
	self.pLayDefault:setViewTouched(true)
	self.pLayDefault:setIsPressedNeedScale(false)
	self.pLayDefault:onMViewClicked(handler(self, self.onBuyClicked))
	self.pTxtPrice = self:findViewByName("txt_price")
	self.pLayIcon = self:findViewByName("lay_icon")

	self.pLayBtnBuy = self:findViewByName("lay_btn_buy")
	self.pLayBtnBuy:setViewTouched(false)
	self.pLayBtnBuy:setIsPressedNeedScale(false)
	self.pLayBtnBuy:onMViewClicked(handler(self, self.onBuyClicked))
	-- local pBtnBuy = getCommonButtonOfContainer(pLayBtnBuy, TypeCommonBtn.S_BLUE)
	-- pBtnBuy:onCommonBtnClicked(handler(self, self.onBuyClicked))
end


function ItemShopItem:updateViews(  )
	if not self.tShopBase then
		return
	end

	--显示物品
	local tGoods = getGoodsByTidFromDB(self.tShopBase.id)
	if tGoods then
		self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.HADMORE, type_icongoods_show.item, tGoods)
		self.pIcon:setIconIsCanTouched(false)
		self.pIcon:setMoreTextColor(_cc.pwhite)
		--显示数字
		if self.tShopBase.num > 0 then
			self.pIcon:setNumber(self.tShopBase.num)
			self.pIcon:setIsShowNumber(true)
		else
			self.pIcon:setIsShowNumber(false)
		end
		--显示折扣
		if Player:getShopData():getIsDiscountId(self.tShopBase.exchange) then
			self.pIcon:setDiscount(tostring(self.tShopBase.discount * 100).."%")
		else
			self.pIcon:setDiscount(nil)
		end
	end
	--价格
	local nPrice = ShopFunc.getShopItemPrice(self.tShopBase.exchange)
	self.pTxtPrice:setString(nPrice)
end

function ItemShopItem:onBuyClicked( pView )
	if not self.tShopBase then
		return
	end
	local tObject = {
	    nType = e_dlg_index.shopbatchbuy, --dlg类型
	    tShopBase = self.tShopBase,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

return ItemShopItem


