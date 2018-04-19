----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2018-03-17 16:01:00
-- Description: 城池密库 商品
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemRoyalBankGoods = class("ItemRoyalBankGoods", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemRoyalBankGoods:ctor(  )
	--解析文件
	self.nCostId = e_type_resdata.royalscore
	parseView("item_royal_bank_goods", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemRoyalBankGoods:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemRoyalBankGoods", handler(self, self.onItemRoyalBankGoodsDestroy))
end

-- 析构方法
function ItemRoyalBankGoods:onItemRoyalBankGoodsDestroy(  )
    self:onPause()
end

function ItemRoyalBankGoods:regMsgs(  )
end

function ItemRoyalBankGoods:unregMsgs(  )
end

function ItemRoyalBankGoods:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function ItemRoyalBankGoods:onPause(  )
	self:unregMsgs()
end

function ItemRoyalBankGoods:setupViews(  )
	self.pLayIcon = self:findViewByName("lay_icon")
	local pLayBtnBuy = self:findViewByName("lay_btn_buy")
	self.pLayBtnBuy = pLayBtnBuy
	local pBtnBuy = getCommonButtonOfContainer(pLayBtnBuy,TypeCommonBtn.XL_BLUE2, "")
	self.pBtnBuy = pBtnBuy
	setMCommonBtnScale(self.pLayBtnBuy, self.pBtnBuy, 0.9)
	local tBtnTable = {}
	tBtnTable.img = getCostResImg(self.nCostId)
	--文本
	tBtnTable.tLabel = {
		{"",getC3B(_cc.white)},
	}
	tBtnTable.awayH = -35 -- 扩展内容层离存放按钮的父层 的高度 (默认self.nAwayH 的高度)
	pBtnBuy:setBtnExText(tBtnTable, true)
	pBtnBuy:onCommonBtnClicked(handler(self, self.onBuyClicked))

	-- --层点击
	-- self:setViewTouched(true)
	-- self:setIsPressedNeedScale(false)
	-- self:setIsPressedNeedColor(false)
	-- self:onMViewClicked(handler(self, self.onBuyClicked))
	
end

function ItemRoyalBankGoods:updateViews(  )
	if not self.tData then
		return
	end
	self.nCostNum = nil
	self.tGoods = nil
	local tOb = luaSplit(self.tData.ob, ":")
	if tOb then
		local nId = tonumber(tOb[1])
		local nNum = tonumber(tOb[2])
		if nId and nNum then
			local tGoods = getGoodsByTidFromDB(nId)
			self.tGoods = tGoods
			local pGoods = getIconGoodsByType(self.pLayIcon, TypeIconGoods.HADMORE, type_icongoods_show.item, tGoods)
			pGoods:setIconIsCanTouched(true)
			pGoods:setNumber(nNum)
		end
	end
	self.nCostNum = self.tData.cost
	self.pBtnBuy:setExTextLbCnCr(1, self.nCostNum)
end

--tData: epangWar_shop
function ItemRoyalBankGoods:setData( tData )
	self.tData = tData
	self:updateViews()
end

--设置是否次数
function ItemRoyalBankGoods:onBuyClicked(  )
	if not self.nCostNum or not self.tGoods then
		return
	end
	local DlgAlert = require("app.common.dialog.DlgAlert")
    local pDlg = getDlgByType(e_dlg_index.alert)
    if(not pDlg) then
        pDlg = DlgAlert.new(e_dlg_index.alert)
    end
    pDlg:setTitle(getConvertedStr(3, 10091))
    --"是否消耗<font color='#%s'>%s</font>积分兑换<font color='#%s'>%s</font>"
    pDlg:setContent(string.format(getConvertedStr(3, 10941), _cc.yellow, self.nCostNum, _cc.yellow, self.tGoods.sName))
    pDlg:setRightHandler(function (  )
        pDlg:closeDlg(false)
        local nScore = getMyGoodsCnt(e_type_resdata.royalscore)
        if nScore >= self.nCostNum then
        	SocketManager:sendMsg("reqRoyalBankExchange", {self.tData.id}, nil)
        	TOAST(getConvertedStr(3, 10942))
        else
        	TOAST(getConvertedStr(3, 10943))
        end
    end)
    pDlg:showDlg(bNew)
end

return ItemRoyalBankGoods


