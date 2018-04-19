-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-04-11 14:49:23 星期三
-- Description: 发展礼包
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")
local MImgLabel = require("app.common.button.MImgLabel")

local ItemDevelopGift = class("ItemDevelopGift", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)
 
function ItemDevelopGift:ctor()
	-- body
	self:myInit()

	parseView("item_develop_gift", handler(self, self.onParseViewCallback))
end

--初始化参数
function ItemDevelopGift:myInit()
	-- body
	self.pData = nil
end

--解析布局回调事件
function ItemDevelopGift:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)
	self:setupViews()
	self:updateViews()
	--注册析构方法
	self:setDestroyHandler("ItemDevelopGift",handler(self, self.onDestroy))	
end

--初始化控件
function ItemDevelopGift:setupViews( )
	-- body
	self.pLayBtn = self:findViewByName("lay_btn")
	self.pLayGoods = self:findViewByName("lay_goods")
	self.pLbTitle = self:findViewByName("lb_title")
	self.pLbNum = self:findViewByName("lb_num")

	self.pBtn = getCommonButtonOfContainer(self.pLayBtn, TypeCommonBtn.M_BLUE, "", false)
	self.pBtn:onCommonBtnClicked(handler(self, self.onBuyBtnCallBack))

	self.pImgLabel = MImgLabel.new({text="", size = 20, parent = self.pLayBtn})		
	self.pImgLabel:followPos("center", 65, 70, 10)		
	self.pImgLabel:hideImg()
end

-- 修改控件内容或者是刷新控件数据
function ItemDevelopGift:updateViews(  )
	-- body
	if not self.pData then
		return
	end
	local pData = self.pData	
	local sNum = {
		{color=_cc.white,text=getConvertedStr(6, 10852)},
		{color=_cc.blue,text=pData.nBuy},
		{color=_cc.white,text="/"..pData.limit},
	}
	self.pLbNum:setString(sNum, false)
	self.pLbTitle:setString(pData.sTitle, false)
	local sOrgPrice = {
		{color=_cc.white,text=getRMBStr(pData.price)},		
	}
	self.pImgLabel:setString(sOrgPrice)
	self.pImgLabel:showRedLine(true, nil, "all")   

	if pData.nBuy < pData.limit then
		local pRecharge = getRechargeDataByKey(pData.pid)
		if pRecharge then
			self.pBtn:updateBtnText(getRMBStr(pRecharge.price))
		end
		self.pBtn:setBtnEnable(true)
	else
		self.pBtn:setBtnEnable(false)
		self.pBtn:updateBtnText(getConvertedStr(6, 10418))
	end
	--物品排序
	sortGoodsList(pData.ob)
	local tGoods = {}
	--物品解析
	for i, v in pairs(pData.ob) do
		local pitem = getGoodsByTidFromDB(v.k)
		if pitem then
			pitem.nCt = v.v
			table.insert(tGoods, pitem)
		end				
	end	
	gRefreshHorizontalList(self.pLayGoods, tGoods)	
end

function ItemDevelopGift:setCurData( _tData )
	-- body
	if not _tData then
		return
	end
	self.pData = _tData or self.pData
	self:updateViews()
end

function ItemDevelopGift:onBuyBtnCallBack( _pView )
	-- body
	if not self.pData then
		return
	end
	local pData = self.pData
	reqRecharge( getRechargeDataByKey(pData.pid) )
end

--析构方法
function ItemDevelopGift:onDestroy(  )
	-- body	
end

return ItemDevelopGift