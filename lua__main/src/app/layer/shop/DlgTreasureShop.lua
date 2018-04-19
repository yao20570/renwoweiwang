----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-10 15:57:44
-- Description: 珍宝阁
-----------------------------------------------------
--珍宝阁
local DlgBase = require("app.common.dialog.DlgBase")
local ItemTreasure = require("app.layer.shop.ItemTreasure")
local DlgTreasureShop = class("DlgTreasureShop", function()
	return DlgBase.new(e_dlg_index.treasureshop)
end)

function DlgTreasureShop:ctor(  )
	parseView("dlg_treasure_shop", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgTreasureShop:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setTitle(getConvertedStr(3, 10308))

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgTreasureShop",handler(self, self.onDlgTreasureShopDestroy))
end

-- 析构方法
function DlgTreasureShop:onDlgTreasureShopDestroy(  )
    self:onPause()
end

function DlgTreasureShop:regMsgs(  )
	regMsg(self, gud_shop_data_update_msg, handler(self, self.updateViews))
	regMsg(self, ghd_treasure_shop_flip_card_msg, handler(self, self.updateViews))
end

function DlgTreasureShop:unregMsgs(  )
	unregMsg(self, gud_shop_data_update_msg)
	unregMsg(self, ghd_treasure_shop_flip_card_msg)
end
--继续方法
-- _bReshow(bool): 是否是在后台切回来而已
function DlgTreasureShop:onResume( _bReshow )
	self:updateViews()
	self:regMsgs()
end
--暂停方法
function DlgTreasureShop:onPause(  )
	self:unregMsgs()
	unregUpdateControl(self)
end

function DlgTreasureShop:setupViews(  )
	self.pTxtCd = self:findViewByName("txt_cd")
	local pLayContent = self:findViewByName("lay_content")
	local nOffsetX, nOffsetY = 186 + 20, 240 + 20
	local nBeginX, nBeginY = 0, pLayContent:getContentSize().height + 20
	for i=1, 9 do
		local nCol = ((i-1) % 3)
		local nRow = math.ceil(i/3)
		local fX = nBeginX + nCol * nOffsetX
		local fY = nBeginY - nRow * nOffsetY
		local pItemTreasure = ItemTreasure.new(i)
		pItemTreasure:setPosition(fX, fY)
		pLayContent:addView(pItemTreasure)
	end
end

function DlgTreasureShop:updateViews(  )
	regUpdateControl(self, handler(self, self.updateCd))
	self:updateCd()
end

function DlgTreasureShop:updateCd(  )
	local bIsBought = Player:getShopData():getIsBoughtTreasure()
	if bIsBought then
		--已购买
		unregUpdateControl(self)
		self.pTxtCd:setString(getConvertedStr(3, 10316))
		setTextCCColor(self.pTxtCd, _cc.white)
	else
		local nCd = Player:getShopData():getFlipCardCd()
		--有cd时间
		if nCd > 0 then
			self.pTxtCd:setString(getConvertedStr(3, 10310) .. formatTimeToHms(nCd))
			setTextCCColor(self.pTxtCd, _cc.red)
		else
			--没有购买且cd时间为0
			unregUpdateControl(self)
			self.pTxtCd:setString(getConvertedStr(3, 10309))
			setTextCCColor(self.pTxtCd, _cc.white)
		end	
	end
end


return DlgTreasureShop