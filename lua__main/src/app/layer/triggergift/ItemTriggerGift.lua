----------------------------------------------------- 
-- author: zhangnianfeng
-- updatetime: 2017-11-20 14:38:29
-- Description: 触发式礼包 item
-----------------------------------------------------
local MCommonView = require("app.common.MCommonView")

local ItemTriggerGift = class("ItemTriggerGift", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemTriggerGift:ctor()
	--解析文件
	parseView("item_trigger_gift", handler(self, self.onParseViewCallback))
end

--解析界面回调
function ItemTriggerGift:onParseViewCallback( pView )
	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	self:setupViews()
	self:onResume()

	--注册析构方法
	self:setDestroyHandler("ItemTriggerGift", handler(self, self.onItemTriggerGiftDestroy))
end

-- 析构方法
function ItemTriggerGift:onItemTriggerGiftDestroy(  )
    self:onPause()
end

function ItemTriggerGift:regMsgs(  )
end

function ItemTriggerGift:unregMsgs(  )
end

function ItemTriggerGift:onResume(  )
	self:regMsgs()
	self:updateViews()
end

function ItemTriggerGift:onPause(  )
	self:unregMsgs()
end

function ItemTriggerGift:setupViews(  )
	self.pLayIcon = self:findViewByName("lay_icon")
	self.pTxtName = self:findViewByName("txt_name")
	setTextCCColor(self.pTxtName, _cc.white)
	self.pTxtNum = self:findViewByName("txt_num")
	setTextCCColor(self.pTxtNum, _cc.white)
	local pLayBg = self:findViewByName("lay_bg")
	local bIsFan = true
	setGradientBackground(pLayBg, bIsFan)
end

function ItemTriggerGift:updateViews(  )
	if not self.tGoods then
		return
	end

	--设置图标
	getIconGoodsByType(self.pLayIcon, TypeIconGoods.NORMAL, type_icongoods_show.item, self.tGoods, TypeIconGoodsSize.M)
	--名字
	self.pTxtName:setString(self.tGoods.sName)
	setLbTextColorByQuality(self.pTxtName, self.tGoods.nQuality)
	--数量
    self.pTxtNum:setString("x"..tostring(self.tGoods.nCt or 0))
end

function ItemTriggerGift:setData( tGoods )
	self.tGoods = tGoods
	self:updateViews()
end

return ItemTriggerGift