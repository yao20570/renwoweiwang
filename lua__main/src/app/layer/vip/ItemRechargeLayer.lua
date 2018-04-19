
-----------------------------------------------------
-- author: maheng
-- updatetime:  2017-05-31 11:12:23 星期三
-- Description: 充值项
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemRechargeLayer = class("ItemRechargeLayer", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function ItemRechargeLayer:ctor()
	-- body
	self:myInit()

	parseView("item_recharge_layer", handler(self, self.onParseViewCallback))

	--注册析构方法
	self:setDestroyHandler("ItemRechargeLayer",handler(self, self.onItemRechargeLayerDestroy))	
end

--初始化参数
function ItemRechargeLayer:myInit()
	-- body
	self.tCurData = nil
end

--解析布局回调事件
function ItemRechargeLayer:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemRechargeLayer:setupViews( )
	--body
	self.pLayRoot = self:findViewByName("root")
	self.pImgIcon = self:findViewByName("img_icon")
	self.pImgCost = self:findViewByName("img_cost")
	self.pLayBtn = self:findViewByName("lay_btn")
	self.pBuyBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.L_YELLOW, getRMBStr(0), true)
	self.pBuyBtn:onCommonBtnClicked(handler(self, self.onRechargeClicked))
end

-- 修改控件内容或者是刷新控件数据
function ItemRechargeLayer:updateViews(  )
	-- body	
	if self.tCurData then		
		--
		if self.tCurData.icon then
			self.pImgIcon:setCurrentImage("#"..self.tCurData.icon..".png")
		end
		if self.tCurData.nameicon then
			self.pImgCost:setCurrentImage("#"..self.tCurData.nameicon..".png")
		end
		self.pBuyBtn:updateBtnText(getRMBStr(self.tCurData.price))
	end	
end

-- 月卡充值点击
function ItemRechargeLayer:onRechargeClicked(  )
	--请求充值哦
	reqRecharge( self.tCurData )
end

--析构方法
function ItemRechargeLayer:onItemRechargeLayerDestroy(  )
	-- body
end


--设置数据
function ItemRechargeLayer:setCurData( _data )
	-- body
	self.tCurData = _data or self.tCurData
	self:updateViews()
end

return ItemRechargeLayer