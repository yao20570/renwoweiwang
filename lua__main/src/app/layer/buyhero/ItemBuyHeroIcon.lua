-- Author: liangzhaowei
-- Date: 2017-06-14 11:54:28
-- 展示物品item

local MCommonView = require("app.common.MCommonView")
local ItemBuyHeroIcon = class("ItemBuyHeroIcon", function()
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

--创建函数
function ItemBuyHeroIcon:ctor()
	-- body
	self:myInit()

	parseView("item_buy_hero_icon", handler(self, self.onParseViewCallback))


	--注册析构方法
	self:setDestroyHandler("ItemBuyHeroIcon",handler(self, self.onDestroy))
	
end

--初始化参数
function ItemBuyHeroIcon:myInit()
	self.pData = {} --数据
	self.tIcon = nil
end

--解析布局回调事件
function ItemBuyHeroIcon:onParseViewCallback( pView )

	self:setContentSize(pView:getContentSize())
	self:addView(pView)
	centerInView(self, pView)

	--ly      
	self.pLyMain = self:findViewByName("ly_main")


	--lb
	--self.pLbN = self:findViewByName("lb_n")
	

	self:setupViews()
	self:updateViews()
end

--初始化控件
function ItemBuyHeroIcon:setupViews( )

end

-- 修改控件内容或者是刷新控件数据
function ItemBuyHeroIcon:updateViews(  )
	-- body
end

--析构方法
function ItemBuyHeroIcon:onDestroy(  )
	-- body
end

--设置数据 _data
function ItemBuyHeroIcon:setCurData(_tData)
	if not _tData then
		return
	end

	self.pData = _tData or {}
	if table.nums(self.pData) > 0  then
		refreshAllIcons(self.pLyMain,self.pData,4,TypeIconGoods.HADMORE,type_icongoods_show.itemnum,TypeIconGoodsSize.L,1)
	end



end


return ItemBuyHeroIcon