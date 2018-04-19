-----------------------------------------------------
-- author: maheng
-- updatetime:  2018-03-5 15:23:55 星期一
-- Description: 加速道具显示
-----------------------------------------------------


local MCommonView = require("app.common.MCommonView")
local IconGoods = require("app.common.iconview.IconGoods")
local ItemPropGood = class("ItemPropGood", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)

function ItemPropGood:ctor(  )
	-- body
	self:myInit()
	parseView("item_prop_good", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemPropGood:myInit(  )
	-- body
	self.tCurData 			= 		nil 			--当前数据
end

--解析布局回调事件
function ItemPropGood:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()

	--注册析构方法
	self:setDestroyHandler("ItemPropGood",handler(self, self.onDestroy))
end

--初始化控件
function ItemPropGood:setupViews( )
	-- body
	self.pLayRoot 			= self:findViewByName("lay_root")
	--线
	self.pLayIcon 			= self:findViewByName("lay_icon")
	if not self.pIconGood then
		self.pIconGood = IconGoods.new(TypeIconGoods.HADMORE, type_icongoods_show.itemnum)
		-- self.pIconGood:setIconClickedCallBack(handler(self, self.onItemIconClick))
		self.pIconGood:setPosition(0, 0)
		self.pLayIcon:addView(self.pIconGood, 10)	
	end
end

-- 修改控件内容或者是刷新控件数据
function ItemPropGood:updateViews(  )
	-- body
	if self.tCurData then
		local pData = self.tCurData
		self.pIconGood:setCurData(pData)	
		self.pIconGood:setIsShowBgQualityTx(false)	
		self.pIconGood:setNumber(pData.nCt, false, true)
		self.pIconGood:setVisible(pData ~= nil)
	end
end

-- 析构方法
function ItemPropGood:onDestroy(  )
	-- body

end

--设置当前数据
function ItemPropGood:setCurData( _tData )
	-- body
	self.tCurData = _tData
	self:updateViews()
end

--获得当前数据
function ItemPropGood:getCurData(  )
	-- body
	return self.tCurData
end

function ItemPropGood:setActionHandler( _nHandler )
	-- body
	if self.pIconGood then
		self.pIconGood:setIconClickedCallBack(_nHandler)
	end
end

function ItemPropGood:setSelected( _bSelected )
	-- body
	local bSelected = _bSelected or false	
	if self.pIconGood then
		self.pIconGood:setIconSelected(bSelected,true)
	end
end

return ItemPropGood