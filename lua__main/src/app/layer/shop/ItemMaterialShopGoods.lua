----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-14 11:28:56
-- Description: 材料商店, 材料商店 子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ShopFunc = require("app.layer.shop.ShopFunc")

local ItemMaterialShopGoods = class("ItemMaterialShopGoods", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemMaterialShopGoods:ctor(  )
	--解析文件
	parseView("item_material_shop_goods", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemMaterialShopGoods:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemMaterialShopGoods", handler(self, self.onItemMaterialShopGoodsDestroy))
end

-- 析构方法
function ItemMaterialShopGoods:onItemMaterialShopGoodsDestroy(  )
    self:onPause()
end

function ItemMaterialShopGoods:regMsgs(  )
	regMsg(self, ghd_shop_buy_success_msg, handler(self, self.onShopBuySuccess))
	regMsg(self, gud_shop_data_update_msg, handler(self, self.updateViews))

end

function ItemMaterialShopGoods:unregMsgs(  )
	unregMsg(self, ghd_shop_buy_success_msg)
	unregMsg(self, gud_shop_data_update_msg)
end

function ItemMaterialShopGoods:onResume(  )
	self:regMsgs()
end

function ItemMaterialShopGoods:onPause(  )
	self:unregMsgs()
end

function ItemMaterialShopGoods:setupViews(  )
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pTxtName = self:findViewByName("txt_name")
	--self.pTxtDesc = self:findViewByName("txt_desc")
	self.pTxtDesc = MUI.MLabel.new({
		    text = "",
		    size = 20,
		    anchorpoint = cc.p(0, 1),
		    align = cc.ui.TEXT_ALIGN_LEFT,
    		valign = cc.ui.TEXT_VALIGN_TOP,
		    color = cc.c3b(255, 255, 255),
		    dimensions = cc.size(290, 54),
		})
	self.pTxtDesc:setPosition(self.pTxtName:getPositionX(), self.pTxtName:getPositionY() - 30)
	self:addView(self.pTxtDesc, 10)
	setTextCCColor(self.pTxtDesc, _cc.pwhite)

	self.pTxtPrivilege = self:findViewByName("txt_privilege")

	--购买
	self.pLayBtnBuy = self:findViewByName("btn_buy")
	local pBtnBuy = getCommonButtonOfContainer(self.pLayBtnBuy, TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10327))
	pBtnBuy:onCommonBtnClicked(handler(self, self.onBuyClicked))
	pBtnBuy:onCommonBtnDisabledClicked(function (  )
		-- body
		TOAST(getConvertedStr(6, 10483))
	end)
	self.pBtnBuy = pBtnBuy

	local tConTable = {}
	tConTable.img = getCostResImg(e_type_resdata.money)
	--文本
	local tLabel = {
	 {"5000: ",getC3B(_cc.yellow)},
	}
	tConTable.tLabel = tLabel
	self.pBtnBuy:setBtnExText(tConTable) 
end

function ItemMaterialShopGoods:updateViews(  )
	if not self.tShopMaterial then
		return
	end

	--显示物品
	local tGoods = getGoodsByTidFromDB(self.tShopMaterial.id)
	if tGoods then
		self.pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.item, tGoods)
		self.pTxtName:setString(tGoods.sName or "")
		--显示描述
		self.pTxtDesc:setString(tGoods.sDes or "")
		
		setTextCCColor(self.pTxtName, getColorByQuality(tGoods.nQuality))
		self.pIcon:setNumber(self.tShopMaterial.num)
	end

	--可购买次数
	local tStr = {
		{color=_cc.pwhite,text=getConvertedStr(3, 10330)},
		{color=_cc.blue,text="0"},
		{color=_cc.pwhite,text=getConvertedStr(3, 10324)},
	}
	local nCanBuy = ShopFunc.getShopMaterialCanBuy(self.tShopMaterial.exchange)
	if nCanBuy > 0 then
		tStr[2] = {color=_cc.blue,text=nCanBuy}
	else
		tStr[2] = {color=_cc.red,text=nCanBuy}
	end
	self.pTxtPrivilege:setString(tStr)

	--价格
	self.nPrice = ShopFunc.getShopMaterialPrice(self.tShopMaterial.exchange)
	self.pBtnBuy:setExTextLbCnCr(1, self.nPrice)

	--按钮是否置灰
	self.pBtnBuy:setBtnEnable(nCanBuy > 0)
	if self.pBtnBuy then
		if self.bShowBtnTx then
			self.pBtnBuy:showLingTx()
		else
			self.pBtnBuy:removeLingTx()
		end
	end	
end

--tShopMaterial:表格数据
function ItemMaterialShopGoods:setData( tShopMaterial )
	self.tShopMaterial = tShopMaterial
	self:updateViews()
end

function ItemMaterialShopGoods:onBuyClicked( pView )
	if not self.tShopMaterial then
		return
	end
	local tObject = {
	    nType = e_dlg_index.shopbatchbuy, --dlg类型
	    tShopBase = self.tShopMaterial,
	}
	sendMsg(ghd_show_dlg_by_type, tObject)
end

function ItemMaterialShopGoods:onShopBuySuccess( sMsgName, pMsgObj)
	if not self.tShopMaterial then
		return
	end
	if self.tShopMaterial.exchange == pMsgObj then
		self:updateViews()
	end
end

function ItemMaterialShopGoods:showBtnLingTx( _bshow )
	-- body
	self.bShowBtnTx = _bshow or false	
end

return ItemMaterialShopGoods


