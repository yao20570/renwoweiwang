-- ItemSpecialSale.lua
---------------------------------------------
-- Author: dshulan
-- Date: 2017-07-05 15:37:00
-- 特价卖场列表项
---------------------------------------------

local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")

local ItemSpecialSale = class("ItemSpecialSale", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemSpecialSale:ctor()
	-- body	
	self:myInit(_index)	
	parseView("item_special_sale", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemSpecialSale:myInit()
	-- body
	self.tCurData  = nil 				--当前数据
	self.tItemList = {}
end

--解析布局回调事件
function ItemSpecialSale:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemSpecialSale",handler(self, self.onItemSpecialSaleDestroy))
end

--初始化控件
function ItemSpecialSale:setupViews()
	-- body
	self.pLayRoot    = self:findViewByName("default")

	--lb
	self.pLbXin      = self:findViewByName("lb_xin")
	
	self.pLayBuyBtn = self:findViewByName("lay_btn")
	--购买按钮
	self.pBuyBtn = getCommonButtonOfContainer(self.pLayBuyBtn, TypeCommonBtn.M_YELLOW, getConvertedStr(7, 10079))
	self.pBuyBtn:onCommonBtnClicked(handler(self, self.onBuyBtnClicked))

	--物品图标层
	self.pLayGoods   = self:findViewByName("lay_items")
	--原价
	self.lbOriPrice = self:createPriceLb(getConvertedStr(7, 10113), "￥", 200, _cc.pwhite, _cc.yellow, _cc.pwhite, cc.p(498, 129))
	--加红线
	self.lbOriPrice:addRedLine(1, true)
	--现价
	self.lbNowPrice = self:createPriceLb(getConvertedStr(7, 10114), "￥", 100, _cc.pwhite, _cc.yellow, _cc.pwhite, cc.p(498, 99))
	--限购
	self.lbLimitBuy = self:createPriceLb(getConvertedStr(7, 10117), 0, "/"..5, _cc.green, _cc.green, _cc.green, cc.p(498, 18), 18)
end

--价格组合文本
function ItemSpecialSale:createPriceLb(_str1, _str2, _str3, _color1, _color2, _color3, _pos, _fontSize)
	-- body
	local tConTable = {}
	--文本
	tConTable.tLabel= {
		{_str1, getC3B(_color1)},
		{_str2, getC3B(_color2)},
		{_str3, getC3B(_color3)},
	}
	tConTable.fontSize = 20
	if _fontSize then
		tConTable.fontSize = _fontSize
	end
	local pText = createGroupText(tConTable)
	pText:setAnchorPoint(cc.p(0.5, 0.5))
	self.pLayRoot:addView(pText, 10)
	pText:setPosition(_pos)
	return pText
end

-- 修改控件内容或者是刷新控件数据
function ItemSpecialSale:updateViews()
	if not self.nCurIdx then return end
	local tAc = Player:getActById(e_id_activity.specialsale)
	self.tAc = tAc
	self.tCurData = tAc.tGoodsList[self.nCurIdx]

	self.lbOriPrice:setLabelCnCr(3, self.tCurData.oriPrice)
	self.lbNowPrice:setLabelCnCr(3, self.tCurData.price)
	self.lbLimitBuy:setLabelCnCr(3, "/"..self.tCurData.limit)

	self:setGoodsListViewData(self.tCurData.award)

	--剩余购买次数
	self.lbLimitBuy:setLabelCnCr(2, tAc:getBuyTimes(self.tCurData.index))

	--礼包名称
	local sName = tAc:getGiftName(self.tCurData.index)
	self.pLbXin:setString(sName)

	--购买限制
	if tAc:isCanBuy(self.tCurData.index) then
		self.pBuyBtn:setBtnEnable(true)
		self.pBuyBtn:updateBtnText(getConvertedStr(7,10079))
	else
		self.pBuyBtn:setBtnEnable(false)
		self.pBuyBtn:updateBtnText(getConvertedStr(7,10115))
	end
end

--设置数据
-- tItemList:List<Pair<Integer,Long>>
function ItemSpecialSale:setGoodsListViewData(tItemList)
	if not tItemList then
		return
	end
	local tCurDatas = getRewardItemsFromSever(tItemList)
	-- for i, v in pairs(tItemList) do
	-- 	local nGoodsId = v.k
	--     local nCt = v.v
	--     local pGoods = getGoodsByTidFromDB(nGoodsId)
	--     pGoods.nCt = nCt
	--     tCurDatas[#tCurDatas+1] = pGoods
	-- end
    gRefreshHorizontalList(self.pLayGoods, tCurDatas)
end

--领取奖励按钮回调
function ItemSpecialSale:onBuyBtnClicked( pView )
	-- body
	-- SocketManager:sendMsg("reqBuySaleGoods", {self.tCurData.type}, function(__msg)
	-- 	-- body
	-- 	-- dump(__msg.body, "购买得到物品")
	-- 	if __msg.body and __msg.body.ob then
	-- 		showGetAllItems(__msg.body.ob, 1)
	-- 	end
	-- end)

	--请求充值
	local tRechargeData = self.tAc:getRechargeInfo(self.tCurData.uid)
	--请求充值哦
	reqRecharge(tRechargeData)
end

-- 析构方法
function ItemSpecialSale:onItemSpecialSaleDestroy()
	-- body
end

-- 设置单项数据
function ItemSpecialSale:setItemData(_index)
  	self.nCurIdx = _index
	self:updateViews()
end



return ItemSpecialSale