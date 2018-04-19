----------------------------------------------------- 
-- author: maheng
-- updatetime: 2017-06-06 19:48:14
-- Description: 国家界面快速入口
-----------------------------------------------------

local MCommonView = require("app.common.MCommonView")

local ItemCountryEntry = class("ItemCountryEntry", function()
	-- body
	return MCommonView.new(TYPE_LAYER.LAYER_MLAYER)
end)


function ItemCountryEntry:ctor(  )
	-- body
	self:myInit()
	parseView("item_entry", handler(self, self.onParseViewCallback))
end

--初始化成员变量
function ItemCountryEntry:myInit(  )
	-- body

end

--解析布局回调事件
function ItemCountryEntry:onParseViewCallback( pView )
	-- body
	self:setLayoutSize(pView:getLayoutSize())
	self:addView(pView)

	self:setupViews()
	self:updateViews()

	--注册析构方法
	self:setDestroyHandler("ItemCountryEntry",handler(self, self.onItemCountryEntryDestroy))
end

--初始化控件
function ItemCountryEntry:setupViews( )
	-- body
	--图标
	self.pImgIcon = self:findViewByName("img_icon")
	self.pImgIcon:setScale(0.8)
	--入口名字
	self.pLbTitle = self:findViewByName("lb_title")
	self.pLbTitle:setString(getConvertedStr(6, 10320))	

	--
	self.pLayRed = self:findViewByName("lay_red")
		
end

-- 修改控件内容或者是刷新控件数据
function ItemCountryEntry:updateViews( )
	-- body
	
end

-- 析构方法
function ItemCountryEntry:onItemCountryEntryDestroy(  )
	-- body
end

--设置文字
function ItemCountryEntry:setTitle( sStr )
	-- body
	if sStr then
		self.pLbTitle:setString(sStr)
	end
end

--设置图标
function ItemCountryEntry:setImg( _img )
	-- body
	if _img then
		self.pImgIcon:setCurrentImage(_img)
	end
end

function ItemCountryEntry:updateRedTips( nNum )
	-- body
	showRedTips(self.pLayRed, 0, nNum)
end
return ItemCountryEntry


