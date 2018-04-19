----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-10-24 17:53:12
-- Description: 武王奖励兑换 子项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemWuWangExchange = class("ItemWuWangExchange", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemWuWangExchange:ctor(  )
	--解析文件
	parseView("item_wuwangexchange", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemWuWangExchange:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("item_wuwangexchange", handler(self, self.onItemWuWangExchangeDestroy))
end

-- 析构方法
function ItemWuWangExchange:onItemWuWangExchangeDestroy(  )
    self:onPause()
end

function ItemWuWangExchange:regMsgs(  )
end

function ItemWuWangExchange:unregMsgs(  )
end

function ItemWuWangExchange:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function ItemWuWangExchange:onPause(  )
	self:unregMsgs()
end

function ItemWuWangExchange:setupViews(  )
	self.pLayGoods1 = self:findViewByName("lay_goods1")
	self.pLayGoods2 = self:findViewByName("lay_goods2")

	local pLayBtn = self:findViewByName("lay_btn")
	self.pBtnExchange = getCommonButtonOfContainer(pLayBtn ,TypeCommonBtn.M_BLUE, getConvertedStr(3, 10487), false)
	self.pBtnExchange:onCommonBtnClicked(handler(self, self.onExchnageClicked))
	self.pBtnExchange:onCommonBtnDisabledClicked(handler(self, self.onDisabledClicked))

	self.pTxtTip = self:findViewByName("txt_tip")
end

function ItemWuWangExchange:updateViews(  ) 
	if not self.tData then
		return
	end

	--消耗图标
	local nGoodsId, nCostNum = self.tData:getCostGoods() 
	if nGoodsId then
		local tGoods = getGoodsByTidFromDB(nGoodsId)
		local pIcon = getIconGoodsByType(self.pLayGoods1, TypeIconGoods.HADMORE, type_icongoods_show.item, tGoods, TypeIconGoodsSize.M)
		pIcon:setMoreText(tGoods.sName)
		pIcon:setMoreTextColor(getColorByQuality(tGoods.nQuality))

		local sColor = _cc.green
		local nCurrNum = getMyGoodsCnt(nGoodsId)
		if nCurrNum < nCostNum then
			sColor = _cc.red
		end
		local tStr = {
		    {color=sColor,text=tostring(nCurrNum)},
		    {color=_cc.white,text="/"..nCostNum}, 
		}
		--分子消耗数/分母拥有数
		pIcon:setCostStr(tStr)
	end

	--获取图标
	local nGoodsId, nGetNum = self.tData:getExchangeGoods() 
	if nGoodsId then
		local tGoods = getGoodsByTidFromDB(nGoodsId)
		local pIcon = getIconGoodsByType(self.pLayGoods2, TypeIconGoods.HADMORE, type_icongoods_show.item, tGoods, TypeIconGoodsSize.M)
		pIcon:setMoreText(tGoods.sName)
		pIcon:setMoreTextColor(getColorByQuality(tGoods.nQuality))
		pIcon:setNumber(nGetNum)
	end

	--是否可兑换
	local bIsCanExchange, nFalseState = self.tData:getIsCanExchange()
	if bIsCanExchange then
		self.pBtnExchange:setBtnEnable(true)
	else
		self.pBtnExchange:setBtnEnable(false)
	end
	--错误码
	if nFalseState == 1 then
		local tStr = {
            {color=_cc.red,text=string.format(getConvertedStr(3, 10489), self.tData.nLv)},
        }
		self.pTxtTip:setString(tStr)
	else
		local sColor = _cc.white
		local nExchanged = 0
		local tActData = Player:getActById(e_id_activity.wuwang)
		if tActData and tActData.tExchangeMsg then
			nExchanged = tActData.tExchangeMsg:getGoodsExchanged(self.tData.nId)
		end
		if nExchanged >= self.tData.nExchangeMax then
			sColor = _cc.red
		end
		local tStr = {
            {color= _cc.pwhite,text=getConvertedStr(3, 10490)},
            {color= sColor,text= math.max(self.tData.nExchangeMax - nExchanged, 0)},
            {color= _cc.white,text= "/"..tostring(self.tData.nExchangeMax)},
        }
        self.pTxtTip:setString(tStr)
	end
end

function ItemWuWangExchange:onExchnageClicked(  )
	if not self.tData then
		return
	end

	local bIsCanExchange, nFalseState = self.tData:getIsCanExchange()
	if bIsCanExchange then
 		SocketManager:sendMsg("reqWuWangExchange",{self.tData.nId})
	else
		if nFalseState == 1 then
			TOAST(getConvertedStr(3, 10492))
		elseif nFalseState == 2 then
			TOAST(getConvertedStr(3, 10493))
		elseif 	nFalseState == 3 then
			TOAST(getConvertedStr(3, 10491))
		end
	end
end

function ItemWuWangExchange:onDisabledClicked(  )
	if not self.tData then
		return
	end

	local bIsCanExchange, nFalseState = self.tData:getIsCanExchange()
	if nFalseState == 1 then
		TOAST(getConvertedStr(3, 10492))
	elseif nFalseState == 2 then
		TOAST(getConvertedStr(3, 10493))
	elseif 	nFalseState == 3 then
		TOAST(getConvertedStr(3, 10491))
	end
end

--tData: ExchangeVO
function ItemWuWangExchange:setData( tData )
	self.tData = tData
	self:updateViews()
end

return ItemWuWangExchange


