----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-06-10 15:57:44
-- Description: 珍宝阁  卡牌
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local nCenterIndex = 5
local ItemTreasure = class("ItemTreasure", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemTreasure:ctor( nIndex )
	self.nIndex = nIndex
	--解析文件
	parseView("item_treasure", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemTreasure:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemTreasure", handler(self, self.onItemTreasureDestroy))
end

-- 析构方法
function ItemTreasure:onItemTreasureDestroy(  )
    self:onPause()
end

function ItemTreasure:regMsgs(  )
	regMsg(self, gud_shop_data_update_msg, handler(self, self.updateViews))	
	regMsg(self, ghd_treasure_shop_flip_card_msg, handler(self, self.onCardFilp))
end

function ItemTreasure:unregMsgs(  )
	unregMsg(self, gud_shop_data_update_msg)
	unregMsg(self, ghd_treasure_shop_flip_card_msg)
end

function ItemTreasure:onResume(  )
	self:updateViews()
	self:regMsgs()
end

function ItemTreasure:onPause(  )
	self:unregMsgs()
end

function ItemTreasure:setupViews(  )
	self.pLayInfo = self:findViewByName("lay_info")
	self.pLayInfo:setVisible(false)
	self.pLayBgCenter = self:findViewByName("lay_bg_center")
	self.pLayBgOther = self:findViewByName("lay_bg_other")
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pImgCost = self:findViewByName("img_cost")
	--self.pImgCost:setScale(0.3, 0.3)
	self.pTxtCost = self:findViewByName("txt_cost")
	self.pLayBgCover = self:findViewByName("lay_bg_cover")
	self.pLayBgCover:setViewTouched(true)
	self.pLayBgCover:setIsPressedNeedScale(false)
	self.pLayBgCover:onMViewClicked(handler(self, self.onBgCoverClicked))

	self:setViewTouched(true)
	self:setIsPressedNeedScale(false)
	self:onMViewClicked(handler(self, self.onBuyClicked))
end

function ItemTreasure:updateViews(  )
	if not self.nIndex then
		return
	end

	--卡牌重置
	self:cardReset()

	--中间特殊显示背景
	if self.nIndex == nCenterIndex then
		self.pLayBgCenter:setVisible(true)
		self.pLayBgOther:setVisible(false)
	else
		self.pLayBgCenter:setVisible(false)
		self.pLayBgOther:setVisible(true)
	end

	--今天是否已买显示
	local bIsBought = Player:getShopData():getIsBoughtTreasure()
	if bIsBought then
		self.pLayBgCover:setVisible(false)
		self.pLayInfo:setVisible(true)
	else
		--是否已翻
		if Player:getShopData():getCardIsFliped(self.nIndex) then
			self.pLayBgCover:setVisible(false)
			self.pLayInfo:setVisible(true)
		else
			self.pLayBgCover:setVisible(true)	
			self.pLayInfo:setVisible(false)
		end
	end

	local tTreasureIdList = Player:getShopData():getTreasureIdList()
	local nId = tTreasureIdList[self.nIndex]
	if not nId then
		return
	end
	self.nExchangeId = nId
		
	--如果打开了就要显示数据
	if self.pLayBgCover:isVisible() == false then
		self:setCardInfo()
	end
end

--设置卡牌数据
function ItemTreasure:setCardInfo(  )
	local nId = self.nExchangeId

	local tTreasure = getShopTreasure(nId)
	if not tTreasure then
		return
	end
	self.tTreasure = tTreasure
	local pItemData = getGoodsByTidFromDB(tTreasure.id)
	if not pItemData then
		return
	end
	self.pItemData = pItemData

	--图标
	local pIcon = getIconGoodsByType(self.pLayIcon, TypeIconGoods.HADMORE, type_icongoods_show.item, pItemData)
	pIcon:setMoreText(pItemData.sName)
	pIcon:setMoreTextColor(getColorByQuality(pItemData.nQuality))
	pIcon:setNumber(tTreasure.num)
	pIcon:setIconIsCanTouched(false)

	--消耗
	if tTreasure.nCostId and tTreasure.nCost then
		local sImg = getCostResImg(tTreasure.nCostId)
		if sImg then
			self.pImgCost:setCurrentImage(sImg)
		end
		self.pTxtCost:setString(tTreasure.nCost)
	end
end

function ItemTreasure:onBuyClicked( pView )
	local bIsBought = Player:getShopData():getIsBoughtTreasure()
	if bIsBought then
		TOAST(getTipsByIndex(621))
		return
	end
	--已翻
	if Player:getShopData():getCardIsFliped(self.nIndex) then
		if self.tTreasure and self.pItemData then
			-- if self.tTreasure.nCostId == e_type_resdata.money then
				local sCostName = getCostResName(self.tTreasure.nCostId)
				local sItemName = self.pItemData.sName
				local tStr = {
			    	{color = _cc.pwhite, text = getConvertedStr(3, 10311)},
			    	{color = _cc.yellow, text = tostring(self.tTreasure.nCost) .. sCostName},
			    	{color = _cc.pwhite, text = getConvertedStr(3, 10312)},
			    	{color = _cc.blue, text = sItemName},
			    }
				showBuyDlg(tStr, self.tTreasure.nCost, handler(self, self.onBuyTreasure), 1, true, self.tTreasure.nCostId)
			-- else
			-- 	if checkIsResourceEnough(self.tTreasure.nCostId, self.tTreasure.nCost, true) then
			-- 		self:onBuyTreasure()
			-- 	end
			-- end
		end
	else
		
	end
end

function ItemTreasure:onBuyTreasure()
	if not self.nExchangeId then
		return
	end
	SocketManager:sendMsg("reqTreasureShopBuy",{self.nExchangeId})
end

function ItemTreasure:onBgCoverClicked( pView )
	if not self.nExchangeId then
		return
	end

	local nCd = Player:getShopData():getFlipCardCd()
	--有cd时间
	if nCd > 0 then
		local tObject = {
		    nType = e_dlg_index.treasureunknow, --dlg类型
		    nExchangeId = self.nExchangeId,
		}
		sendMsg(ghd_show_dlg_by_type, tObject)
	else
		SocketManager:sendMsg("reqTreasureShopFlip",{self.nExchangeId})
	end
end


-- --卡牌翻转效果1
-- function ItemTreasure:showCardFlip(  )
-- 	--内容翻转
-- 	local fDt = 0.8
-- 	local function showInfo(  )

-- 		local orbit1 = cc.OrbitCamera:create(fDt/2,1, 0, 90, -90, 0, 0) 
-- 		local seqAct = cc.Sequence:create(
-- 			-- cc.CallFunc:create(function()
-- 				-- cc.Director:getInstance():setProjection( cc.DIRECTOR_PROJECTION3_D)
-- 			-- end)
-- 			)
-- 		local pAction = cc.Spawn:create(orbit1,seqAct)
-- 		self.pLayInfo:runAction(pAction)  
-- 		self.pLayInfo:setVisible(true)
-- 	end
-- 	-- cc.Director:getInstance():setProjection( cc.DIRECTOR_PROJECTION2_D)
-- 	--背景翻转
-- 	local orbit1 = cc.OrbitCamera:create(fDt,1, 0, 0, -180, 0, 0) 
-- 	local seqAct = cc.Sequence:create(
-- 		cc.DelayTime:create(fDt/2),
-- 		cc.Hide:create(),
-- 		cc.CallFunc:create(showInfo))
-- 	local pAction = cc.Spawn:create(orbit1,seqAct)
-- 	self.pLayBgCover:runAction(pAction)
-- 	self.pLayBgCover:setTouchEnabled(false)
-- end

--卡牌翻转效果2
function ItemTreasure:showCardFlip(  )
	--内容翻转
	local fDt = 0.4
	local function showInfo(  )
		self.pLayInfo:setScaleX(0)
		self.pLayInfo:setVisible(true)
		self.pLayBgCover:setScaleX(1)
		local pLayInfoAct = cc.Sequence:create(
			cc.ScaleTo:create(fDt, 1, 1),
			cc.CallFunc:create(function()
				self.bIsFliping = false
			end)
		)
		self.pLayInfo:runAction(pLayInfoAct)  
	end
	--背景翻转
	self.pLayBgCover:setScaleX(1)
	local pLayBgAct = cc.Sequence:create(
		cc.ScaleTo:create(fDt, 0, 1),
		cc.Hide:create(),
		cc.CallFunc:create(showInfo)
		)
	self.pLayBgCover:runAction(pLayBgAct)
	self.pLayBgCover:setTouchEnabled(false)
	self.bIsFliping = true
end

--卡牌重置
function ItemTreasure:cardReset()
	if self.bIsFliping then
		self.pLayBgCover:stopAllActions()
		self.pLayBgCover:setScaleX(1)
		self.pLayBgCover:setVisible(true)

		self.pLayInfo:stopAllActions()
		self.pLayInfo:setVisible(false)
		self.bIsFliping = false
	end
end

--卡牌翻转消息监听
function ItemTreasure:onCardFilp( sMsgName, pMsgObj )
	if pMsgObj == self.nExchangeId then
		self:setCardInfo()
		self:showCardFlip()
	end
end

return ItemTreasure