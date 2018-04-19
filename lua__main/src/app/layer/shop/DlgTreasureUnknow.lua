----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-10 15:57:44
-- Description: 珍宝阁未知购买
-----------------------------------------------------
--珍宝阁未知购买
local IconGoods = require("app.common.iconview.IconGoods")
local DlgCommon = require("app.common.dialog.DlgCommon")
local DlgTreasureUnknow = class("DlgTreasureUnknow", function()
	return DlgCommon.new(e_dlg_index.treasureunknow)
end)

function DlgTreasureUnknow:ctor(  )
	parseView("dlg_treasure_unknow", handler(self, self.onParseViewCallback))
end

--解析界面回调
function DlgTreasureUnknow:onParseViewCallback( pView )
	self:addContentView(pView) --加入内容层

	self:setTitle(getConvertedStr(3, 10308))

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("DlgTreasureUnknow",handler(self, self.onDlgTreasureUnknowDestroy))
end

-- 析构方法
function DlgTreasureUnknow:onDlgTreasureUnknowDestroy(  )
    self:onPause()
end

function DlgTreasureUnknow:regMsgs(  )
end

function DlgTreasureUnknow:unregMsgs(  )
end

function DlgTreasureUnknow:onResume(  )
	self:regMsgs()
end

function DlgTreasureUnknow:onPause(  )
	self:unregMsgs()
end

function DlgTreasureUnknow:setupViews(  )
	local pTxtTip1 = self:findViewByName("txt_tip1")
	pTxtTip1:setString(getConvertedStr(3, 10313))
	local pTxtTip2 = self:findViewByName("txt_tip2")
	pTxtTip2:setString(getConvertedStr(3, 10314))

	local pLayContent = self:findViewByName("lay_content")

	local nBeginX, nBeginY = 25, pLayContent:getContentSize().height
	pTxtTip1:setPositionX(nBeginX)
	--加入商品图标
	local tTreasureIds = Player:getShopData():getUnknowTreasureIds()
	for i=1,#tTreasureIds do
		local pIcon = IconGoods.new(TypeIconGoods.HADMORE)
		local nOffsetX = pIcon:getContentSize().width
		local nOffsetY = pIcon:getContentSize().height
		local nCol = ((i-1) % 4)
		local nRow = math.ceil(i/4)
		local fX = nBeginX + nCol * (nOffsetX + 28)
		local fY = nBeginY - nRow * nOffsetY
		pIcon:setPosition(fX, fY)
		pLayContent:addView(pIcon)

		local nId = tTreasureIds[i]
		local tTreasure = getShopTreasure(nId)
		if tTreasure then
			local pItemData = getGoodsByTidFromDB(tTreasure.id)
			if pItemData then
				pIcon:setCurData(pItemData)
	            pIcon:setMoreText(pItemData.sName)
				pIcon:setMoreTextColor(getColorByQuality(pItemData.nQuality))
			end
			pIcon:setNumber(tTreasure.num)
		end
	end

	--按钮
	local pLayBtnBuy = self:findViewByName("lay_btn_buy")
	local pBtnBuy = getCommonButtonOfContainer(pLayBtnBuy,TypeCommonBtn.L_YELLOW, getConvertedStr(3, 10315))
	pBtnBuy:onCommonBtnClicked(handler(self, self.onBuyClicked))
	
	--花费
	local tShopInit = getShopInitParam("treBuyCost")
	if tShopInit then
		self.nCostId = tShopInit.nCostId
		self.nCost = tShopInit.nCost
	end
	if self.nCost then
		local tConTable = {}
		tConTable.img = getCostResImg(self.nCostId)
		local tLabel = {
		 {self.nCost},
		}
		tConTable.tLabel = tLabel
		pBtnBuy:setBtnExText(tConTable)
	end
end

function DlgTreasureUnknow:updateViews(  )
end

--nExchangeId:兑换id
function DlgTreasureUnknow:setData(nExchangeId)
	self.nExchangeId = nExchangeId
end

function DlgTreasureUnknow:onBuyClicked( pView )
	if not self.nExchangeId then
		return
	end
	if not self.nCostId then
		return
	end
	if not self.nCost then
		return
	end
	if checkIsResourceEnough(self.nCostId, self.nCost, true) then
		SocketManager:sendMsg("reqTreasureShopBuy",{self.nExchangeId})
	end
	self:closeDlg(false)
end


return DlgTreasureUnknow