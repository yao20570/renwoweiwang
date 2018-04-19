----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-14 17:20:23
-- Description: vip礼包道具
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local ShopArrowTitle = require("app.layer.shop.ShopArrowTitle")
local IconGoods = require("app.common.iconview.IconGoods")
local MImgLabel = require("app.common.button.MImgLabel")
local ItemVipGit = class("ItemVipGit", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

-- tShopBase:表格数据
function ItemVipGit:ctor( tShopBase )
	self.tShopBase = tShopBase
	--解析文件
	parseView("item_vip_gift", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemVipGit:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:updateViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemVipGit", handler(self, self.onItemVipGitDestroy))
end

-- 析构方法
function ItemVipGit:onItemVipGitDestroy(  )
    self:onPause()
end

function ItemVipGit:regMsgs(  )
	regMsg(self, gud_vip_gift_bought_update_msg, handler(self, self.updateViews))
end

function ItemVipGit:unregMsgs(  )
	unregMsg(self, gud_vip_gift_bought_update_msg)
end

function ItemVipGit:onResume(  )
	self:regMsgs()
end

function ItemVipGit:onPause(  )
	self:unregMsgs()
end

function ItemVipGit:setupViews(  )
	self.pLayTitle = self:findViewByName("lay_title")

	self.pTxtOpenLv = self:findViewByName("txt_open_lv")
	setTextCCColor(self.pTxtOpenLv, _cc.red)

	self.tDropList = {}
	self.pIconList = {}
	self.pLayGoods = self:findViewByName("lay_icons")

	local pLayBtnBuy = self:findViewByName("lay_btn_buy")
	self.pLayBtnBuy = pLayBtnBuy
	local pBtnBuy = getCommonButtonOfContainer(pLayBtnBuy,TypeCommonBtn.M_YELLOW, getConvertedStr(3, 10327))
	pBtnBuy:onCommonBtnClicked(handler(self, self.onBuyClicked))
	self.pBtnBuy = pBtnBuy
	

	--商店文字
	self.pImgLabel = MImgLabel.new({text="", size = 20, parent = pLayBtnBuy})
	self.pImgLabel:setImg(getCostResImg(e_type_resdata.money), 1, "right")
	-- self.pImgLabel:setImg(getCostResImg(e_type_resdata.money), 1, "center")
	self.pImgLabel:followPos("center", pLayBtnBuy:getContentSize().width/2, pLayBtnBuy:getContentSize().height + 10, 10)

	--已购买标志
	self.pImgFlag = self:findViewByName("img_flag")	
end


function ItemVipGit:updateViews(  )
	if not self.tVipData then
		return
	end

	--标题
	local sTitleStr = string.format(getConvertedStr(3, 10333), self.tVipData.lv)
	if not self.pShopArrowTitle then
		self.pShopArrowTitle = ShopArrowTitle.new(sTitleStr, 2)
		self.pLayTitle:addView(self.pShopArrowTitle)
	else
		self.pShopArrowTitle:setData(sTitleStr)
	end

	--物品列表
	if self.nListViewGiftId ~= self.tVipData.giftid then
		self.nListViewGiftId = self.tVipData.giftid
		self.tDropList = getDropById(self.tVipData.giftid)
		-- 直接调用通用方法刷新内容
		gRefreshHorizontalList(self.pLayGoods, self.tDropList)
	end

    --是否判断vip等级够不
    if Player:getPlayerInfo().nVip < self.tVipData.lv then
    	self.pTxtOpenLv:setVisible(true)
    	self.pTxtOpenLv:setString(getVipLvString(self.tVipData.lv) .. getConvertedStr(3, 10334))
    	self.pLayBtnBuy:setVisible(false)
    	self.pImgFlag:setVisible(false)

    	self.pBtnBuy:removeLingTx()
    else
    	self.pTxtOpenLv:setVisible(false)
    	self.pLayBtnBuy:setVisible(true)
    	local tStr = {
    		{color=_cc.white, text=getConvertedStr(9,10002)},
    		-- {color=_cc.white, text=" "..self.tVipData.nowprice}, 
    	}
    	
		local nLen = string.len(tostring(self.tVipData.orgprice) .. getConvertedStr(9,10002))
		local fScale = nLen * 0.78
		self.pImgLabel:showRedLine(true, fScale)    	
    	self.pImgLabel:setString(tStr)
		-- self.pImgLabel:followPos("center",self.pLayBtnBuy:getContentSize().width/2-30, self.pLayBtnBuy:getContentSize().height + 10, 10)

		if not self.pTip then
			self.pTip=MUI.MLabel.new({text =self.tVipData.orgprice, size = 20})
			self.pTip:setAnchorPoint(0,0.5)
			-- self.pTip:setPosition(self.pLayBtnBuy:getContentSize().width/2+18, self.pLayBtnBuy:getContentSize().height + 10)
			self.pLayBtnBuy:addView(self.pTip)
		else
			self.pTip:setString(self.tVipData.orgprice)
		end
		local  nPosX1 = 0
		local  nPosX2 = 0
		if string.len(tostring(self.tVipData.orgprice)) >=4 then
			nPosX1=self.pLayBtnBuy:getContentSize().width/2-28
			nPosX2=self.pLayBtnBuy:getContentSize().width/2+17
		else
			nPosX1=self.pLayBtnBuy:getContentSize().width/2-20
			nPosX2=self.pLayBtnBuy:getContentSize().width/2+25
		end
    	self.pTip:setPosition(nPosX2, self.pLayBtnBuy:getContentSize().height + 10)
    	self.pImgLabel:followPos("center",nPosX1, self.pLayBtnBuy:getContentSize().height + 10, 5)


    	self.pBtnBuy:updateBtnText("")

    	--按钮上的文字
    	if  not self.pBtnLabel then 
    		self.pBtnLabel = MImgLabel.new({text="", size = 20, parent =self.pLayBtnBuy})
			self.pBtnLabel:setImg(getCostResImg(e_type_resdata.money), 0.75, "left")
			self.pBtnLabel:followPos("center",self.pLayBtnBuy:getContentSize().width/2, self.pLayBtnBuy:getContentSize().height/2, 1)
    	end
    	local tStr2 = {
    		{color=_cc.white, text=string.format(getConvertedStr(9,10001),self.tVipData.nowprice)},
    	}
		self.pBtnLabel:setString(tStr2)

    	if Player:getPlayerInfo():getIsBoughtVipGift(self.tVipData.lv) then
    		self.pBtnBuy:setBtnEnable(false)
    		self.pLayBtnBuy:setVisible(false)

    		self.pImgFlag:setVisible(true)

    		self.pBtnBuy:removeLingTx()
    	else
    		self.pBtnBuy:setBtnEnable(true)
    		self.pLayBtnBuy:setVisible(true)
    		self.pImgFlag:setVisible(false)

    		self.pBtnBuy:showLingTx()
    	end
    end
end

--tVipData:表格数据
function ItemVipGit:setData( tVipData )
	self.tVipData = tVipData
	self:updateViews()
end

function ItemVipGit:onBuyClicked( pView )
	if not self.tVipData then
		return
	end
	--二次弹窗
	local function sendReq(  )
		-- dump({self.tVipData.lv})
		SocketManager:sendMsg("buyVipGift", {self.tVipData.lv})
	end
	local sName = string.format(getConvertedStr(3, 10333), self.tVipData.lv)
	local tStr = {
    	{color = _cc.pwhite, text = getConvertedStr(3, 10280)},
    	{color = _cc.yellow, text = string.format(getConvertedStr(3, 10281),self.tVipData.nowprice)},
    	{color = _cc.pwhite, text = getConvertedStr(3, 10312)},
    	{color = _cc.yellow, text = sName},
    }
    showBuyDlg(tStr, self.tVipData.nowprice, sendReq, 1)
end


return ItemVipGit


